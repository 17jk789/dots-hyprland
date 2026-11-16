-- config/autocmds-vscode.lua
-- VS Code-specific filetype mappings. Native :terminal commands from the
-- original autocmds.lua are intentionally not loaded in vscode-neovim.

local runner = require("config.runner")
local group = vim.api.nvim_create_augroup("UserVSCodeFiletypeTasks", { clear = true })

local function map_cmd(buf, lhs, command, desc, opts)
  opts = opts or {}
  vim.keymap.set("n", lhs, function()
    runner.run(command, desc, opts)
  end, {
    buffer = buf,
    silent = true,
    desc = desc,
  })
end

local function map_fn(buf, lhs, callback, desc)
  vim.keymap.set("n", lhs, callback, {
    buffer = buf,
    silent = true,
    desc = desc,
  })
end

local function shellquote(value)
  return vim.fn.shellescape(tostring(value))
end

local function file_path()
  return vim.fn.expand("%:p")
end

local function file_dir()
  return vim.fn.expand("%:p:h")
end

local function file_base()
  return vim.fn.expand("%:t:r")
end

-- C / C++ / CMake -----------------------------------------------------------
vim.api.nvim_create_autocmd("FileType", {
  group = group,
  pattern = { "c", "cpp", "cmake" },
  callback = function(ev)
    local buf = ev.buf

    -- CMake project commands. Clean reconfigure checks for CMakeLists.txt
    -- before deleting only the generated build directory.
    map_cmd(buf, "<leader>rra",
      "test -f CMakeLists.txt || { echo 'CMakeLists.txt not found in the workspace root'; exit 2; }; "
        .. "cmake -S . -B build -DCMAKE_EXPORT_COMPILE_COMMANDS=ON "
        .. "&& cmake --build build "
        .. "&& if [ -x build/app ]; then ./build/app; "
        .. "else echo 'Build succeeded, but build/app does not exist; adjust the executable path'; exit 3; fi",
      "CMake Configure + Build + Run")

    map_cmd(buf, "<leader>rrr",
      "test -x build/app && ./build/app || { echo 'build/app not found; build the project first or adjust the executable path'; exit 1; }",
      "Run CMake Binary")

    map_cmd(buf, "<leader>rrb", "cmake --build build", "CMake Build")
    map_cmd(buf, "<leader>rrc",
      "cmake -S . -B build -DCMAKE_EXPORT_COMPILE_COMMANDS=ON",
      "CMake Configure")
    map_cmd(buf, "<leader>rrd",
      "cmake -S . -B build -DCMAKE_BUILD_TYPE=Debug -DCMAKE_EXPORT_COMPILE_COMMANDS=ON",
      "CMake Configure Debug")
    map_cmd(buf, "<leader>rrR",
      "cmake -S . -B build -DCMAKE_BUILD_TYPE=Release -DCMAKE_EXPORT_COMPILE_COMMANDS=ON",
      "CMake Configure Release")
    map_cmd(buf, "<leader>rrt",
      "ctest --test-dir build",
      "CMake Tests")
    map_cmd(buf, "<leader>rrT",
      "ctest --test-dir build --output-on-failure",
      "CMake Tests with Output")
    map_fn(buf, "<leader>rrf", function()
      local test_name = vim.fn.expand("<cword>")
      if test_name == "" then
        vim.notify("No test name under cursor.", vim.log.levels.WARN)
        return
      end
      runner.run("ctest --test-dir build -R " .. shellquote(test_name) .. " --output-on-failure",
        "CMake: Run Selected Test")
    end, "CMake Run Selected Test")

    map_cmd(buf, "<leader>rrx",
      "test -f CMakeLists.txt && rm -rf -- build",
      "CMake Clean Build Directory")
    map_cmd(buf, "<leader>rrA",
      "test -f CMakeLists.txt || { echo 'Refusing: CMakeLists.txt not found in workspace root'; exit 2; }; "
        .. "rm -rf -- build && cmake -S . -B build -DCMAKE_EXPORT_COMPILE_COMMANDS=ON",
      "CMake Clean Reconfigure")

    -- Only Git-tracked source files are formatted/analyzed; generated build
    -- trees and vendored, untracked files are not swept accidentally.
    map_cmd(buf, "<leader>rrF",
      "git ls-files -z -- '*.c' '*.h' '*.cc' '*.cpp' '*.hh' '*.hpp' | xargs -0 -r clang-format -i",
      "Clang Format Tracked C/C++ Files")
    map_cmd(buf, "<leader>rrl",
      "git ls-files -z -- '*.cpp' '*.cc' | xargs -0 -r -n1 clang-tidy -p build",
      "Clang Tidy Tracked C++ Files")
    map_cmd(buf, "<leader>rrv",
      "cmake --build build && valgrind --leak-check=full --show-leak-kinds=all ./build/app",
      "Valgrind CMake Binary")
    map_cmd(buf, "<leader>rrs",
      "cmake -S . -B build-asan -DCMAKE_BUILD_TYPE=Debug -DCMAKE_C_FLAGS='-fsanitize=address -g' -DCMAKE_CXX_FLAGS='-fsanitize=address -g' "
        .. "&& cmake --build build-asan && ./build-asan/app",
      "AddressSanitizer Build + Run")
    map_cmd(buf, "<leader>rru",
      "cmake -S . -B build-ubsan -DCMAKE_BUILD_TYPE=Debug -DCMAKE_C_FLAGS='-fsanitize=undefined -g' -DCMAKE_CXX_FLAGS='-fsanitize=undefined -g' "
        .. "&& cmake --build build-ubsan && ./build-ubsan/app",
      "UndefinedBehaviorSanitizer Build + Run")
    map_cmd(buf, "<leader>rrP",
      "cmake --build build && perf record -g ./build/app && perf report",
      "Perf Profile CMake Binary")
    map_cmd(buf, "<leader>rrgp",
      "cmake --build build && gprof ./build/app gmon.out | head -30",
      "GProf Analysis")

    -- Keep the per-file C/C++ compiler runners as alternatives to CMake.
    if vim.bo[buf].filetype == "c" then
      map_fn(buf, "<leader>rcr", function()
        local file, dir, base = file_path(), file_dir(), file_base()
        vim.cmd("write")
        local cmd = "cd " .. shellquote(dir)
          .. " && gcc -std=c17 -Wall -Wextra -g " .. shellquote(file)
          .. " -o " .. shellquote(base) .. " && ./" .. shellquote(base)
        runner.run(cmd, "GCC Compile + Run")
      end, "GCC Compile + Run")
      map_cmd(buf, "<leader>rco",
        "gcc -O2 -Wall -Wextra " .. shellquote(file_path()) .. " -o " .. shellquote(file_base())
          .. " && ./" .. shellquote(file_base()),
        "GCC Optimized Compile + Run",
        { cwd = file_dir() })
      map_cmd(buf, "<leader>rcc",
        "gcc -c " .. shellquote(file_path()),
        "GCC Compile Only",
        { cwd = file_dir() })
    elseif vim.bo[buf].filetype == "cpp" then
      map_fn(buf, "<leader>rpr", function()
        local file, dir, base = file_path(), file_dir(), file_base()
        vim.cmd("write")
        local cmd = "cd " .. shellquote(dir)
          .. " && g++ -std=c++20 -Wall -Wextra -g " .. shellquote(file)
          .. " -o " .. shellquote(base) .. " && ./" .. shellquote(base)
        runner.run(cmd, "G++ Compile + Run")
      end, "G++ Compile + Run")
      map_cmd(buf, "<leader>rpo",
        "g++ -O2 -Wall -Wextra -std=c++20 " .. shellquote(file_path()) .. " -o " .. shellquote(file_base())
          .. " && ./" .. shellquote(file_base()),
        "G++ Optimized Compile + Run",
        { cwd = file_dir() })
      map_cmd(buf, "<leader>rpc",
        "g++ -c " .. shellquote(file_path()),
        "G++ Compile Only",
        { cwd = file_dir() })
    end

    map_fn(buf, "<leader>rrCM", function()
      vim.cmd("edit CMakeLists.txt")
    end, "Open CMakeLists.txt")
    map_fn(buf, "<leader>rrC", function()
      vim.cmd("edit build/CMakeCache.txt")
    end, "Open CMakeCache")
  end,
})

