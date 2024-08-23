# cmdheight = 1 -- This is the extra config I added

local vscode = require 'vscode-neovim'
vim.notify = vscode.notify
-- set statusline=%<%f\ %h%m%r%=%-14.(%l,%c%V%)\ %P
-- Start in normal mode
vim.api.nvim_create_augroup('start_in_normal_mode', { clear = true })
vim.api.nvim_create_autocmd('BufEnter', {
  group = 'start_in_normal_mode',
  pattern = '*',
  command = 'call feedkeys("\\<Esc>")',
})


-- Git and harpoon mappings
local mappings = {
  { '0', 'git.openChange' },
  { '9', 'git.openFile' },
  { 'ca', 'editor.action.quickFix' },
  { 'a', 'vscode-harpoon.addGlobalEditor' },
  { 'h', 'vscode-harpoon.editGlobalEditors' },
  { 'pe', 'vscode-harpoon.editorGlobalQuickPick' },
  { 'b', 'vscode-harpoon.gotoPreviousGlobalHarpoonEditor' },
  { 'w', 'workbench.action.files.save' },
  { 'q', 'workbench.action.closeActiveEditor' },
  { '<Space>', 'workbench.action.quickOpen' },
  { 'e', 'workbench.view.explorer' },
  { 'gp', 'gitlens.diffWithPreviousInDiffRight' },
  { 'gn', 'gitlens.diffWithNextInDiffRight' },
}

for _, map in ipairs(mappings) do
  local leader_map = '<Leader>' .. map[1]
  local command = map[2] == 'put' and '<Cmd>put<CR>' or string.format("<Cmd>call VSCodeNotify('%s')<CR>", map[2])
  vim.api.nvim_set_keymap('n', leader_map, command, { noremap = true })
  vim.api.nvim_set_keymap('x', leader_map, command, { noremap = true })
  vim.api.nvim_set_keymap('v', leader_map, command, { noremap = true })
end

-- Harpoon dynamic mappings
for i = 1, 8 do
  local leader_map = '<Leader>' .. i
  local command = string.format("<Cmd>call VSCodeNotify('vscode-harpoon.gotoGlobalEditor%s')<CR>", i)
  vim.api.nvim_set_keymap('n', leader_map, command, { noremap = true })
  vim.api.nvim_set_keymap('x', leader_map, command, { noremap = true })

  local leader_map_add = '<Leader>a' .. i
  local command_add = string.format("<Cmd>call VSCodeNotify('vscode-harpoon.addGlobalEditor%s')<CR>", i)
  vim.api.nvim_set_keymap('n', leader_map_add, command_add, { noremap = true })
  vim.api.nvim_set_keymap('x', leader_map_add, command_add, { noremap = true })
end

-- Comment mapping
-- vim.api.nvim_set_keymap('x', "<C-/>", "<Cmd>call VSCodeNotify('editor.action.commentLine')<CR>", {noremap = true})
-- vim.api.nvim_set_keymap('n', "<C-/>", "<Cmd>call VSCodeNotify('editor.action.commentLine')<CR>", {noremap = true})

-- Replace selection with brackets and paste
vim.api.nvim_set_keymap('x', '<leader>r', 'xi[]<Esc>P', { noremap = true })

-- Search function for ?
vim.api.nvim_set_keymap('n', '?', '<Cmd>lua vscode_search(false)<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('x', '?', ':<C-U>lua vscode_search(true)<CR>', { noremap = true, silent = true })

function vscode_search(visual_mode)
  local query
  if visual_mode then
    local start_pos = vim.fn.getpos "'<"
    local end_pos = vim.fn.getpos "'>"
    local start_row, start_col = start_pos[2], start_pos[3]
    local end_row, end_col = end_pos[2], end_pos[3]
    local lines = vim.api.nvim_buf_get_lines(0, start_row - 1, end_row, false)
    if start_row == end_row then
      query = string.sub(lines[1], start_col, end_col)
    else
      lines[1] = string.sub(lines[1], start_col)
      lines[#lines] = string.sub(lines[#lines], 1, end_col)
      query = table.concat(lines, '\n')
    end
  else
    query = vim.fn.expand '<cword>'
  end
  vim.fn.VSCodeNotify('workbench.action.findInFiles', { query = query })
end
