function gdb
    set -l args $argv

    set -l use_pwndbg 0
    set -l use_gef 0
    set -l use_all 0
    set -l use_cat 0
    set -l use_intel 0
    set -l use_context_config 0
    set -l has_stack_arg 0
    set -l has_code_arg 0
    set -l has_disasm_arg 0
    set -l stack_lines 30
    set -l code_lines 25
    set -l disasm_lines 25
    set -l filtered_args

    for arg in $args
        switch $arg
            case '-pwndbg' '-pwngdb'
                set use_pwndbg 1

            case '-gef'
                set use_gef 1

            case '-all'
                set use_all 1

            case '-cat'
                set use_cat 1

            case '-intel'
                set use_intel 1

            case '--stack-lines=*' '--stack_lines=*' '-stack-lines=*' '-stack_lines=*'
                set use_context_config 1
                set has_stack_arg 1
                set -l value (string replace -r -- '^--?stack[_-]?lines?=' '' $arg)
                if test "$value" = "all"
                    set stack_lines 999
                else if string match -qr -- '^[0-9]+$' "$value"
                    set stack_lines $value
                end

            case '--codelines=*' '--code_lines=*' '-codelines=*' '-code_lines=*' '-code-lines=*' '--code-lines=*'
                set use_context_config 1
                set has_code_arg 1
                set -l value (string replace -r -- '^--?code[_-]?lines?=' '' $arg)
                if test "$value" = "all"
                    set code_lines 999
                else if string match -qr -- '^[0-9]+$' "$value"
                    set code_lines $value
                end

            case '--disasm-lines=*' '--disasm_lines=*' '-disasm-lines=*' '-disasm_lines=*'
                set use_context_config 1
                set has_disasm_arg 1
                set -l value (string replace -r -- '^--?disasm[_-]?lines?=' '' $arg)
                if test "$value" = "all"
                    set disasm_lines 999
                else if string match -qr -- '^[0-9]+$' "$value"
                    set disasm_lines $value
                end

            case '*'
                set filtered_args $filtered_args $arg
        end
    end

    if test $use_gef -eq 1; and test $use_pwndbg -eq 1
        echo "Error: choose either -gef or -pwndbg"
        return 1
    end

    if test $use_all -eq 1; and test $use_intel -eq 1
        echo "Error: -all cannot be combined with -intel"
        return 1
    end

    if test $use_cat -eq 1; and test $use_gef -eq 1
        echo "Error: -cat is only supported with -pwndbg"
        return 1
    end

    if test $use_all -eq 1
        set use_cat 1
        set use_context_config 1
    end

    if test $use_gef -eq 1
        set -l gef_cmds
        set gef_cmds $gef_cmds -iex "source /usr/share/gef/gef.py"

        if test $use_all -eq 1; or test $has_disasm_arg -eq 1
            set gef_cmds $gef_cmds \
                -iex "gef config context.nb_lines_code $disasm_lines" \
                -iex "gef config context.nb_lines_code_prev $disasm_lines"
        end

        if test $use_all -eq 1; or test $use_context_config -eq 1
            set gef_cmds $gef_cmds \
                -iex "gef config context.layout 'legend regs code args source memory stack threads trace extra dereference'"

            if test $use_all -eq 1; or test $has_code_arg -eq 1
                set gef_cmds $gef_cmds -iex "gef config context.nb_lines_code $code_lines"
            end

            if test $use_all -eq 1; or test $has_stack_arg -eq 1
                set gef_cmds $gef_cmds -iex "gef config context.nb_lines_stack $stack_lines"
            end

            if test $use_all -eq 1; or test $has_disasm_arg -eq 1
                set gef_cmds $gef_cmds -iex "gef config context.nb_lines_disasm $disasm_lines"
            end

            set gef_cmds $gef_cmds \
                -iex "gef config context.grow_stack_down True" \
                -iex "gef config context.enable True" \
                -iex "gef config context.clear_screen False" \
                -iex "set pagination off" \
                -iex "set breakpoint pending on" \
                -iex "set print pretty on" \
                -iex "set print asm-demangle on" \
                -iex "set follow-fork-mode child" \
                -iex "set detach-on-fork off" \
                -iex "set disassemble-next-line on" \
                -iex "set confirm off"
        end

        command gdb $gef_cmds $filtered_args

    else if test $use_pwndbg -eq 1
        set -l pwndbg_cmds
        set pwndbg_cmds $pwndbg_cmds -iex "source /usr/share/pwndbg/gdbinit.py"

        if test $use_intel -eq 1
            set pwndbg_cmds $pwndbg_cmds -iex "set disassembly-flavor intel"
        end

        if test $use_all -eq 1; or test $use_context_config -eq 1
            set pwndbg_cmds $pwndbg_cmds \
                -iex "set pagination off" \
                -iex "set print pretty on" \
                -iex "set print asm-demangle on" \
                -iex "set breakpoint pending on" \
                -iex "set follow-fork-mode child" \
                -iex "set detach-on-fork off" \
                -iex "set disassemble-next-line on" \
                -iex "set history save on" \
                -iex "set confirm off"

            if test $use_all -eq 1; or test $has_stack_arg -eq 1
                set pwndbg_cmds $pwndbg_cmds -iex "set context-stack-lines $stack_lines"
            end

            if test $use_all -eq 1; or test $has_code_arg -eq 1
                set pwndbg_cmds $pwndbg_cmds -iex "set context-code-lines $code_lines"
            end

            if test $use_all -eq 1; or test $has_disasm_arg -eq 1
                set pwndbg_cmds $pwndbg_cmds -iex "set context-disasm-lines $disasm_lines"
            end

            set pwndbg_cmds $pwndbg_cmds -iex "set context-clear-screen off"
        end

        if test $use_cat -eq 1
            set pwndbg_cmds $pwndbg_cmds -iex "set syntax-highlight-style catppuccin_mocha"
        end

        command gdb $pwndbg_cmds $filtered_args

    else
        command gdb $filtered_args
    end
end
