-- -- plugins/csharp.lua

-- return {
--   -- Roslyn LSP
--   {
--     "seblj/roslyn.nvim",
--     ft = { "cs", "razor", "cshtml" },

--     config = function()
--       local capabilities = require("blink.cmp").get_lsp_capabilities()

--       require("roslyn").setup({
--         args = {
--           "--logLevel=Error",
--         },

--         config = {
--           capabilities = capabilities,

--           settings = {
--             ["csharp|inlay_hints"] = {
--               csharp_enable_inlay_hints_for_implicit_object_creation = true,
--               csharp_enable_inlay_hints_for_implicit_variable_types = true,
--               csharp_enable_inlay_hints_for_lambda_parameter_types = true,
--               csharp_enable_inlay_hints_for_types = true,
--             },
--           },
--         },
--       })

--       -- LSP Extras
--       local group = vim.api.nvim_create_augroup("RoslynExtras", {
--         clear = true,
--       })

--       vim.api.nvim_create_autocmd({
--         "BufEnter",
--         "CursorHold",
--         "InsertLeave",
--       }, {
--         group = group,
--         pattern = "*.cs",
--         callback = function()
--           pcall(vim.lsp.codelens.refresh)
--         end,
--       })

--       vim.api.nvim_create_autocmd("LspAttach", {
--         group = group,
--         callback = function(args)
--           local client = vim.lsp.get_client_by_id(args.data.client_id)

--           if client and client.name == "roslyn" then
--             pcall(function()
--               vim.lsp.inlay_hint.enable(true, {
--                 bufnr = args.buf,
--               })
--             end)
--           end
--         end,
--       })
--     end,
--   },

--   -- easy-dotnet
--   {
--     "GustavEikaas/easy-dotnet.nvim",

--     ft = {
--       "cs",
--       "csproj",
--       "sln",
--       "razor",
--       "cshtml",
--     },

--     dependencies = {
--       "nvim-lua/plenary.nvim",
--       "nvim-telescope/telescope.nvim",
--     },

--     config = function()
--       local dotnet = require("easy-dotnet")

--       dotnet.setup()

--       local opts = {
--         noremap = true,
--         silent = true,
--       }

--       local map = function(lhs, rhs, desc)
--         vim.keymap.set("n", lhs, rhs, vim.tbl_extend("force", opts, {
--           desc = desc,
--         }))
--       end

--     --   map("<leader>.r", dotnet.run, ".NET Run")
--     --   map("<leader>.b", dotnet.build, ".NET Build")
--     --   map("<leader>.s", dotnet.build_solution, ".NET Build Solution")
--     --   map("<leader>.t", dotnet.test, ".NET Test")
--     --   map("<leader>.n", dotnet.nuget, "NuGet")

--     --   map("<leader>.R", dotnet.restore, ".NET Restore")
--     --   map("<leader>.c", dotnet.clean, ".NET Clean")
--     --   map("<leader>.p", dotnet.publish, ".NET Publish")
--     -- ...
--     -- map("<leader>db", function() dotnet.build() end, ".NET Build")
--     -- map("<leader>dt", function() dotnet.test() end, ".NET Test")
--     -- map("<leader>dR", function() dotnet.restore() end, ".NET Restore")
--     -- map("<leader>dc", function() dotnet.clean() end, ".NET Clean")
--     -- map("<leader>di", function() dotnet.nuget() end, "NuGet")
--     -- map("<leader>do", function() dotnet.publish() end, ".NET Publish")
--     -- map("<leader>dx", function() dotnet.run() end, ".NET Run")
--     end,
--   },
-- }

-- plugins/csharp.lua

