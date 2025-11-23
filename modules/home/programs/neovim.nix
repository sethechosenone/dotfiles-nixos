{ pkgs, ... }: let inherit (pkgs) fetchFromGithub; in {
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    extraConfig = ''
      set relativenumber
      set number
      lua << EOF
      require('nvim-tree').setup()
      require('lualine').setup()
      require('claude-code').setup()
      EOF
    '';
    plugins = with pkgs.vimPlugins; [
      nvim-tree-lua
      claude-code-nvim
      nvim-lspconfig
      nvim-treesitter
      blink-cmp
      telescope-nvim
      lualine-nvim
    ];
  };
}
