-- plugins/markdown.lua

return {
  -- Bei Problmen einfach nachhelfen mit: :call mkdp#util#install()
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    ft = { "markdown" },
    build = "cd app && npm install",
    init = function()
      vim.g.mkdp_filetypes = { "markdown" }
    end,
    config = function()
      vim.g.mkdp_auto_start = 0
      vim.g.mkdp_refresh_slow = 1
      vim.g.mkdp_theme = "dark"
    end,
  },

  -- Markdown Syntax + Verbesserungen
  {
    "preservim/vim-markdown",
    ft = { "markdown" },
    config = function()
      vim.g.vim_markdown_folding_disabled = 1
      vim.g.vim_markdown_conceal = 0
      vim.g.vim_markdown_frontmatter = 1
      vim.g.vim_markdown_strikethrough = 1
      vim.g.vim_markdown_toc_autofit = 1
    end,
  },

  -- Inhaltsverzeichnis Generator
  {
    "mzlogin/vim-markdown-toc",
    ft = { "markdown" },
  },

  -- Tabellen Editing
  {
    "dhruvasagar/vim-table-mode",
    ft = { "markdown" },
    config = function()
      vim.g.table_mode_corner = "|"
    end,
  },
}

-- :TableModeToggle
-- :TableModeRealign
-- :GenTocGFM
-- :UpdateToc

-- Mehr noch in python.lua -> "MeanderingProgrammer/render-markdown.nvim",
