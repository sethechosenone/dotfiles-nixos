{ pkgs, ... }: {
  imports = [
    ./programs
    ./services
    ../shell/starship-tty.nix
  ];
  home = {
    stateVersion = "23.11";
    pointerCursor.enable = true;
  };
  systemd.user.sessionVariables.HYPRSHOT_DIR = "$HOME/Pictures/Screenshots";
  xdg.configFile = {
    "autostart/nm-applet.desktop".text = "[Desktop Entry]\nHidden=true\n";
    "autostart/blueman.desktop".text = "[Desktop Entry]\nHidden=true\n";
  };
  gtk.enable = true;
  programs = {
    direnv = {
      enable = true;
      enableZshIntegration = true;
    };
    gh.enable = true;
    zsh = {
      enable = true;
      defaultKeymap = "emacs";
      initContent = ''
        # Override Starship config for TTY (runs after promptInit)
        if [[ "$TERM" == "linux" ]] || [[ $(tty 2>/dev/null) =~ /dev/tty[0-9]+ ]]; then
          export STARSHIP_CONFIG="$HOME/.config/starship-tty.toml"
          eval "$(${pkgs.starship}/bin/starship init zsh)"
        fi
      '';
    };
  };
}
