{ pkgs, ... }: {
  # imports = [ ../../modules/home/programs/neovim.nix ]; # uncomment after initial boot
  home.stateVersion = "23.11";
  programs = {
    # eza = {               # uncomment after initial boot
    #   enable = true;
    #   enableZshIntegration = false;
    # };
    # bat.enable = true;  # uncomment after initial boot
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
