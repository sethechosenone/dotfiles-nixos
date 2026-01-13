{ config, pkgs, ... }: {
  imports = [ ./hardware-configuration.nix ];
  networking.hostName = "SA-PowerTower";
  services.xserver.videoDrivers = [ "amdgpu" "nvidia" ];
  hardware = {
    graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs; [
        nvidia-vaapi-driver
        libva-vdpau-driver
        libvdpau-va-gl
      ];
    };
    nvidia = {
      modesetting.enable = true;
      powerManagement.enable = true;
      open = false;
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.stable;
    };
    i2c.enable = true;
  };
  powerManagement.cpuFreqGovernor = "performance";
  environment.systemPackages = with pkgs; [
    looking-glass-client
    openrgb-unstable
    mangohud
    goverlay
    protonup-qt
    wine-staging
    winetricks
    heroic
    vk-hdr-layer
  ];
}
