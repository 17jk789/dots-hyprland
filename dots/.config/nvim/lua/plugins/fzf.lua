-- plugins/fzf.lua

return {
	{ import = "lazyvim.plugins.extras.editor.fzf" },

	{
		"ibhagwan/fzf-lua",
		opts = function(_, opts)
			opts.winopts = {
				height = 0.85,
				width = 0.80,
				preview = {
					layout = "flex", -- Wechselt automatisch zw. horizontal/vertikal
					flip_threshold = 120, -- Ab 120 Spalten wird auf horizontal gewechselt
				},
			}

			opts.keymap = {
				fzf = {
					-- Schnelleres Scrollen in der Vorschau
					["ctrl-d"] = "preview-page-down",
					["ctrl-u"] = "preview-page-up",
					-- Alles auswählen und in die Quickfix-Liste werfen
					["ctrl-q"] = "select-all+accept",
				},
			}

			opts.files = {
				formatter = "path.filename_first", -- Zeigt "fzf.lua  ~/config/..." statt Pfad zuerst
				fd_opts = "--color=never --type f --hidden --follow --exclude .git",
			}

			-- Bildvorschau aktivieren, wird aber von snacks.nvim übernommen: image = { enabled = true }, -> nur bei Problem aktiviren
			-- opts.previewers = {
			--   builtin = {
			--     extensions = {
			--       ["png"] = { "chafa" }, -- Erfordert 'chafa' auf deinem Ubuntu
			--       ["jpg"] = { "chafa" },
			--       ["jpeg"] = { "chafa" },
			--       ["gif"] = { "chafa" },
			--     },
			--     ueberzug_scaler = "kitty", -- Ghostty nutzt das Kitty-Protokoll
			--   },
			-- }

			return opts
		end,
	},
}
