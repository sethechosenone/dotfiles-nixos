{ config, lib, modulesPath, pkgs, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot = {
    initrd = {
      systemd.storePaths = [ "${pkgs.systemd}/lib/udev/fido_id" ];
      availableKernelModules = [ "nvme" "xhci_pci" "thunderbolt" "usb_storage" "usbhid" "sd_mod" "tpm_crb" ];
      kernelModules = [ "cryptd" ];
      luks.devices."cryptroot" = {
        device = "/dev/disk/by-label/NIXLUKS";
        crypttabExtraOpts = [
          "fido2-device=/dev/onlykey-fido2"
          "token-timeout=60"
        ];
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
