-- config/options.lua

vim.opt.number = true
vim.opt.relativenumber = true
-- vim.cmd [[
--   augroup NumberToggle
--     autocmd!
--     autocmd InsertEnter * set norelativenumber
--     autocmd InsertLeave * set relativenumber
--   augroup END
-- ]]

-- vim.keymap.set("t", "<C-g>", [[>C-\><C-n>]], { noremap = true, silent = true})
vim.keymap.set("t", "<C-g>", "<C-\\><C-n>", { noremap = true, silent = true })

vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.scrolloff = 9

-- new
vim.opt.smarttab = true
vim.opt.autoindent = true

vim.opt.termguicolors = true
vim.opt.signcolumn = "yes"

vim.opt.clipboard = "unnamedplus"
vim.opt.updatetime = 250

vim.opt.mouse = "a"
-- vim.opt.mouse = "nvi"

-- vim.opt.winbar = "%=%m %f  | %l/%L"

-- local function get_ls_style()
--   local path = vim.fn.expand("%:p")
--   if path == "" then
--     return ""
--   end

--   -- Home kürzen zu ~
--   local home = vim.fn.expand("$HOME")
--   local rel_path = path:gsub("^" .. vim.pesc(home), "~")

--   -- File stats
--   local stat = vim.uv.fs_stat(path)
--   if not stat then
--     return rel_path
--   end

--   local perms = vim.fn.getfperm(path)
--   local size = stat.size

--   local mtime = os.date("%b %d %H:%M", stat.mtime.sec)

--   -- local file = vim.fn.fnamemodify(path, ":t")

--   -- local text = table.concat({
--   --   -- " " .. rel_path,
--   --   rel_path,
--   --   "󰌾 " .. perms,
--   --   "󰈔 " .. size .. "B",
--   --   " " .. mtime,
--   --   -- "󰈙 " .. file,
--   -- }, " › ")

--   local text = table.concat({
--     -- " " .. rel_path,
--     rel_path,
--     perms,
--     size .. "B",
--     mtime,
--     -- "󰈙 " .. file,
--   }, " › ")

--   -- limit 80% window width
--   local winwidth = vim.fn.winwidth(0)
--   local maxlen = math.floor(winwidth * 0.8)

--   if vim.fn.strdisplaywidth(text) > maxlen then
--     text = vim.fn.strcharpart(text, 0, maxlen - 1) .. "…"
--   end

--   return "%=%m " .. text
-- end

local function get_ls_style()
	-- Das Fenster, das gerade gerendert wird
	local winid = vim.g.statusline_winid or vim.api.nvim_get_current_win()
	local bufnr = vim.api.nvim_win_get_buf(winid)

	-- 1. Hardcore Filter: Buffer-Typen und Filetypes
	local ft = vim.bo[bufnr].filetype
	local bt = vim.bo[bufnr].buftype

	-- Erweitere die Liste, falls Snacks Explorer einen anderen Namen nutzt
	if
		bt ~= ""
		or ft == "snacks_explorer"
		or ft == "snacks_layout"
		or ft == "snacks_picker_list"
		or ft:find("snacks")
	then
		return ""
	end

	-- 2. Pfad-Check: Verhindert Anzeige in leeren Buffern
	local path = vim.api.nvim_buf_get_name(bufnr)
	if path == "" or path:find("snacks_explorer") then
		return ""
	end

	-- 3. Daten sammeln
	local home = vim.fn.expand("$HOME")
	local rel_path = path:gsub("^" .. vim.pesc(home), "~")
	local stat = vim.uv.fs_stat(path)

	local info = rel_path
	if stat then
		local perms = vim.fn.getfperm(path)
		local size = math.floor(stat.size / 1024) .. "KB"
		local mtime = os.date("%b %d %H:%M", stat.mtime.sec)
		info = string.format("%s › %s › %s › %s", rel_path, perms, size, mtime)
	end

	-- 4. Platz-Check
	local winwidth = vim.api.nvim_win_get_width(winid)
	if winwidth < 50 then
		return ""
	end -- Zu schmal (z.B. Explorer-Leiste)

	local maxlen = math.floor(winwidth * 0.8)
	if #info > maxlen then
		info = "…" .. info:sub(-(maxlen - 1))
	end

	return "%=%m " .. info
end

_G.winbar = get_ls_style
vim.opt.winbar = "%!v:lua.winbar()"

-- vim.filetype.add({
--   extension = {
--     fxml = "xml",
--   },
-- })

vim.filetype.add({
	pattern = {
		[".*docker%-compose.*yaml"] = "yaml",
		[".*docker%-compose.*yml"] = "yaml",
		[".*%.gitlab%-ci%.yaml"] = "yaml",
		[".*%.gitlab%-ci%.yml"] = "yaml",
		[".*helm%-values.*%.yaml"] = "yaml",
		[".*helm%-values.*%.yml"] = "yaml",
	},
})

-- Mason-Binaries zum System-Pfad hinzufügen (behebt "CLI not found")
local mason_bin = vim.fn.stdpath("data") .. "/mason/bin"
if vim.fn.isdirectory(mason_bin) == 1 then
	local path_sep = package.config:sub(1, 1) == "\\" and ";" or ":"
	vim.env.PATH = mason_bin .. path_sep .. vim.env.PATH
end

-- vim.g.loaded_ruby_provider = 0
-- vim.g.loaded_perl_provider = 0
-- vim.g.loaded_node_provider = 0
-- vim.g.loaded_python3_provider = 0

-- Beruhigt den Snacks-Healthcheck
vim.api.nvim_set_hl(0, "SnacksNormal", { fg = "#cba6f7", bg = "NONE" })
vim.api.nvim_set_hl(0, "SnacksIndent", { fg = "#585b70", bg = "NONE" })

vim.diagnostic.config({
	virtual_text = {
		prefix = "●",
		spacing = 2,
		source = "if_many",
	},
	float = {
		border = "rounded",
	},
	severity_sort = true,
})

-- vim.opt.guicursor = "n-v-c:block,i:block-blinkwait500-blinkon500-blinkoff500"

local function is_binary(path)
	local fd = vim.loop.fs_open(path, "r", 438)
	if not fd then
		return false
	end

	local data = vim.loop.fs_read(fd, 1024, 0)
	vim.loop.fs_close(fd)

	return data and data:find("\0", 1, true) ~= nil
end

vim.api.nvim_create_autocmd("BufReadPost", {
	callback = function(args)
		local buf = args.buf
		local file = args.file

		if file == "" or vim.fn.filereadable(file) == 0 then
			return
		end

		if not is_binary(file) then
			return
		end

		vim.bo[buf].modifiable = true
		vim.cmd("%!hexdump -C")

		vim.bo[buf].filetype = "hexdump"
		vim.bo[buf].readonly = true
		vim.bo[buf].modifiable = false
		vim.bo[buf].modified = false
	end,
})

vim.lsp.config("roslyn_ls", {
  cmd = { "true" }, -- harmless no-op
  filetypes = {},
  root_dir = function()
    return nil
  end,
  single_file_support = false,
  handlers = {
    ["textDocument/publishDiagnostics"] = function() end,
  },
})
