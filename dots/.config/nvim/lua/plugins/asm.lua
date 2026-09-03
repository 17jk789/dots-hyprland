-- plugins/asm.lua

-- return {
--   {
--     "neovim/nvim-lspconfig",
--     opts = {
--       servers = {
--         -- Hier wird der asm-lsp konfiguriert
--         asm_lsp = {
--           filetypes = { "asm", "s", "S" },
--           -- Falls du NASM nutzt, kannst du hier spezifische Optionen setzen
--           root_dir = function(fname)
--             local util = require("lspconfig.util")
--             return util.root_pattern(".git", ".asm-lsp.yaml")(fname) or util.path.dirname(fname)
--           end,
--         },
--       },
--     },
--   },
-- }

return {
	{
		"neovim/nvim-lspconfig",
		ft = { "asm", "s", "S" },
		opts = {
			servers = {
				asm_lsp = {}, -- Standard-Setup reicht völlig aus
			},
		},
	},
}
