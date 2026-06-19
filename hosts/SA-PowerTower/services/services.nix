{ pkgs, config, lib, ... }: {
  nixpkgs.overlays = [
    (final: prev: {
      openrgb-unstable = prev.openrgb.overrideAttrs (oldAttrs: {
        version = "unstable-git";
        src = prev.fetchFromGitHub {
          owner = "CalcProgrammer1";
          repo = "OpenRGB";
          rev = "master";
          hash = "sha256-gaThBFioRSj/d7pOexCvufkMoXUA868NFOccGRMDW40=";
        };
        patches = [];
        postPatch = "patchShebangs scripts/build-udev-rules.sh";
        postInstall = (oldAttrs.postInstall or "") + ''
          if [ -f $out/lib/udev/rules.d/60-openrgb.rules ]; then
            substituteInPlace $out/lib/udev/rules.d/60-openrgb.rules \
              --replace-fail '/usr/bin/env' '${pkgs.coreutils}/bin/env' \
              --replace-quiet '/bin/sh' '${pkgs.bash}/bin/sh'
          fi
        '';
      });
    })
    (final: prev:
    let
      llamaCppSrc = prev.fetchFromGitHub {
        owner = "ggml-org";
        repo = "llama.cpp";
        rev = "6f3a9f3dee3c27545371044a3a38005721ac8a8e";
        hash = "sha256-bO1ucb/+vidj/EYzNCssotjte9NlVLdjC794jToNNeM=";
      };
      ollamaAttrs = oldAttrs: {
        version = "0.30.6";
        src = prev.fetchFromGitHub {
          owner = "ollama";
          repo = "ollama";
          tag = "v0.30.6";
          hash = "sha256-qO+Tsjg64QekGHNNiNy5YGSDoToGSnqiN5hN+0LCp4Q=";
        };
        vendorHash = "sha256-lZdGzGb9xRjTm1Rm7/wHjqM490gLznLEndmb4mNbCX0=";
        postPatch = ''
          substituteInPlace version/version.go \
            --replace-fail 0.0.0 '0.30.6'
          [ -d app ] && rm -r app || true
          sed -i \
            -e '/GIT_REPOSITORY.*ggml-org\/llama\.cpp/d' \
            -e '/GIT_TAG.*OLLAMA_LLAMA_CPP_GIT_TAG/d' \
            -e '/GIT_SHALLOW TRUE/d' \
            -e '/PATCH_COMMAND.*OLLAMA_LLAMA_CPP_COMPAT_PATCH_COMMAND/d' \
            cmake/local.cmake
          sed -i 's/ExternalProject_Add(ollama-llama-cpp-source/ExternalProject_Add(ollama-llama-cpp-source\n    DOWNLOAD_COMMAND ""/' cmake/local.cmake
        '';
        preBuild = ''
          llamaCppDir="$(mktemp -d)"
          cp -r ${llamaCppSrc}/. "$llamaCppDir/"
          chmod -R u+w "$llamaCppDir/"
          ollamaCompatDir="$PWD/llama/compat"
          tmpHome="$(mktemp -d)"
          (
            export HOME="$tmpHome"
            export GIT_CONFIG_NOSYSTEM=1
            cd "$llamaCppDir"
            git init -q
            git config user.email "nix@build"
            git config user.name "Nix Build"
            git add -A
            git commit -q -m "vendor"
            find "$ollamaCompatDir" -name "*.patch" | sort | while read -r pf; do
              git apply --whitespace=nowarn "$pf"
            done
          )
          export OLLAMA_LLAMA_CPP_SOURCE="$llamaCppDir"
          cmake -B build \
            -DOLLAMA_LLAMA_BACKENDS=cuda_v12 \
            -DCMAKE_SKIP_BUILD_RPATH=ON \
            -DCMAKE_BUILD_WITH_INSTALL_RPATH=ON \
            -DCMAKE_CUDA_ARCHITECTURES='89'
          cmake --build build -j $NIX_BUILD_CORES
        '';
        preFixup = ''
          find $out/lib/ollama -type f | while read -r f; do
            patchelf --set-rpath '${final.stdenv.cc.cc.lib}/lib:$ORIGIN' "$f" 2>/dev/null || true
          done
        '';
        ldflags = [
          "-X=github.com/ollama/ollama/version.Version=0.30.6"
          "-X=github.com/ollama/ollama/server.mode=release"
        ];
        doCheck = false;
        doInstallCheck = false;
      };
    in {
      ollama = prev.ollama.overrideAttrs ollamaAttrs;
      ollama-cuda = prev.ollama-cuda.overrideAttrs ollamaAttrs;
    })
  ];
  services = {
    openrgb-effects.enable = true;
    hardware = {
      deepcool-digital-linux.enable = true;
      openrgb = {
        enable = true;
        package = pkgs.openrgb-unstable;
        motherboard = "amd";
      };
    };
    udev.extraRules = ''
      SUBSYSTEM=="kvmfr", OWNER="root", GROUP="kvm", MODE="0660"
      ACTION=="add", SUBSYSTEM=="usb", ATTRS{idVendor}=="0b05", ATTRS{idProduct}=="1aae", ATTR{power/autosuspend_delay_ms}="-1"
    '';
    openssh = {
      enable = true;
      openFirewall = true;
      settings = {
        PasswordAuthentication = false;
        PermitRootLogin = "no";
      };
    };
    ollama = {
      enable = true;
      package = pkgs.ollama-cuda;
      loadModels = [ "gemma4:26b-a4b-it-qat" ];
      openFirewall = true;
      host = "172.30.0.1";
      environmentVariables = {
        OLLAMA_CONTEXT_LENGTH = "131072";
        OLLAMA_FLASH_ATTENTION = "1";
        OLLAMA_KV_CACHE_TYPE = "q8_0";
      };
    };
  };
  systemd.services.cloudflared = {
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.cloudflared}/bin/cloudflared tunnel --no-autoupdate run --token $TUNNEL_TOKEN";
      EnvironmentFile = config.sops.secrets.cloudflare-token.path;
      Restart = "always";
    };
  };
  systemd = {
    tmpfiles.rules = [ "f /dev/shm/looking-glass 0660 seth qemu-libvirtd -" ];
    services = {
      deepcool-digital-linux.environment.LD_LIBRARY_PATH = "${config.hardware.nvidia.package}/lib";
      systemd-suspend.serviceConfig.Environment = "SYSTEMD_SLEEP_FREEZE_USER_SESSIONS=false";
      reload-systemd-vconsole-setup.serviceConfig.ExecStart = lib.mkForce (pkgs.writeShellScript "reset-console" ''
        until test -c /dev/dri/card1; do sleep 1; done
        ${pkgs.systemd}/lib/systemd/systemd-vconsole-setup
      '');
      # CHAIN OF COMMANDS NEEDED TO SLEEP:
      # -- before suspend --
      # sleep 1; hyprctl dispatch dpms off; sleep 3
      # -- after suspend --
      # hyprctl dispatch dpms on; sleep [some amount of time]; hyprctl reload
      hyprland-pre-suspend = {
        description = "Turn off monitors before suspend";
        before = [ "sleep.target" ];
        wantedBy = [ "sleep.target" ];
        serviceConfig = {
          Type = "oneshot";
          User = "seth";
          ExecStart = "${pkgs.writeShellScript "hyprland-pre-suspend" ''
            export HYPRLAND_INSTANCE_SIGNATURE=$(${pkgs.coreutils}/bin/ls /run/user/$UID/hypr/ 2>/dev/null | ${pkgs.coreutils}/bin/head -n1)
            sleep 1
            ${pkgs.hyprland}/bin/hyprctl dispatch dpms off
            sleep 3
          ''}";
        };
      };
      hyprland-post-resume = {
        description = "Fix monitors after suspend on hybrid GPU setup";
        after = [ "suspend.target" ];
        wantedBy = [ "suspend.target" ];
        serviceConfig = {
          Type = "oneshot";
          User = "seth";
          ExecStart = "${pkgs.writeShellScript "hyprland-post-resume" ''
            export HYPRLAND_INSTANCE_SIGNATURE=$(${pkgs.coreutils}/bin/ls /run/user/$UID/hypr/ 2>/dev/null | ${pkgs.coreutils}/bin/head -n1)
            ${pkgs.hyprland}/bin/hyprctl dispatch dpms on
            sleep 1
            ${pkgs.hyprland}/bin/hyprctl reload
          ''}";
        };
      };
    };
  };
}
