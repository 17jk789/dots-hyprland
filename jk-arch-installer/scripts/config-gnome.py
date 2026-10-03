Ausserdem: 

fügr noch hinzu dass gnone am nächsten an den keybindigs ist:

-- Experimentell: Diese Keybinds befinden sich noch in der Testphase.
-- Einige Commands funktionieren möglicherweise noch nicht vollständig oder fehlerfrei.

require("hyprland.lib")
require("hyprland.variables")
if is_file_exists(HOME .. "/.config/hypr/custom/variables.lua") then
	require("custom.variables")
end

local qsScripts = "$HOME/.config/quickshell/$qsConfig/scripts"
local hyprScripts = "$HOME/.config/hypr/hyprland/scripts"
local qsIpcCall = "qs -c $qsConfig ipc call"
local qsIsAlive = qsIpcCall .. " TEST_ALIVE"

hl.bind("SUPER + SUPER_L", function()
	hl.dispatch(hl.dsp.global("quickshell:searchToggleRelease"))
	hl.dispatch(hl.dsp.exec_cmd(qsIsAlive .. " || pkill fuzzel || fuzzel"))
end, { description = "Shell: Toggle search" })

hl.bind("SUPER + SUPER_R", function()
	hl.dispatch(hl.dsp.global("quickshell:searchToggleRelease"))
	hl.dispatch(hl.dsp.exec_cmd(qsIsAlive .. " || pkill fuzzel || fuzzel"))
end)

hl.bind("SUPER_L", hl.dsp.global("quickshell:workspaceNumber"), { ignore_mods = true, transparent = true })
hl.bind("SUPER_R", hl.dsp.global("quickshell:workspaceNumber"), { ignore_mods = true, transparent = true })
hl.bind(
	"SUPER_L",
	hl.dsp.global("quickshell:workspaceNumber"),
	{ ignore_mods = true, transparent = true, release = true }
)
hl.bind(
	"SUPER_R",
	hl.dsp.global("quickshell:workspaceNumber"),
	{ ignore_mods = true, transparent = true, release = true }
)

hl.bind("SUPER + Tab", hl.dsp.global("quickshell:overviewWorkspacesToggle"), { description = "Shell: Toggle overview" })

hl.bind("SUPER + V", function()
	hl.dispatch(hl.dsp.global("quickshell:overviewClipboardToggle"))
	hl.dispatch(
		hl.dsp.exec_cmd(
			qsIsAlive
				.. " || pkill fuzzel || cliphist list | fuzzel --match-mode fzf --dmenu | cliphist decode | wl-copy"
		)
	)
end, { description = "Utilities: Clipboard history >> clipboard" })

hl.bind("SUPER + Period", function()
	hl.dispatch(hl.dsp.global("quickshell:overviewEmojiToggle"))
	hl.dispatch(hl.dsp.exec_cmd(qsIsAlive .. " || pkill fuzzel || " .. hyprScripts .. "/fuzzel-emoji.sh copy"))
end, { description = "Utilities: Emoji >> clipboard" })

hl.bind("SUPER + A", hl.dsp.global("quickshell:sidebarLeftToggle"), { description = "Shell: Toggle left sidebar" })
hl.bind("ALT + SUPER + A", hl.dsp.global("quickshell:sidebarLeftToggleDetach"))
hl.bind("SUPER + B", hl.dsp.global("quickshell:sidebarLeftToggle"))
hl.bind("SUPER + O", hl.dsp.global("quickshell:sidebarLeftToggle"))
hl.bind("SUPER + N", hl.dsp.global("quickshell:sidebarRightToggle"), { description = "Shell: Toggle right sidebar" })
hl.bind("SUPER + SHIFT + 7", hl.dsp.global("quickshell:cheatsheetToggle"), { description = "Shell: Toggle cheatsheet" })
hl.bind("SUPER + K", hl.dsp.global("quickshell:oskToggle"), { description = "Shell: Toggle on-screen keyboard" })
hl.bind("SUPER + M", hl.dsp.global("quickshell:mediaControlsToggle"), { description = "Shell: Toggle media controls" })
hl.bind("SUPER + G", hl.dsp.global("quickshell:overlayToggle"), { description = "Shell: Toggle widget overlay" })

hl.bind("CTRL + ALT + Delete", function()
	hl.dispatch(hl.dsp.global("quickshell:sessionToggle"))
	hl.dispatch(hl.dsp.exec_cmd(qsIsAlive .. " || pkill wlogout || wlogout -p layer-shell"))
end, { description = "Shell: Toggle session menu" })

hl.bind("SUPER + J", hl.dsp.global("quickshell:barToggle"), { description = "Shell: Toggle bar" })

hl.bind("ALT + SUPER + SHIFT + 7", hl.dsp.exec_cmd("qs -p $HOME/.config/quickshell/$qsConfig/welcome.qml"))

hl.bind(
	"XF86MonBrightnessUp",
	hl.dsp.exec_cmd(qsIpcCall .. " brightness increment || brightnessctl s 5%+"),
	{ locked = true, repeating = true }
)

hl.bind(
	"XF86MonBrightnessDown",
	hl.dsp.exec_cmd(qsIpcCall .. " brightness decrement || brightnessctl s 5%-"),
	{ locked = true, repeating = true }
)

hl.bind(
	"XF86AudioRaiseVolume",
	hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%+ -l 1.5"),
	{ locked = true, repeating = true }
)

hl.bind(
	"XF86AudioLowerVolume",
	hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%-"),
	{ locked = true, repeating = true }
)

hl.bind("CTRL + SUPER + T", function()
	hl.dispatch(hl.dsp.global("quickshell:wallpaperSelectorToggle"))
	hl.dispatch(hl.dsp.exec_cmd(qsIsAlive .. " || " .. qsScripts .. "/colors/switchwall.sh"))
end, { description = "Shell: Change wallpaper" })

hl.bind(
	"CTRL + ALT + SUPER + T",
	hl.dsp.global("quickshell:wallpaperSelectorRandom"),
	{ description = "Shell: Random wallpaper" }
)

hl.bind(
	"CTRL + SUPER + SHIFT + D",
	hl.dsp.global("quickshell:toggleLightDark"),
	{ description = "Shell: Toggle light/dark mode" }
)

hl.bind(
	"CTRL + SUPER + R",
	hl.dsp.exec_cmd("killall ydotool qs quickshell; qs -c $qsConfig &"),
	{ description = "Shell: Restart widgets" }
)

hl.bind("CTRL + SUPER + P", hl.dsp.global("quickshell:panelFamilyCycle"), { description = "Shell: Cycle panel family" })

--##! Utilities
--# Screenshot, Record, OCR, Color picker, Clipboard history

hl.bind("SUPER + SHIFT + S", function()
	hl.dispatch(hl.dsp.global("quickshell:regionScreenshot"))
	hl.dispatch(
		hl.dsp.exec_cmd(qsIsAlive .. " || pidof slurp || hyprshot --freeze --clipboard-only --mode region --silent")
	)
end, { description = "Utilities: Screen snip" })

hl.bind("SUPER + SHIFT + A", function()
	hl.dispatch(hl.dsp.global("quickshell:regionSearch"))
	hl.dispatch(hl.dsp.exec_cmd(qsIsAlive .. " || pidof slurp || " .. hyprScripts .. "/snip_to_search.sh"))
end, { description = "Utilities: Google Lens" })

--# OCR
hl.bind("SUPER + SHIFT + X", function()
	hl.dispatch(hl.dsp.global("quickshell:regionOcr"))
	hl.dispatch(
		hl.dsp.exec_cmd(
			qsIsAlive
				.. ' || pidof slurp || grim -g "$(slurp $SLURP_ARGS)" "/tmp/ocr_image.png" && '
				.. 'tesseract "/tmp/ocr_image.png" stdout -l '
				.. "$(tesseract --list-langs | awk 'NR>1{print $1}' | tr '\\n' '+' | sed 's/\\+$/\\n/') | "
				.. 'wl-copy && rm "/tmp/ocr_image.png"'
		)
	)
end, { description = "Utilities: Character recognition >> clipboard" })

hl.bind(
	"SUPER + SHIFT + T",
	hl.dsp.global("quickshell:screenTranslate"),
	{ description = "Utilities: Translate screen content" }
)

--# Color picker
hl.bind(
	"SUPER + SHIFT + C",
	hl.dsp.exec_cmd("hyprpicker -a"),
	{ description = "Utilities: Pick color #RRGGBB >> clipboard" }
)

--# Recording stuff
hl.bind("SUPER + SHIFT + R", function()
	hl.dispatch(hl.dsp.global("quickshell:regionRecord"))
	hl.dispatch(hl.dsp.exec_cmd(qsIsAlive .. " || " .. qsScripts .. "/videos/record.sh"))
end, {
	locked = true,
	description = "Utilities: Record region (no sound)",
})

hl.bind("SHIFT + ALT + SUPER + R", function()
	hl.dispatch(hl.dsp.global("quickshell:regionRecord"))
	hl.dispatch(hl.dsp.exec_cmd(qsIsAlive .. " || " .. qsScripts .. "/videos/record.sh"))
end, { locked = true })

hl.bind("CTRL + ALT + R", hl.dsp.exec_cmd(qsScripts .. "/videos/record.sh --fullscreen"), { locked = true })

hl.bind(
	"SHIFT + ALT + SUPER + R",
	hl.dsp.exec_cmd(qsScripts .. "/videos/record.sh --fullscreen --sound"),
	{ locked = true, description = "Utilities: Record screen (with sound)" }
)

--# Fullscreen screenshot
local grimhyprctl = "grim -o \"$(hyprctl activeworkspace -j | jq -r '.monitor')\""

-- hl.bind("Print", hl.dsp.exec_cmd(grimhyprctl .. " - | wl-copy"),
--     { locked = true, description = "Utilities: Screenshot >> clipboard" })

hl.bind("Print", hl.dsp.exec_cmd("obs"), { description = "App: Start OBS" })

hl.bind("CTRL + Print", function()
	hl.dispatch(
		hl.dsp.exec_cmd(
			"mkdir -p $(xdg-user-dir PICTURES)/Screenshots && "
				.. grimhyprctl
				.. " $(xdg-user-dir PICTURES)/Screenshots/Screenshot_\"$(date '+%Y-%m-%d_%H.%M.%S')\".png"
		)
	)
	hl.dispatch(hl.dsp.exec_cmd(grimhyprctl .. " - | wl-copy"))
end, {
	locked = true,
	non_consuming = true,
	description = "Utilities: Screenshot >> clipboard & file",
})

--# AI
hl.bind(
	"SHIFT + ALT + SUPER + mouse:273",
	hl.dsp.exec_cmd(hyprScripts .. "/ai/primary-buffer-query.sh"),
	{ description = "Utilities: Generate AI summary for selected text" }
)
-- (requires a running ollama model)

--##! Screen
--# Zoom
local function zoomfunction(value)
	local zoomvalue = hl.get_config("cursor:zoom_factor")

	if (zoomvalue + value) > 3.0 then
		hl.config({ cursor = { zoom_factor = 3.0 } })
	elseif (zoomvalue + value) < 1.0 then
		hl.config({ cursor = { zoom_factor = 1.0 } })
	else
		hl.config({ cursor = { zoom_factor = zoomvalue + value } })
	end
end

hl.bind("SUPER + Minus", function()
	zoomfunction(-0.3)
end, { repeating = true, description = "Screen: Zoom out" })

hl.bind("SUPER + SHIFT + 0", function()
	zoomfunction(0.3)
end, { repeating = true, description = "Screen: Zoom in" })

--# Zoom with keypad
hl.bind("SUPER + code:82", function()
	zoomfunction(-0.3)
end, { repeating = true })

hl.bind("SUPER + code:86", function()
	zoomfunction(0.3)
end, { repeating = true })

--##! Media
local mediaNextCommand =
	'playerctl next || playerctl position `bc <<< "100 * $(playerctl metadata mpris:length) / 1000000 / 100"`'

hl.bind("SUPER + SHIFT + N", hl.dsp.exec_cmd(mediaNextCommand), { locked = true, description = "Media: Next track" })

hl.bind("XF86AudioNext", hl.dsp.exec_cmd(mediaNextCommand), { locked = true })

hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })

hl.bind("SHIFT + ALT + SUPER + mouse:275", hl.dsp.exec_cmd("playerctl previous"))

hl.bind("SHIFT + ALT + SUPER + mouse:276", hl.dsp.exec_cmd(mediaNextCommand))

hl.bind(
	"SUPER + SHIFT + B",
	hl.dsp.exec_cmd("playerctl previous"),
	{ locked = true, description = "Media: Previous track" }
)

