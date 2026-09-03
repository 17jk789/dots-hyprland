-- plugins/java.lua

-- return {
--   {
--     "mfussenegger/nvim-jdtls",
--     ft = { "java" },
--     dependencies = {
--       "mason-org/mason.nvim",
--       "mason-org/mason-lspconfig.nvim",
--     },
--     config = function()
--       local jdtls = require("jdtls")
--       local mason_path = vim.fn.stdpath("data") .. "/mason"
--       local jdtls_path = mason_path .. "/packages/jdtls"

--       local jar = vim.fn.glob(jdtls_path .. "/plugins/org.eclipse.equinox.launcher_*.jar")
--       local config_dir = jdtls_path .. "/config_linux"

--       local config = {
--         cmd = {
--           "java",
--           "-Declipse.application=org.eclipse.jdt.ls.core.id1",
--           "-Dosgi.bundles.defaultStartLevel=4",
--           "-Declipse.product=org.eclipse.jdt.ls.core.product",
--           "-Dlog.protocol=true",
--           "-Dlog.level=ALL",
--           "-Xms1g",
--           "--add-modules=ALL-SYSTEM",
--           "--add-opens", "java.base/java.util=ALL-UNNAMED",
--           "--add-opens", "java.base/java.lang=ALL-UNNAMED",
--           "-jar", jar,
--           "-configuration", config_dir,
--           "-data", vim.fn.stdpath("cache") .. "/jdtls/" .. vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t"),
--         },
--         root_dir = require("jdtls.setup").find_root({ ".git", "mvnw", "gradlew", "pom.xml", "build.gradle" }),
--       }

--       jdtls.start_or_attach(config)
--     end,
--   },
-- }

-- Wenn jar leer ist, startet LSP nicht!
-- root_dir kann nil sein
-- jdtls braucht Java 17+ (je nach Version).

-- return {
--   {
--     "mfussenegger/nvim-jdtls",
--     ft = { "java" },
--     dependencies = {
--       "mason-org/mason.nvim",
--       "mason-org/mason-lspconfig.nvim",
--     },
--     config = function()
--       local jdtls = require("jdtls")
--       local mason_path = vim.fn.stdpath("data") .. "/mason"
--       local jdtls_path = mason_path .. "/packages/jdtls"

--       local jar = vim.fn.glob(jdtls_path .. "/plugins/org.eclipse.equinox.launcher_*.jar")
--       if jar == "" then
--         vim.notify("jdtls jar not found. Install jdtls via Mason.", vim.log.levels.ERROR)
--         return
--       end

--       -- config dir abhängig vom OS
--       local os_config
--       if vim.fn.has("macunix") == 1 then
--         os_config = "config_mac"
--       elseif vim.fn.has("win32") == 1 then
--         os_config = "config_win"
--       else
--         os_config = "config_linux"
--       end

--       local config_dir = jdtls_path .. "/" .. os_config

--       -- root_dir berechnen
--       local root_dir = require("jdtls.setup").find_root({
--         ".git", "mvnw", "gradlew", "pom.xml", "build.gradle"
--       })

--       if not root_dir then
--         root_dir = vim.fn.getcwd()
--       end

--       -- Workspace eindeutig (hash des Pfades)
--       local workspace_dir = vim.fn.stdpath("cache") .. "/jdtls/" .. vim.fn.sha256(root_dir)

--       local config = {
--         cmd = {
--           "java",
--           "-Declipse.application=org.eclipse.jdt.ls.core.id1",
--           "-Dosgi.bundles.defaultStartLevel=4",
--           "-Declipse.product=org.eclipse.jdt.ls.core.product",
--           "-Dlog.protocol=true",
--           "-Dlog.level=ALL",
--           "-Xms1g",
--           "--add-modules=ALL-SYSTEM",
--           "--add-opens", "java.base/java.util=ALL-UNNAMED",
--           "--add-opens", "java.base/java.lang=ALL-UNNAMED",
--           "-jar", jar,
--           "-configuration", config_dir,
--           "-data", workspace_dir,
--         },
--         root_dir = root_dir,
--         settings = {
--           java = {
--             eclipse = { downloadSources = true },
--             maven = { downloadSources = true },
--             format = { enabled = true },
--             referencesCodeLens = { enabled = true },
--             implementationsCodeLens = { enabled = true },
--           },
--         },
--       }

--       jdtls.start_or_attach(config)
--     end,
--   },
-- }

-- return {
--   {
--     "L3MON4D3/LuaSnip",
--     opts = function(_, opts)
--       local ls = require("luasnip")
--       local s = ls.snippet
--       local t = ls.text_node
--       local i = ls.insert_node
--       local f = ls.function_node

--       ls.add_snippets("java", {

--         s("mainclass", {
--           t("public class "),
--           f(function()
--             return vim.fn.expand("%:t:r")
--           end),
--           t({ " {", "", "    public static void main(String[] args) {", "        " }),
--           i(0),
--           t({ "", "    }", "}", "" }),
--         }),

--         s("mc", {
--           t("public class "),
--           f(function()
--             return vim.fn.expand("%:t:r")
--           end),
--           t({ " {", "", "    public static void main(String[] args) {", "        " }),
--           i(0),
--           t({ "", "    }", "}", "" }),
--         }),

--         s("mch", {
--           t("public class "),
--           f(function()
--             return vim.fn.expand("%:t:r")
--           end),
--           t({
--             " {",
--             "",
--             "    public static void main(String[] args) {",
--             '        System.out.println("Hello World!");',
--             "        ",
--           }),
--           i(0),
--           t({ "", "    }", "}", "" }),
--         }),

--         s("pri", {
--           t("System.out.print("),
--           i(0),
--           t(");"),
--         }),

--         s("priln", {
--           t("System.out.println("),
--           i(0),
--           t(");"),
--         }),
--       })

--       return opts
--     end,
--   },
--   {
--     "mfussenegger/nvim-jdtls",
--     ft = { "java" },
--     dependencies = {
--       "mason-org/mason.nvim",
--       "mason-org/mason-lspconfig.nvim",
--     },
--     config = function()
--       local jdtls = require("jdtls")

--       -- Pfad zu Mason
--       local mason_path = vim.fn.stdpath("data") .. "/mason"
--       local jdtls_path = mason_path .. "/packages/jdtls"

--       local jar_files = vim.fn.glob(jdtls_path .. "/plugins/org.eclipse.equinox.launcher_*.jar", true, true)
--       local jar = jar_files[1]
--       if not jar or jar == "" then
--         vim.notify("JDTLS jar nicht gefunden. Bitte über Mason installieren.", vim.log.levels.ERROR)
--         return
--       end

--       local os_config
--       if vim.fn.has("macunix") == 1 then
--         os_config = "config_mac"
--       elseif vim.fn.has("win32") == 1 then
--         os_config = "config_win"
--       else
--         os_config = "config_linux"
--       end

--       local config_dir = jdtls_path .. "/" .. os_config

--       local root_dir = require("jdtls.setup").find_root({
--         ".git", "mvnw", "gradlew", "pom.xml", "build.gradle"
--       }) or vim.fn.getcwd()

--       local workspace_dir = vim.fn.stdpath("cache") .. "/jdtls/" .. vim.fn.sha256(root_dir)

--       local capabilities = vim.lsp.protocol.make_client_capabilities()
--       local cmp_ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
--       if cmp_ok then
--         capabilities = cmp_nvim_lsp.default_capabilities(capabilities)
--       end

--       local on_attach = function(client, bufnr)
--         local bufopts = { noremap = true, silent = true, buffer = bufnr }
--         vim.keymap.set("n", "K", vim.lsp.buf.hover, bufopts)
--         -- vim.keymap.set("n", "gd", vim.lsp.buf.definition, bufopts) -- Diese Tastenkombination ist bereits in plugins/keymaps definiert.
--         vim.keymap.set("n", "gr", vim.lsp.buf.references, bufopts)
--         -- vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, bufopts) --  -- Diese Tastenkombination ist bereits in plugins/keymaps
--       end

--       -- JDTLS Config
--       local config = {
--         cmd = {
--           "java",
--           "-Declipse.application=org.eclipse.jdt.ls.core.id1",
--           "-Dosgi.bundles.defaultStartLevel=4",
--           "-Declipse.product=org.eclipse.jdt.ls.core.product",
--           "-Dlog.protocol=true",
--           "-Dlog.level=ALL",
--           "-Xms1g",
--           "--add-modules=ALL-SYSTEM",
--           "--add-opens", "java.base/java.util=ALL-UNNAMED",
--           "--add-opens", "java.base/java.lang=ALL-UNNAMED",
--           "-jar", jar,
--           "-configuration", config_dir,
--           "-data", workspace_dir,
--         },
--         root_dir = root_dir,
--         capabilities = capabilities,
--         on_attach = on_attach,
--         settings = {
--           java = {
--             eclipse = { downloadSources = true },
--             maven = { downloadSources = true },
--             format = { enabled = true },
--             referencesCodeLens = { enabled = true },
--             implementationsCodeLens = { enabled = true },
--           },
--         },
--       }

--       jdtls.start_or_attach(config)

--       jdtls.setup_dap({ hotcodereplace = "auto" })
--       jdtls.setup.add_commands()

--       require("jdtls.dap").setup_dap_main_class_configs()
--     end,
--   },
-- }

