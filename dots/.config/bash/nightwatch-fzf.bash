# ============================================================================
# NIGHTWATCH — fzf.fish-inspired native Bash bindings
# Original project: https://github.com/PatrickF1/fzf.fish
# No fzf plugin required.
# ============================================================================

# Requirements:
#   bash, fzf
# Recommended:
#   fd, bat
# Optional:
#   git, delta, atuin
#
# Add to ~/.bashrc:
#   source "$HOME/.config/bash/nightwatch-fzf.bash"
#
# Default bindings:
#   Alt+F   Search files and directories
#   Alt+L   Search Git log
#   Alt+S   Search Git status
#   Ctrl+R  Search history (Atuin when available)
#   Alt+P   Search processes
#   Ctrl+V  Search Bash variables
#
# Configuration:
#   FZF_DEFAULT_OPTS
#   FZF_DEFAULT_OPTS_FILE
#   fzf_directory_opts
#   fzf_git_log_opts
#   fzf_git_status_opts
#   fzf_history_opts
#   fzf_processes_opts
#   fzf_variables_opts
#   fzf_fd_opts
#   fzf_preview_dir_cmd
#   fzf_preview_file_cmd
#   fzf_git_log_format
#   fzf_diff_highlighter
#
# ============================================================================

# Avoid duplicate initialization.
if [[ ${_NIGHTWATCH_FZF_LOADED:-0} == 1 ]]; then
    return 0
fi
_NIGHTWATCH_FZF_LOADED=1

# ============================================================================
# Defaults
# ============================================================================

: "${fzf_git_log_format:=%C(yellow)%h%C(reset) %C(green)%ad%C(reset) %s %C(blue)(%an)%C(reset)}"
: "${fzf_preview_dir_cmd:=ls -la}"
: "${fzf_preview_file_cmd:=bat --style=numbers --color=always --line-range :500}"

if ! declare -p fzf_fd_opts &>/dev/null; then
    fzf_fd_opts=(
        --hidden
        --follow
        --exclude .git
        --exclude .hg
        --exclude .svn
        --exclude node_modules
    )
fi

if ! declare -p fzf_diff_highlighter &>/dev/null; then
    fzf_diff_highlighter=()
fi

# ============================================================================
# Shared helpers
# ============================================================================

_nw_fzf_available() {
    command -v fzf >/dev/null 2>&1
}

_nw_fzf_require() {
    local dependency

    for dependency in "$@"; do
        if ! command -v "$dependency" >/dev/null 2>&1; then
            printf '\nNIGHTWATCH: missing dependency: %s\n' \
                "$dependency" >&2
            return 127
        fi
    done

    return 0
}

_nw_fzf_inside_git() {
    command git rev-parse --is-inside-work-tree >/dev/null 2>&1
}

_nw_fzf_run() {
    command fzf \
        --height='80%' \
        --layout=reverse \
        --border \
        --cycle \
        --marker='>' \
        "$@"
}

# Add per-command options after defaults so user options take precedence.
_nw_fzf_run_configured() {
    local option_name=$1
    local declaration
    local -a custom_options=()

    shift

    if declaration=$(declare -p "$option_name" 2>/dev/null); then
        case $declaration in
            'declare -a '*|'declare -ax '*)
                eval 'custom_options=( "${'"$option_name"'[@]}" )'
                ;;
        esac
    fi

    _nw_fzf_run "$@" "${custom_options[@]}"
}

