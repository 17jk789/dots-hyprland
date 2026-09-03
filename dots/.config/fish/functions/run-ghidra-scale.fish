# function run-ghidra-scale --description "Launch Ghidra (installed via yay) optimized for Hyprland/Wayland"

#     if not type -q ghidra
#         echo (set_color red)"Error: Ghidra is not installed on the system!"(set_color normal)
#         echo "Please install it using: yay -S ghidra"
#         return 1
#     end

#     # env \
#     #     GDK_SCALE=2 \
#     #     GDK_DPI_SCALE=1 \
#     #     _JAVA_OPTIONS="-Dsun.java2d.uiScale=2 \
#     #                    -Dawt.useSystemAAFontSettings=lcd \
#     #                    -Dswing.aatext=true" \
#     #     ghidra >/dev/null 2>&1 &

#     # env \
#     #     GDK_DPI_SCALE=1 \
#     #     _JAVA_OPTIONS="-Dsun.java2d.uiScale=2 \
#     #                    -Dawt.useSystemAAFontSettings=lcd \
#     #                    -Dswing.aatext=true \
#     #                    -Dsun.java2d.renderer=sun.java2d.marlin.MarlinRenderingEngine" \

#     env \
#         XCURSOR_SIZE=24 \
#         GDK_DPI_SCALE=1 \
#         _JAVA_OPTIONS="-Dsun.java2d.uiScale=2 -Dawt.useSystemAAFontSettings=on -Dswing.aatext=true -Dsun.java2d.renderer=sun.java2d.marlin.MarlinRenderingEngine" \
#         ghidra >/dev/null 2>&1 &

#     disown
# end

function run-ghidra-scale --description "Launch Ghidra optimized for Hyprland/Wayland on 4K"
    # 1. Systemprüfung (Schnelles Fail-Fast)
    if not type -q ghidra
        set_color red
        echo "Error: Ghidra is not installed on the system!"
        set_color yellow
        echo "Please install it using: yay -S ghidra"
        set_color normal
        return 1
    end

    # 2. Umgebungsvariablen sauber definieren (Kein Backslash-Chaos)
    set -lx XCURSOR_SIZE 24
    set -lx GDK_DPI_SCALE 1
    # set -lx _JAVA_OPTIONS "\
    #     -Dsun.java2d.uiScale=2 \
    #     -Dawt.useSystemAAFontSettings=on \
    #     -Dswing.aatext=true \
    #     -Dsun.java2d.marlin=true \
    #     -Dsun.java2d.renderer=sun.java2d.marlin.MarlinRenderingEngine"

    set -lx _JAVA_OPTIONS "\
        -Dsun.java2d.uiScale=2 \
        -Dsun.java2d.marlin.interpolation=bicubic \
        -Dawt.useSystemAAFontSettings=lcd \
        -Dswing.aatext=true \
        -Dsun.java2d.marlin=true \
        -Dsun.java2d.renderer=sun.java2d.marlin.MarlinRenderingEngine"

    # 3. Hintergrund-Start & Entkoppeln
    ghidra >/dev/null 2>&1 &
    disown
end
