-- plugins/python.lua

-- local function get_python_bin()
--   local python_bin = vim.fn.getcwd() .. "/venv/bin/python"
--   local f = io.open(python_bin, "r")
--   if f then
--     f:close()
--     return python_bin -- gibt String zurück
--   end
--   return nil -- nil signalisiert "nicht vorhanden"
-- end

-- local function get_ruff_bin()
--   local ruff_bin = vim.fn.getcwd() .. "/venv/bin/ruff"
--   local f = io.open(ruff_bin, "r")
--   if f then
--     f:close()
--     return ruff_bin
--   end
--   return nil
-- end

-- return {
--   -- Treesitter für Python
--   {
--     "nvim-treesitter/nvim-treesitter",
--     ft = "python",
--     opts = function(_, opts)
--       vim.list_extend(opts.ensure_installed, { "python" })
--     end,
--   },

--   -- LSP: pylsp
--   {
--     "neovim/nvim-lspconfig",
--     ft = "python",
--     opts = function()
--       local python_bin = get_python_bin()
--       if not python_bin then
--         return nil
--       end

--       local ruff_bin = get_ruff_bin()

--       return {
--         servers = {
--           pylsp = {
--             cmd = { python_bin, "-m", "pylsp" },
--             settings = {
--               pylsp = {
--                 plugins = {
--                   pyflakes = { enabled = true },
--                   pycodestyle = { enabled = true },
--                   flake8 = { enabled = true },
--                   black = { enabled = true },
--                   ruff = { enabled = ruff_bin ~= nil, executable = ruff_bin },
--                 },
--               },
--             },
--           },
--         },
--       }
--     end,
--   },

--   -- Formatter
--   {
--     "stevearc/conform.nvim",
--     ft = "python",
--     opts = {
--       formatters_by_ft = {
--         python = { "black" },
--       },
--     },
--   },

--   -- Ruff Linter Integration
--   {
--     "mfussenegger/nvim-lint",
--     ft = "python",
--     opts = {
--       linters_by_ft = {
--         python = {
--           function()
--             local bufname = vim.api.nvim_buf_get_name(0)
--             local ruff_bin = get_ruff_bin()
--             if bufname == "" or not ruff_bin then
--               return nil  -- nil-safe, kein Linter starten
--             end
--             return {
--               cmd = ruff_bin,
--               args = { "--stdin-filename", bufname, "-" },
--               stdin = true,
--             }
--           end,
--         },
--       },
--     },
--   },
-- }

-- local function get_python_bin()
--   local venv = vim.fn.getcwd() .. "/venv/bin/python"
--   if vim.fn.executable(venv) == 1 then
--     return venv
--   end
--   return vim.fn.exepath("python3") or "python"
-- end

-- return {
--   {
--     "nvim-treesitter/nvim-treesitter",
--     ft = "python",
--     opts = function(_, opts)
--       opts.ensure_installed = opts.ensure_installed or {}
--       vim.list_extend(opts.ensure_installed, { "python" })
--     end,
--   },

--   {
--     "neovim/nvim-lspconfig",
--     ft = "python",
--     opts = function()
--       return {
--         servers = {
--           pyright = {
--             settings = {
--               python = {
--                 pythonPath = get_python_bin(),
--               },
--             },
--             -- on_attach ohne Inlay-Hints
--             on_attach = function(_, _)
--               -- nichts hier
--             end,
--           },
--         },
--       }
--     end,
--   },

--   {
--     "stevearc/conform.nvim",
--     ft = "python",
--     opts = {
--       formatters_by_ft = {
--         python = { "black" },
--       },
--     },
--   },

--   {
--     "mfussenegger/nvim-lint",
--     ft = "python",
--     opts = {
--       linters_by_ft = {
--         python = { "ruff" },
--       },
--     },
--   },
-- }

