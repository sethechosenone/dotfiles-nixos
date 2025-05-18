{ config, lib, pkgs, ... }:
let
  style = {
    colors = {
      bg = "#000018";
      fg = "#00004a";
      selected = "#3584e4";
      warning = "#faf042";
      critical = "#ff3c3d";
      font = "#ffffff";
      border_bg = "rgba(000018e6)";
      border_fg = "rgba(00004ae6)";
    };
    font = "JetBrainsMono Nerd Font";
    rounding = 15;
  };
in
{
  imports = [ ./style.nix ];
  home-manager = {
    useUserPackages = true;
    useGlobalPkgs = true;
    users.seth = {
      gtk.enable = true;
      home = {
        stateVersion = "23.11"; # we probably shouldn't change this
        pointerCursor = {
          gtk.enable = true;
          package = pkgs.adwaita-icon-theme;
          name = "Adwaita";
          size = 16;
        };
      };
      wayland.windowManager.hyprland = {
        enable = true;
        settings = {
          monitor = "eDP-1, 2256x1504, auto, 1.566667";
          "$terminal" = "kitty";
          "$menu" = "pidof wofi || wofi --show drun";
          exec-once = "nm-applet --indicator & waybar & hyprpaper";
          "$mod" = "SUPER";
          "$userConfigPath" = "/home/seth/.config/nixos";
          general = {
            gaps_in = 2;
            gaps_out = 5;
            border_size = 0;
            layout = "dwindle";
            resize_on_border = true;
          };
          decoration = {
            rounding = 8;
            active_opacity = 0.95;
            inactive_opacity = 0.8;
            blur = {
              enabled = true;
              passes = 2;
              contrast = 0.8916;
              brightness = 1.0;
              vibrancy = 0.5;
              vibrancy_darkness = 0.0;
              popups = true;
            };
          };
          animations.enabled = true;
          bezier = [
            "easeIn, 0.55, 0.085, 0.68, 0.53"
            "easeOut, 0.075, 0.82, 0.165, 1"
          ];
          animation = [
            "layersIn, 1, 10, easeOut, slide"
            "layersOut, 1, 10, easeIn, slide"
            "windowsMove, 1, 8, default"
          ];
          layerrule = [ "animation fade, ^(logout_dialog)$" ];
          dwindle = {
            pseudotile = true;
            preserve_split = true;
          };
          input.touchpad = {
            natural_scroll = true;
            clickfinger_behavior = true;
          };
          gestures = {
            workspace_swipe = true;
            workspace_swipe_fingers = 3;
          };
          bind = [
            "$mod, F, exec, firefox"
            "$mod, E, exec, code $userConfigPath"
            "$mod, return, exec, $terminal"
            "$mod, Q, killactive, "
            "$mod, V, toggleFloating, "
            "$mod, R, exec, $menu"
            "$mod, P, pseudo, "
            "$mod, J, togglesplit, "
            "$mod, S, togglespecialworkspace, magic"
            "$mod SHIFT, S, movetoworkspace, special:magic"
            "$mod, left, movefocus, l"
            "$mod, right, movefocus, r"
            "$mod, up, movefocus, u"
            "$mod, down, movefocus, d"
            "$mod SHIFT, left, movewindow, l"
            "$mod SHIFT, right, movewindow, r"
            "$mod SHIFT, up, movewindow, u"
            "$mod SHIFT, down, movewindow, d"
            "$mod, escape, exec, pidof wlogout || wlogout"
          ] ++ (
            builtins.concatLists (builtins.genList
              (
                x:
                let
                  ws =
                    let c = (x + 1) / 10;
                    in builtins.toString (x + 1 - (c * 10));
                in
                [
                  "$mod, ${ws}, workspace, ${toString(x + 1)}"
                ]
              ) 10
            )
          ) ++ (
            builtins.concatLists (builtins.genList
              (
                x:
                let
                  ws =
                    let c = (x + 1) / 10;
                    in builtins.toString (x + 1 - (c * 10));
                in
                [
                  "$mod SHIFT, ${ws}, movetoworkspace, ${toString(x + 1)}"
                ]
              ) 10
            )
          );
          bindl = [
            ", switch:on:Lid Switch, exec, brightnessctl -s set 0%; brightnessctl -sd framework_laptop::kbd_backlight set 0%"
            ", switch:off:Lid Switch, exec, brightnessctl -r; brightnessctl -rd framework_laptop::kbd_backlight"
          ];
          bindle = [
            # "bindle" doesn't mean anything as a word, it just means "bind + (l)ock + r(e)peat"
            ", XF86AudioRaiseVolume, exec, pamixer --increase 5"
            ", XF86AudioLowerVolume, exec, pamixer --decrease 5"
            ", XF86AudioMute, exec, pamixer --toggle-mute"
            ", XF86MonBrightnessDown, exec, brightnessctl -s set 10%-"
            ", XF86MonBrightnessUp, exec, brightnessctl -s set 10%+"
          ];
          bindm = [
            "$mod, mouse:272, movewindow"
            "$mod, mouse:273, resizewindow"
          ];
        };
      };
      programs = {
        firefox.enable = true;
        kitty = {
          enable = true;
          keybindings = {
            "ctrl+c" = "copy_or_interrupt";
            "ctrl+v" = "paste_from_clipboard"; 
          };
          font = {
            name = style.font;
            size = 10;
          };
          shellIntegration = {
            mode = "no-cursor";
            enableZshIntegration = true;
          };
          settings = {
            cursor_shape = "underline";
            cursor_blink_interval = "0.2";
            cursor_stop_blinking_after = 0;
            background = style.colors.bg;
          };
        };
        vscode.enable = true;
        zsh = {
          enable = true;
          enableCompletion = true;
          syntaxHighlighting.enable = true;
          shellAliases = {
            ls = "eza -hl";
            view = "bat";
            edit = "nvim";
            edit-user-config = "nvim ~/.config/nixos/home.nix";
            edit-system-config = "sudo -e /etc/nixos/configuration.nix";
            rebuild = "sudo nixos-rebuild switch";
          };
          oh-my-zsh = {
            enable = true;
            plugins = [ "git" ];
            theme = "agnoster";
          };
        };
        eza.enable = true;
        bat.enable = true;
        neovim = {
          enable = true;
          defaultEditor = true;
          extraConfig = ''
            set number
          '';
          plugins = with pkgs.vimPlugins; [ vim-visual-multi ];
        };
        htop.enable = true;
        waybar = {
          enable = true;
          settings = {
            mainBar = {
              layer = "top";
              position = "top";
              height = 30;
              output = [ "eDP-1" ];
              modules-left = [ "custom/icon" "hyprland/workspaces" ];
              modules-center = [ "clock" ];
              modules-right = [ "temperature" "backlight" "network" "pulseaudio" "battery" ];
              "hyprland/workspaces" = {
                disable-scroll = true;
                all-outputs = true;
              };
              "clock".format = "{:%A, %b %d, %I:%M %p}";
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
                on-click = "nm-applet";
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
        };
        wofi = {
          enable = true;
          settings = {
            location = "top";
            allow_markup = true;
            allow_images = true;
            width = 750;
            yoffset = 5;
            key_expand = "Tab";
          };
        };
        # hyprlock = {
        #   enable = true;
        #   settings = {
        #     general.ignore_empty_input = true;
        #     background = [
        #       {
        #         monitor = "";
        #         color = "${style.colors.bg}";
        #         blur_passes = 2;
        #         contrast = 0.8916;
        #         brightness = 1.0;
        #         vibrancy = 0.5;
        #         vibrancy_darkness = 0.0;
        #       }
        #     ];
        #     label = [
        #       {
        #         monitor = "";
        #         text = "Hi, $USER";
        #         color = "${style.colors.fg}";
        #         font_size = 25;
        #         font_family = "${style.font}";
        #         position = "0, -40";
        #         halign = "center";
        #         valign = "center";
        #       }
        #     ];
        #     input-field = [
        #       {
        #         monitor = "";
        #         size = "300, 40";
        #         outline_thickness = 2;
        #         dots_size = 0.3;
        #         dots_spacing = 0.2;
        #         dots_center = true;
        #         outer_color = "rgba(0, 0, 0, 0)";
        #         inner_color = "rgba(0, 0, 0, 0.3)";
        #         font_color = "${style.colors.font}";
        #         fade_on_empty = false;
        #         font_family = "${style.font}";
        #         hide_input = false;
        #         position = "0, -120";
        #         halign = "center";
        #         valign = "center";
        #       }
        #     ];
        #   };
        # };
        wlogout = {
          enable = true;
          layout = [
            {
              label = "lock";
              action = "pidof hyprlock || hyprlock";
              text = "Lock...";
              keybind = "l";
            }
            {
              label = "exit";
              action = "hyprctl dispatch exit";
              text = "Log out session...";
              keybind = "e";
            }
            {
              label = "suspend";
              action = "systemctl suspend";
              text = "Suspend to RAM...";
              keybind = "s";
            }
            {
              label = "hibernate";
              action = "systemctl hibernate";
              text = "Hibernate...";
              keybind = "h";
            }
            {
              label = "poweroff";
              action = "systemctl poweroff";
              text = "Shutdown...";
              keybind = "p";
            }
            {
              label = "reboot";
              action = "systemctl reboot";
              text = "Restart...";
              keybind = "r";
            }
          ];
        };
      };
      services = {
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
                on-timeout = "brightnessctl -s set 10%; brightnessctl -sd framework_laptop::kbd_backlight set 0%";
                on-resume = "brightnessctl -r; brightnessctl -rd framework_laptop::kbd_backlight";
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
        swaync.enable = true;
      };
    };
  };
}
