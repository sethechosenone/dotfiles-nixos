{ config, lib, ... }: {
  boot = {
    initrd.availableKernelModules = [ "nvme" "xhci_pci" "ahci" "usb_storage" "usbhid" "sd_mod" ];
    kernelModules = [ "kvm-amd" "kvmfr" "i2c-dev" "i2c-piix4" "vendor-reset" ];
    kernelParams = [
      "amd_iommu=on" "iommu=pt" "acpi_enforce_resources=lax"
      "video=efifb:off" "amd_iommu=force_isolation"
      "usbhid.quirks=0x0B05:0x1AAE:0x00000020"
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
      fsType = "ext4";
      options = [ "rw" "exec" "nofail" ];
    };
    "/mnt/games2" = {
      device = "/dev/disk/by-label/games2";
      fsType = "ext4";
      options = [ "rw" "exec" "nofail" ];
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
