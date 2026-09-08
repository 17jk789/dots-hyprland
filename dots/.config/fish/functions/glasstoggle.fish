function glasstoggle --description "Ultimate Hyprland glass mode toggle"

    set file ~/.config/hypr/hyprland/rules.lua
    set general ~/.config/hypr/hyprland/general.lua

    # DEFAULT
    set opacity 0.90
    set mode normal

    # ARGUMENTE
    if test (count $argv) -gt 0

        switch $argv[1]

            case full

                set mode full

                if test (count $argv) -gt 1
                    set opacity $argv[2]
                end

            case off reset default

                set mode off

            case '*'

                set opacity $argv[1]

        end

    end

    # RESET / AUS
    if test "$mode" = off

        sed -i 's/ignore_opacity = true,/ignore_opacity = false,/' $general
        sed -i '/-- GLASS_MODE_START/,/-- GLASS_MODE_END/d' $file

        notify-send "Glass Toggle" "OFF / Default"

        hyprctl reload
        return

    end

    # TOGGLE CHECK
    if grep -q 'ignore_opacity = true,' $general

        # GLASS AUS

        sed -i 's/ignore_opacity = true,/ignore_opacity = false,/' $general
        sed -i '/-- GLASS_MODE_START/,/-- GLASS_MODE_END/d' $file

        notify-send "Glass Toggle" OFF

    else

        # GLASS AN

        sed -i 's/ignore_opacity = false,/ignore_opacity = true,/' $general

        # alten Block entfernen

        sed -i '/-- GLASS_MODE_START/,/-- GLASS_MODE_END/d' $file

        if test "$mode" = full

            # FULL GLASS

            printf '%s\n' \
                '-- GLASS_MODE_START
-- FULL GLASS MODE

hl.window_rule({
    match = {
        class = ".*",
    },
    opacity = '$opacity',
})


-- AUSNAHMEN

hl.window_rule({
    match = {
        class = "^(kitty|Alacritty|ghostty)$",
    },
    opacity = 1.0,
})


-- GLASS_MODE_END' >>$file

            notify-send "Glass Toggle" "FULL ON ($opacity)"

        else

            # NORMAL GLASS

            printf '%s\n' \
                '-- GLASS_MODE_START
-- NORMAL GLASS MODE

hl.window_rule({
    match = {
        class = ".*",
    },
    opacity = '$opacity',
})


-- AUSNAHMEN

hl.window_rule({
    match = {
        class = "^(code|Code|com.jetbrains.*|jetbrains-.*|brave-browser|Blender|resolve|com.blackmagicdesign.resolve|kitty|Alacritty|ghostty|firefox|firefox-developer-edition|libreoffice|libreoffice-startcenter|org.wireshark.Wireshark|wireshark)$",
    },
    opacity = 1.0,
})


-- GLASS_MODE_END' >>$file

            notify-send "Glass Toggle" "ON ($opacity)"

        end

    end

    hyprctl reload

end