-- return {
--   {
--     "mfussenegger/nvim-jdtls",
--     ft = { "java" },
--     dependencies = {
--       "mason-org/mason.nvim",
--       "mason-org/mason-lspconfig.nvim",
--     },
--     config = function()
--       local augroup = vim.api.nvim_create_augroup("JdtlsAutostart", { clear = true })

--       vim.api.nvim_create_autocmd("FileType", {
--         group = augroup,
--         pattern = "java",
--         callback = function()
--           local jdtls = require("jdtls")

--           local mason_path = vim.fn.stdpath("data") .. "/mason"
--           local jdtls_path = mason_path .. "/packages/jdtls"

--           local jar = vim.fn.glob(jdtls_path .. "/plugins/org.eclipse.equinox.launcher_*.jar")
--           if jar == "" then
--             vim.notify("JDTLS nicht über Mason installiert", vim.log.levels.ERROR)
--             return
--           end

--           local os_config = vim.fn.has("macunix") == 1 and "config_mac"
--             or vim.fn.has("win32") == 1 and "config_win"
--             or "config_linux"

--           local root_dir = require("jdtls.setup").find_root({
--             "build.gradle", "settings.gradle",
--             "pom.xml", "mvnw", "gradlew", ".git",
--           }) or vim.fn.getcwd()

--           local workspace_dir = vim.fn.stdpath("cache") .. "/jdtls/" .. vim.fn.sha256(root_dir)

--           local capabilities = vim.lsp.protocol.make_client_capabilities()
--           local ok, cmp = pcall(require, "cmp_nvim_lsp")
--           if ok then
--             capabilities = cmp.default_capabilities(capabilities)
--           end

--           local config = {
--             cmd = {
--               "java",
--               "-Declipse.application=org.eclipse.jdt.ls.core.id1",
--               "-Dosgi.bundles.defaultStartLevel=4",
--               "-Declipse.product=org.eclipse.jdt.ls.core.product",
--               "-Xms1g",
--               "--add-modules=ALL-SYSTEM",
--               "--add-opens", "java.base/java.util=ALL-UNNAMED",
--               "--add-opens", "java.base/java.lang=ALL-UNNAMED",
--               "-jar", jar,
--               "-configuration", jdtls_path .. "/" .. os_config,
--               "-data", workspace_dir,
--             },
--             root_dir = root_dir,
--             capabilities = capabilities,
--             settings = {
--               java = {
--                 eclipse = { downloadSources = true },
--                 maven = { downloadSources = true },
--                 format = { enabled = true },
--               },
--             },
--           }

--           jdtls.start_or_attach(config)
--           jdtls.setup_dap({ hotcodereplace = "auto" })
--           require("jdtls.dap").setup_dap_main_class_configs()
--         end,
--       })
--     end,
--   },
-- }

-- local function find_style_xml()
--   local cwd = vim.fn.getcwd()

--   -- mögliche Kandidaten im Projekt
--   local candidates = {
--     cwd .. "/config/checkstyle/checkstyle.xml",
--     cwd .. "/checkstyle.xml",
--     cwd .. "/google_checks.xml",
--   }

--   for _, file in ipairs(candidates) do
--     if vim.fn.filereadable(file) == 1 then
--       return file
--     end
--   end

--   -- Fallback auf deine globale Datei
--   return vim.fn.stdpath("config") .. "/lang-servers/intellij-java-google-style.xml"
-- end

