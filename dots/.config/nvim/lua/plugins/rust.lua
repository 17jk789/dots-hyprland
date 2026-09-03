-- plugins/rust.lua

-- return {
--   {
--     "Saecki/crates.nvim",
--     ft = { "rust", "toml" },
--     config = function()
--       require("crates").setup()
--     end,
--   },
-- }

-- return {
--   {
--     "simrat39/rust-tools.nvim", -- alt!!!
--     ft = { "rust" },
--     dependencies = {
--       "neovim/nvim-lspconfig",
--       "nvim-lua/plenary.nvim",
--     },
--     opts = function()
--       return {
--         server = {
--           on_attach = function(_, bufnr)
--             local opts = { noremap = true, silent = true, buffer = bufnr }
--             vim.keymap.set("n", "<Leader>rr", ":split | terminal cargo run<CR>", opts)
--             vim.keymap.set("n", "<Leader>rd", ":split | terminal cargo debug<CR>i", opts)
--             vim.keymap.set("n", "<Leader>rh", "<cmd>RustHoverActions<CR>", opts)
--             vim.keymap.set("n", "<Leader>rc", "<cmd>RustOpenCargo<CR>", opts)
--           end,
--           settings = {
--             ["rust-analyzer"] = {
--               cargo = { allFeatures = true },
--               checkOnSave = { command = "clippy" },
--               inlayHints = {
--                 enable = true,
--                 typeHints = true,
--                 parameterHints = true,
--                 lifetimeElisionHints = "always",
--               },
--             },
--           },
--         },
--       }
--     end,
--   },

--   {
--     "Saecki/crates.nvim",
--     ft = { "rust", "toml" },
--     config = function()
--       require("crates").setup()
--     end,
--   },
-- }

-- return {
--   {
--     "simrat39/rust-tools.nvim", -- This repository was archived by the owner on Jan 3, 2024. It is now read-only.
--     ft = { "rust" },
--     dependencies = {
--       "neovim/nvim-lspconfig",
--       "nvim-lua/plenary.nvim",
--     },
--     opts = function()
--       return {
--         server = {
--           on_attach = function(_, bufnr)
--             local opts = { noremap = true, silent = true, buffer = bufnr }

--             vim.keymap.set("n", "<Leader>rr", ":split | terminal cargo run<CR>", opts)
--             vim.keymap.set("n", "<Leader>rd", ":split | terminal cargo debug<CR>i", opts)
--             vim.keymap.set("n", "<Leader>rb", ":split | terminal cargo build<CR>i", opts)
--             vim.keymap.set("n", "<Leader>rh", "<cmd>RustHoverActions<CR>", opts)
--             vim.keymap.set("n", "<Leader>rc", "<cmd>RustOpenCargo<CR>", opts)

--             -- Auto Reload: Rust Analyzer neu laden wenn neue Datei erstellt wird
--             -- vim.api.nvim_create_autocmd({ "BufWritePost", "BufEnter" }, {
--             --   pattern = { "*.rs", "Cargo.toml" },
--             --   callback = function()
--             --     -- nur wenn rust-tools aktiv ist
--             --     local ok, _ = pcall(vim.cmd, "RustReloadWorkspace")
--             --     if not ok then
--             --       -- fallback: LSP Restart
--             --       pcall(vim.cmd, "LspRestart")
--             --     end
--             --   end,
--             -- })
--           end,

--           settings = {
--             ["rust-analyzer"] = {
--               diagnostics = {
--                 disabled = { "unresolved-proc-macro", "unlinked-file" },
--               },
--               cargo = { allFeatures = true },
--               checkOnSave = { command = "clippy" },
--               inlayHints = {
--                 enable = true,
--                 typeHints = true,
--                 parameterHints = true,
--                 lifetimeElisionHints = "always",
--               },
--             },
--           },
--         },
--       }
--     end,
--   },

--   {
--     "Saecki/crates.nvim",
--     ft = { "rust", "toml" },
--     config = function()
--       require("crates").setup()
--     end,
--   },
-- }

