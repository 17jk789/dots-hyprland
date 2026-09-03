-- plugins/matlab.lua

return {
	--   {
	--     "neovim/nvim-lspconfig",
	--     opts = function(_, opts)
	--       opts.servers = vim.tbl_deep_extend("force", opts.servers or {}, {
	--         matlab_ls = {
	--           settings = {
	--             MATLAB = {
	--               installPath = "/opt/matlab",
	--               indexWorkspace = true,
	--               telemetry = false,
	--               matlabConnectionTiming = "onStart", -- WICHTIG: Startet Engine nur wenn nötig
	--             },
	--           },
	--           -- Wir sagen Neovim, dass dieser Server KEIN Formatting kann,
	--           -- um den automatischen Timeout-Error zu verhindern.
	--           on_attach = function(client, _)
	--             client.server_capabilities.documentFormattingProvider = false
	--             client.server_capabilities.documentRangeFormattingProvider = false

	--             -- Lokale LSP-Navi (überschreibt Global nur hier im Buffer!)
	--             local bopts = { buffer = bufnr, noremap = true, silent = true }
	--             vim.keymap.set("n", "gd", vim.lsp.buf.definition, bopts)
	--             vim.keymap.set("n", "gr", vim.lsp.buf.references, bopts)
	--           end,
	--         },
	--       })
	--     end,
	--     init = function()
	--       local group = vim.api.nvim_create_augroup("MatlabFix", { clear = true })

	--       vim.api.nvim_create_autocmd("FileType", {
	--         group = group,
	--         pattern = "matlab",
	--         callback = function(args)
	--           vim.opt_local.shiftwidth = 4
	--           vim.opt_local.tabstop = 4
	--           vim.opt_local.expandtab = true

	--           -- LSP Keymap nur für Doc/Hover
	--           vim.keymap.set("n", "K", vim.lsp.buf.hover, { buffer = args.buf })

	--           -- MANUELLES FORMATIEREN (Vim-Native statt LSP)
	--           -- Das hier erzeugt NIEMALS einen LSP-Timeout!
	--           vim.api.nvim_create_autocmd("BufWritePre", {
	--             group = group,
	--             buffer = args.buf,
	--             callback = function()
	--               local view = vim.fn.winsaveview()
	--               vim.cmd("silent! normal! gg=G")
	--               vim.fn.winrestview(view)
	--             end,
	--           })
	--         end,
	--       })
	--     end,
	--   },
}
