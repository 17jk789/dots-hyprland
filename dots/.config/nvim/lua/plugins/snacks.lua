-- plugins/snacks.lua

-- return {
--   "folke/snacks.nvim",
--   opts = {
--     explorer = {
--       replace_netrw = true,
--     },

--     picker = {
--       sources = {
--         explorer = {
--           hidden = true,
--           ignored = true,
--           layout = {
--             layout = {
--               position = "right",
--             },
--           },
--         },
--       },
--     },
--   },
-- }

return {
	"folke/snacks.nvim",
	event = "VeryLazy",
	opts = {
		explorer = {
			replace_netrw = true,
		},

		picker = {
			sources = {
				-- Explorer
				explorer = {
					hidden = true,
					ignored = true,
					layout = {
						layout = {
							position = "right",
							-- size = 15, -- Höhe in Zeilen
						},
					},
				},

				-- Git Status
				git_status = {
					layout = {
						layout = {
							-- position = "right",
							-- size = 8,
						},
					},
				},
			},
		},
	},
}
