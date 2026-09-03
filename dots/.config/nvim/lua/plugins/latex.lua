-- plugins/latex.lua

return {
  {
    "lervag/vimtex",
    ft = { "tex", "plaintex", "latex" },
    keys = {
      { "<leader>ll", "<cmd>VimtexCompile<cr>", desc = "LaTeX Compile" },
      { "<leader>lS", "<cmd>VimtexCompileSS<cr>", desc = "LaTeX Compile Once" },
      { "<leader>lv", "<cmd>VimtexView<cr>", desc = "LaTeX View PDF" },
      { "<leader>le", "<cmd>VimtexErrors<cr>", desc = "LaTeX Errors" },
      {
        "<leader>ln",
        function()
          pcall(vim.cmd.cnext)
        end,
        desc = "LaTeX Next Error",
      },
      {
        "<leader>lp",
        function()
          pcall(vim.cmd.cprev)
        end,
        desc = "LaTeX Prev Error",
      },
      { "<leader>lo", "<cmd>copen<cr>", desc = "LaTeX Open Quickfix" },
      { "<leader>lt", "<cmd>VimtexTocOpen<cr>", desc = "LaTeX TOC" },
      { "<leader>lc", "<cmd>VimtexClean<cr>", desc = "LaTeX Clean" },
      { "<leader>lC", "<cmd>VimtexClean!<cr>", desc = "LaTeX Force Clean" },
      { "<leader>ls", "<cmd>VimtexStop<cr>", desc = "LaTeX Stop Compiler" },
      { "<leader>lr", "<cmd>VimtexReload<cr>", desc = "LaTeX Reload" },
      { "<leader>li", "<cmd>VimtexInfo<cr>", desc = "LaTeX Info" },
      { "<leader>lm", "<cmd>VimtexToggleMain<cr>", desc = "LaTeX Toggle Main" },
    },

    init = function()
      vim.g.tex_flavor = "latex"
      vim.g.vimtex_compiler_method = "latexmk"
      vim.g.vimtex_compiler_latexmk = {
        continuous = 1,
        out_dir = "build",
        callback = 1,
        options = {
          "-pdf",
          "-interaction=nonstopmode",
          "-synctex=1",
          "-file-line-error",
          "-halt-on-error",
        },
      }
      vim.g.vimtex_view_forward_search_on_start = 1
      vim.g.vimtex_view_use_temp_files = 0
      vim.g.vimtex_view_reverse_search_edit_cmd = "edit"

      local is_windows = vim.fn.has("win32") == 1 or vim.fn.has("win64") == 1
      local is_linux = vim.fn.has("unix") == 1 and not is_windows

      if is_windows then
        vim.g.vimtex_view_method = "sumatrapdf"
      elseif is_linux and vim.fn.executable("zathura") == 1 then
        vim.g.vimtex_view_method = "zathura"
      elseif is_linux and vim.fn.executable("sioyek") == 1 then
        vim.g.vimtex_view_method = "sioyek"
      else
        vim.g.vimtex_view_method = "general"
        vim.g.vimtex_view_general_viewer = "xdg-open"
      end

      vim.g.vimtex_quickfix_mode = 0
      vim.g.vimtex_quickfix_open_on_warning = 0
      vim.g.vimtex_quickfix_autoclose_after_keystrokes = 1
      vim.g.vimtex_indent_enabled = 1
      vim.g.vimtex_complete_enabled = 1
      vim.g.vimtex_complete_close_braces = 1
      vim.g.vimtex_matchparen_enabled = 1
      vim.g.vimtex_fold_enabled = 1
      vim.g.vimtex_imaps_enabled = 1

      vim.g.vimtex_syntax_conceal_disable = 1
    end,

    -- config = function()
    --   vim.api.nvim_create_autocmd("FileType", {
    --     group = vim.api.nvim_create_augroup("LatexVimtex", { clear = true }),
    --     pattern = { "tex", "plaintex", "latex" },
    --     callback = function()
    --       vim.opt_local.textwidth = 0
    --       vim.opt_local.wrap = true
    --       vim.opt_local.linebreak = true
    --       vim.opt_local.breakindent = true
    --       vim.opt_local.spell = true
    --       vim.opt_local.spelllang = { "de", "en" }
    --       vim.opt_local.conceallevel = 0
    --       vim.opt_local.concealcursor = "nc"
    --       vim.opt_local.formatoptions:remove({ "t" })
    --     end,
    --   })
    -- end,
  },

  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        texlab = {
          settings = {
            texlab = {
              build = {
                executable = "latexmk",
                args = {
                  "-pdf",
                  "-interaction=nonstopmode",
                  "-synctex=1",
                  "%f",
                },
                onSave = true,
              },

              chktex = {
                onOpenAndSave = true,
                onEdit = true,
              },
            },
          },
        },
      },
    },
  },
}
