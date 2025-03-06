return {
  'neovim/nvim-lspconfig',
  event = { 'BufReadPre', 'BufNewFile' },
  dependencies = {
    'hrsh7th/cmp-nvim-lsp',
    { 'antosha417/nvim-lsp-file-operations', config = true },
    { 'folke/neodev.nvim', opts = {} },
  },
  config = function()
    -- import lspconfig plugin
    local lspconfig = require 'lspconfig'

    -- import mason_lspconfig plugin
    local mason_lspconfig = require 'mason-lspconfig'

    -- import cmp-nvim-lsp plugin
    local cmp_nvim_lsp = require 'cmp_nvim_lsp'

    local keymap = vim.keymap -- for conciseness

    vim.api.nvim_create_autocmd('LspAttach', {
      group = vim.api.nvim_create_augroup('UserLspConfig', {}),
      callback = function(ev)
        -- Buffer local mappings.
        -- See `:help vim.lsp.*` for documentation on any of the below functions
        local opts = { buffer = ev.buf, silent = true }

        local function rename_and_save()
          -- Store the current buffer number
          local current_buf = vim.api.nvim_get_current_buf()

          -- Perform the LSP rename
          vim.lsp.buf.rename()

          -- Use a timer to delay the saving operation
          -- This ensures that the rename has completed
          vim.defer_fn(function()
            -- Get all buffer numbers
            local buffers = vim.api.nvim_list_bufs()

            for _, buf in ipairs(buffers) do
              -- Check if the buffer is loaded and modified
              if vim.api.nvim_buf_is_loaded(buf) and vim.api.nvim_buf_get_option(buf, 'modified') then
                -- Get the buffer name (file path)
                local bufname = vim.api.nvim_buf_get_name(buf)

                -- Save the buffer if it's associated with a file
                if bufname ~= '' then
                  vim.api.nvim_buf_call(buf, function()
                    vim.cmd 'silent write'
                  end)
                end
              end
            end

            vim.api.nvim_set_current_buf(current_buf)
          end, 100) -- 100ms delay, adjust if needed
        end

        -- set keybinds
        opts.desc = 'Show LSP references'
        keymap.set('n', 'gR', '<cmd>Telescope lsp_references<CR>', opts) -- show definition, references

        opts.desc = 'Go to declaration'
        keymap.set('n', 'gD', vim.lsp.buf.declaration, opts) -- go to declaration

        opts.desc = 'Show LSP definitions'
        keymap.set('n', 'gd', '<cmd>Telescope lsp_definitions<CR>', opts) -- show lsp definitions

        opts.desc = 'Show LSP implementations'
        keymap.set('n', 'gi', '<cmd>Telescope lsp_implementations<CR>', opts) -- show lsp implementations

        opts.desc = 'Show LSP type definitions'
        keymap.set('n', 'gt', '<cmd>Telescope lsp_type_definitions<CR>', opts) -- show lsp type definitions

        opts.desc = 'See available code actions'
        keymap.set({ 'n', 'v' }, '<leader>ca', vim.lsp.buf.code_action, opts) -- see available code actions, in visual mode will apply to selection

        -- opts.desc = 'Smart rename'
        -- keymap.set('n', '<F2>', vim.lsp.buf.rename, opts) -- smart rename
        -- Set up a keymap to use this function
        keymap.set('n', '<F2>', rename_and_save, { noremap = true, silent = true, desc = 'Smart rename' })

        opts.desc = 'Show buffer diagnostics'
        keymap.set('n', '<leader>D', '<cmd>Telescope diagnostics bufnr=0<CR>', opts) -- show  diagnostics for file

        opts.desc = 'Show line diagnostics'
        keymap.set('n', '<leader>d', vim.diagnostic.open_float, opts) -- show diagnostics for line

        opts.desc = 'Go to previous diagnostic'
        keymap.set('n', '<f20>', vim.diagnostic.goto_prev, opts) -- jump to previous diagnostic in buffer

        opts.desc = 'Go to next diagnostic'
        keymap.set('n', '<f8>', vim.diagnostic.goto_next, opts) -- jump to next diagnostic in buffer

        opts.desc = 'Show documentation for what is under cursor'
        keymap.set('n', 'gh', vim.lsp.buf.hover, opts) -- show documentation for what is under cursor

        opts.desc = 'Restart LSP'
        keymap.set('n', '<leader>rs', ':LspRestart<CR>', opts) -- mapping to restart lsp if necessary
      end,
    })

    -- used to enable autocompletion (assign to every lsp server config)
    local capabilities = cmp_nvim_lsp.default_capabilities()

    -- Change the Diagnostic symbols in the sign column (gutter)
    -- (not in youtube nvim video)
    local signs = { Error = ' ', Warn = ' ', Hint = '󰠠 ', Info = ' ' }
    for type, icon in pairs(signs) do
      local hl = 'DiagnosticSign' .. type
      vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = '' })
    end

    mason_lspconfig.setup_handlers {
      -- default handler for installed servers
      function(server_name)
        lspconfig[server_name].setup {
          capabilities = capabilities,
        }
      end,
      ['ts_ls'] = function()
        lspconfig['ts_ls'].setup {
          filetypes = { 'typescript', 'javascript', 'javascriptreact', 'typescriptreact', 'vue' },
          init_options = {
            plugins = {
              {
                name = '@vue/typescript-plugin',
                location = vim.fn.stdpath 'data' .. '/mason/packages/vue-language-server/node_modules/@vue/language-server',
                languages = { 'vue' },
              },
            },
          },
        }
      end,
      ['volar'] = function()
        lspconfig['volar'].setup {}
      end,
      ['emmet_ls'] = function()
        -- configure emmet language server
        lspconfig['emmet_ls'].setup {
          capabilities = capabilities,
          filetypes = { 'html', 'typescriptreact', 'javascriptreact', 'css', 'sass', 'scss', 'less', 'svelte' },
        }
      end,
      ['lua_ls'] = function()
        -- configure lua server (with special settings)
        lspconfig['lua_ls'].setup {
          capabilities = capabilities,
          settings = {
            Lua = {
              -- make the language server recognize "vim" global
              diagnostics = {
                globals = { 'vim' },
              },
              completion = {
                callSnippet = 'Replace',
              },
            },
          },
        }
      end,
    }

    local customizations = {
      { rule = 'style/*', severity = 'off', fixable = true },
      { rule = 'format/*', severity = 'off', fixable = true },
      { rule = '*-indent', severity = 'off', fixable = true },
      { rule = '*-spacing', severity = 'off', fixable = true },
      { rule = '*-spaces', severity = 'off', fixable = true },
      { rule = '*-order', severity = 'off', fixable = true },
      { rule = '*-dangle', severity = 'off', fixable = true },
      { rule = '*-newline', severity = 'off', fixable = true },
      { rule = '*quotes', severity = 'off', fixable = true },
      { rule = '*semi', severity = 'off', fixable = true },
    }
    lspconfig.eslint.setup {
      filetypes = {
        'javascript',
        'javascriptreact',
        'javascript.jsx',
        'typescript',
        'typescriptreact',
        'typescript.tsx',
        'vue',
        'html',
        'markdown',
        'json',
        'jsonc',
        'yaml',
        'toml',
        'xml',
        'gql',
        'graphql',
        'astro',
        'svelte',
        'css',
        'less',
        'scss',
        'pcss',
        'postcss',
      },
      settings = {
        -- Silent the stylistic rules in you IDE, but still auto fix them
        rulesCustomizations = customizations,
      },
    }

    lspconfig.eslint.setup {
      on_attach = function(client, bufnr)
        vim.api.nvim_create_autocmd('BufWritePre', {
          buffer = bufnr,
          command = 'EslintFixAll',
        })
      end,
    }
  end,
}

