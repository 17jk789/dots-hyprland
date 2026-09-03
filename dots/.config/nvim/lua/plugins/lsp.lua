-- plugins/lsp.lua

-- return {
--   {
--     "neovim/nvim-lspconfig",
--     dependencies = {
--       "mason-org/mason.nvim",
--       "mason-org/mason-lspconfig.nvim",
--     },
--     opts = {
--       servers = {
--         rust_analyzer = {
--           settings = {
--             ["rust-analyzer"] = {
--               cargo = { allFeatures = true },
--               checkOnSave = { command = "clippy" }, -- slow
--               -- checkOnSave = { command = "check" } -- faster
--               inlayHints = {
--                 enable = true,
--                 typeHints = true,
--                 parameterHints = true,
--                 lifetimeElisionHints = "always",
--               },
--             },
--           },
--         },
--         clangd = {
--           cmd = {
--             "clangd",
--             "--background-index",
--             "--clang-tidy",
--             "--completion-style=detailed",
--             "--header-insertion=never",
--           },
--         },
--       },
--     },
--   },
-- }

-- return {
--   {
--     "neovim/nvim-lspconfig",
--     dependencies = {
--       "mason-org/mason.nvim",
--       "mason-org/mason-lspconfig.nvim",
--     },
--     opts = {
--       servers = {
--         clangd = {
--           cmd = {
--             "clangd",
--             "--background-index",
--             "--clang-tidy",
--             "--completion-style=detailed",
--             "--header-insertion=never",
--           },
--         },
--       },
--     },
--   },
-- }

return {
	{
		"neovim/nvim-lspconfig",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			"mason-org/mason.nvim",
			"mason-org/mason-lspconfig.nvim",
		},
		opts = {
			servers = {
				clangd = {
					cmd = {
						"clangd",
						"--background-index",
						"--clang-tidy",
						"--completion-style=detailed",
						"--function-arg-placeholders",
						"--header-insertion=iwyu",
						"--suggest-missing-includes",
						"--cross-file-rename",
						"--all-scopes-completion",
						"--pch-storage=memory",
						"--ranking-model=decision_forest",
						"--inlay-hints",
						"--fallback-style=llvm",
						"--offset-encoding=utf-16",
						"--log=error",
					},

					init_options = {
						clangdFileStatus = true,
						usePlaceholders = true,
						completeUnimported = true,
						semanticHighlighting = true,
					},
				},

				rust_analyzer = {
					enabled = false,
				},
				-- rust_analyzer = {
				--   settings = {
				--     ["rust-analyzer"] = {
				--       diagnostics = {
				--         disabled = {
				--           "unresolved-proc-macro",
				--           "unlinked-file",
				--         },
				--       },

				--       formatting = {
				--         useCrate = true,  -- verwendet rustfmt
				--       },

				--       cargo = {
				--         allFeatures = true,
				--         buildScripts = { enable = true },
				--       },

				--       procMacro = { enable = true },
				--       lens = { enable = true },

				--       completion = {
				--         autoimport = { enable = true },
				--       },

				--       checkOnSave = {
				--         command = "clippy",  -- Linter: Findet Stilfehler und logische Patzer (sehr gründlich)
				--         -- command = "check", -- Standard: Prüft nur, ob der Code kompiliert (schnellste Option)
				--         -- command = "test", -- Tests: Validiert auch den Code innerhalb deiner Test-Module
				--         -- command = "build", -- Kompilieren: Erstellt das komplette Binary (langsam, meist unnötig für LSP)
				--       },

				--       inlayHints = {
				--         enable = true,
				--         typeHints = true,
				--         parameterHints = true,
				--         lifetimeElisionHints = "always",
				--         closureReturnTypeHints = { enable = "always" },
				--         bindingModeHints = { enable = true },
				--       },

				--       files = {
				--         watcher = "client",
				--       },
				--     },
				--   },
				-- },
			},
		},
	},
}

-- return {
--   {
--     "neovim/nvim-lspconfig",
--     dependencies = {
--       "mason-org/mason.nvim",
--       "mason-org/mason-lspconfig.nvim",
--     },
--     opts = {
--       servers = {
--         clangd = {
--           cmd = {
--             "clangd",
--             "--background-index",
--             "--clang-tidy",
--             "--completion-style=detailed",
--             "--header-insertion=never",
--           },
--         },

--         rust_analyzer = {
--           settings = {
--             ["rust-analyzer"] = {
--               diagnostics = {
--                 disabled = {
--                   "unresolved-proc-macro",
--                   "unlinked-file",
--                 },
--               },

--               cargo = {
--                 allFeatures = true,
--                 buildScripts = { enable = true },
--               },

--               procMacro = { enable = true },
--               lens = { enable = true },

--               completion = {
--                 autoimport = { enable = true },
--               },

--               checkOnSave = {
--                 command = "clippy",
--               },

--               inlayHints = {
--                 enable = true,
--                 typeHints = true,
--                 parameterHints = true,
--                 lifetimeElisionHints = "always",
--                 closureReturnTypeHints = { enable = "always" },
--                 bindingModeHints = { enable = true },
--               },

--               files = {
--                 watcher = "client",
--               },
--             },
--           },
--         },

--         local jdtls = require('jdtls')

--         jdtls.start_or_attach({
--           cmd = {'jdtls'},  -- Pfad zu jdtls, evtl. '/usr/local/bin/jdtls'
--           root_dir = require('jdtls.setup').find_root({'.git', 'pom.xml', 'build.gradle'}),
--           settings = {
--             java = {
--               signatureHelp = { enabled = true },
--               contentProvider = { preferred = 'fernflower' }
--             }
--           }
--         })
--       },
--     },
--   },
-- }

