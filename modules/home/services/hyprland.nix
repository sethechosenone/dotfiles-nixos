{
  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
      monitor = "eDP-1, 2560x1600@165, auto, 1.25";
      "$terminal" = "kitty";
      "$menu" = "pidof wofi || wofi --show drun";
      exec-once = [ "nm-applet --indicator & blueman-applet & waybar & hyprpaper" ];
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
        active_opacity = 1;
        inactive_opacity = 0.9;
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
        "layersIn, 1, 8, easeOut, slide"
        "layersOut, 1, 8, easeIn, slide"
        "windowsMove, 1, 8, default"
      ];
      windowrule = [
        "float, class:org.pulseaudio.pavucontrol"
        "float, title:^(Open Folder)$"
        "float, class:nm-connection-editor"
        "float, class:.blueman-manager-wrapped"
      ];
      layerrule = [
        "animation fade, ^(logout_dialog)$"
        "animation fade, ^(selection)$"
        "noanim, ^(hyprpicker)$"
      ];
      dwindle = {
        pseudotile = true;
        preserve_split = true;
      };
      input.touchpad = {
        natural_scroll = true;
        clickfinger_behavior = true;
      };
      gesture = "3, horizontal, workspace";
      bind = [
        "$mod, F, toggleFloating, "
        "$mod, return, exec, $terminal"
        "$mod, Q, killactive, "
        "$mod, R, exec, $menu"
        "$mod, P, pseudo, "
        "$mod, J, togglesplit, "
        "$mod, S, togglespecialworkspace, magic"
        "$mod SHIFT, S, movetoworkspace, special:magic"
        "$mod SHIFT, R, submap, resize"
        "$mod, left, movefocus, l"
        "$mod, right, movefocus, r"
        "$mod, up, movefocus, u"
        "$mod, down, movefocus, d"
        "$mod SHIFT, left, movewindow, l"
        "$mod SHIFT, right, movewindow, r"
        "$mod SHIFT, up, movewindow, u"
        "$mod SHIFT, down, movewindow, d"
        #", Caps_Lock, exec, swayosd-client --caps-lock"
        "$mod, escape, exec, pidof wlogout || wlogout"
        ", Print, exec, pidof hyprshot || hyprshot -m output -m eDP-1"
        "$mod, Print, exec, pidof hyprshot || hyprshot -m region"
      ] ++ (builtins.concatLists (builtins.genList (x:
        let ws = let c = (x + 1) / 10; in builtins.toString (x + 1 - (c * 10));
        in [ "$mod, ${ws}, workspace, ${toString (x + 1)}" ]) 10))
        ++ (builtins.concatLists (builtins.genList (x:
          let
            ws = let c = (x + 1) / 10; in builtins.toString (x + 1 - (c * 10));
          in [ "$mod SHIFT, ${ws}, movetoworkspace, ${toString (x + 1)}" ])
          10));
      binde = [
        "$mod CTRL, right, resizeactive, 10 0"
        "$mod CTRL, left, resizeactive, -10 0"
        "$mod CTRL, up, resizeactive, 0 -10"
        "$mod CTRL, down, resizeactive, 0 10"
      ];
      bindl = [
        ", switch:on:Lid Switch, exec, brightnessctl -s set 0%; brightnessctl -sd framework_laptop::kbd_backlight set 0%"
        ", switch:off:Lid Switch, exec, brightnessctl -r; brightnessctl -rd framework_laptop::kbd_backlight"
      ];
      # "bindle" doesn't mean anything as a word, it just means "bind + (l)ock + r(e)peat"
      bindle = [
        ", XF86AudioRaiseVolume, exec, swayosd-client --output-volume raise"
        ", XF86AudioLowerVolume, exec, swayosd-client --output-volume lower"
        ", XF86AudioMute, exec, swayosd-client --output-volume mute-toggle"
        ", XF86MonBrightnessDown, exec, swayosd-client --brightness -5"
        ", XF86MonBrightnessUp, exec, swayosd-client --brightness +5"
        # swayosd does all of this, but it's still here in case we want to use something else
        #", XF86AudioRaiseVolume, exec, pamixer --increase 5"
        #", XF86AudioLowerVolume, exec, pamixer --decrease 5"
        #", XF86AudioMute, exec, pamixer --toggle-mute"
        #", XF86MonBrightnessDown, exec, brightnessctl -s set 5%-"
        #", XF86MonBrightnessUp, exec, brightnessctl -s set 5%+"
      ];
      bindm = [ "$mod, mouse:272, movewindow" "$mod, mouse:273, resizewindow" ];
    };
  };
}
