{ pkgs, ... }: {
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    syntaxHighlighting.enable = true;
    shellAliases = {
      ls = "eza --icons -hl";
      view = "bat";
      edit = "nvim";
      edit-user-config = "nvim ~/.config/nixos/home.nix";
      edit-system-config = "sudo -e /etc/nixos/configuration.nix";
      rebuild = "sudo nixos-rebuild switch";
    };
    autosuggestions = {
      enable = true;
      strategy = [ "history" "completion" ];
    };
    ohMyZsh = {
      enable = true;
      plugins = [ "git" ];
    };
    shellInit = ''
      if [[ "$TERM" == "linux" ]] || [[ $(tty 2>/dev/null) =~ /dev/tty[0-9]+ ]]; then
        export ZSH_THEME="cypher"
      else
        export ZSH_THEME="agnoster"
      fi
    '';
  };
}
