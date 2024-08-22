return {
  'robitx/gp.nvim',
  config = function()
    local conf = {
      providers = {
        anthropic = {
          disable = false,
          endpoint = 'https://api.anthropic.com/v1/messages',
          secret = vim.fn.environ()['CLAUDE'],
        },
      },
      -- For customization, refer to Install > Configuration in the Documentation/Readme
    }
    require('gp').setup(conf)

    local keymap = vim.keymap
    keymap.set('n', '<leader>ii', ':GpChatNew vsplit<CR>', { silent = true, noremap = true })
  end,
}