return {
  -- Roslyn LSP
  {
    "seblj/roslyn.nvim",
    ft = { "cs", "razor", "cshtml" },

    config = function()
      local capabilities = require("blink.cmp").get_lsp_capabilities()

      -- -- kill roslyn_ls permanently if roslyn.nvim is used
      -- local function stop_roslyn_ls()
      --   for _, client in ipairs(vim.lsp.get_clients()) do
      --     if client.name == "roslyn_ls" then
      --       vim.lsp.stop_client(client.id, true)
      --       vim.notify("roslyn_ls disabled (using roslyn.nvim)", vim.log.levels.WARN)
      --     end
      --   end
      -- end

      -- -- catch early start
      -- vim.api.nvim_create_autocmd("LspAttach", {
      --   callback = function()
      --     vim.schedule(stop_roslyn_ls)
      --   end,
      -- })

      -- -- catch late start (Mason / Lazy / ft load)
      -- vim.api.nvim_create_autocmd({ "BufEnter", "VimEnter" }, {
      --   callback = function()
      --     vim.schedule(stop_roslyn_ls)
      --   end,
      -- })

      require("roslyn").setup({
        args = {
          "--logLevel=Error",
        },

        config = {
          capabilities = capabilities,

          settings = {
            ["csharp|inlay_hints"] = {
              csharp_enable_inlay_hints_for_implicit_object_creation = true,
              csharp_enable_inlay_hints_for_implicit_variable_types = true,
              csharp_enable_inlay_hints_for_lambda_parameter_types = true,
              csharp_enable_inlay_hints_for_types = true,
            },
          },
        },
      })

      -- LSP Extras
      local group = vim.api.nvim_create_augroup("RoslynExtras", {
        clear = true,
      })

      vim.api.nvim_create_autocmd({
        "BufEnter",
        "CursorHold",
        "InsertLeave",
      }, {
        group = group,
        pattern = "*.cs",
        callback = function()
          pcall(vim.lsp.codelens.refresh)
        end,
      })

      vim.api.nvim_create_autocmd("LspAttach", {
        group = group,
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)

          if client and client.name == "roslyn" then
            pcall(function()
              vim.lsp.inlay_hint.enable(true, {
                bufnr = args.buf,
              })
            end)
          end
        end,
      })
    end,
  },

  -- easy-dotnet (TOOL ONLY, no LSP noise)
  {
    "GustavEikaas/easy-dotnet.nvim",

    ft = {
      "cs",
      "csproj",
      "sln",
      "razor",
      "cshtml",
    },

    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
    },

    config = function()
      local dotnet = require("easy-dotnet")

      require("easy-dotnet").setup({
        lsp = {
          enabled = false,
        },
        test_runner = {
          neotest_integration = false,
        },
      })

      -- optional: reduce LSP noise from easy-dotnet if it still appears
      -- vim.api.nvim_create_autocmd("LspAttach", {
      --   callback = function(args)
      --     local client = vim.lsp.get_client_by_id(args.data.client_id)
      --     if client and client.name == "easy_dotnet_in_process" then
      --       vim.lsp.stop_client(client.id, true)
      --     end
      --   end,
      -- })

      -- only CLI mappings (NO LSP / NO references / NO hints)
      local opts = { noremap = true, silent = true }

      local map = function(lhs, rhs, desc)
        vim.keymap.set("n", lhs, rhs, vim.tbl_extend("force", opts, {
          desc = desc,
        }))
      end

    --   map("<leader>.r", dotnet.run, ".NET Run")
    --   map("<leader>.b", dotnet.build, ".NET Build")
    --   map("<leader>.s", dotnet.build_solution, ".NET Build Solution")
    --   map("<leader>.t", dotnet.test, ".NET Test")
    --   map("<leader>.n", dotnet.nuget, "NuGet")

    --   map("<leader>.R", dotnet.restore, ".NET Restore")
    --   map("<leader>.c", dotnet.clean, ".NET Clean")
    --   map("<leader>.p", dotnet.publish, ".NET Publish")
    -- ...
    -- map("<leader>db", function() dotnet.build() end, ".NET Build")
    -- map("<leader>dt", function() dotnet.test() end, ".NET Test")
    -- map("<leader>dR", function() dotnet.restore() end, ".NET Restore")
    -- map("<leader>dc", function() dotnet.clean() end, ".NET Clean")
    -- map("<leader>di", function() dotnet.nuget() end, "NuGet")
    -- map("<leader>do", function() dotnet.publish() end, ".NET Publish")
    -- map("<leader>dx", function() dotnet.run() end, ".NET Run")
    end,
  },
}
