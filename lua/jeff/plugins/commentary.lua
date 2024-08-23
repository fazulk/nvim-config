return {
  'tpope/vim-commentary',
  config = function()
    vim.keymap.set('n', '<C-_>', 'gcc', { remap = true })
    vim.keymap.set('v', '<C-_>', 'gc', { remap = true })
    vim.keymap.set('i', '<C-_>', '<C-o>gcc', { remap = true })
  end,
}
