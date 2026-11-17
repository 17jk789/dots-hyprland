-- config/runner.lua

-- Shared explicit task runner:
--   * Standalone Neovim: native terminal split.
--   * VS Code: integrated terminal using terminal.integrated.defaultProfile.
-- Commands run only after an explicit keypress and with the user's permissions.

local M = {}

local function notify(message, level)
  vim.notify(message, level or vim.log.levels.INFO, { title = "Task Runner" })
end

local function run_native(command, opts)
  opts = opts or {}
  vim.cmd("botright 14split")

  local argv = { vim.o.shell }
  local shell_flags = vim.split(vim.o.shellcmdflag or "-c", "%s+", { trim = true })
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

  -- Pass command/cwd/title as arguments, never interpolate them into JS source.
  local js = [[
    const editor = vscode.window.activeTextEditor;
    const editorFolder = editor
      ? vscode.workspace.getWorkspaceFolder(editor.document.uri)
      : undefined;
    const firstFolder = vscode.workspace.workspaceFolders?.[0];
    const cwd = args.cwd || editorFolder?.uri.fsPath || firstFolder?.uri.fsPath;
    const activeTerminal = vscode.window.activeTerminal;
    const location = activeTerminal
      ? { parentTerminal: activeTerminal }
      : undefined;

    // Omitting shellPath/shellArgs makes VS Code use the user's configured
    // terminal.integrated.defaultProfile.linux (Zsh in this setup).
    const terminal = vscode.window.createTerminal({
      name: args.title || "Neovim Task",
      cwd,
      location,
      // Use Zsh as the default shell for VS Code task execution.
      // Zsh provides reliable POSIX-compatible command syntax
      // while supporting the user's preferred Zsh environment.
      shellPath: "/usr/bin/zsh",
      shellArgs: ["--login", "-f", "-i"],
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
