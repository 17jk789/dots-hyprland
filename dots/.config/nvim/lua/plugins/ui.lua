-- plugins/ui.lua

return {
	{
		-- cmd = "Telescope", -- lädt erst bei Telescope-Befehl
		"nvim-telescope/telescope.nvim",
		cmd = "Telescope",
		dependencies = {
			"nvim-lua/plenary.nvim",
		},
	},

	{
		"folke/trouble.nvim",
		-- cmd = { "TroubleToggle", "Trouble" }, -- nur wenn du Trouble-Befehl benutzt
		cmd = { "Trouble", "TroubleToggle" },
		opts = {},
	},

	{
		"nvim-tree/nvim-tree.lua",
		-- cmd = { "NvimTreeToggle", "NvimTreeFindFile" }, -- nur bei diesen Befehlen laden
		cmd = { "NvimTreeToggle", "NvimTreeFindFile", "NvimTreeFocus" },
		opts = {
			view = { width = 30 },
			renderer = { group_empty = true },
		},
	},

	{
		"numToStr/Comment.nvim",
		keys = {
			{ "gcc", mode = "n" },
			{ "gc", mode = "v" },
		},
		opts = {},
	},

	-- wird schon in plugins/git.lua geladen
	-- {
	--   "tpope/vim-fugitive",
	--   cmd = { "Git", "G" },
	-- },

	{
		"akinsho/bufferline.nvim",
		version = "v5.0.0",
		-- Aktualisiertes Repository
		event = "VeryLazy",
		dependencies = { "nvim-mini/mini.icons" },
		opts = {
			options = {
				-- Nutze mini.icons für die Darstellung
				get_element_icon = function(opts)
					local icon, hl = require("mini.icons").get("file", opts.path)
					return icon, hl
				end,
				diagnostics = "nvim_lsp",
				diagnostics_update_in_insert = false,
				show_buffer_close_icons = true,
				show_close_icon = false,
			},
		},
	},

	{
		"nvim-mini/mini.nvim",
		version = false,
		event = "VeryLazy",
		config = function()
			local hipatterns = require("mini.hipatterns")

			-- local function rgb_group(_, match)
			--   local r, g, b = match:match("rgb%((%d+),%s*(%d+),%s*(%d+)%)")
			--   if not r then return end

			--   local hex = string.format(
			--     "#%02x%02x%02x",
			--     tonumber(r),
			--     tonumber(g),
			--     tonumber(b)
			--   )

			--   return hipatterns.compute_hex_color_group(hex, "bg")
			-- end

			hipatterns.setup({
				highlighters = {
					hex_color = hipatterns.gen_highlighter.hex_color(),

					-- rgb_color = {
					--   pattern = "rgb%(%d+,%s*%d+,%s*%d+%)",
					--   group = rgb_group,
					-- },
				},
			})
		end,
	},

	-- {
	-- "folke/snacks.nvim",
	--   opts = {
	--     terminal = {
	--       enabled = true,  -- Snacks Terminal aktivieren
	--     },
	--     image = {
	--       enabled = true,
	--       -- markdown = {
	--       --   mermaid = false,
	--       -- },
	--     },
	--   },
	--   keys = {
	--     {
	--       "<leader>tt",
	--       function() require("snacks").terminal() end, -- Terminal aufrufen
	--       desc = "Terminal",
	--     },
	--   },
	-- },

	{
		"folke/snacks.nvim",
		opts = {
			terminal = {
				enabled = true,
			},
			-- image = {
			--   -- Aktiviert Bilder, wenn wir in Kitty-Terminal sind
			--   enabled = (function()
			--     local term = os.getenv("TERM") or ""
			--     local term_program = os.getenv("TERM_PROGRAM") or ""
			--     local kitty_window = os.getenv("KITTY_WINDOW_ID") or ""

			--     -- Bilder aktivieren, wenn:
			--     -- 1. TERM enthält "kitty"
			--     -- 2. oder KITTY_WINDOW_ID gesetzt ist (echtes Kitty)
			--     -- 3. oder TERM_PROGRAM Ghostty ist (optional)
			--     return term:find("kitty") ~= nil or kitty_window ~= "" or term_program == "Ghostty"
			--   end)(),
			-- },
		},
		keys = {
			{
				"<leader>tt",
				function()
					require("snacks").terminal()
				end,
				desc = "Terminal",
			},
		},
	},

	-- Mason UI umranden
	{
		"mason-org/mason.nvim",
		opts = {
			ui = {
				border = "rounded", -- macht Mason schick
			},
		},
	},

	-- Optional: Which-Key (die Tasten-Vorschau) ebenfalls umranden
	-- {
	--   "folke/which-key.nvim",
	--   opts = {
	--     win = { border = "rounded" },
	--   },
	-- },
}
