# NIGHTWATCH — fzf.fish-inspired native Zsh bindings
# Original project: https://github.com/PatrickF1/fzf.fish
# No fzf plugin required.
# ============================================================================

# Requirements:
#   zsh, fzf
# Recommended:
#   fd, bat
# Optional:
#   git, delta, atuin
#
# Add to ~/.zshrc:
#   source ~/.config/zsh/nightwatch-fzf.zsh
#
# Default bindings:
#   Ctrl+Alt+F   Search files and directories
#   Ctrl+Alt+L   Search Git log
#   Ctrl+Alt+S   Search Git status
#   Ctrl+R       Search history
#   Ctrl+Alt+P   Search processes
#   Ctrl+V       Search Zsh variables
#
# Per-command configuration:
#   FZF_DEFAULT_OPTS
#   FZF_DEFAULT_OPTS_FILE
#   fzf_directory_opts
#   fzf_git_log_opts
#   fzf_git_status_opts
#   fzf_history_opts
#   fzf_processes_opts
#   fzf_variables_opts
#
# Directory configuration:
#   fzf_fd_opts
#   fzf_preview_dir_cmd
#   fzf_preview_file_cmd
#
# Git configuration:
#   fzf_git_log_format
#   fzf_diff_highlighter
#
# ============================================================================

# Avoid duplicate initialization when sourced more than once.
if [[ ${_NIGHTWATCH_FZF_LOADED:-0} == 1 ]]; then
    return 0
fi
typeset -g _NIGHTWATCH_FZF_LOADED=1

# ============================================================================
# Defaults
# ============================================================================

: ${fzf_git_log_format:='%C(yellow)%h%C(reset) %C(green)%ad%C(reset) %s %C(blue)(%an)%C(reset)'}

if (( ! ${+parameters[fzf_fd_opts]} )); then
    typeset -ga fzf_fd_opts=(
        --hidden
        --follow
        --exclude .git
        --exclude .hg
        --exclude .svn
        --exclude node_modules
    )
fi

if (( ! ${+parameters[fzf_diff_highlighter]} )); then
    typeset -ga fzf_diff_highlighter=()
fi

: ${fzf_preview_dir_cmd:='ls -la'}
: ${fzf_preview_file_cmd:='bat --style=numbers --color=always --line-range :500'}

# ============================================================================
# Shared helpers
# ============================================================================

_nw_fzf_available() {
    (( $+commands[fzf] ))
}

_nw_fzf_require() {
    local dependency

    for dependency in "$@"; do
        if (( ! $+commands[$dependency] )); then
            zle -M "NIGHTWATCH: missing dependency: $dependency"
            return 127
        fi
    done

    return 0
}

_nw_fzf_inside_git() {
    command git rev-parse --is-inside-work-tree >/dev/null 2>&1
}

# Execute fzf with the common defaults.
# FZF_DEFAULT_OPTS and FZF_DEFAULT_OPTS_FILE are respected by fzf itself.
_nw_fzf_run() {
    command fzf \
        --height='80%' \
        --layout=reverse \
        --border \
        --cycle \
        --marker='>' \
        "$@"
}

# Add a command-specific options array at the end so user options win.
_nw_fzf_run_configured() {
    local option_name="$1"
    shift

    local -a custom_options
    if (( ${+parameters[$option_name]} )); then
        custom_options=("${(@P)option_name}")
    else
        custom_options=()
    fi

    _nw_fzf_run "$@" "${custom_options[@]}"
}

# Read a command-line word around the cursor.
# The resulting word is used as the initial fzf query.
_nw_fzf_current_word() {
    local left right

    left="${LBUFFER##* }"
    right="${RBUFFER%% *}"

    REPLY="${left}${right}"
}

# Replace the current word with selected output.
# This does not execute the resulting command.
_nw_fzf_replace_current_word() {
    local replacement="$1"
    local left right

    left="${LBUFFER%${LBUFFER##* }}"

    if [[ "$LBUFFER" == *' '* ]]; then
        left="${LBUFFER%${LBUFFER##* }}"
    else
        left=''
    fi

    if [[ "$RBUFFER" == *' '* ]]; then
        right="${RBUFFER#* }"
        right=" ${right}"
    else
        right=''
    fi

    LBUFFER="${left}${replacement}"
    RBUFFER="$right"

    zle reset-prompt
}

