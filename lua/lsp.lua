-- Null-ls

local builtins = require("null-ls").builtins
require("null-ls").setup({
  sources = {
    builtins.diagnostics.codespell,
    builtins.diagnostics.pylint,
    builtins.diagnostics.jsonlint,
    builtins.diagnostics.yamllint,
    builtins.diagnostics.yamllint,
    builtins.diagnostics.markdownlint,
    builtins.formatting.markdownlint,
    builtins.formatting.black,
    builtins.formatting.cmake_format
  }
})

-- LSP settings
local lspconfig = require 'lspconfig'
local on_attach = function(_, bufnr)
  local opts = { buffer = bufnr }
  vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
  vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
  vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
  vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
  vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
  vim.keymap.set('n', '<leader>wa', vim.lsp.buf.add_workspace_folder, opts)
  vim.keymap.set('n', '<leader>wr', vim.lsp.buf.remove_workspace_folder, opts)
  vim.keymap.set('n', '<leader>wl', function() vim.inspect(vim.lsp.buf.list_workspace_folders()) end, opts)
  vim.keymap.set('n', '<leader>D', vim.lsp.buf.type_definition, opts)
  vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
  vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
  vim.api.nvim_create_user_command("Format", vim.lsp.buf.formatting, {})
  vim.api.nvim_create_user_command("FormatRange", vim.lsp.buf.range_formatting, {})
  vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, opts)
  vim.keymap.set('n', '<leader>fb', vim.lsp.buf.formatting, opts)
  vim.keymap.set('n', '<leader>fr', vim.lsp.buf.range_formatting, opts)
end

-- nvim-cmp supports additional completion capabilities
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').update_capabilities(capabilities)

-- Enable the following language servers
local servers = { 'marksman', 'yamlls', 'rust_analyzer', 'pyright', 'tsserver' }
for _, lsp in ipairs(servers) do
  lspconfig[lsp].setup {
    on_attach = on_attach,
    capabilities = capabilities,
    flags = { debounce_text_changes = 500 }
  }
end

require("clangd_extensions").setup {
  server = {
    on_attach = on_attach,
    capabilities = capabilities,
    flags = { debounce_text_changes = 500 }
  }
}

-- Treesitter configuration
-- Parsers must be installed manually via :TSInstall
require('nvim-treesitter.configs').setup {
  ensure_installed = { "c", "cpp", "python", "yaml", "json", "html", "lua", "dot", "cmake", "bash" },
  highlight = {
    enable = true, -- false will disable the whole extension
  },
  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = 'gnn',
      node_incremental = 'grn',
      scope_incremental = 'grc',
      node_decremental = 'grm',
    },
  },
  indent = {
    enable = true,
  },
  textobjects = {
    select = {
      enable = true,
      lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
      keymaps = {
        -- You can use the capture groups defined in textobjects.scm
        ['af'] = '@function.outer',
        ['if'] = '@function.inner',
        ['ac'] = '@class.outer',
        ['ic'] = '@class.inner',
      },
    },
    move = {
      enable = true,
      set_jumps = true, -- whether to set jumps in the jumplist
      goto_next_start = {
        [']m'] = '@function.outer',
        [']]'] = '@class.outer',
      },
      goto_next_end = {
        [']M'] = '@function.outer',
        [']['] = '@class.outer',
      },
      goto_previous_start = {
        ['[m'] = '@function.outer',
        ['[['] = '@class.outer',
      },
      goto_previous_end = {
        ['[M'] = '@function.outer',
        ['[]'] = '@class.outer',
      },
    },
  },
}

-- Diagnostics presentation

vim.diagnostic.config({
  signs = true,
  virtual_text = false,
  update_in_insert = false,
  severity_sort = true
})

local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
for type, icon in pairs(signs) do
  local hl = "DiagnosticSign" .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

vim.api.nvim_create_autocmd({ 'CursorHold,CursorHoldI' }, {
  desc = 'Diagnostics popver',
  pattern = '*',
  command = 'lua vim.diagnostic.open_float(nil, {focus=false})'
})

-- Trouble

vim.keymap.set('n', '<leader>td', function() require 'trouble'.open('document_diagnostics') end)
vim.keymap.set('n', '<leader>tr', function() require 'trouble'.open('lsp_references') end)
vim.keymap.set('n', '<leader>tw', function() require 'trouble'.open('workspace_diagnostics') end)
vim.keymap.set('n', '<leader>tq', function() require 'trouble'.open('quickfix') end)
vim.keymap.set('n', '<leader>tt', function() require 'trouble'.toggle() end)

