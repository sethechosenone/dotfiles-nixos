{
  imports = [
    ./kitty.nix
    ./neovim.nix
#    ./wofi.nix
    ./firefox.nix
#    ./vscode.nix
    ./discord.nix
  ];
  programs = {
    eza = {
      enable = true;
      enableZshIntegration = false;
    };
    bat.enable = true;
  };
}
