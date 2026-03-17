{ config, lib, ... }: {
  boot = {
    initrd.availableKernelModules = [ "nvme" "xhci_pci" "ahci" "usb_storage" "usbhid" "sd_mod" ];
    kernelModules = [ "kvm-amd" "kvmfr" "i2c-dev" "i2c-piix4" "vendor-reset" ];
    kernelParams = [
      "amd_iommu=on" "iommu=pt" "acpi_enforce_resources=lax"
      "video=efifb:off"
    ];
    extraModprobeConfig = "options kvmfr static_size_mb=32";
    extraModulePackages = with config.boot.kernelPackages; [
      kvmfr
      vendor-reset
    ];
    tmp.useTmpfs = true;
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
  hardware = {
    cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    enableRedistributableFirmware = true;
  };
}
