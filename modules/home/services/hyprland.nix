{ pkgs, ... }: {
  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
      monitor = "eDP-1, 2256x1504, auto, 1.566667";
      "$terminal" = "kitty";
      "$menu" = "pidof wofi || wofi --show drun";
      exec-once = [
        "nm-applet --indicator & waybar & hyprpaper"
        "systemctl --user start hyprpolkitagent"
      ];
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
      bezier =
        [ "easeIn, 0.55, 0.085, 0.68, 0.53" "easeOut, 0.075, 0.82, 0.165, 1" ];
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
      ] ++ (builtins.concatLists (builtins.genList (x:
        let ws = let c = (x + 1) / 10; in builtins.toString (x + 1 - (c * 10));
        in [ "$mod, ${ws}, workspace, ${toString (x + 1)}" ]) 10))
        ++ (builtins.concatLists (builtins.genList (x:
          let
            ws = let c = (x + 1) / 10; in builtins.toString (x + 1 - (c * 10));
          in [ "$mod SHIFT, ${ws}, movetoworkspace, ${toString (x + 1)}" ])
          10));
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
      bindm = [ "$mod, mouse:272, movewindow" "$mod, mouse:273, resizewindow" ];
    };
  };
}
