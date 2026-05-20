# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ pkgs, ... }: {
  imports = [ ./hardware-configuration.nix ];
  networking.hostName = "SA-Framework12";
  hardware.sensor.iio.enable = true;
  programs.iio-hyprland.enable = true;
  boot.kernelModules = [ "uinput" ];
  services = {
    udev.extraRules = ''
      KERNEL=="uinput", MODE="0660", GROUP="input"
    '';
    power-profiles-daemon.enable = true;
  };
  environment.systemPackages = with pkgs; [
    wvkbd
    rnote
    xournalpp
    libinput
    libwacom
    evtest
  ];
}
