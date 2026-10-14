# ~/.bashrc
# NIGHTWATCH | Bash | Arch / BlackArch
# Shared Atuin history, fzf picker, Readline Vi mode.

# Non-interactive shells must remain fast and quiet.
[[ $- == *i* ]] || return

# Prevent duplicate initialization.
[[ ${_NIGHTWATCH_BASHRC_LOADED:-0} == 1 ]] && return
export _NIGHTWATCH_BASHRC_LOADED=1

# ---------------------------------------------------------------------------
# Environment and PATH
# ---------------------------------------------------------------------------

_nw_prepend_path() {
    local dir=$1
    [[ -d $dir ]] || return 0

    case ":$PATH:" in
        *":$dir:"*) ;;
        *) PATH="$dir:$PATH" ;;
    esac
}

_nw_prepend_path "$HOME/.local/bin"
_nw_prepend_path "$HOME/bin"
_nw_prepend_path "$HOME/.local/share/bin"
unset -f _nw_prepend_path
export PATH

[[ -r "$HOME/.cargo/env" ]] && . "$HOME/.cargo/env"

export SHELL_NAME=bash
if command -v nvim >/dev/null 2>&1; then
    export EDITOR="${EDITOR:-nvim}"
elif command -v vim >/dev/null 2>&1; then
    export EDITOR="${EDITOR:-vim}"
else
    export EDITOR="${EDITOR:-vi}"
fi

export VISUAL="${VISUAL:-$EDITOR}"
export PAGER="${PAGER:-less -FRX}"
export LESSHISTFILE=-
umask 077

# ---------------------------------------------------------------------------
# Readline and Vi mode
# ---------------------------------------------------------------------------

set -o vi

bind 'set show-mode-in-prompt off' 2>/dev/null
bind 'set completion-ignore-case on' 2>/dev/null
bind 'set colored-stats on' 2>/dev/null
bind 'set menu-complete-display-prefix on' 2>/dev/null
bind 'set show-all-if-ambiguous on' 2>/dev/null
bind 'set completion-map-case on' 2>/dev/null

shopt -s histappend checkwinsize cmdhist no_empty_cmd_completion
shopt -s dirspell 2>/dev/null

# Native Bash history fallback. Atuin is the shared searchable database.
HISTSIZE=20000
HISTFILESIZE=40000
HISTCONTROL=ignoreboth:erasedups
HISTTIMEFORMAT='%F %T  '
HISTIGNORE='ls:ll:la:lla:l:clear:c:pwd:exit:history'
export HISTSIZE HISTFILESIZE HISTCONTROL HISTTIMEFORMAT HISTIGNORE

# Append new commands and import commands written by other Bash sessions.
# Do not read/import the entire history database at every prompt.
_nw_history_sync() {
    builtin history -a
    builtin history -n
}

_nw_cursor_insert() {
    printf '\e[6 q'
}

# Preserve an existing PROMPT_COMMAND.
PROMPT_COMMAND="_nw_cursor_insert; _nw_history_sync${PROMPT_COMMAND:+; $PROMPT_COMMAND}"

# ---------------------------------------------------------------------------
# Bash completion
# ---------------------------------------------------------------------------

if [[ -r /usr/share/bash-completion/bash_completion ]] &&
   ! declare -F _completion_loader >/dev/null 2>&1; then
    . /usr/share/bash-completion/bash_completion
fi

# ---------------------------------------------------------------------------
# Aliases and modern CLI
# ---------------------------------------------------------------------------

alias grep='grep --color=auto'
alias diff='diff --color=auto'
alias ip='ip -color=auto'

alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias c='clear'
alias h='history'
alias ports='ss -lntup'
alias listening='ss -lntup'
alias myip='ip -brief address'

if command -v eza >/dev/null 2>&1; then
    alias ls='eza --icons=auto --group-directories-first'
    alias ll='eza -lah --icons=auto --git'
    alias la='eza -a --icons=auto --group-directories-first'
    alias lla='eza -laa --icons=auto --group-directories-first'
    alias lt='eza --tree --level=2 --icons=auto'
