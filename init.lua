-- Extend RTP
vim.cmd [[set runtimepath=$TOOLCHAIN_ROOT/config/nvim,$VIMRUNTIME]]

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
  use 'airblade/vim-gitgutter'
  use 'f-person/git-blame.nvim'

  -- Language support
  use 'editorconfig/editorconfig-vim'
  use "fladson/vim-kitty"
  use 'cdelledonne/vim-cmake'
  use 'p00f/clangd_extensions.nvim'

  -- Misc UI
  use 'lukas-reineke/indent-blankline.nvim'
  use 'nvim-lualine/lualine.nvim'
  use 'folke/trouble.nvim'
  use { "nvim-neo-tree/neo-tree.nvim", branch = "v2.x", requires = { "nvim-lua/plenary.nvim", "kyazdani42/nvim-web-devicons", "MunifTanjim/nui.nvim", } }
  use {"akinsho/toggleterm.nvim", tag = 'v2.*'}

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

require('options')
require('colors')
require('lsp')
require('autocomplete')
require('autocmd')

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

vim.g.cmake_build_dir_location = "build"

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

--- Bits and bobs

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

-- vim: ts=2 sts=2 sw=2 et
