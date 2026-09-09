function glasstoggle --description "Toggle Hyprland glass mode and Illogical Impulse transparency"

    # ============================================================
    # CONFIGURATION
    # ============================================================

    set rules_file "$HOME/.config/hypr/hyprland/rules.lua"
    set general_file "$HOME/.config/hypr/hyprland/general.lua"
    set illogical_config "$HOME/.config/illogical-impulse/config.json"

    # Default values
    set mode normal
    set opacity 0.90


    # ============================================================
    # HELP
    # ============================================================

    if test (count $argv) -eq 0
        echo "Usage: glasstoggle [MODE] [OPACITY]"
        echo ""
        echo "Modes:"
        echo "  full [OPACITY]       Enable full glass mode"
        echo "  personal [OPACITY]   Enable personal glass mode"
        echo "  normal [OPACITY]     Enable normal glass mode"
        echo "  illogical [OPACITY]  Toggle Illogical Impulse transparency"
        echo "  off                  Disable glass mode and transparency"
        echo "  reset                Reset glass mode and transparency"
        echo "  default              Reset glass mode and transparency"
        echo ""
        echo "Examples:"
        echo "  glasstoggle normal 0.90"
        echo "  glasstoggle full 0.85"
        echo "  glasstoggle personal 0.80"
        echo "  glasstoggle illogical 0.75"
        echo "  glasstoggle off"

        return 1
    end


    # ============================================================
    # ARGUMENT PARSING
    # ============================================================

    switch $argv[1]

        case full personal normal illogical
            set mode $argv[1]

            if test (count $argv) -gt 1
                set opacity $argv[2]
            end

        case off reset default
            set mode off

        case '*'
            # Allow "glasstoggle 0.85" as shorthand for normal mode.
            set opacity $argv[1]

    end


    # ============================================================
    # NORMALIZE OPACITY
    # ============================================================

    set opacity (string replace ',' '.' -- "$opacity")


    # ============================================================
    # VALIDATE OPACITY
    # ============================================================

    if not string match -rq '^[0-9]+([.][0-9]+)?$' -- "$opacity"
        notify-send \
            "Glass Toggle" \
            "Invalid opacity: $opacity"

        return 1
    end

    # Keep opacity inside the valid 0.0 - 1.0 range.
    if test "$opacity" -lt 0
        set opacity 0
    else if test "$opacity" -gt 1
        set opacity 1
    end


    # ============================================================
    # CALCULATE BACKGROUND TRANSPARENCY
    # ============================================================
    #
    # Illogical Impulse uses a different scale than Hyprland.
    #
    # Formula:
    #
    #     backgroundTransparency = 1 - opacity^3.03
    #
    # contentTransparency is intentionally left untouched.
    #

    set background_transparency \
        (math --scale=6 "1 - ($opacity ^ 3.03)")

    set background_transparency \
        (string replace ',' '.' -- "$background_transparency")

    set background_transparency \
        (printf '%.2f' "$background_transparency")

    set background_transparency \
        (string replace ',' '.' -- "$background_transparency")


    # ============================================================
    # ILLOGICAL IMPULSE ONLY
    # ============================================================

    if test "$mode" = illogical

        if not test -f "$illogical_config"
            notify-send \
                "Glass Toggle" \
                "config.json not found."

            return 1
        end

        if not command -q jq
            notify-send \
                "Glass Toggle" \
                "jq is not installed."

            return 1
        end

        # Read the current transparency state.
        set transparency_enabled \
            (jq -r '.appearance.transparency.enable // false' "$illogical_config")

        # Toggle transparency.
        if test "$transparency_enabled" = true

            set tmp_file (mktemp)

            if jq \
                    '.appearance.transparency.enable = false' \
                    "$illogical_config" >"$tmp_file"

                mv "$tmp_file" "$illogical_config"

            else
                rm -f "$tmp_file"

                notify-send \
                    "Glass Toggle" \
                    "Failed to update config.json."

                return 1
            end

            notify-send \
                "Glass Toggle" \
                "Illogical transparency OFF"

            return 0
        end

        # Enable transparency while preserving contentTransparency.
        set tmp_file (mktemp)

        if jq \
                --arg bg "$background_transparency" \
                '
                .appearance.transparency.automatic = false |
                .appearance.transparency.backgroundTransparency = ($bg | tonumber) |
                .appearance.transparency.enable = true
                ' \
                "$illogical_config" >"$tmp_file"

            mv "$tmp_file" "$illogical_config"

        else
            rm -f "$tmp_file"

            notify-send \
                "Glass Toggle" \
                "Failed to update config.json."

            return 1
        end

        notify-send \
            "Glass Toggle" \
            "Illogical transparency ON ($opacity)"

        return 0
    end


    # ============================================================
    # REQUIRED FILES
    # ============================================================

    if not test -f "$rules_file"
        notify-send \
            "Glass Toggle" \
            "rules.lua not found."

        return 1
    end

    if not test -f "$general_file"
        notify-send \
            "Glass Toggle" \
            "general.lua not found."

        return 1
    end

    if not test -f "$illogical_config"
        notify-send \
            "Glass Toggle" \
            "config.json not found."

        return 1
    end


    # ============================================================
    # DISABLE / RESET
    # ============================================================

    if test "$mode" = off

        # Restore normal Hyprland opacity handling.
        sed -i \
            's/ignore_opacity = true,/ignore_opacity = false,/' \
            "$general_file"

        # Remove all generated glass rules.
        sed -i \
            '/-- GLASS_MODE_START/,/-- GLASS_MODE_END/d' \
            "$rules_file"

        # Disable Illogical Impulse transparency.
        # contentTransparency remains untouched.
        if command -q jq

            set tmp_file (mktemp)

            if jq \
                    '.appearance.transparency.enable = false' \
                    "$illogical_config" >"$tmp_file"

                mv "$tmp_file" "$illogical_config"

            else
                rm -f "$tmp_file"
            end
        end

        hyprctl reload

        notify-send \
            "Glass Toggle" \
            "Glass mode OFF / Default"

        return 0
    end


    # ============================================================
    # CHECK CURRENT GLASS STATE
    # ============================================================

    if grep -q 'ignore_opacity = true,' "$general_file"

        # --------------------------------------------------------
        # GLASS IS ON -> TURN IT OFF
        # --------------------------------------------------------

        sed -i \
            's/ignore_opacity = true,/ignore_opacity = false,/' \
            "$general_file"

        sed -i \
            '/-- GLASS_MODE_START/,/-- GLASS_MODE_END/d' \
            "$rules_file"

        # Disable Illogical Impulse transparency.
        # contentTransparency remains untouched.
        if command -q jq

            set tmp_file (mktemp)

            if jq \
                    '.appearance.transparency.enable = false' \
                    "$illogical_config" >"$tmp_file"

                mv "$tmp_file" "$illogical_config"

            else
                rm -f "$tmp_file"
            end
        end

        hyprctl reload

        notify-send \
            "Glass Toggle" \
            "Glass mode OFF"

        return 0
    end


    # ============================================================
    # ENABLE GLASS MODE
    # ============================================================

    sed -i \
        's/ignore_opacity = false,/ignore_opacity = true,/' \
        "$general_file"

    # Always remove previously generated rules before creating new ones.
    sed -i \
        '/-- GLASS_MODE_START/,/-- GLASS_MODE_END/d' \
        "$rules_file"


    # ============================================================
    # FULL GLASS
    # ============================================================

    if test "$mode" = full

        printf '%s\n' \
            '-- GLASS_MODE_START' \
            '-- FULL GLASS MODE' \
            '' \
            'hl.window_rule({' \
            '    match = {' \
            '        class = ".*",' \
            '    },' \
            "    opacity = $opacity," \
            '})' \
            '' \
            '-- Applications excluded from glass' \
            'hl.window_rule({' \
            '    match = {' \
            '        class = "^(kitty|Alacritty|ghostty)$",' \
            '    },' \
            '    opacity = 1.0,' \
            '})' \
            '' \
            '-- GLASS_MODE_END' \
            >> "$rules_file"

        set notification "FULL GLASS ON ($opacity)"


    # ============================================================
    # PERSONAL GLASS
    # ============================================================

    else if test "$mode" = personal

        printf '%s\n' \
            '-- GLASS_MODE_START' \
            '-- PERSONAL GLASS MODE' \
            '' \
            'hl.window_rule({' \
            '    match = {' \
            '        class = ".*",' \
            '    },' \
            "    opacity = $opacity," \
            '})' \
            '' \
            '-- Personal applications excluded from glass' \
            'hl.window_rule({' \
            '    match = {' \
            '        class = "^(brave-browser|Blender|resolve|com.blackmagicdesign.resolve|kitty|Alacritty|ghostty|firefox|firefox-developer-edition|libreoffice|libreoffice-startcenter|org.wireshark.Wireshark|wireshark|org.kde.gwenview|org.kde.okular)$",' \
            '    },' \
            '    opacity = 1.0,' \
            '})' \
            '' \
            '-- GLASS_MODE_END' \
            >> "$rules_file"

        set notification "PERSONAL GLASS ON ($opacity)"


    # ============================================================
    # NORMAL GLASS
    # ============================================================

    else

        printf '%s\n' \
            '-- GLASS_MODE_START' \
            '-- NORMAL GLASS MODE' \
            '' \
            'hl.window_rule({' \
            '    match = {' \
            '        class = ".*",' \
            '    },' \
            "    opacity = $opacity," \
            '})' \
            '' \
            '-- Applications excluded from glass' \
            'hl.window_rule({' \
            '    match = {' \
            '        class = "^(code|Code|com.jetbrains.*|jetbrains-.*|brave-browser|Blender|resolve|com.blackmagicdesign.resolve|kitty|Alacritty|ghostty|firefox|firefox-developer-edition|libreoffice|libreoffice-startcenter|org.wireshark.Wireshark|wireshark|org.kde.gwenview|org.kde.okular)$",' \
            '    },' \
            '    opacity = 1.0,' \
            '})' \
            '' \
            '-- GLASS_MODE_END' \
            >> "$rules_file"

        set notification "NORMAL GLASS ON ($opacity)"

    end


    # ============================================================
    # UPDATE ILLOGICAL IMPULSE
    # ============================================================
    #
    # Only these values are modified:
    #
    #   automatic
    #   backgroundTransparency
    #   enable
    #
    # contentTransparency is intentionally preserved.
    #

    if command -q jq

        set tmp_file (mktemp)

        if jq \
                --arg bg "$background_transparency" \
                '
                .appearance.transparency.automatic = false |
                .appearance.transparency.backgroundTransparency = ($bg | tonumber) |
                .appearance.transparency.enable = true
                ' \
                "$illogical_config" >"$tmp_file"

            mv "$tmp_file" "$illogical_config"

        else
            rm -f "$tmp_file"

            notify-send \
                "Glass Toggle" \
                "Failed to update config.json."

            return 1
        end

    end


    # ============================================================
    # RELOAD HYPRLAND
    # ============================================================

    hyprctl reload


    # ============================================================
    # NOTIFICATION
    # ============================================================

    notify-send \
        "Glass Toggle" \
        "$notification"

end
