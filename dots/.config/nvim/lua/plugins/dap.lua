-- plugins/dap.lua

-- return {
--   {
--     "mfussenegger/nvim-dap",
--     dependencies = {
--       {
--         "rcarriga/nvim-dap-ui",
--         dependencies = {
--           "nvim-neotest/nvim-nio",
--         },
--       },
--       "jay-babu/mason-nvim-dap.nvim",
--     },
--     config = function()
--       local dap = require("dap")
--       local dapui = require("dapui")

--       local mason_path = vim.fn.stdpath("data") .. "/mason"
--       local codelldb_path =
--         mason_path .. "/packages/codelldb/extension/adapter/codelldb"

--       require("mason-nvim-dap").setup({
--         ensure_installed = { "codelldb" },
--       })

--       dapui.setup()

--       dap.listeners.after.event_initialized["dapui"] = function()
--         dapui.open()
--       end
--       dap.listeners.before.event_terminated["dapui"] = function()
--         dapui.close()
--       end
--       dap.listeners.before.event_exited["dapui"] = function()
--         dapui.close()
--       end

--       dap.adapters.codelldb = {
--         type = "server",
--         port = "${port}",
--         executable = {
--           command = codelldb_path,
--           args = { "--port", "${port}" },
--         },
--       }

--       dap.configurations.rust = {
--         {
--           name = "Debug",
--           type = "codelldb",
--           request = "launch",
--           program = function()
--             return vim.fn.input(
--               "Path to executable: ",
--               vim.fn.getcwd() .. "/target/debug/",
--               "file"
--             )
--           end,
--           cwd = "${workspaceFolder}",
--           stopOnEntry = false,
--           args = {},
--         },
--       }

--       dap.configurations.cpp = {
--         {
--           name = "Debug",
--           type = "codelldb",
--           request = "launch",
--           program = function()
--             return vim.fn.input(
--               "Path to executable: ",
--               vim.fn.getcwd() .. "/build/",
--               "file"
--             )
--           end,
--           cwd = "${workspaceFolder}",
--           stopOnEntry = false,
--           args = {},
--         },
--       }

--       dap.configurations.c = dap.configurations.cpp
--     end,
--    },
-- }