-- return {
--   -- {
--   --   "L3MON4D3/LuaSnip",
--   --   version = "v2.*",
--   --   build = "make install_jsregexp", -- optional für LSP transformations
--   --   event = "InsertEnter",           -- lazy load
--   --   config = function()
--   --     local ls = require("luasnip")
--   --     local s, t, i, f = ls.snippet, ls.text_node, ls.insert_node, ls.function_node

--   --     -- Keymaps (optional, aber empfohlen)
--   --     vim.keymap.set({"i"}, "<C-K>", function() ls.expand() end, {silent = true})
--   --     vim.keymap.set({"i","s"}, "<C-L>", function() ls.jump(1) end, {silent = true})
--   --     vim.keymap.set({"i","s"}, "<C-J>", function() ls.jump(-1) end, {silent = true})
--   --     vim.keymap.set({"i","s"}, "<C-E>", function()
--   --       if ls.choice_active() then ls.change_choice(1) end
--   --     end, {silent = true})

--   --     -- Autocmd: snippets erst beim richtigen FileType registrieren
--   --     vim.api.nvim_create_autocmd("FileType", {
--   --       pattern = "java",
--   --       callback = function()
--   --         ls.add_snippets("java", {
--   --           -- public class + main
--   --           s("main", {
--   --             t("public class "), f(function() return vim.fn.expand("%:t:r") end), t({" {", "", "    public static void main(String[] args) {", "        "}), i(1), t({"", "    }", "}", ""})
--   --           }),
--   --           -- Hello World
--   --           s("mainh", {
--   --             t("public class "), f(function() return vim.fn.expand("%:t:r") end), t({" {", "", "    public static void main(String[] args) {", '        System.out.println("Hello World!");', "    }", "}", ""})
--   --           }),
--   --           -- print
--   --           s("pri", {t("System.out.print("), i(1), t(");")}),
--   --           -- println
--   --           s("priln", {t("System.out.println("), i(1), t(");")}),
--   --         })
--   --       end
--   --     })
--   --   end,
--   -- },

--   {
--     -- "mfussenegger/nvim-jdtls",
--     -- ft = { "java" },
--     -- dependencies = {
--     --   "mason-org/mason.nvim",
--     --   "mason-org/mason-lspconfig.nvim",
--     -- },
--     -- config = function()
--     --   local jdtls = require("jdtls")

--     --   local mason_path = vim.fn.stdpath("data") .. "/mason"
--     --   local jdtls_path = mason_path .. "/packages/jdtls"
--     --   local jar_files = vim.fn.glob(jdtls_path .. "/plugins/org.eclipse.equinox.launcher_*.jar", true, true)
--     --   local jar = jar_files[1]
--     --   if not jar or jar == "" then
--     --     vim.notify("JDTLS jar nicht gefunden. Bitte über Mason installieren.", vim.log.levels.ERROR)
--     --     return
--     --   end

--     --   local os_config
--     --   if vim.fn.has("macunix") == 1 then
--     --     os_config = "config_mac"
--     --   elseif vim.fn.has("win32") == 1 then
--     --     os_config = "config_win"
--     --   else
--     --     os_config = "config_linux"
--     --   end

--     --   local root_dir = require("jdtls.setup").find_root({ ".git", "mvnw", "gradlew", "pom.xml", "build.gradle" }) or vim.fn.getcwd()
--     --   local workspace_dir = vim.fn.stdpath("cache") .. "/jdtls/" .. vim.fn.sha256(root_dir)

--     --   local capabilities = vim.lsp.protocol.make_client_capabilities()
--     --   local cmp_ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
--     --   if cmp_ok then
--     --     capabilities = cmp_nvim_lsp.default_capabilities(capabilities)
--     --   end

--     --   local on_attach = function(client, bufnr)
--     --     local bufopts = { noremap = true, silent = true, buffer = bufnr }
--     --     vim.keymap.set("n", "K", vim.lsp.buf.hover, bufopts)
--     --     -- vim.keymap.set("n", "gd", vim.lsp.buf.definition, bufopts) -- Diese Tastenkombination ist bereits in plugins/keymaps definiert.
--     --     vim.keymap.set("n", "gr", vim.lsp.buf.references, bufopts)
--     --     -- vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, bufopts) -- Diese Tastenkombination ist bereits in plugins/keymaps definiert.
--     --   end

--     --   jdtls.start_or_attach({
--     --     cmd = {
--     --       "java",
--     --       "-Declipse.application=org.eclipse.jdt.ls.core.id1",
--     --       "-Dosgi.bundles.defaultStartLevel=4",
--     --       "-Declipse.product=org.eclipse.jdt.ls.core.product",
--     --       "-Dlog.protocol=true",
--     --       "-Dlog.level=ALL",
--     --       "-Xms1g",
--     --       "--add-modules=ALL-SYSTEM",
--     --       "--add-opens", "java.base/java.util=ALL-UNNAMED",
--     --       "--add-opens", "java.base/java.lang=ALL-UNNAMED",
--     --       "-jar", jar,
--     --       "-configuration", jdtls_path .. "/" .. os_config,
--     --       "-data", workspace_dir,
--     --     },
--     --     root_dir = root_dir,
--     --     capabilities = capabilities,
--     --     on_attach = on_attach,
--     --     settings = {
--     --       java = {
--     --         eclipse = { downloadSources = true },
--     --         maven = { downloadSources = true },
--     --         format = { enabled = true },
--     --         referencesCodeLens = { enabled = true },
--     --         implementationsCodeLens = { enabled = true },
--     --       },
--     --     },
--     --   })
--     -- end,

--     -- "nvim-java/nvim-java",
--     -- ft = { "java" },
--     -- dependencies = {
--     --   "neovim/nvim-lspconfig",
--     --   "mfussenegger/nvim-dap",
--     --   "mason-org/mason.nvim",
--     -- },
--     -- config = function()
--     --   require("java").setup()
--     --   vim.lsp.enable("jdtls")
--     -- end,

--     "nvim-java/nvim-java",
--     ft = { "java" },
--     dependencies = {
--       "neovim/nvim-lspconfig",
--       -- Funktionirt nicht mehr alles in config = function() jetzt!!!
--       -- opts = {
--       --   servers = {
--       --     jdtls = {
--       --       settings = {
--       --         java = {
--       --           eclipse = {
--       --             downloadSources = true,
--       --           },

--       --           configuration = {
--       --             updateBuildConfiguration = "interactive",
--       --             runtimes = {
--       --               -- { name = "JavaSE-1.6", path = "/usr/lib/jvm/java-6-openjdk/" },
--       --               -- { name = "JavaSE-1.7", path = "/usr/lib/jvm/java-7-openjdk/" },
--       --               -- { name = "JavaSE-1.8", path = "/usr/lib/jvm/java-8-openjdk/" },
--       --               -- { name = "JavaSE-9",   path = "/usr/lib/jvm/java-9-openjdk/" },
--       --               -- { name = "JavaSE-10",  path = "/usr/lib/jvm/java-10-openjdk/" },
--       --               -- { name = "JavaSE-11",  path = "/usr/lib/jvm/java-11-openjdk/" }, -- LTS
--       --               -- { name = "JavaSE-12",  path = "/usr/lib/jvm/java-12-openjdk/" },
--       --               -- { name = "JavaSE-13",  path = "/usr/lib/jvm/java-13-openjdk/" },
--       --               -- { name = "JavaSE-14",  path = "/usr/lib/jvm/java-14-openjdk/" },
--       --               -- { name = "JavaSE-15",  path = "/usr/lib/jvm/java-15-openjdk/" },
--       --               -- { name = "JavaSE-16",  path = "/usr/lib/jvm/java-16-openjdk/" },
--       --               -- { name = "JavaSE-17",  path = "/usr/lib/jvm/java-17-openjdk/" }, -- LTS
--       --               -- { name = "JavaSE-18",  path = "/usr/lib/jvm/java-18-openjdk/" },
--       --               -- { name = "JavaSE-19",  path = "/usr/lib/jvm/java-19-openjdk/" },
--       --               -- { name = "JavaSE-20",  path = "/usr/lib/jvm/java-20-openjdk/" },
--       --               { name = "JavaSE-21",  path = "/usr/lib/jvm/java-21-openjdk/" }, -- LTS
--       --               -- { name = "JavaSE-22",  path = "/usr/lib/jvm/java-22-openjdk/" },
--       --               -- { name = "JavaSE-23",  path = "/usr/lib/jvm/java-23-openjdk/" },
--       --               -- { name = "JavaSE-24",  path = "/usr/lib/jvm/java-24-openjdk/" },
--       --               -- { name = "JavaSE-25",  path = "/usr/lib/jvm/java-25-openjdk/" },
--       --             },
--       --           },

--       --           maven = {
--       --             downloadSources = true,
--       --             updateSnapshots = true,
--       --           },

--       --           implementationsCodeLens = {
--       --             enabled = true,
--       --           },

--       --           referencesCodeLens = {
--       --             enabled = true,
--       --           },

--       --           references = {
--       --             includeDecompiledSources = true,
--       --           },

--       --           -- Du nutzt GoogleStyle + eigenes XML.
--       --           -- Das ist gut — aber nur, wenn IntelliJ exakt dasselbe XML nutzt.
--       --           -- In IntelliJ IDEA solltest du:
--       --           -- Settings → Editor → Code Style → Java → Import Scheme → Import from XML
--       --           -- Dasselbe File verwenden wie:
--       --           -- ~/.config/nvim/lang-servers/intellij-java-google-style.xml

--       --           -- Profi-Level:
--       --           -- Deaktiviere in IntelliJ:
--       --           -- Optimize imports on the fly
--       --           -- Reformat on save
--       --           -- Wenn du es in NeoVim schon machst.
--       --           -- Sonst bekommst du unnötige Diff-Noise im Team.
--       --           format = {
--       --             enabled = true,
--       --             -- Bei Rroblemen
--       --             -- enabled = false,
--       --             settings = {
--       --               profile = "GoogleStyle",
--       --               -- ~/.config/nvim/lang-servers/intellij-java-google-style.xml
--       --               url = vim.fn.stdpath("config")
--       --                 .. "/lang-servers/intellij-java-google-style.xml",
--       --               -- ~/my-xm-slyte/Default.xml
--       --               -- url = vim.fn.expand("~/my-xm-slyte/Default.xml"),
--       --             },
--       --           },

--       --           signatureHelp = { enabled = true },

--       --           completion = {
--       --             favoriteStaticMembers = {
--       --               "org.hamcrest.MatcherAssert.assertThat",
--       --               "org.hamcrest.Matchers.*",
--       --               "org.junit.jupiter.api.Assertions.*",
--       --               "org.mockito.Mockito.*",
--       --               "java.util.Objects.requireNonNull",
--       --               "java.util.Objects.requireNonNullElse",
--       --             },

--       --             -- importOrder = {
--       --             --   "java",
--       --             --   "javax",
--       --             --   "com",
--       --             --   "org",
--       --             -- },

--       --             importOrder = {
--       --               "java",
--       --               "javax",
--       --               "jakarta",
--       --               "org",
--       --               "com",
--       --             },

--       --             -- Extended Completion Settings
--       --             guessMethodArguments = true,
--       --             -- filteredTypes = {
--       --             --   "com.sun.*",
--       --             --   "sun.*",
--       --             -- },
--       --           },

--       --           sources = {
--       --             organizeImports = {
--       --               starThreshold = 9999,
--       --               staticStarThreshold = 9999,
--       --             },
--       --           },

--       --           codeGeneration = {
--       --             -- useBlocks = true,
--       --             -- toString = {
--       --             --   template =
--       --             --   "${object.className}{${member.name()}=${member.value}, ${otherMembers}}",
--       --             -- },

--       --             useBlocks = true,
--       --             generateComments = true,
--       --             hashCodeEquals = {
--       --               useJava7Objects = true,
--       --             },
--       --             toString = {
--       --               template =
--       --                 "${object.className}{${member.name()}=${member.value}, ${otherMembers}}",
--       --             },
--       --           },

--       --           inlayHints = {
--       --             parameterNames = { enabled = "all" },
--       --           },

--       --           -- Gradle explizit konfigurieren (wichtig!)
--       --           -- gradle = {
--       --           --   enabled = true,
--       --           --   -- offlineMode = false,
--       --           -- },

--       --           gradle = {
--       --             enabled = true,
--       --             wrapper = {
--       --               enabled = true,
--       --             },
--       --           },

--       --           -- Autobuild / Autobuild Watcher
--       --           -- Mit: Spring Boot, Gradle Wrapper, Hot Reload Debug Adapter kann das schnell CPU fressen.
--       --           autobuild = {
--       --             enabled = false,
--       --           },

--       --           -- Null Analysis Mode (Performance) -> Nur aktivieren wenn wirklich nötig!!!
--       --           -- project = {
--       --           --   referencedLibraries = {
--       --           --     "lib/**/*.jar",
--       --           --   },
--       --           -- },

--       --           -- Import Completion Advanced
--       --           import = {
--       --             maven = {
--       --               enabled = true,
--       --             },
--       --             gradle = {
--       --               enabled = true,
--       --             },
--       --           },

--       --           -- Decompiler Support
--       --           -- contentProvider = { preferred = "fernflower" }, -- Der "alte" Standard (wird auch von IntelliJ genutzt).
--       --           -- contentProvider = { preferred = "quiltflower" }, -- Besser für modernes Java (21+)
--       --           contentProvider = { preferred = "cfr" }, -- Der aktuell stärkste Decompiler für moderne Java-Features.
--       --           -- contentProvider = { preferred = "procyon" }, -- Ein sehr präziser Decompiler, der besonders gut mit Lambdas und synthetischen Methoden umgehen kann.

--       --           -- Semantic Highlighting (optisch besser)
--       --           semanticHighlighting = {
--       --             enabled = true,
--       --           },

--       --           -- Folding / Symbols Advanced: Unser NeoVim nutzt Tree-sitter Folding → dann unnötig.
--       --           -- foldingRange = {
--       --           --   enabled = true,
--       --           -- },

--       --           -- Save Actions (extrem praktisch)
--       --           -- Achtung: organizeImports beim Speichern kann in Teamprojekten unnötige Änderungen und Merge-Konflikte erzeugen
--       --           saveActions = {
--       --             organizeImports = true,
--       --           },
--       --         },
--       --       },

--       --       -- flags = {
--       --       --   allow_incremental_sync = true,
--       --       -- },

--       --       init_options = {
--       --         extendedClientCapabilities = {
--       --           resolveAdditionalTextEditsSupport = true,
--       --         },
--       --       },

--       --       -- Wird von nvim-java/nvim-java Zum Teil übernommen
--       --       -- init_options = {
--       --       --   bundles = {},
--       --       -- },
--       --     },
--       --   },

--       --   setup = {
--       --     jdtls = function()
--       --       require("java").setup({
--       --         jdk = {
--       --           auto_install = false,
--       --         },

--       --         -- Achte darauf, dass java_test.enable nicht doppelt Konfigurationen ausführt, sonst gibt es Konflikte beim Debuggen
--       --         java_test = {
--       --           enable = true,
--       --           -- Damit sind Assertions aktiv (wichtig für Unit Tests mit JUnit).
--       --           config = {
--       --             vmArgs = "-ea",
--       --           },
--       --         },

--       --         java_debug_adapter = {
--       --           enable = true,
--       --           hotcodereplace = "auto", -- Damit bekommst du echtes IntelliJ-ähnliches Hot Reload Verhalten.
--       --         },

--       --         -- Spring DevTools NICHT parallel aktivieren, sonst doppelte Reload-Events.
--       --         spring_boot_tools = {
--       --           enable = true,
--       --           version = "latest",
--       --         },

--       --         -- Stelle sicher, dass du in IntelliJ:
--       --         -- Settings → Plugins → Lombok Plugin installiert
--       --         -- Annotation Processing aktiviert
--       --         -- Sonst hast du unterschiedliche Fehlermeldungen in IDE vs NeoVim.
--       --         lombok = {
--       --           enable = true,
--       --         },

--       --         notifications = {
--       --           dap = true,
--       --         },

--       --         -- Bei großen Gradle/Spring Projekten killt sonst Autobuild deine CPU.
--       --         flags = {
--       --           allow_incremental_sync = true,
--       --           debounce_text_changes = 150,
--       --         },

--       --         -- Bei großen Gradle/Spring Projekten killt sonst Autobuild deine CPU.
--       --         settings = {
--       --           java = {
--       --             maxConcurrentBuilds = 1,
--       --           }
--       --         },

--       --         -- on_attach = function(_, bufnr)
--       --         --   local map = function(mode, lhs, rhs)
--       --         --     vim.keymap.set(mode, lhs, rhs, { buffer = bufnr })
--       --         --   end

--       --         --   -- map("n", "<leader>ca", vim.lsp.buf.code_action) -- Diese Tastenkombination ist bereits in plugins/keymaps definiert.
--       --         --   -- map("v", "<leader>ca", vim.lsp.buf.code_action) -- Diese Tastenkombination ist bereits in plugins/keymaps definiert.

--       --         --   map("n", "<leader>oi", function()
--       --         --     vim.lsp.buf.code_action({
--       --         --       context = { only = { "source.organizeImports" } },
--       --         --       apply = true,
--       --         --     })
--       --         --   end)
--       --         -- end,
--       --         on_attach = function(_, bufnr)
--       --           local function map(mode, lhs, rhs, desc)
--       --             vim.keymap.set(mode, lhs, rhs, {
--       --               buffer = bufnr,
--       --               silent = true,
--       --               noremap = true,
--       --               desc = desc,
--       --             })
--       --           end

--       --           -- Organize Imports (robust)
--       --           map("n", "<leader>oi", function()
--       --             local params = vim.lsp.util.make_range_params()
--       --             params.context = { only = { "source.organizeImports" } }

--       --             local result = vim.lsp.buf_request_sync(
--       --               bufnr,
--       --               "textDocument/codeAction",
--       --               params,
--       --               3000
--       --             )

--       --             if not result then
--       --               vim.notify("No organize imports action found", vim.log.levels.WARN)
--       --               return
--       --             end

--       --             for _, res in pairs(result) do
--       --               for _, action in pairs(res.result or {}) do
--       --                 if action.edit or type(action.command) == "table" then
--       --                   if action.edit then
--       --                     vim.lsp.util.apply_workspace_edit(action.edit, "utf-8")
--       --                   end
--       --                   if action.command then
--       --                     vim.lsp.buf.execute_command(action.command)
--       --                   end
--       --                   return
--       --                 end
--       --               end
--       --             end

--       --             vim.notify("Organize imports not available", vim.log.levels.INFO)
--       --           end, "Java Organize Imports")

--       --           -- Extract Interface
--       --           map("n", "<leader>jei", function()
--       --             local uri = vim.uri_from_bufnr(bufnr)

--       --             -- Neue Command-ID probieren
--       --             local ok = pcall(function()
--       --               vim.lsp.buf.execute_command({
--       --                 command = "java.edit.extractInterface",
--       --                 arguments = { uri },
--       --               })
--       --             end)

--       --             -- Fallback für ältere jdtls Versionen
--       --             if not ok then
--       --               vim.lsp.buf.execute_command({
--       --                 command = "jdtls.extractInterface",
--       --                 arguments = { uri },
--       --               })
--       --             end
--       --           end, "Java Extract Interface")

--       --           -- Optional: Extract Interface (Visual Range)
--       --           map("v", "<leader>jei", function()
--       --             vim.lsp.buf.range_code_action({
--       --               context = { only = { "refactor.extract.interface" } },
--       --             })
--       --           end, "Java Extract Interface (Range)")
--       --         end,
--       --       })
--       --     end,
--       --   },
--       -- },

--       "mfussenegger/nvim-dap",
--       "mason-org/mason.nvim",
--       -- Nur nötig, wenn du die Test-UI direkt in NeoVim haben willst.
--       -- "nvim-neotest/neotest",
--       -- Ich würde aber eine plugins/neotest.lua schreiben:
--       -- return {
--       --   -- Nur nötig, wenn du die Test-UI direkt in NeoVim haben willst
--       --   {
--       --     "nvim-neotest/neotest",
--       --     enabled = false, -- auf true setzen, wenn du Tests in NeoVim nutzen willst
--       --     dependencies = {
--       --       "rcasia/neotest-java",
--       --       "nvim-lua/plenary.nvim",
--       --     },
--       --     config = function()
--       --       require("neotest").setup({
--       --         adapters = {
--       --           require("neotest-java")({}),
--       --         },
--       --       })
--       --     end,
--       --   },
--       -- }
--       -- "rcasia/neotest-java",
--       -- "nvim-lua/plenary.nvim", -- notwendig für neotest
--     },
--     config = function()
--       -- require("java").setup() -- Doppeltes require("java").setup() vermeiden Sonst: Debug/Test Bugs, Code-Actions verschwinden manchmal, doppelte LSP-Attachs, wird aber dennoch benötigt!
--       -- Setup nvim-java

--       -- wir haben noice.lua und brauchen daher keine eigenen Handler mehr für jdtls Notifications
--       local handlers = {
--         -- ["language/status"] = function(_, _) end,
--         ["$/progress"] = function(_, _) end,
--       }

--       require("java").setup(
--         -- {
--         -- jdk = {
--         --   auto_install = false,
--         -- },

--         -- Achte darauf, dass java_test.enable nicht doppelt Konfigurationen ausführt, sonst gibt es Konflikte beim Debuggen
--         -- java_test = {
--         --   enable = true,
--         --   -- Damit sind Assertions aktiv (wichtig für Unit Tests mit JUnit).
--         --   config = {
--         --     vmArgs = "-ea",
--         --   },
--         -- },

--         -- java_debug_adapter = {
--         --   enable = true,
--         --   hotcodereplace = "auto", -- Damit bekommst du echtes IntelliJ-ähnliches Hot Reload Verhalten.
--         -- },

--         -- Spring DevTools NICHT parallel aktivieren, sonst doppelte Reload-Events.
--         -- spring_boot_tools = {
--         --   enable = true,
--         --   version = "latest",
--         -- },

--         -- Stelle sicher, dass du in IntelliJ:
--         -- Settings → Plugins → Lombok Plugin installiert
--         -- Annotation Processing aktiviert
--         -- Sonst hast du unterschiedliche Fehlermeldungen in IDE vs NeoVim.
--         -- lombok = {
--         --   enable = true,
--         -- },

--         -- notifications = {
--         --   dap = true,
--         -- },

--         -- Bei großen Gradle/Spring Projekten killt sonst Autobuild deine CPU.
--         -- flags = {
--         --   allow_incremental_sync = true,
--         --   debounce_text_changes = 150,
--         -- },

--         -- Bei großen Gradle/Spring Projekten killt sonst Autobuild deine CPU.
--         -- settings = {
--         --   java = {
--         --     maxConcurrentBuilds = 1,
--         --   }
--         -- },

--         -- on_attach = function(_, bufnr)
--         --   local map = function(mode, lhs, rhs)
--         --     vim.keymap.set(mode, lhs, rhs, { buffer = bufnr })
--         --   end

--         --   -- map("n", "<leader>ca", vim.lsp.buf.code_action) -- Diese Tastenkombination ist bereits in plugins/keymaps definiert.
--         --   -- map("v", "<leader>ca", vim.lsp.buf.code_action) -- Diese Tastenkombination ist bereits in plugins/keymaps definiert.

--         --   map("n", "<leader>oi", function()
--         --     vim.lsp.buf.code_action({
--         --       context = { only = { "source.organizeImports" } },
--         --       apply = true,
--         --     })
--         --   end)
--         -- end,

--         -- on_attach = function(_, bufnr)
--         --   local function map(mode, lhs, rhs, desc)
--         --     vim.keymap.set(mode, lhs, rhs, {
--         --       buffer = bufnr,
--         --       silent = true,
--         --       noremap = true,
--         --       desc = desc,
--         --     })
--         --   end

--         --   -- Organize Imports (robust)
--         --   map("n", "<leader>oi", function()
--         --     local params = vim.lsp.util.make_range_params()
--         --     params.context = { only = { "source.organizeImports" } }

--         --     local result = vim.lsp.buf_request_sync(
--         --       bufnr,
--         --       "textDocument/codeAction",
--         --       params,
--         --       3000
--         --     )

--         --     if not result then
--         --       vim.notify("No organize imports action found", vim.log.levels.WARN)
--         --       return
--         --     end

--         --     for _, res in pairs(result) do
--         --       for _, action in pairs(res.result or {}) do
--         --         if action.edit or type(action.command) == "table" then
--         --           if action.edit then
--         --             vim.lsp.util.apply_workspace_edit(action.edit, "utf-8")
--         --           end
--         --           if action.command then
--         --             vim.lsp.buf.execute_command(action.command)
--         --           end
--         --           return
--         --         end
--         --       end
--         --     end

--         --     vim.notify("Organize imports not available", vim.log.levels.INFO)
--         --   end, "Java Organize Imports")

--         --   -- Extract Interface
--         --   map("n", "<leader>jei", function()
--         --     local uri = vim.uri_from_bufnr(bufnr)

--         --     -- Neue Command-ID probieren
--         --     local ok = pcall(function()
--         --       vim.lsp.buf.execute_command({
--         --         command = "java.edit.extractInterface",
--         --         arguments = { uri },
--         --       })
--         --     end)

--         --     -- Fallback für ältere jdtls Versionen
--         --     if not ok then
--         --       vim.lsp.buf.execute_command({
--         --         command = "jdtls.extractInterface",
--         --         arguments = { uri },
--         --       })
--         --     end
--         --   end, "Java Extract Interface")

--         --   -- Optional: Extract Interface (Visual Range)
--         --   map("v", "<leader>jei", function()
--         --     vim.lsp.buf.range_code_action({
--         --       context = { only = { "refactor.extract.interface" } },
--         --     })
--         --   end, "Java Extract Interface (Range)")
--         -- end,
--         -- }
--       )

--       -- require('java').setup({
--       --   -- Startup checks
--       --   checks = {
--       --     nvim_version = true,        -- Check NeoVim version
--       --     nvim_jdtls_conflict = true, -- Check for nvim-jdtls conflict
--       --   },

--       --   -- JDTLS configuration
--       --   jdtls = {
--       --     version = '1.43.0',
--       --   },

--       --   -- Extensions
--       --   lombok = {
--       --     enable = true,
--       --     version = '1.18.40',
--       --   },

--       --   java_test = {
--       --     enable = true,
--       --     version = '0.40.1',
--       --   },

--       --   java_debug_adapter = {
--       --     enable = true,
--       --     version = '0.58.2',
--       --   },

--       --   spring_boot_tools = {
--       --     enable = true,
--       --     version = '1.55.1',
--       --   },

--       --   -- JDK installation
--       --   jdk = {
--       --     auto_install = true,
--       --     version = '17',
--       --   },

--       --   -- Logging
--       --   log = {
--       --     use_console = true,
--       --     use_file = true,
--       --     level = 'info',
--       --     log_file = vim.fn.stdpath('state') .. '/nvim-java.log',
--       --     max_lines = 1000,
--       --     show_location = false,
--       --   },
--       -- })

--       vim.lsp.config("jdtls", {
--         handlers = handlers,

--         settings = {
--           java = {
--             -- eclipse = {
--             --   downloadSources = true,
--             -- },

--             configuration = {
--               runtimes = {
--                 -- { name = "JavaSE-1.6", path = "/usr/lib/jvm/java-6-openjdk/", default = true, },
--                 -- { name = "JavaSE-1.7", path = "/usr/lib/jvm/java-7-openjdk/", default = true, },
--                 -- { name = "JavaSE-1.8", path = "/usr/lib/jvm/java-8-openjdk/", default = true, },
--                 -- { name = "JavaSE-9",   path = "/usr/lib/jvm/java-9-openjdk/", default = true, },
--                 -- { name = "JavaSE-10",  path = "/usr/lib/jvm/java-10-openjdk/", default = true, },
--                 -- { name = "JavaSE-11",  path = "/usr/lib/jvm/java-11-openjdk/", default = true, }, -- LTS
--                 -- { name = "JavaSE-12",  path = "/usr/lib/jvm/java-12-openjdk/", default = true, },
--                 -- { name = "JavaSE-13",  path = "/usr/lib/jvm/java-13-openjdk/", default = true, },
--                 -- { name = "JavaSE-14",  path = "/usr/lib/jvm/java-14-openjdk/", default = true, },
--                 -- { name = "JavaSE-15",  path = "/usr/lib/jvm/java-15-openjdk/", default = true, },
--                 -- { name = "JavaSE-16",  path = "/usr/lib/jvm/java-16-openjdk/", default = true, },
--                 -- { name = "JavaSE-17",  path = "/usr/lib/jvm/java-17-openjdk/", default = true, }, -- LTS
--                 -- { name = "JavaSE-18",  path = "/usr/lib/jvm/java-18-openjdk/", default = true, },
--                 -- { name = "JavaSE-19",  path = "/usr/lib/jvm/java-19-openjdk/", default = true, },
--                 -- { name = "JavaSE-20",  path = "/usr/lib/jvm/java-20-openjdk/", default = true, },
--                 -- { name = "JavaSE-21",  path = "/usr/lib/jvm/java-21-openjdk/", default = true, }, -- LTS
--                 -- { name = "JavaSE-22",  path = "/usr/lib/jvm/java-22-openjdk/", default = true, },
--                 -- { name = "JavaSE-23",  path = "/usr/lib/jvm/java-23-openjdk/", default = true, },
--                 -- { name = "JavaSE-24",  path = "/usr/lib/jvm/java-24-openjdk/", default = true, },
--                 { name = "JavaSE-25", path = "/usr/lib/jvm/java-25-openjdk/", default = true }, -- LTS
--                 -- { name = "JavaSE-26",  path = "/usr/lib/jvm/java-26-openjdk/", default = true, },
--               },
--             },

--             -- maven = {
--             --   downloadSources = true,
--             --   updateSnapshots = true,
--             -- },

--             implementationsCodeLens = {
--               enabled = true,
--             },

--             referencesCodeLens = {
--               enabled = true,
--             },

--             -- references = {
--             --   includeDecompiledSources = true,
--             -- },

--             -- XML Formatter (Google Style)
--             -- Du nutzt GoogleStyle + eigenes XML.
--             -- Das ist gut — aber nur, wenn IntelliJ exakt dasselbe XML nutzt.
--             -- In IntelliJ IDEA solltest du:
--             -- Settings → Editor → Code Style → Java → Import Scheme → Import from XML
--             -- Dasselbe File verwenden wie:
--             -- ~/.config/nvim/lang-servers/intellij-java-google-style.xml

--             -- Profi-Level:
--             -- Deaktiviere in IntelliJ:
--             -- Optimize imports on the fly
--             -- Reformat on save
--             -- Wenn du es in NeoVim schon machst.
--             -- Sonst bekommst du unnötige Diff-Noise im Team.
--             -- format = {
--             --   enabled = true,
--             --   -- Bei Rroblemen
--             --   -- enabled = false,
--             --   settings = {
--             --     profile = "GoogleStyle",
--             --     -- ~/.config/nvim/lang-servers/intellij-java-google-style.xml
--             --     url = vim.fn.stdpath("config")
--             --       .. "/lang-servers/intellij-java-google-style.xml",

--             --     -- Alternative: ~/my-xm-slyte/Default.xml
--             --     -- url = vim.fn.expand("~/my-xm-slyte/Default.xml"),
--             --   }
--             -- },

--             format = {
--               enabled = true,
--               settings = {
--                 profile = "GoogleStyle",
--                 url = find_style_xml(),
--               },
--             },

--             -- signatureHelp = { enabled = true },

--             -- completion = {
--             --   favoriteStaticMembers = {
--             --     "org.hamcrest.MatcherAssert.assertThat",
--             --     "org.hamcrest.Matchers.*",
--             --     "org.junit.jupiter.api.Assertions.*",
--             --     "org.mockito.Mockito.*",
--             --     "java.util.Objects.requireNonNull",
--             --     "java.util.Objects.requireNonNullElse",
--             --   },

--             --   -- importOrder = {
--             --   --   "java",
--             --   --   "javax",
--             --   --   "com",
--             --   --   "org",
--             --   -- },

--             --   importOrder = {
--             --     "java",
--             --     "javax",
--             --     "jakarta",
--             --     "org",
--             --     "com",
--             --   },

--             --   -- Extended Completion Settings
--             --   guessMethodArguments = true,
--             --   -- filteredTypes = {
--             --   --   "com.sun.*",
--             --   --   "sun.*",
--             --   -- },
--             -- },

--             -- sources = {
--             --   organizeImports = {
--             --     starThreshold = 9999,
--             --     staticStarThreshold = 9999,
--             --   },
--             -- },

--             -- codeGeneration = {
--             --   -- useBlocks = true,
--             --   -- toString = {
--             --   --   template =
--             --   --   "${object.className}{${member.name()}=${member.value}, ${otherMembers}}",
--             --   -- },

--             --   useBlocks = true,
--             --   generateComments = true,
--             --   hashCodeEquals = {
--             --     useJava7Objects = true,
--             --   },
--             --   toString = {
--             --     template =
--             --       "${object.className}{${member.name()}=${member.value}, ${otherMembers}}",
--             --   },
--             -- },

--             -- inlayHints = {
--             --   parameterNames = { enabled = "all" },
--             -- },

--             -- Gradle explizit konfigurieren (wichtig!)
--             -- gradle = {
--             --   enabled = true,
--             --   -- offlineMode = false,
--             -- },

--             -- gradle = {
--             --   enabled = true,
--             --   wrapper = {
--             --     enabled = true,
--             --   },
--             -- },

--             -- Autobuild / Autobuild Watcher
--             -- Mit: Spring Boot, Gradle Wrapper, Hot Reload Debug Adapter kann das schnell CPU fressen.
--             -- autobuild = {
--             --   enabled = false,
--             -- },

--             -- Null Analysis Mode (Performance) -> Nur aktivieren wenn wirklich nötig!!!
--             -- project = {
--             --   referencedLibraries = {
--             --     "lib/**/*.jar",
--             --   },
--             -- },

--             -- Import Completion Advanced
--             -- import = {
--             --   maven = {
--             --     enabled = true,
--             --   },
--             --   gradle = {
--             --     enabled = true,
--             --   },
--             -- },

--             -- Decompiler Support
--             -- contentProvider = { preferred = "fernflower" }, -- Der "alte" Standard (wird auch von IntelliJ genutzt).
--             -- contentProvider = { preferred = "quiltflower" }, -- Besser für modernes Java (21+)
--             contentProvider = { preferred = "cfr" }, -- Der aktuell stärkste Decompiler für moderne Java-Features.
--             -- contentProvider = { preferred = "procyon" }, -- Ein sehr präziser Decompiler, der besonders gut mit Lambdas und synthetischen Methoden umgehen kann.

--             -- Semantic Highlighting (optisch besser)
--             -- semanticHighlighting = {
--             --   enabled = true,
--             -- },

--             -- Folding / Symbols Advanced: Unser NeoVim nutzt Tree-sitter Folding → dann unnötig.
--             -- foldingRange = {
--             --   enabled = true,
--             -- },

--             -- Save Actions (extrem praktisch)
--             -- Achtung: organizeImports beim Speichern kann in Teamprojekten unnötige Änderungen und Merge-Konflikte erzeugen
--             saveActions = {
--               organizeImports = true,
--             },
--           },
--         },
--       })

--       vim.lsp.enable("jdtls") -- Wird von nvim-java intern genutzt
--       -- require("lspconfig").jdtls.setup({}) -- Das ist die Standardmethode für LSPs über nvim-lspconfig, aber wenn du nvim-java benutzt -> bleib bei vim.lsp.enable("jdtls")

--       -- Automatisches Formatieren beim Speichern -> solte ohne gut gehen!
--       -- vim.api.nvim_create_autocmd("BufWritePre", {
--       --   pattern = "*.java",
--       --   callback = function()
--       --     vim.lsp.buf.format({
--       --       async = false,
--       --     })
--       --   end,
--       -- })

--       -- vim.diagnostic.config({
--       --   virtual_text = false,     -- Entfernt den Text hinter dem Code
--       --   underline = true,        -- Fehler werden nur unterstrichen
--       --   update_in_insert = false, -- Erst beim Verlassen des Insert-Modes prüfen
--       --   severity_sort = true,
--       -- })
--     end,

--     -- Bei Problemen:
--     -- :MasonInstall jdtls
--     -- :MasonInstall java-debug-adapter
--     -- :MasonInstall java-test

--     -- Bei Problemen mit Inlay Hints:
--     -- :edit
--     -- :lua vim.lsp.inlay_hint.enable(false)
--     -- :lua vim.lsp.inlay_hint.enable(true)
--     -- oder einfach
--     -- :lua vim.lsp.inlay_hint.enable(false)
--   },
-- }

