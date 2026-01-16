{ lib, osConfig, ... }: {
  services = {
    hyprpolkitagent.enable = true;
    hyprpaper.enable = true;
    hyprlauncher = {
      enable = true;
      settings = {
        finders = {
          desktop_icons = true;
          math_prefix = "=";
        };
        ui.window_size = "400 260";
      };
    };
    hypridle = {
      enable = true;
      settings = {
        general = {
          lock_cmd = "pidof hyprlock || hyprlock";
          before_sleep_cmd = "loginctl lock-session";
        };
        listener = [
          {
            timeout = 150;
            on-timeout =
              "brightnessctl -s set 5%; brightnessctl -sd framework_laptop::kbd_backlight set 0%";
            on-resume =
              "brightnessctl -r; brightnessctl -sd framework_laptop::kbd_backlight set 100%";
          }
          {
            timeout = 300;
            on-timeout = "loginctl lock-session";
          }
          {
            timeout = 330;
            on-timeout = "hyprctl dispatch dpms off";
            on-resume = "hyprctl dispatch dpms on";
          }
          (lib.mkIf (osConfig.networking.hostName == "SA-Framework16" || osConfig.networking.hostName == "SA-Framework13") {
            timeout = 1800;
            on-timeout = "systemctl suspend";
          })
        ];
      };
    };
    hyprsunset = {
      enable = true;
      settings.profile = [
        {
          time = "6:00";
          identity = true;
        }
        {
          time = "21:00";
          temperature = 5500;
          gamma = 0.8;
        }
      ];
    };
  };
  programs.hyprshot.enable = true;
}
