local M = {}

M.get = function()
	local capabilities = vim.lsp.protocol.make_client_capabilities()
	capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)
	capabilities.general = capabilities.general or {}
	capabilities.general.positionEncodings = { "utf-8" }
	capabilities.offsetEncoding = { "utf-8" }
	return capabilities
end

return M
