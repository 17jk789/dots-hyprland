function yazi-cd --description "Opens Yazi and changes directory to the selected folder upon exit"
    set -l tmp_file (mktemp -t "yazi-cwd.XXXXXX")

    yazi $argv --cwd-file="$tmp_file"

    if set -l cwd (command cat -- "$tmp_file")
        and test -n "$cwd"
        and test "$cwd" != "$PWD"
        builtin cd -- "$cwd"
    end

    rm -f -- "$tmp_file"
end