hl.bind(
	"SUPER + SHIFT + P",
	hl.dsp.exec_cmd("playerctl play-pause"),
	{ locked = true, description = "Media: Play/pause media" }
)

hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })

hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })

hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_SINK@ toggle"), { locked = true })

hl.bind(
	"SUPER + SHIFT + M",
	hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_SINK@ toggle"),
	{ locked = true, description = "Media: Toggle mute" }
)

hl.bind("ALT + XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_SOURCE@ toggle"), { locked = true })

hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_SOURCE@ toggle"), { locked = true })

hl.bind(
	"ALT + SUPER + M",
	hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_SOURCE@ toggle"),
	{ locked = true, description = "Media: Toggle mic" }
)

--#!
--##! Window
--# Focusing
hl.bind("SUPER + mouse:272", hl.dsp.window.drag(), { mouse = true, description = "Window: Move" })

hl.bind("SUPER + mouse:274", hl.dsp.window.drag(), { mouse = true })

hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), { mouse = true, description = "Window: Resize" })

--#/# bind = SUPER + ←/↑/→/↓,, -- Focus in direction
for i = 1, 4 do
	local arrowkey = { "Left", "Right", "Up", "Down" }
	local focusdir = { "l", "r", "u", "d" }

	hl.bind(
		"SUPER + " .. arrowkey[i],
		hl.dsp.focus({ direction = focusdir[i] }),
		{ description = "Window: Focus " .. arrowkey[i] }
	)
end

--# Swap windows
for i = 1, 4 do
	local arrowkey = { "Left", "Right", "Up", "Down" }
	local swappedir = { "l", "r", "u", "d" }

	hl.bind(
		"ALT + SHIFT + SUPER + " .. arrowkey[i],
		hl.dsp.exec_cmd("hyprctl dispatch swapwindow " .. swappedir[i]),
		{ description = "Window: Swap " .. arrowkey[i] }
	)
end

--# Previous / last window
hl.bind(
	"CTRL + SUPER + Tab",
	hl.dsp.exec_cmd("hyprctl dispatch focuscurrentorlast"),
	{ description = "Window: Focus last" }
)

hl.bind("ALT + CTRL + Tab", hl.dsp.exec_cmd("hyprctl dispatch cyclenext"), { description = "Window: Cycle next" })

hl.bind(
	"ALT + SHIFT + Tab",
	hl.dsp.exec_cmd("hyprctl dispatch cyclenext prev"),
	{ description = "Window: Cycle previous" }
)

--# Center floating window
hl.bind("ALT + SUPER + C", hl.dsp.exec_cmd("hyprctl dispatch centerwindow"), { description = "Window: Center" })

for i = 1, 2 do
	local arrowkey = { "udiaeresis", "plus" }
	local focusdir = { "l", "r" }

	hl.bind("SUPER + " .. arrowkey[i], hl.dsp.focus({ direction = focusdir[i] }))
end

--#/# bind = SUPER + SHIFT, ←/↑/→/↓,, -- Move in direction
for i = 1, 4 do
	local arrowkey = { "Left", "Right", "Up", "Down" }
	local focusdir = { "l", "r", "u", "d" }

	hl.bind(
		"SUPER + SHIFT + " .. arrowkey[i],
		hl.dsp.window.move({ direction = focusdir[i] }),
		{ description = "Window: Move " .. arrowkey[i] }
	)
end

hl.bind("ALT + F4", function()
	hl.dispatch(
		hl.dsp.exec_cmd('notify-send "Wrong close keybind" "Super+Q to close. Use Alt+F4 for Windows VMs" -a Hyprland')
	)
end, { non_consuming = true })

hl.bind("SUPER + Q", hl.dsp.window.close(), { description = "Window: Close" })

hl.bind("SHIFT + ALT + SUPER + Q", hl.dsp.exec_cmd("hyprctl kill"), { description = "Window: Forcefully zap a window" })

--# Window split ratio
--#/# binde = SUPER, ;/',, -- Adjust split ratio
hl.bind("SUPER + odiaeresis", hl.dsp.layout("splitratio -0.1"), { repeating = true })

hl.bind("SUPER + adiaeresis", hl.dsp.layout("splitratio +0.1"), { repeating = true })

hl.bind("SHIFT + ALT + SUPER + comma", hl.dsp.layout("splitratio -0.05"), { repeating = true })

hl.bind("SHIFT + ALT + SUPER + 3", hl.dsp.layout("splitratio +0.05"), { repeating = true })

hl.bind("CTRL + SHIFT + SUPER + comma", hl.dsp.layout("splitratio -0.25"), { repeating = true })

hl.bind("CTRL + SHIFT + SUPER + 3", hl.dsp.layout("splitratio +0.25"), { repeating = true })

--# Positioning mode
hl.bind("ALT + SUPER + Space", hl.dsp.window.float({ action = "toggle" }), { description = "Window: Float/Tile" })

hl.bind(
	"SUPER + D",
	hl.dsp.window.fullscreen({ mode = "maximized", action = "toggle" }),
	{ description = "Window: Maximize" }
)

hl.bind(
	"SUPER + F",
	hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" }),
	{ description = "Window: Fullscreen" }
)

hl.bind(
	"ALT + SUPER + F",
	hl.dsp.window.fullscreen_state({
		internal = 0,
		client = 3,
		action = "toggle",
	}),
	{ description = "Window: Fullscreen spoof" }
)

hl.bind("SUPER + P", hl.dsp.window.pin(), { description = "Window: Pin" })

--#/# bind = SUPER+ALT, Hash,, -- Send to workspace -- (1, 2, 3,...)
for i = 1, 10 do
	hl.bind("ALT + SUPER + " .. (i % 10), function()
		hl.dispatch(hl.dsp.window.move({
			workspace = workspace_in_group(i),
			follow = false,
		}))
	end, { description = "Window: Send to workspace " .. i })
end

--# We also use raw keycodes because some keyboard layouts register number keys as different chars. The codes can be verified with `wev`
-- for i = 1, 10 do
--     local numberkey = { 10, 11, 12, 13, 14, 15, 16, 17, 18, 19 }
--     hl.bind("ALT + SUPER + code:" .. numberkey[i], function()
--         hl.dispatch(hl.dsp.window.move({
--             workspace = workspace_in_group(i),
--             follow = false
--         }))
--     end)
-- end

--# keypad numbers
for i = 1, 10 do
	local numpadkey = { 87, 88, 89, 83, 84, 85, 79, 80, 81, 90 }

	hl.bind("ALT + SUPER + code:" .. numpadkey[i], function()
		hl.dispatch(hl.dsp.window.move({
			workspace = workspace_in_group(i),
			follow = false,
		}))
	end)
end

--# #/# bind = SUPER+SHIFT, Scroll ↑/↓,, -- Send to workspace left/right
for i = 1, 4 do
	local key = {
		"SUPER + SHIFT + mouse_",
		"ALT + SUPER + mouse_",
	}

	local keycombos = {
		key[1] .. "down",
		key[1] .. "up",
		key[2] .. "down",
		key[2] .. "up",
	}

	local prefix = { "r-", "r+", "r-", "r+" }

	hl.bind(keycombos[i], hl.dsp.window.move({ workspace = prefix[i] .. "1" }))
end

--#/# bind = SUPER+SHIFT, Page_↑/↓,, -- Send to workspace left/right
for i = 1, 2 do
	local keydirs = { "Up", "Down" }
	local prefix = { "r-", "r+" }
	local descdir = { "left", "right" }

	hl.bind(
		"SUPER + SHIFT + Page_" .. keydirs[i],
		hl.dsp.window.move({ workspace = prefix[i] .. "1" }),
		{ description = "Window: Send to workspace " .. descdir[i] }
	)
end

for i = 1, 4 do
	local key = {
		"ALT + SUPER + Page_",
		"CTRL + SHIFT + SUPER + ",
	}

	local keycombos = {
		key[1] .. "down",
		key[1] .. "up",
		key[2] .. "Right",
		key[2] .. "Left",
	}

	local prefix = { "r+", "r-", "r+", "r-" }

	hl.bind(keycombos[i], hl.dsp.window.move({ workspace = prefix[i] .. "1" }))
end

hl.bind(
	"ALT + SUPER + S",
	hl.dsp.window.move({
		workspace = "special:special",
		follow = false,
	}),
	{ description = "Window: Send to scratchpad" }
)

hl.bind("CTRL + SUPER + S", hl.dsp.workspace.toggle_special("special"))

--##! Workspace
--# Switching
--#/# bind = SUPER, Hash,, -- Focus workspace -- (1, 2, 3,...)
for i = 1, 10 do
	hl.bind("SUPER + " .. (i % 10), function()
		hl.dispatch(hl.dsp.focus({
			workspace = workspace_in_group(i),
		}))
	end, { description = "Workspace: Focus " .. i })
end

--# We also use raw keycodes because some keyboard layouts register number keys as different chars. The codes can be verified with `wev`
for i = 1, 10 do
	local numberkey = { 10, 11, 12, 13, 14, 15, 16, 17, 18, 19 }

	hl.bind("SUPER + code:" .. numberkey[i], function()
		hl.dispatch(hl.dsp.focus({
			workspace = workspace_in_group(i),
		}))
	end)
end

--# keypad numbers
for i = 1, 10 do
	local numpadkey = { 87, 88, 89, 83, 84, 85, 79, 80, 81, 90 }

	hl.bind("SUPER + code:" .. numpadkey[i], function()
		hl.dispatch(hl.dsp.focus({
			workspace = workspace_in_group(i),
		}))
	end)
end

--#/# bind = CTRL+SUPER, ←/→,, -- Focus left/right
--#/# bind = CTRL+SUPER+ALT, ←/→,, -- # [hidden] Focus busy left/right
for i = 1, 2 do
	local keys = { "Left", "Right" }
	local prefix = { "r-", "r+" }
	local descdir = { "left", "right" }

	hl.bind(
		"CTRL + SUPER + " .. keys[i],
		hl.dsp.focus({ workspace = prefix[i] .. "1" }),
		{ description = "Workspace: Focus " .. descdir[i] }
	)
end

for i = 1, 2 do
	local keys = { "Left", "Right" }
	local prefix = { "m-", "m+" }

	hl.bind(
		"CTRL + ALT + SUPER + " .. keys[i],
		hl.dsp.focus({ workspace = prefix[i] .. "1" }),
		{ description = "Workspace: Focus " .. (i == 1 and "previous monitor" or "next monitor") }
	)
end

--#/# bind = SUPER, Page_↑/↓,, -- Focus left/right
for i = 1, 4 do
	local key = {
		"SUPER + Page_Down",
		"SUPER + Page_Up",
	}

	local keycombos = {
		key[1],
		key[2],
		"CTRL + " .. key[1],
		"CTRL + " .. key[2],
	}

	local prefix = { "r+", "r-", "r+", "r-" }

	hl.bind(keycombos[i], hl.dsp.focus({ workspace = prefix[i] .. "1" }))
end

--#/# bind = SUPER, Scroll ↑/↓,, -- Focus left/right
for i = 1, 4 do
	local key = {
		"SUPER + mouse_up",
		"SUPER + mouse_down",
	}

	local keycombos = {
		key[1],
		key[2],
		"CTRL + " .. key[1],
		"CTRL + " .. key[2],
	}

	local prefix = { "+", "-", "r+", "r-" }

	hl.bind(keycombos[i], hl.dsp.focus({ workspace = prefix[i] .. "1" }))
end

--## Special
hl.bind("SUPER + S", hl.dsp.workspace.toggle_special("special"), { description = "Workspace: Toggle scratchpad" })

hl.bind("SUPER + mouse:275", hl.dsp.workspace.toggle_special("special"))

for i = 1, 4 do
	local key = {
		"udiaeresis",
		"plus",
		"Up",
		"Down",
	}

	local prefix = {
		"-1",
		"+1",
		"r-5",
		"r+5",
	}

	hl.bind("CTRL + SUPER + " .. key[i], hl.dsp.focus({ workspace = prefix[i] }))
end

--##! Virtual machines
hl.define_submap("virtual-machine", function()
	hl.bind("ALT + SUPER + F1", function()
		local currentsubmap = hl.get_current_submap()

		if currentsubmap == "virtual-machine" then
			hl.dispatch(
				hl.dsp.exec_cmd("notify-send 'Exited Virtual Machine submap' 'Keybinds re-enabled' -a 'Hyprland'")
			)

			hl.dispatch(hl.dsp.submap("reset"))
		elseif currentsubmap == "" then
			hl.dispatch(
				hl.dsp.exec_cmd(
					"notify-send 'Entered Virtual Machine submap' 'Keybinds disabled. hit SUPER+ALT+F1 to escape' -a 'Hyprland'"
				)
			)

			hl.dispatch(hl.dsp.submap("virtual-machine"))
		end
	end, { submap_universal = true })
end)