-- return {
--   {
--     "mfussenegger/nvim-dap",
--     dependencies = {
--       {
--         "rcarriga/nvim-dap-ui",
--         dependencies = {
--           "nvim-neotest/nvim-nio",
--         },
--       },
--       "jay-babu/mason-nvim-dap.nvim",
--       "mfussenegger/nvim-dap-python",
--     },
--     config = function()
--       local dap = require("dap")
--       local dapui = require("dapui")

--       local mason_path = vim.fn.stdpath("data") .. "/mason"
--       local codelldb_path =
--         mason_path .. "/packages/codelldb/extension/adapter/codelldb"

--       -- require("mason-nvim-dap").setup({
--       --   ensure_installed = { "codelldb" , "python"},
--       -- })

--       require("mason-nvim-dap").setup({
--         ensure_installed = { "codelldb"},
--       })

--       dapui.setup()

--       dap.listeners.after.event_initialized["dapui"] = function()
--         dapui.open()
--       end
--       dap.listeners.before.event_terminated["dapui"] = function()
--         dapui.close()
--       end
--       dap.listeners.before.event_exited["dapui"] = function()
--         dapui.close()
--       end

--       dap.adapters.codelldb = {
--         type = "server",
--         port = "${port}",
--         executable = {
--           command = codelldb_path,
--           args = { "--port", "${port}" },
--         },
--       }

--       dap.configurations.rust = {
--         {
--           name = "Debug",
--           type = "codelldb",
--           request = "launch",
--           program = function()
--             return vim.fn.input(
--               "Path to executable: ",
--               vim.fn.getcwd() .. "/target/debug/",
--               "file"
--             )
--           end,
--           cwd = "${workspaceFolder}",
--           stopOnEntry = false,
--           args = {},
--         },
--       }

--       dap.configurations.cpp = {
--         {
--           name = "Debug",
--           type = "codelldb",
--           request = "launch",
--           program = function()
--             return vim.fn.input(
--               "Path to executable: ",
--               vim.fn.getcwd() .. "/build/",
--               "file"
--             )
--           end,
--           cwd = "${workspaceFolder}",
--           stopOnEntry = false,
--           args = {},
--         },
--       }

--       dap.configurations.c = dap.configurations.cpp

--       -- https://github.com/nvim-java/nvim-java ersetzt das!
--       -- dap.adapters.java = function(callback)
--       --   callback({
--       --     type = "server",
--       --     host = "127.0.0.1",
--       --     port = 5005,  -- Standardport für jdtls Debug
--       --   })
--       -- end

--       -- dap.configurations.java = {
--       --   {
--       --     type = "java",
--       --     request = "launch",
--       --     name = "Debug Current File",
--       --     mainClass = "${file}",
--       --     projectName = "MeinProjekt",
--       --     cwd = vim.fn.getcwd(),
--       --     console = "integratedTerminal",
--       --   },
--       -- }

--       -- local function get_python_bin()
--       --   local python = vim.fn.getcwd() .. "/venv/bin/python"
--       --   if vim.fn.executable(python) == 1 then
--       --     return python
--       --   end
--       --   return vim.fn.exepath("python3")
--       -- end

--       -- require("dap-python").setup(get_python_bin())

--       -- local function get_python_bin()
--       --   local venv = vim.fn.getcwd() .. "/venv/bin/python"
--       --   if vim.fn.executable(venv) == 1 then
--       --     return venv
--       --   end
--       --   return vim.fn.exepath("python3")
--       -- end

--       -- require("dap-python").setup(get_python_bin())
--       -- dap.lua (Python-relevant Teil)
--     end,
--   },

--   -- {
--   --   "Weissle/persistent-breakpoints.nvim",
--   --   config = function()
--   --     require("persistent-breakpoints").setup({
--   --       save_dir = vim.fn.stdpath("data") .. "/breakpoints",
--   --       load_breakpoints_event = { "BufReadPost" },
--   --     })
--   --   end,
--   -- },
-- }

-- local function get_python_bin()
--   local venv = vim.fn.getcwd() .. "/venv/bin/python"
--   if vim.fn.executable(venv) == 1 then
--     return venv
--   end

--   -- Mason debugpy Pfad
--   local mason_debugpy = vim.fn.stdpath("data") .. "/mason/packages/debugpy/venv/bin/python"
--   if vim.fn.executable(mason_debugpy) == 1 then
--     return mason_debugpy
--   end

--   return vim.fn.exepath("python3")
-- end

