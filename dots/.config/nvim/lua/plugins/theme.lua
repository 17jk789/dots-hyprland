-- plugins/theme.lua

-- GitHub Theme

-- return {
--   {
--     "projekt0n/github-nvim-theme",
--     name = "github-theme",
--     lazy = false,
--     priority = 1000,
--     config = function()
--       require("github-theme").setup({})
--       vim.cmd("colorscheme github_dark_dimmed")
--     end
--   },
-- }

-- return {
--   {
--     "projekt0n/github-nvim-theme",
--     name = "github-theme",
--     lazy = false,
--     priority = 1000,
--     config = function()
--       require("github-theme").setup({
--         options = {
--           transparent = true,
--         },
--       })

--       -- Hier einfach die Variante ändern:
--       -- github_dark, github_dark_dimmed, github_dark_default
--       -- github_light, github_light_high_contrast, github_light_default
--       vim.cmd("colorscheme github_dark_dimmed")

--       -- local groups = {
--       --   "Normal",
--       --   "NormalNC",
--       --   "NormalFloat",
--       --   "FloatBorder",
--       --   "SignColumn",
--       --   "EndOfBuffer",
--       --   "LineNr",
--       --   "CursorLineNr",
--       --   "VertSplit",
--       --   "WinSeparator",
--       -- }

--       local groups = {
--         "Normal",
--         "NormalNC",
--         "NormalFloat",
--         "FloatBorder",
--         "SignColumn",
--         "EndOfBuffer",
--         "LineNr",
--         "CursorLineNr",
--         "VertSplit",
--         "WinSeparator",
--         "TabLine",
--         "TabLineSel",
--         "TabLineFill",
--         "StatusLine",
--         "StatusLineNC",
--         "WinBar",
--         "WinBarNC",
--       }

--       for _, group in ipairs(groups) do
--         vim.api.nvim_set_hl(0, group, { bg = "none" })
--       end
--     end,
--   },
-- }

-- Nightfox

-- return {
--   {
--     "EdenEast/nightfox.nvim",
--     name = "nightfox",
--     lazy = false,
--     priority = 1000,
--     config = function()
--       require("nightfox").setup({
--         options = {
--           transparent = false,
--           terminal_colors = true,
--         },
--       })
--       vim.cmd("colorscheme carbonfox")
--     end
--   },
-- }

-- return {
--   {
--     "EdenEast/nightfox.nvim",
--     name = "nightfox",
--     lazy = false,
--     priority = 1000,
--     config = function()
--       require("nightfox").setup({
--         options = {
--           transparent = true,
--           terminal_colors = true,
--         },
--       })

--       -- Hier einfach die Variante ändern: carbonfox, duskfox, nordfox, terafox, dayfox
--       vim.cmd("colorscheme carbonfox")

--       -- local groups = {
--       --   "Normal",
--       --   "NormalNC",
--       --   "NormalFloat",
--       --   "FloatBorder",
--       --   "SignColumn",
--       --   "EndOfBuffer",
--       --   "LineNr",
--       --   "CursorLineNr",
--       --   "VertSplit",
--       --   "WinSeparator",
--       -- }

--       local groups = {
--         "Normal",
--         "NormalNC",
--         "NormalFloat",
--         "FloatBorder",
--         "SignColumn",
--         "EndOfBuffer",
--         "LineNr",
--         "CursorLineNr",
--         "VertSplit",
--         "WinSeparator",
--         "TabLine",
--         "TabLineSel",
--         "TabLineFill",
--         "StatusLine",
--         "StatusLineNC",
--         "WinBar",
--         "WinBarNC",
--       }

--       for _, group in ipairs(groups) do
--         vim.api.nvim_set_hl(0, group, { bg = "none" })
--       end
--     end,
--   },
-- }

-- Tokyo Night

