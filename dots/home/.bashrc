#
# ~/.bashrc
# Nightwatch — independent Arch / BlackArch-inspired shell profile
# Bash + Starship | Catppuccin Mocha | Hyprland-friendly
#

# Non-interactive shells should stay quiet and fast.
[[ $- == *i* ]] || return

# Avoid duplicate sourcing.
[[ ${_NIGHTWATCH_BASHRC_LOADED:-0} == 1 ]] && return
export _NIGHTWATCH_BASHRC_LOADED=1

# ── Environment ──────────────────────────────────────────────────────────────
# Preserve the system PATH; prepend only user-owned locations when present.
case ":$PATH:" in
  *":$HOME/.local/bin:"*) ;;
  *) [[ -d "$HOME/.local/bin" ]] && PATH="$HOME/.local/bin:$PATH" ;;
esac
case ":$PATH:" in
  *":$HOME/bin:"*) ;;
  *) [[ -d "$HOME/bin" ]] && PATH="$HOME/bin:$PATH" ;;
esac
export PATH

# Rustup/Cargo's official environment helper, if installed.
[[ -r "$HOME/.cargo/env" ]] && . "$HOME/.cargo/env"

# User-local applications often install here.
[[ -d "$HOME/.local/share/bin" ]] && {
  case ":$PATH:" in
    *":$HOME/.local/share/bin:"*) ;;
    *) PATH="$HOME/.local/share/bin:$PATH" ;;
  esac
}
export PATH

# Prefer modern editors without assuming they are installed.
if command -v nvim >/dev/null 2>&1; then
  export EDITOR=nvim VISUAL=nvim
elif command -v vim >/dev/null 2>&1; then
  export EDITOR=vim VISUAL=vim
else
  export EDITOR=vi VISUAL=vi
fi
export PAGER="${PAGER:-less}"
export LESS="${LESS:--FRX}"

# Shell-Namen für Skripte oder Prompts festlegen
export SHELL_NAME=bash

# ── Readline / shell behavior ────────────────────────────────────────────────
set -o vi
bind 'set show-mode-in-prompt off' 2>/dev/null
bind 'set completion-ignore-case on' 2>/dev/null
bind 'set colored-stats on' 2>/dev/null
bind 'set menu-complete-display-prefix on' 2>/dev/null

shopt -s histappend checkwinsize cmdhist
shopt -s autocd cdspell no_empty_cmd_completion
shopt -s dirspell 2>/dev/null

# History: useful for interactive work; don't record obvious secrets.
HISTSIZE=20000
HISTFILESIZE=40000
HISTCONTROL=ignoreboth:erasedups
HISTTIMEFORMAT='%F %T  '
HISTIGNORE='ls:ll:la:clear:c:history:exit:pwd:..:...:....'
export HISTSIZE HISTFILESIZE HISTCONTROL HISTTIMEFORMAT HISTIGNORE
umask 077

# ── Bash completion ──────────────────────────────────────────────────────────
if [[ -r /usr/share/bash-completion/bash_completion ]] &&
   ! declare -F _completion_loader >/dev/null 2>&1; then
  . /usr/share/bash-completion/bash_completion
fi

# ── Safe, portable aliases ───────────────────────────────────────────────────
alias grep='grep --color=auto'
alias diff='diff --color=auto'
alias ip='ip -color=auto'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias c='clear'
alias h='history'
alias ports='ss -tulpen'
alias myip='ip -brief address'
alias listening='ss -lntup'

if command -v eza >/dev/null 2>&1; then
  alias ls='eza --icons=auto --group-directories-first'
  alias ll='eza -lah --icons=auto --git'
  alias la='eza -a --icons=auto --group-directories-first'
  alias lt='eza --tree --level=2 --icons=auto'
else
  alias ls='ls --color=auto'
  alias ll='ls -lah --color=auto'
  alias la='ls -A --color=auto'
fi

if command -v bat >/dev/null 2>&1; then
  alias cat='bat --paging=never'
