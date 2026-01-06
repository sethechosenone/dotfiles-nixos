{ config, lib, ... }: {
  boot = {
    initrd = {
      availableKernelModules = [ "nvme" "xhci_pci" "ahci" "usb_storage" "usbhid" "sd_mod" ];
      kernelModules = [ ];
    };
    kernelModules = [ "kvm-amd" ];
    extraModulePackages = [ ];
  };
  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/nixos";
      fsType = "ext4";
    };
    "/boot" = {
      device = "/dev/disk/by-label/boot";
      fsType = "vfat";
      options = [ "fmask=0077" "dmask=0077" ];
    };
    "/mnt/games1" = {
      device = "/dev/disk/by-label/games1";
      fsType = "ntfs3";
      options = [ "uid=1000" "gid=100" "rw" "user" "exec" "umask=000" ];
    };
    "/mnt/games2" = {
      device = "/dev/disk/by-label/games2";
      fsType = "ntfs3";
      options = [ "uid=1000" "gid=100" "rw" "user" "exec" "umask=000" ];
    };
  };
  swapDevices = [{ device = "/dev/disk/by-label/swap"; }];
  networking.useDHCP = lib.mkDefault true;
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
