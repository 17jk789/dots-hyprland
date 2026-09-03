function __ui_info_format_duration --argument-names total_seconds
    if not string match -qr '^[0-9]+$' -- "$total_seconds"
        echo unknown
        return
    end

    set -l hours (math "$total_seconds / 3600")
    set -l minutes (math "($total_seconds % 3600) / 60")
    set -l seconds (math "$total_seconds % 60")

    if test $hours -gt 0
        printf "%s h %s min" $hours $minutes
    else if test $minutes -gt 0
        printf "%s min %s s" $minutes $seconds
    else
        printf "%s s" $seconds
    end
end

function __ui_info_app_version --argument-names app_name
    switch $app_name
        case obs obs64
            if type -q obs
                obs --version 2>/dev/null | command head -n 1
            else if type -q obs64
                obs64 --version 2>/dev/null | command head -n 1
            end
        case ffmpeg
            if type -q ffmpeg
                ffmpeg -version 2>/dev/null | command head -n 1
            end
        case wf-recorder
            if type -q wf-recorder
                wf-recorder --version 2>/dev/null | command head -n 1
            end
        case gpu-screen-recorder
            if type -q gpu-screen-recorder
                gpu-screen-recorder --version 2>/dev/null | command head -n 1
            end
        case kooha
            if type -q kooha
                kooha --version 2>/dev/null | command head -n 1
            end
        case wl-screenrec
            if type -q wl-screenrec
                wl-screenrec --version 2>/dev/null | command head -n 1
            end
        case peek kazam vokoscreen recordmydesktop simplescreenrecorder grim slurp wayshot ffplay scrcpy
            if type -q $app_name
                command $app_name --version 2>/dev/null | command head -n 1
            end
    end
end

function __ui_info_render_source_badges --argument-names color reset
    set -l sources $argv[3..-1]
    if test (count $sources) -eq 0
        return
    end

    printf "  %sQuellen:%s " $color $reset
    for source in $sources
        printf "%s[%s]%s " $color $source $reset
    end
    printf "\n"
end

function __ui_info_line_identity --argument-names text default_label default_color
    set -l lower_text (string lower -- "$text")
    set -l label $default_label
    set -l color $default_color

    if string match -qr '(discord)' -- "$lower_text"
        set label Discord
        set color blue
    else if string match -qr '(vesktop)' -- "$lower_text"
        set label Vesktop
        set color cyan
    else if string match -qr '(obs)' -- "$lower_text"
        set label OBS
        set color yellow
    else if string match -qr '(xdg-desktop-portal|portal\.monitor|screencast|screen cast|screen-cast|screen share|screen capture|screen recording)' -- "$lower_text"
        set label Portal
        set color magenta
    else if string match -qr '(chromium|chrome|brave|firefox)' -- "$lower_text"
        set label Browser
        set color green
    else if string match -qr '(camera|webcam|video source|v4l2_input)' -- "$lower_text"
        set label Camera
        set color green
    else if string match -qr '(microphone|mic|audio source|alsa_input)' -- "$lower_text"
        set label Microphone
        set color green
    end

    printf "%s\t%s\n" $label $color
end

function __ui_info_render_labeled_line --argument-names text default_label default_color indent reset dim
    set -l identity (__ui_info_line_identity "$text" "$default_label" "$default_color")
    set -l identity_parts (string split \t -- $identity)
    set -l label $identity_parts[1]
    set -l color_name $identity_parts[2]
    set -l color (set_color $color_name)
    set -l preview (string shorten -m 110 -- "$text")
    printf "%s- %s%s:%s %s%s\n" $indent $color $label $reset $dim (string shorten -m 110 -- "$text")
end

function __ui_info_pwtop_matches --argument-names pattern
    if not type -q pw-top
        return 1
    end

    set -lx COLUMNS 240
    set -l old_stty ""
    if type -q stty
        set old_stty (stty -g 2>/dev/null)
        stty cols 240 2>/dev/null
    end
    set -l pwtop_lines (pw-top -b -n 1 2>/dev/null)
    if test -n "$old_stty"
        stty "$old_stty" 2>/dev/null
    end
    for line in $pwtop_lines
        if string match -qr -- $pattern -- "$line"
            printf "%s\n" "$line"
        end
    end
end

