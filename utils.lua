vim.api.nvim_set_keymap('n', '?', "<Cmd>lua require('utils').vscode_search()<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap('x', '?', ":<C-U>lua require('utils').vscode_search(true)<CR>", { noremap = true, silent = true })

local utils = {}

function utils.vscode_search(visual_mode)
  local query
  if visual_mode then
    local _, csrow, cscol, _ = unpack(vim.fn.getpos("'<"))
    local _, cerow, cecol, _ = unpack(vim.fn.getpos("'>"))
    local lines = vim.api.nvim_buf_get_lines(0, csrow - 1, cerow, false)
    if #lines == 1 then
      query = string.sub(lines[1], cscol, cecol)
    else
      lines[1] = string.sub(lines[1], cscol)
      lines[#lines] = string.sub(lines[#lines], 1, cecol)
      query = table.concat(lines, '\n')
    end
  else
    query = vim.fn.expand('<cword>')
  end
  vim.fn.VSCodeNotify('workbench.action.findInFiles', { query = query })
end

return utils