# Convert newline-separated output to shell-quoted arguments.
_nw_fzf_quote_lines() {
    local item
    local -a quoted

    while IFS= read -r item; do
        [[ -n "$item" ]] || continue
        quoted+=("${(q)item}")
    done

    REPLY="${(j: :)quoted}"
}

# Preview command for files/directories.
_nw_fzf_preview_path() {
    local path="$1"

    if [[ -d "$path" ]]; then
        eval "$fzf_preview_dir_cmd" -- ${(q)path} 2>/dev/null
    elif [[ -f "$path" ]]; then
        if (( $+commands[bat] )); then
            eval "$fzf_preview_file_cmd" -- ${(q)path} 2>/dev/null
        else
            command cat -- "$path" 2>/dev/null
        fi
    else
        command file -- "$path" 2>/dev/null
    fi
}

# ============================================================================
# Search Directory
# ============================================================================

_nw_fzf_search_directory() {
    _nw_fzf_require fzf || return

    local query selected
    local search_root='.'
    local preview_command

    _nw_fzf_current_word
    query="$REPLY"

    # If the current word ends in /, search inside that directory.
    if [[ "$query" == */ && -d "$query" ]]; then
        search_root="${query%/}"
        query=''
    fi

    if (( $+commands[fd] )); then
        selected="$(
            command fd \
                --type f --type d \
                "${fzf_fd_opts[@]}" \
                . "$search_root" 2>/dev/null |
            _nw_fzf_run_configured fzf_directory_opts \
                --multi \
                --prompt='directory> ' \
                --query="$query" \
                --preview='
                    if [ -d {} ]; then
                        ls -la -- {} 2>/dev/null
                    elif [ -f {} ]; then
                        if command -v bat >/dev/null 2>&1; then
                            bat --style=numbers --color=always --line-range :500 -- {} 2>/dev/null
                        else
                            cat -- {} 2>/dev/null
                        fi
                    else
                        file -- {} 2>/dev/null
                    fi
                ' \
                --preview-window='right,50%,wrap'
        )"
    else
        selected="$(
            command find "$search_root" \
                \( -name .git -o -name node_modules -o -name .hg -o -name .svn \) -prune -o \
                \( -type f -o -type d \) -print 2>/dev/null |
            command sed "s#^\./##" |
            _nw_fzf_run_configured fzf_directory_opts \
                --multi \
                --prompt='directory> ' \
                --query="$query" \
                --preview='
                    if [ -d {} ]; then
                        ls -la -- {} 2>/dev/null
                    elif [ -f {} ]; then
                        if command -v bat >/dev/null 2>&1; then
                            bat --style=numbers --color=always --line-range :500 -- {} 2>/dev/null
                        else
                            cat -- {} 2>/dev/null
                        fi
                    else
                        file -- {} 2>/dev/null
                    fi
                ' \
                --preview-window='right,50%,wrap'
        )"
    fi

    [[ -n "$selected" ]] || {
        zle reset-prompt
        return 0
    }

    local -a paths
    local item

    while IFS= read -r item; do
        [[ -n "$item" ]] || continue

        # Directories get a trailing slash, as in fzf.fish.
        if [[ -d "$item" && "$item" != */ ]]; then
            item+='/'
        fi

        paths+=("${(q)item}")
    done <<< "$selected"

    if (( ${#paths} == 1 )) &&
       [[ -z "${BUFFER//[[:space:]]/}" ]]; then
        if [[ "${paths[1]}" == */ ]]; then
            BUFFER="cd ${paths[1]}"
        else
            BUFFER="${paths[1]}"
        fi

        CURSOR=${#BUFFER}
    else
        _nw_fzf_current_word
        _nw_fzf_replace_current_word "${(j: :)paths}"
        return 0
    fi

    zle reset-prompt
}

zle -N _nw_fzf_search_directory

# ============================================================================
# Search Git Log
# ============================================================================

_nw_fzf_search_git_log() {
    _nw_fzf_require fzf git || return

    if ! _nw_fzf_inside_git; then
        zle -M 'NIGHTWATCH: not inside a Git repository'
        return 1
    fi

    local query selected hash

    _nw_fzf_current_word
    query="$REPLY"

    selected="$(
        command git log \
            --color=always \
            --format="$fzf_git_log_format" \
            --date=short |
        _nw_fzf_run_configured fzf_git_log_opts \
            --ansi \
            --multi \
            --prompt='git log> ' \
            --query="$query" \
            --preview='
                git show --color=always --stat --patch {1} 2>/dev/null |
                '"${(j: :)fzf_diff_highlighter}"'
            ' \
            --preview-window='down,60%,wrap'
    )"

    [[ -n "$selected" ]] || {
        zle reset-prompt
        return 0
    }

    local -a hashes
    while IFS= read -r hash; do
        hash="${hash%% *}"

        # Accept abbreviated or full Git commit hashes.
        if [[ "$hash" == [0-9a-fA-F]## ]]; then
            hashes+=("$hash")
        fi
    done <<< "$selected"

    if (( ${#hashes} )); then
        _nw_fzf_replace_current_word "${(j: :)hashes}"
    else
        zle reset-prompt
    fi
}

zle -N _nw_fzf_search_git_log

# ============================================================================
# Search Git Status
# ============================================================================

_nw_fzf_search_git_status() {
    _nw_fzf_require fzf git || return

    if ! _nw_fzf_inside_git; then
        zle -M 'NIGHTWATCH: not inside a Git repository'
        return 1
    fi

    local query selected line file
    local -a files

    _nw_fzf_current_word
    query="$REPLY"

    selected="$(
        command git status --short |
        _nw_fzf_run_configured fzf_git_status_opts \
            --multi \
            --prompt='git status> ' \
            --query="$query" \
            --preview='
                file=$(printf "%s\n" {} | cut -c4-)
                git diff --color=always -- "$file" 2>/dev/null
                git diff --cached --color=always -- "$file" 2>/dev/null
            ' \
            --preview-window='down,60%,wrap'
    )"

    [[ -n "$selected" ]] || {
        zle reset-prompt
        return 0
    }

    while IFS= read -r line; do
        # Remove Git status columns. Paths with spaces are preserved.
        file="${line[4,-1]}"
        [[ -n "$file" ]] && files+=("${(q)file}")
    done <<< "$selected"

    if (( ${#files} )); then
        _nw_fzf_replace_current_word "${(j: :)files}"
    else
        zle reset-prompt
    fi
}

zle -N _nw_fzf_search_git_status

# ============================================================================
# Search History
# ============================================================================

_nw_fzf_search_history() {
    _nw_fzf_require fzf || return

    local query selected

    _nw_fzf_current_word
    query="$REPLY"

    if (( $+commands[atuin] )); then
        selected="$(
            command atuin history list \
                --format='{command}' 2>/dev/null |
            _nw_fzf_run_configured fzf_history_opts \
                --scheme=history \
                --no-multi \
                --prompt='history> ' \
                --query="$query" \
                --preview='printf "%s\n" {}' \
                --preview-window='down,30%,wrap'
        )"
    else
        selected="$(
            fc -rl 1 2>/dev/null |
            command sed -E \
                's/^[[:space:]]*[0-9]+\**[[:space:]]+//' |
            _nw_fzf_run_configured fzf_history_opts \
                --scheme=history \
                --no-multi \
                --prompt='history> ' \
                --query="$query" \
                --preview='printf "%s\n" {}' \
                --preview-window='down,30%,wrap'
        )"
    fi

    if [[ -n "$selected" ]]; then
        BUFFER="$selected"
        CURSOR=${#BUFFER}
    fi

    zle reset-prompt
}

zle -N _nw_fzf_search_history

# ============================================================================
# Search Processes
# ============================================================================

_nw_fzf_search_processes() {
    _nw_fzf_require fzf || return

    local query selected pid

    _nw_fzf_current_word
    query="$REPLY"

    selected="$(
        command ps -eo pid,user,stat,%cpu,%mem,etime,args |
        _nw_fzf_run_configured fzf_processes_opts \
            --header-lines=1 \
            --multi \
            --prompt='process> ' \
            --query="$query" \
            --preview='
                pid=$(printf "%s\n" {} | awk "{print \$1}")
                ps -p "$pid" -o pid,ppid,user,stat,%cpu,%mem,lstart,etime,args
            ' \
            --preview-window='down,40%,wrap'
    )"

    [[ -n "$selected" ]] || {
        zle reset-prompt
        return 0
    }

    local -a pids
    while IFS= read -r line; do
        pid="${line##[[:space:]]#}"
        pid="${pid%%[[:space:]]*}"

        [[ "$pid" == <-> ]] && pids+=("$pid")
    done <<< "$selected"

    if (( ${#pids} )); then
        _nw_fzf_replace_current_word "${(j: :)pids}"
    else
        zle reset-prompt
    fi
}

zle -N _nw_fzf_search_processes

# ============================================================================
# Search Zsh Variables
# ============================================================================

_nw_fzf_search_variables() {
    _nw_fzf_require fzf || return

    local query selected

    _nw_fzf_current_word
    query="$REPLY"

    selected="$(
        print -rl -- ${(k)parameters} |
        command grep -vx 'history' |
        _nw_fzf_run_configured fzf_variables_opts \
            --multi \
            --prompt='variables> ' \
            --query="$query" \
            --preview='typeset -p -- {} 2>/dev/null' \
            --preview-window='right,55%,wrap'
    )"

    [[ -n "$selected" ]] || {
        zle reset-prompt
        return 0
    }

    local -a variables
    local variable

    while IFS= read -r variable; do
        [[ -n "$variable" ]] || continue
        variables+=("\$${variable}")
    done <<< "$selected"

    if (( ${#variables} )); then
        _nw_fzf_replace_current_word "${(j: :)variables}"
    else
        zle reset-prompt
    fi
}

zle -N _nw_fzf_search_variables

# ============================================================================
# Key binding configuration
# ============================================================================

_nw_fzf_remove_own_bindings() {
    local mode line key widget

    for mode in emacs viins vicmd; do
        while IFS= read -r line; do
            [[ "$line" == *'_nw_fzf_search_'* ]] || continue

            key="${line%% *}"
            widget="${line##* }"

            key="${key#\"}"
            key="${key%\"}"

            case "$widget" in
                _nw_fzf_search_*)
                    bindkey -M "$mode" -r "$key" 2>/dev/null
                    ;;
            esac
        done <<< "$(bindkey -M "$mode" 2>/dev/null)"
    done
}

_nw_fzf_configure_bindings() {
    emulate -L zsh

    local directory=$'\ef'
    local git_log=$'\el'
    local git_status=$'\es'
    local history=$'\C-r'
    local processes=$'\ep'
    local variables=$'\C-v'

    while (( $# )); do
        case "$1" in
            --directory)
                (( $# >= 2 )) || return 2
                directory="$2"
                shift 2
                ;;
            --git-log)
                (( $# >= 2 )) || return 2
                git_log="$2"
                shift 2
                ;;
            --git-status)
                (( $# >= 2 )) || return 2
                git_status="$2"
                shift 2
                ;;
            --history)
                (( $# >= 2 )) || return 2
                history="$2"
                shift 2
                ;;
            --processes)
                (( $# >= 2 )) || return 2
                processes="$2"
                shift 2
                ;;
            --variables)
                (( $# >= 2 )) || return 2
                variables="$2"
                shift 2
                ;;
            -h|--help)
                print -r -- \
                    'Usage: _nw_fzf_configure_bindings [--directory KEY] [--git-log KEY] [--git-status KEY] [--history KEY] [--processes KEY] [--variables KEY]'
                return 0
                ;;
            *)
                print -u2 -r -- "Unknown option: $1"
                return 22
                ;;
        esac
    done

    _nw_fzf_remove_own_bindings

    local mode
    for mode in emacs viins vicmd; do
        [[ -n "$directory" ]] &&
            bindkey -M "$mode" "$directory" _nw_fzf_search_directory

        [[ -n "$git_log" ]] &&
            bindkey -M "$mode" "$git_log" _nw_fzf_search_git_log

        [[ -n "$git_status" ]] &&
            bindkey -M "$mode" "$git_status" _nw_fzf_search_git_status

        [[ -n "$history" ]] &&
            bindkey -M "$mode" "$history" _nw_fzf_search_history

        [[ -n "$processes" ]] &&
            bindkey -M "$mode" "$processes" _nw_fzf_search_processes

        [[ -n "$variables" ]] &&
            bindkey -M "$mode" "$variables" _nw_fzf_search_variables
    done
}

# ============================================================================
# Initialize
# ============================================================================

if [[ -o interactive ]] && _nw_fzf_available; then
    _nw_fzf_configure_bindings
fi
