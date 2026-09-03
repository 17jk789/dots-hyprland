-- lsp/lua.lua

-- local M = {}

-- M.setup = function(capabilities, no_diagnostics)
--     local lspconfig = require("lspconfig")

--     -- bessere Completion-Capabilities
--     capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)

--     lspconfig.lua_ls.setup({
--         capabilities = capabilities,
--         handlers = no_diagnostics,

--         settings = {
--             Lua = {
--                 runtime = {
--                     -- LuaJIT für NeoVim
--                     version = "LuaJIT",
--                     path = vim.split(package.path, ";"),
--                 },
--                 diagnostics = {
--                     globals = { "vim" },  -- NeoVim globale Variablen
--                 },
--                 workspace = {
--                     library = {
--                         [vim.fn.expand("$VIMRUNTIME/lua")] = true,
--                         [vim.fn.stdpath("config") .. "/lua"] = true,
--                     },
--                     checkThirdParty = false,
--                 },
--                 telemetry = {
--                     enable = false,
--                 },
--                 format = {
--                     enable = true,
--                 },
--             },
--         },

--         on_attach = function(client, bufnr)
--             -- Diagnostics optional deaktivieren
--             client.server_capabilities.diagnosticProvider = false
--             client.server_capabilities.documentFormattingProvider = true

--             local buf_map = function(mode, lhs, rhs, opts)
--                 opts = opts or {}
--                 opts.buffer = bufnr
--                 vim.keymap.set(mode, lhs, rhs, opts)
--             end

--             -- LSP Keymaps
--             -- buf_map("n", "gd", vim.lsp.buf.definition) -- Diese Tastenkombination ist bereits in plugins/keymaps definiert.
--             buf_map("n", "K", vim.lsp.buf.hover)
--             buf_map("n", "<leader>rn", vim.lsp.buf.rename)
--             -- buf_map("n", "<leader>ca", vim.lsp.buf.code_action) -- Diese Tastenkombination ist bereits in plugins/keymaps definiert.
--             buf_map("n", "<leader>f", function()
--                 vim.lsp.buf.format({ async = true })
--             end)
--         end,
--     })
-- end

-- return M

local M = {}

M.setup = function(capabilities)
	local lspconfig = require("lspconfig")

	capabilities = require("lsp.capabilities").get()

	lspconfig.lua_ls.setup({
		capabilities = capabilities,

		settings = {
			Lua = {
				runtime = {
					version = "LuaJIT",
				},

				diagnostics = {
					globals = { "vim" },
				},

				workspace = {
					library = vim.api.nvim_get_runtime_file("", true),
					checkThirdParty = false,
				},

				telemetry = {
					enable = false,
				},

				completion = {
					callSnippet = "Replace",
				},
			},
		},

		on_attach = function(client, bufnr)
			-- safer than hard disabling capabilities
			client.server_capabilities.semanticTokensProvider = nil

			local map = function(mode, lhs, rhs)
				vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, silent = true })
			end

			map("n", "K", vim.lsp.buf.hover)
			map("n", "<leader>rn", vim.lsp.buf.rename)
			map("n", "<leader>f", function()
				vim.lsp.buf.format({ async = true })
			end)
		end,
	})
end

return M
