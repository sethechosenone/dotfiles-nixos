{ self, pkgs, lib, ... }: {
  programs.hyprlock = {
    enable = true;
    settings = {
      general.ignore_empty_input = true;
      background = lib.mkForce [{
        monitor = "";
        path = "${self}/modules/nixos/style/wallpaper.png";
        blur_passes = 2;
        contrast = 0.8916;
        brightness = 1.0;
        vibrancy = 0.5;
        vibrancy_darkness = 0.0;
      }];
      auth = {
        fingerprint = {
          enabled = true;
          ready_message = "OR PLACE FINGERPRINT ON READER";
        };
      };
      label = lib.mkForce [
        {
          monitor = "";
          text = "cmd[update:1000] echo \"$(date +\"%-I:%M%p\")\"";
          font_size = 120;
          font_family = "JetBrains Mono Nerd Font Mono ExtraBold";
          position = "0, -300";
          halign = "center";
          valign = "top";
        }
        {
          monitor = "";
          text = "welcome back, $USER";
          font_size = 25;
          position = "0, -40";
          halign = "center";
          valign = "center";
        }
        {
          monitor = "";
          text = "$FPRINTPROMPT";
          font_size = 15;
          position = "0, -150";
          halign = "center";
          valign = "center";
        }
      ];
      input-field = lib.mkForce [{
        monitor = "";
        size = "300, 40";
        outline_thickness = 2;
        dots_size = 0.3;
        dots_spacing = 0.2;
        dots_center = true;
        placeholder_text = "ENTER PASSWORD";
        fade_on_empty = false;
        hide_input = false;
        position = "0, -120";
        halign = "center";
        valign = "center";
      }];
    };
  };
}
