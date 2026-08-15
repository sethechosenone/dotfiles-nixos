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
  ];
}