-- return {
--   {
--     "simrat39/rust-tools.nvim", -- This repository was archived by the owner on Jan 3, 2024. It is now read-only.
--     ft = { "rust" },
--     dependencies = {
--       "neovim/nvim-lspconfig",
--       "nvim-lua/plenary.nvim",
--     },
--     opts = function()
--       return {
--         server = {
--           on_attach = function(_, bufnr)
--             local opts = { noremap = true, silent = true, buffer = bufnr }

--             vim.keymap.set("n", "<Leader>rr", ":split | terminal cargo run<CR>", opts)
--             vim.keymap.set("n", "<Leader>rd", ":split | terminal cargo debug<CR>i", opts)
--             vim.keymap.set("n", "<Leader>rb", ":split | terminal cargo build<CR>i", opts)
--             vim.keymap.set("n", "<Leader>rh", "<cmd>RustHoverActions<CR>", opts)
--             vim.keymap.set("n", "<Leader>rc", "<cmd>RustOpenCargo<CR>", opts)

--             -- Auto Reload: Rust Analyzer neu laden wenn neue Datei erstellt wird
--             -- vim.api.nvim_create_autocmd({ "BufWritePost", "BufEnter" }, {
--             --   pattern = { "*.rs", "Cargo.toml" },
--             --   callback = function()
--             --     -- nur wenn rust-tools aktiv ist
--             --     local ok, _ = pcall(vim.cmd, "RustReloadWorkspace")
--             --     if not ok then
--             --       -- fallback: LSP Restart
--             --       pcall(vim.cmd, "LspRestart")
--             --     end
--             --   end,
--             -- })
--           end,

--           settings = {
--             ["rust-analyzer"] = {
--               diagnostics = {
--                 disabled = {
--                   "unresolved-proc-macro",
--                   "unlinked-file",
--                 },
--                 experimental = {
--                   enable = true,
--                 },
--               },

--               cargo = {
--                 allFeatures = true,
--                 buildScripts = {
--                   enable = true,
--                 },
--               },

--               procMacro = {
--                 enable = true,
--               },

--               lens = {
--                 enable = true,
--               },

--               completion = {
--                 autoimport = {
--                   enable = true,
--                 },
--               },

--               checkOnSave = {
--                 command = "clippy",
--               },

--               inlayHints = {
--                 enable = true,
--                 typeHints = true,
--                 parameterHints = true,
--                 lifetimeElisionHints = "always",
--                 closureReturnTypeHints = {
--                   enable = "always",
--                 },
--                 bindingModeHints = {
--                   enable = true,
--                 },
--               },

--               files = {
--                 watcher = "client",
--               },
--             }
--           },
--         },
--       }
--     end,
--   },

--   {
--     "Saecki/crates.nvim",
--     ft = { "rust", "toml" },
--     config = function()
--       require("crates").setup()
--     end,
--   },
-- }

-- return {
--   {
--     "Saecki/crates.nvim",
--     ft = { "rust", "toml" },
--     config = function()
--       require("crates").setup({
--         completion = {
--           cmp = { enabled = true },
--         },
--         popup = {
--           border = "rounded",
--         },
--       })
--     end,
--   },
-- }

-- return {
--   {
--     "Saecki/crates.nvim",
--     ft = { "toml" },
--     dependencies = {
--       "nvim-lua/plenary.nvim",
--       "hrsh7th/nvim-cmp",
--     },
--     config = function()
--       local ok, crates = pcall(require, "crates")
--       if not ok then
--         return
--       end

--       crates.setup({
--         completion = {
--           cmp = { enabled = true },
--         },
--         popup = {
--           border = "rounded",
--         },
--       })
--     end,
--   },
-- }

-- return {
--   -- {
--   --   "Saecki/crates.nvim",
--   --   ft = { "toml" },
--   --   dependencies = {
--   --     "nvim-lua/plenary.nvim",
--   --     -- "hrsh7th/nvim-cmp", -- blink.cmp braucht das nicht, sonst lädst du unnötig nvim-cmp mit
--   --   },
--   --   config = function()
--   --     require("crates").setup({
--   --       popup = {
--   --         border = "rounded",
--   --       },
--   --     })
--   --   end,
--   -- },

--   {
--     "Saecki/crates.nvim",
--     ft = { "toml" },
--     event = { "BufRead Cargo.toml" }, -- lädt nur bei Cargo.toml
--     dependencies = {
--       "nvim-lua/plenary.nvim",
--     },
--     opts = {
--       popup = {
--         border = "rounded",
--       },
--       completion = {
--         crates = {
--           enabled = true,
--         },
--       },
--     },
--   },

--   -- {
--   --   "nvim-neotest/neotest",
--   --   dependencies = {
--   --     "nvim-neotest/nvim-nio",
--   --     "rouge8/neotest-rust", -- Dieser Adapter ist LSP-unabhängig - aber This repository was archived by the owner on Aug 19, 2025. It is now read-only.
--   --   },
--   --   config = function()
--   --     require("neotest").setup({
--   --       adapters = {
--   --         require("neotest-rust")({
--   --           args = { "--nocapture" },
--   --           -- Er erkennt Tests über Treesitter, egal was dein LSP macht
--   --         }),
--   --       },
--   --     })
--   --   end,
--   -- },

--   {
--     "stevearc/aerial.nvim",
--     ft = { "rust" }, -- toml/lua nicht nötig, wenn Rust-only
--     keys = {
--       { "<leader>rua", "<cmd>AerialToggle! right<CR>", desc = "Rust Outline" },
--     },
--     opts = {
--       backends = { "lsp" }, -- nur LSP wenn rust-analyzer gut konfiguriert
--       layout = {
--         min_width = 35,
--         default_direction = "right",
--         placement = "window",
--       },
--       attach_mode = "global",
--       show_guides = true,
--       close_on_select = true,
--       filter_kind = false, -- professioneller: nichts hart filtern
--     },
--   }
-- }

