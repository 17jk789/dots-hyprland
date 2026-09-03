-- plugins/copilot.lua

-- {
--   "github/copilot.vim",
--   event = "InsertEnter",
--   config = function()
--     vim.keymap.set("i", "<C-J>", 'copilot#Accept("<CR>")', { expr = true, silent = true })
--   end,
-- }

-- keine Tab überschreibung
-- vim.g.copilot_no_tab_map = true
-- vim.g.copilot_assume_mapped = true

-- optional: standardmäßig AUS (sicherer)
-- vim.g.copilot_enabled = false -- optional: standardmäßig AUS
-- vim.cmd("Copilot disable")

-- Keymaps
-- vim.keymap.set("i", "<C-j>", 'copilot#Accept("<CR>")', { expr = true, silent = true })
-- vim.keymap.set("i", "<C-l>", "<Plug>(copilot-next)")
-- vim.keymap.set("i", "<C-h>", "<Plug>(copilot-previous)")
-- vim.keymap.set("i", "<C-e>", "<Plug>(copilot-dismiss)")

-- return {
--   {
--     "github/copilot.vim",
--     event = "InsertEnter",
--     config = function()
--       vim.g.copilot_no_tab_map = true
--       vim.g.copilot_assume_mapped = true
--       vim.g.copilot_enabled = false
--     end,
--   },
-- }

return {
	{
		"github/copilot.vim",
		event = { "BufReadPre", "BufNewFile" },
		config = function()
			-- Grundeinstellungen
			vim.g.copilot_no_tab_map = true
			vim.g.copilot_assume_mapped = true
			vim.g.copilot_enabled = true

			-- Copilot beim Öffnen aktivieren
			vim.cmd("Copilot enable")

			-- Accept
			-- vim.keymap.set("i", "<C-J>", function()
			--   return vim.fn["copilot#Accept"]("")
			-- end, { expr = true, silent = true })

			-- Navigation
			vim.keymap.set("i", "<C-l>", "<Plug>(copilot-next)", { silent = true })
			vim.keymap.set("i", "<C-h>", "<Plug>(copilot-previous)", { silent = true })
			vim.keymap.set("i", "<C-e>", "<Plug>(copilot-dismiss)", { silent = true })

			-- Toggle
			-- vim.keymap.set("n", "<leader>ai", function()
			--   vim.g.copilot_enabled = not vim.g.copilot_enabled
			--   vim.cmd(vim.g.copilot_enabled and "Copilot enable" or "Copilot disable")
			--   print(vim.g.copilot_enabled and "Copilot ON" or "Copilot OFF")
			-- end, { desc = "Toggle Copilot" })
			vim.keymap.set("n", "<leader>ai", function()
				-- Aktuellen Zustand prüfen via :Copilot status (indirekt)
				local output = vim.fn.systemlist("Copilot status")
				local enabled = not vim.tbl_contains(output, "Disabled globally by :Copilot disable")

				if enabled then
					vim.cmd("Copilot disable")
					print("Copilot OFF")
				else
					vim.cmd("Copilot enable")
					print("Copilot ON")
				end
			end, { desc = "Toggle Copilot" })
		end,
	},
}
