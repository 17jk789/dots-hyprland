function open --description "Opens files or URLs with the default application in the background"
    xdg-open $argv >/dev/null 2>&1 &
    disown
end