-- return {
--   {
--     "mfussenegger/nvim-dap",
--     cmd = { "DapContinue", "DapToggleBreakpoint", "DapUI" },
--     dependencies = {
--       {
--         "rcarriga/nvim-dap-ui",
--         dependencies = {
--           "nvim-neotest/nvim-nio",
--         },
--       },
--       "jay-babu/mason-nvim-dap.nvim",
--       "mfussenegger/nvim-dap-python",
--     },
--     config = function()
--       local dap = require("dap")
--       local dapui = require("dapui")

--       local mason_path = vim.fn.stdpath("data") .. "/mason"
--       local codelldb_path =
--         mason_path .. "/packages/codelldb/extension/adapter/codelldb"

--       require("mason-nvim-dap").setup({
--         ensure_installed = { "codelldb" , "python"},
--       })

--       -- require("mason-nvim-dap").setup({
--       --   ensure_installed = { "codelldb"},
--       -- })

--       -- Mason Debug Adapter
--       -- require("mason-nvim-dap").setup({
--       --   ensure_installed = {
--       --     "codelldb",
--       --     "python", -- debugpy
--       --   },
--       -- })

--       dapui.setup()

--       dap.listeners.after.event_initialized["dapui"] = function()
--         dapui.open()
--       end
--       dap.listeners.before.event_terminated["dapui"] = function()
--         dapui.close()
--       end
--       dap.listeners.before.event_exited["dapui"] = function()
--         dapui.close()
--       end

--       dap.adapters.codelldb = {
--         type = "server",
--         port = "${port}",
--         executable = {
--           command = codelldb_path,
--           args = { "--port", "${port}" },
--         },
--       }

--       -- dap.configurations.rust = {
--       --   {
--       --     name = "Debug",
--       --     type = "codelldb",
--       --     request = "launch",
--       --     program = function()
--       --       return vim.fn.input(
--       --         "Path to executable: ",
--       --         vim.fn.getcwd() .. "/target/debug/",
--       --         "file"
--       --       )
--       --     end,
--       --     cwd = "${workspaceFolder}",
--       --     stopOnEntry = false,
--       --     args = {},
--       --   },
--       -- }

--       dap.configurations.rust = {
--         {
--           name = "Debug Rust",
--           type = "codelldb",
--           request = "launch",
--           program = function()
--             local cwd = vim.fn.getcwd()
--             local crate = vim.fn.fnamemodify(cwd, ":t")
--             return cwd .. "/target/debug/" .. crate
--           end,
--           cwd = "${workspaceFolder}",
--           stopOnEntry = false,
--           args = {},
--         },
--       }

--       dap.configurations.cpp = {
--         {
--           name = "Debug",
--           type = "codelldb",
--           request = "launch",
--           program = function()
--             return vim.fn.input(
--               "Path to executable: ",
--               vim.fn.getcwd() .. "/build/",
--               "file"
--             )
--           end,
--           cwd = "${workspaceFolder}",
--           stopOnEntry = false,
--           args = {},
--         },
--       }

--       dap.configurations.c = dap.configurations.cpp

--       -- https://github.com/nvim-java/nvim-java ersetzt das!
--       -- dap.adapters.java = function(callback)
--       --   callback({
--       --     type = "server",
--       --     host = "127.0.0.1",
--       --     port = 5005,  -- Standardport für jdtls Debug
--       --   })
--       -- end

--       -- dap.configurations.java = {
--       --   {
--       --     type = "java",
--       --     request = "launch",
--       --     name = "Debug Current File",
--       --     mainClass = "${file}",
--       --     projectName = "MeinProjekt",
--       --     cwd = vim.fn.getcwd(),
--       --     console = "integratedTerminal",
--       --   },
--       -- }

--       -- local function get_python_bin()
--       --   local python = vim.fn.getcwd() .. "/venv/bin/python"
--       --   if vim.fn.executable(python) == 1 then
--       --     return python
--       --   end
--       --   return vim.fn.exepath("python3")
--       -- end

--       -- require("dap-python").setup(get_python_bin())

--       -- local function get_python_bin()
--       --   local venv = vim.fn.getcwd() .. "/venv/bin/python"
--       --   if vim.fn.executable(venv) == 1 then
--       --     return venv
--       --   end
--       --   return vim.fn.exepath("python3")
--       -- end

--       -- require("dap-python").setup(get_python_bin())
--       -- dap.lua (Python-relevant Teil)

--       -- Python
--       -- local ok, dap_python = pcall(require, "dap-python")
--       -- if ok then
--       --   dap_python.setup(get_python_bin())   -- verwendet Mason debugpy
--       --   dap_python.test_runner = "pytest"
--       -- else
--       --   vim.notify("dap-python konnte nicht geladen werden", vim.log.levels.WARN)
--       -- end

--       local ok, dap_python = pcall(require, "dap-python")
--       if ok then
--           -- Pfad zum Mason-Debugger (hier liegt das installierte debugpy)
--           local mason_path = vim.fn.stdpath("data") .. "/mason/packages/debugpy/venv/bin/python"

--           -- Prüfen, ob wir in einem lokalen Projekt-venv sind (optionaler Bonus)
--           local venv = vim.fn.getcwd() .. "/.venv/bin/python"

--           if vim.fn.executable(venv) == 1 then
--               -- Wenn Projekt-Venv da ist, nutze das (debugpy muss dort AUCH installiert sein)
--               dap_python.setup(venv)
--           else
--               -- Sonst nutze immer den globalen Mason-Debugger (sicherste Methode)
--               dap_python.setup(mason_path)
--           end

--           dap_python.test_runner = "pytest"
--       else
--           vim.notify("dap-python konnte nicht geladen werden", vim.log.levels.WARN)
--       end
--     end,
--   },

--   -- {
--   --   "Weissle/persistent-breakpoints.nvim",
--   --   config = function()
--   --     require("persistent-breakpoints").setup({
--   --       save_dir = vim.fn.stdpath("data") .. "/breakpoints",
--   --       load_breakpoints_event = { "BufReadPost" },
--   --     })
--   --   end,
--   -- },
-- }