function __ui_info_tui --description "Show a live fullscreen UI overview"
    set -l reset (set_color normal)
    set -l title (set_color cyan)
    set -l label (set_color brcyan)
    set -l value (set_color white)
    set -l dim (set_color brblack)
    set -l warn (set_color yellow)
    set -l ok (set_color green)

    if type -q tput
        tput civis 2>/dev/null
    end

    while true
        set -l key ""
        if type -q bash
            set key (command bash -lc 'IFS= read -rsn1 -t 0.1 key; printf "%s" "$key"' 2>/dev/null)
        else
            command sleep 0.1
        end

        if test -n "$key"
            switch $key
                case q Q \003
                    break
            end
        end

        set -l host_name (command hostname 2>/dev/null)
        set -l pretty_host ""
        if type -q hostnamectl
            set pretty_host (hostnamectl --pretty 2>/dev/null)
        end
        if test -z "$pretty_host"
            set pretty_host $host_name
        end

        set -l product_name unknown
        if test -r /sys/devices/virtual/dmi/id/product_name
            set product_name (string trim -- (command cat /sys/devices/virtual/dmi/id/product_name))
        end

        set -l chassis PC
        if test -r /sys/devices/virtual/dmi/id/chassis_type
            set -l chassis_type (string trim -- (command cat /sys/devices/virtual/dmi/id/chassis_type))
            switch $chassis_type
                case 8 9 10 14 31 32
                    set chassis Laptop
            end
        end

        set -l session_type unknown
        if set -q XDG_SESSION_TYPE
            set session_type $XDG_SESSION_TYPE
        end

        set -l display_backend unknown
        if set -q WAYLAND_DISPLAY
            set display_backend Wayland
        else if set -q DISPLAY
            set display_backend X11
        end

        set -l uptime_text (uptime -p 2>/dev/null)
        if test -z "$uptime_text"
            set uptime_text (uptime 2>/dev/null)
        end

        set -l recording_process_lines
        set -l recording_pwtop_lines (__ui_info_pwtop_matches '(screen|capture|portal|monitor|screencast|obs|wf-recorder|wl-screenrec|gpu-screen-recorder|kooha|vesktop|discord|zoom|teams|firefox|chromium|chrome|brave)')
        set -l recording_portal_lines
        if type -q busctl
            set -l portal_tree (busctl --user tree org.freedesktop.portal.Desktop 2>/dev/null)
            for line in $portal_tree
                if string match -qr '(session|screencast|screen|portal)' -- "$line"
                    set -a recording_portal_lines "$line"
                end
            end
        end

        if type -q ps
            set -l ps_lines (ps -eo pid=,etimes=,comm=,args= 2>/dev/null)
            for line in $ps_lines
                if string match -qr '(obs|obs64|ffmpeg|wf-recorder|wl-screenrec|gpu-screen-recorder|kooha|vesktop|discord|zoom|teams|firefox|chromium|chrome|brave|slack|mumble|simplescreenrecorder|peek|vokoscreen|kazam|recordmydesktop|grim|slurp|wayshot|ffplay|scrcpy)' -- "$line"
                    set -a recording_process_lines "$line"
                end
            end
        end

        set -l camera_pwtop_lines (__ui_info_pwtop_matches '(v4l2_input|webcam|camera|TrueVision|UVC|video)')
        set -l microphone_pwtop_lines (__ui_info_pwtop_matches '(alsa_input|microphone|mic|source)')

        set -l camera_process_lines
        set -l microphone_process_lines
        if type -q ps
            set -l ps_lines (ps -eo pid=,etimes=,comm=,args= 2>/dev/null)
            for line in $ps_lines
                if string match -qr '(camera|webcam|v4l2|cheese|vesktop|discord|zoom|teams|firefox|chromium|chrome|brave)' -- "$line"
                    set -a camera_process_lines "$line"
                end
                if string match -qr '(vesktop|discord|zoom|teams|firefox|chromium|chrome|brave|slack|mumble|audacity|whisper|pavucontrol|pipewire|pulse)' -- "$line"
                    set -a microphone_process_lines "$line"
                end
            end
        end

        set -l recording_active 0
        if test (count $recording_process_lines) -gt 0 -o (count $recording_pwtop_lines) -gt 0 -o (count $recording_portal_lines) -gt 0
            set recording_active 1
        end

        set -l recording_sources
        if test (count $recording_process_lines) -gt 0
            set -a recording_sources Prozesse
        end
        if test (count $recording_pwtop_lines) -gt 0
            set -a recording_sources PipeWire
        end
        if test (count $recording_portal_lines) -gt 0
            set -a recording_sources Portal
        end

        set -l camera_active 0
        if test (count $camera_process_lines) -gt 0 -o (count $camera_pwtop_lines) -gt 0
            set camera_active 1
        end

        set -l microphone_active 0
        if test (count $microphone_process_lines) -gt 0 -o (count $microphone_pwtop_lines) -gt 0
            set microphone_active 1
        end

        printf "\e[H\e[2J"

        set -l recording_app Keine
        for line in $recording_process_lines $recording_pwtop_lines $pipewire_capture_lines $portal_session_lines
            set -l lower (string lower -- "$line")
            if string match -qr discord -- "$lower"
                set recording_app (set_color blue)"Discord"(set_color normal)
                break
            else if string match -qr vesktop -- "$lower"
                set recording_app (set_color magenta)"Vesktop"(set_color normal)
                break
            else if string match -qr obs -- "$lower"
                set recording_app (set_color yellow)"OBS"(set_color normal)
                break
            else if string match -qr firefox -- "$lower"
                set recording_app (set_color red)"Firefox"(set_color normal)
                break
            else if string match -qr '(chrome|chromium)' -- "$lower"
                set recording_app (set_color green)"Chrome"(set_color normal)
                break
            else if string match -qr brave -- "$lower"
                set recording_app (set_color brgreen)"Brave"(set_color normal)
                break
            end
        end

        set -l camera_app Keine
        for line in $camera_process_lines $camera_pipewire_lines $camera_consumer_lines
            set -l lower (string lower -- "$line")
            if string match -qr discord -- "$lower"
                set camera_app (set_color blue)"Discord"(set_color normal)
                break
            else if string match -qr vesktop -- "$lower"
                set camera_app (set_color magenta)"Vesktop"(set_color normal)
                break
            else if string match -qr obs -- "$lower"
                set camera_app (set_color yellow)"OBS"(set_color normal)
                break
            else if string match -qr firefox -- "$lower"
                set camera_app (set_color red)"Firefox"(set_color normal)
                break
            else if string match -qr '(chrome|chromium)' -- "$lower"
                set camera_app (set_color green)"Chrome"(set_color normal)
                break
            end
        end

        set -l microphone_app Keine
        for line in $microphone_process_lines $microphone_pipewire_lines $microphone_pwtop_lines
            set -l lower (string lower -- "$line")
            if string match -qr discord -- "$lower"
                set microphone_app (set_color blue)"Discord"(set_color normal)
                break
            else if string match -qr vesktop -- "$lower"
                set microphone_app (set_color magenta)"Vesktop"(set_color normal)
                break
            else if string match -qr obs -- "$lower"
                set microphone_app (set_color yellow)"OBS"(set_color normal)
                break
            else if string match -qr firefox -- "$lower"
                set microphone_app (set_color red)"Firefox"(set_color normal)
                break
            else if string match -qr '(chrome|chromium)' -- "$lower"
                set microphone_app (set_color green)"Chrome"(set_color normal)
                break
            end
        end

        printf "╔══════════════════════════════════════════════╗\n"
        printf "║                STATUS                        ║\n"
        printf "╠══════════════════════════════════════════════╣\n"
        printf "║ Bildschirm : %-30s ║\n" "$recording_app"
        printf "║ Kamera      : %-30s ║\n" "$camera_app"
        printf "║ Mikrofon    : %-30s ║\n" "$microphone_app"
        printf "╚══════════════════════════════════════════════╝\n\n"

        printf "%s════════════════════════════════════════════════════════════%s\n" $title $reset
        printf "%sui-info%s  %slive terminal dashboard%s\n" $title $reset $dim $reset
        printf "%s════════════════════════════════════════════════════════════%s\n\n" $title $reset

        printf "%sSystem%s\n" $label $reset
        printf "  %sHost:%s %s\n" $dim $reset $pretty_host
        printf "  %sType:%s %s\n" $dim $reset $chassis
        printf "  %sModel:%s %s\n" $dim $reset $product_name
        printf "  %sSession:%s %s\n" $dim $reset $session_type
        printf "  %sDisplay:%s %s\n" $dim $reset $display_backend
        printf "  %sUptime:%s %s\n" $dim $reset $uptime_text

        printf "\n%sRecording Status%s\n" $label $reset
        if test $recording_active -eq 1
            printf "  %s● Bildschirmaufnahme aktiv%s\n" $warn $reset
        else
            printf "  %s○ Keine Bildschirmaufnahme aktiv%s\n" $dim $reset
        end
        __ui_info_render_source_badges $dim $reset $recording_sources
        if test (count $recording_pwtop_lines) -gt 0
            printf "  %sPipeWire / Screencast%s (%s%d%s)\n" $label $reset $value (count $recording_pwtop_lines) $reset
            for line in $recording_pwtop_lines
                __ui_info_render_labeled_line "$line" PipeWire brblack "    " $reset $dim
            end
        end
        if test (count $recording_process_lines) -gt 0
            printf "  %sProzesse%s (%s%d%s)\n" $label $reset $value (count $recording_process_lines) $reset
            for line in $recording_process_lines
                __ui_info_render_labeled_line "$line" App white "    " $reset $dim
            end
        end
        if test (count $recording_portal_lines) -gt 0
            printf "  %sPortal%s (%s%d%s)\n" $label $reset $value (count $recording_portal_lines) $reset
            for line in $recording_portal_lines
                __ui_info_render_labeled_line "$line" Portal magenta "    " $reset $dim
            end
        end

        printf "\n%sCamera%s\n" $label $reset
        if test $camera_active -eq 1
            printf "  %s● Kamera aktiv%s\n" $ok $reset
        else
            printf "  %s○ Keine Kamera aktiv%s\n" $dim $reset
        end
        if test (count $camera_pwtop_lines) -gt 0
            for line in $camera_pwtop_lines
                __ui_info_render_labeled_line "$line" Camera green "    " $reset $dim
            end
        else if test (count $camera_process_lines) -gt 0
            for line in $camera_process_lines
                __ui_info_render_labeled_line "$line" Camera green "    " $reset $dim
            end
        end

        printf "\n%sMicrophone%s\n" $label $reset
        if test $microphone_active -eq 1
            printf "  %s● Mikrofon aktiv%s\n" $ok $reset
        else
            printf "  %s○ Kein Mikrofon aktiv%s\n" $dim $reset
        end
        if test (count $microphone_pwtop_lines) -gt 0
            for line in $microphone_pwtop_lines
                __ui_info_render_labeled_line "$line" Microphone green "    " $reset $dim
            end
        else if test (count $microphone_process_lines) -gt 0
            for line in $microphone_process_lines
                __ui_info_render_labeled_line "$line" Microphone green "    " $reset $dim
            end
        end

        printf "\n%sq%s = quit  •  %srefresh%s = 100 ms\n" $warn $reset $dim $reset
    end

    if type -q tput
        tput cnorm 2>/dev/null
    end