-- --
-- return {

--   -- Main LSP Configuration
--   'neovim/nvim-lspconfig',
--   dependencies = {
--     -- Automatically install LSPs and related tools to stdpath for Neovim
--     { 'williamboman/mason.nvim', config = true }, -- NOTE: Must be loaded before dependants
--     'williamboman/mason-lspconfig.nvim',
--     'WhoIsSethDaniel/mason-tool-installer.nvim',

--     -- Useful status updates for LSP.
--     -- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
--     { 'j-hui/fidget.nvim', opts = {} },

--     -- Allows extra capabilities provided by nvim-cmp
--     'hrsh7th/cmp-nvim-lsp',
--   },
--   config = function()
--     -- Brief aside: **What is LSP?**
--     --
--     -- LSP is an initialism you've probably heard, but might not understand what it is.
--     --
--     -- LSP stands for Language Server Protocol. It's a protocol that helps editors
--     -- and language tooling communicate in a standardized fashion.
--     --
--     -- In general, you have a "server" which is some tool built to understand a particular
--     -- language (such as `gopls`, `lua_ls`, `rust_analyzer`, etc.). These Language Servers
--     -- (sometimes called LSP servers, but that's kind of like ATM Machine) are standalone
--     -- processes that communicate with some "client" - in this case, Neovim!
--     --
--     -- LSP provides Neovim with features like:
--     --  - Go to definition
--     --  - Find references
--     --  - Autocompletion
--     --  - Symbol Search
--     --  - and more!
--     --
--     -- Thus, Language Servers are external tools that must be installed separately from
--     -- Neovim. This is where `mason` and related plugins come into play.
--     --
--     -- If you're wondering about lsp vs treesitter, you can check out the wonderfully
--     -- and elegantly composed help section, `:help lsp-vs-treesitter`

--     --  This function gets run when an LSP attaches to a particular buffer.
--     --    That is to say, every time a new file is opened that is associated with
--     --    an lsp (for example, opening `main.rs` is associated with `rust_analyzer`) this
--     --    function will be executed to configure the current buffer
--     vim.api.nvim_create_autocmd('LspAttach', {
--       group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
--       callback = function(event)

--         -- In this case, we create a function that lets us more easily define mappings specific
--         -- for LSP related items. It sets the mode, buffer and description for us each time.
--         local map = function(keys, func, desc)
--           vim.keymap.set('n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
--         end

--         -- Jump to the definition of the word under your cursor.
--         --  This is where a variable was first declared, or where a function is defined, etc.
--         --  To jump back, press <C-t>.
--         map('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')

--         -- Find references for the word under your cursor.
--         map('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')

--         -- Jump to the implementation of the word under your cursor.
--         --  Useful when your language has ways of declaring types without an actual implementation.
--         map('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')

--         -- Jump to the type of the word under your cursor.
--         --  Useful when you're not sure what type a variable is and you want to see
--         --  the definition of its *type*, not where it was *defined*.
--         map('<leader>D', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')

--         -- Fuzzy find all the symbols in your current document.
--         --  Symbols are things like variables, functions, types, etc.
--         map('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')

--         -- Fuzzy find all the symbols in your current workspace.
--         --  Similar to document symbols, except searches over your entire project.
--         map('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')

--         -- Rename the variable under your cursor.
--         --  Most Language Servers support renaming across files, etc.
--         map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')

--         -- Execute a code action, usually your cursor needs to be on top of an error
--         -- or a suggestion from your LSP for this to activate.
--         map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')

--         -- WARN: This is not Goto Definition, this is Goto Declaration.
--         --  For example, in C this would take you to the header.
--         map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

--         -- The following two autocommands are used to highlight references of the
--         -- word under your cursor when your cursor rests there for a little while.
--         --    See `:help CursorHold` for information about when this is executed
--         --
--         -- When you move your cursor, the highlights will be cleared (the second autocommand).
--         local client = vim.lsp.get_client_by_id(event.data.client_id)
--         if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
--           local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
--           vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
--             buffer = event.buf,
--             group = highlight_augroup,
--             callback = vim.lsp.buf.document_highlight,
--           })

--           vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
--             buffer = event.buf,
--             group = highlight_augroup,
--             callback = vim.lsp.buf.clear_references,
--           })

--           vim.api.nvim_create_autocmd('LspDetach', {
--             group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
--             callback = function(event2)
--               vim.lsp.buf.clear_references()
--               vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
--             end,
--           })
--         end

--         -- The following code creates a keymap to toggle inlay hints in your
--         -- code, if the language server you are using supports them
--         --
--         -- This may be unwanted, since they displace some of your code
--         if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
--           map('<leader>th', function()
--             vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
--           end, '[T]oggle Inlay [H]ints')
--         end
--       end,
--     })

