# ~/.zshrc
# NIGHTWATCH | Zsh | Arch / BlackArch
# Fast completion cache, Atuin history, fzf picker, native ZLE Vi mode.

[[ -o interactive ]] || return
[[ ${_NIGHTWATCH_ZSHRC_LOADED:-0} == 1 ]] && return
typeset -g _NIGHTWATCH_ZSHRC_LOADED=1

# ---------------------------------------------------------------------------
# Environment and PATH
# ---------------------------------------------------------------------------

export SHELL_NAME=zsh
export EDITOR="${EDITOR:-nvim}"
export VISUAL="${VISUAL:-$EDITOR}"
export PAGER="${PAGER:-less -FRX}"
export LESSHISTFILE=-
umask 077

# Keep PATH unique without removing system paths.
typeset -U path PATH

for _nw_dir in \
    "$HOME/.local/bin" \
    "$HOME/bin" \
    "$HOME/.local/share/bin" \
    "$HOME/.cargo/bin"; do
    [[ -d $_nw_dir ]] && path=("$_nw_dir" "${path[@]}")
done
unset _nw_dir

[[ -r "$HOME/.cargo/env" ]] && source "$HOME/.cargo/env"

# ---------------------------------------------------------------------------
# Completion: cache initialization for faster startup
# ---------------------------------------------------------------------------

autoload -Uz compinit
zmodload -i zsh/complist 2>/dev/null

ZSH_CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/zsh"
ZSH_COMPDUMP="$ZSH_CACHE_DIR/zcompdump-${ZSH_VERSION}"

command mkdir -p "$ZSH_CACHE_DIR" 2>/dev/null

# -C reuses the existing dump without running a full security audit every
# startup. Run NIGHTWATCH_COMPINIT_SECURE=1 zsh to force a full audit.
if [[ -r "$ZSH_COMPDUMP" &&
      ${NIGHTWATCH_COMPINIT_SECURE:-0} != 1 ]]; then
    compinit -C -d "$ZSH_COMPDUMP"
else
    compinit -d "$ZSH_COMPDUMP"
fi

zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format '%F{blue}── %d ──%f'
zstyle ':completion:*' use-cache yes
zstyle ':completion:*' cache-path "$ZSH_CACHE_DIR/zcompcache"

# Include dotfiles in completion.
_comp_options+=(globdots)

# ---------------------------------------------------------------------------
# ZLE: Vi mode and terminal navigation
# ---------------------------------------------------------------------------

bindkey -v
export KEYTIMEOUT=1

zmodload -i zsh/terminfo 2>/dev/null

[[ -n ${terminfo[khome]-} ]] &&
    bindkey "${terminfo[khome]}" beginning-of-line
[[ -n ${terminfo[kend]-} ]] &&
    bindkey "${terminfo[kend]}" end-of-line
[[ -n ${terminfo[kdch1]-} ]] &&
    bindkey "${terminfo[kdch1]}" delete-char
[[ -n ${terminfo[kich1]-} ]] &&
    bindkey "${terminfo[kich1]}" overwrite-mode

# Common terminal escape sequences.
bindkey '^[[H' beginning-of-line
bindkey '^[[F' end-of-line
bindkey '^[[3~' delete-char
bindkey '^[[Z' undo
bindkey '^?' backward-delete-char

# Ctrl+Left/Right: move by word.
bindkey '^[[1;5C' forward-word
bindkey '^[[1;5D' backward-word
bindkey '^[Oc' forward-word
bindkey '^[Od' backward-word

# Up/Down: search history by the current prefix when Atuin is absent.
# Atuin's integration is loaded below and owns these keys when installed.
autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search

bindkey -M viins '^[[A' up-line-or-beginning-search
bindkey -M viins '^[[B' down-line-or-beginning-search
bindkey -M vicmd '^[[A' up-line-or-beginning-search
bindkey -M vicmd '^[[B' down-line-or-beginning-search

# Familiar Vi motions.
bindkey -M vicmd 'w' forward-word
bindkey -M vicmd 'b' backward-word
bindkey -M vicmd 'W' forward-word
bindkey -M vicmd 'B' backward-word
bindkey -M vicmd '^A' beginning-of-line
bindkey -M vicmd '^E' end-of-line

# Cursor shape: line in insert mode, block in normal mode.
_nw_cursor_insert() { print -n -- $'\e[6 q' }
_nw_cursor_normal() { print -n -- $'\e[2 q' }

zle-line-init() {
    _nw_cursor_insert
}
zle-keymap-select() {
    if [[ $KEYMAP == vicmd || $KEYMAP == isearch || $KEYMAP == command ]]; then
        _nw_cursor_normal
    else
        _nw_cursor_insert
    fi
}
zle -N zle-line-init
zle -N zle-keymap-select

# ---------------------------------------------------------------------------
# Native Zsh history
# ---------------------------------------------------------------------------

HISTFILE="${XDG_STATE_HOME:-$HOME/.local/state}/zsh/history"
command mkdir -p "${HISTFILE:h}" 2>/dev/null