-- Rust ----------------------------------------------------------------------
vim.api.nvim_create_autocmd("FileType", {
  group = group,
  pattern = "rust",
  callback = function(ev)
    local buf = ev.buf
    map_cmd(buf, "<leader>rrr", "cargo run", "Cargo Run")
    map_cmd(buf, "<leader>rrb", "cargo build", "Cargo Build")
    map_cmd(buf, "<leader>rra", "cargo build && cargo run", "Cargo Build + Run")
    map_cmd(buf, "<leader>rrR", "cargo run --release", "Cargo Run Release")
    map_cmd(buf, "<leader>rrBR", "cargo build --release", "Cargo Build Release")
    map_cmd(buf, "<leader>rrc", "cargo check --all-targets", "Cargo Check")
    map_cmd(buf, "<leader>rrl", "cargo clippy --all-targets --all-features -- -D warnings", "Cargo Clippy")
    map_cmd(buf, "<leader>rrFs", "cargo fmt --all", "Cargo Format")
    map_cmd(buf, "<leader>rrt", "cargo test --lib", "Cargo Test Library")
    map_cmd(buf, "<leader>rrT", "cargo test --all-targets --all-features", "Cargo Test All")
    map_cmd(buf, "<leader>rrn", "cargo nextest run", "Cargo Nextest")
    map_cmd(buf, "<leader>rrAr", "cargo audit", "Cargo Audit")
    map_cmd(buf, "<leader>rrAd", "cargo deny check", "Cargo Deny Check")
    map_cmd(buf, "<leader>rrAf", "cargo audit fix", "Cargo Audit Fix (modifies dependencies)")
    map_cmd(buf, "<leader>rrxc", "cargo clean", "Cargo Clean")
    map_cmd(buf, "<leader>rrd", "cargo doc --open", "Cargo Documentation")
    map_cmd(buf, "<leader>rrBB", "cargo bench", "Cargo Bench")
    map_cmd(buf, "<leader>rrw", 'cargo watch -x "check"', "Cargo Watch Check")
    map_cmd(buf, "<leader>rrWw", 'cargo watch -x "test"', "Cargo Watch Test")
    map_cmd(buf, "<leader>rrts", "cargo +nightly miri test", "Cargo Miri (Nightly)")
    map_cmd(buf, "<leader>rrAA", "cargo run -- --help", "Cargo Run with Help")
  end,
})

