-- plugins/bash.lua

return {
	{
		"neovim/nvim-lspconfig",
		ft = { "sh", "bash", "zsh" },
		opts = {
			servers = {
				bashls = {},
			},
		},
	},

	{
		"stevearc/conform.nvim",
		ft = { "sh", "bash", "zsh" },
		optional = true,
		opts = {
			formatters_by_ft = {
				sh = { "shfmt" },
				bash = { "shfmt" },
				zsh = { "shfmt" },
			},
		},
	},
}