-- return {
--   {
--     "neovim/nvim-lspconfig",
--     dependencies = {
--       "mason-org/mason.nvim",
--       "mason-org/mason-lspconfig.nvim",
--     },
--     opts = {
--       servers = {
--         -- C/C++ LSP
--         clangd = {
--           cmd = {
--             "clangd",
--             "--background-index",
--             "--clang-tidy",
--             "--completion-style=detailed",
--             "--header-insertion=never",
--           },
--         },

--         -- Rust LSP
--         rust_analyzer = {
--           settings = {
--             ["rust-analyzer"] = {
--               diagnostics = { disabled = { "unresolved-proc-macro", "unlinked-file" } },
--               cargo = { allFeatures = true, buildScripts = { enable = true } },
--               procMacro = { enable = true },
--               lens = { enable = true },
--               completion = { autoimport = { enable = true } },
--               checkOnSave = { command = "clippy" },
--               inlayHints = {
--                 enable = true,
--                 typeHints = true,
--                 parameterHints = true,
--                 lifetimeElisionHints = "always",
--                 closureReturnTypeHints = { enable = "always" },
--                 bindingModeHints = { enable = true },
--               },
--               files = { watcher = "client" },
--             },
--           },
--         },
--       },
--     },
--   },
-- }

-- return {
--   {
--     "neovim/nvim-lspconfig",
--     dependencies = {
--       "mason-org/mason.nvim",
--       "mason-org/mason-lspconfig.nvim",
--     },
--     opts = {
--       servers = {
--         rust_analyzer = {
--           settings = {
--             ["rust-analyzer"] = {
--               cargo = { allFeatures = true },
--               checkOnSave = { command = "check" },
--               inlayHints = {
--                 enable = true,
--                 typeHints = true,
--                 parameterHints = true,
--                 lifetimeElisionHints = "always",
--               },
--             },
--           },
--         },
--         clangd = {
--           cmd = {
--             "clangd",
--             "--background-index",
--             "--clang-tidy",
--             "--completion-style=detailed",
--             "--header-insertion=never",
--           },
--         },
--       },
--     },
--   },
-- }

-- return {
--   {
--    "neovim/nvim-lspconfig",
--    dependencies = {
--      "mason-org/mason.nvim",
--      "mason-org/mason-lspconfig.nvim",
--     },
--     opts = {
--       servers = {
--         rust_analyzer = {
--           root_dir = function(fname)
--             return require("lspconfig.util")
--               .root_pattern("Cargo.toml", ".git")(fname)
--               or vim.fn.getcwd()
--           end,
--
--           -- on_attach sorgt dafür, dass Shortcuts nur in Rust aktiviert sind
--           on_attach = function(_, bufnr)
--             local map = vim.keymap.set
--             local opts = { noremap = true, silent = true, buffer = bufnr }
--
--             -- Cargo Shortcuts
--             map("n", "<leader>rr", function()
--               vim.cmd("split | terminal cargo run")
--             end, opts)
--
--             map("n", "<leader>rd", function()
--               vim.cmd("split | terminal cargo debug")
--             end, opts)
--
--             map("n", "<leader>rb", function()
--               vim.cmd("split | terminal cargo build")
--             end, opts)
--
--             map("n", "<leader>rt", function()
--               vim.cmd("split | terminal cargo test")
--             end, opts)
--
--             map("n", "<leader>rc", function()
--               vim.cmd("edit Cargo.toml")
--             end, opts)
--
--             -- LSP Commands
--             map("n", "<leader>rh", function()
--               vim.lsp.buf.hover()
--             end, opts)
--
--             map("n", "<leader>re", function()
--               vim.lsp.buf.execute_command({
--                 command = "rust-analyzer.expandMacro",
--                 arguments = { vim.uri_from_bufnr(bufnr) },
--               })
--             end, opts)
--
--             map("n", "<leader>rf", function()
--               vim.lsp.buf.format({ async = true })
--             end, opts)
--           end,
--
--           settings = {
--             ["rust-analyzer"] = {
--               cargo = { allFeatures = true },
--               checkOnSave = { command = "clippy" },
--               inlayHints = {
--                 enable = true,
--                 typeHints = true,
--                 parameterHints = true,
--                 lifetimeElisionHints = "always",
--               },
--             },
--           },
--         },
--
--         clangd = {
--           cmd = {
--             "clangd",
--             "--background-index",
--             "--clang-tidy",
--             "--completion-style=detailed",
--             "--header-insertion=never",
--           },
--         },
--       },
--     },
--   },
-- }
