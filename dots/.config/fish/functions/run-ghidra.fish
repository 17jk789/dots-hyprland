# function run-ghidra --description "Launch Ghidra"
#     /opt/ghidra/ghidraRun
# end

function run-ghidra --description "Launch Ghidra optimized for Hyprland/Wayland"
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
    #     -Dawt.useSystemAAFontSettings=on \
    #     -Dswing.aatext=true \
    #     -Dsun.java2d.marlin=true \
    #     -Dsun.java2d.renderer=sun.java2d.marlin.MarlinRenderingEngine"

    set -lx _JAVA_OPTIONS "\
        -Dsun.java2d.marlin.interpolation=bicubic \
        -Dawt.useSystemAAFontSettings=lcd \
        -Dswing.aatext=true \
        -Dsun.java2d.marlin=true \
        -Dsun.java2d.renderer=sun.java2d.marlin.MarlinRenderingEngine"

    # 3. Hintergrund-Start & Entkoppeln
    ghidra >/dev/null 2>&1 &
    disown
end
