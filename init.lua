require 'jeff.core.global'

if vim.g.vscode then
  require 'vscode-local'
else
  require 'jeff.core'
  require 'jeff.lazy'

  function ReloadConfig()
    vim.notify('All plugins and configuration reloaded!', vim.log.levels.INFO)
  end

  vim.keymap.set('n', '<leader>rr', ReloadConfig, { noremap = true, silent = true, desc = 'Reload config and plugins' })
end
