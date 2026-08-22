# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ pkgs, ... }: {
  imports = [ ./hardware-configuration.nix ];
  networking.hostName = "SA-Framework16";
  hardware = {
    inputmodule.enable = true;
    framework.enableKmod = true;
    keyboard.qmk.enable = true;
  };
  services.led-matrix-sysinfo = {
    enable = true;
    interval = 250;
  };
  environment.systemPackages = with pkgs; [
    wireguard-tools
    qmk
    qmk_hid
    picotool
  ];
  # UPower's udev rule requires charge_control_start_threshold to detect charge
  # limit support, but the Framework 16 EC only exposes the end threshold via
  # cros_charge_control. This rule sets CHARGE_LIMIT directly so UPower detects
  # it. The "_" sentinel tells UPower to skip writing the absent start threshold.
  services.udev.extraRules = ''
    SUBSYSTEM=="power_supply", KERNEL=="BAT1", ATTR{type}=="Battery", ATTR{charge_control_end_threshold}!="", ENV{CHARGE_LIMIT}="_,100"
  '';
}
