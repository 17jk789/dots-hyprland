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
  {
    "esensar/nvim-dev-container",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
    },

    opts = {
      -- ============================================================
      -- Docker
      -- ============================================================

      container_runtime = "docker",
      cache_images = true,

      -- Deine Neovim-Konfiguration auch im Container verwenden.
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

      -- ============================================================
      -- Helper
      -- ============================================================

      -- Dein Container heißt genauso wie das Projektverzeichnis.
      --
      -- Beispiel:
      --   ~/test3/testjk
      --
      -- -> Docker:
      --   testjk
      --
      local function get_container_name()
        return vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
      end

      -- Docker-Befehl ausführen.
      local function docker(args)
        return vim.fn.system("docker " .. args)
      end

      -- Prüfen, ob der Container existiert.
      local function container_exists(name)
        local result = docker(
          "inspect -f '{{.Id}}' "
            .. vim.fn.shellescape(name)
            .. " 2>/dev/null"
        )

        return vim.v.shell_error == 0 and result ~= ""
      end

      -- Prüfen, ob der Container läuft.
      local function container_running(name)
        local result = docker(
          "inspect -f '{{.State.Running}}' "
            .. vim.fn.shellescape(name)
            .. " 2>/dev/null"
        )

        return vim.v.shell_error == 0
          and vim.trim(result) == "true"
      end

      -- Container starten, falls er existiert und gestoppt ist.
      local function ensure_container_running(name)
        if not container_exists(name) then
          vim.notify(
            "Docker-Container '" .. name .. "' wurde nicht gefunden.",
            vim.log.levels.ERROR
          )
          return false
        end

        if not container_running(name) then
          vim.notify(
            "Starte Docker-Container: " .. name,
            vim.log.levels.INFO
          )

          vim.fn.system(
            "docker start " .. vim.fn.shellescape(name)
          )

          if vim.v.shell_error ~= 0 then
            vim.notify(
              "Container konnte nicht gestartet werden: " .. name,
              vim.log.levels.ERROR
            )
            return false
          end
        end

        return true
      end

      -- ============================================================
      -- Neovim im bestehenden Container starten
      -- ============================================================

      local function attach_current_container()
        local container_name = get_container_name()

        if not ensure_container_running(container_name) then
          return
        end

        vim.notify(
          "Starte Neovim im Container: " .. container_name,
          vim.log.levels.INFO
        )

        -- WICHTIG:
        --
        -- Wir verwenden NICHT:
        --
        --   attach_auto(container_name, "nvim")
        --
        -- weil nvim-dev-container dadurch seine eigene
        -- Neovim-Installationslogik auslösen kann.
        --
        -- Dein Container enthält bereits:
        --
        --   /usr/bin/nvim
        --
        -- Deshalb starten wir genau dieses Binary direkt.
        --
        vim.cmd(
          "terminal docker exec -it "
            .. vim.fn.shellescape(container_name)
            .. " /usr/bin/nvim"
        )
      end

      -- ============================================================
      -- Dev Container
      -- ============================================================

      map("n", "<leader>dca", attach_current_container, {
        desc = "[D]ev [C]ontainer [A]ttach Neovim",
      })

      map("n", "<leader>dco", attach_current_container, {
        desc = "[D]ev [C]ontainer [O]pen Neovim",
      })

      map("n", "<leader>dcx", function()
        local container_name = get_container_name()

        if not container_exists(container_name) then
          vim.notify(
            "Container nicht gefunden: " .. container_name,
            vim.log.levels.ERROR
          )
          return
        end

        vim.fn.system(
          "docker stop " .. vim.fn.shellescape(container_name)
        )

        vim.notify(
          "Container gestoppt: " .. container_name,
          vim.log.levels.INFO
        )
      end, {
        desc = "[D]ev [C]ontainer Stop",
      })

      map("n", "<leader>dce", function()
        local container_name = get_container_name()

        if not ensure_container_running(container_name) then
          return
        end

        vim.cmd(
          "terminal docker exec -it "
            .. vim.fn.shellescape(container_name)
            .. " fish"
        )
      end, {
        desc = "[D]ev [C]ontainer [E]xec Fish",
      })

      map("n", "<leader>dcl", function()
        local container_name = get_container_name()

        if not container_exists(container_name) then
          vim.notify(
            "Container nicht gefunden: " .. container_name,
            vim.log.levels.ERROR
          )
          return
        end

        vim.cmd(
          "terminal docker logs -f "
            .. vim.fn.shellescape(container_name)
        )
      end, {
        desc = "[D]ev [C]ontainer [L]ogs",
      })

      -- ============================================================
      -- Python
      -- ============================================================

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

      map("n", "<leader>pc", "<cmd>!python --version<cr>", {
        desc = "[P]ython version [C]heck",
      })

      -- ============================================================
      -- uv
      -- ============================================================

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

      -- ============================================================
      -- Jupyter
      -- ============================================================

      map(
        "n",
        "<leader>jn",
        "<cmd>!jupyter notebook --ip=0.0.0.0 --port=8888 --no-browser<cr>",
        {
          desc = "[J]upyter [N]otebook",
        }
      )

      map(
        "n",
        "<leader>jl",
        "<cmd>!jupyter lab --ip=0.0.0.0 --port=8888 --no-browser<cr>",
        {
          desc = "[J]upyter [L]ab",
        }
      )

      map("n", "<leader>jv", "<cmd>!jupyter --version<cr>", {
        desc = "[J]upyter [V]ersion",
      })

      -- ============================================================
      -- Docker
      -- ============================================================

      map("n", "<leader>db", function()
        vim.cmd("terminal docker build -t python-dev .")
      end, {
        desc = "[D]ocker [B]uild",
      })

      map("n", "<leader>dr", function()
        vim.cmd("terminal docker ps")
      end, {
        desc = "[D]ocker [R]unning containers",
      })

      map("n", "<leader>di", function()
        vim.cmd("terminal docker images")
      end, {
        desc = "[D]ocker [I]mages",
      })

      -- ============================================================
      -- Terminal
      -- ============================================================

      map("n", "<leader>tt", "<cmd>terminal<cr>", {
        desc = "[T]erminal",
      })
    end,
  },
}
