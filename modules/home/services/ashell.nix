{ lib, osConfig, ... }: let
  hostname = osConfig.networking.hostName or "unknown";
  hasBattery = hostname != "SA-PowerTower";
  settingsIndicators =
    if hasBattery
    then [ "Audio" "Microphone" "Bluetooth" "Network" "Battery" ]
    else [ "Audio" "Microphone" "Bluetooth" "Network" ];
in {
  services.swaync.enable = true;
  programs.ashell = {
    enable = true;
    settings = {
      position = "Top";
      modules = {
        left   = [ [ "launcher" "Workspaces" "Tray" ] ];
        center = [ "Tempo" ];
        right  = [ "SystemInfo" [ "Privacy" "Settings" ] ];
      };
      CustomModule = [{
        name    = "launcher";
        icon    = "󱗼";
        command = "hyprlauncher";
      }];
      outputs = lib.mkIf (hostname != "SA-PowerTower") { Targets = [ "eDP-1" ]; };
      workspaces = {
        visibility_mode          = "All";
        enable_workspace_filling = true;
      };
      tempo = {
        clock_format      = "%a %b %d - %I:%M %p";
        weather_location  = { City = "Columbus"; };
        weather_indicator = "IconAndTemperature";
      };
      system_info = {
        indicators = [ "Cpu" "Temperature" ];
        interval   = 5;
        cpu.warn_threshold  = 60;
        cpu.alert_threshold = 80;
        temperature.warn_threshold  = 60;
        temperature.alert_threshold = 80;
      };
      settings.indicators = settingsIndicators;
      appearance.style = "Islands";
    };
  };
}
