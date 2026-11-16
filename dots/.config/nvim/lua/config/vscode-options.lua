-- config/vscode-options.lua

-- Native Neovim command-line completion inside VS Code + vscode-neovim.
-- Load this after your normal/shared options.

if not vim.g.vscode then
  return
end

-- Use VS Code's clipboard bridge instead of depending on xclip/wl-clipboard.
if vim.g.vscode_clipboard then
  vim.g.clipboard = vim.g.vscode_clipboard
end

-- Automatically use system clipboard for yank, delete and paste
vim.opt.clipboard = "unnamedplus"

-- VS Code API
local vscode = require("vscode")

-- :Term -> Terminal as editor
vim.api.nvim_create_user_command("Term", function()
  vscode.action("workbench.action.createTerminalEditor")
end, { desc = "Open VS Code terminal in editor" })

-- :TermPanel -> Terminal in bottom panel
vim.api.nvim_create_user_command("TermPanel", function()
  vscode.action("workbench.action.terminal.new")
end, { desc = "Open VS Code terminal in panel" })

-- Neovim command-line completion:
--   :set nu  -> popup suggestions
--   :edit    -> path completion
--   :help    -> help-tag completion
-- This is Neovim's command-line wildmenu, not the Insert-mode IntelliSense popup.
vim.opt.wildmenu = true
vim.opt.wildmode = "noselect:lastused,full"
vim.opt.wildoptions = "pum"
vim.opt.pumheight = 12
vim.opt.pumblend = 0
vim.opt.wildignorecase = true

-- Neovim 0.12+ live command completion
if vim.fn.exists("*wildtrigger") == 1 then
  local group = vim.api.nvim_create_augroup(
    "VSCodeNeovimCmdlineCompletion",
    { clear = true }
  )

  vim.api.nvim_create_autocmd("CmdlineChanged", {
    group = group,
    pattern = ":",
    callback = function()
      pcall(vim.fn.wildtrigger)
    end,
  })
end

-- A predictable command-line height and useful history.
vim.opt.history = 1000
