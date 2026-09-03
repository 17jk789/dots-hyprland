-- config/autocmds.lua

-- Rust: format on save
-- vim.api.nvim_create_autocmd("BufWritePre", {
--   pattern = "*.rs",
--   callback = function()
--     vim.lsp.buf.format({ async = false })
--   end,
-- })

-- vim.api.nvim_create_autocmd("BufWritePre", {
--   pattern = "*.rs",
--   callback = function()
--     vim.lsp.buf.format({
--       async = false,
--       filter = function(client)
--         return client.name == "rust_analyzer"
--       end,
--     })
--   end,
-- })

-- Rust format on save
-- vim.api.nvim_create_autocmd("BufWritePre", {
--   pattern = "*.rs",
--   callback = function()
--     vim.lsp.buf.format({
--       async = false,
--       filter = function(client)
--         return client.name == "rust_analyzer"
--       end,
--     })
--   end,
-- })

-- -- Always end file with newline
-- vim.api.nvim_create_autocmd("BufWritePre", {
--   callback = function()
--     local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
--     if #lines == 0 or lines[#lines] ~= "" then
--       vim.api.nvim_buf_set_lines(0, -1, -1, false, { "" })
--     end
--   end,
-- })

-- vim.api.nvim_create_autocmd("FileType", {
--   pattern = { "markdown", "text", "rust", "c", "cpp", "java", "lua", "latex" },
--   callback = function()
--     vim.opt_local.spell = true
--     vim.opt_local.spelllang = { "en_us" }
--   end,
-- })

local augroup = vim.api.nvim_create_augroup("UserAutocmds", { clear = true })

local opts = { noremap = true, silent = true }

function _G.run_in_term(cmd)
	vim.cmd("split | terminal " .. cmd)
end

-- vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
--   group = vim.api.nvim_create_augroup("WslLineEndings", { clear = true }),
--   pattern = "*",
--   callback = function()
--     local path = vim.fn.expand("%:p")
--     if path:find("^/mnt/") then
--       vim.opt_local.fileformat = "dos"
--     else
--       vim.opt_local.fileformat = "unix"
--     end
--   end,
-- })

vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
	group = vim.api.nvim_create_augroup("WslLineEndings", { clear = true }),
	pattern = "*",
	callback = function(args)
		local buf = args.buf

		if vim.bo[buf].buftype ~= "" then
			return
		end

		local path = vim.api.nvim_buf_get_name(buf)
		if path == "" then
			return
		end

		local format = path:match("^/mnt/") and "dos" or "unix"

		if vim.bo[buf].fileformat ~= format then
			vim.bo[buf].fileformat = format
		end
	end,
})

-- Formatierung beim Speichern:
-- 'async = true' sorgt dafür, dass die LSP-Formatierung **nicht den Editor blockiert**.
-- Der Rust Analyzer formatiert die Datei im Hintergrund, während du weiterarbeiten kannst.
-- Filter stellt sicher, dass nur 'rust_analyzer' die Formatierung übernimmt.
-- vim.api.nvim_create_autocmd("BufWritePre", {
--   group = augroup,
--   pattern = "*.rs",
--   callback = function()
--     vim.lsp.buf.format({
--       async = true,
--       filter = function(client)
--         return client.name == "rust_analyzer"
--       end,
--     })
--   end,
-- })

vim.api.nvim_create_autocmd("FileType", {
	group = augroup,
	pattern = { "markdown", "text", "latex" },
	callback = function()
		vim.opt_local.spell = true
		vim.opt_local.spelllang = { "en_us" }
	end,
})

vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
	pattern = "*.fxml",
	callback = function()
		vim.bo.filetype = "xml"
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	group = augroup,
	pattern = "rust",
	callback = function()
		local opts = { noremap = true, silent = true, buffer = true }

		vim.keymap.set("n", "<leader>rid", function()
			run_in_term("code .")
		end, { desc = "Open Project in VS Code", silent = true, buffer = true })
		vim.keymap.set("n", "<leader>riR", function()
			run_in_term("rustrover .")
		end, { desc = "Open Project in RustRover", silent = true, buffer = true })
		vim.keymap.set("n", "<leader>rir", function()
			run_in_term("clion .")
		end, { desc = "Open Project in Clion", silent = true, buffer = true })

		-- vim.keymap.set("n", "<leader>rra", ":split | terminal cargo build && cargo run<CR>", opts)
		-- vim.keymap.set("n", "<leader>rrr", ":split | terminal cargo run<CR>", opts)
		-- vim.keymap.set("n", "<leader>rrb", ":split | terminal cargo build<CR>", opts)
		-- vim.keymap.set("n", "<leader>rrt", ":split | terminal cargo test<CR>", opts)
		-- vim.keymap.set("n", "<leader>rrc", ":edit Cargo.toml<CR>", opts)

		vim.keymap.set(
			"n",
			"<leader>rcr",
			":split | terminal rustc % -o %:t:r && ./%:t:r<CR>",
			{ desc = "Rustc Run (Split)", silent = true, buffer = true }
		)

		vim.keymap.set(
			"n",
			"<leader>rco",
			":split | terminal rustc % -O -o %:t:r && ./%:t:r<CR>",
			{ desc = "Rustc Run (Split)", silent = true, buffer = true }
		)

		vim.keymap.set(
			"n",
			"<leader>rcd",
			":split | terminal rustc % -g -o %:t:r && ./%:t:r<CR>",
			{ desc = "Rustc Debug Run (Split)", silent = true, buffer = true }
		)

		vim.keymap.set(
			"n",
			"<leader>rcn",
			":split | terminal rustc % -C target-cpu=native -o %:t:r && ./%:t:r<CR>",
			{ desc = "Rustc Native Run (Split)", silent = true, buffer = true }
		)

		vim.keymap.set(
			"n",
			"<leader>rcl",
			":split | terminal rustc % -C lto -o %:t:r && ./%:t:r<CR>",
			{ desc = "Rustc LTO Run (Split)", silent = true, buffer = true }
		)

		vim.keymap.set(
			"n",
			"<leader>rcs",
			":split | terminal rustc % -C strip=symbols -o %:t:r && ./%:t:r<CR>",
			{ desc = "Rustc Strip Run (Split)", silent = true, buffer = true }
		)

		vim.keymap.set(
			"n",
			"<leader>rcp",
			":split | terminal rustc % -C panic=abort -o %:t:r && ./%:t:r<CR>",
			{ desc = "Rustc Panic Abort Run (Split)", silent = true, buffer = true }
		)

		vim.keymap.set(
			"n",
			"<leader>rci",
			":split | terminal rustc % -C incremental=target/ -o %:t:r && ./%:t:r<CR>",
			{ desc = "Rustc Incremental Run (Split)", silent = true, buffer = true }
		)

		vim.keymap.set(
			"n",
			"<leader>rcc",
			":split | terminal rustc % -C codegen-units=1 -o %:t:r && ./%:t:r<CR>",
			{ desc = "Rustc Incremental Run (Split)", silent = true, buffer = true }
		)

		vim.keymap.set(
			"n",
			"<leader>rce",
			":split | terminal rustc % --edition=2021 -o %:t:r && ./%:t:r<CR>",
			{ desc = "Rustc Edition 2021 Run (Split)", silent = true, buffer = true }
		)

		vim.keymap.set(
			"n",
			"<leader>rcw",
			":split | terminal rustc % -D warnings -o %:t:r && ./%:t:r<CR>",
			{ desc = "Rustc Deny Warnings Run (Split)", silent = true, buffer = true }
		)

		vim.keymap.set(
			"n",
			"<leader>rca",
			":split | terminal rustc % --emit=asm<CR>",
			{ desc = "Rustc Emit ASM (Split)", silent = true, buffer = true }
		)

		vim.keymap.set(
			"n",
			"<leader>rcll",
			":split | terminal rustc % --emit=llvm-ir<CR>",
			{ desc = "Rustc Emit LLVM-IR (Split)", silent = true, buffer = true }
		)

		vim.keymap.set(
			"n",
			"<leader>rcoj",
			":split | terminal rustc % --emit=obj<CR>",
			{ desc = "Rustc Emit Object (Split)", silent = true, buffer = true }
		)

		vim.keymap.set(
			"n",
			"<leader>rchk",
			":split | terminal rustc % --emit=metadata<CR>",
			{ desc = "Rustc Emit Metadata (Split)", silent = true, buffer = true }
		)

		vim.keymap.set(
			"n",
			"<leader>rct",
			":split | terminal rustc % --target x86_64-unknown-linux-gnu -o %:t:r<CR>",
			{ desc = "Rustc Target Linux Run (Split)", silent = true, buffer = true }
		)

		vim.keymap.set(
			"n",
			"<leader>rclib",
			":split | terminal rustc % --crate-type=staticlib<CR>",
			{ desc = "Rustc Emit Static Library (Split)", silent = true, buffer = true }
		)

		vim.keymap.set(
			"n",
			"<leader>rcdy",
			":split | terminal rustc % --crate-type=dylib<CR>",
			{ desc = "Rustc Emit Dynamic Library (Split)", silent = true, buffer = true }
		)

		-- Cargo command im Split-Terminal ausführen
		local function my_cargo(cmd)
			vim.cmd("split | terminal cargo " .. cmd)
		end

		-- Run / Build Basics
		vim.keymap.set("n", "<leader>rrr", function()
			my_cargo("run")
		end, { desc = "Cargo Run (Split)", silent = true, buffer = true })
		vim.keymap.set("n", "<leader>rrb", function()
			my_cargo("build")
		end, { desc = "Cargo Build (Split)", silent = true, buffer = true })
		vim.keymap.set("n", "<leader>rra", function()
			my_cargo("build && cargo run")
		end, { desc = "Cargo Build & Run (Split)", silent = true, buffer = true })
		-- Testing: Use Neotest via <leader>rrntr instead

		vim.keymap.set("n", "<leader>rrAar", function()
			local cmd = table.concat({
				"cargo fmt --all -- --check",
				"cargo check --all-targets --all-features",
				"cargo clippy --all-targets --all-features -- -D warnings",
				"cargo test --all-features",
				"cargo audit",
				"cargo deny check",
			}, " && ")

			vim.cmd("split | terminal bash -c " .. vim.fn.shellescape(cmd))
		end, {
			desc = "Rust Full CI Pipeline (Ultimate)",
			silent = true,
			buffer = true,
		})

		vim.keymap.set("n", "<leader>rrAaa", function()
			local cmd = table.concat({
				-- Format & Style
				"cargo fmt --all -- --check",

				-- Static Checks
				"cargo check --all-targets --all-features",
				"cargo clippy --all-targets --all-features -- -D warnings -W clippy::pedantic -W clippy::nursery",

				-- Tests
				"cargo test --all-features --all-targets",

				-- UB / Unsafe Checks (best effort)
				"cargo +nightly miri test",

				-- Dependency Security
				"cargo audit",
				"cargo deny check",

				-- Outdated Dependencies (optional aber sinnvoll)
				"cargo outdated || true",
			}, " && ")

			vim.cmd("split | terminal bash -c " .. vim.fn.shellescape(cmd))
		end, {
			desc = "Rust Ultimate Safety Pipeline",
			silent = true,
			buffer = true,
		})

		-- Release Mode
		vim.keymap.set("n", "<leader>rrR", function()
			my_cargo("run --release")
		end, { desc = "Cargo Run Release (Split)", silent = true, buffer = true })
		vim.keymap.set("n", "<leader>rrBR", function()
			my_cargo("build --release")
		end, { desc = "Cargo Build Release (Split)", silent = true, buffer = true })

		-- Professional Cargo Terminal Runner (Safe)
		local cargo = {
			buf = nil,
			win = nil,
			job = nil,
		}

		-- Terminal Management
		local function is_job_running()
			return cargo.job and vim.fn.jobwait({ cargo.job }, 0)[1] == -1
		end

		local function reset_state()
			cargo.buf = nil
			cargo.win = nil
			cargo.job = nil
		end

		local function open_terminal(height)
			height = height or 20

			vim.cmd("botright " .. height .. "split")
			vim.cmd("terminal")

			cargo.win = vim.api.nvim_get_current_win()
			cargo.buf = vim.api.nvim_get_current_buf()
		end

		local function close_terminal()
			if cargo.win and vim.api.nvim_win_is_valid(cargo.win) then
				vim.api.nvim_win_close(cargo.win, true)
			end
			reset_state()
		end

		-- Core Runner
		local function run_cargo_command(cmd, title)
			if is_job_running() then
				vim.notify("Cargo process already running.", vim.log.levels.WARN)
				return
			end

			-- open_terminal(20)
			cargo.buf = vim.api.nvim_create_buf(false, true) -- scratch buffer
			vim.api.nvim_open_win(cargo.buf, true, {
				relative = "editor",
				width = vim.o.columns,
				height = 20,
				row = vim.o.lines - 20,
				col = 0,
				style = "minimal",
				border = { "─", "─", "─", " ", " ", " ", " ", " " },
			})
			vim.api.nvim_buf_set_name(cargo.buf, "Cargo :: " .. title)

			cargo.job = vim.fn.termopen(cmd, {
				on_exit = function(_, code)
					vim.schedule(function()
						local status = code == 0 and "SUCCESS" or "FAILURE"
						if cargo.buf and vim.api.nvim_buf_is_valid(cargo.buf) then
							vim.api.nvim_buf_set_option(cargo.buf, "modifiable", true)
							vim.api.nvim_buf_set_lines(cargo.buf, -1, -1, false, {
								"",
								"===================================================",
								"Cargo Command  : " .. title,
								"Exit Code      : " .. code,
								"Status         : " .. status,
								"Finished At    : " .. os.date("%Y-%m-%d %H:%M:%S"),
								"===================================================",
								"",
							})
							vim.api.nvim_buf_set_option(cargo.buf, "modifiable", false) -- lock it again
						end
						reset_state()
					end)
				end,
			})
		end

		-- Cargo Test (Optimized: removed --all-targets for faster iteration)
		local function cargo_test(args, show_output)
			show_output = show_output ~= false -- default: true
			local cmd = {
				"env",
				"RUST_BACKTRACE=1",
				"cargo",
				"test",
				"--lib", -- fast: only library tests, not integration/doc
				"--color=always",
				"--",
			}

			if show_output then
				table.insert(cmd, "--nocapture")
			end

			for _, a in ipairs(args or {}) do
				table.insert(cmd, a)
			end

			run_cargo_command(cmd, "cargo test")
		end

		-- Keymaps
		-- Unified test commands (all use cargo_test helper)
		vim.keymap.set("n", "<leader>rrt", function()
			cargo_test({ "--lib" }, true) -- Library tests only, fastest
		end, { desc = "Cargo Test (Lib) - Fast", silent = true, buffer = true })

		vim.keymap.set("n", "<leader>rrT", function()
			cargo_test({ "--all-targets" }, true) -- All tests (lib + integration + doc)
		end, { desc = "Cargo Test (All Targets)", silent = true, buffer = true })

		vim.keymap.set("n", "<leader>rrti", function()
			cargo_test({ "--test", "*" }, true) -- Integration tests only
		end, { desc = "Cargo Test (Integration)", silent = true, buffer = true })

		vim.keymap.set("n", "<leader>rrte", function()
			local testname = vim.fn.expand("<cword>")
			cargo_test({ testname }, true) -- Single test by name
		end, { desc = "Cargo Test (Current)", silent = true, buffer = true })

		vim.keymap.set("n", "<leader>rrtf", function()
			local file = vim.fn.expand("%:t:r")
			cargo_test({ "--test", file }, true) -- Current test file
		end, { desc = "Cargo Test (File)", silent = true, buffer = true })

		-- Coverage (requires cargo-tarpaulin: cargo install cargo-tarpaulin)
		vim.keymap.set("n", "<leader>rrtcov", function()
			my_cargo("tarpaulin --out Html --output-dir ./coverage")
		end, { desc = "Cargo Tarpaulin (Coverage)", silent = true, buffer = true })

		-- Undefined Behavior check (requires nightly: rustup toolchain install nightly)
		vim.keymap.set("n", "<leader>rrts", function()
			my_cargo("+nightly miri test")
		end, { desc = "Cargo Miri (UB Detection)", silent = true, buffer = true })

		-- Show all available tests
		vim.keymap.set("n", "<leader>rrtl", function()
			my_cargo("test -- --list")
		end, { desc = "Cargo Test (List All)", silent = true, buffer = true })

		vim.keymap.set("n", "<leader>rrntr", function()
			require("neotest").run.run()
		end, { desc = "Run Nearest Test" })

		vim.keymap.set("n", "<leader>rrntf", function()
			require("neotest").run.run(vim.fn.expand("%"))
		end, { desc = "Run File Tests" })

		vim.keymap.set("n", "<leader>rrnts", function()
			require("neotest").summary.toggle()
		end, { desc = "Test Summary" })

		vim.keymap.set("n", "<leader>rrnto", function()
			require("neotest").output.open({ enter = true })
		end, { desc = "Test Output" })

		vim.keymap.set("n", "<leader>rrntx", function()
			require("neotest").run.stop()
		end, { desc = "Stop Tests" })

		-- Stop Running Job
		vim.keymap.set("n", "<leader>tnx", function()
			if is_job_running() then
				vim.fn.jobstop(cargo.job)
				vim.notify("Cargo process stopped.", vim.log.levels.INFO)
				reset_state()
			else
				vim.notify("No running Cargo process.", vim.log.levels.INFO)
			end
		end, { desc = "Cargo Stop", buffer = true })

		-- Quickfix Navigation
		vim.keymap.set("n", "<leader>tnp", "<cmd>cwindow<CR>", { desc = "Quickfix Toggle", buffer = true })

		vim.keymap.set("n", "]t", "<cmd>cnext<CR>", { buffer = true })
		vim.keymap.set("n", "[t", "<cmd>cprev<CR>", { buffer = true })

		-- Standard Audit
		vim.keymap.set("n", "<leader>rrAr", function()
			my_cargo("audit")
		end, { desc = "Cargo Audit", silent = true, buffer = true })

		-- Versucht Sicherheitslücken direkt zu beheben (aktualisiert Cargo.toml/lock)
		vim.keymap.set("n", "<leader>rrAf", function()
			my_cargo("audit fix")
		end, { desc = "Cargo Audit Fix", silent = true, buffer = true })

		-- Zeigt auch Warnungen für bereits veraltete (yanked) Crates an
		vim.keymap.set("n", "<leader>rrAy", function()
			my_cargo("audit --yanked")
		end, { desc = "Cargo Audit (Yanked)", silent = true, buffer = true })

		-- Ignoriert die Datenbank-Aktualisierung (schneller, wenn man gerade erst geupdatet hat)
		vim.keymap.set("n", "<leader>rrAn", function()
			my_cargo("audit -n")
		end, { desc = "Cargo Audit (No-Fetch)", silent = true, buffer = true })

		-- Bonus: Cargo Deny (falls installiert, prüft auch Lizenzen und Dubletten)
		vim.keymap.set("n", "<leader>rrAd", function()
			my_cargo("deny check")
		end, { desc = "Cargo Deny Check", silent = true, buffer = true })

		vim.keymap.set("n", "<leader>rrff", function()
			my_cargo("flamegraph")
		end, { desc = "Cargo Flamegraph", silent = true, buffer = true })

		-- Profiling: Samply integration
		vim.keymap.set("n", "<leader>rrfr", function()
			vim.cmd("write")
			vim.fn.jobstart({ "cargo", "build", "--release" }, {
				on_exit = function(_, code)
					if code == 0 then
						vim.fn.jobstart({
							"samply",
							"record",
							"cargo",
							"run",
							"--release",
						}, { detach = true })
					end
				end,
			})
		end, { desc = "Build + Profile (samply)", buffer = true })

		-- Hilfsfunktion um den Projektnamen (Binärdatei) zu finden
		local function get_project_name()
			local toml = vim.fn.findfile("Cargo.toml", ".;")
			if toml ~= "" then
				for line in io.lines(toml) do
					local name = line:match('^name%s*=%s*"(.-)"')
					if name then
						return name
					end
				end
			end
			return nil
		end

		-- Der neue Befehl für Binaries
		vim.keymap.set("n", "<leader>rrAb", function()
			local name = get_project_name()
			if name then
				-- Prüft die Debug-Binary auf Sicherheitslücken
				my_cargo("audit bin target/debug/" .. name)
			else
				print("Cargo.toml nicht gefunden!")
			end
		end, { desc = "Cargo Audit Binary (Debug)", silent = true, buffer = true })

		-- Optional: Audit für die Release-Binary (optimiert)
		vim.keymap.set("n", "<leader>rrAB", function()
			local name = get_project_name()
			if name then
				my_cargo("audit bin target/release/" .. name)
			else
				print("Cargo.toml nicht gefunden!")
			end
		end, { desc = "Cargo Audit Binary (Release)", silent = true, buffer = true })

		-- Benchmarks & Performance
		vim.keymap.set("n", "<leader>rrBB", function()
			my_cargo("bench")
		end, { desc = "Cargo Bench (Split)", silent = true, buffer = true }) -- Alle Benchmarks ausführen

		-- Benchmark-Vergleiche (Erfordert installiertes critcmp)
		-- vim.keymap.set("n", "<leader>rrcc", function()
		--   -- Führt critcmp für die zwei Standard-Baselines aus
		--   vim.cmd("split | term critcmp main feature")
		-- end, opts)

		-- Nextest (falls installiert – deutlich schneller)
		vim.keymap.set("n", "<leader>rrn", function()
			my_cargo("nextest run")
		end, { desc = "Cargo Nextest Run (Split)", silent = true, buffer = true })

		-- Quality / Professional Dev Tools
		vim.keymap.set("n", "<leader>rrc", function()
			my_cargo("check")
		end, { desc = "Cargo Check (Split)", silent = true, buffer = true })
		vim.keymap.set("n", "<leader>rrl", function()
			my_cargo("clippy")
		end, { desc = "Cargo Clippy (Split)", silent = true, buffer = true })
		vim.keymap.set("n", "<leader>rrFs", function()
			my_cargo("fmt")
		end, { desc = "Cargo Format (Split)", silent = true, buffer = true })

		-- Cleanup / Docs / Benchmarks
		vim.keymap.set("n", "<leader>rrxc", function()
			my_cargo("clean")
		end, { desc = "Cargo Clean (Split)", silent = true, buffer = true })
		vim.keymap.set("n", "<leader>rrd", function()
			my_cargo("doc --open")
		end, { desc = "Cargo Doc Open (Split)", silent = true, buffer = true })
		vim.keymap.set("n", "<leader>rrBM", function()
			my_cargo("bench")
		end, { desc = "Cargo Bench (Split)", silent = true, buffer = true })

		-- Cargo Files schnell öffnen
		vim.keymap.set(
			"n",
			"<leader>rrCc",
			":edit Cargo.toml<CR>",
			{ desc = "Edit Cargo.toml (Split)", silent = true, buffer = true }
		)
		vim.keymap.set(
			"n",
			"<leader>rrLl",
			":edit Cargo.lock<CR>",
			{ desc = "Edit Cargo.lock (Split)", silent = true, buffer = true }
		)

		vim.keymap.set("n", "<leader>rrw", function()
			my_cargo('watch -x "check"')
		end, { desc = "Cargo Watch Check", buffer = true })

		vim.keymap.set("n", "<leader>rrWw", function()
			my_cargo('watch -x "test"')
		end, { desc = "Cargo Watch Test", buffer = true })

		vim.keymap.set("n", "<leader>rrAA", function()
			local args = vim.fn.input("Args: ")
			my_cargo("run -- " .. args)
		end, { desc = "Cargo Run with Args", buffer = true })

		vim.keymap.set("n", "<leader>rrAD", function()
			local dep = vim.fn.input("Add crate: ")
			my_cargo("add " .. dep)
		end, { desc = "Cargo Add", buffer = true })

		vim.keymap.set("n", "<leader>rrRD", function()
			local dep = vim.fn.input("Remove crate: ")
			my_cargo("remove " .. dep)
		end, { desc = "Cargo Remove", buffer = true })

		vim.keymap.set("n", "<leader>rrATt", function()
			my_cargo("tree")
		end, { desc = "Cargo Tree", buffer = true })

		vim.keymap.set("n", "<leader>rrATT", function()
			my_cargo("tree -d")
		end, { desc = "Cargo Tree", buffer = true })

		vim.keymap.set("n", "<leader>rrFf", function()
			local feat = vim.fn.input("Features: ")
			my_cargo("run --features " .. feat)
		end, { desc = "Cargo Run Features", buffer = true })

		vim.keymap.set("n", "<leader>rrm", function()
			my_cargo("expand")
		end, { desc = "Cargo Expand", buffer = true })

		vim.keymap.set("n", "<leader>rrAs", function()
			my_cargo("asm")
		end, { desc = "Cargo ASM", buffer = true })

		vim.keymap.set("n", "<leader>rrBl", function()
			my_cargo("bloat --release")
		end, { desc = "Cargo Bloat", buffer = true })

		vim.keymap.set("n", "<leader>rrFx", function()
			my_cargo("fix --allow-dirty --allow-staged")
		end, { desc = "Cargo Fix", buffer = true })

		vim.keymap.set("n", "<leader>rrAcf", function()
			my_cargo("check --lib")
		end, { desc = "Cargo Check (Fast)", buffer = true })

		vim.keymap.set("n", "<leader>rrLog", function()
			vim.cmd("split | terminal RUST_LOG=debug cargo run")
		end, { desc = "Run with Logging", buffer = true })

		vim.keymap.set("n", "<leader>rrWs", function()
			my_cargo("build --workspace")
		end, { desc = "Workspace Build", buffer = true })

		vim.keymap.set("n", "<leader>rrCl", function()
			my_cargo("clippy --fix --allow-dirty")
		end, { desc = "Clippy Fix", buffer = true })

		-- Dependency Management
		vim.keymap.set("n", "<leader>rruD", function()
			my_cargo("+nightly udeps --output json")
		end, { desc = "Cargo Udeps (Unused Deps)", buffer = true })

		vim.keymap.set("n", "<leader>rrtdup", function()
			my_cargo("tree --duplicates")
		end, { desc = "Cargo Tree (Duplicates)", buffer = true })

		vim.keymap.set("n", "<leader>rrVc", function()
			my_cargo("vendor")
		end, { desc = "Cargo Vendor (Offline)", buffer = true })

		vim.keymap.set("n", "<leader>rrUp", function()
			my_cargo("update")
		end, { desc = "Cargo Update Deps", buffer = true })

		-- Workspace Management
		vim.keymap.set("n", "<leader>rrWT", function()
			my_cargo("test --workspace")
		end, { desc = "Workspace Test", buffer = true })

		-- Die Klassiker (Run & Stop)
		-- vim.keymap.set("n", "<leader>tnr", function() require("neotest").run.run() end, { desc = "Test Run (Nearest)", buffer = true })
		-- vim.keymap.set("n", "<leader>tnf", function() require("neotest").run.run(vim.fn.expand("%")) end, { desc = "Test Run (File)", buffer = true })
		-- vim.keymap.set("n", "<leader>tnx", function() require("neotest").run.stop() end, { desc = "Test Stop", buffer = true })

		-- Die UI / Übersicht (Dein Favorit)
		-- vim.keymap.set("n", "<leader>tns", function() require("neotest").summary.toggle() end, { desc = "Test Summary Toggle" })
		-- vim.keymap.set("n", "<leader>tno", function() require("neotest").output.open({ enter = true }) end, { desc = "Test Output (Popup)" })
		-- vim.keymap.set("n", "<leader>tnp", function() require("neotest").output_panel.toggle() end, { desc = "Test Panel (Log unten)" })

		-- Navigation (Schnell zwischen Fehlern springen)
		-- vim.keymap.set("n", "[t", function() require("neotest").jump.prev({ status = "failed" }) end, { desc = "Jump to Prev Failed Test" })
		-- vim.keymap.set("n", "]t", function() require("neotest").jump.next({ status = "failed" }) end, { desc = "Jump to Next Failed Test" })

		-- Watch Mode (Automatisch testen beim Speichern)
		-- (Erfordert nvim-neotest/neotest-watch, falls du das willst)
		-- vim.keymap.set("n", "<leader>tnw", function() require("neotest").watch.toggle(vim.fn.expand("%")) end, { desc = "Test Watch Toggle" })

		vim.keymap.set("n", "<F5>", function()
			require("dap").continue()
		end, opts)

		vim.keymap.set("n", "<F9>", function()
			require("dap").toggle_breakpoint()
		end, opts)

		vim.keymap.set("n", "<F10>", function()
			require("dap").step_over()
		end, opts)

		vim.keymap.set("n", "<F11>", function()
			require("dap").step_into()
		end, opts)

		vim.keymap.set("n", "<F12>", function()
			require("dap").step_out()
		end, opts)
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	group = augroup,
	pattern = "java",
	callback = function()
		local opts = { noremap = true, silent = true, buffer = true }

		local function map_if_free(mode, lhs, rhs)
			if vim.fn.mapcheck(lhs, mode) == "" then
				vim.keymap.set(mode, lhs, rhs, opts)
			end
		end

		vim.keymap.set("n", "<leader>rid", function()
			run_in_term("code .")
		end, { desc = "Open Project in VS Code", silent = true, buffer = true })
		vim.keymap.set("n", "<leader>rir", function()
			run_in_term("idea .")
		end, { desc = "Open Project in Intellij", silent = true, buffer = true })

		-- Achtung: Diese Mappings sind für einfache Java-Dateien gedacht!
		-- Nicht in Gradle-, Maven- oder komplexen Projekten verwenden!

		vim.keymap.set(
			"n",
			"<leader>rcr",
			":split | terminal javac % && java -cp %:p:h %:t:r<CR>",
			{ desc = "Java Compile & Run (Split)", silent = true, buffer = true }
		)

		vim.keymap.set(
			"n",
			"<leader>rcc",
			":split | terminal javac %<CR>",
			{ desc = "Java Compile (Split)", silent = true, buffer = true }
		)

		vim.keymap.set(
			"n",
			"<leader>rcd",
			":split | terminal javac -g % && java -cp %:p:h %:t:r<CR>",
			{ desc = "Java Debug Compile & Run (Split)", silent = true, buffer = true }
		)

		vim.keymap.set(
			"n",
			"<leader>rco",
			":split | terminal javac -d . % && java -cp %:p:h %:t:r<CR>",
			{ desc = "Java Compile to Directory & Run (Split)", silent = true, buffer = true }
		)

		vim.keymap.set(
			"n",
			"<leader>rcl",
			":split | terminal javac -Xlint % && java -cp %:p:h %:t:r<CR>",
			{ desc = "Java Compile Xlint & Run (Split)", silent = true, buffer = true }
		)

		vim.keymap.set(
			"n",
			"<leader>rcw",
			":split | terminal javac -Werror % && java -cp %:p:h %:t:r<CR>",
			{ desc = "Java Compile Werror & Run (Split)", silent = true, buffer = true }
		)

		vim.keymap.set(
			"n",
			"<leader>rcp",
			":split | terminal javac -classpath . % && java -classpath . %:t:r<CR>",
			{ desc = "Java Classpath Compile & Run (Split)", silent = true, buffer = true }
		)

		vim.keymap.set(
			"n",
			"<leader>rcs",
			":split | terminal javac -sourcepath . % && java -cp %:p:h %:t:r<CR>",
			{ desc = "Java Sourcepath Compile & Run (Split)", silent = true, buffer = true }
		)

		vim.keymap.set(
			"n",
			"<leader>rcv",
			":split | terminal javac -verbose %<CR>",
			{ desc = "Java Verbose Compile (Split)", silent = true, buffer = true }
		)

		vim.keymap.set(
			"n",
			"<leader>rci",
			":split | terminal javac -implicit:none %<CR>",
			{ desc = "Java No-Implicit Compile (Split)", silent = true, buffer = true }
		)

		vim.keymap.set(
			"n",
			"<leader>rct",
			":split | terminal javac --release 17 % && java -cp %:p:h %:t:r<CR>",
			{ desc = "Java Release 17 Compile & Run (Split)", silent = true, buffer = true }
		)

		vim.keymap.set(
			"n",
			"<leader>rra",
			":split | terminal sh -c './gradlew build && ./gradlew run'<CR>",
			{ desc = "Gradle Build & Run (Split)", silent = true, buffer = true }
		)
		vim.keymap.set(
			"n",
			"<leader>rrpo",
			":split | terminal sh -c './gradlew run --args=\"client 0.0.0.0:1234\"'<CR>",
			{
				desc = "Gradle: Run Client",
				silent = true,
			}
		)
		vim.keymap.set(
			"n",
			"<leader>rrr",
			":split | terminal ./gradlew run<CR>",
			{ desc = "Gradle Run (Split)", silent = true, buffer = true }
		)
		vim.keymap.set(
			"n",
			"<leader>rrb",
			":split | terminal ./gradlew build<CR>",
			{ desc = "Gradle Build (Split)", silent = true, buffer = true }
		)

		-- Ganzen Testlauf starten
		vim.keymap.set(
			"n",
			"<leader>rrtt",
			":split | terminal ./gradlew test<CR>",
			{ desc = "Gradle Test (Split)", silent = true, buffer = true }
		)

		-- Nur aktuelle Testklasse
		map_if_free("n", "<leader>rrtcs", function()
			local file = vim.fn.expand("%:t:r")
			vim.cmd("split | terminal ./gradlew test --tests " .. file)
		end, { desc = "Gradle Test Class (Split)", silent = true, buffer = true })

		-- Testmethode unter Cursor (JUnit naming assumed)
		map_if_free("n", "<leader>rrtm", function()
			local method = vim.fn.expand("<cword>")
			vim.cmd("split | terminal ./gradlew test --tests '*." .. method .. "'")
		end, { desc = "Gradle Test Method (Split)", silent = true, buffer = true })

		-- Tests mit Debug Infos
		map_if_free("n", "<leader>rrtdi", function()
			vim.cmd("split | terminal ./gradlew test --info")
		end, { desc = "Gradle Test Info (Split)", silent = true, buffer = true })

		-- Continuous Test Mode (sehr nice)
		map_if_free("n", "<leader>rrtw", function()
			vim.cmd("split | terminal ./gradlew test --continuous")
		end, { desc = "Gradle Test Continuous (Split)", silent = true, buffer = true })

		-- Test Report öffnen
		map_if_free("n", "<leader>rrtr", function()
			-- Bestimmt das Tool: wslview für WSL, sonst xdg-open
			local cmd = vim.env.WSL_DISTRO_NAME ~= nil and "wslview" or "xdg-open"
			local file = "./app/build/reports/tests/test/index.html"

			if vim.fn.filereadable(file) == 1 then
				vim.fn.jobstart({ cmd, file }, { detach = true })
			else
				vim.notify("Report not found: " .. file, vim.log.levels.WARN)
			end
		end, { desc = "Gradle View Test Report", silent = true, buffer = true })

		-- Nur fehlgeschlagene Tests rerun
		map_if_free("n", "<leader>rrtf", function()
			vim.cmd("split | terminal ./gradlew test --rerun-tasks")
		end, { desc = "Gradle Test Rerun Tasks (Split)", silent = true, buffer = true })

		vim.keymap.set(
			"n",
			"<leader>rrg",
			":edit build.gradle<CR>",
			{ desc = "Edit build.gradle (Split)", silent = true, buffer = true }
		)

		-- Maven Support (if not using Gradle)
		local function is_maven_project()
			return vim.fn.filereadable("pom.xml") == 1
		end

		if is_maven_project() then
			local function mvn(cmd)
				vim.cmd("split | terminal mvn " .. cmd)
			end

			vim.keymap.set("n", "<leader>rrma", function()
				mvn("clean package")
			end, { desc = "Maven Build (Split)", silent = true, buffer = true })
			vim.keymap.set("n", "<leader>rrmr", function()
				mvn('exec:java -Dexec.mainClass="com.example.App"')
			end, { desc = "Maven Run (Split)", silent = true, buffer = true })
			vim.keymap.set("n", "<leader>rrmc", function()
				mvn("compile")
			end, { desc = "Maven Compile (Split)", silent = true, buffer = true })
			vim.keymap.set("n", "<leader>rrmt", function()
				mvn("test")
			end, { desc = "Maven Test (Split)", silent = true, buffer = true })
			vim.keymap.set("n", "<leader>rrmci", function()
				mvn("clean install")
			end, { desc = "Maven Install (Split)", silent = true, buffer = true })
		end

		-- Interactive Console (jshell)
		vim.keymap.set(
			"n",
			"<leader>jsh",
			":split | terminal jshell<CR>",
			{ desc = "JShell Console", silent = true, buffer = true }
		)

		-- Fixed: Maven mainClass should be user input
		if is_maven_project() then
			vim.keymap.set("n", "<leader>rrmrc", function()
				local mainClass = vim.fn.input("Main Class (e.g., com.example.App): ")
				mvn('exec:java -Dexec.mainClass="' .. mainClass .. '"')
			end, { desc = "Maven Run (Custom Class)", silent = true, buffer = true })
		end

		vim.keymap.set("n", "<F5>", function()
			require("dap").continue()
		end, opts)

		vim.keymap.set("n", "<F9>", function()
			require("dap").toggle_breakpoint()
		end, opts)

		vim.keymap.set("n", "<F10>", function()
			require("dap").step_over()
		end, opts)

		vim.keymap.set("n", "<F11>", function()
			require("dap").step_into()
		end, opts)

		vim.keymap.set("n", "<F12>", function()
			require("dap").step_out()
		end, opts)

		-- Java Runner (Main Classes)
		map_if_free(
			"n",
			"<leader>jrr",
			"<cmd>JavaRunnerRunMain<CR>",
			{ desc = "Java Run Main (Command)", silent = true, buffer = true }
		)
		map_if_free(
			"n",
			"<leader>jrs",
			"<cmd>JavaRunnerStopMain<CR>",
			{ desc = "Java Stop Main (Command)", silent = true, buffer = true }
		)
		map_if_free(
			"n",
			"<leader>jrl",
			"<cmd>JavaRunnerToggleLogs<CR>",
			{ desc = "Java Toggle Logs (Command)", silent = true, buffer = true }
		)

		-- Java Tests (ohne Debug, CLI-like Komfort)
		map_if_free(
			"n",
			"<leader>jtc",
			"<cmd>JavaTestRunCurrentClass<CR>",
			{ desc = "Java Run Current Class (Command)", silent = true, buffer = true }
		)
		map_if_free(
			"n",
			"<leader>jtm",
			"<cmd>JavaTestRunCurrentMethod<CR>",
			{ desc = "Java Run Current Method (Command)", silent = true, buffer = true }
		)
		map_if_free(
			"n",
			"<leader>jta",
			"<cmd>JavaTestRunAllTests<CR>",
			{ desc = "Java Run All Tests (Command)", silent = true, buffer = true }
		)
		map_if_free(
			"n",
			"<leader>jtr",
			"<cmd>JavaTestViewLastReport<CR>",
			{ desc = "Java View Last Report (Command)", silent = true, buffer = true }
		)

		-- Refactoring (sehr IDE-mäßig)
		map_if_free(
			"n",
			"<leader>jrv",
			"<cmd>JavaRefactorExtractVariable<CR>",
			{ desc = "Java Extract Variable (Command)", silent = true, buffer = true }
		)
		map_if_free(
			"n",
			"<leader>jrm",
			"<cmd>JavaRefactorExtractMethod<CR>",
			{ desc = "Java Extract Method (Command)", silent = true, buffer = true }
		)
		map_if_free(
			"n",
			"<leader>jrc",
			"<cmd>JavaRefactorExtractConstant<CR>",
			{ desc = "Java Extract Constant (Command)", silent = true, buffer = true }
		)
		map_if_free(
			"n",
			"<leader>jrf",
			"<cmd>JavaRefactorExtractField<CR>",
			{ desc = "Java Extract Field (Command)", silent = true, buffer = true }
		)

		-- Settings / Runtime
		map_if_free(
			"n",
			"<leader>jrsr",
			"<cmd>JavaSettingsChangeRuntime<CR>",
			{ desc = "Java Change Runtime (Command)", silent = true, buffer = true }
		)
		map_if_free(
			"n",
			"<leader>jrp",
			"<cmd>JavaProfile<CR>",
			{ desc = "Java Profile (Command)", silent = true, buffer = true }
		)

		-- Neotest (nur für neotest-java)
		-- local function get_neotest()
		--   if not package.loaded["neotest"] then
		--     require("lazy").load({
		--       plugins = { "nvim-neotest/neotest", "rcasia/neotest-java" },
		--     })
		--   end
		--   return require("neotest")
		-- end

		-- -- Aktuellen Test ausführen
		-- map_if_free("n", "<leader>nt", function()
		--   get_neotest().run.run()
		-- end, { desc = "Neotest Run Current Test", buffer = true })

		-- -- Alle Tests der Datei
		-- map_if_free("n", "<leader>nT", function()
		--   get_neotest().run.run(vim.fn.expand("%"))
		-- end, { desc = "Neotest Run File", buffer = true })

		-- -- Letzten Test erneut ausführen
		-- map_if_free("n", "<leader>nl", function()
		--   get_neotest().run.run_last()
		-- end, { desc = "Neotest Run Last", buffer = true })

		-- -- Test-Übersicht öffnen
		-- map_if_free("n", "<leader>no", function()
		--   get_neotest().summary.toggle()
		-- end, { desc = "Neotest Toggle Summary", buffer = true })
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	group = augroup,
	pattern = { "c", "cpp" },
	callback = function()
		local opts = { noremap = true, silent = true, buffer = true }

		vim.keymap.set("n", "<leader>rid", function()
			run_in_term("code .")
		end, { desc = "Open Project in VS Code", silent = true, buffer = true })
		vim.keymap.set("n", "<leader>rir", function()
			run_in_term("clion .")
		end, { desc = "Open Project in Clion", silent = true, buffer = true })

		-- .../app
		vim.keymap.set("n", "<F5>", function()
			require("dap").continue()
		end, opts)

		vim.keymap.set("n", "<F9>", function()
			require("dap").toggle_breakpoint()
		end, opts)

		vim.keymap.set("n", "<F10>", function()
			require("dap").step_over()
		end, opts)

		vim.keymap.set("n", "<F11>", function()
			require("dap").step_into()
		end, opts)

		vim.keymap.set("n", "<F12>", function()
			require("dap").step_out()
		end, opts)

		-- vim.keymap.set(
		--   "n",
		--   "<leader>rra",
		--   ":split | terminal sh -c 'cmake -S . -B build && cmake --build build && ./build/app'<CR>",
		--   opts
		-- )

		-- vim.keymap.set(
		--   "n",
		--   "<leader>rrr",
		--   ":split | terminal ./build/app<CR>",
		--   opts
		-- )

		-- vim.keymap.set(
		--   "n",
		--   "<leader>rrb",
		--   ":split | terminal cmake --build build<CR>",
		--   opts
		-- )

		-- vim.keymap.set(
		--   "n",
		--   "<leader>rrt",
		--   ":split | terminal sh -c 'cd build && ctest'<CR>",
		--   opts
		-- )

		-- vim.keymap.set(
		--   "n",
		--   "<leader>rrg",
		--   ":edit CMakeLists.txt<CR>",
		--   opts
		-- )

		-- Terminal-Split mit Shell-Command
		local function run(cmd)
			vim.cmd("split | terminal " .. cmd)
		end

		-- Configure + Build + Run (Full Pipeline)
		vim.keymap.set("n", "<leader>rra", function()
			run("sh -c 'cmake -S . -B build && cmake --build build && ./build/app'")
		end, { desc = "CMake Build & Run (Split)", silent = true, buffer = true })

		-- Run only
		vim.keymap.set("n", "<leader>rrr", function()
			run("./build/app")
		end, { desc = "C/C++ Run Binary (Split)", silent = true, buffer = true })

		-- Build only
		vim.keymap.set("n", "<leader>rrb", function()
			run("cmake --build build")
		end, { desc = "CMake Build (Split)", silent = true, buffer = true })

		-- Configure only (sehr wichtig bei neuen Flags)
		vim.keymap.set("n", "<leader>rrc", function()
			run("cmake -S . -B build")
		end, { desc = "CMake Configure (Split)", silent = true, buffer = true })

		-- Debug / Release Builds
		vim.keymap.set("n", "<leader>rrd", function()
			run("cmake -S . -B build -DCMAKE_BUILD_TYPE=Debug")
		end, { desc = "CMake Configure Debug (Split)", silent = true, buffer = true })

		vim.keymap.set("n", "<leader>rrR", function()
			run("cmake -S . -B build -DCMAKE_BUILD_TYPE=Release")
		end, { desc = "CMake Configure Release (Split)", silent = true, buffer = true })

		-- Tests
		vim.keymap.set("n", "<leader>rrt", function()
			run("sh -c 'cd build && ctest'")
		end, { desc = "CMake Run Tests (Split)", silent = true, buffer = true })

		-- Verbose Tests (sehr hilfreich)
		vim.keymap.set("n", "<leader>rrT", function()
			run("sh -c 'cd build && ctest --output-on-failure'")
		end, { desc = "CMake Run Tests Output-on-Failure (Split)", silent = true, buffer = true })

		-- Einzelnen Test ausführen (Name unter Cursor)
		vim.keymap.set("n", "<leader>rrf", function()
			local test = vim.fn.expand("<cword>")
			run("sh -c 'cd build && ctest -R " .. test .. "'")
		end, { desc = "CMake Run Specific Test (Split)", silent = true, buffer = true })

		-- Clean Build
		vim.keymap.set("n", "<leader>rrx", function()
			run("rm -rf build")
		end, { desc = "CMake Clean Build Directory (Split)", silent = true, buffer = true })

		-- Reconfigure komplett
		vim.keymap.set("n", "<leader>rrA", function()
			run("rm -rf build && cmake -S . -B build")
		end, { desc = "CMake Reconfigure Clean (Split)", silent = true, buffer = true })

		-- Format Code (wenn clang-format vorhanden)
		vim.keymap.set("n", "<leader>rrF", function()
			run("clang-format -i $(find . -name '*.[ch]pp' -o -name '*.c' -o -name '*.h')")
		end, { desc = "Clang-Format All Files (Split)", silent = true, buffer = true })

		-- Static Analysis optional
		vim.keymap.set("n", "<leader>rrl", function()
			run("clang-tidy $(find . -name '*.cpp')")
		end, { desc = "Clang-Tidy Analyze (Split)", silent = true, buffer = true })

		-- Memory & Sanitizers
		vim.keymap.set("n", "<leader>rrv", function()
			run("cmake -S . -B build -DCMAKE_BUILD_TYPE=Debug && cmake --build build && valgrind ./build/app")
		end, { desc = "Valgrind (Memory Check)", silent = true, buffer = true })

		vim.keymap.set("n", "<leader>rrs", function()
			run("cmake -S . -B build -DCMAKE_CXX_FLAGS='-fsanitize=address -g' && cmake --build build && ./build/app")
		end, { desc = "ASAN (Address Sanitizer)", silent = true, buffer = true })

		vim.keymap.set("n", "<leader>rru", function()
			run("cmake -S . -B build -DCMAKE_CXX_FLAGS='-fsanitize=undefined -g' && cmake --build build && ./build/app")
		end, { desc = "UBSAN (UB Sanitizer)", silent = true, buffer = true })

		-- Profiling
		vim.keymap.set("n", "<leader>rrP", function()
			run("cmake --build build && perf record -g ./build/app && perf report")
		end, { desc = "Perf Profiling", silent = true, buffer = true })

		vim.keymap.set("n", "<leader>rrgp", function()
			run("cmake --build build && gprof ./build/app gmon.out | head -30")
		end, { desc = "GProf Analysis", silent = true, buffer = true })

		-- Wichtige Files schnell öffnen
		vim.keymap.set(
			"n",
			"<leader>rrCM",
			":edit CMakeLists.txt<CR>",
			{ desc = "Edit CMakeLists.txt (Split)", silent = true, buffer = true }
		)
		vim.keymap.set(
			"n",
			"<leader>rrC",
			":edit build/CMakeCache.txt<CR>",
			{ desc = "Edit CMakeCache.txt (Split)", silent = true, buffer = true }
		)
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	group = augroup,
	pattern = "python",
	callback = function()
		local opts = { noremap = true, silent = true, buffer = true }

		-- Projekt öffnen
		vim.keymap.set("n", "<leader>rid", function()
			run_in_term("code .")
		end, { desc = "Open Project in VS Code", silent = true, buffer = true })
		vim.keymap.set("n", "<leader>rir", function()
			run_in_term("pycharm .")
		end, { desc = "Open Project in PyCharm", silent = true, buffer = true })

		-- Python Run & Testing
		vim.keymap.set(
			"n",
			"<leader>rrpy",
			":split | terminal python3 %<CR>",
			{ desc = "Python Run (Split)", silent = true, buffer = true }
		)
		vim.keymap.set(
			"n",
			"<leader>rrt",
			":split | terminal pytest<CR>",
			{ desc = "Pytest Run (Split)", silent = true, buffer = true }
		)
		vim.keymap.set(
			"n",
			"<leader>rrv",
			":split | terminal python3 -m venv .venv<CR>",
			{ desc = "Python Create Venv (Split)", silent = true, buffer = true }
		)

		-- Linting & Formatting
		vim.keymap.set(
			"n",
			"<leader>rlf",
			":!black %<CR>",
			{ desc = "Format with Black", silent = true, buffer = true }
		)
		vim.keymap.set(
			"n",
			"<leader>rll",
			":!ruff check %<CR>",
			{ desc = "Lint with Ruff", silent = true, buffer = true }
		)
		vim.keymap.set(
			"n",
			"<leader>rlF",
			":!ruff format %<CR>",
			{ desc = "Format with Ruff", silent = true, buffer = true }
		)
		vim.keymap.set(
			"n",
			"<leader>rty",
			":split | terminal mypy %<CR>",
			{ desc = "Type Check (mypy)", silent = true, buffer = true }
		)

		-- Tests
		vim.keymap.set(
			"n",
			"<leader>rrrT",
			":split | terminal pytest %<CR>",
			{ desc = "Run current file tests", silent = true, buffer = true }
		)
		vim.keymap.set(
			"n",
			"<leader>rrcvov",
			":split | terminal pytest --cov=. --cov-report=html %<CR>",
			{ desc = "Pytest Coverage", silent = true, buffer = true }
		)
		vim.keymap.set(
			"n",
			"<leader>rrp",
			":split | terminal python3 -m cProfile -s cumtime %<CR>",
			{ desc = "Python Profile (CProfile)", silent = true, buffer = true }
		)

		-- DAP Debugging
		vim.keymap.set("n", "<F5>", function()
			require("dap").continue()
		end, opts)
		vim.keymap.set("n", "<F9>", function()
			require("dap").toggle_breakpoint()
		end, opts)
		vim.keymap.set("n", "<F10>", function()
			require("dap").step_over()
		end, opts)
		vim.keymap.set("n", "<F11>", function()
			require("dap").step_into()
		end, opts)
		vim.keymap.set("n", "<F12>", function()
			require("dap").step_out()
		end, opts)

		-- Virtuelle Umgebung aktivieren/deaktivieren
		vim.keymap.set(
			"n",
			"<leader>rav",
			":split | terminal source .venv/bin/activate<CR>",
			{ desc = "Activate Venv", silent = true, buffer = true }
		)
		vim.keymap.set(
			"n",
			"<leader>rdv",
			":split | terminal deactivate<CR>",
			{ desc = "Deactivate Venv", silent = true, buffer = true }
		)

		-- Jupyter / IPython
		vim.keymap.set(
			"n",
			"<leader>rij",
			":split | terminal jupyter console --kernel python3<CR>",
			{ desc = "Open Jupyter Console", silent = true, buffer = true }
		)

		-- Docstrings / TODOs
		vim.keymap.set(
			"n",
			"<leader>rtd",
			":lua require('neogen').generate()<CR>",
			{ desc = "Generate Docstring (Neogen)", silent = true, buffer = true }
		)
		vim.keymap.set("n", "<leader>rtf", ":TodoTelescope<CR>", { desc = "Find TODOs", silent = true, buffer = true })
		vim.keymap.set(
			"n",
			"<leader>te",
			"<cmd>TroubleToggle lsp_workspace_diagnostics<CR>",
			{ desc = "Show All Python Errors" }
		)
		vim.keymap.set("n", "<leader>rrbd", "<cmd>!bandit %<CR>", { desc = "Run Bandit Security Scan" })
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	group = augroup,
	-- "markdown" ist hier entscheidend, da jupytext .ipynb in .md umwandelt!
	pattern = { "python", "markdown", "quarto" },
	callback = function()
		local opts = { noremap = true, silent = true, buffer = true }

		vim.keymap.set("n", "<leader>onb", function()
			-- Speichert die aktuelle Datei, damit Änderungen übernommen werden
			vim.cmd("silent write")

			-- Holt den Dateinamen der aktuellen Datei
			local file = vim.fn.expand("%:p")

			-- Führt jupytext aus, um die Datei zu synchronisieren und öffnet sie in jupyter
			-- Benötigt 'jupyter-notebook' oder 'jupyter-lab' im PATH
			local cmd = string.format("jupyter notebook '%s' &", file)

			vim.fn.jobstart(cmd, { detach = true })
			print("Opening Jupyter Notebook...")
		end, { desc = "Jupyter: Open in Browser", buffer = true })

		-- 1. Initialisierung (Der erste Schritt im Notebook)
		vim.keymap.set("n", "<leader>rmi", ":MoltenInit<CR>", { desc = "Molten: Init Kernel", buffer = true })

		-- 2. Ausführen (Wie Shift+Enter in Jupyter)
		-- 'e' für Evaluate: Funktioniert mit Motions (z.B. <leader>eip für den ganzen Block)
		vim.keymap.set("n", "<leader>rre", ":MoltenEvaluateOperator<CR>", { desc = "Molten: Run Block", silent = true })
		-- Für mich
		-- vim.keymap.set("n", "<leader>rra", ":MoltenEvaluateOperator<CR>", { desc = "Molten: Run Block", buffer = true })
		-- Auswahl im Visual Mode ausführen
		vim.keymap.set(
			"v",
			"<leader>rre",
			":<C-u>MoltenEvaluateVisual<CR>gv",
			{ desc = "Molten: Run Selection", buffer = true }
		)
		-- Nur die aktuelle Zeile feuern
		vim.keymap.set("n", "<leader>rrrl", ":MoltenEvaluateLine<CR>", { desc = "Molten: Run Line", buffer = true })

		-- 3. Readme-Style Management (Output Fenster)
		-- Zeigt den Output (z.B. den Mandelbrot Plot) wieder an
		vim.keymap.set("n", "<leader>rros", ":MoltenShowOutput<CR>", { desc = "Molten: Show Output", buffer = true })
		-- Versteckt den Output, um das Readme sauber zu lesen
		vim.keymap.set("n", "<leader>rroh", ":MoltenHideOutput<CR>", { desc = "Molten: Hide Output", buffer = true })
		-- Löscht die Zelle/den Output komplett
		vim.keymap.set("n", "<leader>rrrd", ":MoltenDelete<CR>", { desc = "Molten: Delete Cell", buffer = true })

		-- 4. Navigation (Schnell zwischen Code-Blöcken springen)
		-- Sucht nach dem nächsten Markdown-Codeblock
		vim.keymap.set("n", "]c", "/^```<CR>:noh<CR>", { desc = "Next Code Block", buffer = true, silent = true })
		vim.keymap.set("n", "[c", "?^```<CR>:noh<CR>", { desc = "Prev Code Block", buffer = true, silent = true })
	end,
})

