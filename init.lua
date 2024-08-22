require 'jeff.core.global'

if vim.g.vscode then
    require 'vscode-local'
else
    require('jeff.core')
    require('jeff.lazy')
end
