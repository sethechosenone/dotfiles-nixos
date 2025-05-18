{ pkgs, config, lib, ... }: {
  imports = [
    ./kitty.nix
    ./neovim.nix
    ./wofi.nix
    ./firefox.nix
    ./vscode.nix
  ];
  programs = {
    eza.enable = true;
    bat.enable = true;
  };
}