-- Python --------------------------------------------------------------------
vim.api.nvim_create_autocmd("FileType", {
  group = group,
  pattern = "python",
  callback = function(ev)
    local buf = ev.buf

    local function python_executable()
      local dir = file_dir()
      local current = dir

      while current and current ~= "" do
        for _, candidate in ipairs({
          current .. "/.venv/bin/python",
          current .. "/venv/bin/python",
          current .. "/env/bin/python",
        }) do
          if vim.fn.executable(candidate) == 1 then
            return candidate
          end
        end

        local parent = vim.fn.fnamemodify(current, ":h")
        if parent == current or current == "/" then
          break
        end
        current = parent
      end

      if vim.env.VIRTUAL_ENV and vim.fn.executable(vim.env.VIRTUAL_ENV .. "/bin/python") == 1 then
        return vim.env.VIRTUAL_ENV .. "/bin/python"
      end
      return vim.fn.executable("python3") == 1 and "python3" or "python"
    end

    map_fn(buf, "<leader>rra", function()
      local py = python_executable()
      local file = file_path()
      vim.cmd("write")
      runner.run(shellquote(py) .. " " .. shellquote(file), "Python Run (Project Venv)")
    end, "Python Run (Project Venv)")
    map_cmd(buf, "<leader>rrpy", "python3 " .. shellquote(file_path()), "Python Run Current File")
    map_cmd(buf, "<leader>rrt", "pytest", "Pytest")
    map_cmd(buf, "<leader>rrrT", "pytest " .. shellquote(file_path()), "Pytest Current File")
    map_cmd(buf, "<leader>rrv", "python3 -m venv .venv", "Create Python Virtual Environment")
    map_cmd(buf, "<leader>rll", "ruff check " .. shellquote(file_path()), "Ruff Check")
    map_cmd(buf, "<leader>rlF", "ruff format " .. shellquote(file_path()), "Ruff Format")
    map_cmd(buf, "<leader>rty", "mypy " .. shellquote(file_path()), "Mypy Type Check")
    map_cmd(buf, "<leader>rrbd", "bandit -q " .. shellquote(file_path()), "Bandit Security Scan")
    map_cmd(buf, "<leader>rrp",
      "python3 -m cProfile -s cumtime " .. shellquote(file_path()),
      "Python cProfile")
  end,
})