--#!
--# Testing
hl.bind(
	"ALT + SUPER + F11",
	hl.dsp.exec_cmd(
		'bash -c \'RANDOM_IMAGE=$(find ~/Pictures -type f | shuf -n 1); ACTION=$(notify-send "Test notification with body image" "This notification should contain your user account <b>image</b> and <a href=\\"https://discord.com/app\\">Discord</a> <b>icon</b>. Oh and here is a random image in your Pictures folder: <img src=\\"$RANDOM_IMAGE\\" alt=\\"Testing image\\"/>" -a "Hyprland" -p -h "string:image-path:/var/lib/AccountsService/icons/$USER" -t 6000 -i "discord" -A "openImage=Profile image" -A "action2=Open the random image" -A "action3=Useless button"); [[ $ACTION == *openImage ]] && xdg-open "/var/lib/AccountsService/icons/$USER"; [[ $ACTION == *action2 ]] && xdg-open "$RANDOM_IMAGE"\''
	)
) -- # [hidden]

hl.bind(
	"ALT + SUPER + F12",
	hl.dsp.exec_cmd(
		'bash -c \'RANDOM_IMAGE=$(find ~/Pictures -type f | shuf -n 1); ACTION=$(notify-send "Test notification" "This notification should contain a random image in your <b>Pictures</b> folder and <a href=\\"https://discord.com/app\\">Discord</a> <b>icon</b>.\n<i>Flick right to dismiss!</i>" -a "Discord (fake)" -p -h "string:image-path:$RANDOM_IMAGE" -t 6000 -i "discord" -A "openImage=Profile image" -A "action2=Useless button"); [[ $ACTION == *openImage ]] && xdg-open "/var/lib/AccountsService/icons/$USER"\''
	)
) -- # [hidden]

hl.bind(
	"ALT + SUPER + SHIFT + 0",
	hl.dsp.exec_cmd("notify-send 'Urgent notification' 'Ah hell no' -u critical -a 'Hyprland keybind'")
) -- # [hidden]

--##! Session
hl.bind("SUPER + L", hl.dsp.exec_cmd("loginctl lock-session"), { description = "Session: Lock" })

hl.bind(
	"SUPER + SHIFT + L",
	hl.dsp.exec_cmd("systemctl suspend || loginctl suspend"),
	{ locked = true, description = "Session: Sleep" }
)

-- hl.bind("switch:on:Lid Switch",
--     hl.dsp.exec_cmd("systemctl suspend || loginctl suspend"),
--     { locked = true }) -- # [hidden] Suspend when laptop lid is closed, uncomment if for whatever reason it's not the default behavior

hl.bind(
	"CTRL + SHIFT + ALT + SUPER + Delete",
	hl.dsp.exec_cmd("systemctl poweroff || loginctl poweroff"),
	{ description = "Session: Shut down" }
) -- # [hidden] Power off

for i = 1, 2 do
	local keys = { "H", "H" }
	local prefix = { "m-", "m+" }

	hl.bind(
		(i == 1 and "SUPER + " or "ALT + SUPER + ") .. keys[i],
		hl.dsp.focus({ workspace = prefix[i] .. "1" }),
		{ description = "Workspace: " .. (i == 1 and "Previous" or "Next") }
	)
end

hl.bind("ALT + Tab", hl.dsp.focus({ last = true }), { description = "Window: Focus last" })

hl.bind("SUPER + SHIFT + Tab", hl.dsp.focus({ workspace = "-1" }), { description = "Workspace: Previous" })

hl.bind("CTRL + SUPER + F", function()
	hl.dispatch(hl.dsp.window.float({ action = "toggle" }))
	hl.dispatch(hl.dsp.window.pin())
end, { description = "Window: Float + Always on top" })

hl.bind("CTRL + SUPER + O", function()
	hl.dispatch(hl.dsp.window.pin())
	hl.dispatch(hl.dsp.window.float({ action = "toggle" }))
end, { description = "Window: Return to tiling" })

hl.bind("XF86Calculator", hl.dsp.exec_cmd("qalculate-gtk"), { description = "App: Start Qalculate" })

hl.bind("CTRL + SUPER + G", hl.dsp.exec_cmd("fish -c 'glasstoggle 0.80'"), { description = "Toggle glass mode" })

hl.bind(
	"CTRL + SUPER + H",
	hl.dsp.exec_cmd("kitty --hold python3 $HOME/.config/fish/functions/gnome-toggle.py --reboot"),
	{ description = "Session: Toggle GNOME/Hyprland profile" }
)

hl.bind("CTRL + SUPER + B", hl.dsp.exec_cmd("fish -c border-visible"), { description = "Toggle border visibility" })

--##! Apps
hl.bind("SUPER + Return", hl.dsp.exec_cmd(terminal), { description = "App: Terminal" })

hl.bind("SUPER + T", hl.dsp.exec_cmd(terminal))

hl.bind("CTRL + ALT + T", hl.dsp.exec_cmd(terminal))

hl.bind("SUPER + E", hl.dsp.exec_cmd(fileManager), { description = "App: File manager" })

hl.bind("SUPER + W", hl.dsp.exec_cmd(browser), { description = "App: Browser" }) -- Sollte Brave laut JK-Arch Config sein

hl.bind("SUPER + ALT + W", hl.dsp.exec_cmd("firefox"), { description = "App: Firefox" })

hl.bind(
	"CTRL + SUPER + W",
	hl.dsp.exec_cmd("mullvad-browser -P"),
	{ description = "App: Mullvad Browser" }
)

hl.bind(
	"SUPER + SHIFT + W",
	hl.dsp.exec_cmd("librewolf"),
	{ description = "App: LibreWolf" }
)

hl.bind("SUPER + ALT + SHIFT + W", hl.dsp.exec_cmd("torbrowser-launcher"), { description = "App: Tor Browser" })

hl.bind(
	"ALT + space",
	hl.dsp.exec_cmd(
		'bash -c \'BROWSERS=(brave firefox librewolf mullvad-browser); ${BROWSERS[$((RANDOM % ${#BROWSERS[@]}))]}\''
	),
	{ description = "App: Random browser" }
)

hl.bind("SUPER + C", hl.dsp.exec_cmd(codeEditor), { description = "App: Code editor" })

hl.bind("CTRL + SHIFT + ALT + SUPER + W", hl.dsp.exec_cmd(officeSoftware), { description = "App: Office software" })

hl.bind("SUPER + X", hl.dsp.exec_cmd(textEditor), { description = "App: Text editor" })

hl.bind("CTRL + SUPER + V", hl.dsp.exec_cmd(volumeMixer), { description = "App: Volume mixer" })

hl.bind("SUPER + I", hl.dsp.exec_cmd(settingsApp), { description = "App: Settings app" })

hl.bind("CTRL + SHIFT + Escape", hl.dsp.exec_cmd(taskManager), { description = "App: Task manager" })

--# Cursed stuff
--## Make window not amogus large
hl.bind(
	"CTRL + SUPER + ALT + ssharp",
	hl.dsp.window.resize({
		x = 640,
		y = 480,
		"exact",
	})
)

-- Magic Mouse Vor und Zurück mit SUPER-Taste + Wischen
-- hl.bind("mouse:274", hl.dsp.exec_cmd("kitty"))
-- hl.bind("SUPER + mouse_down", hl.dsp.exec_cmd("hyprctl dispatch workspace e+1"))
-- hl.bind("SUPER + mouse_up", hl.dsp.exec_cmd("hyprctl dispatch workspace e-1"))


#!/usr/bin/env python3

# Fix theme evt. noch besser, er soll im gleich ornder ./assets/dash-to-panel.conf verwenden!!! Er soll nichts ausgeben was er nihct tut also "
# print(
#     "No yay"
# )

# print(
#     "No paru"
# )

# print(
#     "No AUR"
# )" muss raus. ok!!!

# Es msuss aber auch eifnach gut zu dem gtk-4.0 theme passen!!!

# 
# /*
#  * ============================================================
#  * CATPPUCCIN GTK 4 — STABLE / FOCUS-SAFE
#  * ============================================================
#  *
#  * Catppuccin Latte / Mocha
#  *
#  * Source template:
#  *   ~/.config/matugen/templates/gtk-4.0/gtk.css
#  *
#  * Goals:
#  *   - Exact Catppuccin Latte / Mocha colors
#  *   - Consistent GTK 4 semantic color roles
#  *   - Stable colors when window loses focus
#  *   - Stable headerbar / titlebar
#  *   - Stable sidebar / backdrop
#  *   - Stable popovers / menus / dialogs
#  *   - Complete legacy GTK compatibility
#  *   - Complete Catppuccin palette aliases
#  *   - No automatic color fading caused by backdrop colors
#  *
#  * IMPORTANT:
#  *   This file intentionally defines backdrop colors equal to
#  *   their normal counterparts. GTK therefore has no reason to
#  *   visually "dim" the application when it loses focus.
#  *
#  * ============================================================
#  */

# /* ============================================================
#  * LIGHT — CATPPUCCIN LATTE
#  * ============================================================ */

# @media (prefers-color-scheme: light) {
#   /* ==========================================================
#    * ACCENT
#    * ========================================================== */

#   @define-color accent_color #8839ef;
#   @define-color accent_bg_color #8839ef;
#   @define-color accent_fg_color #eff1f5;

#   @define-color accent_hover_color rgba(136, 57, 239, 0.08);
#   @define-color accent_active_color rgba(136, 57, 239, 0.12);

#   @define-color accent_vibrant_hover_color rgba(136, 57, 239, 0.18);
#   @define-color accent_vibrant_active_color rgba(136, 57, 239, 0.26);

#   /* ==========================================================
#    * STATUS / SEMANTIC COLORS
#    * ========================================================== */

#   @define-color destructive_color #d20f39;
#   @define-color destructive_bg_color #d20f39;
#   @define-color destructive_fg_color #eff1f5;

#   @define-color error_color #d20f39;
#   @define-color error_bg_color #d20f39;
#   @define-color error_fg_color #eff1f5;

#   @define-color warning_color #df8e1d;
#   @define-color warning_bg_color #df8e1d;
#   @define-color warning_fg_color #eff1f5;

#   @define-color success_color #40a02b;
#   @define-color success_bg_color #40a02b;
#   @define-color success_fg_color #eff1f5;

#   /* ==========================================================
#    * WINDOW
#    * ========================================================== */

#   @define-color window_bg_color #eff1f5;
#   @define-color window_fg_color #4c4f69;

#   @define-color view_bg_color #eff1f5;
#   @define-color view_fg_color #4c4f69;

#   @define-color content_view_bg #eff1f5;
#   @define-color text_view_bg #eff1f5;

#   /* ==========================================================
#    * HEADERBAR / TITLEBAR
#    *
#    * IMPORTANT:
#    * backdrop == normal
#    *
#    * This prevents the headerbar from changing when the
#    * application loses focus.
#    * ========================================================== */

#   @define-color headerbar_bg_color #eff1f5;
#   @define-color headerbar_fg_color #4c4f69;

#   @define-color headerbar_backdrop_color #eff1f5;

#   /* ==========================================================
#    * SIDEBAR
#    * ========================================================== */

#   @define-color sidebar_bg_color #eff1f5;
#   @define-color sidebar_fg_color #4c4f69;

#   @define-color sidebar_backdrop_color #eff1f5;
#   @define-color sidebar_border_color #eff1f5;

#   @define-color sidebar_row_active_bg_color #8839ef;
#   @define-color sidebar_row_active_fg_color #eff1f5;

#   /* ==========================================================
#    * SECONDARY SIDEBAR
#    * ========================================================== */

#   @define-color secondary_sidebar_bg_color #e6e9ef;
#   @define-color secondary_sidebar_fg_color #5c5f77;

#   @define-color secondary_sidebar_backdrop_color #e6e9ef;

#   /* ==========================================================
#    * CARDS
#    * ========================================================== */

#   @define-color card_bg_color #e6e9ef;
#   @define-color card_fg_color #4c4f69;

#   /* ==========================================================
#    * DIALOGS
#    * ========================================================== */

#   @define-color dialog_bg_color #e6e9ef;
#   @define-color dialog_fg_color #4c4f69;

#   /* ==========================================================
#    * THUMBNAILS
#    * ========================================================== */

#   @define-color thumbnail_bg_color #e6e9ef;
#   @define-color thumbnail_fg_color #4c4f69;

#   /* ==========================================================
#    * POPOVERS
#    * ========================================================== */

