{ pkgs, ... }: {
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    extraConfig = ''
      set relativenumber
      set number
      set splitright
      set cursorlineopt=number
      set cursorline
      set tabstop=4
      set shiftwidth=4
      set noexpandtab
      set noequalalways
      set showtabline=1
      set guicursor=
    '';
    extraLuaConfig = builtins.readFile ./assets/neovim.lua;
    plugins = with pkgs.vimPlugins; [
      nvim-tree-lua
      claude-code-nvim
      nvim-lspconfig
      nvim-treesitter
      blink-cmp
      telescope-nvim
      lualine-nvim
      direnv-vim
      nvim-dap
      nvim-dap-ui
      nvim-dap-virtual-text
      nvim-dap-python
      nvim-dap-go
    ];
  };
}
