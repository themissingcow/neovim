--- Plugins {{{
-- Install packer if we need to...

local install_path = vim.fn.stdpath 'data' .. '/site/pack/packer/start/packer.nvim'

if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
  vim.fn.execute('!git clone https://github.com/wbthomason/packer.nvim ' .. install_path)
end

-- Auto re-source init when edited
local packer_group = vim.api.nvim_create_augroup('Packer', { clear = true })
vim.api.nvim_create_autocmd('BufWritePost', {
  command = 'source <afile> | PackerCompile',
  group = packer_group,
  pattern = 'init.lua'
})

require('packer').startup(function(use)

  use 'wbthomason/packer.nvim'

  -- Git
  use 'tpope/vim-fugitive'
  use 'lewis6991/gitsigns.nvim'
  use 'f-person/git-blame.nvim'

  -- Language support
  use 'editorconfig/editorconfig-vim'
  use "fladson/vim-kitty"
  use 'ilyachur/cmake4vim'
  use 'p00f/clangd_extensions.nvim'

  -- Misc UI
  use 'lukas-reineke/indent-blankline.nvim'
  use 'nvim-lualine/lualine.nvim'
  use 'folke/trouble.nvim'
  use { "nvim-neo-tree/neo-tree.nvim", branch = "v2.x", requires = { "nvim-lua/plenary.nvim", "kyazdani42/nvim-web-devicons", "MunifTanjim/nui.nvim", } }
  use {"akinsho/toggleterm.nvim", tag = 'v2.*'}
  use 'antoinemadec/FixCursorHold.nvim'

  -- Tools
  use 'tpope/vim-abolish'
  use 'bkad/CamelCaseMotion'
  use 'vim-test/vim-test'

  -- LSP
  use 'neovim/nvim-lspconfig'
  use { "jose-elias-alvarez/null-ls.nvim", requires = { "nvim-lua/plenary.nvim" } }
  use 'nvim-treesitter/nvim-treesitter'
  use 'nvim-treesitter/nvim-treesitter-textobjects'

  -- Autocomplete
  use 'hrsh7th/nvim-cmp'
  use 'hrsh7th/cmp-buffer'
  use 'hrsh7th/cmp-omni'
  use 'hrsh7th/cmp-path'
  use 'hrsh7th/cmp-nvim-lsp'
  use 'saadparwaiz1/cmp_luasnip'
  use 'L3MON4D3/LuaSnip'

  -- Fzf
  use { 'junegunn/fzf', run = './install --bin', }
  use { 'ibhagwan/fzf-lua', requires = { 'kyazdani42/nvim-web-devicons' } }
  use 'gfanto/fzf-lsp.nvim'

  -- Colors
  use 'sainnhe/everforest'
  use 'felipevolpone/mono-theme'

end)

--- }}}
--- Options {{{


-- Text
vim.o.wrap = false
vim.o.breakindent = true
vim.o.spelloptions = 'camel'
vim.o.spellcapcheck = ''
vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.o.expandtab = false

-- Search
vim.o.hlsearch = false
vim.o.ignorecase = true
vim.o.smartcase = true

-- Display
vim.o.termguicolors = true
vim.wo.colorcolumn = "72,99"
vim.wo.number = true
vim.wo.signcolumn = 'yes'
vim.o.equalalways = false
vim.o.scrolloff = 8

-- Interactivity
vim.o.updatetime = 500
vim.o.mouse = 'a'

-- File Management
vim.o.undofile = true

-- }}}
--- Colors {{{

vim.g.everforest_background = "medium"
vim.cmd [[colorscheme everforest]]

vim.cmd [[
hi ErrorText cterm=underline gui=underline
hi WarningText cterm=underline gui=underline
hi InfoText cterm=underline gui=underline
hi HintText cterm=underline gui=underline

hi SpellBad cterm=undercurl gui=undercurl
]]


-- }}}
--- LSP {{{

-- Null-ls

local builtins = require("null-ls").builtins
require("null-ls").setup({
  sources = {
    builtins.diagnostics.pylint,
    builtins.diagnostics.jsonlint,
    builtins.diagnostics.yamllint,
    builtins.diagnostics.yamllint,
    builtins.diagnostics.markdownlint,
    builtins.formatting.markdownlint,
    builtins.formatting.black,
    builtins.formatting.cmake_format,
    builtins.code_actions.gitsigns
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
    on_attach = function(unused, buffnr)
			on_attach(unused, buffnr)
			vim.keymap.set('n', '<leader>ga', ':ClangdSwitchSourceHeader<CR>') 
		end,
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

vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
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

-- }}}
--- Autocomplete {{{

vim.o.completeopt = 'menu,menuone,noselect'

-- luasnip setup
local luasnip = require 'luasnip'

-- nvim-cmp setup
local cmp = require 'cmp'
cmp.setup {
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<CR>'] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    },
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { 'i', 's' }),
  }),
  sources = {
    { name = 'nvim_lsp' },
    { name = 'omni' },
    { name = 'path' },
    { name = 'luasnip' }
  },
  sorting = {
    comparators = {
      cmp.config.compare.offset,
      cmp.config.compare.exact,
      cmp.config.compare.recently_used,
      require("clangd_extensions.cmp_scores"),
      cmp.config.compare.kind,
      cmp.config.compare.sort_text,
      cmp.config.compare.length,
      cmp.config.compare.order,
    },
  },
}

cmp.setup.filetype('gitcommit', {
  sources = {
    { name = 'buffer' }
  }
})

cmp.setup.filetype('json', {
  sources = {
    { name = 'buffer' }
  }
})

-- }}}
--- Autocmd {{{

vim.api.nvim_create_autocmd({ 'FileType' }, {
  desc = 'python settings',
  pattern = 'python,yaml,c,cpp,markdown,go',
  command = 'set spell'
})

vim.api.nvim_create_autocmd({ 'FileType' }, {
  desc = 'doxygen comments',
  pattern = 'python,c,cpp',
  command = 'set comments^=:///'
})

vim.api.nvim_create_autocmd({ 'BufEnter' }, {
  desc = 'doxygen ft',
  pattern = '*.dox',
  command = 'set ft=c.doxygen'
})

vim.api.nvim_create_autocmd({ 'TermOpen' }, {
  desc = 'term setup',
  pattern = '*',
  command = 'set nospell nonumber'
})


-- Lualine

local git_blame = require('gitblame')
local get_color = require'lualine.utils.utils'.extract_highlight_colors

require('lualine').setup {
  options = {
    icons_enabled = true,
    theme = 'everforest',
    component_separators = '|',
    section_separators = '',
  },
  sections = {
    lualine_b = {
      {
        "diagnostics",
      	diagnostics_color = {
         error = {fg = get_color("DiagnosticSignError", "fg")},
         warn = {fg = get_color("DiagnosticSignWarn", "fg")},
         info = {fg = get_color("DiagnosticSignInfo", "fg")},
         hint = {fg = get_color("DiagnosticSignHint", "fg")},
	     }
      }
    },
    lualine_c = {
        { git_blame.get_current_blame_text, cond = git_blame.is_blame_text_available }
    },
    lualine_x = {'filename', 'encoding', 'fileformat', 'filetype'},

  }
}

-- CMake

vim.g.cmake_build_dir_prefix = "build/"
vim.g.cmake_ctest_args = "--output-on-failure"

vim.keymap.set('n', '<leader>cb', ':CMakeBuild<CR>')
vim.keymap.set('n', '<leader>ct', ':CTest<CR>')


-- Indent blankline
--
require('indent_blankline').setup { char = '┊', show_trailing_blankline_indent = false }

-- Diagnostic keymaps
--
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next)

-- Git blame

vim.g.gitblame_message_template = '<summary> [<author>]'
vim.g.gitblame_display_virtual_text = 0

-- Git signs

require('gitsigns').setup{
  on_attach = function(bufnr)
    local gs = package.loaded.gitsigns

    local function map(mode, l, r, opts)
      opts = opts or {}
      opts.buffer = bufnr
      vim.keymap.set(mode, l, r, opts)
    end

    -- Navigation
    map('n', ']c', function()
      if vim.wo.diff then return ']c' end
      vim.schedule(function() gs.next_hunk() end)
      return '<Ignore>'
    end, {expr=true})

    map('n', '[c', function()
      if vim.wo.diff then return '[c' end
      vim.schedule(function() gs.prev_hunk() end)
      return '<Ignore>'
    end, {expr=true})

    -- Actions
    map({'n', 'v'}, '<leader>hs', ':Gitsigns stage_hunk<CR>')
    map({'n', 'v'}, '<leader>hr', ':Gitsigns reset_hunk<CR>')
    map('n', '<leader>hS', gs.stage_buffer)
    map('n', '<leader>hu', gs.undo_stage_hunk)
    map('n', '<leader>hR', gs.reset_buffer)
    map('n', '<leader>hp', gs.preview_hunk)
    map('n', '<leader>hb', function() gs.blame_line{full=true} end)
    map('n', '<leader>tb', gs.toggle_current_line_blame)
    map('n', '<leader>hd', gs.diffthis)
    map('n', '<leader>hD', function() gs.diffthis('~') end)
    map('n', '<leader>td', gs.toggle_deleted)

    -- Text object
    map({'o', 'x'}, 'ih', ':<C-U>Gitsigns select_hunk<CR>')
  end
}

-- Test

vim.keymap.set('n', '<leader>tn', ':TestNearest<CR>', { silent = true })
vim.keymap.set('n', '<leader>tf', ':TestFile<CR>', { silent = true })
vim.keymap.set('n', '<leader>ts', ':TestSuite<CR>', { silent = true })
vim.keymap.set('n', '<leader>tl', ':TestLast<CR>', { silent = true })
vim.keymap.set('n', '<leader>tv', ':TestVisit<CR>', { silent = true })

vim.cmd [[
let test#strategy="neovim"
let test#python#runner="pytest"
]]

-- NeoTree

vim.keymap.set('', '<leader>bf', ':Neotree toggle<CR>', { noremap = true, script = true })
vim.keymap.set('', '<leader>bg', ':Neotree git_status toggle<CR>', { noremap = true, script = true })

-- fzf

vim.keymap.set('', ';', require 'fzf-lua'.files, { noremap = true })
vim.keymap.set('', '<leader>sf', require 'fzf-lua'.files, { noremap = true })
vim.keymap.set('', '<leader>sb', require 'fzf-lua'.buffers, { noremap = true })
vim.keymap.set('', '<leader>st', require 'fzf-lua'.live_grep, { noremap = true })
vim.keymap.set('', '<leader>sw', require 'fzf-lua'.grep_cword, { noremap = true })
vim.keymap.set('', '<leader>sg', require 'fzf-lua'.git_commits, { noremap = true })
vim.keymap.set('', '<leader>ss', require 'fzf-lua'.spell_suggest, { noremap = true })
vim.keymap.set('', '<leader>so', require 'fzf-lua'.lsp_document_symbols, { noremap = true })
vim.keymap.set('', '<leader>sl', require 'fzf-lua'.resume, { noremap = true })

require('fzf-lua').setup {
  winopts = { preview = { horizontal = 'right:40%' } },
  files = { previewer = false }
}

-- Toggleterm

require("toggleterm").setup {
    open_mapping = [[<c-t>]],
}

-- }}}
--- Bits and bobs {{{

-- Retain selection after re-indenting
vim.keymap.set('v', '<', '<gv')
vim.keymap.set('v', '>', '>gv')

-- Easier window navigation
vim.keymap.set('n', '<c-j>', '<c-w>j')
vim.keymap.set('n', '<c-k>', '<c-w>k')
vim.keymap.set('n', '<c-l>', '<c-w>l')
vim.keymap.set('n', '<c-h>', '<c-w>h')
vim.keymap.set('i', '<c-j>', '<c-\\><c-n><c-w>ji')
vim.keymap.set('i', '<c-h>', '<c-\\><c-n><c-w>hi')
vim.keymap.set('i', '<c-l>', '<c-\\><c-n><c-w>li')
vim.keymap.set('i', '<c-h>', '<c-\\><c-n><c-w>hi')

-- Strip trailing whitespace
vim.keymap.set('', '<leader>S', ':%s/\\s+\\n/\\r/g<CR>', { noremap = true, silent = true })

-- Open buffer in default editor app
vim.keymap.set('', '<leader>o', ':!open %<CR>', { silent = true })

-- To migrate to LUA...
vim.cmd [[

" Sticky shift...
cnoreabbrev W w

" Camelcase motion by default
call camelcasemotion#CreateMotionMappings(',')
nmap w ,w
nmap b ,b


" Comment-wrap, always at 72 regardless of textwidth
function! CommentWrap() range
	let l:oldtextwidth=&textwidth
	let &textwidth=72
	execute "normal! gvgq"
	let &textwidth=l:oldtextwidth
endfunction

vnoremap <leader>fc :<c-u>call CommentWrap()<CR>

]]

-- vim: ts=2 sts=2 sw=2 foldmethod=marker
