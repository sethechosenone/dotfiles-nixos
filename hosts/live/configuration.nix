{ pkgs, ... }: {
  nixpkgs = {
    overlays =
      [ (final: prev: { sudo = prev.sudo.override { withInsults = true; }; }) ];
    config.allowUnfree = true;
  };
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
