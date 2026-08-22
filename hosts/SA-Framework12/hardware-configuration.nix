{ config, lib, modulesPath, pkgs, ... }:

let
  luksDevice = "/dev/disk/by-label/NIXLUKS";
  # tries=0: unlimited recovery-key attempts once FIDO2 is exhausted.
  # token-timeout: see SA-Framework16 -- total plug-and-unlock window,
  # and the recovery-prompt delay when no token shows up.
  luksUnlockOpts = [
    "tpm2-device=auto"
    "fido2-device=/dev/onlykey-fido2"
    "token-timeout=120"
    "tries=0"
  ];
  # Must be the bin/ path — see SA-Framework16/hardware-configuration.nix
  # for the full rationale behind this whole unlock setup.
  initrdCryptsetup = "${config.boot.initrd.systemd.package}/bin/systemd-cryptsetup";
in
{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot = {
    initrd = {
      systemd.storePaths = [ "${pkgs.systemd}/lib/udev/fido_id" ];
      systemd.extraBin = {
        fido2-token = "${pkgs.libfido2}/bin/fido2-token";
      };
      # See SA-Framework16 for the full story: a locked OnlyKey silently
      # drops CTAP requests and there is no timeout anywhere in the stack,
      # so udev must not expose /dev/onlykey-fido2 -- this service creates
      # the symlink only once the key answers (= unlocked), then pokes udev
      # so cryptsetup's security-device monitor rescans it.
      systemd.services.onlykey-fido2-gate = {
        description = "Expose OnlyKey FIDO2 interface once the key is unlocked";
        wantedBy = [ "initrd.target" ];
        before = [ "systemd-cryptsetup@cryptroot.service" ];
        unitConfig.DefaultDependencies = false;
        serviceConfig = {
          Type = "simple";
          Restart = "always";
          RestartSec = 1;
          StandardOutput = "journal";
          StandardError = "journal";
        };
        script = ''
          link=/dev/onlykey-fido2
          while true; do
            # key unplugged: drop the dangling symlink so cryptsetup goes
            # back to waiting instead of erroring on a dead node
            if [ -L "$link" ] && [ ! -e "$link" ]; then
              rm -f "$link"
            fi
            if [ ! -e "$link" ]; then
              for h in /sys/class/hidraw/hidraw*; do
                [ -e "$h" ] || continue
                hid=$(readlink -f "$h/device" 2>/dev/null) || continue
                case "$(basename "$hid")" in
                  0003:1D50:60FC.*) ;;
                  *) continue ;;
                esac
                [ "$(cat "$hid/../bInterfaceNumber" 2>/dev/null)" = "01" ] || continue
                node="/dev/$(basename "$h")"
                if timeout 2 fido2-token -I "$node" > /dev/null 2>&1; then
                  ln -sf "$(basename "$h")" "$link"
                  echo "OnlyKey answered, exposing $node as $link"
                  udevadm trigger --action=change "$h" || true
                fi
              done
            fi
            sleep 1
          done
        '';
      };
      # Same unlock hardening as SA-Framework16 (minus the keyboard
      # measurement): make the FIDO2 "plug in"/"confirm presence" notices
      # visible on the console, and survive hard FIDO2 errors (e.g. a
      # plugged-in but still-locked OnlyKey) that would otherwise abort the
      # unit and drop to an emergency shell instead of offering the recovery
      # key.
      systemd.services."systemd-cryptsetup@cryptroot" = {
        overrideStrategy = "asDropin";
        environment = {
          SYSTEMD_CRYPTSETUP_USE_TOKEN_MODULE = "0";
          SYSTEMD_LOG_TARGET = "console";
        };
        serviceConfig = {
          StandardOutput = "journal+console";
          StandardError = "journal+console";
          ExecStart = [
            ""
            "-${initrdCryptsetup} attach 'cryptroot' '${luksDevice}' '-' '${lib.concatStringsSep "," luksUnlockOpts}'"
            "${initrdCryptsetup} attach 'cryptroot' '${luksDevice}' '-' 'tpm2-device=auto,tries=0'"
          ];
        };
      };
      availableKernelModules = [ "nvme" "xhci_pci" "thunderbolt" "usb_storage" "usbhid" "sd_mod" "tpm_crb" ];
      kernelModules = [ "cryptd" ];
      luks.devices."cryptroot" = {
        device = luksDevice;
        crypttabExtraOpts = luksUnlockOpts;
      };
      services.udev.packages = [
        # fido_id tags FIDO hidraw interfaces "security-device", which is
        # the tag systemd-cryptsetup's plug-it-in monitor listens for. The
        # /dev/onlykey-fido2 symlink itself is deliberately NOT managed by
        # udev but by the onlykey-fido2-gate service: it must only appear
        # once the key is unlocked and answering CTAP requests.
        (pkgs.runCommand "udevFido2" {} ''
          mkdir -p $out/lib/udev/rules.d/
          cp ${pkgs.systemd}/lib/udev/rules.d/60-fido-id.rules \
          $out/lib/udev/rules.d/60-fido-id.rules
        '')
      ];
    };
    kernelModules = [ "kvm-intel" ];
    kernelParams = [ "intel_iommu=on" ];
    extraModulePackages = [ ];
  };

  fileSystems."/" =
    { device = "/dev/disk/by-label/nixos";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-label/boot";
      fsType = "vfat";
      options = [ "fmask=0077" "dmask=0077" ];
    };

  swapDevices =
    [ { device = "/dev/disk/by-label/swap"; }
    ];


  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlp170s0.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
