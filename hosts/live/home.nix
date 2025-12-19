{
  imports = [ ../../modules/home/programs/neovim.nix ];
  home.stateVersion = "23.11";
  programs = {
    eza.enable = true;
    bat.enable = true;
  };
}