#   @define-color popover_bg_color #e6e9ef;
#   @define-color popover_fg_color #4c4f69;

#   @define-color popover_fg_hover_color rgba(76, 79, 105, 0.08);

#   /* ==========================================================
#    * MENUS
#    * ========================================================== */

#   @define-color menu_bg_color #e6e9ef;
#   @define-color menu_fg_color #4c4f69;

#   /* ==========================================================
#    * TOOLTIP
#    * ========================================================== */

#   @define-color tooltip_bg_color #4c4f69;
#   @define-color tooltip_fg_color #eff1f5;

#   /* ==========================================================
#    * OVERVIEW / NEW TAB
#    * ========================================================== */

#   @define-color overview_bg_color #dce0e8;
#   @define-color overview_fg_color #4c4f69;

#   /* ==========================================================
#    * SURFACE HIERARCHY
#    * ========================================================== */

#   @define-color surface_container_lowest #dce0e8;
#   @define-color surface_container_low #e6e9ef;
#   @define-color surface_container #e6e9ef;
#   @define-color surface_container_high #dce0e8;
#   @define-color surface_container_highest #ccd0da;

#   @define-color surface_variant #dce0e8;
#   @define-color on_surface_variant #5c5f77;

#   /* ==========================================================
#    * OUTLINES
#    * ========================================================== */

#   @define-color outline #9ca0b0;
#   @define-color outline_variant #ccd0da;

#   @define-color border_color #ccd0da;
#   @define-color borders #ccd0da;

#   /*
#    * Keep unfocused borders subtle, but don't make them
#    * disappear or become darker when the window loses focus.
#    */
#   @define-color unfocused_borders #e6e9ef;

#   /* ==========================================================
#    * TEXT
#    * ========================================================== */

#   @define-color text_color #4c4f69;
#   @define-color secondary_text_color #5c5f77;
#   @define-color muted_text_color #6c6f85;
#   @define-color placeholder_text_color #9ca0b0;

#   @define-color insensitive_fg_color #9ca0b0;
#   @define-color insensitive_bg_color #e6e9ef;
#   @define-color insensitive_base_color #e6e9ef;

#   /* ==========================================================
#    * SELECTION
#    * ========================================================== */

#   @define-color selected_bg_color #8839ef;
#   @define-color selected_fg_color #eff1f5;

#   @define-color theme_selected_bg_color #8839ef;
#   @define-color theme_selected_fg_color #eff1f5;

#   /* ==========================================================
#    * LINKS
#    * ========================================================== */

#   @define-color link_color #1e66f5;
#   @define-color link_visited_color #7287fd;

#   /* ==========================================================
#    * SCROLLBAR
#    * ========================================================== */

#   @define-color scrollbar_bg_color #e6e9ef;
#   @define-color scrollbar_slider_color #ccd0da;
#   @define-color scrollbar_slider_hover_color #bcc0cc;

#   /* ==========================================================
#    * INVERSE / MATERIAL ROLES
#    * ========================================================== */

#   @define-color inverse_on_surface #eff1f5;
#   @define-color inverse_primary #1e66f5;
#   @define-color inverse_surface #4c4f69;

#   @define-color inverse_on_surface_hover rgba(239, 241, 245, 0.08);
#   @define-color inverse_on_surface_active rgba(239, 241, 245, 0.18);

#   @define-color inverse_primary_hover rgba(30, 102, 245, 0.08);
#   @define-color inverse_primary_active rgba(30, 102, 245, 0.18);

#   /* ==========================================================
#    * LEGACY GTK
#    * ========================================================== */

#   @define-color theme_fg_color #4c4f69;
#   @define-color theme_text_color #4c4f69;
#   @define-color theme_bg_color #eff1f5;
#   @define-color theme_base_color #eff1f5;
#   @define-color theme_text_aa_color #6c6f85;

#   /* ==========================================================
#    * COMPLETE CATPPUCCIN LATTE
#    * ========================================================== */

#   @define-color crust #dce0e8;
#   @define-color mantle #e6e9ef;
#   @define-color base #eff1f5;

#   @define-color surface0 #e6e9ef;
#   @define-color surface1 #ccd0da;
#   @define-color surface2 #bcc0cc;

#   @define-color overlay0 #9ca0b0;
#   @define-color overlay1 #8c8fa1;
#   @define-color overlay2 #7c7f93;

#   @define-color subtext0 #6c6f85;
#   @define-color subtext1 #5c5f77;
#   @define-color text #4c4f69;

#   @define-color rosewater #dc8a78;
#   @define-color flamingo #dd7878;
#   @define-color pink #ea76cb;
#   @define-color mauve #8839ef;

#   @define-color red #d20f39;
#   @define-color maroon #e64553;
#   @define-color peach #fe640b;
#   @define-color yellow #df8e1d;

#   @define-color green #40a02b;
#   @define-color teal #179299;
#   @define-color sky #04a5e5;
#   @define-color sapphire #209fb5;

#   @define-color blue #1e66f5;
#   @define-color lavender #7287fd;

#   /* ==========================================================
#    * COLOR ALIASES
#    * ========================================================== */

#   @define-color red_color #d20f39;
#   @define-color orange_color #fe640b;
#   @define-color yellow_color #df8e1d;
#   @define-color green_color #40a02b;
#   @define-color teal_color #179299;
#   @define-color sky_color #04a5e5;
#   @define-color sapphire_color #209fb5;
#   @define-color blue_color #1e66f5;
#   @define-color lavender_color #7287fd;
#   @define-color mauve_color #8839ef;
#   @define-color pink_color #ea76cb;
#   @define-color flamingo_color #dd7878;
#   @define-color maroon_color #e64553;
#   @define-color rosewater_color #dc8a78;

#   /* ==========================================================
#    * UTILITY
#    * ========================================================== */

#   @define-color accent_color_rgba rgba(136, 57, 239, 1);
#   @define-color accent_bg_color_rgba rgba(136, 57, 239, 1);

#   @define-color transparent rgba(0, 0, 0, 0);

#   /* ==========================================================
#    * CSS CUSTOM PROPERTIES
#    * ========================================================== */

#   :root {
#     --accent-color: #8839ef;
#     --accent-bg-color: #8839ef;
#     --accent-fg-color: #eff1f5;

#     --destructive-color: #d20f39;
#     --destructive-bg-color: #d20f39;
#     --destructive-fg-color: #eff1f5;

#     --error-color: #d20f39;
#     --error-bg-color: #d20f39;
#     --error-fg-color: #eff1f5;

#     --warning-color: #df8e1d;
#     --warning-bg-color: #df8e1d;
#     --warning-fg-color: #eff1f5;

#     --success-color: #40a02b;
#     --success-bg-color: #40a02b;
#     --success-fg-color: #eff1f5;

#     --window-bg-color: #eff1f5;
#     --window-fg-color: #4c4f69;

#     --view-bg-color: #eff1f5;
#     --view-fg-color: #4c4f69;

#     --content-view-bg: #eff1f5;
#     --text-view-bg: #eff1f5;

#     --headerbar-bg-color: #eff1f5;
#     --headerbar-fg-color: #4c4f69;
#     --headerbar-backdrop-color: #eff1f5;

#     --sidebar-bg-color: #eff1f5;
#     --sidebar-fg-color: #4c4f69;
#     --sidebar-backdrop-color: #eff1f5;
#     --sidebar-border-color: #eff1f5;

#     --secondary-sidebar-bg-color: #e6e9ef;
#     --secondary-sidebar-fg-color: #5c5f77;
#     --secondary-sidebar-backdrop-color: #e6e9ef;

#     --card-bg-color: #e6e9ef;
#     --card-fg-color: #4c4f69;

#     --dialog-bg-color: #e6e9ef;
#     --dialog-fg-color: #4c4f69;

#     --popover-bg-color: #e6e9ef;
#     --popover-fg-color: #4c4f69;

#     --menu-bg-color: #e6e9ef;
#     --menu-fg-color: #4c4f69;

#     --overview-bg-color: #dce0e8;
#     --overview-fg-color: #4c4f69;

#     --surface-container-lowest: #dce0e8;
#     --surface-container-low: #e6e9ef;
#     --surface-container: #e6e9ef;
#     --surface-container-high: #dce0e8;
#     --surface-container-highest: #ccd0da;

#     --surface-variant: #dce0e8;
#     --on-surface-variant: #5c5f77;

#     --outline-color: #9ca0b0;
#     --outline-variant: #ccd0da;

#     --text-color: #4c4f69;
#     --secondary-text-color: #5c5f77;
#     --muted-text-color: #6c6f85;
#     --placeholder-text-color: #9ca0b0;

#     --selected-bg-color: #8839ef;
#     --selected-fg-color: #eff1f5;

#     --selection-bg-color: #8839ef;
#     --selection-fg-color: #eff1f5;

#     --link-color: #1e66f5;
#     --link-visited-color: #7287fd;

#     --border-color: #ccd0da;
#     --borders: #ccd0da;
#     --unfocused-borders: #e6e9ef;

#     --scrollbar-bg-color: #e6e9ef;
#     --scrollbar-slider-color: #ccd0da;
#     --scrollbar-slider-hover-color: #bcc0cc;

#     --crust: #dce0e8;
#     --mantle: #e6e9ef;
#     --base: #eff1f5;

#     --surface0: #e6e9ef;
#     --surface1: #ccd0da;
#     --surface2: #bcc0cc;

#     --overlay0: #9ca0b0;
#     --overlay1: #8c8fa1;
#     --overlay2: #7c7f93;

#     --subtext0: #6c6f85;
#     --subtext1: #5c5f77;
#     --text: #4c4f69;

#     --rosewater: #dc8a78;
#     --flamingo: #dd7878;
#     --pink: #ea76cb;
#     --mauve: #8839ef;

#     --red: #d20f39;
#     --maroon: #e64553;
#     --peach: #fe640b;
#     --yellow: #df8e1d;

#     --green: #40a02b;
#     --teal: #179299;
#     --sky: #04a5e5;
#     --sapphire: #209fb5;

#     --blue: #1e66f5;
#     --lavender: #7287fd;
#   }
# }

# /* ============================================================
#  * DARK — CATPPUCCIN MOCHA
#  * ============================================================ */

# @media (prefers-color-scheme: dark) {
#   /* ==========================================================
#    * ACCENT
#    * ========================================================== */

#   @define-color accent_color #cba6f7;
#   @define-color accent_bg_color #cba6f7;
#   @define-color accent_fg_color #1e1e2e;

#   @define-color accent_hover_color rgba(203, 166, 247, 0.08);
#   @define-color accent_active_color rgba(203, 166, 247, 0.12);

#   @define-color accent_vibrant_hover_color rgba(203, 166, 247, 0.18);
#   @define-color accent_vibrant_active_color rgba(203, 166, 247, 0.26);

#   /* ==========================================================
#    * STATUS / SEMANTIC COLORS
#    * ========================================================== */

#   @define-color destructive_color #f38ba8;
#   @define-color destructive_bg_color #f38ba8;
#   @define-color destructive_fg_color #1e1e2e;

#   @define-color error_color #f38ba8;
#   @define-color error_bg_color #f38ba8;
#   @define-color error_fg_color #1e1e2e;

#   @define-color warning_color #f9e2af;
#   @define-color warning_bg_color #f9e2af;
#   @define-color warning_fg_color #1e1e2e;

#   @define-color success_color #a6e3a1;
#   @define-color success_bg_color #a6e3a1;
#   @define-color success_fg_color #1e1e2e;

#   /* ==========================================================
#    * WINDOW
#    * ========================================================== */

#   @define-color window_bg_color #1e1e2e;
#   @define-color window_fg_color #cdd6f4;

#   @define-color view_bg_color #1e1e2e;
#   @define-color view_fg_color #cdd6f4;

#   @define-color content_view_bg #1e1e2e;
#   @define-color text_view_bg #1e1e2e;

#   /* ==========================================================
#    * HEADERBAR / TITLEBAR
#    *
#    * IMPORTANT:
#    * backdrop == normal
#    *
#    * The headerbar therefore stays EXACTLY the same when
#    * another application receives focus.
#    * ========================================================== */

#   @define-color headerbar_bg_color #1e1e2e;
#   @define-color headerbar_fg_color #cdd6f4;

#   @define-color headerbar_backdrop_color #1e1e2e;

#   /* ==========================================================
#    * SIDEBAR
#    * ========================================================== */

#   @define-color sidebar_bg_color #1e1e2e;
#   @define-color sidebar_fg_color #cdd6f4;

#   @define-color sidebar_backdrop_color #1e1e2e;
#   @define-color sidebar_border_color #1e1e2e;