-- Java ----------------------------------------------------------------------
vim.api.nvim_create_autocmd("FileType", {
  group = group,
  pattern = "java",
  callback = function(ev)
    local buf = ev.buf
    local has_gradle = vim.fn.filereadable("gradlew") == 1
    local has_maven = vim.fn.filereadable("pom.xml") == 1

    if has_gradle then
      map_cmd(buf, "<leader>rra", "./gradlew build && ./gradlew run", "Gradle Build + Run")
      map_cmd(buf, "<leader>rrr", "./gradlew run", "Gradle Run")
      map_cmd(buf, "<leader>rrb", "./gradlew build", "Gradle Build")
      map_cmd(buf, "<leader>rrtt", "./gradlew test", "Gradle Test")
      map_cmd(buf, "<leader>rrtf", "./gradlew test --rerun-tasks", "Gradle Rerun Tests")
      map_cmd(buf, "<leader>rrtdi", "./gradlew test --info", "Gradle Test Info")
    elseif has_maven then
      map_cmd(buf, "<leader>rrr", "mvn exec:java", "Maven Run (requires exec plugin)")
      map_cmd(buf, "<leader>rrb", "mvn clean package", "Maven Build")
      map_cmd(buf, "<leader>rrtt", "mvn test", "Maven Test")
      map_cmd(buf, "<leader>rrc", "mvn clean", "Maven Clean")
    else
      map_cmd(buf, "<leader>rcc",
        "javac " .. shellquote(file_path()),
        "Javac Compile Current File",
        { cwd = file_dir() })
      map_fn(buf, "<leader>rcr", function()
        local file, dir, base = file_path(), file_dir(), file_base()
        runner.run("cd " .. shellquote(dir) .. " && javac " .. shellquote(file)
          .. " && java -cp . " .. shellquote(base), "Javac Compile + Run")
      end, "Javac Compile + Run")
    end

    map_fn(buf, "<leader>rrg", function()
      if vim.fn.filereadable("build.gradle") == 1 or vim.fn.filereadable("build.gradle.kts") == 1 then
        vim.cmd("edit build.gradle")
      elseif has_maven then
        vim.cmd("edit pom.xml")
      end
    end, "Open Java Build File")
  end,
})