elif command -v batcat >/dev/null 2>&1; then
  alias cat='batcat --paging=never'
fi

command -v nvim >/dev/null 2>&1 && alias vi='nvim'
command -v fdfind >/dev/null 2>&1 && ! command -v fd >/dev/null 2>&1 && alias fd='fdfind'

# ── Small quality-of-life helpers ────────────────────────────────────────────
mkcd() {
  [[ $# -eq 1 ]] || { printf 'Usage: mkcd DIRECTORY\n' >&2; return 2; }
  mkdir -p -- "$1" && cd -- "$1"
}

# Extract common archive formats into the current directory.
extract() {
  [[ $# -eq 1 && -f "$1" ]] || {
    printf 'Usage: extract ARCHIVE\n' >&2
    return 2
  }
  case "$1" in
    *.tar.bz2|*.tbz2) tar -xjf -- "$1" ;;
    *.tar.gz|*.tgz)   tar -xzf -- "$1" ;;
    *.tar.xz|*.txz)   tar -xJf -- "$1" ;;
    *.tar.zst|*.tzst) tar --zstd -xf "$1" ;;
    *.tar)            tar -xf -- "$1" ;;
    *.bz2)            bunzip2 -- "$1" ;;
    *.gz)             gunzip -- "$1" ;;
    *.xz)             unxz -- "$1" ;;
    *.zip)            unzip -- "$1" ;;
    *.7z)             7z x -- "$1" ;;
    *) printf 'extract: unsupported archive: %s\n' "$1" >&2; return 1 ;;
  esac
}

# Search text recursively; prefer ripgrep when installed.
if command -v rg >/dev/null 2>&1; then
  croot() { rg --hidden --glob '!.git' --glob '!node_modules' --glob '!vendor' "$@"; }
else
  croot() { grep -RIn --exclude-dir=.git --exclude-dir=node_modules --exclude-dir=vendor -- "$@"; }
fi

# ── FZF ──────────────────────────────────────────────────────────────────────
if command -v fzf >/dev/null 2>&1; then
  export FZF_DEFAULT_OPTS='--height=40% --layout=reverse --border=rounded --info=inline --margin=1 --padding=1'
  if command -v fd >/dev/null 2>&1; then
    export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git --exclude node_modules'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  elif command -v rg >/dev/null 2>&1; then
    export FZF_DEFAULT_COMMAND='rg --files --hidden -g !.git -g !node_modules'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  fi
  # Use the official Bash integration only when available.
  if fzf --bash >/dev/null 2>&1; then
    eval "$(fzf --bash)"
  elif [[ -r /usr/share/fzf/key-bindings.bash ]]; then
    . /usr/share/fzf/key-bindings.bash
    [[ -r /usr/share/fzf/completion.bash ]] && . /usr/share/fzf/completion.bash
  fi
fi

# ── Starship prompt ──────────────────────────────────────────────────────────
# Starship owns the prompt; do not set PS1 separately.
if command -v starship >/dev/null 2>&1; then
  export STARSHIP_CONFIG="${STARSHIP_CONFIG:-$HOME/.config/starship.toml}"
  eval "$(starship init bash)"
fi

# ── Optional tool integrations ───────────────────────────────────────────────
# Only initialize tools that are already installed.
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init bash)"
fi
if command -v direnv >/dev/null 2>&1; then
  eval "$(direnv hook bash)"
fi

# ── Small status helpers ─────────────────────────────────────────────────────
# Keep network lookups opt-in: no public-IP request or telemetry at shell startup.
shellinfo() {
  printf 'Shell:    %s\n' "${BASH_VERSION:+Bash $BASH_VERSION}"
  printf 'Kernel:   %s\n' "$(uname -sr)"
  printf 'User:     %s\n' "${USER:-unknown}"
  printf 'Host:     %s\n' "$(hostname -s 2>/dev/null || hostname)"
  printf 'Directory:%s\n' " $PWD"
  printf 'Prompt:   %s\n' "$(command -v starship >/dev/null 2>&1 && echo Starship || echo Bash default)"
}
