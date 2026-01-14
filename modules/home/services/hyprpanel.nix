{ config, lib, osConfig, ... }: let
  hostname = osConfig.networking.hostName or "unknown";
  rightBarLayouts = {
    "SA-Framework16" = [ "cputemp" "volume" "network" "bluetooth" "battery" "notifications" ];
    "SA-Framework13" = [ "cputemp" "volume" "network" "bluetooth" "battery" "notifications" ]; 
    "SA-PowerTower" = [ "cputemp" "volume" "network" "bluetooth" "notifications" ];
  };
in {
  programs.hyprpanel = {
    enable = true;
    systemd.enable = true;
    settings = {
      scalingPriority = "hyprland";
      bar = {
        autoHide = "fullscreen";
        layouts = {
          "0" = {
            left = [ "dashboard" "workspaces" "systray" ];
            middle = [ "clock" "weather" ];
            right = rightBarLayouts.${hostname} or [ "cputemp" "volume" "network" "bluetooth" "notifications" ];
          };
          "1" = {
            left = [];
            middle = [];
            right = [];
          };
        };
        workspaces = {
          show_numbered = true;
          workspaces = 10;
          numbered_active_indicator = "highlight";
        };
        launcher.autoDetectIcon = true;
        clock.format = "%a %b %d - %I:%M %p";
        network = {
          showInfoOnHover = true;
          truncation = false;
        };
        notifications = {
          show_total = true;
          hideCountWhenZero = true;
        };
      };
      wallpaper = {
        enable = false;
        image = "${config.stylix.image}";
        pywal = false;
      };
      menus = {
        clock = {
          time = {
            military = false;
            hideSeconds = true;
          };
          weather = {
            key = "adc29dab4102a55634c21f471c3b5c14";
            unit = "imperial";
          };
        };
        dashboard= {
          directories = {
            left = {
              directory1.command = "zsh -c \"xdg-open $HOME/Downloads/\"";
              directory2.command = "zsh -c \"xdg-open $HOME/Videos/\"";
              directory3.command = "zsh -c \"xdg-open $HOME/Projects/\"";
            };
            right = {
              directory1.command = "zsh -c \"xdg-open $HOME/Documents/\"";
              directory2.command = "zsh -c \"xdg-open $HOME/Pictures/\"";
              directory3.command = "zsh -c \"xdg-open $HOME/\"";
            };
          };
          stats.enable_gpu = true;
          shortcuts = {
            left = {
              shortcut1 = {
                icon = "󰈹";
                command = "firefox";
                tooltip = "Firefox";
              };
              shortcut2 = {
                icon = "";
                command = "kitty";
                tooltip = "Terminal";
              };
              shortcut4.command = "hyprlauncher";
            };
            right.shortcut3.command = "pidof hyprshot || hyprshot -m region";
          };
        };
        notifications.autoDismiss = true;
        power = {
          enabled = true;
          low_percent = 15;
          critical_percent = 5;
          hud_notifications = true;
          notification_title = "WARNING: Battery running low";
          notification_body = "Start thinking about plugging in soon. $POWER_LEVEL% charge remaining.";
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
      };
      audio = {
        enabled = true;
        volume_step_percent = 5;
        hud_notifications = true;
      };
      theme = {
        # most of this is handled by stylix
        tooltip.scaling = 65;
        notification.scaling = 65;
        bar = {
          scaling = 65;
          floating = true;
          dropdownGap = "1.7em";
          margin_sides = "0.4em";
          border_radius = "0.7em";
          button_radius = "0.7em";
          menus.menu = {
            dashboard = {
              profile.radius = "4em";
              controls.wifi.background = lib.mkForce "#B7C5D3";
              scaling = 65;
            };
            clock = {
              time = {
                time = lib.mkForce "#B7C5D3";
                period = lib.mkForce "#B7C5D3";
              };
              calendar.days = lib.mkForce "#F6F6F8";
              icon = lib.mkForce "#99C1F1";
              hourly = {
                time = lib.mkForce "#99C1F1";
                temperature = lib.mkForce "#99C1F1";
                icon = lib.mkForce "#99C1F1";
              };
              stats = lib.mkForce "#B7C5D3";
              status = lib.mkForce "#89DDFF";
              scaling = 65;
            };
            volume.scaling = 65;
            network = {
              label.color = lib.mkForce "#7AA2F7";
              switch.enabled = lib.mkForce "#7AA2F7";
              listitems.active = lib.mkForce "#7AA2F7";
              icons.active = lib.mkForce "#7AA2F7";
              iconbuttons.active = lib.mkForce "#7AA2F7";
              scroller.color = lib.mkForce "#7AA2F7";
              scaling = 65;
            };
            bluetooth = {
              label.color = lib.mkForce "#7AA2F7";
              listitems.active = lib.mkForce "#89DDFF";
              scroller.color = lib.mkForce "#89DDFF";
              switch.active = lib.mkForce "#89DDFF";
              scaling = 65;
            };
            battery = {
              label.color = lib.mkForce "#B7C5D3";
              listitems.active = lib.mkForce "#B7C5D3";
              icons.active = lib.mkForce "#B7C5D3";
              slider.primary = lib.mkForce "#B7C5D3";
              scaling = 65;
            };
            notifications = {
              label = lib.mkForce "#B7C5D3";
              switch.active = lib.mkForce "#B7C5D3";
              scaling = 65;
            };
            power = {
              shutdown.label_background = "#28323A";
              reboot.label_background = "#28323A";
              logout.label_background = "#28323A";
              sleep.label_background = "#28323A";
            };
          };
          buttons = {
            radius = "0.7em";
            padding_y = "0.1em";
            dashboard = {
              background = lib.mkForce "#62A0EA";
              icon = lib.mkForce "#171D23";
            };
            workspaces = {
              spacing = "0.4em";
              available = lib.mkForce "#B7C5D3";
              active = lib.mkForce "#B7C5D3";
              occupied = lib.mkForce "#B7C5D3";
              highlight = {
                radius = "0.7em";
                padding = "0.4em";
              };
            };
            systray.background = lib.mkForce "#28323A";
            clock = {
              text = lib.mkForce "#B7C5D3";
              icon = lib.mkForce "#B7C5D3";
              border = lib.mkForce "#B7C5D3";
            };
            network = {
              text = lib.mkForce "#7AA2F7";
              icon = lib.mkForce "#7AA2F7";
              border = lib.mkForce "#7AA2F7";
            };
            bluetooth = {
              text = lib.mkForce "#7AA2F7";
              icon = lib.mkForce "#7AA2F7";
              border = lib.mkForce "#7AA2F7";
            };
            battery = {
              text = lib.mkForce "#B7C5D3";
              icon = lib.mkForce "#B7C5D3";
              border = lib.mkForce "#B7C5D3";
            };
            modules.weather = {
              text = lib.mkForce "#99C1F1";
              icon = lib.mkForce "#99C1F1";
              border = lib.mkForce "#99C1F1";
            };
            monitors.cputemp.bar = "#171D23";
          };
        };
        osd = {
          orientation = "horizontal";
          location = "top";
          bar = lib.mkForce "#B7C5D3";
          iconContainer = lib.mkForce "#B7C5D3";
          text = lib.mkForce "#B7C5D3";
          background = lib.mkForce "#171D23";
          scaling = 65;
        };
      };
    };
  };
}
