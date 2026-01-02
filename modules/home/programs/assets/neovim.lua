vim.g.mapleader = " "
vim.g.direnv_silent_load = 1

-- File type specific settings
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'nix',
  callback = function()
    vim.opt_local.expandtab = true
    vim.opt_local.shiftwidth = 2
    vim.opt_local.tabstop = 2
  end,
})

vim.api.nvim_create_autocmd('FileType', {
  pattern = 'rust',
  callback = function()
    vim.opt_local.expandtab = false
    vim.opt_local.shiftwidth = 4
    vim.opt_local.tabstop = 4
  end,
})

-- Plugin setup
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

require('telescope').setup({
  defaults = {
    mappings = {
      i = {
        ['<C-j>'] = 'move_selection_next',
        ['<C-k>'] = 'move_selection_previous',
      },
    },
  },
})

require('claude-code').setup({
  window = {
    position = 'vertical',
    split_ratio = 0.3
  }
})

-- LSP Configuration
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

-- Completion setup
require('blink-cmp').setup({
  keymap = {
    preset = 'super-tab',
  },
  sources = {
    default = { 'lsp' }
  }
})

-- DAP Configuration
local dap = require('dap')
local dapui = require('dapui')

require('nvim-dap-virtual-text').setup()
dapui.setup()

-- Auto open/close DAP UI
dap.listeners.after.event_initialized['dapui_config'] = function()
  dapui.open()
end
dap.listeners.before.event_terminated['dapui_config'] = function()
  dapui.close()
end
dap.listeners.before.event_exited['dapui_config'] = function()
  dapui.close()
end

-- Python DAP (will use debugpy from project environment)
require('dap-python').setup('python')

-- Go DAP (will use delve from project environment)
require('dap-go').setup()

-- Rust DAP (will use codelldb from project environment)
dap.adapters.codelldb = {
  type = 'server',
  port = '${port}',
  executable = {
    command = 'codelldb',
    args = { '--port', '${port}' },
  }
}

dap.configurations.rust = {
  {
    name = 'Launch',
    type = 'codelldb',
    request = 'launch',
    program = function()
      return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/target/debug/', 'file')
    end,
    cwd = '${workspaceFolder}',
    stopOnEntry = false,
  },
}

-- TypeScript/JavaScript DAP (will use vscode-js-debug from project environment)
dap.adapters['pwa-node'] = {
  type = 'server',
  host = 'localhost',
  port = '${port}',
  executable = {
    command = 'js-debug-adapter',
    args = { '${port}' },
  }
}

for _, language in ipairs({ 'typescript', 'javascript', 'typescriptreact', 'javascriptreact' }) do
  dap.configurations[language] = {
    {
      type = 'pwa-node',
      request = 'launch',
      name = 'Launch file',
      program = '${file}',
      cwd = '${workspaceFolder}',
    },
    {
      type = 'pwa-node',
      request = 'attach',
      name = 'Attach',
      processId = require('dap.utils').pick_process,
      cwd = '${workspaceFolder}',
    },
  }
end

-- Keymaps
-- f* = file menu
vim.api.nvim_set_keymap('n', '<leader>f', ':NvimTreeToggle<CR>', { noremap = true, silent = true })

-- c = claude
vim.api.nvim_set_keymap('n', '<leader>c', ':ClaudeCode<CR>', { noremap = true, silent = true })

-- s* = search (Telescope)
vim.api.nvim_set_keymap('n', '<leader>sf', ':Telescope find_files<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>sg', ':Telescope live_grep<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>sb', ':Telescope buffers<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>sh', ':Telescope help_tags<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>sr', ':Telescope lsp_references<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>ss', ':Telescope lsp_document_symbols<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>s', ':Telescope<CR>', { noremap = true, silent = true })

-- t = terminal
vim.api.nvim_set_keymap('n', '<leader>t', ':belowright 15split | terminal<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('t', '<C-n>', '<C-\\><C-n>', { noremap = true })

-- d* = debug/diagnostic (common actions)
vim.api.nvim_set_keymap('n', '<leader>db', ':lua require("dap").toggle_breakpoint()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>dc', ':lua require("dap").continue()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>di', ':lua require("dap").step_into()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>do', ':lua require("dap").step_over()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>du', ':lua require("dap").step_out()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>dr', ':lua require("dap").repl.open()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>dl', ':lua require("dap").run_last()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>dd', ':lua vim.diagnostic.setloclist()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>de', ':lua vim.diagnostic.open_float()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '[d', ':lua vim.diagnostic.goto_prev()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', ']d', ':lua vim.diagnostic.goto_next()<CR>', { noremap = true, silent = true })

-- D* = advanced debug (powerful options)
vim.api.nvim_set_keymap('n', '<leader>Db', ':lua require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))<CR>', { noremap = true, silent = true })

-- F-keys for debugging (standard across IDEs, can remove if you prefer d* only)
vim.api.nvim_set_keymap('n', '<F5>', ':lua require("dap").continue()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<F10>', ':lua require("dap").step_over()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<F11>', ':lua require("dap").step_into()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<F12>', ':lua require("dap").step_out()<CR>', { noremap = true, silent = true })

-- Misc
vim.api.nvim_set_keymap('n', '<leader><space>', ':noh<CR>', { noremap = true, silent = true })
