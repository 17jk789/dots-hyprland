-- plugins/db.lua

-- return {
--   {
--     "kndndrj/nvim-dbee",
--     dependencies = { "MunifTanjim/nui.nvim" },

--     cmd = { "Dbee", "DbeeToggle", "DbeeOpen" },

--     build = function()
--       pcall(function()
--         require("dbee").install()
--       end)
--     end,

--     opts = function()
--       local ok, sources = pcall(require, "dbee.sources")
--       if not ok then return {} end

--       return {
--         sources = {
--           sources.EnvSource:new("DBEE_CONNECTIONS"),

--           sources.MemorySource:new({
--             {
--               name = "MySQL Docker",
--               type = "mysql",
--               -- Format: user:password@tcp(127.0.0.1:3306)/database
--               url = "root:rootpassword@tcp(127.0.0.1:3306)/test_db",
--             },

--             {
--               name = "Postgres Local",
--               type = "postgres",
--               url = "postgres://postgres:postgres@localhost:5432/test_db?sslmode=disable",
--             },

--             {
--               name = "MariaDB Local",
--               type = "mysql", -- MariaDB nutzt den mysql Treiber
--               url = "root:rootpassword@tcp(127.0.0.1:3306)/test_db",
--             },
--           }),

--           sources.FileSource:new(
--             vim.fn.stdpath("cache") .. "/dbee/persistence.json"
--           ),
--         },
--       }
--     end,

--     config = function(_, opts)
--       require("dbee").setup(opts)
--     end,

--     keys = {
--       { "<leader>Dt", function() require("dbee").toggle() end, desc = "DBee: Toggle UI" },
--     },
--   },
-- }

-- return {
--   {
--     "kndndrj/nvim-dbee",
--     dependencies = {
--       "MunifTanjim/nui.nvim"
--     },
--     cmd = { "Dbee", "DbeeToggle", "DbeeOpen" },

--     -- build = function()
--     --   pcall(function()
--     --     require("dbee").install()
--     --   end)
--     -- end,

--     build = "make install",

--     -- opts = {
--     --   sources = {
--     --     require("dbee.sources").EnvSource:new("DBEE_CONNECTIONS"),
--     --   },
--     -- },

--     opts = {},

--     config = function(_, opts)
--       require("dbee").setup(opts)
--     end,

--     keys = {
--       { "<leader>Dt", function() require("dbee").toggle() end, desc = "DBee: Toggle UI" },
--     },
--   },
-- }

return {
	--   {
	--     "kndndrj/nvim-dbee",
	--     dependencies = { "MunifTanjim/nui.nvim" },
	--     cmd = { "Dbee", "DbeeToggle", "DbeeOpen" },
	--     build = function()
	--       -- Nutzt die interne Installationsroutine des Plugins
	--       require("dbee").install()
	--     end,
	--     config = function()
	--       local dbee = require("dbee")
	--       local sources = require("dbee.sources")

	--       dbee.setup({
	--         sources = {
	--           -- Sicher: Secrets kommen aus der Umgebungsvariable
	--           sources.EnvSource:new("DBEE_CONNECTIONS"),
	--           -- Praktisch für temporäre Verbindungen im UI
	--           sources.MemorySource:new(),
	--         },
	--       })
	--     end,
	--     keys = {
	--       -- Lazy-loading: Plugin lädt erst beim Drücken des Hotkeys
	--       { "<leader>Dt", function() require("dbee").toggle() end, desc = "DBee: Toggle UI" },
	--     },
	--   },
}
