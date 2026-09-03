return {
  {
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = {
        "tree-sitter-cli",
        "mmdc",

        -- Rust:
        "rust-analyzer",
        -- "rustfmt",

        -- C++:
        "clangd",
        "codelldb",

        -- Auto completion:
        "ltex-ls",

        -- Assembly:
        "asm-lsp",

        -- Java:
        -- "jdtls", -- https://github.com/nvim-java/nvim-java installirt das automatisch
        -- "java-debug-adapter", -- https://github.com/nvim-java/nvim-java installirt das automatisch
        -- "java-test", -- https://github.com/nvim-java/nvim-java installirt das automatisch
        -- "vscode-java-test",
        -- "kotlin_language_server",
        -- "checkstyle",

        -- Python:
        "pyright",
        -- "python-lsp-server", -- früber "pylsp",
        -- "pylsp-mypy" -- optional, für Typ-Prüfung
        -- "python-lsp-black",
        -- "black",
        "ruff",
        "debugpy",
        -- "mypy",

        -- HTML:
        "html-lsp",
        "htmlhint",

        -- XML / FXML:
        "lemminx",
        "xmlformatter",

        -- CSS:
        "css-lsp",

        -- Lua:
        -- "lua_ls",
        "lua-language-server",
        "stylua",

        -- JavaScript:
        "typescript-language-server",
        -- "eslint-lsp",
        "prettier",
        -- "eslint_d",
        -- "js-debug-adapter",

        -- Zig:
        -- "zls",

        -- Go:
        "gopls",

        -- C#
        -- "omnisharp",
        "roslyn-language-server",

        -- Bash
        "bash-language-server",
        "shellcheck",
        "shfmt",

        -- Julia
        -- "julials",

        -- Clojure
        -- "clojure_lsp",

        -- Nim
        -- "nim_langserver",

        -- JSON
        -- "jsonls",

        -- YAML
        -- "yamlls",

        -- MATLAB
        -- "matlab-language-server",

        -- Docker & YAML
        "dockerfile-language-server",
        "yaml-language-server",

        -- Latex
        "texlab",
      },
    },
  },
  -- {
  --   "tpope/vim-fugitive",
  --   cmd = { "Git", "G" },
  -- },
}
