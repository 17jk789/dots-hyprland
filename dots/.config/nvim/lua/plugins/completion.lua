-- plugins/completion.lua

-- return {
--   {
--     "hrsh7th/nvim-cmp",
--     opts = function(_, opts)
--       local cmp = require("cmp")

--       opts.mapping = cmp.mapping.preset.insert({
--         ["<C-Space>"] = cmp.mapping.complete(),
--         ["<CR>"] = cmp.mapping.confirm({ select = true }),
--         ["<Tab>"] = cmp.mapping(function(fallback)
--           if cmp.visible() then
--             cmp.select_next_item()
--           else
--             fallback()
--           end
--         end, { "i", "s" }),
--         ["<S-Tab>"] = cmp.mapping(function(fallback)
--           if cmp.visible() then
--             cmp.select_prev_item()
--           else
--             fallback()
--           end
--         end, { "i", "s" }),
--       })

--       opts.experimental = { ghost_text = false }
--     end,
--   },
-- }

-- return {
--   {
--     "hrsh7th/nvim-cmp",
--     dependencies = {
--       "hrsh7th/cmp-nvim-lsp",
--       "L3MON4D3/LuaSnip",
--     },
--     opts = function(_, opts)
--       local cmp = require("cmp")

--       opts.sources = cmp.config.sources({
--         { name = "nvim_lsp" },
--       })

--       opts.mapping = cmp.mapping.preset.insert({
--         ["<C-Space>"] = cmp.mapping.complete(),
--         ["<CR>"] = cmp.mapping.confirm({ select = true }),
--         ["<Tab>"] = cmp.mapping(function(fallback)
--           if cmp.visible() then
--             cmp.select_next_item()
--           else
--             fallback()
--           end
--         end, { "i", "s" }),
--         ["<S-Tab>"] = cmp.mapping(function(fallback)
--           if cmp.visible() then
--             cmp.select_prev_item()
--           else
--             fallback()
--           end
--         end, { "i", "s" }),
--       })

--       opts.experimental = { ghost_text = false }
--     end,
--   },
-- }

-- return {
--   {
--     "hrsh7th/nvim-cmp",
--     dependencies = {
--       "hrsh7th/cmp-nvim-lsp",
--       "L3MON4D3/LuaSnip",
--     },
--     opts = function(_, opts)
--       local cmp = require("cmp")

--       opts.sources = cmp.config.sources({
--         { name = "nvim_lsp" },
--       })

--       opts.mapping = cmp.mapping.preset.insert({
--         ["<C-Space>"] = cmp.mapping.complete(),
--         ["<CR>"] = cmp.mapping.confirm({ select = false }), -- safer

--         ["<Tab>"] = cmp.mapping(function(fallback)
--           if cmp.visible() then
--             cmp.select_next_item()
--           else
--             fallback()
--           end
--         end, { "i", "s" }),

--         ["<S-Tab>"] = cmp.mapping(function(fallback)
--           if cmp.visible() then
--             cmp.select_prev_item()
--           else
--             fallback()
--           end
--         end, { "i", "s" }),
--       })

--       -- Ghost text ist nice, aber manchmal störend.
--       opts.experimental = { ghost_text = false }
--     end,
--   },
-- }

-- return {
--   {
--     "hrsh7th/nvim-cmp",
--     dependencies = {
--       "hrsh7th/cmp-nvim-lsp",
--       "hrsh7th/cmp-buffer",
--       "hrsh7th/cmp-path",
--       "L3MON4D3/LuaSnip",
--     },
--     opts = function(_, opts)
--       local cmp = require("cmp")

--       opts.completion = {
--         completeopt = "menu,menuone,noselect",
--       }

--       -- IntelliSense-ähnliche Priorisierung
--       opts.sources = cmp.config.sources({
--         { name = "nvim_lsp", priority = 1000 },
--         { name = "path", priority = 750 },
--         { name = "buffer", priority = 500, keyword_length = 3 },
--       })

--       opts.mapping = cmp.mapping.preset.insert({
--         ["<C-Space>"] = cmp.mapping.complete(),

--         -- Kein Auto-Accept → sicher
--         ["<CR>"] = cmp.mapping.confirm({
--           select = false,
--           behavior = cmp.ConfirmBehavior.Insert,
--         }),

--         -- Tab nur wenn Menü sichtbar
--         ["<Tab>"] = cmp.mapping(function(fallback)
--           if cmp.visible() then
--             cmp.select_next_item()
--           else
--             fallback()
--           end
--         end, { "i", "s" }),

--         ["<S-Tab>"] = cmp.mapping(function(fallback)
--           if cmp.visible() then
--             cmp.select_prev_item()
--           else
--             fallback()
--           end
--         end, { "i", "s" }),
--       })

--       -- Kein Ghost-Text (IntelliSense-Style)
--       opts.experimental = {
--         ghost_text = false,
--       }

--       return opts
--     end,
--   },
-- }

