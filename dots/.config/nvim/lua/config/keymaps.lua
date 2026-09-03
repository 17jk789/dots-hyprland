-- config/keymaps.lua

-- local map = vim.keymap.set
local opts = { noremap = true, silent = true }

-- Safe Keymap Helper (setzt nur wenn frei)
local function map_if_free(mode, lhs, rhs, opts)
  if vim.fn.mapcheck(lhs, mode) == "" then
    vim.keymap.set(mode, lhs, rhs, opts or { noremap = true, silent = true })
  end
end

-- Test
-- Schaltet Autoformat komplett AUS oder AN (für LSP und Conform)
vim.keymap.set("n", "<leader>ta", function()
  vim.g.autoformat = not vim.g.autoformat
  if vim.g.autoformat then
    print("Autoformat: ON (Watch out for legacy code!)")
  else
    print("Autoformat: OFF (Safe mode enabled)")
  end
end, { desc = "Toggle Autoformat Global" })

vim.api.nvim_create_user_command("AutoFormatOff", function()
  vim.g.autoformat = false
  print("Autoformat: OFF")
end, {})

vim.api.nvim_create_user_command("AutoFormatOn", function()
  vim.g.autoformat = true
  print("Autoformat: ON")
end, {})

vim.keymap.set(
  "n",
  "<C-p>",
  ":Telescope find_files<cr>",
  { desc = "Find Files (Telescope)", silent = true, noremap = true }
)
vim.keymap.set("n", "<C-f>", ":Telescope live_grep<cr>", { desc = "Telescope Live Grep", silent = true })
vim.keymap.set(
  "n",
  "<C-o>",
  ":Telescope lsp_document_symbols<cr>",
  { desc = "Telescope LSP Document Symbols", silent = true }
)

vim.api.nvim_create_user_command("LspRestart", function()
  for _, client in ipairs(vim.lsp.get_clients({ bufnr = 0 })) do
    vim.lsp.stop_client(client.id)
  end

  vim.cmd("edit")
end, { desc = "Restart LSP" })

-- vim.keymap.set("n", "<C-m>", ":TroubleToggle<cr>", { desc = "Trouble Toggle", silent = true, buffer = true })
vim.keymap.set("n", "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", { desc = "Trouble Toggle", silent = true })
vim.keymap.set("n", "<C-b>", ":NvimTreeToggle<cr>", { desc = "NvimTree Toggle", silent = true })

vim.keymap.set("n", "<leader>f<space>", "<cmd>FzfLua files<cr>", { desc = "Fzf Find Files", silent = true })

-- vim.keymap.set("n", "<C-_>", "gcc", { desc = "Toggle Comment", silent = true, buffer = true })
vim.keymap.set("n", "<leader>/", "gcc", { desc = "Toggle Comment", silent = true })
-- vim.keymap.set("v", "<C-_>", "gc", { desc = "Toggle Comment (Visual)", silent = true, buffer = true })
vim.keymap.set("v", "<leader>/", "gc", { desc = "Toggle Comment", silent = true })

vim.keymap.set("n", "<C-S-p>", ":Telescope commands<cr>", { desc = "Telescope Commands", silent = true })

-- vim.keymap.set("n", "<C-Tab>", ":bnext<cr>", { desc = "Switch to Next Buffer", silent = true, buffer = true })
vim.keymap.set("n", "<leader>bn", ":bnext<cr>", { desc = "Next Buffer", silent = true })
-- vim.keymap.set("n", "<C-S-Tab>", ":bprevious<cr>", { desc = "Switch to Previous Buffer", silent = true, buffer = true })
vim.keymap.set("n", "<leader>bp", ":bprevious<cr>", { desc = "Previous Buffer", silent = true })

vim.keymap.set("n", "<C-s>", ":w<cr>", { desc = "Save File", silent = true })
vim.keymap.set("i", "<C-s>", "<Esc>:w<cr>a", { desc = "Save File and Continue Editing", silent = true })

vim.keymap.set("n", "gd", "<cmd>lua vim.lsp.buf.definition()<cr>", { desc = "Go to Definition", silent = true })
vim.keymap.set("n", "gr", "<cmd>lua vim.lsp.buf.references()<cr>", { desc = "Show References", silent = true })
vim.keymap.set("n", "K", "<cmd>lua vim.lsp.buf.hover()<cr>", { desc = "Show Hover Info", silent = true })

vim.keymap.set("n", "<F2>", "<cmd>lua vim.lsp.buf.rename()<cr>", opts)

