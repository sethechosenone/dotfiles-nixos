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
      lua << EOF
      vim.g.mapleader = " "
      vim.g.direnv_silent_load = 1
      vim.api.nvim_create_autocmd('FileType', {
        pattern = 'nix',
        callback = function()
          vim.opt_local.expandtab = true
          vim.opt_local.shiftwidth = 2
          vim.opt_local.tabstop = 2
        end,
      })
      require('nvim-tree').setup({
        diagnostics = {
          enable = true
        },
        renderer = {
          highlight_opened_files = "name",
          full_name = true,
        },
        view = {
          cursorlineopt = "screenline",
          preserve_window_proportions = true,
        },
      })
      require('lualine').setup()
      require('claude-code').setup({
        window = {
          position = 'vertical',
          split_ratio = 0.3
        }
      })
      vim.lsp.config.nil_ls = {
        cmd = { 'nil' },
        filetypes = { 'nix' },
        root_markers = { 'flake.nix', '.git' },
      }
      vim.lsp.config.pyright = {
        cmd = { 'pyright-langserver', '--stdio' },
        filetypes = { 'python' },
        root_markers = { 'pyproject.toml', 'setup.py', 'requirements.txt', '.git' },
      }
      vim.lsp.config.rust_analyzer = {
        cmd = { 'rust-analyzer' },
        filetypes = { 'rust' },
        root_markers = { 'Cargo.toml', '.git' },
      }
      vim.lsp.config.gopls = {
        cmd = { 'gopls' },
        filetypes = { 'go', 'gomod', 'gowork', 'gotmpl' },
        root_markers = { 'go.mod', 'go.work', '.git' },
      }
      vim.lsp.config.tsserver = {
        cmd = { 'typescript-language-server', '--stdio' },
        filetypes = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' },
        root_markers = { 'package.json', 'tsconfig.json', 'jsconfig.json', '.git' },
      }
      local filetype_to_lsp = {
        nix = 'nil_ls',
        python = 'pyright',
        rust = 'rust_analyzer',
        go = 'gopls',
        gomod = 'gopls',
        gowork = 'gopls',
        gotmpl = 'gopls',
        javascript = 'tsserver',
        javascriptreact = 'tsserver',
        typescript = 'tsserver',
        typescriptreact = 'tsserver',
      }
      vim.api.nvim_create_autocmd('FileType', {
        pattern = vim.tbl_keys(filetype_to_lsp),
        callback = function(args)
          local lsp_name = filetype_to_lsp[args.match]
          local config = vim.lsp.config[lsp_name]
          if config and vim.fn.executable(config.cmd[1]) == 1 then
            vim.lsp.enable(lsp_name)
          end
        end,
      })
      require('blink-cmp').setup({
        keymap = {
          preset = 'super-tab',
        },
        sources = {
          default = { 'lsp' }
        }
      })
      vim.api.nvim_set_keymap('n', '<leader>f', ':NvimTreeToggle<CR>', { noremap = true, silent = true })
      vim.api.nvim_set_keymap('n', '<leader>c', ':ClaudeCode<CR>', { noremap = true, silent = true })
      vim.api.nvim_set_keymap('n', '<leader>s', ':Telescope<CR>', { noremap = true, silent = true })
      vim.api.nvim_set_keymap('n', '<leader>t', ':belowright 15split | terminal<CR>', { noremap = true, silent = true })
      vim.api.nvim_set_keymap('n', '<leader>d', ':lua vim.diagnostic.setloclist()<CR>', { noremap = true, silent = true })
      vim.api.nvim_set_keymap('n', '<leader>e', ':lua vim.diagnostic.open_float()<CR>', { noremap = true, silent = true })
      vim.api.nvim_set_keymap('n', '[d', ':lua vim.diagnostic.goto_prev()<CR>', { noremap = true, silent = true })
      vim.api.nvim_set_keymap('n', ']d', ':lua vim.diagnostic.goto_next()<CR>', { noremap = true, silent = true })
      vim.api.nvim_set_keymap('t', '<C-n>', '<C-\\><C-n>', { noremap = true })
      vim.api.nvim_set_keymap('n', '<leader><space>', ':noh<CR>', { noremap = true, silent = true })
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
      direnv-vim
    ];
  };
}