-- return {
-- Ruff + Black (stabil via none-ls)
-- {
--   "nvimtools/none-ls.nvim",
--   ft = "python",
--   opts = function(_, opts)
--     local nls = require("null-ls")
--     opts.sources = opts.sources or {}

--     vim.list_extend(opts.sources, {
--       nls.builtins.formatting.black,
--       nls.builtins.diagnostics.ruff,
--     })
--   end,
-- },

-- Conform für Formatter (Black + isort)
-- {
--     "stevearc/conform.nvim",
--     lazy = false,  -- direkt laden
--     config = function()
--         require("conform").setup({
--             formatters_by_ft = {
--                 python = { "isort", "black" },  -- Reihenfolge: isort → black
--             },
--             format_on_save = {
--                 timeout_ms = 500,
--                 lsp_format = "fallback",
--             },
--         })
--     end,
-- },

-- -- Null-ls für Linter (Ruff)
-- {
--     "jose-elias-alvarez/null-ls.nvim",
--     ft = "python",
--     dependencies = { "nvim-lua/plenary.nvim" },
--     opts = function(_, opts)
--         local nls = require("null-ls")
--         opts.sources = opts.sources or {}
--         vim.list_extend(opts.sources, {
--             nls.builtins.diagnostics.ruff,  -- Ruff als Linter
--         })
--     end,
-- },

-- Image Support (Ghostty kompatibel via Kitty Protocol)
-- {
--   "3rd/image.nvim",
--   ft = "python",
--   opts = {
--     backend = "kitty",
--     max_width = 100,
--     max_height = 20,
--   },
-- },

-- Molten (Jupyter Core)
-- {
--   "benlubas/molten-nvim",
--   version = "^1.0.0",
--   build = ":UpdateRemotePlugins",
--   ft = { "python", "ipynb" },
--   init = function()
--     -- stabile Defaults
--     vim.g.molten_auto_open_output = false
--     vim.g.molten_image_provider = "image.nvim"
--     vim.g.molten_output_win_max_height = 25
--     vim.g.molten_wrap_output = true
--     vim.g.molten_virt_text_output = false
--   end,

--   config = function()

--     -- Sichere Kernel-Initialisierung
--     local function ensure_kernel()
--       if not vim.b.molten_initialized then
--         vim.cmd("MoltenInit")
--         vim.b.molten_initialized = true
--       end
--     end

--     -- Notebook-Zellen via "# %%"
--     vim.api.nvim_create_autocmd("FileType", {
--       -- pattern = "python",
--       pattern = { "python", "ipynb" },
--       callback = function()
--         vim.bo.commentstring = "# %s"
--       end,
--     })

--     -- vim.api.nvim_create_autocmd("FileType", {
--     --   pattern = { "python", "ipynb" },
--     --   callback = function()
--     --     if not vim.b.molten_initialized then
--     --       vim.cmd("MoltenInit")
--     --       vim.b.molten_initialized = true
--     --     end
--     --   end,
--     -- })

--     -- Kernel manuell starten
--     vim.keymap.set("n", "<leader>mi", ensure_kernel, { desc = "Init Jupyter Kernel" })

--     -- aktuelle Zeile
--     vim.keymap.set("n", "<leader>rr", function()
--       ensure_kernel()
--       vim.cmd("MoltenEvaluateLine")
--     end, { desc = "Run Line" })

--     -- visuelle Auswahl
--     vim.keymap.set("v", "<leader>rr", function()
--       ensure_kernel()
--       vim.cmd("MoltenEvaluateVisual")
--     end, { desc = "Run Selection" })

--     -- gesamte Datei
--     vim.keymap.set("n", "<leader>rf", function()
--       ensure_kernel()
--       vim.cmd("normal! ggVG")
--       vim.cmd("MoltenEvaluateVisual")
--     end, { desc = "Run File" })

--     -- nächste Zelle (# %%)
--     vim.keymap.set("n", "<leader>rc", function()
--       ensure_kernel()
--       vim.cmd("MoltenEvaluateOperator")
--     end, { desc = "Run Cell" })

--     -- Output Toggle
--     vim.keymap.set("n", "<leader>ro", ":MoltenShowOutput<CR>", { desc = "Show Output" })
--     vim.keymap.set("n", "<leader>rh", ":MoltenHideOutput<CR>", { desc = "Hide Output" })
--   end,
-- },
-- }

--pip install pynvim jupyter-client ipykernel black ruff
-- Optional:
-- python -m ipykernel install --user

return {
	-- 1. Molten Konfiguration
	{
		"benlubas/molten-nvim",
		ft = { "markdown", "python" },
		version = "^1.0.0",
		build = ":UpdateRemotePlugins",
		init = function()
			-- WICHTIG: Erlaubt Molten, Markdown-Inhalte im Output-Fenster zu rendern
			vim.g.molten_auto_open_output = true
			vim.g.molten_output_win_max_height = 30
			vim.g.molten_virt_text_output = true
			-- vim.g.molten_virt_text_output = false
			vim.g.molten_use_border_highlights = true
			vim.g.molten_virt_lines_off_by_1 = true

			-- Bilder & Stil
			vim.g.molten_image_provider = "image.nvim"
			vim.g.molten_output_win_style = "minimal"

			-- Optional: Wenn du oft mit DataFrames arbeitest, hilft dieses Plugin:
			-- Es sorgt dafür, dass HTML/Markdown Tabellen sauberer aussehen.
		end,
	},

	-- 2. Image.nvim (Optimiert für Ghostty/Kitty)
	-- {
	--   "3rd/image.nvim",
	--   opts = {
	--     backend = "kitty",
	--     max_width = 150,
	--     max_height = 30,
	--     max_height_window_percentage = math.huge,
	--     max_width_window_percentage = math.huge,
	--     window_overlap_clear_enabled = true,
	--     editor_only_render_when_focused = true,
	--     tmux_show_boundary = false,
	--     -- Aktiviert die Integration für Markdown-Dateien selbst
	--     integrations = {
	--       markdown = {
	--         enabled = true,
	--         clear_in_insert_mode = false,
	--         download_remote_images = true,
	--         only_render_image_at_cursor = false,
	--         filetypes = { "markdown", "vimwiki", "quarto" }, -- Quarto für Notebook-Feeling
	--       },
	--     },
	--   },
	-- },

	{
		"3rd/image.nvim",
		cond = function()
			local term = os.getenv("TERM") or ""
			local term_program = os.getenv("TERM_PROGRAM") or ""
			local kitty_protocol = os.getenv("KITTY_WINDOW_ID") -- Kitty setzt diese Variable

			-- Prüft auf echte Kitty-Umgebung oder Ghostty
			if kitty_protocol and kitty_protocol ~= "" then
				return true
			elseif term:find("kitty") or term:find("ghostty") then
				return true
			end

			return false
		end,
		opts = {
			backend = "kitty",
			max_width = 100,
			max_height = 20,
			max_width_window_percentage = math.huge,
			max_height_window_percentage = math.huge,
			window_overlap_clear_enabled = true,
			editor_only_render_when_focused = true,
			tmux_show_boundary = false,
			integrations = {
				markdown = {
					enabled = true,
					clear_in_insert_mode = false,
					download_remote_images = true,
					only_render_image_at_cursor = false,
					filetypes = { "markdown", "vimwiki", "quarto", "latex", "tex" },
				},
			},
		},
	},

	-- 3. EMPFEHLUNG: Render-Markdown für schöneres UI
	-- Dies verbessert das Aussehen von Markdown-Blöcken im Editor enorm.
	{
		"MeanderingProgrammer/render-markdown.nvim",
		ft = { "markdown" },
		dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-mini/mini.nvim" }, -- if you use the mini.nvim suite
		-- dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-mini/mini.icons' },        -- if you use standalone mini plugins
		-- dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' }, -- if you prefer nvim-web-devicons
		opts = {
			-- file_types = { "markdown", "quarto", "python" },
			file_types = { "markdown", "quarto" },

			code = {
				style = "full",
				left_pad = 2,
				right_pad = 4,
				border = "thin",
				highlight = "RenderMarkdownCode", -- Nutzt Theme-Farben für Hintergründe
			},

			-- extra_border = {
			--   enabled = true,
			-- },
		},
	},

	{
		"GCBallesteros/jupytext.nvim",
		lazy = false,
		ft = { "python", "markdown" },
		opts = {
			-- Hier erzwingen wir das Markdown-Verhalten für Python-Notebooks
			custom_language_formatting = {
				python = {
					extension = "md",
					style = "markdown",
					force_ft = "markdown", -- WICHTIG: Damit vi` funktioniert
					-- force_ft = nil,
					converter = "pylatexenc", -- Oder "mmarkdown" / "none"
				},
			},
		},
		config = function(_, opts)
			require("jupytext").setup(opts)
		end,
	},

	-- {
	--   "jmbuhr/otter.nvim",
	--   ft = { "markdown" },
	--   dependencies = { "neovim/nvim-lspconfig" },
	--   config = function()
	--     local group = vim.api.nvim_create_augroup("OtterSetup", { clear = true })

	--     -- Filter für E303 (Too many blank lines)
	--     -- local original_handler = vim.lsp.handlers["textDocument/publishDiagnostics"]
	--     -- vim.lsp.handlers["textDocument/publishDiagnostics"] = function(err, result, ctx, config)
	--     --   local filtered = {}
	--     --   if result and result.diagnostics then
	--     --     for _, d in ipairs(result.diagnostics) do
	--     --       -- Ignoriert E303 und die Nachricht "too many blank lines"
	--     --       if not (d.code == "E303" or d.message:lower():find("too many blank lines")) then
	--     --         table.insert(filtered, d)
	--     --       end
	--     --     end
	--     --     result.diagnostics = filtered
	--     --   end
	--     --   original_handler(err, result, ctx, config)
	--     -- end

	--     -- local original_handler = vim.lsp.handlers["textDocument/publishDiagnostics"]
	--     -- vim.lsp.handlers["textDocument/publishDiagnostics"] = function(err, result, ctx, config)
	--     --   local filtered = {}
	--     --   if result and result.diagnostics then
	--     --     for _, d in ipairs(result.diagnostics) do
	--     --       -- Wir prüfen, ob die Quelle 'pycodestyle' ist (Groß/Kleinschreibung egal)
	--     --       local source = d.source or ""
	--     --       if not source:lower():find("pycodestyle") then
	--     --         table.insert(filtered, d)
	--     --       end
	--     --     end
	--     --     result.diagnostics = filtered
	--     --   end
	--     --   original_handler(err, result, ctx, config)
	--     -- end

	--     -- local function filter_diagnostics(diagnostics)
	--     --   local filtered = {}

	--     --   for _, d in ipairs(diagnostics) do
	--     --     local source = d.source or ""

	--     --     if not source:lower():find("pycodestyle") then
	--     --       table.insert(filtered, d)
	--     --     end
	--     --   end

	--     --   return filtered
	--     -- end

	--     -- if not vim.g._otter_diagnostic_filter then
	--     --   vim.g._otter_diagnostic_filter = true

	--     --   local original = vim.lsp.handlers["textDocument/publishDiagnostics"]

	--     --   vim.lsp.handlers["textDocument/publishDiagnostics"] = function(err, result, ctx, config)
	--     --     if result and result.diagnostics then
	--     --       local client = vim.lsp.get_client_by_id(ctx.client_id)

	--     --       if client and client.name == "otter-ls" then
	--     --         local filtered = {}

	--     --         for _, d in ipairs(result.diagnostics) do
	--     --           local source = d.source or ""

	--     --           if not source:lower():find("pycodestyle") then
	--     --             table.insert(filtered, d)
	--     --           end
	--     --         end

	--     --         result.diagnostics = filtered
	--     --       end
	--     --     end

	--     --     return original(err, result, ctx, config)
	--     --   end
	--     -- end

	--     local original = vim.lsp.handlers["textDocument/publishDiagnostics"]

	--     vim.lsp.handlers["textDocument/publishDiagnostics"] = function(err, result, ctx, config)
	--       if result and result.diagnostics then
	--         local client = vim.lsp.get_client_by_id(ctx.client_id)

	--         if client and (client.name == "pyright" or client.name == "ruff_lsp") then
	--           local filtered = {}

	--           for _, d in ipairs(result.diagnostics) do
	--             local source = d.source or ""

	--             -- Beispiel: pycodestyle ignorieren
	--             if not source:lower():find("pycodestyle") then
	--               table.insert(filtered, d)
	--             end
	--           end

	--           result.diagnostics = filtered
	--         end
	--       end

	--       return original(err, result, ctx, config)
	--     end

	--     vim.api.nvim_create_autocmd("FileType", {
	--       pattern = "markdown",
	--       group = group,
	--       callback = function()
	--         -- require("otter").activate({"python"})
	--         if not vim.b.otter_activated then
	--           require("otter").activate({ "python" })
	--           vim.b.otter_activated = true
	--         end
	--       end,
	--     })
	--   end,
	-- }

	{
		"jmbuhr/otter.nvim",
		ft = { "markdown" },
		dependencies = { "neovim/nvim-lspconfig" },

		config = function()
			local group = vim.api.nvim_create_augroup("OtterSetup", { clear = true })

			-- Sichere Otter Activation
			local function activate_otter()
				if vim.b.otter_activated then
					return
				end

				-- Nur wenn Python Codeblock existiert
				if vim.fn.search("```python", "nw") == 0 then
					return
				end

				local ok, otter = pcall(require, "otter")
				if not ok then
					return
				end

				-- zusätzlicher Schutz (verhindert seltene doppelte Aktivierung)
				vim.schedule(function()
					otter.activate({ "python" })
					vim.b.otter_activated = true
				end)
			end

			-- Markdown öffnen
			vim.api.nvim_create_autocmd("FileType", {
				pattern = "markdown",
				group = group,
				callback = activate_otter,
			})

			-- Bei Buffer Wechsel (z.B. nach Reload)
			vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
				pattern = "*.md",
				group = group,
				callback = activate_otter,
			})

			-- Otter Buffers verstecken
			vim.api.nvim_create_autocmd("BufReadPost", {
				pattern = "*.otter.py",
				callback = function()
					vim.bo.buflisted = false
					vim.bo.bufhidden = "hide"
				end,
			})
		end,
	},
}
