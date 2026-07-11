{ config, lib, modulesPath, pkgs, ... }:

let
  luksDevice = "/dev/disk/by-label/NIXLUKS";
  # tries=0: unlimited recovery-key attempts once FIDO2 is exhausted.
  luksUnlockOpts = [
    "tpm2-device=auto"
    "fido2-device=/dev/onlykey-fido2"
    "token-timeout=60"
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
        (pkgs.runCommand "udevFido2" {} ''
          mkdir -p $out/lib/udev/rules.d/
          cp ${pkgs.systemd}/lib/udev/rules.d/60-fido-id.rules \
          $out/lib/udev/rules.d/60-fido-id.rules
          cat > $out/lib/udev/rules.d/61-onlykey-fido2.rules <<'EOF'
          SUBSYSTEM=="hidraw", ATTRS{idVendor}=="1d50", ATTRS{idProduct}=="60fc", \
          ATTRS{bInterfaceNumber}=="01", \
          ENV{ID_FIDO_TOKEN}="1", SYMLINK+="onlykey-fido2", TAG+="systemd"
          EOF
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