local function find_style_xml()
  local cwd = vim.fn.getcwd()

  -- mögliche Kandidaten im Projekt
  local candidates = {
    cwd .. "/config/checkstyle/checkstyle.xml",
    cwd .. "/checkstyle.xml",
    cwd .. "/google_checks.xml",
  }

  for _, file in ipairs(candidates) do
    if vim.fn.filereadable(file) == 1 then
      return file
    end
  end

  -- Fallback auf deine globale Datei
  return vim.fn.stdpath("config") .. "/lang-servers/intellij-java-google-style.xml"
end

return {
  {
    "nvim-java/nvim-java",
    ft = { "java" },
    dependencies = {
      "neovim/nvim-lspconfig",
      "mfussenegger/nvim-dap",
      "mason-org/mason.nvim",
 	  "MunifTanjim/nui.nvim",
    },
    config = function()
      -- require("java").setup() -- Doppeltes require("java").setup() vermeiden Sonst: Debug/Test Bugs, Code-Actions verschwinden manchmal, doppelte LSP-Attachs, wird aber dennoch benötigt!
      -- Setup nvim-java

      -- wir haben noice.lua und brauchen daher keine eigenen Handler mehr für jdtls Notifications
    --   local handlers = {
    --     -- ["language/status"] = function(_, _) end,
    --     ["$/progress"] = function(_, _) end,
    --   }

      require("java").setup({
        jdk = {
          auto_install = false,
          path = "/usr/lib/jvm/java-25-openjdk",
        },

        lombok = {
          enable = true,
		  auto_install = true,
        },

        java_test = {
          enable = true,
        },

        java_debug_adapter = {
          enable = true,
        },

        spring_boot_tools = {
          enable = true,
        },

        notifications = {
          dap = true,
        },
      })

      vim.lsp.config("jdtls", {
        -- handlers = handlers,

        settings = {
          java = {
            -- eclipse = {
            --   downloadSources = true,
            -- },

            -- configuration = {
            --   runtimes = {
            --     -- { name = "JavaSE-1.6", path = "/usr/lib/jvm/java-6-openjdk/", default = true, },
            --     -- { name = "JavaSE-1.7", path = "/usr/lib/jvm/java-7-openjdk/", default = true, },
            --     -- { name = "JavaSE-1.8", path = "/usr/lib/jvm/java-8-openjdk/", default = true, },
            --     -- { name = "JavaSE-9",   path = "/usr/lib/jvm/java-9-openjdk/", default = true, },
            --     -- { name = "JavaSE-10",  path = "/usr/lib/jvm/java-10-openjdk/", default = true, },
            --     -- { name = "JavaSE-11",  path = "/usr/lib/jvm/java-11-openjdk/", default = true, }, -- LTS
            --     -- { name = "JavaSE-12",  path = "/usr/lib/jvm/java-12-openjdk/", default = true, },
            --     -- { name = "JavaSE-13",  path = "/usr/lib/jvm/java-13-openjdk/", default = true, },
            --     -- { name = "JavaSE-14",  path = "/usr/lib/jvm/java-14-openjdk/", default = true, },
            --     -- { name = "JavaSE-15",  path = "/usr/lib/jvm/java-15-openjdk/", default = true, },
            --     -- { name = "JavaSE-16",  path = "/usr/lib/jvm/java-16-openjdk/", default = true, },
            --     -- { name = "JavaSE-17",  path = "/usr/lib/jvm/java-17-openjdk/", default = true, }, -- LTS
            --     { name = "JavaSE-17",  path = "/usr/lib/jvm/java-17-openjdk/", }, -- LTS
            --     -- { name = "JavaSE-18",  path = "/usr/lib/jvm/java-18-openjdk/", default = true, },
            --     -- { name = "JavaSE-19",  path = "/usr/lib/jvm/java-19-openjdk/", default = true, },
            --     -- { name = "JavaSE-20",  path = "/usr/lib/jvm/java-20-openjdk/", default = true, },
            --     -- { name = "JavaSE-21",  path = "/usr/lib/jvm/java-21-openjdk/", default = true, }, -- LTS
            --     { name = "JavaSE-21",  path = "/usr/lib/jvm/java-21-openjdk/", }, -- LTS
            --     -- { name = "JavaSE-22",  path = "/usr/lib/jvm/java-22-openjdk/", default = true, },
            --     -- { name = "JavaSE-23",  path = "/usr/lib/jvm/java-23-openjdk/", default = true, },
            --     -- { name = "JavaSE-24",  path = "/usr/lib/jvm/java-24-openjdk/", default = true, },
            --     { name = "JavaSE-25", path = "/usr/lib/jvm/java-25-openjdk/", default = true, }, -- LTS
            --     -- { name = "JavaSE-26",  path = "/usr/lib/jvm/java-26-openjdk/", default = true, },
            --   },
            -- },

            -- maven = {
            --   downloadSources = true,
            --   updateSnapshots = true,
            -- },

            implementationsCodeLens = {
              enabled = true,
            },

            referencesCodeLens = {
              enabled = true,
            },

            references = {
              includeDecompiledSources = true,
            },

            -- XML Formatter (Google Style)
            -- Du nutzt GoogleStyle + eigenes XML.
            -- Das ist gut — aber nur, wenn IntelliJ exakt dasselbe XML nutzt.
            -- In IntelliJ IDEA solltest du:
            -- Settings → Editor → Code Style → Java → Import Scheme → Import from XML
            -- Dasselbe File verwenden wie:
            -- ~/.config/nvim/lang-servers/intellij-java-google-style.xml

            -- Profi-Level:
            -- Deaktiviere in IntelliJ:
            -- Optimize imports on the fly
            -- Reformat on save
            -- Wenn du es in NeoVim schon machst.
            -- Sonst bekommst du unnötige Diff-Noise im Team.
            -- format = {
            --   enabled = true,
            --   -- Bei Rroblemen
            --   -- enabled = false,
            --   settings = {
            --     profile = "GoogleStyle",
            --     -- ~/.config/nvim/lang-servers/intellij-java-google-style.xml
            --     url = vim.fn.stdpath("config")
            --       .. "/lang-servers/intellij-java-google-style.xml",

            --     -- Alternative: ~/my-xm-slyte/Default.xml
            --     -- url = vim.fn.expand("~/my-xm-slyte/Default.xml"),
            --   }
            -- },

            format = {
              enabled = true,
              settings = {
                profile = "GoogleStyle",
                url = find_style_xml(),
              },
            },

            -- signatureHelp = { enabled = true },

            completion = {
              favoriteStaticMembers = {
                "org.hamcrest.MatcherAssert.assertThat",
                "org.hamcrest.Matchers.*",
                "org.junit.jupiter.api.Assertions.*",
                "org.mockito.Mockito.*",
                "java.util.Objects.requireNonNull",
                "java.util.Objects.requireNonNullElse",
              },

              -- importOrder = {
              --   "java",
              --   "javax",
              --   "com",
              --   "org",
              -- },

              importOrder = {
                "java",
                "javax",
                "jakarta",
                "org",
                "com",
              },

              -- Extended Completion Settings
              guessMethodArguments = true,
              -- filteredTypes = {
              --   "com.sun.*",
              --   "sun.*",
              -- },
            },

            sources = {
              organizeImports = {
                starThreshold = 9999,
                staticStarThreshold = 9999,
              },
            },

            -- codeGeneration = {
            --   -- useBlocks = true,
            --   -- toString = {
            --   --   template =
            --   --   "${object.className}{${member.name()}=${member.value}, ${otherMembers}}",
            --   -- },

            --   useBlocks = true,
            --   generateComments = true,
            --   hashCodeEquals = {
            --     useJava7Objects = true,
            --   },
            --   toString = {
            --     template =
            --       "${object.className}{${member.name()}=${member.value}, ${otherMembers}}",
            --   },
            -- },

            inlayHints = {
              parameterNames = { enabled = "all" },
            },

            -- Gradle explizit konfigurieren (wichtig!)
            -- gradle = {
            --   enabled = true,
            --   -- offlineMode = false,
            -- },

            -- gradle = {
            --   enabled = true,
            --   wrapper = {
            --     enabled = true,
            --   },
            -- },

            -- Autobuild / Autobuild Watcher
            -- Mit: Spring Boot, Gradle Wrapper, Hot Reload Debug Adapter kann das schnell CPU fressen.
            -- autobuild = {
            --   enabled = false,
            -- },

            -- Null Analysis Mode (Performance) -> Nur aktivieren wenn wirklich nötig!!!
            -- project = {
            --   referencedLibraries = {
            --     "lib/**/*.jar",
            --   },
            -- },

            -- Import Completion Advanced
            -- import = {
            --   maven = {
            --     enabled = true,
            --   },
            --   gradle = {
            --     enabled = true,
            --   },
            -- },

            -- Decompiler Support
            -- contentProvider = { preferred = "fernflower" }, -- Der "alte" Standard (wird auch von IntelliJ genutzt).
            -- contentProvider = { preferred = "quiltflower" }, -- Besser für modernes Java (21+)
            contentProvider = { preferred = "cfr" }, -- Der aktuell stärkste Decompiler für moderne Java-Features.
            -- contentProvider = { preferred = "procyon" }, -- Ein sehr präziser Decompiler, der besonders gut mit Lambdas und synthetischen Methoden umgehen kann.

            -- Semantic Highlighting (optisch besser)
            semanticHighlighting = {
              enabled = true,
            },

            -- Folding / Symbols Advanced: Unser NeoVim nutzt Tree-sitter Folding → dann unnötig.
            -- foldingRange = {
            --   enabled = true,
            -- },

            -- Save Actions (extrem praktisch)
            -- Achtung: organizeImports beim Speichern kann in Teamprojekten unnötige Änderungen und Merge-Konflikte erzeugen
            saveActions = {
              organizeImports = true,
            },
          },
        },
      })

      vim.lsp.enable("jdtls") -- Wird von nvim-java intern genutzt
      -- require("lspconfig").jdtls.setup({}) -- Das ist die Standardmethode für LSPs über nvim-lspconfig, aber wenn du nvim-java benutzt -> bleib bei vim.lsp.enable("jdtls")

      -- Automatisches Formatieren beim Speichern -> solte ohne gut gehen!
      -- vim.api.nvim_create_autocmd("BufWritePre", {
      --   pattern = "*.java",
      --   callback = function()
      --     vim.lsp.buf.format({
      --       async = false,
      --     })
      --   end,
      -- })

      -- vim.diagnostic.config({
      --   virtual_text = false,     -- Entfernt den Text hinter dem Code
      --   underline = true,        -- Fehler werden nur unterstrichen
      --   update_in_insert = false, -- Erst beim Verlassen des Insert-Modes prüfen
      --   severity_sort = true,
      -- })
    end,

    -- Bei Problemen:
    -- :MasonInstall jdtls
    -- :MasonInstall java-debug-adapter
    -- :MasonInstall java-test

    -- Bei Problemen mit Inlay Hints:
    -- :edit
    -- :lua vim.lsp.inlay_hint.enable(false)
    -- :lua vim.lsp.inlay_hint.enable(true)
    -- oder einfach
    -- :lua vim.lsp.inlay_hint.enable(false)
  },
}
