{ pkgs, config, ... }: {
  nixpkgs.overlays = [
    (final: prev: {
      openrgb-unstable = prev.openrgb.overrideAttrs (oldAttrs: {
        version = "unstable-git";
        src = prev.fetchFromGitHub {
          owner = "CalcProgrammer1";
          repo = "OpenRGB";
          rev = "master";
          hash = "sha256-XDc/RxsCMGh/A3TygLWe/4hi7oLEwjx3Iz3VdqPBszQ=";
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
  ];
  services = {
    hardware = {
      deepcool-digital-linux.enable = true;
      openrgb = {
        enable = true;
        package = pkgs.openrgb-unstable;
        motherboard = "amd";
      };
    };
    udev.extraRules = "SUBSYSTEM==\"kvmfr\", OWNER=\"seth\", GROUP=\"kvm\", MODE=\"0660\"";
  };
  systemd = {
    tmpfiles.rules = [ "f /dev/shm/looking-glass 0660 seth qemu-libvirtd -" ];
    services = {
      deepcool-digital-linux.environment.LD_LIBRARY_PATH = "${config.hardware.nvidia.package}/lib";
      systemd-suspend.serviceConfig.Environment = "SYSTEMD_SLEEP_FREEZE_USER_SESSIONS=false";
      # CHAIN OF COMMANDS NEEDED TO SLEEP:
      # -- before suspend --
      # sleep 1; hyprctl dispatch dpms off; sleep 3
      # -- after suspend --
      # hyprctl dispatch dpms on; sleep 3; hyprctl reload
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
            sleep 3
            ${pkgs.hyprland}/bin/hyprctl reload
          ''}";
        };
      };
    };
  };
}
