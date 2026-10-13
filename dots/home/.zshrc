#
# ~/.zshrc
# NIGHTWATCH — independent Arch / CachyOS / BlackArch-inspired Zsh
# Zsh + Starship | Catppuccin Mocha | FZF | optional Zsh plugins
#

# Interactive shells only.
[[ -o interactive ]] || return

# Guard against accidental duplicate sourcing.
[[ ${_NIGHTWATCH_ZSHRC_LOADED:-0} == 1 ]] && return
typeset -g _NIGHTWATCH_ZSHRC_LOADED=1

# ── Environment ──────────────────────────────────────────────────────────────
export SHELL_NAME=zsh
export EDITOR="${EDITOR:-nvim}"
export VISUAL="${VISUAL:-$EDITOR}"
export PAGER="${PAGER:-less -FRX}"
export LESSHISTFILE=-

# Preserve the system PATH and prepend user-local locations only when present.
typeset -U path PATH
[[ -d "$HOME/.local/bin" ]] && path=("$HOME/.local/bin" $path)
[[ -d "$HOME/bin" ]] && path=("$HOME/bin" $path)
[[ -d "$HOME/.local/share/bin" ]] && path=("$HOME/.local/share/bin" $path)
[[ -d "$HOME/.cargo/bin" ]] && path=("$HOME/.cargo/bin" $path)
export PATH

# Load Cargo's official helper when available.
[[ -r "$HOME/.cargo/env" ]] && source "$HOME/.cargo/env"

# Restrictive default permissions for newly created files.
umask 077

# ── Completion ───────────────────────────────────────────────────────────────
autoload -Uz compinit
zmodload -i zsh/complist 2>/dev/null

# Keep completion cache private; refresh periodically rather than every shell.
ZSH_COMPDUMP="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump-${ZSH_VERSION}"
mkdir -p -- "${ZSH_COMPDUMP:h}" 2>/dev/null
_compinit_args=(-d "$ZSH_COMPDUMP")
[[ -n ${ZSH_COMPDUMP_FORCE:-} ]] && _compinit_args+=(-C)
compinit "${_compinit_args[@]}"

zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format '%F{blue}── %d ──%f'
zstyle ':completion:*' use-cache yes
zstyle ':completion:*' cache-path "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompcache"
_comp_options+=(globdots)

# ── Keybindings ──────────────────────────────────────────────────────────────
# Vi mode; use KEYTIMEOUT to make mode switching responsive.
bindkey -v
export KEYTIMEOUT=1

# Reliable terminal-aware Home/End/Delete/Page keys, with common fallbacks.
zmodload -i zsh/terminfo 2>/dev/null
[[ -n ${terminfo[khome]-} ]] && bindkey "${terminfo[khome]}" beginning-of-line
[[ -n ${terminfo[kend]-} ]] && bindkey "${terminfo[kend]}" end-of-line
[[ -n ${terminfo[kdch1]-} ]] && bindkey "${terminfo[kdch1]}" delete-char
[[ -n ${terminfo[kich1]-} ]] && bindkey "${terminfo[kich1]}" overwrite-mode
[[ -n ${terminfo[kpp]-} ]] && bindkey "${terminfo[kpp]}" history-beginning-search-backward
[[ -n ${terminfo[knp]-} ]] && bindkey "${terminfo[knp]}" history-beginning-search-forward
bindkey '^[[H' beginning-of-line
bindkey '^[[F' end-of-line
bindkey '^[[3~' delete-char
bindkey '^[[5~' history-beginning-search-backward
bindkey '^[[6~' history-beginning-search-forward
bindkey '^[[1;5C' forward-word
bindkey '^[[1;5D' backward-word
bindkey '^[Oc' forward-word
bindkey '^[Od' backward-word
bindkey '^H' backward-kill-word
bindkey '^[[Z' undo

# Search through history using Up/Down, preserving the current input.
autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey '^[[A' up-line-or-beginning-search
bindkey '^[[B' down-line-or-beginning-search

# ── History ──────────────────────────────────────────────────────────────────
HISTFILE="${XDG_STATE_HOME:-$HOME/.local/state}/zsh/history"
[[ -d "${HISTFILE:h}" ]] || mkdir -p -- "${HISTFILE:h}" 2>/dev/null
HISTSIZE=30000
SAVEHIST=60000
setopt APPEND_HISTORY
setopt EXTENDED_HISTORY
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_REDUCE_BLANKS
setopt HIST_SAVE_NO_DUPS
setopt SHARE_HISTORY
setopt INC_APPEND_HISTORY
setopt INTERACTIVE_COMMENTS

# Do not persist common one-off/noisy commands. Prefix a command with a space
# to keep it out of history (HIST_IGNORE_SPACE).
HISTORY_IGNORE='(ls|ll|la|clear|c|pwd|exit|history|cd|cd ..|..|...|....)'

# ── Navigation / shell behavior ──────────────────────────────────────────────
setopt AUTO_CD
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS
setopt PUSHD_SILENT
setopt INTERACTIVE_COMMENTS
setopt NO_BEEP
setopt CORRECT
setopt LONG_LIST_JOBS