-- JavaScript / TypeScript ---------------------------------------------------
vim.api.nvim_create_autocmd("FileType", {
  group = group,
  pattern = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
  callback = function(ev)
    local buf = ev.buf

    local function get_pm()
      if vim.fn.filereadable("pnpm-lock.yaml") == 1 then
        return "pnpm"
      elseif vim.fn.filereadable("yarn.lock") == 1 then
        return "yarn"
      end
      return "npm"
    end

    local pm = get_pm()
    local add_command = pm == "npm" and "install" or "add"

    map_cmd(buf, "<leader>rpr", "node " .. shellquote(file_path()), "Node Run Current File")
    map_cmd(buf, "<leader>rpt", "tsc " .. shellquote(file_path()) .. " && node " .. shellquote(vim.fn.expand("%:p:r") .. ".js"),
      "TypeScript Compile + Run")
    map_cmd(buf, "<leader>rrb", pm .. " run build", "Package Build (" .. pm .. ")")
    map_cmd(buf, "<leader>rrfd", pm .. " run dev", "Package Dev Server (" .. pm .. ")")
    map_cmd(buf, "<leader>rrt", pm .. " test", "Package Test (" .. pm .. ")")
    map_cmd(buf, "<leader>rrtc", pm .. " test -- --coverage", "Package Test Coverage")
    map_cmd(buf, "<leader>rrl", pm .. " run lint", "Package Lint (" .. pm .. ")")
    map_cmd(buf, "<leader>rri", pm .. " install", "Install Dependencies")
    map_cmd(buf, "<leader>rpf", "npx prettier --write " .. shellquote(file_path()), "Prettier Format Current File")
    map_cmd(buf, "<leader>rty", "tsc --noEmit", "TypeScript Check")

    map_fn(buf, "<leader>rradd", function()
      local package_name = vim.fn.input("Package name: ")
      if package_name == "" then
        return
      end
      runner.run(pm .. " " .. add_command .. " " .. shellquote(package_name), "Add Package")
    end, "Add Package")

    map_fn(buf, "<leader>rrrm", function()
      local package_name = vim.fn.input("Package name: ")
      if package_name == "" then
        return
      end
      local remove_command = pm == "npm" and "uninstall" or "remove"
      runner.run(pm .. " " .. remove_command .. " " .. shellquote(package_name), "Remove Package")
    end, "Remove Package")
  end,
})

-- Go ------------------------------------------------------------------------
vim.api.nvim_create_autocmd("FileType", {
  group = group,
  pattern = "go",
  callback = function(ev)
    local buf = ev.buf
    map_cmd(buf, "<leader>rpr", "go run " .. shellquote(file_path()), "Go Run")
    map_cmd(buf, "<leader>rpb", "go build ./...", "Go Build")
    map_cmd(buf, "<leader>rpt", "go test -v -race ./...", "Go Tests with Race Detector")
    map_cmd(buf, "<leader>rptc", "go test -cover ./...", "Go Test Coverage")
    map_cmd(buf, "<leader>rpB", "go test -bench ./... -benchmem", "Go Benchmarks")
    map_cmd(buf, "<leader>rpl", "golangci-lint run", "Go Lint")
    map_cmd(buf, "<leader>rpmg", "go mod tidy", "Go Mod Tidy")
    map_cmd(buf, "<leader>rpmu", "go get -u ./...", "Go Update Dependencies")
  end,
})

-- Zig -----------------------------------------------------------------------
vim.api.nvim_create_autocmd("FileType", {
  group = group,
  pattern = "zig",
  callback = function(ev)
    local buf = ev.buf
    map_cmd(buf, "<leader>rpr", "zig run " .. shellquote(file_path()), "Zig Run")
    map_cmd(buf, "<leader>rpt", "zig build test", "Zig Tests")
    map_cmd(buf, "<leader>rpf", "zig fmt " .. shellquote(file_path()), "Zig Format")
    map_cmd(buf, "<leader>rpb", "zig build", "Zig Build")
  end,
})

-- HTML ----------------------------------------------------------------------
vim.api.nvim_create_autocmd("FileType", {
  group = group,
  pattern = "html",
  callback = function(ev)
    local buf = ev.buf
    map_cmd(buf, "<leader>rpl", "htmlhint " .. shellquote(file_path()), "HTMLHint")
    map_cmd(buf, "<leader>rpt", "tidy -errors -quiet " .. shellquote(file_path()), "HTML Tidy Check")
    map_cmd(buf, "<leader>rpf", "prettier --write " .. shellquote(file_path()), "Prettier HTML Format")
  end,
})