#   @define-color sidebar_row_active_bg_color #cba6f7;
#   @define-color sidebar_row_active_fg_color #1e1e2e;

#   /* ==========================================================
#    * SECONDARY SIDEBAR
#    * ========================================================== */

#   @define-color secondary_sidebar_bg_color #181825;
#   @define-color secondary_sidebar_fg_color #bac2de;

#   @define-color secondary_sidebar_backdrop_color #181825;

#   /* ==========================================================
#    * CARDS
#    * ========================================================== */

#   @define-color card_bg_color #313244;
#   @define-color card_fg_color #cdd6f4;

#   /* ==========================================================
#    * DIALOGS
#    * ========================================================== */

#   @define-color dialog_bg_color #313244;
#   @define-color dialog_fg_color #cdd6f4;

#   /* ==========================================================
#    * THUMBNAILS
#    * ========================================================== */

#   @define-color thumbnail_bg_color #313244;
#   @define-color thumbnail_fg_color #cdd6f4;

#   /* ==========================================================
#    * POPOVERS
#    * ========================================================== */

#   @define-color popover_bg_color #313244;
#   @define-color popover_fg_color #cdd6f4;

#   @define-color popover_fg_hover_color rgba(205, 214, 244, 0.08);

#   /* ==========================================================
#    * MENUS
#    * ========================================================== */

#   @define-color menu_bg_color #313244;
#   @define-color menu_fg_color #cdd6f4;

#   /* ==========================================================
#    * TOOLTIP
#    * ========================================================== */

#   @define-color tooltip_bg_color #11111b;
#   @define-color tooltip_fg_color #cdd6f4;

#   /* ==========================================================
#    * OVERVIEW / NEW TAB
#    * ========================================================== */

#   @define-color overview_bg_color #11111b;
#   @define-color overview_fg_color #cdd6f4;

#   /* ==========================================================
#    * SURFACE HIERARCHY
#    *
#    * Deliberately kept coherent with Catppuccin Mocha:
#    *
#    * crust  -> #11111b
#    * mantle -> #181825
#    * base   -> #1e1e2e
#    * surface0 -> #313244
#    * surface1 -> #45475a
#    * ========================================================== */

#   @define-color surface_container_lowest #11111b;
#   @define-color surface_container_low #181825;
#   @define-color surface_container #181825;

#   @define-color surface_container_high #1f1f2e;
#   @define-color surface_container_highest #313244;

#   @define-color surface_variant #45475a;
#   @define-color on_surface_variant #a6adc8;

#   /* ==========================================================
#    * OUTLINES
#    * ========================================================== */

#   @define-color outline #7f849c;
#   @define-color outline_variant #45475a;

#   @define-color border_color #45475a;
#   @define-color borders #45475a;

#   @define-color unfocused_borders #313244;

#   /* ==========================================================
#    * TEXT
#    * ========================================================== */

#   @define-color text_color #cdd6f4;
#   @define-color secondary_text_color #bac2de;
#   @define-color muted_text_color #a6adc8;
#   @define-color placeholder_text_color #6c7086;

#   @define-color insensitive_fg_color #6c7086;
#   @define-color insensitive_bg_color #181825;
#   @define-color insensitive_base_color #181825;

#   /* ==========================================================
#    * SELECTION
#    * ========================================================== */

#   @define-color selected_bg_color #cba6f7;
#   @define-color selected_fg_color #1e1e2e;

#   @define-color theme_selected_bg_color #cba6f7;
#   @define-color theme_selected_fg_color #1e1e2e;

#   /* ==========================================================
#    * LINKS
#    * ========================================================== */

#   @define-color link_color #89b4fa;
#   @define-color link_visited_color #b4befe;

#   /* ==========================================================
#    * SCROLLBAR
#    * ========================================================== */

#   @define-color scrollbar_bg_color #181825;
#   @define-color scrollbar_slider_color #45475a;
#   @define-color scrollbar_slider_hover_color #585b70;

#   /* ==========================================================
#    * INVERSE / MATERIAL ROLES
#    * ========================================================== */

#   @define-color inverse_on_surface #1e1e2e;
#   @define-color inverse_primary #89b4fa;
#   @define-color inverse_surface #cdd6f4;

#   @define-color inverse_on_surface_hover rgba(30, 30, 46, 0.08);
#   @define-color inverse_on_surface_active rgba(30, 30, 46, 0.18);

#   @define-color inverse_primary_hover rgba(137, 180, 250, 0.08);
#   @define-color inverse_primary_active rgba(137, 180, 250, 0.18);

#   /* ==========================================================
#    * LEGACY GTK
#    * ========================================================== */

#   @define-color theme_fg_color #cdd6f4;
#   @define-color theme_text_color #cdd6f4;
#   @define-color theme_bg_color #1e1e2e;
#   @define-color theme_base_color #1e1e2e;
#   @define-color theme_text_aa_color #a6adc8;

#   /* ==========================================================
#    * COMPLETE CATPPUCCIN MOCHA
#    * ========================================================== */

#   @define-color crust #11111b;
#   @define-color mantle #181825;
#   @define-color base #1e1e2e;

#   @define-color surface0 #313244;
#   @define-color surface1 #45475a;
#   @define-color surface2 #585b70;

#   @define-color overlay0 #6c7086;
#   @define-color overlay1 #7f849c;
#   @define-color overlay2 #9399b2;

#   @define-color subtext0 #a6adc8;
#   @define-color subtext1 #bac2de;
#   @define-color text #cdd6f4;

#   @define-color rosewater #f5e0e5;
#   @define-color flamingo #f2cdcd;
#   @define-color pink #f5c2e7;
#   @define-color mauve #cba6f7;

#   @define-color red #f38ba8;
#   @define-color maroon #eba0ac;
#   @define-color peach #fab387;
#   @define-color yellow #f9e2af;

#   @define-color green #a6e3a1;
#   @define-color teal #94e2d5;
#   @define-color sky #89dceb;
#   @define-color sapphire #74c7ec;

#   @define-color blue #89b4fa;
#   @define-color lavender #b4befe;

#   /* ==========================================================
#    * COLOR ALIASES
#    * ========================================================== */

#   @define-color red_color #f38ba8;
#   @define-color orange_color #fab387;
#   @define-color yellow_color #f9e2af;
#   @define-color green_color #a6e3a1;
#   @define-color teal_color #94e2d5;
#   @define-color sky_color #89dceb;
#   @define-color sapphire_color #74c7ec;
#   @define-color blue_color #89b4fa;
#   @define-color lavender_color #b4befe;
#   @define-color mauve_color #cba6f7;
#   @define-color pink_color #f5c2e7;
#   @define-color flamingo_color #f2cdcd;
#   @define-color maroon_color #eba0ac;
#   @define-color rosewater_color #f5e0e5;

#   /* ==========================================================
#    * UTILITY
#    * ========================================================== */

#   @define-color accent_color_rgba rgba(203, 166, 247, 1);
#   @define-color accent_bg_color_rgba rgba(203, 166, 247, 1);

#   @define-color transparent rgba(0, 0, 0, 0);

#   /* ==========================================================
#    * CSS CUSTOM PROPERTIES
#    * ========================================================== */

#   :root {
#     --accent-color: #cba6f7;
#     --accent-bg-color: #cba6f7;
#     --accent-fg-color: #1e1e2e;

#     --destructive-color: #f38ba8;
#     --destructive-bg-color: #f38ba8;
#     --destructive-fg-color: #1e1e2e;

#     --error-color: #f38ba8;
#     --error-bg-color: #f38ba8;
#     --error-fg-color: #1e1e2e;

#     --warning-color: #f9e2af;
#     --warning-bg-color: #f9e2af;
#     --warning-fg-color: #1e1e2e;

#     --success-color: #a6e3a1;
#     --success-bg-color: #a6e3a1;
#     --success-fg-color: #1e1e2e;

#     --window-bg-color: #1e1e2e;
#     --window-fg-color: #cdd6f4;

#     --view-bg-color: #1e1e2e;
#     --view-fg-color: #cdd6f4;

#     --content-view-bg: #1e1e2e;
#     --text-view-bg: #1e1e2e;

#     --headerbar-bg-color: #1e1e2e;
#     --headerbar-fg-color: #cdd6f4;
#     --headerbar-backdrop-color: #1e1e2e;

#     --sidebar-bg-color: #1e1e2e;
#     --sidebar-fg-color: #cdd6f4;
#     --sidebar-backdrop-color: #1e1e2e;
#     --sidebar-border-color: #1e1e2e;

#     --secondary-sidebar-bg-color: #181825;
#     --secondary-sidebar-fg-color: #bac2de;
#     --secondary-sidebar-backdrop-color: #181825;

#     --card-bg-color: #313244;
#     --card-fg-color: #cdd6f4;

#     --dialog-bg-color: #313244;
#     --dialog-fg-color: #cdd6f4;

#     --popover-bg-color: #313244;
#     --popover-fg-color: #cdd6f4;

#     --menu-bg-color: #313244;
#     --menu-fg-color: #cdd6f4;

#     --overview-bg-color: #11111b;
#     --overview-fg-color: #cdd6f4;

#     --surface-container-lowest: #11111b;
#     --surface-container-low: #181825;
#     --surface-container: #181825;
#     --surface-container-high: #1f1f2e;
#     --surface-container-highest: #313244;

#     --surface-variant: #45475a;
#     --on-surface-variant: #a6adc8;

#     --outline-color: #7f849c;
#     --outline-variant: #45475a;

#     --text-color: #cdd6f4;
#     --secondary-text-color: #bac2de;
#     --muted-text-color: #a6adc8;
#     --placeholder-text-color: #6c7086;

#     --selected-bg-color: #cba6f7;
#     --selected-fg-color: #1e1e2e;

#     --selection-bg-color: #cba6f7;
#     --selection-fg-color: #1e1e2e;

#     --link-color: #89b4fa;
#     --link-visited-color: #b4befe;

#     --border-color: #45475a;
#     --borders: #45475a;
#     --unfocused-borders: #313244;

#     --scrollbar-bg-color: #181825;
#     --scrollbar-slider-color: #45475a;
#     --scrollbar-slider-hover-color: #585b70;

#     --crust: #11111b;
#     --mantle: #181825;
#     --base: #1e1e2e;

#     --surface0: #313244;
#     --surface1: #45475a;
#     --surface2: #585b70;

#     --overlay0: #6c7086;
#     --overlay1: #7f849c;
#     --overlay2: #9399b2;

#     --subtext0: #a6adc8;
#     --subtext1: #bac2de;
#     --text: #cdd6f4;

#     --rosewater: #f5e0e5;
#     --flamingo: #f2cdcd;
#     --pink: #f5c2e7;
#     --mauve: #cba6f7;

#     --red: #f38ba8;
#     --maroon: #eba0ac;
#     --peach: #fab387;
#     --yellow: #f9e2af;

#     --green: #a6e3a1;
#     --teal: #94e2d5;
#     --sky: #89dceb;
#     --sapphire: #74c7ec;

#     --blue: #89b4fa;
#     --lavender: #b4befe;
#   }
# }


"""
======================================================================
CATPPUCCIN MOCHA — GNOME SHELL 50 / 51
======================================================================

A modular GNOME Shell color theme for Arch Linux.

Inspired by the architecture of:
    Marble Shell Theme
    Catppuccin GTK Theme

DESIGN GOALS
------------

* Catppuccin Mocha palette
* GNOME Shell 50 / 51
* Modular CSS architecture
* Colors only
* No GTK 3 modification
* No GTK 4 / Libadwaita modification
* No application theme modification
* No font modification
* No layout modification
* No geometry modification
* No animation modification
* No Dash-to-Panel configuration
* No shortcut modification
* pacman only for optional packages

FILES
-----

~/.local/share/gnome-shell/extensions/
    catppuccin-mocha-colors@local/

        metadata.json
        extension.js

        stylesheet.css
        colors.css
        app.css
        panel.css
        popup-menu.css
        quick-settings.css
        calendar.css
        notifications.css
        overview.css
        dash.css
        dialogs.css
        search.css
        widgets.css
        osd.css

IMPORTANT
---------

This script does NOT install User Themes.

It uses a small GNOME Shell extension which loads the
theme stylesheet directly with St.Theme.

The theme is therefore independent of GTK 3 and GTK 4.

======================================================================
"""

from __future__ import annotations

import json
import os
import shutil
import subprocess
import sys
from datetime import datetime
from pathlib import Path


# ======================================================================
# CONFIGURATION
# ======================================================================

HOME = Path.home()

UUID = "catppuccin-mocha-colors@local"

EXTENSION_NAME = "Catppuccin Mocha Shell Colors"