-- vim.api.nvim_create_autocmd("FileType", {
--   group = augroup,
--   pattern = "c",
--   callback = function()
--     vim.keymap.set("n", "<leader>rid", function()
--       run_in_term("code .")
--     end, opts) -- VS Code
--     vim.keymap.set("n", "<leader>rir", function()
--       run_in_term("eclipse")
--     end, opts) -- Eclipse
--     vim.keymap.set("n", "<leader>rrb", function()
--       run_in_term("gcc % -o %:r")
--     end, opts)
--     vim.keymap.set("n", "<leader>rrr", function()
--       run_in_term("./%:r")
--     end, opts)
--   end,
-- })

vim.api.nvim_create_autocmd("FileType", {
	group = augroup,
	pattern = "c",
	callback = function()
		-- local opts = { noremap = true, silent = true, buffer = true }

		vim.keymap.set(
			"n",
			"<leader>rcr",
			":split | terminal gcc % -o %:r && ./%:r<CR>",
			{ desc = "GCC Compile & Run (Split)", silent = true, buffer = true }
		)

		vim.keymap.set(
			"n",
			"<leader>rco",
			":split | terminal gcc % -O2 -o %:r && ./%:r<CR>",
			{ desc = "GCC Optimized Run (Split)", silent = true, buffer = true }
		)

		vim.keymap.set(
			"n",
			"<leader>rcd",
			":split | terminal gcc % -g -o %:r && ./%:r<CR>",
			{ desc = "GCC Debug Run (Split)", silent = true, buffer = true }
		)

		vim.keymap.set(
			"n",
			"<leader>rcw",
			":split | terminal gcc % -Wall -Wextra -o %:r && ./%:r<CR>",
			{ desc = "GCC Warnings Run (Split)", silent = true, buffer = true }
		)

		vim.keymap.set(
			"n",
			"<leader>rcs",
			":split | terminal gcc % -std=c11 -o %:r && ./%:r<CR>",
			{ desc = "GCC Compile & Run (Split)", silent = true, buffer = true }
		)

		vim.keymap.set(
			"n",
			"<leader>rcc",
			":split | terminal gcc -c %<CR>",
			{ desc = "GCC Compile Only (Split)", silent = true, buffer = true }
		)

		-- Memory & Sanitizers
		vim.keymap.set(
			"n",
			"<leader>rcv",
			":split | terminal gcc -g % -o %:r && valgrind ./%:r<CR>",
			{ desc = "GCC + Valgrind (Memory Check)", silent = true, buffer = true }
		)

		vim.keymap.set(
			"n",
			"<leader>rcsan",
			":split | terminal gcc -fsanitize=address -g % -o %:r && ./%:r<CR>",
			{ desc = "GCC + ASAN", silent = true, buffer = true }
		)
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	group = augroup,
	pattern = "cpp",
	callback = function()
		-- local opts = { noremap = true, silent = true, buffer = true }

		vim.keymap.set(
			"n",
			"<leader>rpr",
			":split | terminal g++ % -o %:r && ./%:r<CR>",
			{ desc = "G++ Compile & Run (Split)", silent = true, buffer = true }
		)

		vim.keymap.set(
			"n",
			"<leader>rpo",
			":split | terminal g++ % -O2 -o %:r && ./%:r<CR>",
			{ desc = "G++ O2 Compile & Run (Split)", silent = true, buffer = true }
		)

		vim.keymap.set(
			"n",
			"<leader>rpd",
			":split | terminal g++ % -g -o %:r && ./%:r<CR>",
			{ desc = "G++ Debug Compile & Run (Split)", silent = true, buffer = true }
		)

		vim.keymap.set(
			"n",
			"<leader>rpw",
			":split | terminal g++ % -Wall -Wextra -o %:r && ./%:r<CR>",
			{ desc = "G++ Warnings Compile & Run (Split)", silent = true, buffer = true }
		)

		vim.keymap.set(
			"n",
			"<leader>rps",
			":split | terminal g++ % -std=c++20 -o %:r && ./%:r<CR>",
			{ desc = "G++ C++20 Compile & Run (Split)", silent = true, buffer = true }
		)

		vim.keymap.set(
			"n",
			"<leader>rpc",
			":split | terminal g++ -c %<CR>",
			{ desc = "G++ Compile Only (Split)", silent = true, buffer = true }
		)

		-- Memory & Sanitizers
		vim.keymap.set(
			"n",
			"<leader>rpv",
			":split | terminal g++ -g % -o %:r && valgrind ./%:r<CR>",
			{ desc = "G++ + Valgrind (Memory Check)", silent = true, buffer = true }
		)

		vim.keymap.set(
			"n",
			"<leader>rpsan",
			":split | terminal g++ -fsanitize=address -g % -o %:r && ./%:r<CR>",
			{ desc = "G++ + ASAN", silent = true, buffer = true }
		)

		vim.keymap.set(
			"n",
			"<leader>rpub",
			":split | terminal g++ -fsanitize=undefined -g % -o %:r && ./%:r<CR>",
			{ desc = "G++ + UBSAN", silent = true, buffer = true }
		)
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	group = augroup,
	pattern = "go",
	callback = function()
		-- local opts = { noremap = true, silent = true, buffer = true }

		vim.keymap.set(
			"n",
			"<leader>rpr",
			":split | terminal go run %<CR>",
			{ desc = "Go Run (Split)", silent = true, buffer = true }
		)

		vim.keymap.set(
			"n",
			"<leader>rpb",
			":split | terminal go build -o %:r % && ./%:r<CR>",
			{ desc = "Go Build & Run (Split)", silent = true, buffer = true }
		)

		vim.keymap.set(
			"n",
			"<leader>rpt",
			":split | terminal go test -v -race %<CR>",
			{ desc = "Go Test (with Race Detector)", silent = true, buffer = true }
		)

		vim.keymap.set(
			"n",
			"<leader>rptc",
			":split | terminal go test -cover %<CR>",
			{ desc = "Go Test (with Coverage)", silent = true, buffer = true }
		)

		vim.keymap.set(
			"n",
			"<leader>rpb",
			":split | terminal go test -bench ./... -benchmem<CR>",
			{ desc = "Go Benchmark", silent = true, buffer = true }
		)

		vim.keymap.set(
			"n",
			"<leader>rpl",
			":split | terminal golangci-lint run %<CR>",
			{ desc = "Go Lint Current File (Split)", silent = true, buffer = true }
		)

		vim.keymap.set(
			"n",
			"<leader>rpmg",
			":split | terminal go mod tidy<CR>",
			{ desc = "Go Mod Tidy", silent = true, buffer = true }
		)

		vim.keymap.set(
			"n",
			"<leader>rpmu",
			":split | terminal go get -u ./...<CR>",
			{ desc = "Go Mod Update", silent = true, buffer = true }
		)

		vim.keymap.set(
			"n",
			"<leader>rpc",
			":split | terminal go build -c %<CR>",
			{ desc = "Go Compile Only (Split)", silent = true, buffer = true }
		)

		-- Documentation
		vim.keymap.set(
			"n",
			"<leader>rpd",
			":split | terminal godoc -h<CR>",
			{ desc = "Go Doc Server", silent = true, buffer = true }
		)
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	group = augroup,
	pattern = "zig",
	callback = function()
		-- local opts = { noremap = true, silent = true, buffer = true }

		vim.keymap.set(
			"n",
			"<leader>rpr",
			":split | terminal zig run %<CR>",
			{ desc = "Zig Run (Split)", silent = true, buffer = true }
		)

		vim.keymap.set(
			"n",
			"<leader>rpb",
			":split | terminal zig build-exe % -O ReleaseSafe -femit-bin=%:r && ./%:r<CR>",
			{ desc = "Zig Build & Run (Split)", silent = true, buffer = true }
		)

		vim.keymap.set(
			"n",
			"<leader>rpd",
			":split | terminal zig build-exe % -O Debug -femit-bin=%:r && ./%:r<CR>",
			{ desc = "Zig Debug Build & Run (Split)", silent = true, buffer = true }
		)

		vim.keymap.set(
			"n",
			"<leader>rpo",
			":split | terminal zig build-exe % -O ReleaseFast -femit-bin=%:r && ./%:r<CR>",
			{ desc = "Zig Optimized Build & Run (Split)", silent = true, buffer = true }
		)

		vim.keymap.set(
			"n",
			"<leader>rpc",
			":split | terminal zig build-exe % -femit-bin=%:r<CR>",
			{ desc = "Zig Compile Only (Split)", silent = true, buffer = true }
		)

		vim.keymap.set(
			"n",
			"<leader>rpt",
			":split | terminal zig build test<CR>",
			{ desc = "Zig Run Tests", silent = true, buffer = true }
		)

		vim.keymap.set(
			"n",
			"<leader>rpf",
			":split | terminal zig fmt %<CR>",
			{ desc = "Zig Format", silent = true, buffer = true }
		)
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	pattern = { "html" },
	callback = function()
		local opts = { silent = true, buffer = true }

		-- Browser Preview (Öffnet die aktuelle Datei im Standard-Browser)
		vim.keymap.set("n", "<leader>rph", "<cmd>Open<CR>", { desc = "HTML: Open in Browser", buffer = true })

		-- HTML Linting manuell im Terminal triggern (HTMLHint)
		vim.keymap.set(
			"n",
			"<leader>rpl",
			":split | terminal htmlhint %<CR>",
			{ desc = "HTML: Lint with HTMLHint (Split)", silent = true, buffer = true }
		)

		-- Schnell-Validierung mit Tidy (falls installiert)
		vim.keymap.set(
			"n",
			"<leader>rpt",
			":split | terminal tidy -errors -quiet %<CR>",
			{ desc = "HTML: Check with Tidy", silent = true, buffer = true }
		)

		-- Pretty Print HTML
		vim.keymap.set(
			"n",
			"<leader>rpf",
			":split | terminal prettier --write %<CR>",
			{ desc = "HTML: Format with Prettier", silent = true, buffer = true }
		)
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	group = augroup,
	pattern = { "javascript", "typescript" },
	callback = function()
		-- local opts = { noremap = true, silent = true, buffer = true }

		-- JavaScript / TypeScript direkt ausführen
		vim.keymap.set(
			"n",
			"<leader>rpr",
			":split | terminal node %<CR>",
			{ desc = "Node Run (Split)", silent = true, buffer = true }
		)

		-- TypeScript vorher kompilieren und dann ausführen
		vim.keymap.set(
			"n",
			"<leader>rpt",
			":split | terminal tsc % && node %:r.js<CR>",
			{ desc = "TS Compile & Run (Split)", silent = true, buffer = true }
		)

		-- Linting & Formatting
		vim.keymap.set(
			"n",
			"<leader>rpl",
			":split | terminal eslint %<CR>",
			{ desc = "Lint Current JS/TS File (Split)", silent = true, buffer = true }
		)

		vim.keymap.set(
			"n",
			"<leader>rpf",
			":split | terminal npx prettier --write %<CR>",
			{ desc = "Format with Prettier", silent = true, buffer = true }
		)

		-- Package Manager Detection & Build (wrapped in function to ensure proper scope)
		local function get_pm()
			if vim.fn.filereadable("pnpm-lock.yaml") == 1 then
				return "pnpm"
			elseif vim.fn.filereadable("yarn.lock") == 1 then
				return "yarn"
			else
				return "npm"
			end
		end

		-- Build
		vim.keymap.set("n", "<leader>rrb", function()
			vim.cmd("split | terminal " .. pm .. " run build")
		end, { desc = "Build (" .. pm .. ")", silent = true, buffer = true })

		-- Dev Server
		vim.keymap.set("n", "<leader>rrfd", function()
			vim.cmd("split | terminal " .. pm .. " run dev")
		end, { desc = "Dev Server (" .. pm .. ")", silent = true, buffer = true })

		-- Test (Jest/Vitest)
		vim.keymap.set("n", "<leader>rrt", function()
			vim.cmd("split | terminal " .. pm .. " test")
		end, { desc = "Test (" .. pm .. ")", silent = true, buffer = true })

		vim.keymap.set("n", "<leader>rrtc", function()
			vim.cmd("split | terminal " .. pm .. " test -- --coverage")
		end, { desc = "Test Coverage", silent = true, buffer = true })

		-- Lint
		vim.keymap.set("n", "<leader>rrl", function()
			vim.cmd("split | terminal " .. pm .. " run lint")
		end, { desc = "Lint (" .. pm .. ")", silent = true, buffer = true })

		-- Install Dependencies
		vim.keymap.set("n", "<leader>rri", function()
			vim.cmd("split | terminal " .. get_pm() .. " install")
		end, { desc = "Install Dependencies", silent = true, buffer = true })

		-- Add Package
		vim.keymap.set("n", "<leader>rradd", function()
			local pkg = vim.fn.input("Package name: ")
			vim.cmd("split | terminal " .. get_pm() .. " add " .. pkg)
		end, { desc = "Add Package", buffer = true })

		-- Remove Package
		vim.keymap.set("n", "<leader>rrrm", function()
			local pkg = vim.fn.input("Package name: ")
			vim.cmd("split | terminal " .. get_pm() .. " remove " .. pkg)
		end, { desc = "Remove Package", buffer = true })

		-- Type Check (TypeScript)
		vim.keymap.set(
			"n",
			"<leader>rty",
			":split | terminal tsc --noEmit<CR>",
			{ desc = "TypeScript Check", silent = true, buffer = true }
		)
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	group = augroup,
	pattern = "lua",
	callback = function()
		-- local opts = { noremap = true, silent = true, buffer = true }

		-- Lua Datei direkt ausführen
		vim.keymap.set(
			"n",
			"<leader>rpr",
			":split | terminal lua %<CR>",
			{ desc = "Lua Run (Split)", silent = true, buffer = true }
		)

		-- LuaJIT benutzen (optional, schneller)
		vim.keymap.set(
			"n",
			"<leader>rpj",
			":split | terminal luajit %<CR>",
			{ desc = "LuaJIT Run (Split)", silent = true, buffer = true }
		)

		-- Lua testing with busted
		vim.keymap.set(
			"n",
			"<leader>rpt",
			":split | terminal busted<CR>",
			{ desc = "Busted Test (Split)", silent = true, buffer = true }
		)

		-- Linting with luacheck
		vim.keymap.set(
			"n",
			"<leader>rpl",
			":split | terminal luacheck %<CR>",
			{ desc = "Luacheck Lint", silent = true, buffer = true }
		)
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	group = augroup,
	pattern = { "asm", "s", "S" },
	callback = function()
		-- local opts = { noremap = true, silent = true, buffer = true }

		-- Standard: Assemblieren, Linken & Ausführen
		vim.keymap.set(
			"n",
			"<leader>rar",
			":split | terminal nasm -f elf64 % -o %:r.o && ld %:r.o -o %:r && %:p:r<CR>",
			{ desc = "NASM Run (ELF64)", silent = true, buffer = true }
		)

		-- Für mich
		vim.keymap.set(
			"n",
			"<leader>rra",
			":split | terminal nasm -f elf64 % -o %:r.o && ld %:r.o -o %:r && %:p:r<CR>",
			{ desc = "NASM Run (ELF64)", silent = true, buffer = true }
		)

		-- Debug: Mit Debug-Symbolen für GDB assemblieren
		vim.keymap.set(
			"n",
			"<leader>rad",
			":split | terminal nasm -f elf64 -g -F dwarf % -o %:r.o && ld %:r.o -o %:r<CR>",
			{ desc = "NASM Build with Debug Symbols", silent = true, buffer = true }
		)

		-- Nur Assemblieren (Object File erstellen)
		vim.keymap.set(
			"n",
			"<leader>rac",
			":split | terminal nasm -f elf64 % -o %:r.o<CR>",
			{ desc = "NASM Compile Only", silent = true, buffer = true }
		)

		-- Listing File generieren
		vim.keymap.set(
			"n",
			"<leader>ral",
			":split | terminal nasm -f elf64 % -l %:r.lst<CR>",
			{ desc = "NASM Generate Listing File", silent = true, buffer = true }
		)

		-- GAS: Assemblieren, Linken & Ausführen
		vim.keymap.set(
			"n",
			"<leader>gar",
			":split | terminal as % -o %:r.o && ld %:r.o -o %:r && %:p:r<CR>",
			{ desc = "GAS Run (AT&T)", silent = true, buffer = true }
		)

		-- GAS Debug: Mit Debug-Symbolen für GDB
		vim.keymap.set(
			"n",
			"<leader>gad",
			":split | terminal as -g % -o %:r.o && ld %:r.o -o %:r<CR>",
			{ desc = "GAS Build Debug", silent = true, buffer = true }
		)

		-- GAS: Nur Assemblieren
		vim.keymap.set(
			"n",
			"<leader>gac",
			":split | terminal as % -o %:r.o<CR>",
			{ desc = "GAS Compile Only", silent = true, buffer = true }
		)

		-- Cleanup
		vim.keymap.set("n", "<leader>rax", function()
			local bin = vim.fn.expand("%:p:r")
			os.remove(bin .. ".o")
			os.remove(bin)
			print("Cleaned up: " .. vim.fn.expand("%:t:r"))
		end, { desc = "NASM Cleanup Files", silent = true, buffer = true })
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	group = augroup,
	pattern = { "cs" },
	callback = function()
		local ok, dotnet = pcall(require, "easy-dotnet")
		if not ok then
			return
		end

		-- Standard: Ausführen (Entspricht dotnet run)
		vim.keymap.set("n", "<leader>rar", function()
			dotnet.run()
		end, { desc = ".NET Run Project", silent = true, buffer = true })

		-- Für dich zum Ausführen
		vim.keymap.set("n", "<leader>rra", function()
			dotnet.run()
		end, { desc = ".NET Run Project", silent = true, buffer = true })

		-- Build: Projekt kompilieren
		vim.keymap.set("n", "<leader>rad", function()
			dotnet.build()
		end, { desc = ".NET Build Project", silent = true, buffer = true })

		-- Restore: Abhängigkeiten wiederherstellen
		vim.keymap.set("n", "<leader>rac", function()
			dotnet.restore()
		end, { desc = ".NET Restore Packages", silent = true, buffer = true })

		-- Cleanup: Projekt aufräumen (Löscht bin/obj Ordner)
		vim.keymap.set("n", "<leader>rax", function()
			dotnet.clean()
		end, { desc = ".NET Clean Project", silent = true, buffer = true })

		-- Zusätzliche nützliche C# Extras
		vim.keymap.set("n", "<leader>rat", function()
			dotnet.test()
		end, { desc = ".NET Run Tests", silent = true, buffer = true })

		vim.keymap.set("n", "<leader>rap", function()
			dotnet.publish()
		end, { desc = ".NET Publish Project", silent = true, buffer = true })
	end,
})