-- return {
--   {
--     "saghen/blink.cmp",
--     event = "InsertEnter",
--     dependencies = {
--       "rafamadriz/friendly-snippets",
--     },

--     opts = {
--       keymap = {
--         preset = "default",

--         ["<C-Space>"] = { "show", "show_documentation", "hide_documentation" },

--         ["<CR>"] = {
--           "accept",
--           auto_select = false, -- kein auto accept
--         },

--         ["<Tab>"] = {
--           function(cmp)
--             if cmp.is_visible() then
--               return cmp.select_next()
--             end
--           end,
--           "snippet_forward",
--           "fallback",
--         },

--         ["<S-Tab>"] = {
--           function(cmp)
--             if cmp.is_visible() then
--               return cmp.select_prev()
--             end
--           end,
--           "snippet_backward",
--           "fallback",
--         },
--       },

--       completion = {
--         menu = {
--           auto_show = true,
--         },
--         ghost_text = {
--           enabled = false, -- IntelliSense Style
--         },
--       },

--       sources = {
--         default = { "lsp", "path", "buffer" },

--         providers = {
--           lsp = {
--             score_offset = 1000,
--           },
--           path = {
--             score_offset = 750,
--           },
--           buffer = {
--             score_offset = 500,
--             min_keyword_length = 3,
--           },
--         },
--       },

--       signature = {
--         enabled = true, -- wichtig für Rust/C++ etc.
--       },
--     },
--   },
-- }

-- return {
--   {
--     "saghen/blink.cmp",
--     event = "InsertEnter",
--     dependencies = {
--       "rafamadriz/friendly-snippets",
--     },

--     opts = {
--       enabled = function()
--         return vim.g.blink_cmp_enabled ~= false
--       end,

--       keymap = {
--         preset = "default",

--         ["<C-Space>"] = { "show", "show_documentation", "hide_documentation" },

--         -- ["<CR>"] = {
--         --   "accept",
--         --   auto_select = false,
--         -- },

--         ["<CR>"] = {
--           function(cmp)
--             if cmp.is_visible() and cmp.get_selected_item() then
--               return cmp.accept()
--             end
--           end,
--           "fallback",
--         },

--         ["<Tab>"] = {
--           function(cmp)
--             if cmp.is_visible() then
--               return cmp.select_next()
--             end
--           end,
--           "snippet_forward",
--           "fallback",
--         },

--         ["<S-Tab>"] = {
--           function(cmp)
--             if cmp.is_visible() then
--               return cmp.select_prev()
--             end
--           end,
--           "snippet_backward",
--           "fallback",
--         },
--       },

--       completion = {
--         menu = { auto_show = true },
--         ghost_text = { enabled = false },
--       },

--       sources = {
--         default = { "lsp", "path", "buffer" },
--         providers = {
--           lsp = { score_offset = 1000 },
--           path = { score_offset = 750 },
--           buffer = {
--             score_offset = 500,
--             min_keyword_length = 3,
--           },
--         },
--       },

--       signature = { enabled = true },
--     },
--   },
-- }

-- return {
--   {
--     "saghen/blink.cmp",
--     event = "InsertEnter",
--     dependencies = {
--       "rafamadriz/friendly-snippets",
--     },

--     opts = {
--       keymap = {
--         preset = "default",

--         ["<C-Space>"] = { "show", "show_documentation", "hide_documentation" },

--         -- ["<CR>"] = {
--         --   "accept",
--         --   auto_select = false,
--         -- },

--         ["<CR>"] = {
--           function(cmp)
--             if cmp.is_visible() and cmp.get_selected_item() then
--               return cmp.accept()
--             end
--           end,
--           "fallback",
--         },

--         ["<Tab>"] = {
--           function(cmp)
--             if cmp.is_visible() then
--               return cmp.select_next()
--             end
--           end,
--           "snippet_forward",
--           "fallback",
--         },

--         ["<S-Tab>"] = {
--           function(cmp)
--             if cmp.is_visible() then
--               return cmp.select_prev()
--             end
--           end,
--           "snippet_backward",
--           "fallback",
--         },
--       },

--       completion = {
--         menu = { auto_show = true },
--         ghost_text = { enabled = false },
--       },

--       sources = {
--         default = { "lsp", "path", "buffer" },
--         providers = {
--           lsp = { score_offset = 1000 },
--           path = { score_offset = 750 },
--           buffer = {
--             score_offset = 500,
--             min_keyword_length = 3,
--           },
--         },
--       },

--       signature = { enabled = true },
--     },
--   },
-- }

