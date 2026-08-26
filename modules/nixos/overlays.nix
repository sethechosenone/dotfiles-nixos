{ ... }:
{
  nixpkgs.overlays = [
    # wf-recorder 0.6.0 uses the deprecated AVCodec.sample_fmts field directly,
    # which ffmpeg 9 (now the nixpkgs default) removed outright. ffmpeg 7/8 still
    # carry it (deprecated but present), so build wf-recorder against ffmpeg_7
    # until upstream ports to avcodec_get_supported_config().
    (final: prev: {
      wf-recorder = prev.wf-recorder.override { ffmpeg = final.ffmpeg_7; };
    })

    # onlykey-agent's package.nix uses overridePythonAttrs to build lib-agent
    # (libagent 1.0.6), but overridePythonAttrs concatenates propagatedBuildInputs
    # rather than replacing them. This causes bech32 to appear twice in the closure
    # (once from the local let-binding in package.nix, once from the original
    # libagent 0.15.0's deps), which pythonCatchConflictsPhase rejects.
    # Fix: build lib-agent fresh with an explicit, deduplicated dep list.
    # Remove this overlay once fixed upstream in nixpkgs.
    (final: prev: {
      onlykey-agent =
        let
          py = final.python3.pkgs;
          lib-agent = py.buildPythonPackage rec {
            pname = "lib-agent";
            version = "1.0.6";
            format = "setuptools";
            src = prev.fetchPypi {
              inherit pname version;
              sha256 = "sha256-IrJizIHDIPHo4tVduUat7u31zHo3Nt8gcMOyUUqkNu0=";
            };
            propagatedBuildInputs = with py; [
              bech32
              backports-shutil-which
              configargparse
              cryptography
              cython
              docutils
              ecdsa
              mnemonic
              pymsgbox
              pycryptodome
              pynacl
              python-daemon
              semver
              setuptools
              unidecode
              wheel
            ];
            # Several libagent submodules (gpg, ssh, signify, age) do
            # `import pkg_resources` at module level (used only for --version
            # output). pkg_resources is part of setuptools but is unavailable in the
            # Nix build sandbox even when setuptools is in propagatedBuildInputs.
            # Patch in an importlib.metadata fallback so the import succeeds in both
            # the build check and at runtime without setuptools.
            postPatch = ''
              python3 <<'PYEOF'
              import glob
              compat = '\n'.join([
                'try:',
                '    import pkg_resources',
                'except ImportError:',
                '    import importlib.metadata as _im',
                '    def _req(name):',
                '        try:',
                '            reqs = [r.split()[0].split(";")[0].lower()',
                '                    for r in (_im.metadata(name).get_all("Requires-Dist") or [])]',
                '        except Exception:',
                '            reqs = []',
                '        class _R:',
                '            def __init__(self, k):',
                '                self.key = k',
                '                try: self.version = _im.version(k)',
                '                except Exception: self.version = "unknown"',
                '        return [_R(k) for k in [name] + reqs]',
                '    class pkg_resources:',
                '        require = staticmethod(_req)',
              ])
              for path in glob.glob('libagent/**/*.py', recursive=True):
                  src = open(path).read()
                  if 'import pkg_resources' in src:
                      open(path, 'w').write(src.replace('import pkg_resources', compat, 1))
              PYEOF
            '';
            doCheck = false;
            pythonImportsCheck = [ "libagent" ];
            meta = prev.python3Packages.libagent.meta // {
              description = "Using OnlyKey as hardware SSH and GPG agent";
            };
          };
        in
        py.buildPythonApplication rec {
          pname = "onlykey-agent";
          version = "1.1.15";
          format = "setuptools";
          src = prev.fetchPypi {
            inherit pname version;
            hash = "sha256-SbGb7CjcD7cFPvASZtip56B4uxRiFKZBvbsf6sb8fds=";
          };
          propagatedBuildInputs = [
            lib-agent
            final.onlykey-cli
            py.setuptools
          ];
          postInstall = ''
            mkdir $out/${py.python.sitePackages}/onlykey_agent
            mv $out/bin/onlykey_agent.py $out/${py.python.sitePackages}/onlykey_agent/__init__.py
            chmod a-x $out/${py.python.sitePackages}/onlykey_agent/__init__.py
          '';
          doCheck = false;
          pythonImportsCheck = [ "onlykey_agent" ];
          meta = {
            description = "Middleware that lets you use OnlyKey as a hardware SSH/GPG device";
            homepage = "https://github.com/trustcrypto/onlykey-agent";
            license = final.lib.licenses.lgpl3Only;
            maintainers = with final.lib.maintainers; [ kalbasit ];
          };
        };
    })

    # nixpkgs ships hyprgrass 2026-06-10 against hyprland 0.56.2, but that
    # version predates the 0.56 API reshuffle (Monitor moved, warpCursorTo
    # removed, etc.). Pin to the Aug-2026 HEAD which targets 0.56.x.
    # Remove this overlay once nixpkgs catches up.
    #
    # We must also build against hyprgrass's *vendored* wf-touch submodule
    # rather than nixpkgs' wf-touch package. hyprgrass pins wf-touch
    # 8974eb0; nixpkgs ships 2026-07-18, which:
    #   - made gesture_action_t::exceeds_tolerance non-virtual (nixpkgs
    #     papers over the resulting compile error by sed'ing out `override`)
    #   - added a mandatory timer_interface_t that must be installed via
    #     gesture_t::set_timer() before use.
    # hyprgrass never calls set_timer() (it drives long-press timing itself
    # through wl_event_loop), so assert(priv->timer) in gesture_t::reset()
    # aborts on the first finger-down -- i.e. Hyprland dies on every
    # touchscreen tap. hyprgrass's meson prefers a system `wftouch`
    # pkg-config dep, so dropping wf-touch from buildInputs makes it fall
    # back to the correct submodule.
    (final: prev: {
      hyprlandPlugins = prev.hyprlandPlugins // {
        hyprgrass = prev.hyprlandPlugins.hyprgrass.overrideAttrs (old: {
          version = "0.8.2-unstable-2026-08-13";
          src = final.fetchFromGitHub {
            owner = "horriblename";
            repo = "hyprgrass";
            rev = "56473e9e0b2da34bb3b871e90f40b3fc3d41ba9b";
            fetchSubmodules = true;
            hash = "sha256-wXZ0c/iq6zplYJtd/kSJipKlW64fPypgDNfBYSvyBbg=";
          };
          # The vendored wf-touch declares exceeds_tolerance virtual, so the
          # nixpkgs `override`-stripping sed is both unnecessary and harmful.
          postPatch = "";
          # glm came in transitively via nixpkgs' wf-touch; the vendored
          # subproject needs it declared directly.
          buildInputs = builtins.filter (
            p: !(prev.lib.hasInfix "wf-touch" (p.name or ""))
          ) old.buildInputs ++ [ final.glm ];
          # Keep the test suite on: it exercises the gesture state machine and
          # is what catches a wf-touch mismatch at build time instead of at
          # the first touch.
          doCheck = true;
        });
      };
    })
  ];
}