-- return {
--   {
--     "folke/tokyonight.nvim",
--     name = "tokyonight",
--     lazy = false,
--     priority = 1000,
--     config = function()
--       require("tokyonight").setup({
--         style = "night", -- storm / moon / night / day möglich
--         transparent = true,
--         terminal_colors = true,
--       })

--       vim.cmd("colorscheme tokyonight")

--       -- local groups = {
--       --   "Normal",
--       --   "NormalNC",
--       --   "NormalFloat",
--       --   "FloatBorder",
--       --   "SignColumn",
--       --   "EndOfBuffer",
--       --   "LineNr",
--       --   "CursorLineNr",
--       --   "VertSplit",
--       --   "WinSeparator",
--       -- }

--       local groups = {
--         "Normal",
--         "NormalNC",
--         "NormalFloat",
--         "FloatBorder",
--         "SignColumn",
--         "EndOfBuffer",
--         "LineNr",
--         "CursorLineNr",
--         "VertSplit",
--         "WinSeparator",
--         "TabLine",
--         "TabLineSel",
--         "TabLineFill",
--         "StatusLine",
--         "StatusLineNC",
--         "WinBar",
--         "WinBarNC",
--       }

--       for _, group in ipairs(groups) do
--         vim.api.nvim_set_hl(0, group, { bg = "none" })
--       end
--     end,
--   },
-- }

-- Catppuccin

return {
	{
		"catppuccin/nvim",
		name = "catppuccin",
		lazy = false,
		priority = 1000,
		config = function()
			require("catppuccin").setup({
				flavour = "mocha", -- latte / frappe / macchiato / mocha
				transparent_background = true,
				term_colors = true,
				-- integrations = {
				--   snacks = true,
				--   lsp_trouble = true,
				--   mason = true,
				--   which_key = true,
				--   -- weitere Plugins bei Bedarf hier auf true setzen
				-- },
			})

			vim.cmd("colorscheme catppuccin")

			-- local colors = require("catppuccin.palettes").get_palette("mocha")

			-- local groups = {
			--   "Normal",
			--   "NormalNC",
			--   "NormalFloat",
			--   "FloatBorder",
			--   "SignColumn",
			--   "EndOfBuffer",
			--   "LineNr",
			--   "CursorLineNr",
			--   "VertSplit",
			--   "WinSeparator",
			-- }

			local groups = {
				"Normal",
				"NormalNC",
				"NormalFloat",
				"FloatBorder",
				"SignColumn",
				"EndOfBuffer",
				"LineNr",
				"CursorLineNr",
				"VertSplit",
				"WinSeparator",
				"TabLine",
				"TabLineSel",
				"TabLineFill",
				"StatusLine",
				"StatusLineNC",
				"WinBar",
				"WinBarNC",
			}

			-- for _, group in ipairs(groups) do
			--   vim.api.nvim_set_hl(0, group, { bg = "none" })
			-- end

			for _, group in ipairs(groups) do
				-- Der Trick: Wir holen das existierende Highlight (mit Farbe!)
				local old_hl = vim.api.nvim_get_hl(0, { name = group })
				-- Wir ändern NUR den Hintergrund, behalten aber das FG (Vordergrund)
				vim.api.nvim_set_hl(0, group, vim.tbl_extend("force", old_hl, { bg = "none" }))
			end

			vim.api.nvim_set_hl(0, "CursorLineNr", { fg = "#fab387", bold = true, bg = "none" })
			-- vim.api.nvim_set_hl(0, "CursorLineNr", { fg = colors.mauve, bold = true, bg = "none" })
			-- vim.api.nvim_set_hl(0, "LineNr", { fg = colors.surface0, bg = "none" })
			-- vim.api.nvim_set_hl(0, "CursorLine", { bg = colors.surface0})

			-- Terminal Background beim Start ändern
			-- vim.api.nvim_create_autocmd("VimEnter", {
			-- 	callback = function()
			-- 		io.write("\27]11;#1E1E2E\7")
			-- 	end,
			-- })

			-- Beim Beenden zurück zu schwarz
			-- vim.api.nvim_create_autocmd("VimLeavePre", {
			-- 	callback = function()
			-- 		io.write("\27]11;#1a1b1b\7")
			-- 	end,
			-- })
		end,
	},
}

