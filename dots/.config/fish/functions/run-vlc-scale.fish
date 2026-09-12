function run-vlc-scale --description "Launch VLC with 150% UI scaling optimized for Hyprland/Wayland"

    # 1. System check (Fast fail)
    if not type -q vlc
        set_color red
        echo "Error: VLC is not installed on the system!"
        set_color yellow
        echo "Please install it using: yay -S vlc"
        set_color normal
        return 1
    end

    # 2. Environment variables for 150% UI scaling
    set -lx QT_SCALE_FACTOR 1.5
    set -lx XCURSOR_SIZE 24

    # 3. Start VLC in the background and detach it
    vlc >/dev/null 2>&1 &
    disown

end
