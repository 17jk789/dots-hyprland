-- plugins/noice.lua

return {
	"folke/noice.nvim",
	event = "VeryLazy",

	opts = function()
		vim.g.noice_pyjava_filter = true

		return {
			routes = {
				{
					filter = {
						any = {
							{ event = "msg_show" },
							{ event = "lsp", kind = "progress" },
							{ event = "notify" },
						},
						cond = function()
							if not vim.g.noice_pyjava_filter then
								return false
							end

							local ft = vim.bo.filetype
							return ft == "python" or ft == "java"
						end,
					},
					opts = { skip = true },
				},
			},

			lsp = {
				progress = {
					enabled = true,
				},
				override = {
					["vim.lsp.util.convert_input_to_markdown_lines"] = true,
					["vim.lsp.util.stylize_markdown"] = true,
					["cmp.entry.get_documentation"] = true,
				},
			},

			presets = {
				bottom_search = true,
				command_palette = true,
				long_message_to_split = true,
			},
		}
	end,

	keys = {
		{
			"<leader>un",
			function()
				vim.g.noice_pyjava_filter = not vim.g.noice_pyjava_filter

				if vim.g.noice_pyjava_filter then
					vim.notify("Noice: Python/Java Filter ON")
				else
					vim.notify("Noice: Python/Java Filter OFF")
				end
			end,
			desc = "Toggle Noice Python/Java Filter",
		},
	},
}
