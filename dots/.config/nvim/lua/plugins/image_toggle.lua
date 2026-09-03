-- plugins/image_toggle.lua

-- Pfad zur JSON-Datei
-- local json_file = vim.fn.expand("~/.config/nvim/image_toggle_status.json")

-- Initialisiere die JSON-Datei, falls sie nicht existiert
-- if vim.fn.filereadable(json_file) == 0 then
--   vim.fn.writefile({ vim.fn.json_encode({ display = true }) }, json_file)
-- end

-- Status aus JSON lesen
-- local function read_status()
--   local ok, data = pcall(vim.fn.json_decode, table.concat(vim.fn.readfile(json_file), "\n"))
--   if ok and data and data.display ~= nil then
--     return data.display
--   end
--   return false
-- end

-- local image_status = read_status()

-- Plugin Konfiguration
return {
	--   "3rd/image.nvim",
	--   cond = image_status, -- Plugin nur laden, wenn display = true
	--   opts = {
	--     backend = "kitty",
	--     max_width = 90,
	--     max_height = 20,
	--     max_width_window_percentage = math.huge,
	--     max_height_window_percentage = math.huge,
	--     editor_only_render_when_focused = false,
	--     integrations = {
	--       markdown = {
	--         enabled = true,
	--         clear_in_insert_mode = false,
	--         download_remote_images = true,
	--         only_render_image_at_cursor = false,
	--         filetypes = { "markdown", "vimwiki", "quarto", "latex", "tex" },
	--       },
	--     },
	--   },
	--   config = function(_, opts)
	--     local ok, image = pcall(require, "image")
	--     if not ok then
	--       return
	--     end

	--     image.setup(opts)
	--     vim.g.image_display = image_status

	--     local function safe_render()
	--       if image.render_at_cursor then
	--         image.render_at_cursor()
	--       elseif image.render_file then
	--         image.render_file(vim.api.nvim_buf_get_name(0))
	--       elseif image.render then
	--         image.render()
	--       end
	--     end

	--     local function save_status(value)
	--       vim.fn.writefile({ vim.fn.json_encode({ display = value }) }, json_file)
	--     end

	--     vim.g.image_on = function()
	--       vim.g.image_display = true
	--       if opts.integrations and opts.integrations.markdown then
	--         opts.integrations.markdown.enabled = true
	--       end
	--       safe_render()
	--       save_status(true)
	--       print("ImageON")
	--     end

	--     vim.g.image_off = function()
	--       vim.g.image_display = false
	--       if opts.integrations and opts.integrations.markdown then
	--         opts.integrations.markdown.enabled = false
	--       end
	--       image.clear()
	--       save_status(false)
	--       print("ImageOFF")
	--     end

	--     vim.g.image_toggle = function()
	--       if vim.g.image_display then
	--         vim.g.image_off()
	--       else
	--         vim.g.image_on()
	--       end
	--     end
	--   end,
}
