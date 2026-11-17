-- config/vscode-options.lua

-- VS Code mode: VS Code owns the workbench and language tooling; Neovim owns
-- modal editing and the Ex command line.

if not vim.g.vscode then
  return
end

if vim.g.vscode_clipboard then
  vim.g.clipboard = vim.g.vscode_clipboard
  vim.opt.clipboard = "unnamedplus"
end

local vscode = require("vscode")

local function define_user_command(name, callback, opts)
  -- Makes re-sourcing the configuration safe without touching builtin commands.
  pcall(vim.api.nvim_del_user_command, name)
  vim.api.nvim_create_user_command(name, callback, opts)
end

define_user_command("Term", function()
  vscode.action("workbench.action.createTerminalEditor")
end, { nargs = 0, desc = "Create VS Code terminal editor" })

define_user_command("TermPanel", function()
  vscode.action("workbench.action.terminal.new")
end, { nargs = 0, desc = "Create VS Code terminal in panel" })

define_user_command("TermToggle", function()
  vscode.action("workbench.action.terminal.toggleTerminal")
end, { nargs = 0, desc = "Toggle VS Code terminal panel" })

-- Command-line completion is deliberately Tab-driven. Do not call wildtrigger
-- on every CmdlineChanged event: that can mutate partial user commands and
-- interferes with substitute/search command-lines such as :%s/old/new/gc.
vim.opt.wildmenu = true
vim.opt.wildmode = "longest:full,full"
vim.opt.wildoptions = "pum"
vim.opt.pumheight = 12
vim.opt.pumblend = 0
vim.opt.wildignorecase = true
vim.opt.history = 1000