--     -- LSP servers and clients are able to communicate to each other what features they support.
--     --  By default, Neovim doesn't support everything that is in the LSP specification.
--     --  When you add nvim-cmp, luasnip, etc. Neovim now has *more* capabilities.
--     --  So, we create new capabilities with nvim cmp, and then broadcast that to the servers.
--     local capabilities = vim.lsp.protocol.make_client_capabilities()
--     capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())

--     -- Enable the following language servers
--     --  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
--     --
--     --  Add any additional override configuration in the following tables. Available keys are:
--     --  - cmd (table): Override the default command used to start the server
--     --  - filetypes (table): Override the default list of associated filetypes for the server
--     --  - capabilities (table): Override fields in capabilities. Can be used to disable certain LSP features.
--     --  - settings (table): Override the default settings passed when initializing the server.
--     --        For example, to see the options for `lua_ls`, you could go to: https://luals.github.io/wiki/settings/
--     local servers = {

--       require('lspconfig').tailwindcss.setup {},
--       require('lspconfig').volar.setup {},

--       -- clangd = {},
--       -- gopls = {},
--       -- pyright = {},
--       -- ... etc. See `:help lspconfig-all` for a list of all the pre-configured LSPs
--       --
--       -- Some languages (like typescript) have entire language plugins that can be useful:
--       --    https://github.com/pmizio/typescript-tools.nvim
--       --
--       -- But for many setups, the LSP (`tsserver`) will work just fine
--       tsserver = {},
--       --
--       lua_ls = {
--         -- cmd = {...},
--         -- filetypes = { ...},
--         -- capabilities = {},
--         settings = {
--           Lua = {
--             completion = {
--               callSnippet = 'Replace',
--             },
--             -- You can toggle below to ignore Lua_LS's noisy `missing-fields` warnings
--             -- diagnostics = { disable = { 'missing-fields' } },
--           },
--         },
--       },
--     }

--     -- Ensure the servers and tools above are installed
--     --  To check the current status of installed tools and/or manually install
--     --  other tools, you can run
--     --    :Mason
--     --
--     --  You can press `g?` for help in this menu.
--     require('mason').setup()

--     -- You can add other tools here that you want Mason to install
--     -- for you, so that they are available from within Neovim.
--     local ensure_installed = vim.tbl_keys(servers or {})
--     vim.list_extend(ensure_installed, {
--       'stylua', -- Used to format Lua code
--     })
--     require('mason-tool-installer').setup { ensure_installed = ensure_installed }

--     require('mason-lspconfig').setup {
--       handlers = {
--         function(server_name)
--           local server = servers[server_name] or {}
--           -- This handles overriding only values explicitly passed
--           -- by the server configuration above. Useful when disabling
--           -- certain features of an LSP (for example, turning off formatting for tsserver)
--           server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
--           require('lspconfig')[server_name].setup(server)
--         end,
--       },
--     }
--   end,
-- }