-- Lua -----------------------------------------------------------------------
vim.api.nvim_create_autocmd("FileType", {
  group = group,
  pattern = "lua",
  callback = function(ev)
    local buf = ev.buf
    map_cmd(buf, "<leader>rpr", "lua " .. shellquote(file_path()), "Lua Run")
    map_cmd(buf, "<leader>rpj", "luajit " .. shellquote(file_path()), "LuaJIT Run")
    map_cmd(buf, "<leader>rpt", "busted", "Busted Tests")
    map_cmd(buf, "<leader>rpl", "luacheck " .. shellquote(file_path()), "LuaCheck")
  end,
})

-- Shell ---------------------------------------------------------------------
vim.api.nvim_create_autocmd("FileType", {
  group = group,
  pattern = { "sh", "bash", "zsh", "fish" },
  callback = function(ev)
    local buf = ev.buf
    local file = shellquote(file_path())
    local ft = vim.bo[buf].filetype

    if ft == "fish" then
      map_cmd(buf, "<leader>rpr", "fish -n " .. file .. " && fish " .. file,
        "Fish Syntax Check + Run")
      map_cmd(buf, "<leader>rpl", "fish -n " .. file, "Fish Syntax Check")
      map_cmd(buf, "<leader>rpf", "fish_indent -w " .. file, "Fish Format")

    elseif ft == "zsh" then
      map_cmd(buf, "<leader>rpr", "zsh -n " .. file .. " && zsh " .. file,
        "Zsh Syntax Check + Run")
      map_cmd(buf, "<leader>rpl", "zsh -n " .. file,
        "Zsh Syntax Check")

    else
      map_cmd(buf, "<leader>rpr", "bash -n " .. file .. " && bash " .. file,
        "Bash Syntax Check + Run")
      map_cmd(buf, "<leader>rpl", "shellcheck " .. file, "ShellCheck")
      map_cmd(buf, "<leader>rpf", "shfmt -w " .. file, "shfmt")
    end
  end,
})

-- Assembly ------------------------------------------------------------------
vim.api.nvim_create_autocmd("FileType", {
  group = group,
  pattern = { "asm", "nasm", "s" },
  callback = function(ev)
    local buf = ev.buf
    local file = shellquote(file_path())
    local base = shellquote(file_base())
    local dir = shellquote(file_dir())
    map_cmd(buf, "<leader>rar",
      "cd " .. dir .. " && nasm -f elf64 " .. file .. " -o " .. base .. ".o && ld " .. base .. ".o -o " .. base .. " && ./" .. base,
      "NASM Assemble + Link + Run")
    map_cmd(buf, "<leader>rad",
      "cd " .. dir .. " && nasm -f elf64 -g -F dwarf " .. file .. " -o " .. base .. ".o && ld " .. base .. ".o -o " .. base,
      "NASM Debug Build")
    map_cmd(buf, "<leader>rac",
      "cd " .. dir .. " && nasm -f elf64 " .. file .. " -o " .. base .. ".o",
      "NASM Compile Only")
    map_cmd(buf, "<leader>ral",
      "cd " .. dir .. " && nasm -f elf64 " .. file .. " -l " .. base .. ".lst",
      "NASM Listing")
  end,
})

-- C# / .NET -----------------------------------------------------------------
vim.api.nvim_create_autocmd("FileType", {
  group = group,
  pattern = "cs",
  callback = function(ev)
    local buf = ev.buf
    map_cmd(buf, "<leader>rar", "dotnet run", ".NET Run")
    map_cmd(buf, "<leader>rra", "dotnet run", ".NET Run")
    map_cmd(buf, "<leader>rad", "dotnet build", ".NET Build")
    map_cmd(buf, "<leader>rac", "dotnet restore", ".NET Restore")
    map_cmd(buf, "<leader>rax", "dotnet clean", ".NET Clean")
    map_cmd(buf, "<leader>rat", "dotnet test", ".NET Test")
  end,
})
