{ pkgs, ... }: {
  users.users = {
    nixos.shell = pkgs.zsh;
    root.shell = pkgs.zsh;
  };
  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };
  environment.systemPackages = with pkgs; [
    eza
    bat
    sbctl
  ];
}
