{ pkgs, ... }: {
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    syntaxHighlighting.enable = true;
    shellAliases = {
      ls = "eza -hl";
      view = "bat";
      edit = "nvim";
      edit-user-config = "nvim ~/.config/nixos/home.nix";
      edit-system-config = "sudo -e /etc/nixos/configuration.nix";
      rebuild = "sudo nixos-rebuild switch";
    };
    ohMyZsh = {
      enable = true;
      plugins = [ "git" ];
      theme = "agnoster";
    };
  };
}
