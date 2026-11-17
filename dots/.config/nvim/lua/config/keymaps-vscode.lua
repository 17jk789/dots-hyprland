-- config/keymaps-vscode.lua
-- VS Code owns the IDE UI and all language services. Neovim supplies modal editing.

if not vim.g.vscode then
  return
end

local ok, vscode = pcall(require, "vscode")
if not ok then
  vim.notify("vscode-neovim Lua API is unavailable.", vim.log.levels.ERROR)
  return
end

if vim.g.vscode_clipboard then
  vim.g.clipboard = vim.g.vscode_clipboard
  vim.opt.clipboard = "unnamedplus"
end

-- Keep deletes out of the system clipboard; explicit yanks go to VS Code.
vim.keymap.set({ "n", "x" }, "d", '"_d', { noremap = true, silent = true, desc = "Delete without changing clipboard" })
vim.keymap.set("n", "dd", '"_dd', { noremap = true, silent = true, desc = "Delete line without changing clipboard" })
vim.keymap.set({ "n", "x" }, "y", '"+y', { noremap = true, silent = true, desc = "Yank to VS Code clipboard" })
vim.keymap.set("n", "yy", '"+yy', { noremap = true, silent = true, desc = "Yank line to VS Code clipboard" })

local function map(mode, lhs, command, desc)
  vim.keymap.set(mode, lhs, function()
    vscode.action(command)
  end, { noremap = true, silent = true, desc = desc })
end

-- Search / command navigation.
map("n", "<C-p>", "workbench.action.quickOpen", "Quick Open / Find Files")
map("n", "<leader><space>", "workbench.action.quickOpen", "Quick Open / Find Files")
map("n", "<leader>ff", "workbench.action.quickOpen", "Find Files")
map("n", "<C-f>", "actions.find", "Find in Current File")
map("n", "<leader>sg", "workbench.action.findInFiles", "Search in Files")
map("n", "<C-o>", "workbench.action.gotoSymbol", "Go to Document Symbol")
map("n", "<leader>ss", "workbench.action.gotoSymbol", "Document Symbols")
map("n", "<C-S-p>", "workbench.action.showCommands", "Command Palette")

-- These actions use the currently active VS Code language extension.
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
map("n", "<leader>cf", "editor.action.formatDocument", "Format Document")
map("x", "<leader>cf", "editor.action.formatSelection", "Format Selection")
map("n", "<F2>", "editor.action.rename", "Rename Symbol")
map({ "n", "x" }, "<leader>/", "editor.action.commentLine", "Toggle Comment")

-- VS Code workbench views. Keep these as Neovim mappings so every LazyVim
-- leader sequence is still handled by Neovim (VS Code supports only 2-key chords).
map("n", "<C-b>", "workbench.action.toggleSidebarVisibility", "Toggle Sidebar")
-- Stateful same-key toggles for views that need a specific open command.
-- Use these shortcuts consistently; mouse-driven view changes are not observable
-- through the public vscode-neovim Lua API and therefore cannot sync this state.
local view_open = {}
local function toggle_view(lhs, state_key, open_command, close_command, desc)
  vim.keymap.set("n", lhs, function()
    if view_open[state_key] then
      vscode.action(close_command)
    else
      vscode.action(open_command)
    end
    view_open[state_key] = not view_open[state_key]
  end, { noremap = true, silent = true, desc = desc })
end

toggle_view("<leader>n", "explorer", "workbench.view.explorer", "workbench.action.toggleSidebarVisibility", "Toggle Explorer")
toggle_view("<leader>e", "explorer", "workbench.view.explorer", "workbench.action.toggleSidebarVisibility", "Toggle Explorer")
toggle_view("<leader>xx", "problems", "workbench.actions.view.problems", "workbench.action.togglePanel", "Toggle Problems Panel")
toggle_view("<leader>gG", "scm", "workbench.view.scm", "workbench.action.toggleSidebarVisibility", "Toggle Source Control View")
toggle_view("<leader>du", "debug", "workbench.view.debug", "workbench.action.toggleSidebarVisibility", "Toggle Debug View")
vim.api.nvim_create_user_command("VSCodeToggleStateReset", function()
  for key in pairs(view_open) do
    view_open[key] = nil
  end
  vim.notify("VS Code view-toggle state reset.", vim.log.levels.INFO)
end, { desc = "Reset keyboard-driven VS Code view toggle state" })
map("n", "<leader>dr", "workbench.debug.action.focusRepl", "Debug Console")
map("n", "<F6>", "workbench.debug.action.focusRepl", "Debug Console")

-- Terminal: tt creates an editor terminal; tT / ft toggle the bottom panel.
map("n", "<leader>tt", "workbench.action.createTerminalEditor", "New Terminal Editor")
map("n", "<leader>tT", "workbench.action.terminal.toggleTerminal", "Toggle Terminal Panel")
map("n", "<leader>ft", "workbench.action.terminal.toggleTerminal", "Toggle Terminal Panel")
map("n", "<leader>fT", "workbench.action.terminal.new", "New Terminal Panel")
map("n", "<leader>fR", "workbench.files.action.showActiveFileInExplorer", "Reveal Active File")

-- VS Code editor tabs replace a separate BufferLine UI.
map("n", "H", "workbench.action.previousEditor", "Previous Editor")
map("n", "L", "workbench.action.nextEditor", "Next Editor")
map("n", "<leader>bp", "workbench.action.previousEditor", "Previous Editor")
map("n", "<leader>bn", "workbench.action.nextEditor", "Next Editor")
map("n", "<leader>bd", "workbench.action.closeActiveEditor", "Close Editor")
map("n", "<leader>ba", "workbench.action.closeAllEditors", "Close All Editors")

map("n", "<C-s>", "workbench.action.files.save", "Save")
map("n", "<leader>ws", "workbench.action.files.saveAll", "Save All")

-- VS Code debugger replaces nvim-dap in this environment.
map("n", "<F5>", "workbench.action.debug.start", "Start / Continue Debugging")
map("n", "<F9>", "editor.debug.action.toggleBreakpoint", "Toggle Breakpoint")
map("n", "<F10>", "workbench.action.debug.stepOver", "Debug Step Over")
map("n", "<F11>", "workbench.action.debug.stepInto", "Debug Step Into")
map("n", "<F12>", "workbench.action.debug.stepOut", "Debug Step Out")
