{ osConfig, ... }: let
  hostname = osConfig.networking.hostName or "unknown";
  rightBarLayouts = {
    "SA-Framework16" = [ "cpu" "volume" "network" "bluetooth" "battery" "notifications" ];
    "SA-Framework13" = [ "cpu" "volume" "network" "bluetooth" "battery" "notifications" ];
    "SA-PowerTower"  = [ "cpu" "volume" "network" "bluetooth" "notifications" ];
  };
in {
  imports = [ ./wayle-styling.nix ];
  services.wayle = {
    enable = true;
    autoInstallDependencies = true;
    settings = {
      bar = {
        location = "top";
        rounding = "md";
        scale = 0.65;
        inset-edge = 0.35;
        inset-ends = 0.4;
        padding = 0.3;
        padding-ends = 1.5;
        module-gap = 1.0;
        button-variant = "block-prefix";
        button-rounding = "lg";
        button-bg-color = "transparent";
        dropdown-autohide = true;
        layout = [
          {
            monitor = "*";
            left   = [ "dashboard" "hyprland-workspaces" "systray" ];
            center = [ "clock" "weather" ];
            right  = rightBarLayouts.${hostname} or [ "cpu" "volume" "network" "bluetooth" "notifications" ];
          }
          {
            monitor = "HDMI-A-1";
            show   = false;
          }
        ];
      };
      osd = {
        enabled  = true;
        position = "top";
      };
      wallpaper.engine-enabled = false;
      styling = {
        scale = 0.7;
        palette.primary = "#b7c5d3";
      };
      modules = {
        "hyprland-workspaces" = {
          numbering         = "absolute";
          active-indicator  = "background";
          workspace-padding = 0.9;
        };
        clock.format = "%a %b %d -- %I:%M %p";
        weather = {
          provider = "open-meteo";
          location = "Columbus";
          units    = "imperial";
        };
        cpu = {
          border-color = "accent";
          icon-bg-color = "accent";
          label-color  = "accent";
          temp-sensor = "auto";
          format      = "{{ temp_c }}°";
          thresholds  = [
            { above = 70; icon-color = "status-warning"; label-color = "status-warning"; }
            { above = 90; icon-color = "status-error"; label-color = "status-error"; }
          ];
        };
        battery = {
          border-color = "accent";
          icon-bg-color = "accent";
          label-color  = "accent";
          thresholds = [
            { below = 40; icon-color = "status-warning"; label-color = "status-warning"; }
            { below = 15; icon-color = "status-error"; label-color = "status-error"; icon-bg-color = "status-error"; }
          ];
        };
        network = {
          label-show   = true;
          border-color = "accent";
          icon-bg-color = "accent";
          label-color  = "accent";
        };
        bluetooth = {
          label-show   = true;
          border-color = "accent";
          icon-bg-color = "accent";
          label-color  = "accent";
        };
        notification = {
          border-color  = "accent";
          icon-bg-color = "accent";
          label-color   = "accent";
          thresholds    = [
            { above = 1; icon-bg-color = "blue"; label-color = "blue"; border-color = "blue"; }
          ];
        };
        systray = {
          item-gap         = 0.5;
          internal-padding = 1.0;
        };
        volume = {
          border-color  = "accent";
          icon-bg-color = "accent";
          label-color   = "accent";
        };
        dashboard.icon-bg-color = "#62A0EA";
      };
    };
  };
}