end

function ui-info --description "Show a colorful UI overview with device, display, windows and recordings"
    if test (count $argv) -gt 0
        switch $argv[1]
            case --tui --live --watch
                __ui_info_tui
                return
        end
    end

    __ui_info_snapshot
end

function __ui_info_snapshot --description "Show a colorful UI overview with device, display, windows and recordings"
    set -l reset (set_color normal)
    set -l title (set_color cyan)
    set -l label (set_color brcyan)
    set -l value (set_color white)
    set -l dim (set_color brblack)
    set -l warn (set_color yellow)

    set -l host_name (command hostname 2>/dev/null)
    set -l pretty_host ""
    if type -q hostnamectl
        set pretty_host (hostnamectl --pretty 2>/dev/null)
    end
    if test -z "$pretty_host"
        set pretty_host $host_name
    end

    set -l product_name unknown
    if test -r /sys/devices/virtual/dmi/id/product_name
        set product_name (string trim -- (command cat /sys/devices/virtual/dmi/id/product_name))
    end

    set -l vendor_name ""
    if test -r /sys/devices/virtual/dmi/id/sys_vendor
        set vendor_name (string trim -- (command cat /sys/devices/virtual/dmi/id/sys_vendor))
    end

    set -l chassis PC
    if test -r /sys/devices/virtual/dmi/id/chassis_type
        set -l chassis_type (string trim -- (command cat /sys/devices/virtual/dmi/id/chassis_type))
        switch $chassis_type
            case 8 9 10 14 31 32
                set chassis Laptop
        end
    end

    set -l os_name unknown
    if test -r /etc/os-release
        set os_name (command grep '^PRETTY_NAME=' /etc/os-release 2>/dev/null | command cut -d= -f2- | string trim -c '"')
    end
    if test -z "$os_name"
        set os_name (uname -s)
    end

    set -l kernel (uname -r)
    set -l arch (uname -m)
    set -l session_type unknown
    if set -q XDG_SESSION_TYPE
        set session_type $XDG_SESSION_TYPE
    end
    set -l session_desktop unknown
    if set -q XDG_CURRENT_DESKTOP
        set session_desktop $XDG_CURRENT_DESKTOP
    else if set -q DESKTOP_SESSION
        set session_desktop $DESKTOP_SESSION
    end
    set -l display_backend unknown
    if set -q WAYLAND_DISPLAY
        set display_backend Wayland
    else if set -q DISPLAY
        set display_backend X11
    end
    set -l uptime_text (uptime -p 2>/dev/null)
    if test -z "$uptime_text"
        set uptime_text (uptime 2>/dev/null)
    end

    set -l boot_text (uptime -s 2>/dev/null)
    if test -z "$boot_text"
        if type -q who
            set boot_text (who -b 2>/dev/null)
        end
    end

    set -l logged_in_users (who 2>/dev/null)
    set -l camera_nodes (command find /dev -maxdepth 1 -type c -name 'video*' 2>/dev/null)
    set -l microphone_nodes (command find /dev/snd -maxdepth 1 -type c 2>/dev/null)
    set -l camera_consumer_pids
    set -l camera_consumer_lines
    set -l microphone_consumer_pids
    set -l microphone_consumer_lines
    if type -q lsof
        set -l camera_lsof_lines (lsof -nP /dev/video* 2>/dev/null)
        for line in $camera_lsof_lines
            if string match -qr '^COMMAND' -- "$line"
                continue
            end
            set -l camera_parts (string match -r --groups-only '^([^ ]+)\s+([0-9]+)\s+([^ ]+)\s+([^ ]+)\s+(.*)$' -- "$line")
            if test (count $camera_parts) -ge 5
                set -l camera_pid $camera_parts[2]
                if not contains -- $camera_pid $camera_consumer_pids
                    set -a camera_consumer_pids $camera_pid
                    set -a camera_consumer_lines "$line"
                end
            end
        end
        if test (count $microphone_nodes) -gt 0
            for microphone_node in $microphone_nodes
                set -l microphone_lsof_lines (lsof -nP "$microphone_node" 2>/dev/null)
                for line in $microphone_lsof_lines
                    if string match -qr '^COMMAND' -- "$line"
                        continue
                    end
                    set -l microphone_parts (string match -r --groups-only '^([^ ]+)\s+([0-9]+)\s+([^ ]+)\s+([^ ]+)\s+(.*)$' -- "$line")
                    if test (count $microphone_parts) -ge 5
                        set -l microphone_pid $microphone_parts[2]
                        if not contains -- $microphone_pid $microphone_consumer_pids
                            set -a microphone_consumer_pids $microphone_pid
                            set -a microphone_consumer_lines "$line"
                        end
                    end
                end
            end
        end
    else if type -q fuser
        set camera_consumer_lines (fuser -v /dev/video* 2>/dev/null)
        if test (count $microphone_nodes) -gt 0
            set microphone_consumer_lines (fuser -v $microphone_nodes 2>/dev/null)
        end
    end
    set -l login_sessions
    if type -q loginctl
        set login_sessions (loginctl list-sessions --no-legend 2>/dev/null)
    end

    set -l recording_app_regex '(obs|obs64|ffmpeg|wf-recorder|wl-screenrec|gpu-screen-recorder|kooha|vesktop|simplescreenrecorder|peek|vokoscreen|kazam|recordmydesktop|grim|slurp|wayshot|ffplay|scrcpy)'
    set -l recording_support_regex '(xdg-desktop-portal|xdg-desktop-portal-hyprland|pipewire|wireplumber|gstreamer|portal)'
    set -l microphone_app_regex '(obs|obs64|ffmpeg|arecord|parec|pw-record|pw-cat|audacity|whisper|wf-recorder|wl-screenrec|gpu-screen-recorder|kooha|vesktop|discord|zoom|teams|firefox|chromium|chrome|brave|slack|mumble|pavucontrol)'
    set -l microphone_support_regex '(pipewire|wireplumber|pulseaudio|pipewire-pulse|alsa|portal|pulse)'

    set -l monitor_lines
    if test "$display_backend" = X11
        if type -q xrandr
            set monitor_lines (xrandr --query 2>/dev/null | command grep ' connected')
        end
    else if type -q hyprctl
        set monitor_lines (hyprctl monitors 2>/dev/null)
    else if type -q swaymsg
        set monitor_lines (swaymsg -t get_outputs 2>/dev/null)
    else if type -q wlr-randr
        set monitor_lines (wlr-randr 2>/dev/null)
    end

    set -l window_lines
    if type -q wmctrl
        set window_lines (wmctrl -lG 2>/dev/null)
    else if type -q hyprctl
        set window_lines (hyprctl clients 2>/dev/null)
    end

    set -l recording_lines
    set -l recording_support_lines
    if type -q ps
        set -l ps_lines (ps -eo pid=,etimes=,comm=,args= 2>/dev/null)
        for line in $ps_lines
            if string match -qr -- $recording_app_regex -- "$line"
                set -a recording_lines "$line"
            else if string match -qr -- $recording_support_regex -- "$line"
                set -a recording_support_lines "$line"
            end
        end
    end

    set -l pipewire_capture_lines (__ui_info_pwtop_matches '(screen|capture|portal|monitor|screencast|obs|wf-recorder|wl-screenrecorder|wl-screenrec|gpu-screen-recorder|kooha|vesktop|discord|zoom|teams|firefox|chromium|chrome|brave)')
    if test (count $pipewire_capture_lines) -eq 0
        set -e pipewire_capture_lines
    end
    if type -q pw-dump
        set -l pw_lines (pw-dump 2>/dev/null)
        for line in $pw_lines
            if string match -qr '(ScreenCast|screen cast|screen-cast|screen capture|screen share|screencast|portal.monitor|Video/Source|Stream/Output/Video|OBS|obs|wf-recorder|wl-screenrec|gpu-screen-recorder|kooha|vesktop|chromium|firefox|discord|zoom|teams)' -- "$line"
                set -a pipewire_capture_lines "$line"
            end
        end
    else if type -q pw-cli
        set -l pw_lines (pw-cli ls Node 2>/dev/null)
        for line in $pw_lines
            if string match -qr '(ScreenCast|screen cast|screen-cast|screen capture|screen share|screencast|portal.monitor|Video/Source|Stream/Output/Video|OBS|obs|wf-recorder|wl-screenrec|gpu-screen-recorder|kooha|vesktop|chromium|firefox|discord|zoom|teams)' -- "$line"
                set -a pipewire_capture_lines "$line"
            end
        end
    end

    set -l microphone_process_lines
    set -l microphone_support_lines
    if type -q ps
        set -l ps_lines (ps -eo pid=,etimes=,comm=,args= 2>/dev/null)
        for line in $ps_lines
            if string match -qr -- $microphone_app_regex -- "$line"
                set -a microphone_process_lines "$line"
            else if string match -qr -- $microphone_support_regex -- "$line"
                set -a microphone_support_lines "$line"
            end
        end
    end

    set -l microphone_pipewire_lines
    if type -q pw-dump
        set -l pw_lines (pw-dump 2>/dev/null)
        for line in $pw_lines
            if string match -qr '(Audio/Source|Audio/Source/Virtual|microphone|mic|alsa_input|source-output|capture.*audio|application.name.*(obs|discord|zoom|teams|firefox|chromium|chrome|brave|slack|mumble|audacity|whisper)|node.description.*(Microphone|Mic))' -- "$line"
                set -a microphone_pipewire_lines "$line"
            end
        end
    else if type -q pw-cli
        set -l pw_lines (pw-cli ls Node 2>/dev/null)
        for line in $pw_lines
            if string match -qr '(Audio/Source|Audio/Source/Virtual|microphone|mic|alsa_input|source-output|capture.*audio|application.name.*(obs|discord|zoom|teams|firefox|chromium|chrome|brave|slack|mumble|audacity|whisper)|node.description.*(Microphone|Mic))' -- "$line"
                set -a microphone_pipewire_lines "$line"
            end
        end
    end

    set -l microphone_pulse_lines
    if type -q pactl
        set -l pactl_lines (pactl list source-outputs short 2>/dev/null)
        for line in $pactl_lines
            if test -n "$line"
                set -a microphone_pulse_lines "$line"
            end
        end
    end

    set -l microphone_portal_lines
    if type -q busctl
        set -l portal_tree (busctl --user tree org.freedesktop.portal.Desktop 2>/dev/null)
        for line in $portal_tree
            if string match -qr '(access|audio|microphone|input|capture|portal)' -- "$line"
                set -a microphone_portal_lines "$line"
            end
        end
    end

    set -l portal_session_lines
    if type -q busctl
        set -l portal_tree (busctl --user tree org.freedesktop.portal.Desktop 2>/dev/null)
        for line in $portal_tree
            if string match -qr '(session|screencast|screen)' -- "$line"
                set -a portal_session_lines "$line"
            end
        end
    end

    set -l camera_pipewire_lines
    if type -q pw-dump
        set -l pw_lines (pw-dump 2>/dev/null)
        for line in $pw_lines
            if string match -qr '(portal.monitor.*Camera|Video/Source|node.description.*Camera|webcam|TrueVision|camera)' -- "$line"
                set -a camera_pipewire_lines "$line"
            end
        end
    end

    set -l recent_recordings (command find ~/Videos ~/Schreibtisch ~/Pictures ~/.local/share -type f \( -iname '*.mkv' -o -iname '*.mp4' -o -iname '*.webm' -o -iname '*.mov' \) -mtime -30 2>/dev/null | command head -n 8)

    printf "%s╔════════════════════════════════════════════════════════════╗%s\n" $title $reset
    printf "%s║JK-Arch all-ui-info                                             ║%s\n" $title $reset
    printf "%s╚════════════════════════════════════════════════════════════╝%s\n\n" $title $reset

    # python3 ~/.config/fish/functions/privacy_status.py

    printf "\n"

    printf "%sSystem%s\n" $label $reset
    printf "  %sHost:%s %s\n" $dim $reset $pretty_host
    printf "  %sType:%s %s\n" $dim $reset $chassis
    if test -n "$vendor_name"
        printf "  %sModel:%s %s %s%s%s\n" $dim $reset $vendor_name $value $product_name $reset
    else
        printf "  %sModel:%s %s\n" $dim $reset $product_name
    end
    printf "  %sOS:%s %s\n" $dim $reset $os_name
    printf "  %sKernel:%s %s\n" $dim $reset $kernel
    printf "  %sArch:%s %s\n" $dim $reset $arch
    printf "  %sUptime:%s %s\n" $dim $reset $uptime_text
    if test -n "$boot_text"
        printf "  %sBoot:%s %s\n" $dim $reset $boot_text
    end
    printf "  %sSession:%s %s (%s)\n" $dim $reset $session_type $session_desktop
    printf "  %sDisplay:%s %s\n" $dim $reset $display_backend

    printf "\n%sDisplays%s\n" $label $reset
    if test (count $monitor_lines) -gt 0
        for line in $monitor_lines
            printf "  %s- %s%s\n" $dim $reset $line
        end
    else
        printf "  %sKeine Display-Details gefunden%s\n" $warn $reset
    end

    printf "\n%sWindows%s\n" $label $reset
    if test (count $window_lines) -gt 0
        for line in $window_lines
            printf "  %s- %s%s\n" $dim $reset $line
        end
    else
        printf "  %sKeine Fenster-Details gefunden%s\n" $warn $reset
    end

    set -l recording_active 0
    if test (count $recording_lines) -gt 0
        set recording_active 1
    else if test (count $pipewire_capture_lines) -gt 0
        set recording_active 1
    else if test (count $portal_session_lines) -gt 0
        set recording_active 1
    end

    set -l recording_sources
    if test (count $recording_lines) -gt 0
        set -a recording_sources Prozesse
    end
    if test (count $pipewire_capture_lines) -gt 0
        set -a recording_sources PipeWire
    end
    if test (count $portal_session_lines) -gt 0
        set -a recording_sources Portal
    end

    printf "\n%sRecording Status%s\n" $label $reset
    if test $recording_active -eq 1
        printf "  %s● Bildschirmaufnahme aktiv%s\n" $warn $reset
    else
        printf "  %s○ Keine Bildschirmaufnahme aktiv%s\n" $dim $reset
    end

    if test (count $recording_sources) -gt 0
        __ui_info_render_source_badges $dim $reset $recording_sources
    end

    if test (count $recording_lines) -gt 0
        printf "  %sProzesse%s (%s%d%s)\n" $label $reset $value (count $recording_lines) $reset
        for line in $recording_lines
            set -l parts (string match -r --groups-only '^([0-9]+)\s+([0-9]+)\s+([^ ]+)\s+(.*)$' -- "$line")
            if test (count $parts) -ge 4
                set -l rec_pid $parts[1]
                set -l rec_etimes $parts[2]
                set -l rec_comm $parts[3]
                set -l rec_args $parts[4]
                set -l rec_runtime (__ui_info_format_duration $rec_etimes)
                set -l rec_start unknown
                if type -q ps
                    set rec_start (ps -p "$rec_pid" -o lstart= 2>/dev/null | string trim)
                end

                set -l rec_scope unknown
                if string match -qr '(window|active-window|window-id|source-window|grab_window|focus|window capture|capture_window)' -- "$rec_args"
                    set rec_scope Fenster
                else if string match -qr '(region|area|crop|selection|rectangle|partial|trim|geometry)' -- "$rec_args"
                    set rec_scope Teilbereich
                else if string match -qr '(monitor|display|screen|fullscreen|full-screen|x11grab|screen capture|monitor capture|pipewire)' -- "$rec_args"
                    set rec_scope Fullscreen
                end

                set -l rec_target ""
                if string match -qr '(obs)' -- "$rec_comm $rec_args"
                    set rec_target OBS
                else if string match -qr '(ffmpeg)' -- "$rec_comm $rec_args"
                    set rec_target ffmpeg
                else if string match -qr '(wf-recorder)' -- "$rec_comm $rec_args"
                    set rec_target wf-recorder
                else if string match -qr '(wl-screenrec)' -- "$rec_comm $rec_args"
                    set rec_target wl-screenrec
                else if string match -qr '(gpu-screen-recorder)' -- "$rec_comm $rec_args"
                    set rec_target gpu-screen-recorder
                else if string match -qr '(kooha)' -- "$rec_comm $rec_args"
                    set rec_target kooha
                else if string match -qr '(simplescreenrecorder|kazam|vokoscreen|peek|recordmydesktop|grim|slurp|wayshot|scrcpy)' -- "$rec_comm $rec_args"
                    set rec_target $rec_comm
                end

                set -l rec_version ""
                if test -n "$rec_target"
                    set rec_version (__ui_info_app_version $rec_comm)
                end

                set -l rec_preview (string shorten -m 110 -- "$rec_args")
                printf "    %s- %s%s%s\n" $dim $value $rec_comm $reset
                printf "      %s%-10s%s %s\n" $dim "PID:" $reset $rec_pid
                printf "      %s%-10s%s %s\n" $dim "Seit:" $reset $rec_start
                printf "      %s%-10s%s %s\n" $dim "Laufzeit:" $reset $rec_runtime
                printf "      %s%-10s%s %s\n" $dim "Typ:" $reset $rec_scope
                if test -n "$rec_target"
                    printf "      %s%-10s%s %s\n" $dim "App:" $reset $rec_target
                end
                if test -n "$rec_version"
                    printf "      %s%-10s%s %s\n" $dim "Version:" $reset $rec_version
                end
                printf "      %s%-10s%s %s\n" $dim "Cmd:" $reset $rec_preview
            else
                printf "    %s- %s%s\n" $dim $reset $line
            end
        end
    end

    if test (count $pipewire_capture_lines) -gt 0
        printf "  %sPipeWire / Screencast%s (%s%d%s)\n" $label $reset $value (count $pipewire_capture_lines) $reset
        for line in $pipewire_capture_lines
            set -l capture_preview (string shorten -m 120 -- "$line")
            printf "    %s- %s%s\n" $dim $reset $capture_preview
        end
    end

    if test (count $portal_session_lines) -gt 0
        printf "  %sPortal sessions%s (%s%d%s)\n" $label $reset $value (count $portal_session_lines) $reset
        for line in $portal_session_lines
            printf "    %s- %s%s\n" $dim $reset $line
        end
    end

    if test (count $recording_support_lines) -gt 0
        printf "  %sSupport-Dienste%s\n" $label $reset
        for line in $recording_support_lines
            set -l support_preview (string shorten -m 92 -- "$line")
            printf "    %s- %s%s\n" $dim $reset $support_preview
        end
    end

    printf "\n%sRecent captures%s\n" $label $reset
    if test (count $recent_recordings) -gt 0
        for file in $recent_recordings
            set -l file_size unknown
            set -l file_time unknown
            if type -q stat
                set file_size (stat -c '%s' "$file" 2>/dev/null)
                set file_time (stat -c '%y' "$file" 2>/dev/null)
            end
            printf "  %s- %s%s%s\n" $dim $reset $file $reset
            printf "    %smtime:%s %s  %ssize:%s %s bytes\n" $dim $reset $file_time $dim $reset $file_size
        end
    else
        printf "  %sKeine aktuellen Capture-Dateien gefunden%s\n" $warn $reset
    end

    set -l camera_active 0
    if test (count $camera_consumer_pids) -gt 0
        set camera_active 1
    else if test (count $camera_consumer_lines) -gt 0
        set camera_active 1
    else if test (count $camera_pipewire_lines) -gt 0
        set camera_active 1
    end

    printf "\n%sCamera Status%s\n" $label $reset
    if test $camera_active -eq 1
        printf "  %s● Kamera aktiv%s\n" $warn $reset
    else
        printf "  %s○ Keine Kamera aktiv%s\n" $dim $reset
    end

    if test (count $camera_nodes) -gt 0
        printf "  %sGeräte%s\n" $label $reset
        for node in $camera_nodes
            set -l camera_name ""
            if type -q udevadm
                set camera_name (command udevadm info -q property -n "$node" 2>/dev/null | command grep '^ID_MODEL=' | command head -n 1 | command cut -d= -f2-)
            end
            if test -n "$camera_name"
                printf "  %s- %s%s (%s)%s\n" $dim $reset $node $camera_name $reset
            else
                printf "  %s- %s%s%s\n" $dim $reset $node $reset
            end
        end

        if test (count $camera_consumer_pids) -gt 0
            printf "  %sProzesse%s\n" $label $reset
            for pid in $camera_consumer_pids
                set -l camera_proc (ps -p $pid -o pid=,etimes=,comm=,args= 2>/dev/null)
                if test -n "$camera_proc"
                    set -l camera_proc_parts (string match -r --groups-only '^([0-9]+)\s+([0-9]+)\s+([^ ]+)\s+(.*)$' -- "$camera_proc")
                    if test (count $camera_proc_parts) -ge 4
                        set -l cam_pid $camera_proc_parts[1]
                        set -l cam_etimes $camera_proc_parts[2]
                        set -l cam_comm $camera_proc_parts[3]
                        set -l cam_args $camera_proc_parts[4]
                        set -l cam_runtime (__ui_info_format_duration $cam_etimes)
                        set -l cam_start unknown
                        if type -q ps
                            set cam_start (ps -p "$cam_pid" -o lstart= 2>/dev/null | string trim)
                        end
                        set -l cam_preview (string shorten -m 92 -- "$cam_args")
                        printf "    %s- %s%s%s\n" $dim $value $cam_comm $reset
                        printf "      %s%-10s%s %s\n" $dim "PID:" $reset $cam_pid
                        printf "      %s%-10s%s %s\n" $dim "Seit:" $reset $cam_start
                        printf "      %s%-10s%s %s\n" $dim "Laufzeit:" $reset $cam_runtime
                        printf "      %s%-10s%s %s\n" $dim "Cmd:" $reset $cam_preview
                    else
                        printf "    %s- %s%s\n" $dim $reset $camera_proc
                    end
                end
            end
        else if test -n "$camera_consumer_lines"
            printf "  %sKamera-Clients%s\n" $label $reset
            for line in $camera_consumer_lines
                printf "    %s- %s%s\n" $dim $reset $line
            end
        else
            printf "  %sKeine aktiven Kamera-Clients gefunden%s\n" $warn $reset
        end

        if test (count $camera_pipewire_lines) -gt 0
            printf "  %sPipeWire-Kamera%s\n" $label $reset
            for line in $camera_pipewire_lines
                set -l camera_preview (string shorten -m 110 -- "$line")
                printf "    %s- %s%s\n" $dim $reset $camera_preview
            end
        end
    else
        printf "  %sKeine Kamera gefunden%s\n" $warn $reset
    end

    set -l microphone_active 0
    if test (count $microphone_consumer_pids) -gt 0
        set microphone_active 1
    else if test (count $microphone_consumer_lines) -gt 0
        set microphone_active 1
    else if test (count $microphone_pipewire_lines) -gt 0
        set microphone_active 1
    else if test (count $microphone_pulse_lines) -gt 0
        set microphone_active 1
    else if test (count $microphone_process_lines) -gt 0
        set microphone_active 1
    end

    printf "\n%sMicrophone Status%s\n" $label $reset
    if test $microphone_active -eq 1
        printf "  %s● Mikrofon aktiv%s\n" $warn $reset
    else
        printf "  %s○ Kein Mikrofon aktiv%s\n" $dim $reset
    end

    set -l microphone_sources
    if test (count $microphone_process_lines) -gt 0
        set -a microphone_sources Prozesse
    end
    if test (count $microphone_pipewire_lines) -gt 0
        set -a microphone_sources PipeWire
    end
    if test (count $microphone_pulse_lines) -gt 0
        set -a microphone_sources Pulse
    end
    if test (count $microphone_portal_lines) -gt 0
        set -a microphone_sources Portal
    end
    if test (count $microphone_sources) -gt 0
        printf "  %sQuellen:%s %s\n" $dim $reset (string join ", " -- $microphone_sources)
    end

    if test (count $microphone_nodes) -gt 0
        printf "  %sGeräte%s\n" $label $reset
        for node in $microphone_nodes
            set -l mic_name ""
            if type -q udevadm
                set mic_name (command udevadm info -q property -n "$node" 2>/dev/null | command grep '^ID_MODEL=' | command head -n 1 | command cut -d= -f2-)
            end
            if test -n "$mic_name"
                printf "    %s- %s%s (%s)%s\n" $dim $reset $node $mic_name $reset
            else
                printf "    %s- %s%s%s\n" $dim $reset $node $reset
            end
        end
    end

    if test (count $microphone_consumer_pids) -gt 0
        printf "  %sProzesse%s\n" $label $reset
        for pid in $microphone_consumer_pids
            set -l microphone_proc (ps -p $pid -o pid=,etimes=,comm=,args= 2>/dev/null)
            if test -n "$microphone_proc"
                set -l microphone_proc_parts (string match -r --groups-only '^([0-9]+)\s+([0-9]+)\s+([^ ]+)\s+(.*)$' -- "$microphone_proc")
                if test (count $microphone_proc_parts) -ge 4
                    set -l mic_pid $microphone_proc_parts[1]
                    set -l mic_etimes $microphone_proc_parts[2]
                    set -l mic_comm $microphone_proc_parts[3]
                    set -l mic_args $microphone_proc_parts[4]
                    set -l mic_runtime (__ui_info_format_duration $mic_etimes)
                    set -l mic_start unknown
                    if type -q ps
                        set mic_start (ps -p "$mic_pid" -o lstart= 2>/dev/null | string trim)
                    end
                    set -l mic_preview (string shorten -m 92 -- "$mic_args")
                    printf "    %s- %s%s%s\n" $dim $value $mic_comm $reset
                    printf "      %s%-10s%s %s\n" $dim "PID:" $reset $mic_pid
                    printf "      %s%-10s%s %s\n" $dim "Seit:" $reset $mic_start
                    printf "      %s%-10s%s %s\n" $dim "Laufzeit:" $reset $mic_runtime
                    printf "      %s%-10s%s %s\n" $dim "Cmd:" $reset $mic_preview
                else
                    printf "    %s- %s%s\n" $dim $reset $microphone_proc
                end
            end
        end
    else if test -n "$microphone_consumer_lines"
        printf "  %sKamera-/Audio-Clients%s\n" $label $reset
        for line in $microphone_consumer_lines
            printf "    %s- %s%s\n" $dim $reset $line
        end
    end

    if test (count $microphone_pipewire_lines) -gt 0
        printf "  %sPipeWire / Mikrofon%s\n" $label $reset
        for line in $microphone_pipewire_lines
            set -l mic_preview (string shorten -m 110 -- "$line")
            printf "    %s- %s%s\n" $dim $reset $mic_preview
        end
    end

    if test (count $microphone_pulse_lines) -gt 0
        printf "  %sPulse Source-Outputs%s\n" $label $reset
        for line in $microphone_pulse_lines
            printf "    %s- %s%s\n" $dim $reset $line
        end
    end

    if test (count $microphone_portal_lines) -gt 0
        printf "  %sPortal / Audio%s\n" $label $reset
        for line in $microphone_portal_lines
            printf "    %s- %s%s\n" $dim $reset $line
        end
    end

    printf "\n%sUsers%s\n" $label $reset
    if test -n "$logged_in_users"
        for line in $logged_in_users
            printf "  %s- %s%s\n" $dim $reset $line
        end
    else
        printf "  %sKeine aktiven Sitzungen gefunden%s\n" $warn $reset
    end

    printf "\n%sSessions%s\n" $label $reset
    if test -n "$login_sessions"
        for line in $login_sessions
            printf "  %s- %s%s\n" $dim $reset $line
        end
    else
        printf "  %sKeine loginctl-Sessions gefunden%s\n" $warn $reset
    end

    printf "\n%sTipp:%s Kameras kommen von /dev/video*, Fenster von wmctrl/hyprctl, Aufnahmen von ps/Dateien.\n" $dim $reset
end