# Read the shell word around Readline's cursor.
_nw_fzf_current_word() {
    local left right

    left=${READLINE_LINE:0:READLINE_POINT}
    right=${READLINE_LINE:READLINE_POINT}

    left=${left##* }
    right=${right%% *}

    REPLY="${left}${right}"
}

# Replace the current shell word without executing the command.
_nw_fzf_replace_current_word() {
    local replacement=$1
    local left right

    left=${READLINE_LINE:0:READLINE_POINT}
    right=${READLINE_LINE:READLINE_POINT}

    if [[ $left == *' '* ]]; then
        left=${left%${left##* }}
    else
        left=''
    fi

    if [[ $right == *' '* ]]; then
        right=" ${right#* }"
    else
        right=''
    fi

    READLINE_LINE="${left}${replacement}${right}"
    READLINE_POINT=$((${#left} + ${#replacement}))
}

# Quote a filename for insertion into a shell command.
_nw_fzf_quote() {
    printf -v REPLY '%q' "$1"
}

# ============================================================================
# Search files and directories
# ============================================================================

_nw_fzf_search_directory() {
    _nw_fzf_require fzf || return

    local query selected search_root='.'
    local item
    local -a paths=()

    _nw_fzf_current_word
    query=$REPLY

    # If the current word ends in /, search inside that directory.
    if [[ $query == */ && -d $query ]]; then
        search_root=${query%/}
        query=''
    fi

    if command -v fd >/dev/null 2>&1; then
        selected=$(
            command fd \
                --type f \
                --type d \
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
        ) || return 0
    else
        selected=$(
            command find "$search_root" \
                \( \
                    -name .git -o \
                    -name node_modules -o \
                    -name .hg -o \
                    -name .svn \
                \) -prune -o \
                \( -type f -o -type d \) -print 2>/dev/null |
            command sed 's#^\./##' |
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
        ) || return 0
    fi

    [[ -n $selected ]] || return 0

    while IFS= read -r item; do
        [[ -n $item ]] || continue

        # Add a trailing slash to directories.
        if [[ -d $item && $item != */ ]]; then
            item+='/'
        fi

        printf -v item '%q' "$item"
        paths+=("$item")
    done <<< "$selected"

    if (( ${#paths[@]} == 1 )) &&
       [[ -z ${READLINE_LINE//[[:space:]]/} ]]; then
        if [[ ${paths[0]} == */ ]]; then
            READLINE_LINE="cd ${paths[0]}"
        else
            READLINE_LINE=${paths[0]}
        fi

        READLINE_POINT=${#READLINE_LINE}
    elif (( ${#paths[@]} )); then
        _nw_fzf_replace_current_word "${paths[*]}"
    fi
}

# ============================================================================
# Search Git log
# ============================================================================

_nw_fzf_search_git_log() {
    _nw_fzf_require fzf git || return

    if ! _nw_fzf_inside_git; then
        printf '\nNIGHTWATCH: not inside a Git repository\n' >&2
        return 1
    fi

    local query selected hash
    local -a hashes=()

    _nw_fzf_current_word
    query=$REPLY

    selected=$(
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
                git show --color=always --stat --patch {1} 2>/dev/null
            ' \
            --preview-window='down,60%,wrap'
    ) || return 0

    [[ -n $selected ]] || return 0

    while IFS= read -r hash; do
        hash=${hash%% *}
        [[ $hash =~ ^[0-9a-fA-F]+$ ]] && hashes+=("$hash")
    done <<< "$selected"

    if (( ${#hashes[@]} )); then
        _nw_fzf_replace_current_word "${hashes[*]}"
    fi
}

# ============================================================================
# Search Git status
# ============================================================================

_nw_fzf_search_git_status() {
    _nw_fzf_require fzf git || return

    if ! _nw_fzf_inside_git; then
        printf '\nNIGHTWATCH: not inside a Git repository\n' >&2
        return 1
    fi

    local query selected line file
    local -a files=()

    _nw_fzf_current_word
    query=$REPLY

    selected=$(
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
    ) || return 0

    [[ -n $selected ]] || return 0

    while IFS= read -r line; do
        file=${line:3}
        [[ -n $file ]] || continue

        printf -v file '%q' "$file"
        files+=("$file")
    done <<< "$selected"

    if (( ${#files[@]} )); then
        _nw_fzf_replace_current_word "${files[*]}"
    fi
}

# ============================================================================
# Search history: Atuin when available, Bash history otherwise
# ============================================================================

_nw_fzf_search_history() {
    _nw_fzf_require fzf || return

    local query selected

    _nw_fzf_current_word
    query=$REPLY

    if command -v atuin >/dev/null 2>&1; then
        selected=$(
            command atuin history list \
                --format='{command}' 2>/dev/null |
            _nw_fzf_run_configured fzf_history_opts \
                --scheme=history \
                --no-multi \
                --prompt='history> ' \
                --query="$query" \
                --preview='printf "%s\n" {}' \
                --preview-window='down,30%,wrap'
        ) || return 0
    else
        selected=$(
            builtin history |
            command sed -E \
                's/^[[:space:]]*[0-9]+\**[[:space:]]+//' |
            _nw_fzf_run_configured fzf_history_opts \
                --scheme=history \
                --no-multi \
                --prompt='history> ' \
                --query="$query" \
                --preview='printf "%s\n" {}' \
                --preview-window='down,30%,wrap'
        ) || return 0
    fi

    # Escape leaves the current command line untouched.
    [[ -n $selected ]] || return 0

    READLINE_LINE=$selected
    READLINE_POINT=${#READLINE_LINE}
}

# ============================================================================
# Search processes
# ============================================================================

_nw_fzf_search_processes() {
    _nw_fzf_require fzf || return

    local query selected line pid
    local -a pids=()

    _nw_fzf_current_word
    query=$REPLY

    selected=$(
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
    ) || return 0

    [[ -n $selected ]] || return 0

    while IFS= read -r line; do
        pid=${line#"${line%%[![:space:]]*}"}
        pid=${pid%%[[:space:]]*}

        [[ $pid =~ ^[0-9]+$ ]] && pids+=("$pid")
    done <<< "$selected"

    if (( ${#pids[@]} )); then
        _nw_fzf_replace_current_word "${pids[*]}"
    fi
}

# ============================================================================
# Search Bash variables
# ============================================================================

_nw_fzf_search_variables() {
    _nw_fzf_require fzf || return

    local query selected variable
    local -a variables=()

    _nw_fzf_current_word
    query=$REPLY

    selected=$(
        compgen -A variable |
        command grep -vx 'history' |
        _nw_fzf_run_configured fzf_variables_opts \
            --multi \
            --prompt='variables> ' \
            --query="$query" \
            --preview='declare -p -- {} 2>/dev/null' \
            --preview-window='right,55%,wrap'
    ) || return 0

    [[ -n $selected ]] || return 0

    while IFS= read -r variable; do
        [[ -n $variable ]] || continue
        variables+=("\$${variable}")
    done <<< "$selected"

    if (( ${#variables[@]} )); then
        _nw_fzf_replace_current_word "${variables[*]}"
    fi
}

# ============================================================================
# Readline binding configuration
# ============================================================================

_nw_fzf_remove_own_bindings() {
    local map line keyseq

    for map in emacs-standard vi-insertion vi-command; do
        while IFS= read -r line; do
            [[ $line == *'_nw_fzf_search_'* ]] || continue

            keyseq=${line%%:*}
            keyseq=${keyseq#\"}
            keyseq=${keyseq%\"}

            bind -m "$map" -r "$keyseq" 2>/dev/null
        done < <(bind -m "$map" -p 2>/dev/null)
    done
}

_nw_fzf_configure_bindings() {
    local directory=$'\ef'
    local git_log=$'\el'
    local git_status=$'\es'
    local history=$'\er'
    local processes=$'\ep'
    local variables=$'\C-v'
    local map

    while (( $# )); do
        case "$1" in
            --directory)
                (( $# >= 2 )) || return 2
                directory=$2
                shift 2
                ;;
            --git-log)
                (( $# >= 2 )) || return 2
                git_log=$2
                shift 2
                ;;
            --git-status)
                (( $# >= 2 )) || return 2
                git_status=$2
                shift 2
                ;;
            --history)
                (( $# >= 2 )) || return 2
                history=$2
                shift 2
                ;;
            --processes)
                (( $# >= 2 )) || return 2
                processes=$2
                shift 2
                ;;
            --variables)
                (( $# >= 2 )) || return 2
                variables=$2
                shift 2
                ;;
            -h|--help)
                printf '%s\n' \
                    'Usage: _nw_fzf_configure_bindings [--directory KEY] [--git-log KEY] [--git-status KEY] [--history KEY] [--processes KEY] [--variables KEY]'
                return 0
                ;;
            *)
                printf 'Unknown option: %s\n' "$1" >&2
                return 22
                ;;
        esac
    done

    _nw_fzf_remove_own_bindings

    for map in emacs-standard vi-insertion vi-command; do
        [[ -n $directory ]] &&
            bind -m "$map" -x "\"$directory\": _nw_fzf_search_directory" 2>/dev/null

        [[ -n $git_log ]] &&
            bind -m "$map" -x "\"$git_log\": _nw_fzf_search_git_log" 2>/dev/null

        [[ -n $git_status ]] &&
            bind -m "$map" -x "\"$git_status\": _nw_fzf_search_git_status" 2>/dev/null

        [[ -n $history ]] &&
            bind -m "$map" -x "\"$history\": _nw_fzf_search_history" 2>/dev/null

        [[ -n $processes ]] &&
            bind -m "$map" -x "\"$processes\": _nw_fzf_search_processes" 2>/dev/null

        [[ -n $variables ]] &&
            bind -m "$map" -x "\"$variables\": _nw_fzf_search_variables" 2>/dev/null
    done
}

# ============================================================================
# Initialize
# ============================================================================

if [[ $- == *i* ]] && _nw_fzf_available; then
    _nw_fzf_configure_bindings
fi