HISTSIZE=20000
SAVEHIST=40000

setopt APPEND_HISTORY
setopt EXTENDED_HISTORY
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_SAVE_NO_DUPS
setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY
setopt HIST_IGNORE_SPACE
setopt HIST_REDUCE_BLANKS
setopt INTERACTIVE_COMMENTS

# Do not save routine noise; commands prefixed with a space are ignored too.
HISTORY_IGNORE='(ls|ll|la|lla|l|clear|c|pwd|exit|history)'

# AUTO_CD and directory stack convenience.
setopt AUTO_CD
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS
setopt PUSHD_SILENT
setopt NO_BEEP
setopt LONG_LIST_JOBS

# Deliberately omit CORRECT: pentest tools, flags and target names can be
# unusual, and interactive correction can slow down or interrupt workflows.

# ---------------------------------------------------------------------------
# Aliases and CLI
# ---------------------------------------------------------------------------

alias grep='grep --color=auto'
alias diff='diff --color=auto'
alias ip='ip -color=auto'

alias c='clear'
alias r='reset'
alias h='history'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias cd..='cd ..'

alias ports='ss -tulpen'
alias listening='ss -lntup'
alias myip='ip -brief address'

alias df='df -h'
alias free='free -h'
alias du='du -h'
alias dd='dd status=progress'

# Interactive confirmation for accidental overwrites.
alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -i'

if (( $+commands[eza] )); then
    alias ls='eza --icons=auto --group-directories-first'
    alias ll='eza -lah --icons=auto --git'
    alias la='eza -a --icons=auto --group-directories-first'
    alias lla='eza -laa --icons=auto --group-directories-first'
    alias l='eza -lah --icons=auto --group-directories-first'
    alias tree='eza --tree --icons=auto'
else
    alias ls='ls --color=auto'
    alias ll='ls -lah --color=auto'
    alias la='ls -A --color=auto'
    alias lla='ls -la --color=auto'
    alias l='ls -lah --color=auto'
    (( $+commands[tree] )) && alias tree='tree -C'
fi

if (( $+commands[bat] )); then
    alias cat='bat --paging=never'
elif (( $+commands[batcat] )); then
    alias cat='batcat --paging=never'
fi

(( $+commands[nvim] )) && alias vi='nvim'

if (( ! $+commands[fd] && $+commands[fdfind] )); then
    alias fd='fdfind'
fi

if (( $+commands[rg] )); then
    alias grepall='rg --hidden --glob "!.git" --glob "!node_modules"'
fi

# ---------------------------------------------------------------------------
# Small helpers
# ---------------------------------------------------------------------------

