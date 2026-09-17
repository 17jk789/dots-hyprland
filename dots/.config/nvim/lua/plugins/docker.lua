-- return {
--     "esensar/nvim-dev-container",

--     dependencies = {
--         "nvim-treesitter/nvim-treesitter",
--     },

--     opts = {
--         -- ============================================================
--         -- Dev Container
--         -- ============================================================

--         -- Neovim-Konfiguration in den Container mounten.
--         -- Dadurch verwendet Neovim IM Container dieselbe
--         -- LazyVim/Neovim-Konfiguration wie auf dem Host.
--         attach_mounts = {
--             neovim_config = {
--                 enabled = true,
--             },

--             -- Plugin-/Lazy-Daten ebenfalls teilen.
--             -- Dadurch müssen Plugins nicht bei jedem Container
--             -- neu installiert werden.
--             neovim_data = {
--                 enabled = true,
--             },

--             -- Neovim State mitnehmen.
--             neovim_state = {
--                 enabled = true,
--             },
--         },

--         -- Docker explizit verwenden.
--         container_runtime = "docker",

--         -- Cache verwenden, damit Attach schneller wird.
--         cache_images = true,
--     },

--     config = function(_, opts)
--         require("devcontainer").setup(opts)

--         local map = vim.keymap.set

--         -- ============================================================
--         -- Dev Container
--         -- ============================================================

--         -- Container starten
--         map(
--             "n",
--             "<leader>dco",
--             "<cmd>DevcontainerStart<cr>",
--             { desc = "[D]ev [C]ontainer [O]pen/Start" }
--         )

--         -- Neovim im Container öffnen.
--         -- Das ist der eigentliche VS-Code-ähnliche Workflow.
--         map(
--             "n",
--             "<leader>dca",
--             "<cmd>DevcontainerAttach<cr>",
--             { desc = "[D]ev [C]ontainer [A]ttach / Open Neovim" }
--         )

--         -- Container stoppen
--         map(
--             "n",
--             "<leader>dcx",
--             "<cmd>DevcontainerStop<cr>",
--             { desc = "[D]ev [C]ontainer Stop" }
--         )

--         -- Container-Befehl ausführen
--         map(
--             "n",
--             "<leader>dce",
--             "<cmd>DevcontainerExec<cr>",
--             { desc = "[D]ev [C]ontainer [E]xec" }
--         )

--         -- Container-Logs
--         map(
--             "n",
--             "<leader>dcl",
--             "<cmd>DevcontainerLogs<cr>",
--             { desc = "[D]ev [C]ontainer [L]ogs" }
--         )

--         -- ============================================================
--         -- Python
--         -- ============================================================

--         -- Python-Datei im Container ausführen
--         map(
--             "n",
--             "<leader>py",
--             "<cmd>!python %<cr>",
--             { desc = "[Py]thon Run current file" }
--         )

--         map(
--             "n",
--             "<leader>pt",
--             "<cmd>!pytest<cr>",
--             { desc = "[P]ytest Run [T]ests" }
--         )

--         map(
--             "n",
--             "<leader>pf",
--             "<cmd>!black src tests<cr>",
--             { desc = "[P]ython [F]ormat" }
--         )

--         map(
--             "n",
--             "<leader>pm",
--             "<cmd>!mypy src<cr>",
--             { desc = "[P]ython [M]ypy" }
--         )

--         map(
--             "n",
--             "<leader>pb",
--             "<cmd>!bandit -r src<cr>",
--             { desc = "[P]ython [B]andit security scan" }
--         )

--         -- ============================================================
--         -- uv
--         -- ============================================================

--         map(
--             "n",
--             "<leader>ua",
--             "<cmd>!uv add<space>",
--             { desc = "[U]v [A]dd dependency" }
--         )

--         map(
--             "n",
--             "<leader>us",
--             "<cmd>!uv sync<cr>",
--             { desc = "[U]v [S]ync" }
--         )

--         map(
--             "n",
--             "<leader>ur",
--             "<cmd>!uv run<space>",
--             { desc = "[U]v [R]un command" }
--         )

--         map(
--             "n",
--             "<leader>ul",
--             "<cmd>!uv pip list<cr>",
--             { desc = "[U]v [L]ist packages" }
--         )

--         -- ============================================================
--         -- Jupyter
--         -- ============================================================

--         map(
--             "n",
--             "<leader>jn",
--             "<cmd>!jupyter notebook --ip=0.0.0.0 --port=8888 --no-browser<cr>",
--             { desc = "[J]upyter [N]otebook" }
--         )

--         map(
--             "n",
--             "<leader>jl",
--             "<cmd>!jupyter lab --ip=0.0.0.0 --port=8888 --no-browser<cr>",
--             { desc = "[J]upyter [L]ab" }
--         )

--         -- ============================================================
--         -- Docker
--         -- ============================================================

--         map(
--             "n",
--             "<leader>db",
--             "<cmd>!docker build -t python-dev .<cr>",
--             { desc = "[D]ocker [B]uild" }
--         )

--         map(
--             "n",
--             "<leader>dr",
--             "<cmd>!docker ps<cr>",
--             { desc = "[D]ocker [R]unning containers" }
--         )

--         map(
--             "n",
--             "<leader>di",
--             "<cmd>!docker images<cr>",
--             { desc = "[D]ocker [I]mages" }
--         )

--         -- ============================================================
--         -- Terminal
--         -- ============================================================

--         map(
--             "n",
--             "<leader>tt",
--             "<cmd>terminal<cr>",
--             { desc = "[T]erminal" }
--         )

--         -- ============================================================
--         -- Quick commands
--         -- ============================================================

--         map(
--             "n",
--             "<leader>pc",
--             "<cmd>!python --version<cr>",
--             { desc = "[P]ython version [C]heck" }
--         )

--         map(
--             "n",
--             "<leader>uv",
--             "<cmd>!uv --version<cr>",
--             { desc = "[U]v [V]ersion" }
--         )

--         map(
--             "n",
--             "<leader>jv",
--             "<cmd>!jupyter --version<cr>",
--             { desc = "[J]upyter [V]ersion" }
--         )
--     },
-- }

