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
      rebuild-raspi = "nixos-rebuild switch --flake /etc/nixos#SA-RaspberryPi4 --target-host seth@192.168.1.100 --build-host arm-builder --sudo --ask-sudo-password"; 
      build-installer = "pushd ~/ISOs && nix build /etc/nixos#installer; popd";
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