-- Kanagawa

-- return {
--   {
--     "rebelot/kanagawa.nvim",
--     name = "kanagawa",
--     lazy = false,
--     priority = 1000,
--     config = function()
--       require("kanagawa").setup({
--         compile = true,
--         undercurl = true,
--         commentStyle = { italic = true },
--         functionStyle = {},
--         keywordStyle = { italic = true },
--         statementStyle = { bold = true },
--         typeStyle = {},
--         transparent = true, -- transparent background
--         terminalColors = true,
--       })

--       vim.cmd("colorscheme kanagawa")

--       -- local groups = {
--       --   "Normal",
--       --   "NormalNC",
--       --   "NormalFloat",
--       --   "FloatBorder",
--       --   "SignColumn",
--       --   "EndOfBuffer",
--       --   "LineNr",
--       --   "CursorLineNr",
--       --   "VertSplit",
--       --   "WinSeparator",
--       -- }

--       local groups = {
--         "Normal",
--         "NormalNC",
--         "NormalFloat",
--         "FloatBorder",
--         "SignColumn",
--         "EndOfBuffer",
--         "LineNr",
--         "CursorLineNr",
--         "VertSplit",
--         "WinSeparator",
--         "TabLine",
--         "TabLineSel",
--         "TabLineFill",
--         "StatusLine",
--         "StatusLineNC",
--         "WinBar",
--         "WinBarNC",
--       }

--       for _, group in ipairs(groups) do
--         vim.api.nvim_set_hl(0, group, { bg = "none" })
--       end
--     end,
--   },
-- }

-- Gruvbox Material

-- return {
--   {
--     "sainnhe/gruvbox-material",
--     name = "gruvbox-material",
--     lazy = false,
--     priority = 1000,
--     config = function()
--       vim.g.gruvbox_material_background = "soft" -- soft / medium / hard
--       vim.g.gruvbox_material_foreground = "material"
--       vim.g.gruvbox_material_enable_italic = 1
--       vim.g.gruvbox_material_transparent_background = 1 -- transparent background
--       vim.g.gruvbox_material_enable_bold = 1

--       vim.cmd("colorscheme gruvbox-material")

--       -- local groups = {
--       --   "Normal",
--       --   "NormalNC",
--       --   "NormalFloat",
--       --   "FloatBorder",
--       --   "SignColumn",
--       --   "EndOfBuffer",
--       --   "LineNr",
--       --   "CursorLineNr",
--       --   "VertSplit",
--       --   "WinSeparator",
--       -- }

--       local groups = {
--         "Normal",
--         "NormalNC",
--         "NormalFloat",
--         "FloatBorder",
--         "SignColumn",
--         "EndOfBuffer",
--         "LineNr",
--         "CursorLineNr",
--         "VertSplit",
--         "WinSeparator",
--         "TabLine",
--         "TabLineSel",
--         "TabLineFill",
--         "StatusLine",
--         "StatusLineNC",
--         "WinBar",
--         "WinBarNC",
--       }

--       for _, group in ipairs(groups) do
--         vim.api.nvim_set_hl(0, group, { bg = "none" })
--       end
--     end,
--   },
-- }

-- Everforest

