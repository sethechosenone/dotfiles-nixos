{ ... }:
{
  nixpkgs.overlays = [
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
              unidecode
              wheel
            ];
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
