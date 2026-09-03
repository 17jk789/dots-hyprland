-- plugins/treesitter-context.lua

return {
	"nvim-treesitter/nvim-treesitter-context",
	dependencies = { "nvim-treesitter/nvim-treesitter" },
	event = "LazyFile",
	config = function()
		require("treesitter-context").setup({
			enable = true,

			-- Maximale Anzahl an Zeilen, die angezeigt werden (0 = unbegrenzt)
			-- Wir setzen max_lines auf 5, sodass genug Kontext (einschließlich Klassenname) immer sichtbar ist
			max_lines = 6, -- Zeigt mindestens 5 Zeilen, darunter auch die Klasse und Methode

			-- 'topline' sorgt für stabilere Anzeige des Kontexts (ähnlich zu VS Code/IntelliJ)
			-- Teste alternativ 'cursor' für andere Positionierung, falls die Anzeige stabiler sein soll
			mode = "cursor", -- 'cursor' bietet möglicherweise eine stabilere Anzeige

			-- Zeilennummern aktivieren
			line_numbers = true,

			-- Zeigt nur die erste Zeile der Methode, um zu verhindern, dass der Kontext zu groß wird
			multiline_threshold = 1,

			-- Der Klassennamen soll immer angezeigt werden.
			-- Der 'outer'-Scope sorgt dafür, dass der äußere Kontext (Klasse) immer sichtbar bleibt.
			trim_scope = "outer", -- Das sorgt dafür, dass die Klasse immer sichtbar bleibt, auch bei kleineren Scrolls

			-- Der Trenner zwischen den Kontextzeilen bleibt "─", um den visuellen Trennstrich anzuzeigen.
			separator = "─",

			-- zindex sorgt dafür, dass der Kontext immer über anderen Inhalten liegt, z.B. Code
			zindex = 20,
		})

		-- Optik: Markierung anstelle eines weißen Strichs
		-- vim.api.nvim_set_hl(0, "TreesitterContext", { link = "CursorLine" })  -- Die Kontextmarkierung erhält die CursorLine-Hervorhebung
		-- vim.api.nvim_set_hl(0, "TreesitterContextBottom", { underline = false })  -- Entfernt Unterstreichungen für den unteren Kontext

		-- Zusätzliche optische Anpassungen für den Hintergrund
		-- vim.api.nvim_set_hl(0, "TreesitterContext", { bg = "#2e3440" })  -- Dunkelgrauer Hintergrund für den oberen Kontext
		-- vim.api.nvim_set_hl(0, "TreesitterContextBottom", { bg = "#3b4252" })  -- Etwas dunklerer Hintergrund für den unteren Kontext
		vim.api.nvim_set_hl(0, "TreesitterContextSeparator", { link = "WinSeparator" })
		vim.api.nvim_set_hl(0, "TreesitterContextBottom", { bg = "#2e3440" })
	end,
}
