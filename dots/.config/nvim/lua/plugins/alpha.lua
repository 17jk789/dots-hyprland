-- plugins/alpha.lua

-- Alte Desktop Version von https://www.lazyvim.org/plugins
-- return {
--   "nvimdev/dashboard-nvim",
--   lazy = false, -- As https://github.com/nvimdev/dashboard-nvim/pull/450, dashboard-nvim shouldn't be lazy-loaded to properly handle stdin.
--   opts = function()
--     local logo = [[
--         ██████╗       ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗         Z
--         ██╔══██╗      ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║     Z
--         ██████╔╝█████╗██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║  z
--         ██╔═══╝ ╚════╝██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║z
--         ██║           ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║
--         ╚═╝           ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝
--     ]]

--     logo = string.rep("\n", 8) .. logo .. "\n\n"

--     local opts = {
--       theme = "doom",
--       hide = {
--         -- this is taken care of by lualine
--         -- enabling this messes up the actual laststatus setting after loading a file
--         statusline = false,
--       },
--       config = {
--         header = vim.split(logo, "\n"),
--         -- stylua: ignore
--         center = {
--           { action = 'lua LazyVim.pick()()',                           desc = " Find File",       icon = " ", key = "f" },
--           { action = "ene | startinsert",                              desc = " New File",        icon = " ", key = "n" },
--           { action = 'lua LazyVim.pick("oldfiles")()',                 desc = " Recent Files",    icon = " ", key = "r" },
--           { action = 'lua LazyVim.pick("live_grep")()',                desc = " Find Text",       icon = " ", key = "g" },
--           { action = 'lua LazyVim.pick.config_files()()',              desc = " Config",          icon = " ", key = "c" },
--           { action = 'lua require("persistence").load()',              desc = " Restore Session", icon = " ", key = "s" },
--           { action = "LazyExtras",                                     desc = " Lazy Extras",     icon = " ", key = "x" },
--           { action = "Lazy",                                           desc = " Lazy",            icon = "󰒲 ", key = "l" },
--           { action = function() vim.api.nvim_input("<cmd>qa<cr>") end, desc = " Quit",            icon = " ", key = "q" },
--         },
--         footer = function()
--           local stats = require("lazy").stats()
--           local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
--           return { "⚡ NeoVim loaded " .. stats.loaded .. "/" .. stats.count .. " plugins in " .. ms .. "ms" }
--         end,
--       },
--     }

--     for _, button in ipairs(opts.config.center) do
--       button.desc = button.desc .. string.rep(" ", 43 - #button.desc)
--       button.key_format = "  %s"
--     end

--     -- open dashboard after closing lazy
--     if vim.o.filetype == "lazy" then
--       vim.api.nvim_create_autocmd("WinClosed", {
--         pattern = tostring(vim.api.nvim_get_current_win()),
--         once = true,
--         callback = function()
--           vim.schedule(function()
--             vim.api.nvim_exec_autocmds("UIEnter", { group = "dashboard" })
--           end)
--         end,
--       })
--     end

--     return opts
--   end,
-- }

-- Neovim Version
local v = vim.version()
local nvim_version = string.format("NeoVim v%d.%d.%d", v.major, v.minor, v.patch)

-- LazyVim Version (best effort)
-- LazyVim Version (best effort)
local lazy_version = (function()
	-- 1. Versuch: Die offizielle LazyVim Config nutzen (wie dein Terminal-Check)
	local ok_lv, lv_config = pcall(require, "lazyvim.config")
	if ok_lv and lv_config.version then
		return "LazyVim " .. lv_config.version
	end

	-- 2. Fallback: Direkt über lazy.nvim Metadaten (für Commit-Infos)
	local ok_lazy, Config = pcall(require, "lazy.core.config")
	if ok_lazy and Config.plugins and Config.plugins["LazyVim"] then
		local p = Config.plugins["LazyVim"]
		local version = p.version or p.tag or "stable"
		local commit = type(p.commit) == "string" and (" (" .. p.commit:sub(1, 7) .. ")") or ""
		return "LazyVim " .. version .. commit
	end

	return "LazyVim"
end)()

-- OS + Linux Distribution + Version
local os_info = (function()
	local file = io.open("/etc/os-release", "r")
	if not file then
		return "Linux (unknown distro)"
	end

	local data = file:read("*a")
	file:close()

	local pretty = data:match('PRETTY_NAME="(.-)"')

	if pretty then
		-- optional: " (Noble Numbat)" entfernen
		pretty = pretty:gsub("%s*%b()", "")

		return pretty
	end

	return "Linux"
end)()

-- ASCII art found in:
-- https://github.com/MaximilianLloyd/ascii.nvim/
-- Also appears in:
-- https://github.com/doomemacs/doomemacs (MIT)
-- Original author unknown.
-- local header = [[
-- =================     ===============     ===============   ========  ========
-- \\ . . . . . . .\\   //. . . . . . .\\   //. . . . . . .\\  \\. . .\\// . . //
-- ||. . ._____. . .|| ||. . ._____. . .|| ||. . ._____. . .|| || . . .\/ . . .||
-- || . .||   ||. . || || . .||   ||. . || || . .||   ||. . || ||. . . . . . . ||
-- ||. . ||   || . .|| ||. . ||   || . .|| ||. . ||   || . .|| || . | . . . . .||
-- || . .||   ||. _-|| ||-_ .||   ||. . || || . .||   ||. _-|| ||-_.|\ . . . . ||
-- ||. . ||   ||-'  || ||  `-||   || . .|| ||. . ||   ||-'  || ||  `|\_ . .|. .||
-- || . _||   ||    || ||    ||   ||_ . || || . _||   ||    || ||   |\ `-_/| . ||
-- ||_-' ||  .|/    || ||    \|.  || `-_|| ||_-' ||  .|/    || ||   | \  / |-_.||
-- ||    ||_-'      || ||      `-_||    || ||    ||_-'      || ||   | \  / |  `||
-- ||    `'         || ||         `'    || ||    `'         || ||   | \  / |   ||
-- ||            .===' `===.         .==='.`===.         .===' /==. |  \/  |   ||
-- ||         .=='   \_|-_ `===. .==='   _|_   `===. .===' _-|/   `==  \/  |   ||
-- ||      .=='    _-'    `-_  `='    _-'   `-_    `='  _-'   `-_  /|  \/  |   ||
-- ||   .=='    _-'          '-__\._-'         '-_./__-'         `' |. /|  |   ||
-- ||.=='    _-'                                                     `' |  /==.||
-- =='    _-'                                                            \/   `==
-- \   _-'                    N E O V I M - J U L I A N                   `-_   /
--  `''                                                                      ``'

-- __NVIM__ / __LAZY__ / JKNV 3.6.9 / __OS__]]

-- local header = [[
--         ██████╗       ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗         Z
--         ██╔══██╗      ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║     Z
--         ██████╔╝█████╗██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║  z
--         ██╔═══╝ ╚════╝██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║z
--         ██║           ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║
--         ╚═╝           ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝
--
-- N E O V I M - J U L I A N

-- __NVIM__ / __LAZY__ / JKNV 3.6.9 / __OS__]]

-- ASCII art found in:
-- https://github.com/MaximilianLloyd/ascii.nvim/
-- Original author unknown.
local header = [[
                                                                    
       ████ ██████           █████      ██                    
      ███████████             █████                            
      █████████ ███████████████████ ███   ███████████  
     █████████  ███    █████████████ █████ ██████████████  
    █████████ ██████████ █████████ █████ █████ ████ █████  
  ███████████ ███    ███ █████████ █████ █████ ████ █████ 
 ██████  █████████████████████ ████ █████ █████ ████ ██████

N E O V I M - J U L I A N

__NVIM__ / __LAZY__ / JKNV 3.6.9 / Arch Linux x86_64]]

header = header:gsub("__NVIM__", nvim_version):gsub("__LAZY__", lazy_version):gsub("__OS__", os_info)

return {
	{
		"folke/snacks.nvim",
		opts = {
			dashboard = {
				-- Von: https://github.com/folke/snacks.nvim/blob/main/docs/dashboard.md
				sections = {
					{ section = "header" },
					{ icon = " ", title = "Keymaps", section = "keys", indent = 2, padding = 1 },
					{ icon = " ", title = "Recent Files", section = "recent_files", indent = 2, padding = 1 },
					{ icon = " ", title = "Projects", section = "projects", indent = 2, padding = 1 },
					{ section = "startup" },
				},

				-- Von: https://github.com/folke/snacks.nvim/blob/main/docs/dashboard.md
				-- sections = {
				--   { section = "header" },
				--   { section = "keys", gap = 1, padding = 2},
				--   { icon = " ", title = "Recent Files", section = "recent_files", indent = 2, padding = 2},
				--   { icon = " ", title = "Projects", section = "projects", indent = 2, padding = 2 },
				--   { section = "startup" },
				-- },

				-- Von: https://github.com/folke/snacks.nvim/blob/main/docs/dashboard.md
				-- sections = {
				--   { section = "header" },
				--   {
				--     pane = 2,
				--     section = "terminal",
				--     cmd = "colorscript -e square",
				--     height = 5,
				--     padding = 1,
				--   },
				--   { section = "keys", gap = 1, padding = 1 },
				--   { pane = 2, icon = " ", title = "Recent Files", section = "recent_files", indent = 2, padding = 1 },
				--   { pane = 2, icon = " ", title = "Projects", section = "projects", indent = 2, padding = 1 },
				--   {
				--     pane = 2,
				--     icon = " ",
				--     title = "Git Status",
				--     section = "terminal",
				--     enabled = function()
				--       return Snacks.git.get_root() ~= nil
				--     end,
				--     cmd = "git status --short --branch --renames",
				--     height = 5,
				--     padding = 1,
				--     ttl = 5 * 60,
				--     indent = 3,
				--   },
				--   { section = "startup" },
				-- },

				-- Von: https://github.com/folke/snacks.nvim/blob/main/docs/dashboard.md
				-- sections = {
				--   {
				--     section = "terminal",
				--     cmd = "chafa ~/.config/wall.png --format symbols --symbols vhalf --size 60x17 --stretch; sleep .1",
				--     height = 17,
				--     padding = 1,
				--   },
				--   {
				--     pane = 2,
				--     { section = "keys", gap = 1, padding = 1 },
				--     { section = "startup" },
				--   },
				-- },

				-- Von: https://github.com/folke/snacks.nvim/blob/main/docs/dashboard.md
				-- sections = {
				--   { section = "header" },
				--   { section = "keys", gap = 1, padding = 1 },
				--   { section = "startup" },
				-- },

				-- Von: https://github.com/folke/snacks.nvim/blob/main/docs/dashboard.md
				-- sections = {
				--   { section = "header" },
				--   {
				--     pane = 2,
				--     section = "terminal",
				--     cmd = "colorscript -e square",
				--     height = 5,
				--     padding = 1,
				--   },
				--   { section = "keys", gap = 1, padding = 1 },
				--   {
				--     pane = 2,
				--     icon = " ",
				--     desc = "Browse Repo",
				--     padding = 1,
				--     key = "b",
				--     action = function()
				--       Snacks.gitbrowse()
				--     end,
				--   },
				--   function()
				--     local in_git = Snacks.git.get_root() ~= nil
				--     local cmds = {
				--       {
				--         title = "Notifications",
				--         cmd = "gh notify -s -a -n5",
				--         action = function()
				--           vim.ui.open("https://github.com/notifications")
				--         end,
				--         key = "n",
				--         icon = " ",
				--         height = 5,
				--         enabled = true,
				--       },
				--       {
				--         title = "Open Issues",
				--         cmd = "gh issue list -L 3",
				--         key = "i",
				--         action = function()
				--           vim.fn.jobstart("gh issue list --web", { detach = true })
				--         end,
				--         icon = " ",
				--         height = 7,
				--       },
				--       {
				--         icon = " ",
				--         title = "Open PRs",
				--         cmd = "gh pr list -L 3",
				--         key = "P",
				--         action = function()
				--           vim.fn.jobstart("gh pr list --web", { detach = true })
				--         end,
				--         height = 7,
				--       },
				--       {
				--         icon = " ",
				--         title = "Git Status",
				--         cmd = "git --no-pager diff --stat -B -M -C",
				--         height = 10,
				--       },
				--     }
				--     return vim.tbl_map(function(cmd)
				--       return vim.tbl_extend("force", {
				--         pane = 2,
				--         section = "terminal",
				--         enabled = in_git,
				--         padding = 1,
				--         ttl = 5 * 60,
				--         indent = 3,
				--       }, cmd)
				--     end, cmds)
				--   end,
				--   { section = "startup" },
				-- },

				-- Von: https://github.com/folke/snacks.nvim/blob/main/docs/dashboard.md
				-- sections = {
				--   { section = "header" },
				--   { section = "keys", gap = 1, padding = 1 },
				--   { section = "startup" },
				--   {
				--     section = "terminal",
				--     cmd = "pokemon-colorscripts -r --no-title; sleep .1",
				--     random = 10,
				--     pane = 2,
				--     indent = 4,
				--     height = 30,
				--   },
				-- },

				-- Von: https://github.com/folke/snacks.nvim/blob/main/docs/dashboard.md
				-- formats = {
				--   key = function(item)
				--     return { { "[", hl = "special" }, { item.key, hl = "key" }, { "]", hl = "special" } }
				--   end,
				-- },

				-- Von: https://github.com/folke/snacks.nvim/blob/main/docs/dashboard.md
				-- sections = {
				--   { section = "terminal", cmd = "fortune -s | cowsay", hl = "header", padding = 1, indent = 8 },
				--   { title = "MRU", padding = 1 },
				--   { section = "recent_files", limit = 8, padding = 1 },
				--   { title = "MRU ", file = vim.fn.fnamemodify(".", ":~"), padding = 1 },
				--   { section = "recent_files", cwd = true, limit = 8, padding = 1 },
				--   { title = "Sessions", padding = 1 },
				--   { section = "projects", padding = 1 },
				--   { title = "Bookmarks", padding = 1 },
				--   { section = "keys" },
				-- },

				preset = {
					-- ASCII art found in:
					-- https://github.com/MaximilianLloyd/ascii.nvim/
					-- Also appears in:
					-- https://github.com/doomemacs/doomemacs (MIT)
					-- Original author unknown.
					--           [[
					-- =================     ===============     ===============   ========  ========
					-- \\ . . . . . . .\\   //. . . . . . .\\   //. . . . . . .\\  \\. . .\\// . . //
					-- ||. . ._____. . .|| ||. . ._____. . .|| ||. . ._____. . .|| || . . .\/ . . .||
					-- || . .||   ||. . || || . .||   ||. . || || . .||   ||. . || ||. . . . . . . ||
					-- ||. . ||   || . .|| ||. . ||   || . .|| ||. . ||   || . .|| || . | . . . . .||
					-- || . .||   ||. _-|| ||-_ .||   ||. . || || . .||   ||. _-|| ||-_.|\ . . . . ||
					-- ||. . ||   ||-'  || ||  `-||   || . .|| ||. . ||   ||-'  || ||  `|\_ . .|. .||
					-- || . _||   ||    || ||    ||   ||_ . || || . _||   ||    || ||   |\ `-_/| . ||
					-- ||_-' ||  .|/    || ||    \|.  || `-_|| ||_-' ||  .|/    || ||   | \  / |-_.||
					-- ||    ||_-'      || ||      `-_||    || ||    ||_-'      || ||   | \  / |  `||
					-- ||    `'         || ||         `'    || ||    `'         || ||   | \  / |   ||
					-- ||            .===' `===.         .==='.`===.         .===' /==. |  \/  |   ||
					-- ||         .=='   \_|-_ `===. .==='   _|_   `===. .===' _-|/   `==  \/  |   ||
					-- ||      .=='    _-'    `-_  `='    _-'   `-_    `='  _-'   `-_  /|  \/  |   ||
					-- ||   .=='    _-'          '-__\._-'         '-_./__-'         `' |. /|  |   ||
					-- ||.=='    _-'                                                     `' |  /==.||
					-- =='    _-'                                                            \/   `==
					-- \   _-'                    N E O V I M - J U L I A N                   `-_   /
					--  `''                                                                      ``'
					--           ]],

					-- ASCII art found in:
					-- https://github.com/MaximilianLloyd/ascii.nvim/
					-- Original author unknown.

					--           [[
					--                                               
					--        ████ ██████           █████      ██
					--       ███████████             █████ 
					--       █████████ ███████████████████ ███   ███████████
					--      █████████  ███    █████████████ █████ ██████████████
					--     █████████ ██████████ █████████ █████ █████ ████ █████
					--   ███████████ ███    ███ █████████ █████ █████ ████ █████
					--  ██████  █████████████████████ ████ █████ █████ ████ ██████

					-- N E O V I M - J U L I A N]],

					header = header,

					-- ASCII art found in:
					-- https://github.com/MaximilianLloyd/ascii.nvim/
					-- Original author unknown.
					--           [[
					--             :h-                                  Nhy`
					--            -mh.                           h.    `Ndho
					--            hmh+                          oNm.   oNdhh
					--           `Nmhd`                        /NNmd  /NNhhd
					--           -NNhhy                      `hMNmmm`+NNdhhh
					--           .NNmhhs              ```....`..-:/./mNdhhh+
					--            mNNdhhh-     `.-::///+++////++//:--.`-/sd`
					--            oNNNdhhdo..://++//++++++/+++//++///++/-.`
					--       y.   `mNNNmhhhdy+/++++//+/////++//+++///++////-` `/oos:
					--  .    Nmy:  :NNNNmhhhhdy+/++/+++///:.....--:////+++///:.`:s+
					--  h-   dNmNmy oNNNNNdhhhhy:/+/+++/-         ---:/+++//++//.`
					--  hd+` -NNNy`./dNNNNNhhhh+-://///    -+oo:`  ::-:+////++///:`
					--  /Nmhs+oss-:++/dNNNmhho:--::///    /mmmmmo  ../-///++///////.
					--   oNNdhhhhhhhs//osso/:---:::///    /yyyyso  ..o+-//////////:/.
					--    /mNNNmdhhhh/://+///::://////     -:::- ..+sy+:////////::/:/.
					--      /hNNNdhhs--:/+++////++/////.      ..-/yhhs-/////////::/::/`
					--        .ooo+/-::::/+///////++++//-/ossyyhhhhs/:///////:::/::::/:
					--        -///:::::::////++///+++/////:/+ooo+/::///////.::://::---+`
					--        /////+//++++/////+////-..//////////::-:::--`.:///:---:::/:
					--        //+++//++++++////+++///::--                 .::::-------::
					--        :/++++///////////++++//////.                -:/:----::../-
					--        -/++++//++///+//////////////               .::::---:::-.+`
					--        `////////////////////////////:.            --::-----...-/
					--         -///://////////////////////::::-..      :-:-:-..-::.`.+`
					--          :/://///:///::://::://::::::/:::::::-:---::-.-....``/- -
					--            ::::://::://::::::::::::::----------..-:....`.../- -+oo/
					--             -/:::-:::::---://:-::-::::----::---.-.......`-/.      ``
					--            s-`::--:::------:////----:---.-:::...-.....`./:
					--           yMNy.`::-.--::..-dmmhhhs-..-.-.......`.....-/:`
					--          oMNNNh. `-::--...:NNNdhhh/.--.`..``.......:/-
					--         :dy+:`      .-::-..NNNhhd+``..`...````.-::-`
					--                         .-:mNdhh:.......--::::-`
					--                            yNh/..------..`
					--
					-- N E O V I M - J U L I A N
					--
					--           ]],

					--           [[
					--         ██████╗       ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗         Z
					--         ██╔══██╗      ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║     Z
					--         ██████╔╝█████╗██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║  z
					--         ██╔═══╝ ╚════╝██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║z
					--         ██║           ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║
					--         ╚═╝           ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝
					--
					-- N E O V I M - J U L I A N
					--
					--           ]],

					--           [[
					--
					--           _____                    _____                   _______                   _____                    _____                    _____
					--          /\    \                  /\    \                 /::\    \                 /\    \                  /\    \                  /\    \
					--         /::\____\                /::\    \               /::::\    \               /::\____\                /::\    \                /::\____\
					--        /::::|   |               /::::\    \             /::::::\    \             /:::/    /                \:::\    \              /::::|   |
					--       /:::::|   |              /::::::\    \           /::::::::\    \           /:::/    /                  \:::\    \            /:::::|   |
					--      /::::::|   |             /:::/\:::\    \         /:::/~~\:::\    \         /:::/    /                    \:::\    \          /::::::|   |
					--     /:::/|::|   |            /:::/__\:::\    \       /:::/    \:::\    \       /:::/____/                      \:::\    \        /:::/|::|   |
					--    /:::/ |::|   |           /::::\   \:::\    \     /:::/    / \:::\    \      |::|    |                       /::::\    \      /:::/ |::|   |
					--   /:::/  |::|   | _____    /::::::\   \:::\    \   /:::/____/   \:::\____\     |::|    |     _____    ____    /::::::\    \    /:::/  |::|___|______
					--  /:::/   |::|   |/\    \  /:::/\:::\   \:::\    \ |:::|    |     |:::|    |    |::|    |    /\    \  /\   \  /:::/\:::\    \  /:::/   |::::::::\    \
					-- /:: /    |::|   /::\____\/:::/__\:::\   \:::\____\|:::|____|     |:::|    |    |::|    |   /::\____\/::\   \/:::/  \:::\____\/:::/    |:::::::::\____\
					-- \::/    /|::|  /:::/    /\:::\   \:::\   \::/    / \:::\    \   /:::/    /     |::|    |  /:::/    /\:::\  /:::/    \::/    /\::/    / ~~~~~/:::/    /
					--  \/____/ |::| /:::/    /  \:::\   \:::\   \/____/   \:::\    \ /:::/    /      |::|    | /:::/    /  \:::\/:::/    / \/____/  \/____/      /:::/    /
					--          |::|/:::/    /    \:::\   \:::\    \        \:::\    /:::/    /       |::|____|/:::/    /    \::::::/    /                       /:::/    /
					--          |::::::/    /      \:::\   \:::\____\        \:::\__/:::/    /        |:::::::::::/    /      \::::/____/                       /:::/    /
					--          |:::::/    /        \:::\   \::/    /         \::::::::/    /         \::::::::::/____/        \:::\    \                      /:::/    /
					--          |::::/    /          \:::\   \/____/           \::::::/    /           ~~~~~~~~~~               \:::\    \                    /:::/    /
					--          /:::/    /            \:::\    \                \::::/    /                                      \:::\    \                  /:::/    /
					--         /:::/    /              \:::\____\                \::/____/                                        \:::\____\                /:::/    /
					--         \::/    /                \::/    /                 ~~                                               \::/    /                \::/    /
					--          \/____/                  \/____/                                                                    \/____/                  \/____/
					--
					-- N E O V I M - J U L I A N
					--
					--           ]],

					--           [[
					--
					--  /$$   /$$ /$$$$$$$$  /$$$$$$  /$$    /$$ /$$$$$$ /$$      /$$
					-- | $$$ | $$| $$_____/ /$$__  $$| $$   | $$|_  $$_/| $$$    /$$$
					-- | $$$$| $$| $$      | $$  \ $$| $$   | $$  | $$  | $$$$  /$$$$
					-- | $$ $$ $$| $$$$$   | $$  | $$|  $$ / $$/  | $$  | $$ $$/$$ $$
					-- | $$  $$$$| $$__/   | $$  | $$ \  $$ $$/   | $$  | $$  $$$| $$
					-- | $$\  $$$| $$      | $$  | $$  \  $$$/    | $$  | $$\  $ | $$
					-- | $$ \  $$| $$$$$$$$|  $$$$$$/   \  $/    /$$$$$$| $$ \/  | $$
					-- |__/  \__/|________/ \______/     \_/    |______/|__/     |__/
					--
					-- N E O V I M - J U L I A N
					--
					--           ]],

					--           [[
					--
					--   _   _ ______ ______      _______ __  __
					--  | \ | |  ____/ __ \ \    / /_   _|  \/  |
					--  |  \| | |__ | |  | \ \  / /  | | | \  / |
					--  | . ` |  __|| |  | |\ \/ /   | | | |\/| |
					--  | |\  | |___| |__| | \  /   _| |_| |  | |
					--  |_| \_|______\____/   \/   |_____|_|  |_|
					--
					-- N E O V I M - J U L I A N
					--
					--           ]],

					--           [[
					--
					--  .-----------------. .----------------.  .----------------.  .----------------.  .----------------.  .----------------.
					-- | .--------------. || .--------------. || .--------------. || .--------------. || .--------------. || .--------------. |
					-- | | ____  _____  | || |  _________   | || |     ____     | || | ____   ____  | || |     _____    | || | ____    ____ | |
					-- | ||_   \|_   _| | || | |_   ___  |  | || |   .'    `.   | || ||_  _| |_  _| | || |    |_   _|   | || ||_   \  /   _|| |
					-- | |  |   \ | |   | || |   | |_  \_|  | || |  /  .--.  \  | || |  \ \   / /   | || |      | |     | || |  |   \/   |  | |
					-- | |  | |\ \| |   | || |   |  _|  _   | || |  | |    | |  | || |   \ \ / /    | || |      | |     | || |  | |\  /| |  | |
					-- | | _| |_\   |_  | || |  _| |___/ |  | || |  \  `--'  /  | || |    \ ' /     | || |     _| |_    | || | _| |_\/_| |_ | |
					-- | ||_____|\____| | || | |_________|  | || |   `.____.'   | || |     \_/      | || |    |_____|   | || ||_____||_____|| |
					-- | |              | || |              | || |              | || |              | || |              | || |              | |
					-- | '--------------' || '--------------' || '--------------' || '--------------' || '--------------' || '--------------' |
					--  '----------------'  '----------------'  '----------------'  '----------------'  '----------------'  '----------------'
					--
					-- N E O V I M - J U L I A N
					--
					--           ]],

					--           [[
					--
					--                           ,
					--       ,       ,      ,    )\          ,    ,          ,    ,        ,       ,          ,
					--      /(       )\    /( |‾‾‾‾‾|\      /(    )\        /(    )\      /(      /(          )\
					--    |‾‾‾‾|   |‾‾‾|\|‾‾‾‾|     | \  /|‾‾‾‾||‾‾‾‾|\   /|‾‾‾||‾‾‾|\  |‾‾‾‾| /|‾‾‾‾|      |‾‾‾‾|\
					--    |    |\ /|   |||    \‾‾‾‾‾\ | / |    ||    | \ / |   ||   | \ |    || |    |      |    | \
					--    |‾‾‾‾||/‾‾‾‾‾\||‾‾‾‾ ,     \|| /‾‾‾‾‾/\‾‾‾‾\ || / ‾‾‾/\‾‾‾ \ ||‾‾‾‾||/‾‾‾‾/       |‾‾‾‾|  \
					--    |    |/ /|    ||     /‾‾‾‾|/ |/     /  \    \||/    /  \    \||    ||     |       |    |  |
					--    |      / |    ||     \‾‾‾\|  |     |    |    ||    |    |    ||    ||     |  /|‾|\ \    \ |
					--    |     /  |    ||     /--,/‾|\|     |    |    ||    |    |    ||    | \     \/ /‾\ \ \    \|
					--   /|    /  /     ||     '‾‾‾‾‾\| \     \  /    / |    |    |    ||    |  \     \/   \ \/     |
					--  //    /| /     / |     /     /   \     \/    /  |    |    |    ||    |   \          \/     /
					-- |/    / |/     /   ‾‾‾|/     /     ‾‾‾‾|/    /   |    |    |    ||    |    |      /\       /
					--  ‾‾‾‾‾   ‾‾‾‾‾‾        ‾‾‾‾‾‾           ‾‾‾‾‾     ‾‾‾‾      ‾‾‾‾  ‾‾‾‾      ‾‾‾‾‾‾  ‾‾‾‾‾‾‾
					--
					-- N E O V I M - J U L I A N
					--
					--           ]],

					--           [[
					--
					--  ________   _______   ________  ___      ___ ___  _____ ______
					-- |\   ___  \|\  ___ \ |\   __  \|\  \    /  /|\  \|\   _ \  _   \
					-- \ \  \\ \  \ \   __/|\ \  \|\  \ \  \  /  / | \  \ \  \\\__\ \  \
					--  \ \  \\ \  \ \  \_|/_\ \  \\\  \ \  \/  / / \ \  \ \  \\|__| \  \
					--   \ \  \\ \  \ \  \_|\ \ \  \\\  \ \    / /   \ \  \ \  \    \ \  \
					--    \ \__\\ \__\ \_______\ \_______\ \__/ /     \ \__\ \__\    \ \__\
					--     \|__| \|__|\|_______|\|_______|\|__|/       \|__|\|__|     \|__|
					--
					-- N E O V I M - J U L I A N
					--
					--           ]],

					--           [[
					--
					-- ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗
					-- ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║
					-- ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║
					-- ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║
					-- ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║
					-- ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝
					--
					-- N E O V I M - J U L I A N
					--
					--           ]],

					--           [[
					--
					--  ███▄    █ ▓█████  ▒█████   ██▒   █▓ ██▓ ███▄ ▄███▓
					--  ██ ▀█   █ ▓█   ▀ ▒██▒  ██▒▓██░   █▒▓██▒▓██▒▀█▀ ██▒
					-- ▓██  ▀█ ██▒▒███   ▒██░  ██▒ ▓██  █▒░▒██▒▓██    ▓██░
					-- ▓██▒  ▐▌██▒▒▓█  ▄ ▒██   ██░  ▒██ █░░░██░▒██    ▒██
					-- ▒██░   ▓██░░▒████▒░ ████▓▒░   ▒▀█░  ░██░▒██▒   ░██▒
					-- ░ ▒░   ▒ ▒ ░░ ▒░ ░░ ▒░▒░▒░    ░ ▐░  ░▓  ░ ▒░   ░  ░
					-- ░ ░░   ░ ▒░ ░ ░  ░  ░ ▒ ▒░    ░ ░░   ▒ ░░  ░      ░
					--    ░   ░ ░    ░   ░ ░ ░ ▒       ░░   ▒ ░░      ░
					--          ░    ░  ░    ░ ░        ░   ░         ░
					--                                 ░
					--
					-- N E O V I M - J U L I A N
					--
					--           ]],

					--           [[
					--
					-- ███▄▄▄▄      ▄████████  ▄██████▄   ▄█    █▄   ▄█    ▄▄▄▄███▄▄▄▄
					-- ███▀▀▀██▄   ███    ███ ███    ███ ███    ███ ███  ▄██▀▀▀███▀▀▀██▄
					-- ███   ███   ███    █▀  ███    ███ ███    ███ ███▌ ███   ███   ███
					-- ███   ███  ▄███▄▄▄     ███    ███ ███    ███ ███▌ ███   ███   ███
					-- ███   ███ ▀▀███▀▀▀     ███    ███ ███    ███ ███▌ ███   ███   ███
					-- ███   ███   ███    █▄  ███    ███ ███    ███ ███  ███   ███   ███
					-- ███   ███   ███    ███ ███    ███ ███    ███ ███  ███   ███   ███
					--  ▀█   █▀    ██████████  ▀██████▀   ▀██████▀  █▀    ▀█   ███   █▀
					--
					-- N E O V I M - J U L I A N
					--
					--           ]],

					--           [[
					--
					--  ██████   █████ ██████████    ███████    █████   █████ █████ ██████   ██████
					-- ░░██████ ░░███ ░░███░░░░░█  ███░░░░░███ ░░███   ░░███ ░░███ ░░██████ ██████
					--  ░███░███ ░███  ░███  █ ░  ███     ░░███ ░███    ░███  ░███  ░███░█████░███
					--  ░███░░███░███  ░██████   ░███      ░███ ░███    ░███  ░███  ░███░░███ ░███
					--  ░███ ░░██████  ░███░░█   ░███      ░███ ░░███   ███   ░███  ░███ ░░░  ░███
					--  ░███  ░░█████  ░███ ░   █░░███     ███   ░░░█████░    ░███  ░███      ░███
					--  █████  ░░█████ ██████████ ░░░███████░      ░░███      █████ █████     █████
					-- ░░░░░    ░░░░░ ░░░░░░░░░░    ░░░░░░░         ░░░      ░░░░░ ░░░░░     ░░░░░
					--
					-- N E O V I M - J U L I A N
					--
					--           ]],

					--           header = [[

					--     ....      ..                   ...     ...                                                    .
					--   +^""888h. ~"888h              .=*8888n.."%888:                                                 @88>
					--  8X.  ?8888X  8888f            X    ?8888f '8888                     u.        ...     ..        %8P      ..    .     :
					-- '888x  8888X  8888~            88x. '8888X  8888>       .u     ...ue888b    :~""888h.:^"888:      .     .888: x888  x888.
					-- '88888 8888X   "88x:          '8888k 8888X  '"*8h.   ud8888.   888R Y888r  8X   `8888X  8888>   .@88u  ~`8888~'888X`?888f`
					--  `8888 8888X  X88x.            "8888 X888X .xH8    :888'8888.  888R I888> X888n. 8888X  ?888>  ''888E`   X888  888X '888>
					--    `*` 8888X '88888X             `8" X888!:888X    d888 '88%"  888R I888> '88888 8888X   ?**h.   888E    X888  888X '888>
					--   ~`...8888X  "88888            =~`  X888 X888X    8888.+"     888R I888>   `*88 8888~ x88x.     888E    X888  888X '888>
					--    x8888888X.   `%8" 88888888    :h. X8*` !888X    8888L      u8888cJ888   ..<"  88*`  88888X    888E    X888  888X '888>
					--   '%"*8888888h.   "  88888888   X888xX"   '8888..: '8888c. .+  "*888*P"       ..XC.    `*8888k   888&   "*88%""*88" '888!`
					--   ~    888888888!`            :~`888f     '*888*"   "88888%      'Y"        :888888H.    `%88>   R888"    `~    "    `"`
					--        X888^"""                   ""        `"`       "YP'                 <  `"888888:    X"     ""
					--        `88f                                                                      %888888x.-`
					--         88                                                                         ""**""
					--         ""

					-- N E O V I M - J U L I A N

					--           ]],

					--           header = [[

					--      ...     ...                                                    .
					--   .=*8888n.."%888:                                                 @88>
					--  X    ?8888f '8888                     u.        ...     ..        %8P      ..    .     :
					--  88x. '8888X  8888>       .u     ...ue888b    :~""888h.:^"888:      .     .888: x888  x888.
					-- '8888k 8888X  '"*8h.   ud8888.   888R Y888r  8X   `8888X  8888>   .@88u  ~`8888~'888X`?888f`
					--  "8888 X888X .xH8    :888'8888.  888R I888> X888n. 8888X  ?888>  ''888E`   X888  888X '888>
					--    `8" X888!:888X    d888 '88%"  888R I888> '88888 8888X   ?**h.   888E    X888  888X '888>
					--   =~`  X888 X888X    8888.+"     888R I888>   `*88 8888~ x88x.     888E    X888  888X '888>
					--    :h. X8*` !888X    8888L      u8888cJ888   ..<"  88*`  88888X    888E    X888  888X '888>
					--   X888xX"   '8888..: '8888c. .+  "*888*P"       ..XC.    `*8888k   888&   "*88%""*88" '888!`
					-- :~`888f     '*888*"   "88888%      'Y"        :888888H.    `%88>   R888"    `~    "    `"`
					--     ""        `"`       "YP'                 <  `"888888:    X"     ""
					--                                                    %888888x.-`
					--                                                      ""**""

					-- N E O V I M - J U L I A N

					--           ]],

					--           header = [[

					--  ...=-. .   ..=...
					-- ..===--..   ..===.....                                       ...
					-- =====---.   ..+++++...                                       .==
					-- ===+======....+++++... .=..####.  .-#*##.  .:#%##..+##    +##.##..##*####.#####.
					-- +++++======...+++++... .=:     #..#......:.#     .#.###  .##. ##..##. .-##. .###
					-- +++++..=====:.+++++... .=:     # +:.......=-     .#:.##-.##.  ##..##.  .##   *##
					-- +++++...======*++++... .=:     # .#      ..%     .#.. ####..  ##..##.  .##   *##
					-- +++++.   =====+****...  =:     #  .#=..=#  .#:..=#.   .##:   .##..##.  .##.  *##
					-- +++++.   ..===+++**...
					-- ..***.   ...=++++...
					--    .*.      .-+.

					-- N E O V I M - J U L I A N

					--           ]],

					--           header = [[

					--        ▄▌             █
					--     ,▓████▄           ███▄
					--   ,████████▒          █████▄
					--  ████████████         ███████▄
					-- ▐█████████████▄       ████████H
					-- ▐██████████████▌      ████████H
					-- ▐████████████████▄    ████████H
					-- ▐███████▒▀████████▌   ████████H
					-- ▐███████▒░`█████████▄ ████████H
					-- ▐███████▒  `▀████████▌███████▌H
					-- ▐███████▒    ╙███████████████▌H
					-- ║███████▒     `▀█████████████▌H
					-- ▐███████▒       ╙█████████████H
					--  ╙██████▒        `██████████▀Ñ`
					--   `╙████▒         `╠██████▒Ñ╨`
					--     `╨▀█▒           `███▒Ñ`
					--        ╙╨            `╨╨`

					-- N E O V I M - J U L I A N

					--           ]],

					-- footer = {
					--   "",
					--   " github.com",
					-- },

					keys = {
						{
							icon = " ",
							key = "f",
							desc = "Find File",
							action = ":lua Snacks.dashboard.pick('files')",
						},
						-- { icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
						{
							icon = " ",
							key = "g",
							desc = "Find Text",
							action = ":lua Snacks.dashboard.pick('live_grep')",
						},
						{
							icon = " ",
							key = "r",
							desc = "Recent Files",
							action = ":lua Snacks.dashboard.pick('oldfiles')",
						},
						{
							icon = " ",
							key = "c",
							desc = "Config",
							action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})",
						},
						{ icon = " ", key = "s", desc = "Restore Session", section = "session" },
						{ icon = " ", key = "x", desc = "Lazy Extras", action = ":LazyExtras" },
						{ icon = "󰒲 ", key = "l", desc = "Lazy", action = ":Lazy" },
						{ icon = " ", key = "y", desc = "Lazy Health", action = ":Lazy health" },
						{ icon = " ", key = "h", desc = "System Health Check", action = ":checkhealth" },
						{ icon = " ", key = "m", desc = "Mason", action = ":Mason" },
						-- { icon = " ", key = "i", desc = "LspInfo", action = ":LspInfo" },
						{
							icon = " ",
							key = "b",
							desc = "17jk789/jk-arch",
							action = function()
								local url = "https://github.com/17jk789/jk-arch"
								local cmd

								if vim.fn.has("mac") == 1 then
									cmd = { "open", url }
								elseif vim.env.WSL_DISTRO_NAME ~= nil then
									-- Speziell für WSL: Nutzt den Windows-Standardbrowser
									cmd = { "wslview", url }
								elseif vim.fn.has("unix") == 1 then
									cmd = { "xdg-open", url }
								end

								if cmd then
									vim.fn.jobstart(cmd, { detach = true })
								else
									vim.notify("No suitable command found to open the URL.", vim.log.levels.ERROR)
								end
							end,
						},
						-- {
						--   icon = " ",
						--   key = "k",
						--   desc = "LazyVim Keymaps",
						--   action = function()
						--     local url = "https://www.lazyvim.org/keymaps"
						--     local cmd
						--     if vim.fn.has("mac") == 1 then
						--       cmd = {"open", url}
						--     elseif vim.fn.has("unix") == 1 then
						--       cmd = {"xdg-open", url}
						--     elseif vim.fn.has("win32") == 1 then
						--       cmd = {"cmd", "/c", "start", "", url}
						--     end
						--     if cmd then
						--       vim.fn.jobstart(cmd, {detach = true})
						--     end
						--   end
						-- },
						{ icon = " ", key = "q", desc = "Quit", action = ":qa" },
					},
				},
			},
		},
	},
}
