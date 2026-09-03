function glasstoggle

    set file ~/.config/hypr/hyprland/rules.lua
    set general ~/.config/hypr/hyprland/general.lua

    if grep -q 'ignore_opacity = true,' $general

        # GLASS AUS
        sed -i 's/ignore_opacity = true,/ignore_opacity = false,/' $general
        sed -i '/-- GLASS_MODE_START/,/-- GLASS_MODE_END/d' $file

        notify-send "Glass Toggle" OFF

    else

        # GLASS AN
        sed -i 's/ignore_opacity = false,/ignore_opacity = true,/' $general

        printf '%s\n' '-- GLASS_MODE_START
-- Alle Apps: 90% Transparenz
hl.window_rule({
	match = {
		class = ".*",
	},
	opacity = 0.9,
})

-- Keine Transparenz für diese Apps
hl.window_rule({
	match = {
		class = "^(code|Code|com.jetbrains.clion|brave-browser|Blender|kitty|Alacritty|ghostty|firefox|firefox-developer-edition|libreoffice|libreoffice-startcenter|org.wireshark.Wireshark|wireshark)$",
	},
	opacity = 1.0,
})
-- GLASS_MODE_END' >>$file

        notify-send "Glass Toggle" ON

    end

    hyprctl reload

end
