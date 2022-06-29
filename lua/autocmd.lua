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

