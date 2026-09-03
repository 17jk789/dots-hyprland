return {
	{
		"neovim/nvim-lspconfig",
		ft = { "go", "gomod", "gowork" },
		opts = {
			servers = {
				gopls = {
					settings = {
						gopls = {
							gofumpt = true,
							codelenses = {
								gc_details = true,
								generate = true,
								regenerate_cgo = true,
								tidying = true,
								upgrade_dependency = true,
								vendor = true,
							},
							analyses = {
								nilness = true,
								unusedparams = true,
								unusedwrite = true,
								useany = true,
							},
							staticcheck = true,
						},
					},
				},
			},
		},
	},

	{
		"stevearc/conform.nvim",
		ft = { "go", "gomod", "gowork" },
		opts = {
			formatters_by_ft = {
				go = { "gofmt" },
				gomod = { "gofmt" },
				gowork = { "gofmt" },
			},
		},
	},
}