mkcd() {
    (( $# == 1 )) || {
        print -u2 'Usage: mkcd DIRECTORY'
        return 2
    }

    command mkdir -p -- "$1" && builtin cd -- "$1"
}

extract() {
    (( $# == 1 )) && [[ -f "$1" ]] || {
        print -u2 'Usage: extract ARCHIVE'
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
            print -u2 "extract: unsupported archive: $1"
            return 1
            ;;
    esac
}

croot() {
    if (( $+commands[rg] )); then
        command rg --hidden \
            --glob '!.git' \
            --glob '!node_modules' \
            --glob '!vendor' "$@"
    else
        command grep -RIn \
            --exclude-dir=.git \
            --exclude-dir=node_modules \
            --exclude-dir=vendor -- "$@"
    fi
}

dns() {
    (( $+commands[dig] )) || {
        print -u2 'dns: install bind (dig)'
        return 127
    }
    (( $# > 0 )) || {
        print -u2 'Usage: dns DOMAIN [dig options]'
        return 2
    }
    command dig "$@"
}

pubip() {
    (( $+commands[curl] )) || {
        print -u2 'pubip: curl is not installed'
        return 127
    }
    command curl -fsS --max-time 5 https://api.ipify.org && print
}

httphead() {
    (( $+commands[curl] )) || {
        print -u2 'httphead: curl is not installed'
        return 127
    }
    (( $# == 1 )) || {
        print -u2 'Usage: httphead URL'
        return 2
    }
    command curl -sS -I -L --max-time 10 -- "$1"
}

shellinfo() {
    print -r -- "Shell:     Zsh $ZSH_VERSION"
    print -r -- "Kernel:    $(uname -sr)"
    print -r -- "Directory: $PWD"
    print -r -- "History:   $(( $+commands[atuin] )) (Atuin installed: 1=yes)"
    print -r -- "Prompt:    $(( $+commands[starship] )) (Starship installed: 1=yes)"
}

# ---------------------------------------------------------------------------
# Atuin: history search, insert selection without execution
# ---------------------------------------------------------------------------

if (( $+commands[atuin] )); then
    eval "$(atuin init zsh --disable-ctrl-r)"

    _atuin_search() {
        emulate -L zsh
        zle -I

        local output rc
        output=$(__atuin_search_cmd "$@")
        rc=$?

        zle reset-prompt
        print -rn -- "${zle_bracketed_paste[1]}" > /dev/tty 2>/dev/null

        if (( rc != 0 )); then
            [[ -n $output ]] && print -r -- "$output" > /dev/tty
            return $rc
        fi

        if [[ -n $output ]]; then
            # Remove Atuin's special accept prefix, if present.
            output="${output#__atuin_accept__:}"

            # Insert into the editable command line only.
            BUFFER="$output"
            CURSOR=$#BUFFER
        fi

        zle reset-prompt
    }

    # Explicitly bind Up/Down to Atuin's search widgets.
    if (( $+widgets[atuin-up-search-viins] )); then
        bindkey -M viins '^[[A' atuin-up-search-viins
    fi
    if (( $+widgets[atuin-up-search-vicmd] )); then
        bindkey -M vicmd '^[[A' atuin-up-search-vicmd
    fi
fi

# ---------------------------------------------------------------------------
# NIGHTWATCH fzf bindings
# ---------------------------------------------------------------------------

[[ -r "$HOME/.config/zsh/nightwatch-fzf.zsh" ]] &&
    source "$HOME/.config/zsh/nightwatch-fzf.zsh"

# ---------------------------------------------------------------------------
# Optional integrations
# ---------------------------------------------------------------------------

(( $+commands[zoxide] )) && eval "$(zoxide init zsh)"
(( $+commands[direnv] )) && eval "$(direnv hook zsh)"

if (( $+commands[starship] )); then
    export STARSHIP_CONFIG="${STARSHIP_CONFIG:-$HOME/.config/starship.toml}"
    eval "$(starship init zsh)"
fi

# ---------------------------------------------------------------------------
# Optional autosuggestions
# ---------------------------------------------------------------------------
# Load one available installation. Native Zsh suggestions are not a promise
# that all Fish/Bash inline suggestion engines will behave identically.

for _nw_plugin in \
    /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh \
    /usr/share/zsh/plugins/zsh-autosuggestions.zsh \
    /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh; do
    if [[ -r $_nw_plugin ]]; then
        source "$_nw_plugin"
        break
    fi
done

# ---------------------------------------------------------------------------
# ZLE widgets: preserve the command line while launching interactive tools
# ---------------------------------------------------------------------------

_nw_clear_widget() {
    echoti clear 2>/dev/null || printf '\e[H\e[2J'
    zle reset-prompt
}

_nw_tui_widget() {
    local app=$1
    shift

    zle -I

    if (( $+commands[$app] )); then
        print
        command "$app" "$@"
        print
    else
        print -u2 "NIGHTWATCH: $app is not installed."
    fi

    zle reset-prompt
}

_nw_list_widget()    { _nw_tui_widget ls -la }
_nw_yazi_widget()    { _nw_tui_widget yazi }
_nw_nvim_widget()    { _nw_tui_widget nvim . }
_nw_lazygit_widget() { _nw_tui_widget lazygit }
_nw_navi_widget()    { _nw_tui_widget lazy_navi }

_nw_edit_widget() {
    local tmp rc

    tmp=$(command mktemp "${TMPDIR:-/tmp}/nightwatch-zsh.XXXXXX") || return 1
    command chmod 600 "$tmp"
    print -rn -- "$BUFFER" > "$tmp"

    zle -I
    "${VISUAL:-${EDITOR:-vi}}" "$tmp"
    rc=$?

    if (( rc == 0 )); then
        BUFFER=$(<"$tmp")
        CURSOR=$#BUFFER
    fi

    command rm -f -- "$tmp"
    zle reset-prompt
    return $rc
}

zle -N _nw_clear_widget
zle -N _nw_list_widget
zle -N _nw_yazi_widget
zle -N _nw_nvim_widget
zle -N _nw_lazygit_widget
zle -N _nw_navi_widget
zle -N _nw_edit_widget

for _nw_map in viins vicmd; do
    bindkey -M "$_nw_map" '^[c' _nw_clear_widget
    bindkey -M "$_nw_map" '^H' backward-word
    bindkey -M "$_nw_map" '^L' forward-word
    bindkey -M "$_nw_map" '^S' _nw_list_widget
    bindkey -M "$_nw_map" '^Y' _nw_yazi_widget
    bindkey -M "$_nw_map" '^N' _nw_nvim_widget
    bindkey -M "$_nw_map" '^G' _nw_lazygit_widget
    bindkey -M "$_nw_map" '^K' _nw_navi_widget
    bindkey -M "$_nw_map" '^X^E' _nw_edit_widget
done
unset _nw_map

# ---------------------------------------------------------------------------
# Syntax highlighting: last optional plugin
# ---------------------------------------------------------------------------

for _nw_plugin in \
    /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh \
    /usr/share/zsh/plugins/zsh-syntax-highlighting.zsh \
    /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh; do
    if [[ -r $_nw_plugin ]]; then
        source "$_nw_plugin"
        break
    fi
done
unset _nw_plugin