-- return {
--   {
--     "sainnhe/everforest",
--     name = "everforest",
--     lazy = false,
--     priority = 1000,
--     config = function()
--       vim.g.everforest_background = "hard"   -- soft / medium / hard
--       vim.g.everforest_enable_italic = 1
--       vim.g.everforest_enable_bold = 1
--       vim.g.everforest_transparent_background = 1 -- transparent

--       vim.cmd("colorscheme everforest")

--       -- local groups = {
--       --   "Normal",
--       --   "NormalNC",
--       --   "NormalFloat",
--       --   "FloatBorder",
--       --   "SignColumn",
--       --   "EndOfBuffer",
--       --   "LineNr",
--       --   "CursorLineNr",
--       --   "VertSplit",
--       --   "WinSeparator",
--       -- }

--       local groups = {
--         "Normal",
--         "NormalNC",
--         "NormalFloat",
--         "FloatBorder",
--         "SignColumn",
--         "EndOfBuffer",
--         "LineNr",
--         "CursorLineNr",
--         "VertSplit",
--         "WinSeparator",
--         "TabLine",
--         "TabLineSel",
--         "TabLineFill",
--         "StatusLine",
--         "StatusLineNC",
--         "WinBar",
--         "WinBarNC",
--       }

--       for _, group in ipairs(groups) do
--         vim.api.nvim_set_hl(0, group, { bg = "none" })
--       end
--     end,
--   },
-- }

-- Rose-Pine

-- return {
--   {
--     "rose-pine/neovim",
--     name = "rose-pine",
--     lazy = false,
--     priority = 1000,
--     config = function()
--       require("rose-pine").setup({
--         variant = "moon",          -- moon / dawn / main
--         dark_variant = "moon",     -- optional, für dunkle Mode
--         transparent = true,        -- transparent background
--         disable_background = true, -- extra Sicherheit für Transparenz
--         highlight_groups = {},     -- kann für Plugin-Anpassungen genutzt werden
--       })

--       vim.cmd("colorscheme rose-pine")

--       -- local groups = {
--       --   "Normal",
--       --   "NormalNC",
--       --   "NormalFloat",
--       --   "FloatBorder",
--       --   "SignColumn",
--       --   "EndOfBuffer",
--       --   "LineNr",
--       --   "CursorLineNr",
--       --   "VertSplit",
--       --   "WinSeparator",
--       -- }

--       local groups = {
--         "Normal",
--         "NormalNC",
--         "NormalFloat",
--         "FloatBorder",
--         "SignColumn",
--         "EndOfBuffer",
--         "LineNr",
--         "CursorLineNr",
--         "VertSplit",
--         "WinSeparator",
--         "TabLine",
--         "TabLineSel",
--         "TabLineFill",
--         "StatusLine",
--         "StatusLineNC",
--         "WinBar",
--         "WinBarNC",
--       }

--       for _, group in ipairs(groups) do
--         vim.api.nvim_set_hl(0, group, { bg = "none" })
--       end
--     end,
--   },
-- }

-- Cyberdream

-- return {
--   {
--     "scottmckendry/cyberdream.nvim",
--     name = "cyberdream",
--     lazy = false,
--     priority = 1000,
--     config = function()
--       require("cyberdream").setup({
--         transparent = true,         -- transparent background
--         terminal_colors = true,     -- Terminalfarben aktivieren
--         italic_comments = true,     -- optional, wenn du italics willst
--         borderless_telescope = true,-- optional für borderloses Telescope
--       })

--       vim.cmd("colorscheme cyberdream")

--       -- local groups = {
--       --   "Normal",
--       --   "NormalNC",
--       --   "NormalFloat",
--       --   "FloatBorder",
--       --   "SignColumn",
--       --   "EndOfBuffer",
--       --   "LineNr",
--       --   "CursorLineNr",
--       --   "VertSplit",
--       --   "WinSeparator",
--       -- }

--       local groups = {
--         "Normal",
--         "NormalNC",
--         "NormalFloat",
--         "FloatBorder",
--         "SignColumn",
--         "EndOfBuffer",
--         "LineNr",
--         "CursorLineNr",
--         "VertSplit",
--         "WinSeparator",
--         "TabLine",
--         "TabLineSel",
--         "TabLineFill",
--         "StatusLine",
--         "StatusLineNC",
--         "WinBar",
--         "WinBarNC",
--       }

--       for _, group in ipairs(groups) do
--         vim.api.nvim_set_hl(0, group, { bg = "none" })
--       end
--     end,
--   },
-- }
