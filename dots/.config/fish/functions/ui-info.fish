function ui-info --description "Show a colorful UI overview with recordings"
    # printf "%s╔════════════════════════════════════════════════════════════╗%s\n" $title $reset
    # printf "%s║JK-Arch ui-info                                             ║%s\n" $title $reset
    # printf "%s╚════════════════════════════════════════════════════════════╝%s\n\n" $title $reset

    python3 ~/.config/fish/functions/privacy_status.py
end
