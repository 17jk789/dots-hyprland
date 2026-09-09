function glasstoggle --description "Ultimate Hyprland glass mode toggle"

    set file "$HOME/.config/hypr/hyprland/rules.lua"
    set general "$HOME/.config/hypr/hyprland/general.lua"
    set json "$HOME/.config/illogical-impulse/config.json"

    # ============================================================
    # DEFAULT
    # ============================================================

    set mode normal
    set opacity 0.90

    # ============================================================
    # ARGUMENTE
    # ============================================================

    if test (count $argv) -gt 0

        switch $argv[1]

            case full

                set mode full

                if test (count $argv) -gt 1
                    set opacity $argv[2]
                end

            case personal

                set mode personal

                if test (count $argv) -gt 1
                    set opacity $argv[2]
                end

            case normal

                set mode normal

                if test (count $argv) -gt 1
                    set opacity $argv[2]
                end

            case off reset default

                set mode off

            case '*'

                set opacity $argv[1]

        end

    end

    # ============================================================
    # KOMMA -> PUNKT
    # ============================================================

    set opacity (string replace ',' '.' -- "$opacity")

    # ============================================================
    # DATEIEN PRÜFEN
    # ============================================================

    if not test -f "$file"

        notify-send \
            "Glass Toggle" \
            "rules.lua not found."

        return 1

    end

    if not test -f "$general"

        notify-send \
            "Glass Toggle" \
            "general.lua not found."

        return 1

    end

    if not test -f "$json"

        notify-send \
            "Glass Toggle" \
            "config.json not found."

        return 1

    end

    # ============================================================
    # OFF / RESET
    # ============================================================

    if test "$mode" = off

        sed -i \
            's/ignore_opacity = true,/ignore_opacity = false,/' \
            "$general"

        sed -i \
            '/-- GLASS_MODE_START/,/-- GLASS_MODE_END/d' \
            "$file"

        # --------------------------------------------------------
        # ILLOGICAL IMPULSE TRANSPARENCY AUS
        # --------------------------------------------------------
        #
        # contentTransparency wird NICHT angerührt.
        #
        if test -f "$json"; and command -q jq

            set tmp (mktemp)

            if jq \
                    '.appearance.transparency.enable = false' \
                    "$json" >"$tmp"

                mv "$tmp" "$json"

            else

                rm -f "$tmp"

            end

        end

        hyprctl reload

        notify-send \
            "Glass Toggle" \
            "OFF / Default"

        return 0

    end

    # ============================================================
    # OPACITY VALIDIEREN
    # ============================================================

    if not string match -rq '^[0-9]+([.][0-9]+)?$' -- "$opacity"

        notify-send \
            "Glass Toggle" \
            "Invalid opacity: $opacity"

        return 1

    end

    # ============================================================
    # OPACITY BEGRENZEN
    # ============================================================

    if test "$opacity" -lt 0
        set opacity 0
    end

    if test "$opacity" -gt 1
        set opacity 1
    end

    # ============================================================
    # BACKGROUND TRANSPARENCY BERECHNEN
    # ============================================================
    #
    # contentTransparency wird NICHT berechnet.
    #
    # Nur backgroundTransparency:
    #
    # 1 - opacity^3.03
    #
    # ============================================================

    set background_transparency \
        (math --scale=6 "1 - ($opacity ^ 3.03)")

    # ============================================================
    # DEZIMALPUNKT ERZWINGEN
    # ============================================================

    set background_transparency \
        (string replace ',' '.' -- "$background_transparency")

    # ============================================================
    # AUF 2 STELLEN FORMATIEREN
    # ============================================================

    set background_transparency \
        (printf '%.2f' "$background_transparency")

    set background_transparency \
        (string replace ',' '.' -- "$background_transparency")

    # ============================================================
    # GLASS STATUS PRÜFEN
    # ============================================================

    if grep -q 'ignore_opacity = true,' "$general"

        # ========================================================
        # ON -> OFF
        # ========================================================

        sed -i \
            's/ignore_opacity = true,/ignore_opacity = false,/' \
            "$general"

        sed -i \
            '/-- GLASS_MODE_START/,/-- GLASS_MODE_END/d' \
            "$file"

        # --------------------------------------------------------
        # TRANSPARENCY AUS
        # --------------------------------------------------------
        #
        # NUR enable ändern.
        #
        # contentTransparency bleibt 100 % unverändert.
        #
        if test -f "$json"; and command -q jq

            set tmp (mktemp)

            if jq \
                    '.appearance.transparency.enable = false' \
                    "$json" >"$tmp"

                mv "$tmp" "$json"

            else

                rm -f "$tmp"

            end

        end

        hyprctl reload

        notify-send \
            "Glass Toggle" \
            "OFF"

        return 0

    end

    # ============================================================
    # OFF -> ON
    # ============================================================

    sed -i \
        's/ignore_opacity = false,/ignore_opacity = true,/' \
        "$general"

    # Alte Glass-Regeln entfernen
    sed -i \
        '/-- GLASS_MODE_START/,/-- GLASS_MODE_END/d' \
        "$file"

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
            '-- AUSNAHMEN' \
            '' \
            'hl.window_rule({' \
            '    match = {' \
            '        class = "^(kitty|Alacritty|ghostty)$",' \
            '    },' \
            '    opacity = 1.0,' \
            '})' \
            '' \
            '-- GLASS_MODE_END' >>"$file"

        set notification "FULL ON ($opacity)"

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
            '-- PERSÖNLICHE APPS OHNE GLASS' \
            '' \
            'hl.window_rule({' \
            '    match = {' \
            '        class = "^(brave-browser|Blender|resolve|com.blackmagicdesign.resolve|kitty|Alacritty|ghostty|firefox|firefox-developer-edition|libreoffice|libreoffice-startcenter|org.wireshark.Wireshark|wireshark|org.kde.gwenview|org.kde.okular)$",' \
            '    },' \
            '    opacity = 1.0,' \
            '})' \
            '' \
            '-- GLASS_MODE_END' >>"$file"

        set notification "PERSONAL ON ($opacity)"

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
            '-- AUSNAHMEN' \
            '' \
            'hl.window_rule({' \
            '    match = {' \
            '        class = "^(code|Code|com.jetbrains.*|jetbrains-.*|brave-browser|Blender|resolve|com.blackmagicdesign.resolve|kitty|Alacritty|ghostty|firefox|firefox-developer-edition|libreoffice|libreoffice-startcenter|org.wireshark.Wireshark|wireshark|org.kde.gwenview|org.kde.okular)$",' \
            '    },' \
            '    opacity = 1.0,' \
            '})' \
            '' \
            '-- GLASS_MODE_END' >>"$file"

        set notification "NORMAL ON ($opacity)"

    end

    # ============================================================
    # ILLOGICAL IMPULSE
    # ============================================================
    #
    # WICHTIG:
    #
    # contentTransparency wird hier NICHT verändert.
    #
    # Es werden ausschließlich diese beiden Werte gesetzt:
    #
    #   backgroundTransparency
    #   enable
    #
    # ============================================================

    if test -f "$json"; and command -q jq

        set tmp (mktemp)

        if jq \
                --arg bg "$background_transparency" \
                '
            .appearance.transparency.automatic = false |
            .appearance.transparency.backgroundTransparency = ($bg | tonumber) |
            .appearance.transparency.enable = true
            ' \
                "$json" >"$tmp"

            mv "$tmp" "$json"

        else

            rm -f "$tmp"

            notify-send \
                "Glass Toggle" \
                "Error writing transparency configuration."

            return 1

        end

    end

    # ============================================================
    # HYPRLAND RELOAD
    # ============================================================

    hyprctl reload

    # ============================================================
    # NOTIFICATION
    # ============================================================

    notify-send \
        "Glass Toggle" \
        "$notification"

end