EXTENSION_DIR = (
    HOME
    / ".local"
    / "share"
    / "gnome-shell"
    / "extensions"
    / UUID
)


# ======================================================================
# CATPPUCCIN MOCHA
# ======================================================================

COLORS = {
    "rosewater": "#f5e0e5",
    "flamingo": "#f2cdcd",
    "pink": "#f5c2e7",
    "mauve": "#cba6f7",
    "red": "#f38ba8",
    "maroon": "#eba0ac",
    "peach": "#fab387",
    "yellow": "#f9e2af",
    "green": "#a6e3a1",
    "teal": "#94e2d5",
    "sky": "#89dceb",
    "sapphire": "#74c7ec",
    "blue": "#89b4fa",
    "lavender": "#b4befe",

    "text": "#cdd6f4",
    "subtext1": "#bac2de",
    "subtext0": "#a6adc8",

    "overlay2": "#9399b2",
    "overlay1": "#7f849c",
    "overlay0": "#6c7086",

    "surface2": "#585b70",
    "surface1": "#45475a",
    "surface0": "#313244",

    "base": "#1e1e2e",
    "mantle": "#181825",
    "crust": "#11111b",
}


# ======================================================================
# HELPERS
# ======================================================================

def command_exists(command: str) -> bool:
    return shutil.which(command) is not None


def run(
    command: list[str],
    *,
    check: bool = True,
    capture: bool = False,
) -> subprocess.CompletedProcess:

    print("$", " ".join(command))

    return subprocess.run(
        command,
        check=check,
        text=True,
        capture_output=capture,
    )


def ask_yes_no(question: str) -> bool:

    while True:

        try:
            answer = input(
                f"{question} [y/n]: "
            ).strip().lower()

        except EOFError:
            return False

        if answer in {"y", "yes"}:
            return True

        if answer in {"n", "no"}:
            return False

        print("Please answer y or n.")


def package_installed(package: str) -> bool:

    result = subprocess.run(
        [
            "pacman",
            "-Q",
            package,
        ],
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
        check=False,
    )

    return result.returncode == 0


def pacman_install(*packages: str) -> None:

    packages = tuple(
        package
        for package in packages
        if package
    )

    if not packages:
        return

    run(
        [
            "sudo",
            "pacman",
            "-S",
            "--needed",
            *packages,
        ]
    )


def extension_exists() -> bool:

    result = run(
        [
            "gnome-extensions",
            "info",
            UUID,
        ],
        check=False,
        capture=True,
    )

    return result.returncode == 0


def extension_enabled() -> bool:

    result = run(
        [
            "gnome-extensions",
            "info",
            UUID,
        ],
        check=False,
        capture=True,
    )

    output = (
        result.stdout
        + "\n"
        + result.stderr
    ).lower()

    return (
        "state: enabled" in output
        or "status: enabled" in output
    )


def disable_extension() -> None:

    run(
        [
            "gnome-extensions",
            "disable",
            UUID,
        ],
        check=False,
    )


def enable_extension() -> bool:

    result = run(
        [
            "gnome-extensions",
            "enable",
            UUID,
        ],
        check=False,
    )

    return result.returncode == 0


def write_file(
    path: Path,
    content: str,
) -> None:

    path.write_text(
        content.rstrip() + "\n",
        encoding="utf-8",
    )

    print(
        f"  wrote {path.name:<24} "
        f"{path.stat().st_size:>7} bytes"
    )


# ======================================================================
# ROOT CHECK
# ======================================================================

if os.geteuid() == 0:

    print()
    print("Do NOT run this script as root.")
    print("The script uses sudo only when pacman needs it.")
    print()

    sys.exit(1)


# ======================================================================
# COMMAND CHECK
# ======================================================================

required_commands = [
    "pacman",
    "gsettings",
    "gnome-extensions",
]

for command in required_commands:

    if not command_exists(command):

        print()
        print(
            f"[ERROR] Required command not found: {command}"
        )
        print()

        if command == "pacman":
            print("This installer is intended for Arch Linux.")

        elif command == "gsettings":
            print("Install the GNOME desktop components.")

        elif command == "gnome-extensions":
            print("Install gnome-shell.")

        sys.exit(1)


# ======================================================================
# GNOME VERSION
# ======================================================================

if command_exists("gnome-shell"):

    result = run(
        [
            "gnome-shell",
            "--version",
        ],
        check=False,
        capture=True,
    )

    shell_version = (
        result.stdout.strip()
        or result.stderr.strip()
    )

else:

    shell_version = "unknown"


# ======================================================================
# HEADER
# ======================================================================

print()
print("=" * 78)
print("       CATPPUCCIN MOCHA — GNOME SHELL")
print("                    COLOR THEME")
print("=" * 78)
print()

print("Detected Shell:")
print(f"  {shell_version}")
print()

print("Architecture:")
print("  Modular CSS")
print("  Catppuccin color tokens")
print("  Direct St.Theme stylesheet loading")
print()

print("Untouched:")
print("  GTK 3")
print("  GTK 4 / Libadwaita")
print("  Application themes")
print("  Fonts")
print("  Font sizes")
print("  Width")
print("  Height")
print("  Padding")
print("  Margins")
print("  Spacing")
print("  Border radius")
print("  Shadows")
print("  Animations")
print("  Transitions")
print("  Shortcuts")
print("  Dash-to-Panel settings")
print()


# ======================================================================
# OPTIONAL PAPIRUS
# ======================================================================

print("=" * 78)
print("[1/8] OPTIONAL ICON THEME")
print("=" * 78)
print()

use_papirus = False

if package_installed("papirus-icon-theme"):

    print("Papirus icon theme is already installed.")
    print()

    use_papirus = ask_yes_no(
        "Use Papirus-Dark?"
    )

else:

    print(
        "papirus-icon-theme is not installed."
    )

    print()

    install = ask_yes_no(
        "Install papirus-icon-theme?"
    )

    if install:

        pacman_install(
            "papirus-icon-theme"
        )

        if package_installed(
            "papirus-icon-theme"
        ):

            print(
                "[OK] Papirus-Dark installed."
            )

            use_papirus = True

        else:

            print(
                "[WARNING] Papirus installation failed."
            )

    else:

        print(
            "Papirus installation skipped."
        )


# ======================================================================
# GNOME DARK MODE
# ======================================================================

print()
print("=" * 78)
print("[2/8] GNOME COLOR SCHEME")
print("=" * 78)
print()

run(
    [
        "gsettings",
        "set",
        "org.gnome.desktop.interface",
        "color-scheme",
        "prefer-dark",
    ]
)

print(
    "[OK] GNOME dark color scheme selected."
)

if use_papirus:

    run(
        [
            "gsettings",
            "set",
            "org.gnome.desktop.interface",
            "icon-theme",
            "Papirus-Dark",
        ]
    )

    print(
        "[OK] Papirus-Dark selected."
    )

else:

    print(
        "[OK] Existing icon theme preserved."
    )


# ======================================================================
# EXTENSION STATE
# ======================================================================

print()
print("=" * 78)
print("[3/8] EXTENSION STATE")
print("=" * 78)
print()

was_enabled = extension_enabled()

if was_enabled:

    print(
        "[INFO] Existing theme extension is enabled."
    )

    print(
        "[INFO] Disabling before replacement..."
    )

    disable_extension()

else:

    print(
        "[INFO] Theme extension is not enabled."
    )


# ======================================================================
# BACKUP
# ======================================================================

print()
print("=" * 78)
print("[4/8] BACKUP / INSTALL DIRECTORY")
print("=" * 78)
print()

EXTENSION_DIR.parent.mkdir(
    parents=True,
    exist_ok=True,
)

if EXTENSION_DIR.exists():

    timestamp = datetime.now().strftime(
        "%Y%m%d-%H%M%S"
    )

    backup_dir = EXTENSION_DIR.with_name(
        f"{UUID}.backup-{timestamp}"
    )

    print(
        "Existing installation detected."
    )

    print(
        "Backup:"
    )

    print(
        f"  {backup_dir}"
    )

    shutil.copytree(
        EXTENSION_DIR,
        backup_dir,
    )

    shutil.rmtree(
        EXTENSION_DIR
    )

EXTENSION_DIR.mkdir(
    parents=True,
    exist_ok=True,
)


# ======================================================================
# 5. METADATA
# ======================================================================

print()
print("=" * 78)
print("[5/8] GENERATING MODULAR THEME")
print("=" * 78)
print()

metadata = {
    "uuid": UUID,
    "name": EXTENSION_NAME,
    "description": (
        "Catppuccin Mocha color theme for "
        "GNOME Shell 50 and 51"
    ),
    "version": 10,
    "shell-version": [
        "50",
        "51",
    ],
}

write_file(
    EXTENSION_DIR / "metadata.json",
    json.dumps(
        metadata,
        indent=2,
    ),
)


# ======================================================================
# EXTENSION.JS
# ======================================================================

extension_js = r"""
import Gio from "gi://Gio";
import St from "gi://St";

import {
    Extension,
} from "resource:///org/gnome/shell/extensions/extension.js";


export default class CatppuccinMochaShellColors
    extends Extension {

    enable() {

        this._theme =
            St.ThemeContext
                .get_for_stage(global.stage)
                .get_theme();

        this._stylesheet =
            Gio.File.new_for_path(
                this.path + "/stylesheet.css"
            );

        try {

            this._theme.load_stylesheet(
                this._stylesheet
            );

            log(
                "Catppuccin Mocha Shell Colors: "
                + "theme loaded"
            );

        } catch (error) {

            logError(
                error,
                "Catppuccin Mocha Shell Colors: "
                + "failed to load theme"
            );

        }
    }


    disable() {

        if (
            this._theme &&
            this._stylesheet
        ) {

            try {

                this._theme.unload_stylesheet(
                    this._stylesheet
                );

            } catch (error) {

                logError(
                    error,
                    "Catppuccin Mocha Shell Colors: "
                    + "failed to unload theme"
                );

            }
        }

        this._theme = null;
        this._stylesheet = null;
    }
}
"""

write_file(
    EXTENSION_DIR / "extension.js",
    extension_js,
)


# ======================================================================
# COLORS.CSS
# ======================================================================

colors_css = f"""
/*
 * ================================================================
 * CATPPUCCIN MOCHA
 * COLOR TOKENS
 * ================================================================
 */

:root {{
    --ctp-rosewater: {COLORS["rosewater"]};
    --ctp-flamingo:  {COLORS["flamingo"]};
    --ctp-pink:      {COLORS["pink"]};
    --ctp-mauve:     {COLORS["mauve"]};
    --ctp-red:       {COLORS["red"]};
    --ctp-maroon:    {COLORS["maroon"]};
    --ctp-peach:     {COLORS["peach"]};
    --ctp-yellow:    {COLORS["yellow"]};
    --ctp-green:     {COLORS["green"]};
    --ctp-teal:      {COLORS["teal"]};
    --ctp-sky:       {COLORS["sky"]};
    --ctp-sapphire:  {COLORS["sapphire"]};
    --ctp-blue:      {COLORS["blue"]};
    --ctp-lavender:  {COLORS["lavender"]};

    --ctp-text:      {COLORS["text"]};
    --ctp-subtext1:  {COLORS["subtext1"]};
    --ctp-subtext0:  {COLORS["subtext0"]};

    --ctp-overlay2:  {COLORS["overlay2"]};
    --ctp-overlay1:  {COLORS["overlay1"]};
    --ctp-overlay0:  {COLORS["overlay0"]};

    --ctp-surface2:  {COLORS["surface2"]};
    --ctp-surface1:  {COLORS["surface1"]};
    --ctp-surface0:  {COLORS["surface0"]};

    --ctp-base:      {COLORS["base"]};
    --ctp-mantle:    {COLORS["mantle"]};
    --ctp-crust:     {COLORS["crust"]};
}}
"""

write_file(
    EXTENSION_DIR / "colors.css",
    colors_css,
)


# ======================================================================
# MASTER STYLESHEET
# ======================================================================

stylesheet_css = """
/*
 * CATPPUCCIN MOCHA
 * GNOME SHELL 50 / 51
 *
 * Modular entry point.
 */

@import url("colors.css");
@import url("app.css");
@import url("panel.css");
@import url("popup-menu.css");
@import url("quick-settings.css");
@import url("calendar.css");
@import url("notifications.css");
@import url("overview.css");
@import url("dash.css");
@import url("dialogs.css");
@import url("search.css");
@import url("widgets.css");
@import url("osd.css");
"""

write_file(
    EXTENSION_DIR / "stylesheet.css",
    stylesheet_css,
)


# ======================================================================
# APP.CSS
# ======================================================================

