-- plugins/discord.lua

-- return {
--   "andweeb/presence.nvim",
--   event = "VeryLazy", -- Wichtig: Lädt das Plugin erst, wenn alles bereit ist
--   config = function()
--     require("presence").setup({
--       auto_update = true,
--       editing_text = "Editing %s",
--       file_explorer_text = "Browsing %s",
--       show_time = true,
--       -- Hier kannst du nichts am Pfad ändern, presence.nvim sucht automatisch.
--     })
--   end,
-- }

return {
	"vyfor/cord.nvim",
	build = ":Cord update",
	opts = {
		display = {
			theme = "atom", -- Aktiviert das Atom Material Design
		},
	},
}
