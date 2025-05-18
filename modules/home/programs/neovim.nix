{ pkgs, ... }: let inherit (pkgs) fetchFromGithub; in {
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    extraConfig = ''
      set number
    '';
    plugins = with pkgs.vimPlugins; [ vim-visual-multi ];
  };
}
