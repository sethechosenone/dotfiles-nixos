{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    syntaxHighlighting.enable = true;
    shellAliases = {
      ls = "eza --icons -hl";
      view = "bat";
      edit = "nvim";
      edit-system = "edit /etc/nixos";
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
      zsh-newuser-install() { :; }
      if [[ "$TERM" == "linux" ]] || [[ $(tty 2>/dev/null) =~ /dev/tty[0-9]+ ]]; then
        export ZSH_THEME="cypher"
      else
        export ZSH_THEME="agnoster"
      fi
    '';
    interactiveShellInit = ''
      eval "$(direnv hook zsh)"
    '';
  };
}
