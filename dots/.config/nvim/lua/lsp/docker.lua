-- lsp/docker.lua

local M = {}

M.setup = function(capabilities)
	local lspconfig = require("lspconfig")

	capabilities = require("lsp.capabilities").get()

	lspconfig.dockerls.setup({
		capabilities = capabilities,
		filetypes = { "dockerfile" },

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
