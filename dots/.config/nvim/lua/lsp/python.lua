-- lsp/python.lua

-- local M = {}

-- M.setup = function(capabilities, no_diagnostics)
--     local lspconfig = require('lspconfig')

--     -- bessere Completion-Capabilities
--     capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

--     lspconfig.pylsp.setup({
--         capabilities = capabilities,
--         handlers = no_diagnostics,

--         -- handlers = {
--         --   ["textDocument/publishDiagnostics"] = function() end
--         -- }

--         settings = {
--             pylsp = {
--                 plugins = {
--                     -- klassische Linters AUS
--                     pycodestyle = { enabled = false },
--                     pyflakes    = { enabled = false },
--                     pylint      = { enabled = false },
--                     mccabe      = { enabled = false },

--                     -- Completion
--                     rope_completion = { enabled = false },
--                     jedi_completion = { enabled = true },

--                     -- Formatierung
--                     black = {
--                         enabled = true,
--                         line_length = 88,
--                     },
--                     yapf = { enabled = false },

--                     -- ruff im pylsp: lieber AUS
--                     ruff = { enabled = false },
--                 },
--             },
--         },

--         on_attach = function(client, bufnr)
--             -- Diagnostics wirklich abschalten
--             -- client.server_capabilities.diagnosticProvider = false
--             client.server_capabilities.diagnosticProvider = true

--             -- nur pylsp formatiert
--             client.server_capabilities.documentFormattingProvider = true

--             -- Semantic Tokens aus (optional, aber oft angenehmer)
--             client.server_capabilities.semanticTokensProvider = nil

--             local buf_map = function(mode, lhs, rhs, opts)
--                 opts = opts or {}
--                 opts.buffer = bufnr
--                 vim.keymap.set(mode, lhs, rhs, opts)
--             end

--             -- buf_map('n', 'gd', vim.lsp.buf.definition) -- Diese Tastenkombination ist bereits in plugins/keymaps definiert.
--             buf_map('n', 'K', vim.lsp.buf.hover)
--             buf_map('n', '<leader>rn', vim.lsp.buf.rename)
--             -- buf_map('n', '<leader>ca', vim.lsp.buf.code_action) -- Diese Tastenkombination ist bereits in plugins/keymaps definiert.
--             buf_map('n', '<leader>f', function()
--                 vim.lsp.buf.format({ async = true })
--             end)

--             buf_map('n', '<leader>oi', function()
--                 vim.lsp.buf.execute_command({
--                     command = 'pylsp.organizeImports',
--                     arguments = { vim.api.nvim_buf_get_name(0) },
--                 })
--             end)
--         end,
--     })
-- end

-- return M

-- local M = {}

-- M.setup = function(capabilities)
--     local lspconfig = require('lspconfig')

--     -- bessere Completion-Capabilities
--     capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

--     lspconfig.pylsp.setup({
--         capabilities = capabilities,

--         settings = {
--             pylsp = {
--                 plugins = {
--                     -- klassische Linters AUS
--                     pycodestyle = { enabled = false },
--                     pyflakes    = { enabled = false },
--                     pylint      = { enabled = false },
--                     mccabe      = { enabled = false },

--                     -- Completion
--                     rope_completion = { enabled = false },
--                     jedi_completion = { enabled = true },

--                     -- Formatierung
--                     -- black = {
--                     --     enabled = true,
--                     --     line_length = 88,
--                     -- },

--                     -- andere Formatierer deaktiviert
--                     yapf = { enabled = false },
--                     ruff = { enabled = false },
--                 },
--             },
--         },

--         on_attach = function(client, bufnr)
--             -- Diagnostics anlassen
--             client.server_capabilities.diagnosticProvider = true

--             -- Formatierung über pylsp (falls verfügbar)
--             client.server_capabilities.documentFormattingProvider = true

--             -- Semantic Tokens deaktivieren (optional)
--             client.server_capabilities.semanticTokensProvider = nil

--             -- Hilfsfunktion für Buffer-Local Keymaps
--             local buf_map = function(mode, lhs, rhs, opts)
--                 opts = opts or {}
--                 opts.buffer = bufnr
--                 vim.keymap.set(mode, lhs, rhs, opts)
--             end

--             -- LSP Keymaps
--             -- buf_map('n', 'gd', vim.lsp.buf.definition) -- Diese Tastenkombination ist bereits in plugins/keymaps definiert.
--             buf_map('n', 'K', vim.lsp.buf.hover)
--             buf_map('n', '<leader>rn', vim.lsp.buf.rename)
--             -- buf_map('n', '<leader>ca', vim.lsp.buf.code_action) -- Diese Tastenkombination ist bereits in plugins/keymaps definiert.
--             buf_map('n', '<leader>f', function()
--                 vim.lsp.buf.format({ async = true })
--             end)
--             buf_map('n', '<leader>oi', function()
--                 vim.lsp.buf.execute_command({
--                     command = 'pylsp.organizeImports',
--                     arguments = { vim.api.nvim_buf_get_name(0) },
--                 })
--             end)
--         end,
--     })
-- end

-- return M

-- local M = {}

-- M.setup = function(capabilities)
--     local lspconfig = require('lspconfig')

--     capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