-- Langsam aber stabil
-- vim.api.nvim_create_autocmd("FileType", {
--   group = vim.api.nvim_create_augroup("MatlabConfig", { clear = true }),
--   pattern = { "matlab" },
--   callback = function()
--     local opts = { noremap = true, silent = true, buffer = true }
--     local matlab_path = "/usr/local/MATLAB/R2025b/bin/matlab"
--     -- local matlab_path = "/opt/matlab/bin/matlab"

--     -- Optimierte Run-Funktion mit startinsert
--     local function run_cmd(cmd)
--       vim.cmd("split | terminal " .. cmd)
--       -- Verhindert E21 Fehler und erlaubt sofortiges Strg+C
--       vim.cmd("startinsert")
--     end

--     -- <leader>rra: Datei ausführen (Bleibt offen für Plots)
--     vim.keymap.set("n", "<leader>rra", function()
--       local file_path = vim.fn.expand("%:p")
--       run_cmd(matlab_path .. " -nosplash -nodesktop -r \"clc; run('" .. file_path .. "')\"")
--     end, { desc = "MATLAB Run (Stay open for Plots)", silent = true, buffer = true })

--     -- <leader>rrr: Interaktive Konsole
--     vim.keymap.set("n", "<leader>rrr", function()
--       run_cmd(matlab_path .. " -nosplash -nodesktop -r \"clc;\"")
--     end, { desc = "Open MATLAB Console", silent = true, buffer = true })

--     -- F5: Schnell-Ausführung
--     vim.keymap.set("n", "<F5>", function()
--       local file_path = vim.fn.expand("%:p")
--       run_cmd(matlab_path .. " -nosplash -nodesktop -r \"run('" .. file_path .. "')\"")
--     end, opts)

--     -- BONUS: <leader>rrk zum schnellen "Killen" des Terminals/Plots
--     vim.keymap.set("n", "<leader>rrk", function()
--       vim.cmd("bwipeout!")
--     end, { desc = "Kill MATLAB / Close Plot", silent = true, buffer = true })
--   end,
-- })