-- vim.keymap.set("n", "<C-m>", "<cmd>lua vim.diagnostic.open_float()<cr>", { desc = "Show Diagnostic Float", silent = true, buffer = true })
-- vim.keymap.set("n", "[d", "<cmd>lua vim.diagnostic.goto_prev()<cr>", { desc = "Go to Previous Diagnostic", silent = true, buffer = true })
-- vim.keymap.set("n", "]d", "<cmd>lua vim.diagnostic.goto_next()<cr>", { desc = "Go to Next Diagnostic", silent = true, buffer = true })

-- vim.keymap.set("n", "<F5>", "<cmd>lua require'dap'.continue()<cr>", { desc = "DAP Continue", silent = true, buffer = true })
-- vim.keymap.set("n", "<F9>", "<cmd>lua require'dap'.toggle_breakpoint()<cr>", { desc = "DAP Toggle Breakpoint", silent = true, buffer = true })
-- vim.keymap.set("n", "<F10>", "<cmd>lua require'dap'.step_over()<cr>", { desc = "DAP Step Over", silent = true, buffer = true })
-- vim.keymap.set("n", "<F11>", "<cmd>lua require'dap'.step_into()<cr>", { desc = "DAP Step Into", silent = true, buffer = true })
-- vim.keymap.set("n", "<F12>", "<cmd>lua require'dap'.step_out()<cr>", { desc = "DAP Step Out", silent = true, buffer = true })

vim.keymap.set("n", "L", ":BufferLineCycleNext<CR>", { silent = true })
vim.keymap.set("n", "H", ":BufferLineCyclePrev<CR>", { silent = true })

-- vim.keymap.set("n", "<C-d>", "<cmd>lua require('dapui').toggle()<cr>", { desc = "Toggle DAP UI", silent = true, buffer = true })
vim.keymap.set("n", "<leader>du", "<cmd>lua require('dapui').toggle()<cr>", { desc = "DAP UI Toggle", silent = true })
vim.keymap.set("n", "<leader>dr", "<cmd>lua require'dap'.repl.open()<cr>", { desc = "DAP Open REPL", silent = true })

vim.keymap.set("n", "<leader>cf", ":ConformInfo<CR>", { desc = "Conform: Formatter Info" })

-- Clipboard yanking (system clipboard)
-- vim.keymap.set({ "n", "v" }, "y", '"+y', { noremap = true, silent = true })
-- vim.keymap.set("n", "yy", '"+yy', { noremap = true, silent = true })
vim.keymap.set({ "n", "v", "o" }, "y", '"+y', { noremap = true, silent = true })
vim.keymap.set({ "n", "o" }, "yy", '"+yy', { noremap = true, silent = true })

-- d / dd NICHT ins Clipboard (Black-hole register)
vim.keymap.set({ "n", "v" }, "d", '"_d', { noremap = true, silent = true })
vim.keymap.set("n", "dd", '"_dd', { noremap = true, silent = true })

vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code Action" })
vim.keymap.set("v", "<leader>ca", vim.lsp.buf.code_action, { desc = "Range Code Action" })

local function get_current_dir()
  return vim.fn.expand("%:p:h")
end

local function build_path(dir, file)
  return vim.fn.fnameescape(dir .. "/" .. file)
end

local function ensure_dir(path)
  local dir = vim.fn.fnamemodify(path, ":h")
  if vim.fn.isdirectory(dir) == 0 then
    vim.fn.mkdir(dir, "p")
  end
end

function _G.complete_from_current_dir(arglead)
  local dir = get_current_dir()
  local results = vim.fn.getcompletion(dir .. "/" .. arglead, "file")

  return vim.tbl_map(function(path)
    return path:gsub("^" .. dir .. "/", "")
  end, results)
end

local function open_relative(cmd, raw_args)
  local dir = get_current_dir()

  -- split nur beim ersten |
  local file, extra = raw_args:match("^(.-)%s*|%s*(.+)$")

  if not file then
    file = raw_args
  end

  -- Datei / Split
  if file == "" then
    vim.cmd(cmd)
  else
    local full_path = dir .. "/" .. file
    ensure_dir(full_path)
    vim.cmd(cmd .. " " .. build_path(dir, file))
  end

  -- Extra Commands (z.B. term, terminal, etc.)
  if extra and extra ~= "" then
    -- wenn irgendein terminal command vorkommt
    if extra:match("^term") or extra:match("^terminal") then
      vim.cmd("lcd " .. vim.fn.fnameescape(dir))
    end

    vim.cmd(extra)
  end
