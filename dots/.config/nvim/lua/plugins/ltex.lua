-- plugins/ltex.lua

return {
  {
    "neovim/nvim-lspconfig",
    ft = { "tex", "markdown", "text", "gitcommit" },
    dependencies = {
      "folke/which-key.nvim",
    },
    opts = {
      servers = {
        ltex = {
          settings = {
            ltex = {
              language = "de-DE",
              additionalRules = {
                enablePickyRules = true,
              },
              checkFrequency = "save",
            },
          },
        },
      },
    },
    keys = {
      -- 1. Toggle BOTH LTeX and Built-in Spellcheck
      {
        "<leader>lLa",
        function()
          local current_clients = vim.lsp.get_clients({ name = "ltex", bufnr = 0 })

          if #current_clients > 0 then
            for _, client in ipairs(current_clients) do
              vim.lsp.buf_detach_client(0, client.id)
            end
            vim.diagnostic.reset(nil, 0)
            vim.opt_local.spell = false
            vim.notify("LTeX & Spellcheck OFF", vim.log.levels.WARN, { title = "LTeX / Spell" })
          else
            vim.cmd("edit!")
            vim.opt_local.spell = true
            vim.notify("LTeX & Spellcheck ON", vim.log.levels.INFO, { title = "LTeX / Spell" })
          end
        end,
        desc = "Toggle LTeX & Spellcheck (All)",
      },

      -- 2. Toggle ONLY LTeX Language Server
      {
        "<leader>lLl",
        function()
          local current_clients = vim.lsp.get_clients({ name = "ltex", bufnr = 0 })

          if #current_clients > 0 then
            for _, client in ipairs(current_clients) do
              vim.lsp.buf_detach_client(0, client.id)
            end
            vim.diagnostic.reset(nil, 0)
            vim.notify("LTeX Grammar Check OFF", vim.log.levels.WARN, { title = "LTeX" })
          else
            vim.cmd("edit!")
            vim.notify("LTeX Grammar Check ON", vim.log.levels.INFO, { title = "LTeX" })
          end
        end,
        desc = "Toggle LTeX Only",
      },

      -- 3. Toggle ONLY Built-in Spellcheck
      {
        "<leader>lLs",
        function()
          -- Toggles the spell option between true and false
          vim.opt_local.spell = not vim.opt_local.spell:get()

          if vim.opt_local.spell:get() then
            vim.notify("Spellcheck ON", vim.log.levels.INFO, { title = "Spellcheck" })
          else
            vim.notify("Spellcheck OFF", vim.log.levels.WARN, { title = "Spellcheck" })
          end
        end,
        desc = "Toggle Spellcheck Only",
      },
    },
  },
}