-- besser:
-- vim.api.nvim_create_autocmd("FileType", {
--   group = vim.api.nvim_create_augroup("MatlabConfig", { clear = true }),
--   pattern = { "matlab" },

--   callback = function()
--     local opts = { noremap = true, silent = true, buffer = true }

--     -- MAX SPEED MATLAB
--     local matlab_fast = "/opt/matlab/bin/matlab -nojvm -nodisplay -nosplash -nodesktop"

--     local matlab_batch = "/opt/matlab/bin/matlab -batch"

--     -- SPLIT TERMINAL (horizontal)
--     local function run_cmd(cmd)
--       vim.cmd("split")

--       -- vim.cmd("resize 15")

--       vim.cmd("terminal " .. cmd)

--       vim.cmd("startinsert")
--     end

--     -- <leader>rra = FAST RUN
--     vim.keymap.set("n", "<leader>rra", function()
--       local file = vim.fn.expand("%:p")

--       run_cmd(matlab_fast .. " -r \"try; run('" .. file .. "'); catch ME; disp(getReport(ME)); end; exit\"")
--     end, {
--       desc = "Run MATLAB FAST",
--       silent = true,
--       buffer = true,
--     })

--     -- <leader>rrr = Interactive Console
--     vim.keymap.set("n", "<leader>rrr", function()
--       run_cmd(matlab_fast)
--     end, {
--       desc = "Open MATLAB Console",
--       silent = true,
--       buffer = true,
--     })

--     -- F5 = TURBO RUN
--     vim.keymap.set("n", "<F5>", function()
--       local file = vim.fn.expand("%:p")

--       run_cmd(matlab_batch .. " \"run('" .. file .. "')\"")
--     end, opts)

--     -- <leader>rrk = Kill Terminal
--     vim.keymap.set("n", "<leader>rrk", function()
--       vim.cmd("bd!")
--     end, {
--       desc = "Close MATLAB Terminal",
--       silent = true,
--       buffer = true,
--     })
--   end,
-- })