end

vim.api.nvim_create_user_command("Ee", function(opts)
  open_relative("edit", opts.args)
end, {
  nargs = "*",
  complete = "customlist,v:lua.complete_from_current_dir",
})

vim.api.nvim_create_user_command("Spp", function(opts)
  open_relative("split", opts.args)
end, {
  nargs = "*",
  complete = "customlist,v:lua.complete_from_current_dir",
})

vim.api.nvim_create_user_command("Vspp", function(opts)
  open_relative("vsplit", opts.args)
end, {
  nargs = "*",
  complete = "customlist,v:lua.complete_from_current_dir",
})

-- :Open <file> -> öffnet Datei mit xdg-open / OS Default App
vim.api.nvim_create_user_command("Open", function(opts)
  local file = opts.args ~= "" and opts.args or vim.fn.expand("%:p")

  if vim.fn.filereadable(file) == 0 then
    vim.notify("File not found: " .. file, vim.log.levels.ERROR)
    return
  end

  -- Tool-Auswahl: wslview für WSL, xdg-open für natives Linux
  local cmd = vim.env.WSL_DISTRO_NAME ~= nil and "wslview" or "xdg-open"

  -- Prüfen, ob das Tool überhaupt existiert
  if vim.fn.executable(cmd) == 0 then
    vim.notify("Programm '" .. cmd .. "' not found. Please install it!", vim.log.levels.ERROR)
    return
  end

  vim.fn.jobstart({ cmd, file }, { detach = true })
end, {
  nargs = "?",
  complete = "file",
})

vim.api.nvim_create_user_command("Openn", function(opts)
  local dir = vim.fn.expand("%:p:h")

  -- wenn kein Argument → aktuelle Datei
  local file
  if opts.args == "" then
    file = vim.fn.expand("%:p")
  else
    file = dir .. "/" .. opts.args
  end

  file = vim.fn.fnameescape(file)

  -- prüfen ob Datei existiert
  if vim.fn.filereadable(file) == 0 then
    vim.notify("File not found: " .. file, vim.log.levels.ERROR)
    return
  end

  -- Tool wählen
  local cmd = vim.env.WSL_DISTRO_NAME ~= nil and "wslview" or "xdg-open"

  if vim.fn.executable(cmd) == 0 then
    vim.notify("Programm '" .. cmd .. "' not found!", vim.log.levels.ERROR)
    return
  end

  -- öffnen
  vim.fn.jobstart({ cmd, file }, { detach = true })
end, {
  nargs = "?",
  complete = "customlist,v:lua.complete_from_current_dir",
})

-- Explorer öffnen, sollte schon gehen.
-- map_if_free("n", "<leader>e", Snacks.picker.explorer)
-- vim.keymap.set("n", "<leader>e", function() Snacks.explorer() end, { desc = "File Explorer" })

map_if_free("n", "]h", "<cmd>Gitsigns next_hunk<cr>", { desc = "Next Hunk" })
map_if_free("n", "[h", "<cmd>Gitsigns prev_hunk<cr>", { desc = "Prev Hunk" })

-- Git Basics
map_if_free("n", "<leader>gb", "<cmd>G blame<cr>", { desc = "Git Blame", silent = true })
map_if_free("n", "<leader>gd", "<cmd>DiffviewOpen<cr>", { desc = "Diffview Open", silent = true })
map_if_free("n", "<leader>gh", "<cmd>DiffviewFileHistory %<cr>", { desc = "Diffview File History", silent = true })
map_if_free("n", "<leader>gc", "<cmd>Git commit<cr>", { desc = "Git Commit", silent = true })
map_if_free("n", "<leader>gp", "<cmd>Git push<cr>", { desc = "Git Push", silent = true })
map_if_free("n", "<leader>gl", "<cmd>Git pull<cr>", { desc = "Git Pull", silent = true })

-- Git Status öffnen
-- map_if_free("n", "<leader>g", Snacks.picker.git_status, { desc = "Git Status Picker" })
vim.keymap.set("n", "<leader>gG", "<cmd>Git<cr>", { desc = "Git Status" })

