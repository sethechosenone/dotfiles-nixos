{ pkgs, config, ... }: {
  programs.waybar = {
    enable = true;
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 30;
        output = [ "eDP-1" ];
        modules-left = [ "custom/icon" "hyprland/workspaces" ];
        modules-center = [ "clock" "hyprland/submap" ];
        modules-right = [ "temperature" "backlight" "network" "pulseaudio" "battery" ];
        "hyprland/workspaces" = {
          disable-scroll = true;
          all-outputs = true;
        };
        "clock" = {
          format = "{:%A, %b %d, %I:%M %p}";
          tooltip-format = "{calendar}";
          calendar = {
            mode = "month";
          };
        };
        "battery" = {
          format = "{icon} {capacity}%";
          format-charging = "󱐋{icon} {capacity}%";
          format-icons = [ "󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹" ];
          states = {
            "warning" = 15;
            "critical" = 5;
          };
          interval = 3;
        };
        "pulseaudio" = {
          format = "{icon} {volume}%";
          format-muted = " ";
          format-icons = [ "" " " " " ];
          on-click = "pavucontrol";
        };
        "network" = {
          format-wifi = "{icon}";
          format-ethernet = "󰈀 ";
          format-disconnected = "󰤭 ";
          format-icons = [ "󰤯 " "󰤟 " "󰤢 " "󰤥 " "󰤨 " ];
          on-click = "nm-connection-editor";
          tooltip-format = "{essid} {ipaddr}";
        };
        "backlight".format = "󰃠 {percent}%";
        "temperature" = {
          format = "{icon} {temperatureC}°C";
          critical-threshold = 90;
          format-critical = " {icon} {temperatureC}°C";
          format-icons = [ "" "" "" "" ];
        };
        "custom/icon" = {
          format = "  ";
          tooltip = false;
        };
      };
    };
    style = ''
      * { font-family: JetBrainsMono Nerd Font, SymbolsNerdFont;  }
      #custom-icon {
        background-image: url("${pkgs.nixos-icons}/share/icons/hicolor/24x24/apps/nix-snowflake.png");
        background-repeat: no-repeat;
        background-position: center;
        margin-left: 5px;
        padding-right: 7px;
      }
      #workspaces {
        padding: 0 5px;
        color: @base05;
        border-radius: 15px;
      }
      #workspaces button {
        margin: 0 2px;
        padding: 0 10px;
        border-width: 2px;
        box-shadow: none;
      }
      #battery.warning { color: #faf042; }
      #battery.critical { color: #ff3c3d; }
      #temperature.critical { color: #ff3c3d; }
      window#waybar {
        border-radius: 15px;
        padding: 0 5px;
      }
      #temperature,
      #backlight,
      #network,
      #pulseaudio,
      #battery {
        padding: 0px 5px;
        padding-left: 10px;
        margin: 3px 3px;
      }
      #clock { padding: 0px 5px; }
      #submap {
        padding: 0px 10px;
        border-radius: 15px;
      }
      #battery { padding-right: 5px; }
    '';
  };
}
