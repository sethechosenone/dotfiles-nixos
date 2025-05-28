{ pkgs, lib, ... }: {
  programs.wlogout = {
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
    style = lib.mkAfter ''
      * { 
        box-shadow: none; 
        background-image: none;
      }
      window { background-color: rgba(20, 20, 20, 0.75); }
      button {
        margin: 5px;
        border-radius: 15px;
        border-width: 0;
        font-size: 20px;
        background-size: 25%;
        background-repeat: no-repeat;
        background-position: center;
      }
      svg { color: @base05; }
      #lock { background-image: url("${pkgs.wlogout}/share/wlogout/assets/lock.svg"); }
      #exit { background-image: url("${pkgs.wlogout}/share/wlogout/assets/logout.svg"); }
      #suspend { background-image: url("${pkgs.wlogout}/share/wlogout/assets/suspend.svg"); }
      #hibernate { background-image: url("${pkgs.wlogout}/share/wlogout/assets/hibernate.svg"); }
      #poweroff { background-image: url("${pkgs.wlogout}/share/wlogout/assets/shutdown.svg"); }
      #reboot { background-image: url("${pkgs.wlogout}/share/wlogout/assets/reboot.svg"); }
    '';
  };
}
