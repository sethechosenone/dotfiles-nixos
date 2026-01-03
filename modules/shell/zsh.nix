{ ... }: {
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
    shellInit = "zsh-newuser-install() { :; }";
    interactiveShellInit = "eval \"$(direnv hook zsh)\"";
  };
}
