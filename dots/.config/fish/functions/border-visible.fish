function border-visible

    set colors ~/.config/hypr/hyprland/colors.lua
    set general ~/.config/hypr/hyprland/general.lua

    if grep -q -- "-- BORDER_VISIBLE_ON" $general

        # ============================================================
        # ON -> OFF / DEFAULT
        # ============================================================

        sed -i '/-- BORDER_VISIBLE_ON/d' $general

        # Rahmenstärke auf Standard setzen
        sed -i -E 's/border_size[[:space:]]*=[[:space:]]*[0-9]+,/border_size = 1,/' $general

        # general.lua -> DEFAULT
        # Aktiver Border
        sed -i -E 's/(colors[[:space:]]*=[[:space:]]*\{[[:space:]]*)"rgba\([^"]+\)",[[:space:]]*"rgba\([^"]+\)",[[:space:]]*"rgba\([^"]+\)"([[:space:]]*\})/\1"rgba(ffffff88)", "rgba(61D6FFAA)", "rgba(7BCBFFFF)"\4/' $general

        # Inaktiver Border
        sed -i -E 's/(colors[[:space:]]*=[[:space:]]*\{[[:space:]]*)"rgba\([^"]+\)"([[:space:]]*\})/\1"rgba(ffffff18)"\2/' $general

        # colors.lua -> DEFAULT
        sed -i -E 's/(active_border[[:space:]]*=[[:space:]]*")[^"]*(")/\1rgba(47464877)\2/' $colors
        sed -i -E 's/(inactive_border[[:space:]]*=[[:space:]]*")[^"]*(")/\1rgba(1c1b1d33)\2/' $colors
        sed -i -E 's/(background_color[[:space:]]*=[[:space:]]*")[^"]*(")/\1rgba(131315FF)\2/' $colors
        sed -i -E 's/(border_color[[:space:]]*=[[:space:]]*")[^"]*(")/\1rgba(c6c5d6AA) rgba(c6c5d677)\2/' $colors

        notify-send "Border Visible" OFF

    else

        # ============================================================
        # OFF -> ON / LILA
        # ============================================================

        # Rahmenstärke erhöhen
        sed -i -E 's/border_size[[:space:]]*=[[:space:]]*[0-9]+,/border_size = 2,/' $general

        # general.lua -> LILA
        # Aktiver Border
        sed -i -E 's/(colors[[:space:]]*=[[:space:]]*\{[[:space:]]*)"rgba\([^"]+\)",[[:space:]]*"rgba\([^"]+\)",[[:space:]]*"rgba\([^"]+\)"([[:space:]]*\})/\1"rgba(cba6f7FF)", "rgba(cba6f7FF)", "rgba(cba6f7FF)"\4/' $general

        # Inaktiver Border
        sed -i -E 's/(colors[[:space:]]*=[[:space:]]*\{[[:space:]]*)"rgba\([^"]+\)"([[:space:]]*\})/\1"rgba(cba6f733)"\2/' $general

        # colors.lua -> LILA
        sed -i -E 's/(active_border[[:space:]]*=[[:space:]]*")[^"]*(")/\1rgba(cba6f7FF)\2/' $colors
        sed -i -E 's/(inactive_border[[:space:]]*=[[:space:]]*")[^"]*(")/\1rgba(cba6f733)\2/' $colors
        sed -i -E 's/(background_color[[:space:]]*=[[:space:]]*")[^"]*(")/\1rgba(1e1e2eFF)\2/' $colors
        sed -i -E 's/(border_color[[:space:]]*=[[:space:]]*")[^"]*(")/\1rgba(cba6f7AA) rgba(cba6f777)\2/' $colors

        printf '%s\n' '-- BORDER_VISIBLE_ON' >>$general

        notify-send "Border Visible" ON

    end

    hyprctl reload

end