-- Hunks
-- map_if_free("n", "]h", "<cmd>Gitsigns next_hunk<cr>", { desc = "Go to Next Git Hunk" })
-- map_if_free("n", "[h", "<cmd>Gitsigns prev_hunk<cr>", { desc = "Go to Previous Git Hunk" })
map_if_free("n", "<leader>hs", "<cmd>Gitsigns stage_hunk<cr>", { desc = "Gitsigns Stage Hunk", silent = true })
map_if_free("n", "<leader>hr", "<cmd>Gitsigns reset_hunk<cr>", { desc = "Gitsigns Reset Hunk", silent = true })
map_if_free("n", "<leader>hp", "<cmd>Gitsigns preview_hunk<cr>", { desc = "Gitsigns Preview Hunk", silent = true })
map_if_free("n", "<leader>hb", "<cmd>Gitsigns blame_line<cr>", { desc = "Gitsigns Blame Line", silent = true })
map_if_free("n", "<leader>hS", "<cmd>Gitsigns stage_buffer<cr>", { desc = "Gitsigns Stage Buffer", silent = true })
map_if_free("n", "<leader>hR", "<cmd>Gitsigns reset_buffer<cr>", { desc = "Gitsigns Reset Buffer", silent = true })
map_if_free("n", "<leader>hd", "<cmd>Gitsigns diffthis<cr>", { desc = "Gitsigns Diff This", silent = true })
map_if_free("n", "<leader>hD", "<cmd>Gitsigns diffthis ~<cr>", { desc = "Gitsigns Diff This ~", silent = true })

-- Toggle Git UI
map_if_free(
  "n",
  "<leader>tb",
  "<cmd>Gitsigns toggle_current_line_blame<cr>",
  { desc = "Gitsigns Toggle Current Line Blame", silent = true }
)
map_if_free("n", "<leader>ts", "<cmd>Gitsigns toggle_signs<cr>", { desc = "Gitsigns Toggle Signs", silent = true })
map_if_free(
  "n",
  "<leader>tn",
  "<cmd>Gitsigns toggle_numhl<cr>",
  { desc = "Gitsigns Toggle Number Highlight", silent = true }
)
map_if_free(
  "n",
  "<leader>tl",
  "<cmd>Gitsigns toggle_linehl<cr>",
  { desc = "Gitsigns Toggle Line Highlight", silent = true }
)
map_if_free(
  "n",
  "<leader>tw",
  "<cmd>Gitsigns toggle_word_diff<cr>",
  { desc = "Gitsigns Toggle Word Diff", silent = true }
)

-- Extra Git Commands (nicht typisch in LazyVim)
map_if_free("n", "<leader>gco", "<cmd>Git checkout<cr>", { desc = "Git Checkout", silent = true })
-- map_if_free("n", "<leader>gcb", "<cmd>Git checkout -b ")
map_if_free("n", "<leader>gcb", function()
  vim.ui.input({ prompt = "New branch name: " }, function(branch)
    if branch and branch ~= "" then
      vim.cmd("Git checkout -b " .. branch)
    end
  end)
end)
map_if_free("n", "<leader>gca", "<cmd>Git commit --amend<cr>", { desc = "Git Commit Amend", silent = true })
map_if_free("n", "<leader>gss", "<cmd>Git stash<cr>", { desc = "Git Stash", silent = true })
map_if_free("n", "<leader>gsp", "<cmd>Git stash pop<cr>", { desc = "Git Stash Pop", silent = true })
map_if_free("n", "<leader>gF", "<cmd>Git fetch<cr>", { desc = "Git Fetch", silent = true })
map_if_free("n", "<leader>gr", "<cmd>Git remote -v<cr>", { desc = "Git Remote -v", silent = true })
-- map_if_free("n", "<leader>glo", "<cmd>Git log --oneline --graph<cr>")
map_if_free(
  "n",
  "<leader>glo",
  "<cmd>Git log --oneline --graph --decorate --all<cr>",
  { desc = "Git Log Oneline Graph", silent = true }
)
map_if_free("n", "<leader>gdc", "<cmd>DiffviewClose<cr>", { desc = "Diffview Close", silent = true })

-- Schneller Wechsel zwischen geändert Dateien in Diffview
-- Wenn Diffview offen ist, kannst du mit diesen Keys durch die Dateien springen
map_if_free("n", "<leader>gn", "<cmd>DiffviewNextFile<cr>", { desc = "Git: Next File in Diff" })
map_if_free("n", "<leader>gN", "<cmd>DiffviewPrevFile<cr>", { desc = "Git: Prev File in Diff" })

-- local json_file = vim.fn.expand("~/.config/nvim/image_toggle_status.json")

