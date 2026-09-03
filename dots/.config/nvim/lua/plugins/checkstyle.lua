-- plugins/checkstyle.lua

return {
	-- {
	--   "mfussenegger/nvim-lint",
	--   event = { "BufReadPre", "BufNewFile" },
	--   config = function()
	--     local lint = require("lint")

	--     -- CHECKSTYLE CONFIG FIX
	--     lint.linters.checkstyle = {
	--       cmd = "checkstyle",
	--       stdin = false,
	--       args = function()
	--         local config = vim.fs.find(
	--           { "config/checkstyle/checkstyle.xml", "checkstyle.xml" },
	--           {
	--             upward = true,
	--             path = vim.fn.expand("%:p:h"),
	--             stop = vim.loop.os_homedir(),
	--           }
	--         )

	--         return {
	--           "-f", "sarif",
	--           "-c", (#config > 0 and config[1] or "google_checks.xml"),
	--           vim.api.nvim_buf_get_name(0),
	--         }
	--       end,
	--       stream = "stdout",
	--       ignore_exitcode = true,
	--       parser = require("lint.parser").from_errorformat(
	--         "%f:%l:%c: %m",
	--         {
	--           source = "checkstyle",
	--           severity = vim.diagnostic.severity.WARN,
	--         }
	--       ),
	--     }

	--     -- FILETYPE ZUWEISUNG
	--     lint.linters_by_ft = {
	--       java = { "checkstyle" },
	--     }

	--     -- DIAGNOSTICS (INLINE!)
	--     vim.diagnostic.config({
	--       virtual_text = {
	--         prefix = "●",
	--         source = "always",
	--       },
	--       underline = true,
	--       update_in_insert = false,
	--       severity_sort = true,
	--     })

	--     -- AUTOCMD: beim Speichern + beim Öffnen
	--     vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost" }, {
	--       group = vim.api.nvim_create_augroup("nvim-lint-java", { clear = true }),
	--       callback = function()
	--         lint.try_lint()
	--       end,
	--     })
	--   end,
	-- },
}
