-- lsp/yaml.lua

local M = {}

M.setup = function(capabilities)
	local lspconfig = require("lspconfig")

	capabilities = require("lsp.capabilities").get()

	lspconfig.yamlls.setup({
		capabilities = capabilities,

		filetypes = {
			"yaml",
			"yml",
			"yaml.docker-compose",
			"yaml.gitlab",
			"yaml.helm-values",
		},

		settings = {
			yaml = {
				schemaStore = {
					enable = true,
				},
				schemas = {
					["https://json.schemastore.org/docker-compose.json"] = "docker-compose*.yml",
					["https://json.schemastore.org/gitlab-ci.json"] = ".gitlab-ci.yml",
				},
			},
		},

		on_attach = function(client, bufnr)
			local buf_map = function(mode, lhs, rhs, opts)
				opts = opts or {}
				opts.buffer = bufnr
				vim.keymap.set(mode, lhs, rhs, opts)
			end
		end,
	})
end

return M