app_css = f"""
/*
 * ================================================================
 * APP / GLOBAL SHELL
 * ================================================================
 */

stage {{
    color: {COLORS["text"]};
    background-color: {COLORS["crust"]};
}}

#overview {{
    color: {COLORS["text"]};
    background-color: {COLORS["crust"]};
}}

#overviewGroup {{
    color: {COLORS["text"]};
    background-color: {COLORS["crust"]};
}}

StWidget {{
    color: {COLORS["text"]};
}}

.button,
.flat,
.icon-button {{
    color: {COLORS["text"]};
    background-color: {COLORS["surface0"]};
    border-color: {COLORS["surface1"]};
}}

.button:hover,
.flat:hover,
.icon-button:hover {{
    color: {COLORS["text"]};
    background-color: {COLORS["surface1"]};
}}

.button:active,
.button:checked,
.flat:active,
.flat:checked,
.icon-button:checked {{
    color: {COLORS["base"]};
    background-color: {COLORS["mauve"]};
}}

.button:focus,
.flat:focus,
.icon-button:focus {{
    border-color: {COLORS["lavender"]};
}}

.button:insensitive,
.flat:insensitive,
.icon-button:insensitive {{
    color: {COLORS["overlay0"]};
}}

.link {{
    color: {COLORS["blue"]};
}}

.link:hover {{
    color: {COLORS["lavender"]};
}}

.success {{
    color: {COLORS["green"]};
}}

.warning {{
    color: {COLORS["yellow"]};
}}

.error,
.critical {{
    color: {COLORS["red"]};
}}

.info {{
    color: {COLORS["sky"]};
}}

.destructive-action {{
    color: {COLORS["red"]};
}}

.destructive-action:hover {{
    color: {COLORS["base"]};
    background-color: {COLORS["red"]};
}}

StEntry {{
    color: {COLORS["text"]};
    background-color: {COLORS["surface0"]};
    border-color: {COLORS["surface1"]};
    caret-color: {COLORS["mauve"]};
    selection-background-color: {COLORS["mauve"]};
}}

StEntry:focus {{
    color: {COLORS["text"]};
    background-color: {COLORS["surface1"]};
    border-color: {COLORS["lavender"]};
}}

StScrollBar {{
    -slider-background-color: {COLORS["surface1"]};
    -slider-hover-background-color: {COLORS["surface2"]};
    -slider-active-background-color: {COLORS["mauve"]};
}}
"""

write_file(
    EXTENSION_DIR / "app.css",
    app_css,
)


# ======================================================================
# PANEL.CSS
# ======================================================================

panel_css = f"""
/*
 * ================================================================
 * PANEL
 * ================================================================
 */

#panel {{
    color: {COLORS["text"]};
    background-color: {COLORS["mantle"]};
    border-color: {COLORS["surface0"]};
}}

#panel .panel-button {{
    color: {COLORS["text"]};
    background-color: transparent;
    border-color: transparent;
}}

#panel .panel-button:hover,
#panel .panel-button:focus {{
    color: {COLORS["text"]};
    background-color: {COLORS["surface0"]};
    border-color: {COLORS["surface1"]};
}}

#panel .panel-button:active,
#panel .panel-button:checked {{
    color: {COLORS["base"]};
    background-color: {COLORS["mauve"]};
    border-color: {COLORS["mauve"]};
}}

#panel .panel-status-button {{
    color: {COLORS["text"]};
}}

#panel .clock-display {{
    color: {COLORS["text"]};
}}

#panel .panel-button .system-status-icon {{
    color: {COLORS["text"]};
}}

#panel .panel-button:hover .system-status-icon,
#panel .panel-button:focus .system-status-icon {{
    color: {COLORS["lavender"]};
}}

#panel:backdrop {{
    color: {COLORS["subtext1"]};
    background-color: {COLORS["mantle"]};
}}
"""

write_file(
    EXTENSION_DIR / "panel.css",
    panel_css,
)


# ======================================================================
# POPUP-MENU.CSS
# ======================================================================

popup_menu_css = f"""
/*
 * ================================================================
 * POPUP MENUS
 * ================================================================
 */

.popup-menu,
.popup-menu-boxpointer,
.popup-menu-content,
.popup-sub-menu {{
    color: {COLORS["text"]};
    background-color: {COLORS["base"]};
    border-color: {COLORS["surface0"]};
}}

.popup-menu-item {{
    color: {COLORS["subtext1"]};
    background-color: {COLORS["base"]};
}}

.popup-menu-item:hover,
.popup-menu-item:focus {{
    color: {COLORS["text"]};
    background-color: {COLORS["surface0"]};
}}

.popup-menu-item:active,
.popup-menu-item:checked {{
    color: {COLORS["base"]};
    background-color: {COLORS["mauve"]};
}}

.popup-menu-item:insensitive {{
    color: {COLORS["overlay0"]};
}}

.popup-menu-arrow {{
    color: {COLORS["subtext0"]};
}}

.popup-inactive-menu-item {{
    color: {COLORS["overlay1"]};
}}

.popup-sub-menu .popup-menu-item {{
    color: {COLORS["subtext1"]};
}}

.popup-sub-menu .popup-menu-item:hover {{
    color: {COLORS["text"]};
    background-color: {COLORS["surface0"]};
}}

.app-menu,
.app-menu .popup-menu-content {{
    color: {COLORS["text"]};
    background-color: {COLORS["base"]};
    border-color: {COLORS["surface0"]};
}}

.app-menu .popup-menu-item {{
    color: {COLORS["subtext1"]};
    background-color: {COLORS["base"]};
}}

.app-menu .popup-menu-item:hover,
.app-menu .popup-menu-item:focus {{
    color: {COLORS["text"]};
    background-color: {COLORS["surface0"]};
}}

.app-menu .popup-menu-item:active {{
    color: {COLORS["base"]};
    background-color: {COLORS["mauve"]};
}}
"""

write_file(
    EXTENSION_DIR / "popup-menu.css",
    popup_menu_css,
)


# ======================================================================
# QUICK-SETTINGS.CSS
# ======================================================================

quick_settings_css = f"""
/*
 * ================================================================
 * QUICK SETTINGS
 * ================================================================
 */

.quick-settings,
.quick-settings-box,
.quick-settings-grid,
.quick-settings-system-item {{
    color: {COLORS["text"]};
    background-color: {COLORS["base"]};
    border-color: {COLORS["surface0"]};
}}

.quick-toggle,
.quick-menu-toggle {{
    color: {COLORS["text"]};
    background-color: {COLORS["surface0"]};
    border-color: {COLORS["surface1"]};
}}

.quick-toggle:hover,
.quick-menu-toggle:hover {{
    color: {COLORS["text"]};
    background-color: {COLORS["surface1"]};
}}

.quick-toggle:checked,
.quick-menu-toggle:checked {{
    color: {COLORS["base"]};
    background-color: {COLORS["mauve"]};
    border-color: {COLORS["mauve"]};
}}

.quick-toggle:checked:hover,
.quick-menu-toggle:checked:hover {{
    color: {COLORS["base"]};
    background-color: {COLORS["lavender"]};
}}

.quick-toggle:insensitive,
.quick-menu-toggle:insensitive {{
    color: {COLORS["overlay0"]};
    background-color: {COLORS["surface0"]};
}}

.quick-toggle-menu {{
    color: {COLORS["text"]};
    background-color: {COLORS["base"]};
    border-color: {COLORS["surface0"]};
}}

.quick-toggle-menu .header {{
    color: {COLORS["text"]};
}}

.quick-toggle-menu .header .icon {{
    color: {COLORS["text"]};
}}

.quick-toggle-menu .header .icon.active {{
    color: {COLORS["base"]};
    background-color: {COLORS["mauve"]};
}}

.quick-menu-toggle .quick-toggle-arrow {{
    color: {COLORS["text"]};
    background-color: {COLORS["surface1"]};
}}

.slider {{
    color: {COLORS["text"]};
    -barlevel-background-color: {COLORS["surface1"]};
    -barlevel-active-background-color: {COLORS["mauve"]};
    -barlevel-overdrive-color: {COLORS["red"]};
}}

.slider:hover {{
    -barlevel-active-background-color: {COLORS["lavender"]};
}}

.quick-slider .slider-bin {{
    color: {COLORS["text"]};
    -barlevel-background-color: {COLORS["surface1"]};
    -barlevel-active-background-color: {COLORS["mauve"]};
    -barlevel-overdrive-color: {COLORS["red"]};
}}

.quick-slider .slider-bin:hover {{
    -barlevel-active-background-color: {COLORS["lavender"]};
}}

.toggle-switch {{
    background-color: {COLORS["surface1"]};
}}

.toggle-switch:checked {{
    background-color: {COLORS["mauve"]};
}}

.toggle-switch-slider {{
    background-color: {COLORS["text"]};
}}

.toggle-switch:checked .toggle-switch-slider {{
    background-color: {COLORS["base"]};
}}
"""

write_file(
    EXTENSION_DIR / "quick-settings.css",
    quick_settings_css,
)


# ======================================================================
# CALENDAR.CSS
# ======================================================================

calendar_css = f"""
/*
 * ================================================================
 * CALENDAR / DATE MENU
 * ================================================================
 */

.calendar {{
    color: {COLORS["text"]};
    background-color: {COLORS["base"]};
    border-color: {COLORS["surface0"]};
}}

.calendar-month-label,
.calendar-year-label {{
    color: {COLORS["text"]};
}}

.calendar-day,
.calendar-day-base {{
    color: {COLORS["subtext1"]};
    background-color: {COLORS["base"]};
}}

.calendar-day:hover,
.calendar-day-base:hover,
.calendar-day-base:focus {{
    color: {COLORS["text"]};
    background-color: {COLORS["surface0"]};
}}

.calendar-day:selected,
.calendar-day-base:active {{
    color: {COLORS["base"]};
    background-color: {COLORS["mauve"]};
}}

.calendar-today,
.calendar-day-base.calendar-today {{
    color: {COLORS["mauve"]};
}}

.datemenu-today-button,
.world-clocks-button,
.weather-button {{
    color: {COLORS["text"]};
}}

.datemenu-today-button:hover,
.world-clocks-button:hover,
.weather-button:hover {{
    color: {COLORS["text"]};
    background-color: {COLORS["surface0"]};
}}

.events-button {{
    color: {COLORS["subtext1"]};
}}

.events-button:hover {{
    color: {COLORS["text"]};
    background-color: {COLORS["surface0"]};
}}

.world-clocks-header,
.weather-header {{
    color: {COLORS["text"]};
}}

.world-clocks-button {{
    border-color: {COLORS["surface0"]};
}}
"""

write_file(
    EXTENSION_DIR / "calendar.css",
    calendar_css,
)


# ======================================================================
# NOTIFICATIONS.CSS
# ======================================================================

notifications_css = f"""
/*
 * ================================================================
 * NOTIFICATIONS
 * ================================================================
 */

.notification-banner {{
    color: {COLORS["text"]};
    background-color: {COLORS["base"]};
    border-color: {COLORS["surface0"]};
}}

.notification-banner:hover {{
    background-color: {COLORS["surface0"]};
}}

.notification-button {{
    color: {COLORS["text"]};
    background-color: {COLORS["surface0"]};
    border-color: {COLORS["surface1"]};
}}

.notification-button:hover {{
    color: {COLORS["text"]};
    background-color: {COLORS["surface1"]};
}}

.notification-button:active {{
    color: {COLORS["base"]};
    background-color: {COLORS["mauve"]};
}}

.message-list {{
    color: {COLORS["text"]};
    background-color: {COLORS["base"]};
}}

.message {{
    color: {COLORS["text"]};
    background-color: {COLORS["base"]};
    border-color: {COLORS["surface0"]};
}}

.message:hover {{
    background-color: {COLORS["surface0"]};
}}

.message-list-placeholder {{
    color: {COLORS["overlay1"]};
}}

.summary-source-counter {{
    color: {COLORS["base"]};
    background-color: {COLORS["mauve"]};
}}

.secondary-icon {{
    color: {COLORS["subtext0"]};
}}
"""

write_file(
    EXTENSION_DIR / "notifications.css",
    notifications_css,
)


# ======================================================================
# OVERVIEW.CSS
# ======================================================================