--     lspconfig.pyright.setup({
--         capabilities = capabilities,

--         settings = {
--             python = {
--                 analysis = {
--                     typeCheckingMode = "strict", -- MAXIMUM STRICTNESS
--                     autoSearchPaths = true,
--                     useLibraryCodeForTypes = true,
--                     diagnosticMode = "workspace",

--                     reportMissingImports = true,
--                     reportMissingTypeStubs = false,
--                     reportUnusedVariable = true,
--                     reportUnusedImport = true,
--                     reportOptionalMemberAccess = true,
--                     reportOptionalSubscript = true,
--                     reportGeneralTypeIssues = true,
--                 },
--             },
--         },

--         on_attach = function(client, bufnr)
--             -- pyright macht KEIN formatting
--             client.server_capabilities.documentFormattingProvider = false

--             -- optional cleaner look
--             client.server_capabilities.semanticTokensProvider = nil

--             local buf_map = function(mode, lhs, rhs, opts)
--                 opts = opts or {}
--                 opts.buffer = bufnr
--                 vim.keymap.set(mode, lhs, rhs, opts)
--             end

--             -- Keymaps
--             buf_map('n', 'K', vim.lsp.buf.hover)
--             buf_map('n', '<leader>rn', vim.lsp.buf.rename)
--             buf_map('n', '<leader>ca', vim.lsp.buf.code_action)

--             -- Format (kommt von ruff/null-ls)
--             buf_map('n', '<leader>f', function()
--                 vim.lsp.buf.format({ async = true })
--             end)
--         end,
--     })

--     -- Null-ls / Ruff Setup
--     local null_ls = require("null-ls")
--     null_ls.setup({
--         sources = {
--             null_ls.builtins.diagnostics.ruff,
--             null_ls.builtins.formatting.ruff,
--         },
--         on_attach = function(client, bufnr)
--             if client.supports_method("textDocument/formatting") then
--                 local group = vim.api.nvim_create_augroup("LspFormatting", { clear = true })
--                 vim.api.nvim_clear_autocmds({ group = group, buffer = bufnr })
--                 vim.api.nvim_create_autocmd("BufWritePre", {
--                     group = group,
--                     buffer = bufnr,
--                     callback = function() vim.lsp.buf.format({ bufnr = bufnr }) end,
--                 })
--             end
--         end,
--     })
-- end

-- return M

local M = {}

M.setup = function(capabilities)
	local lspconfig = require("lspconfig")
	-- local null_ls = require("none-ls")

	capabilities = require("lsp.capabilities").get()

	-- PYRIGHT
	lspconfig.pyright.setup({
		capabilities = capabilities,

		settings = {
			python = {
				analysis = {
					typeCheckingMode = "strict",
					diagnosticMode = "workspace",
					autoSearchPaths = true,
					useLibraryCodeForTypes = true,
					autoImportCompletions = true,

					reportMissingImports = true,
					reportUnusedVariable = true,
					reportUnusedImport = true,
					reportOptionalMemberAccess = true,
					reportOptionalSubscript = true,
					reportGeneralTypeIssues = true,
					reportUnboundVariable = true,
				},
			},
		},

		on_attach = function(client, bufnr)
			client.server_capabilities.documentFormattingProvider = false

			local map = function(mode, lhs, rhs)
				vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, silent = true })
			end

			map("n", "K", vim.lsp.buf.hover)
			map("n", "gd", vim.lsp.buf.definition)
			map("n", "gr", vim.lsp.buf.references)
			map("n", "<leader>rn", vim.lsp.buf.rename)
			map("n", "<leader>ca", vim.lsp.buf.code_action)
			map("n", "[d", vim.diagnostic.goto_prev)
			map("n", "]d", vim.diagnostic.goto_next)
		end,
	})

	-- NONE-LS (MUSS IM FUNKTIONSTEIL SEIN!)
	--   null_ls.setup({
	--     sources = {
	--       null_ls.builtins.diagnostics.ruff,
	--       null_ls.builtins.formatting.black.with({
	--         extra_args = { "--fast" },
	--       }),
	--       null_ls.builtins.diagnostics.bandit,
	--       null_ls.builtins.diagnostics.mypy.with({
	--         extra_args = { "--strict" },
	--       }),
	--     },
	--   })

	-- DIAGNOSTICS UI (Clean & Modern)
	vim.diagnostic.config({
		virtual_text = false,
		signs = true,
		underline = true,
		update_in_insert = false,
		severity_sort = true,
		float = {
			border = "rounded",
			source = "if_many",
		},
	})
end

-- NULL-LS (LINT + FORMAT + SECURITY)
-- null_ls.setup({
--     sources = {
--         -- Ruff (Lint)
--         null_ls.builtins.diagnostics.ruff,

--         -- Formatting (empfohlen stabiler als ruff-format hier)
--         null_ls.builtins.formatting.black.with({
--             extra_args = { "--fast" }
--         }),

--         -- Security
--         null_ls.builtins.diagnostics.bandit,

--         -- Typing ergänzend
--         null_ls.builtins.diagnostics.mypy.with({
--             extra_args = { "--strict" }
--         }),
--     },

--     on_attach = function(client, bufnr)
--         if client.supports_method("textDocument/formatting") then
--             local group = vim.api.nvim_create_augroup("LspFormatting", { clear = true })

--             vim.api.nvim_create_autocmd("BufWritePre", {
--                 group = group,
--                 buffer = bufnr,
--                 callback = function()
--                     vim.lsp.buf.format({
--                         bufnr = bufnr,
--                         timeout_ms = 2000,
--                     })
--                 end,
--             })
--         end
--     end,
-- })

-- Diagnostics UI verbessern
-- vim.diagnostic.config({
--     virtual_text = false, -- cleaner
--     signs = true,
--     underline = true,
--     update_in_insert = false,
--     severity_sort = true,

--     float = {
--         border = "rounded",
--         -- source = "always",
--         source = "if_many",
--     },
-- })

-- end

return M
