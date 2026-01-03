{ pkgs, ... }: {
  imports = [
    ../../modules/home/programs/neovim.nix
    ../../modules/shell/starship-tty.nix
  ];
  home.stateVersion = "23.11";
  programs = {
    eza.enable = true;
    bat.enable = true;
    zsh = {
      enable = true;
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
