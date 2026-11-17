-- plugins/vscode.lua

-- Keep standalone LazyVim fully featured. In VS Code, VS Code extensions own
-- LSP, completion, formatting, linting, debugging, and duplicated IDE chrome.
local vscode = not not vim.g.vscode
local enabled = not vscode

return {
  -- LSP clients and installers.
  { "neovim/nvim-lspconfig", enabled = enabled },
  { "mason-org/mason.nvim", enabled = enabled },
  { "mason-org/mason-lspconfig.nvim", enabled = enabled },
  { "jay-babu/mason-nvim-dap.nvim", enabled = enabled },

  -- Completion / snippets / inline AI.
  { "saghen/blink.cmp", enabled = enabled },
  { "L3MON4D3/LuaSnip", enabled = enabled },
  { "rafamadriz/friendly-snippets", enabled = enabled },
  { "github/copilot.vim", enabled = enabled },

  -- Formatting and linting.
  { "stevearc/conform.nvim", enabled = enabled },
  { "mfussenegger/nvim-lint", enabled = enabled },

  -- Debugging and test UI.
  { "mfussenegger/nvim-dap", enabled = enabled },
  { "rcarriga/nvim-dap-ui", enabled = enabled },
  { "theHamsta/nvim-dap-virtual-text", enabled = enabled },
  { "mfussenegger/nvim-dap-python", enabled = enabled },
  { "nvim-neotest/neotest", enabled = enabled },

  -- Language-specific Neovim clients/integrations.
  { "mrcjkb/rustaceanvim", enabled = enabled },
  { "pmizio/typescript-tools.nvim", enabled = enabled },
  { "nvim-java/nvim-java", enabled = enabled },
  { "seblyng/roslyn.nvim", enabled = enabled },
  { "p00f/clangd_extensions.nvim", enabled = enabled },
  { "Civitasv/cmake-tools.nvim", enabled = enabled },
  { "jmbuhr/otter.nvim", enabled = enabled },
  { "GustavEikaas/easy-dotnet.nvim", enabled = enabled },

  -- VS Code supplies these workbench surfaces.
  { "akinsho/bufferline.nvim", enabled = enabled },
  { "nvim-tree/nvim-tree.lua", enabled = enabled },
  { "nvim-telescope/telescope.nvim", enabled = enabled },
  { "ibhagwan/fzf-lua", enabled = enabled },
  { "nvim-lualine/lualine.nvim", enabled = enabled },
  { "folke/trouble.nvim", enabled = enabled },
  { "stevearc/aerial.nvim", enabled = enabled },
  { "folke/noice.nvim", enabled = enabled },
  { "lervag/vimtex", enabled = enabled },
}
