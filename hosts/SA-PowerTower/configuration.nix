{ config, pkgs }: {
  imports = [ ./hardware-configuration.nix ];
  networking.hostName = "SA-PowerTower";
  services.xserver.videoDrivers = [ "amdgpu" "nvidia" ];
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      nvidia-vaapi-driver
      vaapiVdpau
      libvdpau-va-gl
    ];
  };
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };
  boot.kernelParams = [ "nvidia-drm.modeset=1" ];
  powerManagement.cpuFreqGovernor = "performance";
  environment.systemPackages = with pkgs; [
    looking-glass-client
    openrgb
    mangohud
    goverlay
    protonup-qt
    wine-staging
    winetricks
  ];
}
