{ config, ... }: {
  services = {
    hyprpolkitagent.enable = true;
    hypridle = {
      enable = true;
      settings = {
        general = {
          lock_cmd = "pidof hyprlock || hyprlock";
          before_sleep_cmd = "loginctl lock-session";
          after_sleep_cmd = "hyprctl dispatch dpms on";
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
          {
            timeout = 1800;
            on-timeout = "systemctl suspend";
          }
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
}