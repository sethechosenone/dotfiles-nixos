# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ pkgs, ... }: {
  imports = [ ./hardware-configuration.nix ];
  networking.hostName = "SA-Framework12";
  services.iio-sensor-proxy.enable = true;
  environment.systemPackages = with pkgs; [
    iio-hyprland
    wvkbd
    rnote
  ];
}