else
    alias ls='ls --color=auto'
    alias ll='ls -lah --color=auto'
    alias la='ls -A --color=auto'
    alias lla='ls -la --color=auto'
fi

if command -v bat >/dev/null 2>&1; then
    alias cat='bat --paging=never'
elif command -v batcat >/dev/null 2>&1; then
    alias cat='batcat --paging=never'
fi

command -v nvim >/dev/null 2>&1 && alias vi='nvim'

if ! command -v fd >/dev/null 2>&1 &&
   command -v fdfind >/dev/null 2>&1; then
    alias fd='fdfind'
fi

# ---------------------------------------------------------------------------
# Small helpers
# ---------------------------------------------------------------------------

mkcd() {
    [[ $# -eq 1 ]] || {
        printf 'Usage: mkcd DIRECTORY\n' >&2
        return 2
    }

    command mkdir -p -- "$1" && builtin cd -- "$1"
}

extract() {
    [[ $# -eq 1 && -f $1 ]] || {
        printf 'Usage: extract ARCHIVE\n' >&2
        return 2
    }

    case "$1" in
        *.tar.bz2|*.tbz2) command tar -xjf "$1" ;;
        *.tar.gz|*.tgz)   command tar -xzf "$1" ;;
        *.tar.xz|*.txz)   command tar -xJf "$1" ;;
        *.tar.zst|*.tzst) command tar --zstd -xf "$1" ;;
        *.tar)            command tar -xf "$1" ;;
        *.bz2)            command bunzip2 -- "$1" ;;
        *.gz)             command gunzip -- "$1" ;;
        *.xz)             command unxz -- "$1" ;;
        *.zip)            command unzip "$1" ;;
        *.7z)             command 7z x "$1" ;;
        *)
            printf 'extract: unsupported archive: %s\n' "$1" >&2
            return 1
            ;;
    esac
}

if command -v rg >/dev/null 2>&1; then
    croot() {
        command rg --hidden \
            --glob '!.git' \
            --glob '!node_modules' \
            --glob '!vendor' "$@"
    }
else
    croot() {
        command grep -RIn \
            --exclude-dir=.git \
            --exclude-dir=node_modules \
            --exclude-dir=vendor -- "$@"
    }
fi

dns() {
    command -v dig >/dev/null 2>&1 || {
        printf 'dns: install bind (dig)\n' >&2
        return 127
    }
    [[ $# -gt 0 ]] || {
        printf 'Usage: dns DOMAIN [dig options]\n' >&2
        return 2
    }
    command dig "$@"
}

pubip() {
    command -v curl >/dev/null 2>&1 || {
        printf 'pubip: curl is not installed\n' >&2
        return 127
    }
    command curl -fsS --max-time 5 https://api.ipify.org && printf '\n'
}

httphead() {
    command -v curl >/dev/null 2>&1 || {
        printf 'httphead: curl is not installed\n' >&2
        return 127
    }
    [[ $# -eq 1 ]] || {
        printf 'Usage: httphead URL\n' >&2
        return 2
    }
    command curl -sS -I -L --max-time 10 -- "$1"
}

# ---------------------------------------------------------------------------
# Atuin: Up-arrow history search, insert without execution
# ---------------------------------------------------------------------------

if command -v atuin >/dev/null 2>&1; then
    eval "$(atuin init bash --disable-ctrl-r)"

    # Requires Atuin >= 18.10.0.
    if declare -F atuin-bind >/dev/null 2>&1; then
        for keymap in emacs vi-insertion vi-command; do
            case "$keymap" in
                emacs)        handler=atuin-up-search-emacs ;;
                vi-insertion) handler=atuin-up-search-viins ;;
                vi-command)   handler=atuin-up-search-vicmd ;;
            esac

            atuin-bind -m "$keymap" '\e[A'  "$handler"
            atuin-bind -m "$keymap" '\eOA' "$handler"
        done
    fi