# ── Colors and portable aliases ──────────────────────────────────────────────
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

# Interactive overwrite safety for file operations.
# Use command cp/mv/rm to bypass these aliases deliberately.
alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -i'

if (( $+commands[eza] )); then
  alias ls='eza --icons=auto --group-directories-first'
  alias ll='eza -lah --icons=auto --git'
  alias la='eza -a --icons=auto --group-directories-first'
  alias tree='eza --tree --icons=auto'
  alias l='eza -lah --icons=auto --group-directories-first'
else
  alias ls='ls --color=auto'
  alias ll='ls -lah --color=auto'
  alias la='ls -A --color=auto'
  alias l='ls -lah --color=auto'
  alias tree='tree -C'
fi

if (( $+commands[bat] )); then
  alias cat='bat --paging=never'
elif (( $+commands[batcat] )); then
  alias cat='batcat --paging=never'
fi

(( $+commands[nvim] )) && alias vi='nvim'
(( $+commands[rg] )) && alias grepall='rg --hidden --glob "!.git" --glob "!node_modules"'
(( $+commands[fd] )) || { (( $+commands[fdfind] )) && alias fd='fdfind'; }

# ── Practical helpers ────────────────────────────────────────────────────────
mkcd() {
  (( $# == 1 )) || { print -u2 'Usage: mkcd DIRECTORY'; return 2; }
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
    *.zip)            command unzip -- "$1" ;;
    *.7z)             command 7z x -- "$1" ;;
    *) print -u2 "extract: unsupported archive: $1"; return 1 ;;
  esac
}

croot() {
  if (( $+commands[rg] )); then
    command rg --hidden --glob '!.git' --glob '!node_modules' --glob '!vendor' "$@"
  else
    command grep -RIn --exclude-dir=.git --exclude-dir=node_modules --exclude-dir=vendor -- "$@"
  fi
}

shellinfo() {
  print -r -- "Shell:     Zsh $ZSH_VERSION"
  print -r -- "Kernel:    $(uname -sr)"
  print -r -- "User:      ${USER:-unknown}"
  print -r -- "Host:      $(hostname -s 2>/dev/null || hostname)"
  print -r -- "Directory: $PWD"
  print -r -- "Prompt:    $([[ $+commands[starship] == 1 ]] && print Starship || print fallback)"
}

# ── FZF ──────────────────────────────────────────────────────────────────────
if (( $+commands[fzf] )); then
  export FZF_DEFAULT_OPTS='--height=40% --layout=reverse --border=rounded --info=inline --margin=1 --padding=1'
  if (( $+commands[fd] )); then
    export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git --exclude node_modules'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  elif (( $+commands[rg] )); then
    export FZF_DEFAULT_COMMAND='rg --files --hidden -g !.git -g !node_modules'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  fi
  if [[ -r /usr/share/fzf/key-bindings.zsh ]]; then
    source /usr/share/fzf/key-bindings.zsh
    [[ -r /usr/share/fzf/completion.zsh ]] && source /usr/share/fzf/completion.zsh
  elif (( $+commands[fzf] )); then
    source <(fzf --zsh)
  fi
fi

# ── Optional plugin integrations ─────────────────────────────────────────────
# Arch packages commonly install plugins under /usr/share/zsh/plugins.
# Load autosuggestions before syntax-highlighting; highlighting must be last.
for _plugin in \
  /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh \
  /usr/share/zsh/plugins/zsh-autosuggestions.zsh \
  /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh; do
  if [[ -r "$_plugin" ]]; then source "$_plugin"; break; fi
done

# ── Optional directory/environment tools ─────────────────────────────────────
(( $+commands[zoxide] )) && eval "$(zoxide init zsh)"
(( $+commands[direnv] )) && eval "$(direnv hook zsh)"

# ── Prompt ───────────────────────────────────────────────────────────────────
# Starship is the single prompt owner. The fallback works without Starship.
if (( $+commands[starship] )); then
  export STARSHIP_CONFIG="${STARSHIP_CONFIG:-$HOME/.config/starship.toml}"
  eval "$(starship init zsh)"
else
  autoload -Uz colors && colors
  setopt PROMPT_SUBST
  _nightwatch_prompt() {
    local code=$?
    local status_color='%F{green}'
    (( code != 0 )) && status_color='%F{red}'
    PROMPT=$'\n'"%F{blue}╭─%F{cyan}%n@%m %F{blue}│ %F{teal}%~ ${status_color}[${code}]%f"$'\n'"%F{blue}╰─%F{green}❯%f "
  }
  autoload -Uz add-zsh-hook
  add-zsh-hook precmd _nightwatch_prompt
fi

# Syntax highlighting must be loaded last among ZLE plugins.
for _plugin in \
  /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh \
  /usr/share/zsh/plugins/zsh-syntax-highlighting.zsh \
  /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh; do
  if [[ -r "$_plugin" ]]; then source "$_plugin"; break; fi
done
unset _plugin