overview_css = f"""
/*
 * ================================================================
 * OVERVIEW
 * ================================================================
 */

.overview-controls {{
    color: {COLORS["text"]};
}}

.workspace-thumbnails {{
    color: {COLORS["text"]};
}}

.workspace-thumbnail {{
    background-color: {COLORS["mantle"]};
    border-color: {COLORS["surface0"]};
}}

.workspace-thumbnail:selected {{
    border-color: {COLORS["mauve"]};
}}

.workspace-thumbnail:hover {{
    border-color: {COLORS["lavender"]};
}}

.ws-switcher-indicator {{
    background-color: {COLORS["mauve"]};
}}

.switcher-list {{
    color: {COLORS["text"]};
    background-color: {COLORS["base"]};
    border-color: {COLORS["surface0"]};
}}

.switcher-list .item-box {{
    color: {COLORS["text"]};
    background-color: {COLORS["base"]};
}}

.switcher-list .item-box:hover,
.switcher-list .item-box:focus {{
    color: {COLORS["text"]};
    background-color: {COLORS["surface0"]};
}}

.switcher-list .item-box:selected {{
    color: {COLORS["text"]};
    background-color: {COLORS["surface0"]};
    border-color: {COLORS["mauve"]};
}}

.app-well-app {{
    color: {COLORS["text"]};
}}

.app-well-app:hover,
.app-well-app:focus {{
    color: {COLORS["text"]};
    background-color: {COLORS["surface0"]};
}}

.app-well-app:active {{
    color: {COLORS["base"]};
    background-color: {COLORS["mauve"]};
}}

.app-well-app .overview-icon-label {{
    color: {COLORS["text"]};
}}

.grid-search-result {{
    color: {COLORS["text"]};
}}

.grid-search-result:hover,
.grid-search-result:focus {{
    color: {COLORS["text"]};
    background-color: {COLORS["surface0"]};
}}

.list-search-result {{
    color: {COLORS["text"]};
}}

.list-search-result:hover,
.list-search-result:focus {{
    color: {COLORS["text"]};
    background-color: {COLORS["surface0"]};
}}
"""

write_file(
    EXTENSION_DIR / "overview.css",
    overview_css,
)


# ======================================================================
# DASH.CSS
# ======================================================================

dash_css = f"""
/*
 * ================================================================
 * DASH
 * ================================================================
 */

.dash {{
    color: {COLORS["text"]};
    background-color: {COLORS["mantle"]};
}}

.dash-item-container:hover,
.dash-item-container:focus {{
    background-color: {COLORS["surface0"]};
}}

.app-well-app-running-dot {{
    background-color: {COLORS["mauve"]};
}}

.show-apps-icon {{
    color: {COLORS["text"]};
}}

.show-apps-icon:hover {{
    color: {COLORS["lavender"]};
}}

.show-apps-icon:checked {{
    color: {COLORS["mauve"]};
}}
"""

write_file(
    EXTENSION_DIR / "dash.css",
    dash_css,
)


# ======================================================================
# DIALOGS.CSS
# ======================================================================

dialogs_css = f"""
/*
 * ================================================================
 * DIALOGS / LOCK / LOGIN
 * ================================================================
 */

.modal-dialog,
.dialog-list,
.end-session-dialog {{
    color: {COLORS["text"]};
    background-color: {COLORS["base"]};
    border-color: {COLORS["surface0"]};
}}

.modal-dialog-button,
.modal-dialog-linked-button {{
    color: {COLORS["text"]};
    background-color: {COLORS["surface0"]};
    border-color: {COLORS["surface1"]};
}}

.modal-dialog-button:hover,
.modal-dialog-linked-button:hover {{
    color: {COLORS["text"]};
    background-color: {COLORS["surface1"]};
}}

.modal-dialog-button:active,
.modal-dialog-linked-button:active {{
    color: {COLORS["base"]};
    background-color: {COLORS["mauve"]};
}}

.modal-dialog-button:default,
.modal-dialog-linked-button:default {{
    color: {COLORS["base"]};
    background-color: {COLORS["mauve"]};
    border-color: {COLORS["mauve"]};
}}

.login-dialog,
.unlock-dialog {{
    color: {COLORS["text"]};
    background-color: {COLORS["crust"]};
}}

#lockDialogGroup,
#unlockDialogGroup {{
    color: {COLORS["text"]};
    background-color: {COLORS["crust"]};
}}

.login-dialog-button,
.login-dialog-session-list-button,
.unlock-dialog-button {{
    color: {COLORS["text"]};
    background-color: {COLORS["surface0"]};
    border-color: {COLORS["surface1"]};
}}

.login-dialog-button:hover,
.login-dialog-session-list-button:hover,
.unlock-dialog-button:hover {{
    color: {COLORS["text"]};
    background-color: {COLORS["surface1"]};
}}

.login-dialog-button:default {{
    color: {COLORS["base"]};
    background-color: {COLORS["mauve"]};
}}
"""

write_file(
    EXTENSION_DIR / "dialogs.css",
    dialogs_css,
)


# ======================================================================
# SEARCH.CSS
# ======================================================================

search_css = f"""
/*
 * ================================================================
 * SEARCH
 * ================================================================
 */

.search-entry,
#searchEntry {{
    color: {COLORS["text"]};
    background-color: {COLORS["surface0"]};
    border-color: {COLORS["surface1"]};
    caret-color: {COLORS["mauve"]};
    selection-background-color: {COLORS["mauve"]};
}}

.search-entry:focus,
#searchEntry:focus {{
    color: {COLORS["text"]};
    background-color: {COLORS["surface1"]};
    border-color: {COLORS["mauve"]};
}}

.search-statustext {{
    color: {COLORS["subtext0"]};
}}

.search-section-content {{
    color: {COLORS["text"]};
    background-color: {COLORS["base"]};
}}

.search-provider-icon {{
    color: {COLORS["text"]};
}}

.search-provider-icon:hover {{
    color: {COLORS["lavender"]};
}}

.system-action-icon {{
    color: {COLORS["text"]};
    background-color: {COLORS["surface0"]};
}}

.system-action-icon:hover {{
    color: {COLORS["base"]};
    background-color: {COLORS["mauve"]};
}}
"""

write_file(
    EXTENSION_DIR / "search.css",
    search_css,
)


# ======================================================================
# WIDGETS.CSS
# ======================================================================

widgets_css = f"""
/*
 * ================================================================
 * GENERIC SHELL WIDGETS
 * ================================================================
 */

.tooltip {{
    color: {COLORS["text"]};
    background-color: {COLORS["mantle"]};
    border-color: {COLORS["surface0"]};
}}

.osd-window {{
    color: {COLORS["text"]};
    background-color: {COLORS["base"]};
    border-color: {COLORS["surface0"]};
}}

.workspace-switcher-container,
.workspace-switcher {{
    color: {COLORS["text"]};
    background-color: {COLORS["base"]};
    border-color: {COLORS["surface0"]};
}}

.workspace-switcher-container:hover,
.workspace-switcher:hover {{
    border-color: {COLORS["surface1"]};
}}

.audio-device-item {{
    color: {COLORS["text"]};
}}

.audio-device-item:hover {{
    color: {COLORS["text"]};
    background-color: {COLORS["surface0"]};
}}

.audio-device-item.selected {{
    color: {COLORS["base"]};
    background-color: {COLORS["mauve"]};
}}

.system-menu-action {{
    color: {COLORS["text"]};
    background-color: {COLORS["surface0"]};
}}

.system-menu-action:hover {{
    color: {COLORS["base"]};
    background-color: {COLORS["mauve"]};
}}

.indicator-button {{
    color: {COLORS["text"]};
}}

.indicator-button:hover {{
    color: {COLORS["lavender"]};
}}
"""

write_file(
    EXTENSION_DIR / "widgets.css",
    widgets_css,
)


# ======================================================================
# OSD.CSS
# ======================================================================

osd_css = f"""
/*
 * ================================================================
 * OSD
 * ================================================================
 */

.osd-window {{
    color: {COLORS["text"]};
    background-color: {COLORS["base"]};
    border-color: {COLORS["surface0"]};
}}

.osd-window .level {{
    -barlevel-background-color: {COLORS["surface1"]};
    -barlevel-active-background-color: {COLORS["mauve"]};
    -barlevel-overdrive-color: {COLORS["red"]};
}}

.osd-window .level:hover {{
    -barlevel-active-background-color: {COLORS["lavender"]};
}}
"""

write_file(
    EXTENSION_DIR / "osd.css",
    osd_css,
)


# ======================================================================
# 6. OPTIONAL GNOME EXTENSIONS
# ======================================================================

print()
print("=" * 78)
print("[6/8] OPTIONAL GNOME EXTENSIONS")
print("=" * 78)
print()

optional_extensions = [
    "appindicator@ubuntu.com",
    "caffeine@patapon.info",
    "dash-to-panel@jderose9.github.com",
]

for uuid in optional_extensions:

    result = run(
        [
            "gnome-extensions",
            "enable",
            uuid,
        ],
        check=False,
    )

    if result.returncode == 0:

        print(
            f"[OK] {uuid}"
        )

    else:

        print(
            f"[INFO] {uuid} not installed/enabled"
        )


print()
print(
    "[IMPORTANT] No Dash-to-Panel settings were modified."
)


# ======================================================================
# 7. USER SETTINGS
# ======================================================================

print()
print("=" * 78)
print("[7/8] USER SETTINGS")
print("=" * 78)
print()

print(
    "GNOME shortcuts: untouched"
)

print(
    "GNOME workspace settings: untouched"
)

print(
    "GTK settings: untouched"
)

print(
    "Font settings: untouched"
)


# ======================================================================
# 8. VERIFY
# ======================================================================

print()
print("=" * 78)
print("[8/8] VERIFICATION")
print("=" * 78)
print()

required_files = [
    "metadata.json",
    "extension.js",
    "stylesheet.css",
    "colors.css",
    "app.css",
    "panel.css",
    "popup-menu.css",
    "quick-settings.css",
    "calendar.css",
    "notifications.css",
    "overview.css",
    "dash.css",
    "dialogs.css",
    "search.css",
    "widgets.css",
    "osd.css",
]

verification_ok = True

for filename in required_files:

    path = EXTENSION_DIR / filename

    if (
        path.is_file()
        and path.stat().st_size > 0
    ):

        print(
            f"[OK] {filename:<24}"
            f"{path.stat().st_size:>7} bytes"
        )

    else:

        print(
            f"[ERROR] {filename}"
        )

        verification_ok = False


# ======================================================================
# ENABLE
# ======================================================================

print()
print("=" * 78)
print("ACTIVATING THEME")
print("=" * 78)
print()

if verification_ok:

    if enable_extension():

        print()
        print(
            "[OK] Catppuccin Mocha Shell Colors enabled."
        )

    else:

        print()
        print(
            "[ERROR] Could not enable the extension."
        )

        print()
        print(
            "Run:"
        )

        print(
            f"  gnome-extensions info {UUID}"
        )

else:

    print(
        "[ERROR] Installation files are incomplete."
    )

    print(
        "The extension was not enabled."
    )


# ======================================================================
# INFO
# ======================================================================

print()
print("=" * 78)
print("EXTENSION INFORMATION")
print("=" * 78)
print()

run(
    [
        "gnome-extensions",
        "info",
        UUID,
    ],
    check=False,
)


# ======================================================================
# FINAL
# ======================================================================

print()
print("=" * 78)
print("CATPPUCCIN MOCHA INSTALLED")
print("=" * 78)
print()

print(
    "Theme:"
)

print(
    "  Catppuccin Mocha"
)

print()

print(
    "GNOME Shell:"
)

print(
    "  50 / 51"
)

print()

print(
    "CSS architecture:"
)

print(
    "  Modular"
)

print(
    "  colors.css"
)

print(
    "  app.css"
)

print(
    "  panel.css"
)

print(
    "  popup-menu.css"
)

print(
    "  quick-settings.css"
)

print(
    "  calendar.css"
)

print(
    "  notifications.css"
)

print(
    "  overview.css"
)

print(
    "  dash.css"
)

print(
    "  dialogs.css"
)

print(
    "  search.css"
)

print(
    "  widgets.css"
)

print(
    "  osd.css"
)

print()

print(
    "GTK 3:              UNTOUCHED"
)

print(
    "GTK 4 / Libadwaita:  UNTOUCHED"
)

print(
    "Applications:        UNTOUCHED"
)

print(
    "Fonts:               UNTOUCHED"
)

print(
    "Geometry:            UNTOUCHED"
)

print(
    "Animations:          UNTOUCHED"
)

print(
    "Shortcuts:           UNTOUCHED"
)

print()

if use_papirus:

    print(
        "Icons:              Papirus-Dark"
    )

else:

    print(
        "Icons:              Existing icon theme"
    )

print()

print(
    "Package manager:"
)

print(
    "  pacman"
)

print()

print(
    "No yay"
)

print(
    "No paru"
)

print(
    "No AUR"
)

print()

print(
    f"Installation directory:"
)

print(
    f"  {EXTENSION_DIR}"
)

print()

print("=" * 78)
