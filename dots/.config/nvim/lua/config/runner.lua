-- lua/config/runner.lua
--
-- One command runner for BOTH environments:
--   * Standalone Neovim: opens a native terminal split.
--   * VS Code + vscode-neovim: creates a visible VS Code integrated terminal.
--
-- Commands are only executed after an explicit keypress. They run with the
-- current user's permissions; this is not a sandbox.

local M = {}

local function notify(message, level)
  vim.notify(message, level or vim.log.levels.INFO, { title = "Task Runner" })
end

local function run_native(command, opts)
  opts = opts or {}

  vim.cmd("botright 14split")

  local shell = vim.o.shell
  local shell_flags = vim.split(vim.o.shellcmdflag or "-c", "%s+", { trim = true })
  local argv = { shell }

  vim.list_extend(argv, shell_flags)
  table.insert(argv, command)

  local job = vim.fn.termopen(argv, {
    cwd = opts.cwd,
    env = opts.env,
    on_exit = opts.on_exit,
  })

  if job <= 0 then
    notify("Could not start terminal process.", vim.log.levels.ERROR)
    return nil
  end

  vim.cmd("startinsert")
  return job
end

local function run_vscode(command, title, opts)
  local ok, vscode = pcall(require, "vscode")
  if not ok then
    notify("The vscode-neovim Lua API is unavailable.", vim.log.levels.ERROR)
    return nil
  end

  opts = opts or {}

  -- Arguments are passed separately to vscode.eval_async; the command is
  -- never interpolated into JavaScript source.
  local js = [[
    const editor = vscode.window.activeTextEditor;
    const editorFolder = editor
      ? vscode.workspace.getWorkspaceFolder(editor.document.uri)
      : undefined;
    const firstFolder = vscode.workspace.workspaceFolders?.[0];
    const cwd = args.cwd || editorFolder?.uri.fsPath || firstFolder?.uri.fsPath;
    const activeTerminal = vscode.window.activeTerminal;

    // If a terminal is already active, split beside it (the closest VS Code
    // equivalent to the original `:split | terminal ...` workflow). Otherwise
    // use the configured default terminal location.
    const location = activeTerminal
      ? { parentTerminal: activeTerminal }
      : undefined;

    const terminal = vscode.window.createTerminal({
      name: args.title || "Neovim Task",
      cwd,
      location,
      // Use bash for predictable POSIX command syntax, even when the user's
      // normal integrated-terminal profile is fish.
      shellPath: "/usr/bin/bash",
      shellArgs: ["--noprofile", "--norc", "-i"],
    });

    terminal.show(false);
    terminal.sendText(args.command, true);
    return true;
  ]]

  vscode.eval_async(js, {
    args = {
      command = command,
      title = title or "Neovim Task",
      cwd = opts.cwd,
    },
    callback = function(err)
      if err then
        vim.schedule(function()
          notify("VS Code terminal error: " .. tostring(err), vim.log.levels.ERROR)
        end)
      end
    end,
  })

  return true
end

---Run a shell command in the current project context.
---@param command string
---@param title? string
---@param opts? table { cwd?: string, env?: table, on_exit?: function }
---@return integer|boolean|nil
function M.run(command, title, opts)
  if type(command) ~= "string" or command == "" then
    notify("Empty command rejected.", vim.log.levels.ERROR)
    return nil
  end

  opts = opts or {}

  if vim.g.vscode then
    return run_vscode(command, title, opts)
  end

  return run_native(command, opts)
end

return M