fi

# ---------------------------------------------------------------------------
# NIGHTWATCH: native Bash + fzf
# ---------------------------------------------------------------------------

_nightwatch="$HOME/.config/bash/nightwatch-fzf.bash"

if [[ -r "$_nightwatch" ]]; then
    source "$_nightwatch"
else
    printf 'NIGHTWATCH: Datei nicht lesbar: %s\n' "$_nightwatch" >&2
fi
unset _nightwatch

# ---------------------------------------------------------------------------
# Prompt and optional integrations
# ---------------------------------------------------------------------------

if command -v starship >/dev/null 2>&1; then
    export STARSHIP_CONFIG="${STARSHIP_CONFIG:-$HOME/.config/starship.toml}"
    eval "$(starship init bash)"
fi

command -v zoxide >/dev/null 2>&1 &&
    eval "$(zoxide init bash)"

command -v direnv >/dev/null 2>&1 &&
    eval "$(direnv hook bash)"

# ---------------------------------------------------------------------------
# Readline widgets: retain the current line while launching a TUI
# ---------------------------------------------------------------------------

_nw_edit_line() {
    local tmp rc

    tmp=$(mktemp "${TMPDIR:-/tmp}/nightwatch-bash.XXXXXX") || return 1
    chmod 600 "$tmp"

    printf '%s' "$READLINE_LINE" > "$tmp"
    "${VISUAL:-${EDITOR:-vi}}" "$tmp"
    rc=$?

    if (( rc == 0 )); then
        READLINE_LINE=$(<"$tmp")
        READLINE_POINT=${#READLINE_LINE}
    fi

    command rm -f -- "$tmp"
    return "$rc"
}

_nw_tui() {
    local app=$1
    shift

    if command -v "$app" >/dev/null 2>&1; then
        printf '\n'
        command "$app" "$@"
        printf '\n'
    else
        printf '\nNIGHTWATCH: %s is not installed.\n' "$app" >&2
    fi
}

_nw_clear()    { printf '\e[H\e[2J'; }
_nw_list()     { command ls -la; }
_nw_yazi()     { _nw_tui yazi; }
_nw_nvim()     { _nw_tui nvim .; }
_nw_lazygit()  { _nw_tui lazygit; }
_nw_lazynavi() { _nw_tui lazy_navi; }

# Ctrl+S can require stty -ixon in the terminal.
for _nw_map in vi-insert vi-command; do
    bind -m "$_nw_map" -x '"\ec": _nw_clear' 2>/dev/null
    bind -m "$_nw_map" '"\C-h": backward-word' 2>/dev/null
    bind -m "$_nw_map" '"\C-l": forward-word' 2>/dev/null
    bind -m "$_nw_map" -x '"\C-s": _nw_list' 2>/dev/null
    bind -m "$_nw_map" -x '"\C-y": _nw_yazi' 2>/dev/null
    bind -m "$_nw_map" -x '"\C-n": _nw_nvim' 2>/dev/null
    bind -m "$_nw_map" -x '"\C-g": _nw_lazygit' 2>/dev/null
    bind -m "$_nw_map" -x '"\C-k": _nw_lazynavi' 2>/dev/null
    bind -m "$_nw_map" -x '"\C-x\C-e": _nw_edit_line' 2>/dev/null
done
unset _nw_map

shellinfo() {
    printf 'Shell:     Bash %s\n' "$BASH_VERSION"
    printf 'Kernel:    %s\n' "$(uname -sr)"
    printf 'Directory: %s\n' "$PWD"

    if command -v atuin >/dev/null 2>&1; then
        printf 'History:   Atuin\n'
    else
        printf 'History:   Bash native\n'
    fi

    if command -v starship >/dev/null 2>&1; then
        printf 'Prompt:    Starship\n'
    else
        printf 'Prompt:    Bash default\n'
    fi
}
