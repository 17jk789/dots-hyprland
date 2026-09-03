-- plugins/treesitter.lua

return {
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		event = { "BufReadPre", "BufNewFile" },
		opts = {
			ensure_installed = {
				-- Programmiersprachen
				"c",
				"cpp",
				"rust",
        		"c_sharp",
				"java",
				"kotlin",
				"lua",
				"python",
				"go",
				"zig",
				"ron",
				"javascript",
				"typescript",
				"tsx",
				"sql",
				"ruby",
				"php",
				"perl",
				"asm",
				"matlab",
				-- Konfiguration (Korrekturen!)
				"dockerfile",
				"terraform",
				"nginx",
				"tmux",
				"ssh_config",
				"diff",
				"toml",
				"yaml",
				"json",
				"json5",
				"jsonc",
				"ini",
				"xml",
				"csv",
				-- Build & Shell (Korrekturen!)
				"make",
				"groovy",
				"cmake",
				"bash",
				"fish",
				"zsh",
				"powershell",
				-- "sh",
				-- System & Desktop-Envs (Ghostty-kompatibel)
				"hyprlang",
				"rasi",
				"kdl",
				-- "waybar",
				-- Dokumentation & Git
				"markdown",
				"markdown_inline",
				"rst",
				"latex",
				"bibtex",
				"vim",
				"vimdoc",
				"query",
				"regex",
				"git_config",
				"gitignore",
				"git_rebase",
				"gitcommit",
				-- Web
				"html",
				"css",
				"scss",
				"graphql",
				"http",
				"gotmpl",
			},

			highlight = { enable = true },

			-- indent = { enable = true },

			-- auto_install = true,

			-- indent = {
			--   enable = true,
			--   disable = { "cpp" },
			-- },

			textobjects = {
				select = {
					enable = true,
					lookahead = true,
					keymaps = {
						["af"] = "@function.outer",
						["if"] = "@function.inner",
						["ac"] = "@class.outer",
						["ic"] = "@class.inner",
					},
				},

				move = {
					enable = true,
					set_jumps = true,
					goto_next_start = {
						["]m"] = "@function.outer",
					},
					goto_previous_start = {
						["[m"] = "@function.outer",
					},
				},
			},
		},
	},
}