return {
	"esensar/nvim-dev-container",

	dependencies = {
		"nvim-treesitter/nvim-treesitter",
	},

	opts = {
		container_runtime = "docker",
		cache_images = true,

		attach_mounts = {
			neovim_config = {
				enabled = true,
			},
			neovim_data = {
				enabled = true,
			},
			neovim_state = {
				enabled = true,
			},
		},
	},

	config = function(_, opts)
		require("devcontainer").setup(opts)

		local map = vim.keymap.set

		-- =========================================================
		-- Dev Container
		-- =========================================================

		map("n", "<leader>dco", "<cmd>DevcontainerStart<cr>", {
			desc = "[D]ev [C]ontainer [O]pen / Start",
		})

		map("n", "<leader>dca", "<cmd>DevcontainerAttach<cr>", {
			desc = "[D]ev [C]ontainer [A]ttach",
		})

		map("n", "<leader>dcx", "<cmd>DevcontainerStop<cr>", {
			desc = "[D]ev [C]ontainer Stop",
		})

		map("n", "<leader>dce", "<cmd>DevcontainerExec<cr>", {
			desc = "[D]ev [C]ontainer [E]xec",
		})

		map("n", "<leader>dcl", "<cmd>DevcontainerLogs<cr>", {
			desc = "[D]ev [C]ontainer [L]ogs",
		})

		-- =========================================================
		-- Python
		-- =========================================================

		map("n", "<leader>py", "<cmd>!python %<cr>", {
			desc = "[Py]thon Run current file",
		})

		map("n", "<leader>pt", "<cmd>!pytest<cr>", {
			desc = "[P]ytest Run tests",
		})

		map("n", "<leader>pf", "<cmd>!black src tests<cr>", {
			desc = "[P]ython [F]ormat",
		})

		map("n", "<leader>pm", "<cmd>!mypy src<cr>", {
			desc = "[P]ython [M]ypy",
		})

		map("n", "<leader>pb", "<cmd>!bandit -r src<cr>", {
			desc = "[P]ython [B]andit security scan",
		})

		-- =========================================================
		-- uv
		-- =========================================================

		map("n", "<leader>ua", "<cmd>!uv add<space>", {
			desc = "[U]v [A]dd dependency",
		})

		map("n", "<leader>us", "<cmd>!uv sync<cr>", {
			desc = "[U]v [S]ync",
		})

		map("n", "<leader>ur", "<cmd>!uv run<space>", {
			desc = "[U]v [R]un command",
		})

		map("n", "<leader>ul", "<cmd>!uv pip list<cr>", {
			desc = "[U]v [L]ist packages",
		})

		map("n", "<leader>uv", "<cmd>!uv --version<cr>", {
			desc = "[U]v [V]ersion",
		})

		-- =========================================================
		-- Jupyter
		-- =========================================================

		map("n", "<leader>jn", "<cmd>!jupyter notebook --ip=0.0.0.0 --port=8888 --no-browser<cr>", {
			desc = "[J]upyter [N]otebook",
		})

		map("n", "<leader>jl", "<cmd>!jupyter lab --ip=0.0.0.0 --port=8888 --no-browser<cr>", {
			desc = "[J]upyter [L]ab",
		})

		map("n", "<leader>jv", "<cmd>!jupyter --version<cr>", {
			desc = "[J]upyter [V]ersion",
		})

		-- =========================================================
		-- Docker
		-- =========================================================

		map("n", "<leader>db", "<cmd>!docker build -t python-dev .<cr>", {
			desc = "[D]ocker [B]uild",
		})

		map("n", "<leader>dr", "<cmd>!docker ps<cr>", {
			desc = "[D]ocker [R]unning containers",
		})

		map("n", "<leader>di", "<cmd>!docker images<cr>", {
			desc = "[D]ocker [I]mages",
		})

		-- =========================================================
		-- Terminal
		-- =========================================================

		map("n", "<leader>tt", "<cmd>terminal<cr>", {
			desc = "[T]erminal",
		})

		-- =========================================================
		-- Environment
		-- =========================================================

		map("n", "<leader>pc", "<cmd>!python --version<cr>", {
			desc = "[P]ython version [C]heck",
		})
	end,
}
