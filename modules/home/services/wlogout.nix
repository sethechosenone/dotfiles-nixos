{ pkgs, ... }: {
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
    style = ''
      * { 
        box-shadow: none; 
        background-image: none;
      }
      /*window { background-color: rgba(12, 12, 12, 0.9); }*/
      button {
        margin: 5px;
        border-radius: 15px;
        border-width: 0;
        background-color: @base02;
        font-size: 20px;
        color: @base05;
        background-size: 25%;
        background-repeat: no-repeat;
        background-position: center;
      }
      #lock { background-image: url("${pkgs.wlogout}/share/wlogout/icons/lock.png"); }
      #exit { background-image: url("${pkgs.wlogout}/share/wlogout/icons/logout.png"); }
      #suspend { background-image: url("${pkgs.wlogout}/share/wlogout/icons/suspend.png"); }
      #hibernate { background-image: url("${pkgs.wlogout}/share/wlogout/icons/hibernate.png"); }
      #poweroff { background-image: url("${pkgs.wlogout}/share/wlogout/icons/shutdown.png"); }
      #reboot { background-image: url("${pkgs.wlogout}/share/wlogout/icons/reboot.png"); }
      button:hover { 
        background-color: @base03;
        outline-style: none;
      }
    '';
  };
}
