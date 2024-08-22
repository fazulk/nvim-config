return {
  'NeogitOrg/neogit',
  dependencies = {
    'nvim-lua/plenary.nvim', -- required
    'sindrets/diffview.nvim', -- optional - Diff integration

    -- Only one of these is needed, not both.
    'nvim-telescope/telescope.nvim', -- optional
    'ibhagwan/fzf-lua', -- optional
  },
  config = function() -- This is the function that runs, AFTER loading
    local neogit = require 'neogit'
    neogit.setup {}

    local keymap = vim.keymap
    keymap.set('n', '<leader>gs', neogit.open, { silent = true, noremap = true })
    keymap.set('n', '<leader>gp', ':Neogit pull<CR>', { silent = true, noremap = true })
  end,
}
