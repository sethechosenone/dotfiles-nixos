{ config, ... }: {
  programs.hyprpanel = {
    enable = true;
    settings = {
      bar = {
        scaling = 1.25;
        layouts = {
          "0" = {
            left = [ "dashboard" "workspaces" "systray" ];
            middle = [ "clock" "weather" ];
            right = [ "cputemp" "network" "bluetooth" "battery" "notifications" ];
            launcher.autoDetectIcon = true;
            workspaces = {
              show_numbered = true;
              workspaces = 10;
            };
          };
        };
      };
      wallpaper.image = "${config.stylix.image}";
      matugen = true;
      matugen-settings = {
        mode = "dark";
        scheme_type = "tonal-spot";
        variation = "standard_2";
      };
      menus.clock = {
        time = {
          military = false;
          hideSeconds = true;
        };
        weather.unit = "imperial";
        dashboard= {
          directories.enabled = false;
          stats.enable_gpu = true;
        };
      };
      dbus = {
        enabled = true;
        brightness = {
          enabled = true;
          adjust_step_percent = 5;
          min_brightness = 1;
          hud_notifications = true;
        };
        power = {
          enabled = true;
          low_percent = 15;
          critical_percent = 5;
          hud_notifications = true;
        };
      };
      audio = {
        enabled = true;
        volume_step_percent = 5;
        hud_notifications = true;
      };
    };
  };
}