-- -- JSON erstellen, falls nicht existiert
-- if vim.fn.filereadable(json_file) == 0 then
--   vim.fn.writefile({ vim.fn.json_encode({ display = false }) }, json_file)
-- end

-- -- Hilfsfunktion, um Status in die JSON zu schreiben
-- local function save_status(value)
--   vim.fn.writefile({ vim.fn.json_encode({ display = value }) }, json_file)
-- end

-- -- Commands, die nur JSON ändern
-- vim.api.nvim_create_user_command("ImageON", function()
--   save_status(true)
--   print("JSON: display = true")
-- end, {})

-- vim.api.nvim_create_user_command("ImageOFF", function()
--   save_status(false)
--   print("JSON: display = false")
-- end, {})

-- vim.api.nvim_create_user_command("ImageToggle", function()
--   local ok, data = pcall(vim.fn.json_decode, table.concat(vim.fn.readfile(json_file), "\n"))
--   local current = ok and data and data.display or false
--   save_status(not current)
--   print("JSON: display = " .. tostring(not current))
-- end, {})

-- -- Keymaps
-- vim.keymap.set("n", "<leader>io", "<cmd>ImageON<cr>", { noremap = true, silent = true, desc = "ImageON" })
-- vim.keymap.set("n", "<leader>if", "<cmd>ImageOFF<cr>", { noremap = true, silent = true, desc = "ImageOFF" })
-- vim.keymap.set("n", "<leader>it", "<cmd>ImageToggle<cr>", { noremap = true, silent = true, desc = "ImageToggle" })

-- -- Copilot Accept (wie VS Code Tab)
-- vim.keymap.set("i", "<Tab>", function()
--   if vim.fn["copilot#Accept"]("") ~= "" then
--     return vim.fn["copilot#Accept"]("<CR>")
--   end
--   return "<Tab>"
-- end, { expr = true, silent = true })

-- -- Copilot Navigation
-- vim.keymap.set("i", "<C-l>", "<Plug>(copilot-next)")
-- vim.keymap.set("i", "<C-h>", "<Plug>(copilot-previous)")
-- vim.keymap.set("i", "<C-e>", "<Plug>(copilot-dismiss)")

-- -- Toggle AI Mode
-- vim.keymap.set("n", "<leader>ai", function()
--   if vim.g.copilot_enabled then
--     vim.cmd("Copilot disable")
--     vim.g.copilot_enabled = false
--     vim.g.blink_cmp_enabled = true
--     print("Copilot OFF | blink ON")
--   else
--     vim.cmd("Copilot enable")
--     vim.g.copilot_enabled = true
--     vim.g.blink_cmp_enabled = false
--     print("Copilot ON | blink OFF")
--   end
-- end, { desc = "Toggle Copilot / blink" })

vim.api.nvim_create_user_command("LspInfo", function()
  local clients = vim.lsp.get_clients({ bufnr = 0 })

  if vim.tbl_isempty(clients) then
    vim.notify("No active LSP clients", vim.log.levels.INFO)
    return
  end

  local buf = vim.api.nvim_get_current_buf()
  local lines = {}

  table.insert(lines, "Active LSP clients (buffer " .. buf .. "):\n")

  for _, client in ipairs(clients) do
    -- SICHERER AUFRUF: pcall verhindert, dass nvim-java/jdtls alles zum Absturz bringt
    local success, cmd_list = pcall(function()
      local raw = client.config.cmd
      if type(raw) == "function" then
        return raw()
      end
      return raw
    end)

    -- Fallback, falls der Aufruf fehlschlägt oder kein Table kommt
    if not success or type(cmd_list) ~= "table" then
      cmd_list = { "Befehl konnte nicht gelesen werden (LSP geschützt)" }
    end

    table.insert(lines, "• Name: " .. client.name)
    table.insert(lines, "  id: " .. client.id)
    table.insert(lines, "  root: " .. (client.config.root_dir or "nil"))
    table.insert(lines, "  cmd: " .. table.concat(cmd_list, " "))
    table.insert(lines, "")
  end

  vim.notify(table.concat(lines, "\n"), vim.log.levels.INFO, {
    title = "LSP Info",
  })
end, {})

vim.api.nvim_create_user_command("LspClient", function()
  vim.cmd("checkhealth lsp")
end, {})

vim.api.nvim_create_user_command("LspClient", function()
  vim.cmd("checkhealth lsp")
end, {})
