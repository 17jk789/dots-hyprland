-- plugins/web-dev.lua

return {
	{
		"neovim/nvim-lspconfig",
		-- ft = { "html", "css", "javascript", "javascriptreact", "typescript", "typescriptreact", "json", "xml", "fxml" },
		ft = { "html", "css", "javascript", "javascriptreact", "typescript", "typescriptreact", "json", "xml" },
		opts = {
			servers = {
				-- Deaktiviere doppelte/standard Server, wir verwenden hier andere Tools
				vtsls = { enabled = false },
				tsserver = { enabled = false },

				html = {},

				cssls = {
					settings = {
						css = {
							lint = {
								vendorPrefix = "ignore", -- Ignoriert die "-fx-" Warnungen
								duplicateProperties = "ignore",
								-- unknownProperties = "ignore", -- Wichtig für JavaFX-spezifische Befehle
							},
						},
					},
				},

				-- XML & FXML Support
				lemminx = {
					-- filetypes = { "xml", "fxml" },
					filetypes = { "xml" },
				},

				eslint = {
					settings = {
						workingDirectory = { mode = "location" },
					},
					-- settings = { workingDirectory = { mode = "auto" } },
				},
			},

			setup = {
				eslint = function()
					-- Fixe ESLint-Fehler bei Save, nur wenn ESLint aktiv ist
					vim.api.nvim_create_autocmd("BufWritePre", {
						callback = function(args)
							for _, client in ipairs(vim.lsp.get_active_clients({ bufnr = args.buf })) do
								if client.name == "eslint" then
									vim.cmd("EslintFixAll")
									return
								end
							end
						end,
					})
				end,
			},
		},

		-- config = function()
		--   local group = vim.api.nvim_create_augroup("eslint_fix", { clear = true })

		--   vim.api.nvim_create_autocmd("BufWritePre", {
		--     group = group,
		--     callback = function(args)
		--       for _, client in ipairs(vim.lsp.get_clients({ bufnr = args.buf })) do
		--         if client.name == "eslint" then
		--           vim.lsp.buf.code_action({
		--             context = { only = { "source.fixAll.eslint" } },
		--             apply = true,
		--           })
		--           return
		--         end
		--       end
		--     end,
		--   })
		-- end,
	},

	{
		"pmizio/typescript-tools.nvim",
		ft = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
		dependencies = {
			"nvim-lua/plenary.nvim",
			"neovim/nvim-lspconfig",
		},
		opts = {
			settings = {
				expose_as_code_action = "all",
				complete_function_calls = true,
			},
		},
	},

	{
		"stevearc/conform.nvim",
		-- ft = { "html", "css", "javascript", "javascriptreact", "typescript", "typescriptreact", "json", "xml", "fxml" },
		ft = { "html", "css", "javascript", "javascriptreact", "typescript", "typescriptreact", "json", "xml" },
		opts = {
			formatters_by_ft = {
				javascript = { "prettier" },
				javascriptreact = { "prettier" },
				typescript = { "prettier" },
				typescriptreact = { "prettier" },
				json = { "prettier" },
				html = { "prettier" },
				css = { "prettier" },
				xml = { "xmlformatter" },
				-- fxml = { "xmlformat" },
			},
			-- optional: automatische Formatierung auf Save
			-- format_on_save = {
			--   timeout_ms = 500,
			--   lsp_format = "fallback",
			-- },
		},
	},

	{
		"windwp/nvim-ts-autotag",
		ft = { "html", "javascriptreact", "typescriptreact" },
		opts = {},
	},

	{
		"mfussenegger/nvim-lint",
		ft = { "html" },
		opts = {
			linters_by_ft = {
				html = { "htmlhint" },
			},
		},
	},
}
