-- plugins/git.lua

-- return {
--   {
--     "lewis6991/gitsigns.nvim",
--     opts = {},
--   },
-- }

-- return {
--   {
--     "lewis6991/gitsigns.nvim",
--     event = "BufReadPre",
--     opts = {
--       -- Git signs immer aktiv
--       signcolumn = true,
--       numhl = true,
--       linehl = true,
--       word_diff = true,

--       -- Inline blame wie GitLens
--       current_line_blame = true,
--       current_line_blame_opts = {
--         delay = 300,
--         virt_text_pos = "eol",
--         ignore_whitespace = false,
--       },

--       current_line_blame_formatter =
--         "<author>, <author_time:%Y-%m-%d> • <summary>",

--       -- Performance / UX
--       watch_gitdir = { interval = 1000 },
--       update_debounce = 100,

--       -- Preview Fenster schöner
--       preview_config = {
--         border = "rounded",
--       },
--     },
--   },
-- }

return {
	-- GITSIGNS (GitLens Inline Blame + Signs)
	{
		"lewis6991/gitsigns.nvim",
		event = "BufReadPre",
		opts = {
			signcolumn = true,
			numhl = true,
			-- linehl = true,
			linehl = false,
			-- word_diff = true,
			word_diff = false,

			-- Inline blame automatisch aktiv
			current_line_blame = true,
			current_line_blame_opts = {
				delay = 250,
				virt_text_pos = "eol",
				ignore_whitespace = false,
			},

			current_line_blame_formatter =
				-- " <author>, <author_time:%Y-%m-%d> • <summary>",
				-- " <author>, <author_time:%Y-%m-%d %H:%M> • <summary>",
				"    <author> (<abbrev_sha>), <author_time:%Y-%m-%d %H:%M> • <summary>",
			-- "    <author> <abbrev_sha> • <author_time:%Y-%m-%d %H:%M> • <summary>",

			watch_gitdir = { interval = 1000 },
			update_debounce = 100,

			preview_config = {
				border = "rounded",
				style = "minimal",
			},

			signs = {
				add = { text = "│" },
				change = { text = "│" },
				delete = { text = "_" },
				topdelete = { text = "‾" },
				changedelete = { text = "~" },
				untracked = { text = "┆" },
			},
		},
	},

	-- DIFFVIEW (GitLens Diff UI Ersatz)
	{
		"sindrets/diffview.nvim",
		dependencies = "nvim-lua/plenary.nvim",
		cmd = {
			"DiffviewOpen",
			"DiffviewClose",
			"DiffviewFileHistory",
		},
		opts = {
			enhanced_diff_hl = true,
			use_icons = true,
			show_help_hints = true,
		},
	},

	-- FUGITIVE (Power Git Commands)
	{
		"tpope/vim-fugitive",
		cmd = {
			"Git",
			"G",
		},
	},

	-- LAZYGIT via snacks.nvim
	-- {
	-- 	"folke/snacks.nvim",
	-- 	priority = 1000,
	-- 	lazy = false,
	-- 	opts = {
	-- 		lazygit = {
	-- 			enabled = true,
	-- 			configure = true,
	-- 			win = {
	-- 				width = 0,
	-- 				height = 0,
	-- 			},

	-- 			config = {
	-- 				os = {
	-- 					editCommand = "nvim",
	-- 					editCommandTemplate = "nvim --server {{server}} --remote-send '<C-\\><C-n>:e {{filename}}<CR>'",
	-- 				},

	-- 				git = {
	-- 					paging = {
	-- 						colorArg = "always",
	-- 						-- 'syntax-theme="none"' sorgt dafür, dass Grün/Rot deinem Theme entsprechen
	-- 						-- pager = [[delta --paging=never --line-numbers --hunk-header-decoration-style="blue box" --hunk-header-style="file line-number syntax" --syntax-theme="none"]],
	-- 						-- pager = "delta --dark --paging=never --line-numbers",
	-- 						pager = "delta --dark --paging=never --line-numbers --true-color=always --syntax-theme='Catppuccin-mocha'",
	-- 					},
	-- 				},

	-- 				gui = {
	-- 					sideBySideView = true,
	-- 				},
	-- 			},
	-- 		},
	-- 	},

	-- 	keys = {
	-- 		{
	-- 			"<leader>gg",
	-- 			function()
	-- 				Snacks.lazygit()
	-- 			end,
	-- 			desc = "LazyGit",
	-- 		},
	-- 	},
	-- },

  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    opts = {
      lazygit = {
        enabled = true,
        configure = true,

        win = {
          width = 0,
          height = 0,
        },

        config = {
          os = {
            editCommand = "nvim",
            -- kompatibel mit LazyGit + Snacks + remote editing
            editCommandTemplate = "nvim --server {{server}} --remote-send '<C-\\><C-n>:e {{filename}} +{{line}}<CR>'",
          },

          git = {
            paging = {
              colorArg = "always",
              pager = table.concat({
                "delta",
                "--paging=never",
                "--line-numbers",
                "--side-by-side",
                "--true-color=always",
                "--navigate",
                "--hyperlinks",
                '--hyperlinks-file-link-format="lazygit-edit://{path}:{line}"',
                "--file-decoration-style=none",
                "--hunk-header-style=file",
                "--commit-style=bold",
              }, " "),
            },
          },

          gui = {
            sideBySideView = true,
            showBottomLine = true,
          },
        },
      },
    },

    keys = {
      {
        "<leader>gg",
        function()
          Snacks.lazygit()
        end,
        desc = "LazyGit",
      },
    },
  },

}

-- :Gitsigns toggle_current_line_blame
-- :Gitsigns toggle_signs
-- :Gitsigns toggle_numhl
-- :Gitsigns toggle_linehl
-- :Gitsigns toggle_word_diff
