function doom --description "Doom Emacs terminal launcher and CLI"
    set -l doom_bin "$HOME/.config/emacs/bin/doom"

    if test (count $argv) -gt 0
        switch $argv[1]
            case sync upgrade doctor install uninstall purge build
                command "$doom_bin" $argv
                return $status
            case --version -V --help -h
                command "$doom_bin" $argv
                return $status
        end
    end

    command emacs -nw $argv
end