return {
	{
		"mfussenegger/nvim-dap",
		cmd = { "DapContinue", "DapToggleBreakpoint", "DapUI" },

		dependencies = {
			{
				"rcarriga/nvim-dap-ui",
				dependencies = { "nvim-neotest/nvim-nio" },
			},
			"jay-babu/mason-nvim-dap.nvim",
			"mfussenegger/nvim-dap-python",
			"theHamsta/nvim-dap-virtual-text",
			"Weissle/persistent-breakpoints.nvim",

			-- OPTIONAL (safe geladen)
			"nvim-telescope/telescope.nvim",
			"nvim-telescope/telescope-dap.nvim",
		},

		config = function()
			local dap = require("dap")
			local dapui = require("dapui")

			-- MASON (ROBUST)
			require("mason-nvim-dap").setup({
				ensure_installed = { "codelldb", "python" },
				automatic_installation = true,
			})

			-- UI (STABIL + LESBAR)
			dapui.setup({
				expand_lines = true,
				render = {
					max_type_length = 80,
					max_value_lines = 20,
				},
				layouts = {
					{
						elements = {
							{ id = "scopes", size = 0.35 },
							{ id = "stacks", size = 0.20 },
							{ id = "breakpoints", size = 0.15 },
							{ id = "watches", size = 0.30 },
						},
						size = 50,
						position = "left",
					},
					{
						elements = {
							"repl",
							"console",
						},
						size = 12,
						position = "bottom",
					},
				},
			})

			-- WRAP FIX (SEHR WICHTIG)
			vim.api.nvim_create_autocmd("FileType", {
				pattern = { "dapui_*" },
				callback = function()
					vim.wo.wrap = true
					vim.wo.linebreak = true
					vim.wo.breakindent = true
				end,
			})

			-- INLINE VALUES
			require("nvim-dap-virtual-text").setup({
				highlight_changed_variables = true,
				show_stop_reason = true,
			})

			-- BREAKPOINTS
			require("persistent-breakpoints").setup({
				load_breakpoints_event = { "BufReadPost" },
			})

			-- AUTO UI
			dap.listeners.after.event_initialized["dapui"] = function()
				dapui.open()
			end
			dap.listeners.before.event_terminated["dapui"] = function()
				dapui.close()
			end
			dap.listeners.before.event_exited["dapui"] = function()
				dapui.close()
			end

			-- CODELLDB (ULTRA STABLE)
			dap.adapters.codelldb = {
				type = "server",
				port = "${port}",
				executable = {
					command = "codelldb",
					args = { "--port", "${port}" },
				},
				enrich_config = function(config, on_config)
					config.initCommands = {
						"settings set target.x86-disassembly-flavor intel",
						'settings set frame-format "{frame.pc} {function.name}\\n"',
					}
					on_config(config)
				end,
			}

			-- RUST (BEST PRACTICE)
			local function get_rust_binary()
				-- versuche cargo metadata (beste methode)
				local cwd = vim.fn.getcwd()
				local handle = io.popen("cargo metadata --format-version 1 --no-deps 2>/dev/null")
				if handle then
					local result = handle:read("*a")
					handle:close()

					local ok, json = pcall(vim.fn.json_decode, result)
					if ok and json and json.packages then
						local name = json.packages[1].name
						return cwd .. "/target/debug/" .. name
					end
				end

				-- fallback
				local crate = vim.fn.fnamemodify(cwd, ":t")
				return cwd .. "/target/debug/" .. crate
			end

			dap.configurations.rust = {
				{
					name = "Debug Rust (cargo)",
					type = "codelldb",
					request = "launch",
					program = get_rust_binary,
					cwd = "${workspaceFolder}",
					stopOnEntry = false,
					args = function()
						return vim.split(vim.fn.input("Args: "), " ")
					end,
				},
			}

			-- C / C++
			-- dap.configurations.cpp = {
			--   {
			--     name = "Debug binary",
			--     type = "codelldb",
			--     request = "launch",
			--     program = function()
			--       return vim.fn.input("Binary: ", vim.fn.getcwd() .. "/", "file")
			--     end,
			--     cwd = "${workspaceFolder}",
			--     stopOnEntry = false,
			--   },
			-- }
			-- dap.configurations.c = dap.configurations.cpp

			local function get_cpp_binary()
				local cwd = vim.fn.getcwd()

				local candidates = {
					cwd .. "/build/app",
					cwd .. "/build/main",
					cwd .. "/a.out",
				}

				for _, path in ipairs(candidates) do
					if vim.fn.filereadable(path) == 1 then
						return path
					end
				end

				-- fallback → user input
				return vim.fn.input("Binary: ", cwd .. "/", "file")
			end

			dap.configurations.cpp = {
				{
					name = "Debug (auto)",
					type = "codelldb",
					request = "launch",
					program = get_cpp_binary,
					cwd = "${workspaceFolder}",
					stopOnEntry = false,
				},
			}

			dap.configurations.c = dap.configurations.cpp

			-- PYTHON (ROBUST)
			-- local function get_python()
			--   local cwd = vim.fn.getcwd()
			--   local venvs = {
			--     cwd .. "/.venv/bin/python",
			--     cwd .. "/venv/bin/python",
			--   }

			--   for _, v in ipairs(venvs) do
			--     if vim.fn.executable(v) == 1 then
			--       return v
			--     end
			--   end

			--   return "python3"
			-- end

			-- require("dap-python").setup(get_python())

			local mason_path = vim.fn.stdpath("data") .. "/mason/packages/debugpy/venv/bin/python"

			require("dap-python").setup(mason_path)

			-- TELESCOPE (SAFE LOAD!)
			local ok_telescope, telescope = pcall(require, "telescope")
			if ok_telescope then
				pcall(telescope.load_extension, "dap") -- KEIN CRASH MEHR
			end

			-- KEYMAPS (STABIL)
			local map = vim.keymap.set

			-- map("n", "<F5>", dap.continue)
			-- map("n", "<F10>", dap.step_over)
			-- map("n", "<F11>", dap.step_into)
			-- map("n", "<F12>", dap.step_out)

			-- map("n", "<leader>b", dap.toggle_breakpoint)
			-- map("n", "<leader>dr", dap.repl.open)

			map("n", "<leader>ds", function()
				pcall(function()
					require("telescope").extensions.dap.frames()
				end)
			end)

			-- SIGNS
			vim.fn.sign_define("DapBreakpoint", {
				text = "●",
				texthl = "DiagnosticError",
			})

			vim.fn.sign_define("DapStopped", {
				text = "▶",
				texthl = "DiagnosticWarn",
			})
		end,
	},
}
