-- plugins/cpp.lua

-- return {
--   {
--     "p00f/clangd_extensions.nvim",
--     ft = { "c", "cpp", "objc", "objcpp" },
--     opts = {
--       server = {
--         cmd = {
--           "clangd",
--           "--background-index",
--           "--clang-tidy",
--           "--completion-style=detailed",
--           "--header-insertion=never",
--         },
--       },
--     },
--   },
-- }

-- return {
--   {
--     "p00f/clangd_extensions.nvim",
--     ft = { "c", "cpp", "objc", "objcpp" },
--     opts = {
--       -- Keine eigene clangd Konfiguration hier!
--       -- clangd kommt sauber aus lsp.lua (mason-lspconfig).
--       server = {},
--     },
--   },
-- }

return {
	-- 1. Erweiterte UI für clangd (Inlay Hints, AST-Visualisierung)
	{
		"p00f/clangd_extensions.nvim",
		ft = { "c", "cpp", "objc", "objcpp" },
		opts = {
			ast = {
				-- Zeigt Icons für Typen und Deklarationen im Code (Inlay Hints)
				role_icons = {
					type = "",
					declaration = "",
					expression = "",
					specifier = "",
					statement = "",
					["template argument"] = "",
				},
				kind_icons = {
					Compound = "",
					Recovery = "",
					TranslationUnit = "",
					PackExpansion = "",
					TemplateTypeParm = "",
					TemplateTemplateParm = "",
					TemplateParamObject = "",
				},
			},
		},
		config = function(_, opts)
			require("clangd_extensions").setup(opts)
		end,
	},

	-- 2. Projekt-Management & Build-Automatisierung (CMake)
	{
		"Civitasv/cmake-tools.nvim",
		ft = { "c", "cpp", "objc", "objcpp" },
		dependencies = { "nvim-lua/plenary.nvim" },
		opts = {
			cmake_build_directory = "build/${variant:buildType}",
			-- WICHTIG: Erstellt automatisch die Index-Datei für dein clangd LSP
			cmake_generate_options = { "-DCMAKE_EXPORT_COMPILE_COMMANDS=1" },
			cmake_runner = {
				type = "terminal",
			},
			cmake_notifications = {
				runner = { enabled = true, compile_on_run = true },
			},
		},
	},
}
