{ ... }: {
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    syntaxHighlighting.enable = true;
    shellAliases = {
      ls = "eza --icons -l";
      view = "bat";
      run = "source"; # short-hand for executing scripts in same shell, can save performance but is rarely worth it
      edit = "nvim";
      edit-system = "edit /etc/nixos";
      rebuild = "nixos-rebuild switch --sudo";
      rebuild-raspi = "nixos-rebuild switch --flake /etc/nixos#SA-RaspberryPi4 --target-host seth@192.168.1.100 --build-host arm-builder --sudo --ask-sudo-password"; 
      build-installer = "pushd ~/ISOs && nix build /etc/nixos#installer; popd";
      build-raspi4-image = "pushd ~ && nix build /etc/nixos#nixosConfigurations.SA-RaspberryPi4.config.system.build.sdImage && popd";
      build-raspizero-image = "pushd ~ && nix build /etc/nixos#nixosConfigurations.SA-RaspberryPiZero2W.config.system.build.sdImage && popd";
    };
    autosuggestions = {
      enable = true;
      strategy = [ "history" "completion" ];
    };
    shellInit = "zsh-newuser-install() { :; }";
    interactiveShellInit = "eval \"$(direnv hook zsh)\"";
  };
}