return {
  {
    "mrcjkb/rustaceanvim",
    -- version = "^8",
    ft = { "rust" },

    config = function()
      vim.g.rustaceanvim = {

        -------------------------
        -- TOOLS
        -------------------------

        tools = {
          autoSetHints = true,

          hover_actions = {
            auto_focus = true,
          },

          inlay_hints = {
            auto = true,
            show_parameter_hints = true,
            parameter_hints_prefix = " ",
            other_hints_prefix = "=> ",
          },
        },

        -------------------------
        -- LSP SERVER
        -------------------------

        server = {

          on_attach = function(_, bufnr)
            -- local map = function(keys, func, desc)
            --   vim.keymap.set("n", keys, func, { buffer = bufnr, desc = desc })
            -- end

            local map = function(keys, func, desc)
              vim.keymap.set("n", keys, func, {
                buffer = bufnr,
                desc = desc or "",
              })
            end

            -- Rust spezielle Features

            map("<leader>re", function()
              vim.cmd.RustLsp("expandMacro")
            end, "Expand Macro")

            map("<leader>rh", function()
              vim.cmd.RustLsp("hoverActions")
            end, "Hover Actions")

            map("<leader>rca", function()
              vim.cmd.RustLsp("codeAction")
            end, "Rust Code Action")

            map("<leader>rj", function()
              vim.cmd.RustLsp("joinLines")
            end, "Join Lines")

            map("<leader>rr", function()
              vim.cmd.RustLsp("runnables")
            end, "Rust Runnables")

            map("<leader>rd", function()
              vim.cmd.RustLsp("debuggables")
            end, "Rust Debuggables")

            map("<leader>rt", function()
              vim.cmd.RustLsp("testables")
            end, "Rust Testables")

            map("<leader>rrx", function()
              vim.cmd("!cargo clippy --all --all-features -- -Dwarnings")
            end, "Run full clippy")
          end,

          -------------------------
          -- rust-analyzer settings
          -------------------------

          default_settings = {
            ["rust-analyzer"] = {

              diagnostics = {
                enable = true,
                experimental = {
                  enable = true,
                },
              },

              -------------------------
              -- Clippy on Save
              -------------------------

              -- checkOnSave = {
              -- command = "clippy",

              -- This enables full Clippy analysis on every save.
              -- It is very accurate but also a CPU-heavy operation ("CPU killer"),
              -- especially in large projects or WSL environments.
              -- extraArgs = {
              --   "--all",
              --   "--all-features",
              --   "--",
              --   "-Dwarnings",
              -- },
              -- },

              checkOnSave = true,

              check = {
                command = "clippy",
              },

              -------------------------
              -- Cargo
              -------------------------

              cargo = {
                allFeatures = true,
                buildScripts = {
                  enable = true,
                },
                loadOutDirsFromCheck = true,
                autoreload = true,
              },

              -------------------------
              -- Proc Macros
              -------------------------

              procMacro = {
                enable = true,
              },

              -------------------------
              -- Completion
              -------------------------

              -- completion = {

              --   autoimport = {
              --     enable = true,
              --   },

              --   autoself = {
              --     enable = true,
              --   },

              --   postfix = {
              --     enable = true,
              --   },

              --   callable = {
              --     snippets = "fill_arguments",
              --   },

              --   fullFunctionSignatures = {
              --     enable = true,
              --   },
              -- },

              completion = {
                autoimport = {
                  enable = true,
                },

                autoself = {
                  enable = true,
                },

                postfix = {
                  enable = true,
                },

                callable = {
                  snippets = "fill_arguments",
                  -- snippets = "none", -- momenates Problem neovim 0.12
                },

                fullFunctionSignatures = {
                  enable = true,
                },

                completionItemLabelDetails = {
                  enable = true,
                },

                -- limit = {
                --   maxItems = 200,
                -- },

                hideDeprecated = true,
              },

              -------------------------
              -- Inlay hints
              -------------------------

              -- inlayHints = {

              --   bindingModeHints = {
              --     enable = true,
              --   },

              --   chainingHints = {
              --     enable = true,
              --   },

              --   closingBraceHints = {
              --     enable = true,
              --     minLines = 1,
              --   },

              --   closureReturnTypeHints = {
              --     enable = "always",
              --   },

              --   lifetimeElisionHints = {
              --     enable = "always",
              --     useParameterNames = true,
              --   },

              --   parameterHints = {
              --     enable = true,
              --   },

              --   typeHints = {
              --     enable = true,
              --   },
              -- },

              inlayHints = {
                bindingModeHints = {
                  enable = true,
                },

                chainingHints = {
                  enable = true,
                },

                closingBraceHints = {
                  enable = true,
                  minLines = 1,
                },

                closureReturnTypeHints = {
                  enable = "always",
                },

                lifetimeElisionHints = {
                  enable = "always",
                  useParameterNames = true,
                },

                parameterHints = {
                  enable = true,
                },

                typeHints = {
                  enable = true,
                },

                renderColons = true,
                locationLinks = true,

                maxLength = 25,
              },

              -------------------------
              -- CodeLens
              -------------------------

              -- lens = {
              --   enable = true,
              --   run = true,
              --   debug = true,
              --   implementations = true,
              --   references = true,
              -- },

              lens = {
                enable = true,
                run = true,
                debug = true,
                implementations = true,
                references = true,
                refresh = true,
              },

              -------------------------
              -- Hover
              -------------------------

              hover = {
                actions = {
                  enable = true,
                },
              },

              -------------------------
              -- Performance Boost
              -------------------------

              files = {
                -- watcher = "client",
                watcher = "server",
              },
            },
          },
        },

        -------------------------
        -- Debug Adapter
        -------------------------

        dap = {
          adapter = require("rustaceanvim.config").get_codelldb_adapter(
            vim.fn.stdpath("data") .. "/mason/packages/codelldb/extension/adapter/codelldb",
            vim.fn.stdpath("data") .. "/mason/packages/codelldb/extension/lldb/lib/liblldb.so"
          ),
        },
      }
    end,
  },

  -- crates bleibt gleich (perfekt)
  {
    "Saecki/crates.nvim",
    ft = { "toml" },
    -- event = { "BufRead Cargo.toml" },
    event = { "BufReadPre Cargo.toml" },
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    opts = {
      popup = { border = "rounded" },
      completion = {
        crates = { enabled = true },
      },
    },
  },

  -- outline bleibt gleich
  {
    "stevearc/aerial.nvim",
    ft = { "rust" },
    keys = {
      { "<leader>rua", "<cmd>AerialToggle! right<CR>", desc = "Rust Outline" },
    },
    opts = {
      backends = { "lsp" },
      layout = {
        min_width = 35,
        default_direction = "right",
      },
      attach_mode = "global",
      show_guides = true,
      close_on_select = true,
    },
  },

  -- Neotest (modern + kompatibel mit deinem Setup)
  -- {
  --   "nvim-neotest/neotest",
  --   dependencies = {
  --     "nvim-neotest/nvim-nio",
  --     "rouge8/neotest-rust",
  --   },
  --   config = function()
  --     -- require("neotest").setup({
  --     --   adapters = {
  --     --     require("neotest-rust")({
  --     --       args = { "--all-features", "--nocapture" },
  --     --       dap_adapter = "lldb",
  --     --     }),
  --     --   },
  --     -- })
  --     require("neotest").setup({
  --       adapters = {
  --         require("neotest-rust")({
  --           args = { "--all-features" },
  --           dap_adapter = "codelldb",
  --         }),
  --       },
  --     })
  --   end,
  -- },

  {
    "nvim-neotest/neotest",
    ft = { "rust" },
    dependencies = {
      "nvim-neotest/nvim-nio",
      "rouge8/neotest-rust",
    },
    config = function()
      require("neotest").setup({
        adapters = {
          require("neotest-rust")({
            args = { "--all-features" },
            dap_adapter = "codelldb",
          }),
        },
      })
    end,
  },

  {
    "stevearc/conform.nvim",
    opts = function(_, opts)
      opts.formatters_by_ft = opts.formatters_by_ft or {}
      opts.formatters_by_ft.rust = { "rustfmt" }
    end,
  },
}