return {
	{
		"saghen/blink.cmp",
		event = "InsertEnter",
		dependencies = {
			"L3MON4D3/LuaSnip",
			"rafamadriz/friendly-snippets",
		},

		opts = {
			enabled = function()
				return vim.g.blink_cmp_enabled ~= false
			end,

			snippets = {
				expand = function(snippet)
					-- REPARATUR 1: Lädt die friendly-snippets automatisch beim ersten Snippet
					if not _G.luasnip_loader_initialized then
						require("luasnip.loaders.from_vscode").lazy_load()
						_G.luasnip_loader_initialized = true
					end
					require("luasnip").lsp_expand(snippet)
				end,
			},

			keymap = {
				preset = "default",

				["<C-Space>"] = { "show", "show_documentation", "hide_documentation" },

				["<CR>"] = {
					function(cmp)
						if cmp.is_visible() and cmp.get_selected_item() then
							return cmp.accept()
						end
					end,
					"fallback",
				},

				-- ELITE TAB (Copilot + blink + LuaSnip perfekt kombiniert)
				["<Tab>"] = {
					function(cmp)
						-- 1. Copilot FIRST
						local copilot = vim.fn["copilot#Accept"]("")
						if copilot ~= "" then
							vim.api.nvim_feedkeys(copilot, "n", false)
							return true
						end

						-- 2. Completion
						if cmp.is_visible() then
							return cmp.select_next()
						end

						-- 3. REPARATUR 2: Nutzt direkt LuaSnip zum Vorwärtsspringen
						local ls = require("luasnip")
						if ls.expand_or_locally_jumpable() then
							ls.expand_or_jump()
							return true
						end

						return false
					end,
					"fallback",
				},

				["<S-Tab>"] = {
					function(cmp)
						if cmp.is_visible() then
							return cmp.select_prev()
						end

						-- REPARATUR 3: Nutzt direkt LuaSnip zum Rückwärtsspringen
						local ls = require("luasnip")
						if ls.jumpable(-1) then
							ls.jump(-1)
							return true
						end
					end,
					"fallback",
				},
			},

			completion = {
				menu = {
					auto_show = true,
					-- border = "rounded", -- nicer UI
				},

				list = {
					selection = {
						preselect = false, -- verhindert falsche auto-selections
					},
				},

				ghost_text = {
					enabled = false, -- wichtig für Copilot!
				},

				-- Copilot-safe
				accept = {
					auto_brackets = {
						enabled = false,
					},
				},
			},

			-- sources = {
			--   default = { "lsp", "path", "buffer" },

			--   providers = {
			--     lsp = { score_offset = 1000 },
			--     path = { score_offset = 750 },

			--     buffer = {
			--       score_offset = 500,
			--       min_keyword_length = 4, -- weniger spam = mehr performance
			--     },
			--   },
			-- },

			sources = {
				default = { "snippets", "lsp", "path", "buffer" }, -- Snippets priorisiert
			},

			signature = {
				enabled = true,
			},
		},
	},
}

-- return {
--   -- Kompatibilitätsschicht, sorgt dafür, dass blink wie nvim-cmp funktioniert
--   {
--     "saghen/blink.compat",
--     version = "*",
--     lazy = true,
--     opts = { impersonate_nvim_cmp = true },
--   },

--   -- Haupt-Completion Setup
--   {
--     "saghen/blink.cmp",
--     cond = not vim.g.vscode,
--     lazy = false, -- lazy loading intern geregelt
--     dependencies = {
--       { "L3MON4D3/LuaSnip", version = "v2.*" },
--     },
--     version = "v0.*",
--     opts = {
--       enabled = function() return vim.g.blink_cmp_enabled ~= false end,

--       -- Snippets & Copilot-safe Tab-Mapping
--       snippets = {
--         preset = "luasnip",
--         expand = function(snippet)
--           require("luasnip").lsp_expand(snippet)
--         end,
--       },

--       keymap = {
--         preset = "default",
--         ["<C-l>"] = { "snippet_forward", "fallback" },
--         ["<C-h>"] = { "snippet_backward", "fallback" },
--         ["<Tab>"] = function(cmp)
--           -- Copilot zuerst
--           local copilot = vim.fn["copilot#Accept"]("")
--           if copilot ~= "" then
--             vim.api.nvim_feedkeys(copilot, "n", false)
--             return true
--           end
--           -- blink Auswahl
--           if cmp.is_visible() then return cmp.select_next() end
--           -- Snippet vorwärts
--           if cmp.snippet_active() then return cmp.snippet_forward() end
--           return false
--         end,
--         ["<S-Tab>"] = function(cmp)
--           if cmp.is_visible() then return cmp.select_prev() end
--           if cmp.snippet_active() then return cmp.snippet_backward() end
--           return false
--         end,
--         ["<CR>"] = function(cmp)
--           if cmp.is_visible() and cmp.get_selected_item() then
--             return cmp.accept()
--           end
--           return false
--         end,
--       },

--       completion = {
--         menu = { auto_show = true },
--         list = { selection = { preselect = false, auto_insert = false } },
--         ghost_text = { enabled = false }, -- Copilot-safe
--         accept = { auto_brackets = { enabled = false } },
--       },

--       cmdline = {
--         keymap = {},
--         completion = { menu = { auto_show = true } },
--       },

--       signature = { enabled = true },

--       sources = {
--         default = { "snippets", "lsp", "path", "buffer" },
--         providers = {
--           path = {
--             opts = {
--               get_cwd = function() return vim.fn.getcwd() end,
--               show_hidden_files_by_default = true,
--               trailing_slash = false,
--             },
--           },
--         },
--       },

--       appearance = { nerd_font_variant = "mono" },

--       fuzzy = {}, -- optional: Snippet-Priorisierung kann hier hinzugefügt werden
--     },

--     -- erlaubt anderen Configs, die default-Sources zu erweitern
--     opts_extend = { "sources.default" },
--   },
-- }
