-- config/keymaps-vscode.lua

-- VS Code-specific keymaps for vscode-neovim.
-- Neovim remains the modal editing engine; VS Code owns all editor/LSP UI.
-- This module is intentionally isolated from standalone Neovim keymaps.

if not vim.g.vscode then
  return
end

local ok, vscode = pcall(require, "vscode")
if not ok then
  vim.notify("vscode-neovim Lua API is unavailable.", vim.log.levels.ERROR)
  return
end

-- Use the extension's clipboard bridge; no xclip/wl-clipboard dependency.
if vim.g.vscode_clipboard then
  vim.g.clipboard = vim.g.vscode_clipboard
end
vim.opt.clipboard = "unnamedplus"

-- Keep the existing register policy: yanks go to VS Code/system clipboard,
-- ordinary deletes do not overwrite that clipboard.
vim.keymap.set({ "n", "x" }, "d", '"_d', {
  noremap = true,
  silent = true,
  desc = "Delete to black-hole register",
})
vim.keymap.set("n", "dd", '"_dd', {
  noremap = true,
  silent = true,
  desc = "Delete line to black-hole register",
})
vim.keymap.set({ "n", "v", "o" }, "y", '"+y', {
  noremap = true,
  silent = true,
  desc = "Yank to VS Code clipboard",
})
vim.keymap.set({ "n", "o" }, "yy", '"+yy', {
  noremap = true,
  silent = true,
  desc = "Yank line to VS Code clipboard",
})

local function map(mode, lhs, command, desc)
  vim.keymap.set(mode, lhs, function()
    vscode.action(command)
  end, {
    noremap = true,
    silent = true,
    desc = desc,
  })
end

-- Search and command navigation.
map("n", "<C-p>", "workbench.action.quickOpen", "Quick Open / Find Files")
map("n", "<leader><space>", "workbench.action.quickOpen", "Find Files")
map("n", "<leader>ff", "workbench.action.quickOpen", "Find Files")
map("n", "<C-f>", "actions.find", "Find in Current File")
map("n", "<leader>sg", "workbench.action.findInFiles", "Search in Files")
map("n", "<C-o>", "workbench.action.gotoSymbol", "Go to Document Symbol")
map("n", "<leader>ss", "workbench.action.gotoSymbol", "Document Symbols")
map("n", "<C-S-p>", "workbench.action.showCommands", "Command Palette")

-- VS Code-native language-service navigation. These actions call whichever
-- Marketplace language extension owns the current file type.
map("n", "gd", "editor.action.revealDefinition", "Go to Definition")
map("n", "gD", "editor.action.peekDefinition", "Peek Definition")
map("n", "gr", "editor.action.referenceSearch.trigger", "Find References")
map("n", "gI", "editor.action.goToImplementation", "Go to Implementation")
map("n", "gy", "editor.action.goToTypeDefinition", "Go to Type Definition")
map("n", "K", "editor.action.showHover", "Hover Documentation")
map("n", "<leader>cd", "editor.action.showHover", "Show Documentation")
map("n", "[d", "editor.action.marker.prev", "Previous Diagnostic")
map("n", "]d", "editor.action.marker.next", "Next Diagnostic")
map({ "n", "x" }, "<leader>ca", "editor.action.quickFix", "Code Action / Quick Fix")

-- Formatting is performed by the formatter selected in settings.json.
map("n", "<leader>cf", "editor.action.formatDocument", "Format Document")
map("x", "<leader>cf", "editor.action.formatSelection", "Format Selection")
map("n", "<F2>", "editor.action.rename", "Rename Symbol")
map({ "n", "x" }, "<leader>/", "editor.action.commentLine", "Toggle Comment")

-- VS Code workbench, explorer, problems and terminal.
map("n", "<C-b>", "workbench.action.toggleSidebarVisibility", "Toggle Sidebar")
map("n", "<leader>e", "workbench.view.explorer", "Explorer")
map("n", "<leader>xx", "workbench.actions.view.problems", "Problems")
-- VS Code native Zsh terminals
map("n", "<leader>tt",
  "workbench.action.createTerminalEditor",
  "New Zsh Terminal Editor")

map("n", "<leader>tT",
  "workbench.action.terminal.toggleTerminal",
  "Toggle Zsh Terminal")

map("n", "<leader>ft",
  "workbench.action.terminal.toggleTerminal",
  "Toggle Terminal")

map("n", "<leader>fT",
  "workbench.action.terminal.new",
  "New Terminal")
map("n", "<leader>fR", "workbench.files.action.showActiveFileInExplorer", "Reveal File in Explorer")

-- VS Code editor tabs replace BufferLine's visual tab UI.
map("n", "H", "workbench.action.previousEditor", "Previous Editor")
map("n", "L", "workbench.action.nextEditor", "Next Editor")
map("n", "<leader>bp", "workbench.action.previousEditor", "Previous Editor")
map("n", "<leader>bn", "workbench.action.nextEditor", "Next Editor")
map("n", "<leader>bd", "workbench.action.closeActiveEditor", "Close Editor")
map("n", "<leader>ba", "workbench.action.closeAllEditors", "Close All Editors")

-- Save and Git are handled by VS Code.
map("n", "<C-s>", "workbench.action.files.save", "Save")
map("n", "<leader>ws", "workbench.action.files.saveAll", "Save All")
map("n", "<leader>gG", "workbench.view.scm", "Source Control")

-- VS Code debugger replaces nvim-dap only in this environment.
map("n", "<leader>du", "workbench.view.debug", "Run and Debug")
map("n", "<leader>dr", "workbench.debug.action.focusRepl", "Debug Console")
map("n", "<F5>", "workbench.action.debug.start", "Start / Continue Debugging")
map("n", "<F9>", "editor.debug.action.toggleBreakpoint", "Toggle Breakpoint")
map("n", "<F10>", "workbench.action.debug.stepOver", "Debug Step Over")
map("n", "<F11>", "workbench.action.debug.stepInto", "Debug Step Into")
map("n", "<F12>", "workbench.action.debug.stepOut", "Debug Step Out")
