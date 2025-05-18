{ pkgs, lib, ... }: {
  programs.hyprlock = {
    enable = true;
    settings = {
      general.ignore_empty_input = true;
      background = lib.mkDefault [{
        monitor = "";
        blur_passes = 2;
        contrast = 0.8916;
        brightness = 1.0;
        vibrancy = 0.5;
        vibrancy_darkness = 0.0;
      }];
      label = lib.mkDefault [{
        monitor = "";
        text = "$USER";
        font_size = 25;
        position = "0, -40";
        halign = "center";
        valign = "center";
      }];
      input-field = lib.mkDefault [{
        monitor = "";
        size = "300, 40";
        outline_thickness = 2;
        dots_size = 0.3;
        dots_spacing = 0.2;
        dots_center = true;
        outer_color = "rgba(0, 0, 0, 0)";
        inner_color = "rgba(0, 0, 0, 0.3)";
        fade_on_empty = false;
        hide_input = false;
        position = "0, -120";
        halign = "center";
        valign = "center";
      }];
    };
  };
}
