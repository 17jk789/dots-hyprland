# ~/.config/fish/config.fish

# # Commands to run in interactive sessions can go here
# if status is-interactive

#     set -gx SHELL_NAME fish

#     # ---------------------------------------------------------
#     # IPs
#     # ---------------------------------------------------------

#     # IPs are hidden by default.
#     set -gx MY_IP "x.x.x.x"
#     set -gx PUB_IP "x.x.x.x"

#     # ---------------------------------------------------------
#     # Fish / Shell Settings
#     # ---------------------------------------------------------

#     # Enable Fish's Vi-style key bindings globally.
#     # This is required so features such as Autopair work correctly with Vi mode.
#     set -g fish_key_bindings fish_vi_key_bindings

#     # No greeting
#     set fish_greeting

#     # ---------------------------------------------------------
#     # Starship
#     # ---------------------------------------------------------

#     function starship_transient_prompt_func
#         starship module character
#     end

#     if test "$TERM" != linux
#         starship init fish | source
#         enable_transience
#     end

#     # ---------------------------------------------------------
#     # Aliases
#     # ---------------------------------------------------------

#     if type -q eza
#         alias ls 'eza --icons --group-directories-first'
#         alias ll 'eza -l --icons --group-directories-first'
#         alias la 'eza -a --icons --group-directories-first'
#         alias lla 'eza -laa --icons --group-directories-first'
#     end

#     # ---------------------------------------------------------
#     # Edit Commandline in NeoVim
#     # ---------------------------------------------------------

#     function edit-commandline
#         set -l tmpfile (mktemp --suffix=.fish)

#         printf '%s\n' (commandline) >$tmpfile

#         nvim $tmpfile

#         if test $status -eq 0
#             commandline -r -- (cat $tmpfile)
#             commandline -f repaint
#         end

#         rm -f -- $tmpfile
#     end

#     # ---------------------------------------------------------
#     # Key Bindings
#     # ---------------------------------------------------------

#     function fish_user_key_bindings

#         # Start Vi mode directly in Insert mode.
#         fish_vi_key_bindings insert

#         # Autopair
#         if functions -q _autopair_install
#             _autopair_install
#         end

#         # Disable Alt+L
#         # bind -M insert \el true
#         # bind -M default \el true

#         # Navigation
#         bind -M insert \ch prevd-or-backward-word
#         bind -M insert \cl nextd-or-forward-word

#         bind -M default \ch prevd-or-backward-word
#         bind -M default \cl nextd-or-forward-word

#         bind -M insert \ec 'clear; commandline -f repaint'
#         bind -M default \ec 'clear; commandline -f repaint'

#         # ls -laa
#         bind -M insert \cs "commandline -r 'ls -laa'; commandline -f execute"
#         bind -M default \cs "commandline -r 'ls -laa'; commandline -f execute"

#         # Yazi
#         bind -M insert \cy 'yazi; commandline -f repaint'
#         bind -M default \cy 'yazi; commandline -f repaint'

#         # Neovim
#         bind -M insert \cn 'nvim (pwd); commandline -f repaint'
#         bind -M default \cn 'nvim (pwd); commandline -f repaint'

#         # Lazygit
#         bind -M insert \cg 'lazygit; commandline -f repaint'
#         bind -M default \cg 'lazygit; commandline -f repaint'

#         # Lazy Navi
#         bind -M insert \ck 'lazy_navi; commandline -f repaint'
#         bind -M default \ck 'lazy_navi; commandline -f repaint'

#         # Strg + X + E: aktuelle Commandline in Neovim bearbeiten
#         bind -M default \cx\ce edit-commandline
#         bind -M insert \cx\ce edit-commandline
#     end

#     # if test "$TERM" != "linux"
#     #     alias ls 'eza --icons=auto'
#     # end

#     # if test "$TERM" = xterm-kitty
#     #     alias ssh 'kitten ssh'
#     # end

#     # set -gx EDITOR nvim
#     # set -gx VISUAL nvim
# end

# BlackArch Linux | Performance | Pentesting | Modern CLI
# Keep startup lean: no automatic network requests or tool scans.

# Commands to run in interactive sessions can go here
if status is-interactive
    status is-interactive; or return

    # Prevent duplicate initialization if this file is sourced again.
    if set -q __nightwatch_fish_loaded
        return
    end
    set -g __nightwatch_fish_loaded 1

    # =============================================================================
    # 1. ENVIRONMENT
    # =============================================================================

    set -gx SHELL_NAME fish
    set -gx EDITOR nvim
    set -gx VISUAL nvim
    set -gx SUDO_EDITOR nvim
    set -gx PAGER 'less -FRX'
    set -gx LESSHISTFILE -
    set -gx MY_IP "x.x.x.x"
    set -gx PUB_IP "x.x.x.x"

    # Avoid unnecessary greeting and startup output.
    set -g fish_greeting

    # Vi mode, initially in insert mode.
    set -g fish_key_bindings fish_vi_key_bindings
    set -g fish_cursor_default block
    set -g fish_cursor_insert line
    set -g fish_cursor_replace_one underscore

    # Allow Ctrl-S bindings by disabling terminal software flow control.
    if isatty stdin
        command stty -ixon 2>/dev/null
    end

    # =============================================================================
    # 2. PATH — prepend only existing directories, avoid duplicates
    # =============================================================================

    # Fish's fish_add_path handles duplicate entries.
    fish_add_path --prepend --path \
        "$HOME/.local/bin" \
        "$HOME/bin" \
        "$HOME/go/bin" \
        "$HOME/.cargo/bin"

    # Optional personal pentesting tools:
    # fish_add_path --prepend --path "$HOME/tools"
    # fish_add_path --prepend --path "$HOME/tools/bin"

    # =============================================================================
    # 3. MODERN CLI ALIASES
    # =============================================================================

    if type -q eza
        alias ls  'eza --icons=auto --group-directories-first'
        alias ll  'eza -lah --icons=auto --git'
        alias la  'eza -a --icons=auto --group-directories-first'
        alias lla 'eza -laa --icons=auto --group-directories-first'
        alias l   'eza -lah --icons=auto --group-directories-first'
    else
        alias ls  'command ls --color=auto'
        alias ll  'command ls -lah --color=auto'
        alias la  'command ls -A --color=auto'
        alias lla 'command ls -la --color=auto'
        alias l   'command ls -lah --color=auto'
    end

    if type -q bat
        alias cat 'bat --paging=never'
    else if type -q batcat
        alias cat 'batcat --paging=never'
    end

    alias c clear
    alias h history
    alias .. 'cd ..'
    alias ... 'cd ../..'
    alias .... 'cd ../../..'

    alias ports 'ss -lntup'
    alias listening 'ss -lntup'
    alias myip 'ip -brief address'
    alias routes 'ip route'
    alias sockets 'ss -tulpen'

    alias grep 'grep --color=auto'
    alias diff 'diff --color=auto'

    # =============================================================================
    # 4. STARSHIP PROMPT
    # =============================================================================

    function starship_transient_prompt_func
        starship module character
    end

    if test "$TERM" != linux; and type -q starship
        starship init fish | source

        # Enable only if the installed Starship integration provides it.
        if functions -q enable_transience
            enable_transience
        end
    end

    # =============================================================================
    # 5. DIRECTORY NAVIGATION
    # =============================================================================

    if type -q zoxide
        zoxide init fish | source
    end

    # =============================================================================
    # 6. FUZZY FINDER — avoid following symlinks through huge trees
    # =============================================================================

    if type -q fd
        set -gx FZF_DEFAULT_COMMAND \
            'fd --type f --hidden --exclude .git --exclude node_modules --exclude .venv --exclude vendor'
    else if type -q rg
        set -gx FZF_DEFAULT_COMMAND \
            'rg --files --hidden -g !.git -g !node_modules -g !.venv -g !vendor'
    end

    if set -q FZF_DEFAULT_COMMAND
        set -gx FZF_CTRL_T_COMMAND "$FZF_DEFAULT_COMMAND"
    end

    set -gx FZF_DEFAULT_OPTS \
        '--height=80% --layout=reverse --border=rounded --info=inline --margin=1'

    # =============================================================================
    # 7. ATUIN — shell history
    # =============================================================================
    # Atuin is initialized once per interactive shell.
    # Keep Ctrl-R available for fzf.fish when that plugin is installed.
    # Remove --disable-ctrl-r if you want Atuin to own Ctrl-R instead.

    if type -q atuin
        atuin init fish --disable-ctrl-r | source
    end

    # =============================================================================
    # 8. DIRenv — project-specific environments
    # =============================================================================

    if type -q direnv
        direnv hook fish | source
    end

    # =============================================================================
    # 9. SMALL, EXPLICIT HELPERS
    # =============================================================================

    function mkcd --description 'Create a directory and enter it'
        if test (count $argv) -ne 1
            echo 'Usage: mkcd DIRECTORY' >&2
            return 2
        end

        command mkdir -p -- "$argv[1]"; or return $status
        cd -- "$argv[1]"
    end

    function extract --description 'Extract a supported archive'
        if test (count $argv) -ne 1; or not test -f "$argv[1]"
            echo 'Usage: extract ARCHIVE' >&2
            return 2
        end

        set -l archive "$argv[1]"

        switch "$archive"
            case '*.tar.bz2' '*.tbz2'
                command tar -xjf "$archive"
            case '*.tar.gz' '*.tgz'
                command tar -xzf "$archive"
            case '*.tar.xz' '*.txz'
                command tar -xJf "$archive"
            case '*.tar.zst' '*.tzst'
                command tar --zstd -xf "$archive"
            case '*.tar'
                command tar -xf "$archive"
            case '*.bz2'
                command bunzip2 -- "$archive"
            case '*.gz'
                command gunzip -- "$archive"
            case '*.xz'
                command unxz -- "$archive"
            case '*.zip'
                command unzip "$archive"
            case '*.7z'
                command 7z x "$archive"
            case '*'
                echo "extract: unsupported archive: $archive" >&2
                return 1
        end
    end

    function croot --description 'Search text recursively, excluding common noise'
        if test (count $argv) -lt 1
            echo 'Usage: croot PATTERN [PATH ...]' >&2
            return 2
        end

        if type -q rg
            command rg --hidden \
                --glob '!.git' \
                --glob '!node_modules' \
                --glob '!.venv' \
                --glob '!vendor' \
                -- "$argv"
        else
            command grep -RIn \
                --exclude-dir=.git \
                --exclude-dir=node_modules \
                --exclude-dir=.venv \
                --exclude-dir=vendor \
                -- "$argv"
        end
    end

    function dns --description 'Run an explicit DNS query'
        if not type -q dig
            echo 'dns: install bind (dig)' >&2
            return 127
        end

        if test (count $argv) -eq 0
            echo 'Usage: dns DOMAIN [dig options]' >&2
            return 2
        end

        command dig $argv
    end

    function pubip --description 'Query public IP on explicit request'
        if not type -q curl
            echo 'pubip: curl is not installed' >&2
            return 127
        end

        command curl -fsS --max-time 5 https://api.ipify.org
        and echo
    end

    function httphead --description 'Inspect HTTP response headers'
        if not type -q curl
            echo 'httphead: curl is not installed' >&2
            return 127
        end

        if test (count $argv) -ne 1
            echo 'Usage: httphead URL' >&2
            return 2
        end

        command curl -sS -I -L --max-time 10 -- "$argv[1]"
    end

    function shellinfo --description 'Show shell and tool availability'
        echo "Shell:     "(fish --version)
        echo "Kernel:    "(uname -sr)
        echo "Directory: $PWD"

        for tool in nvim starship atuin fzf rg fd zoxide direnv
            if type -q "$tool"
                printf '%-11s%s\n' "$tool:" available
            else
                printf '%-11s%s\n' "$tool:" missing
            end
        end
    end

    # =============================================================================
    # 10. EDIT CURRENT COMMAND IN NEOVIM
    # =============================================================================

    function edit-commandline --description 'Edit current command in Neovim'
        if not type -q nvim
            echo 'edit-commandline: nvim is not installed' >&2
            return 127
        end

        set -l tmp (command mktemp --suffix=.fish); or return 1
        commandline > "$tmp"

        command nvim "$tmp"
        set -l rc $status

        if test $rc -eq 0
            set -l edited (string collect < "$tmp")
            commandline --replace -- "$edited"
        end

        command rm -f -- "$tmp"
        commandline -f repaint
        return $rc
    end

    # =============================================================================
    # 11. KEY BINDINGS
    # =============================================================================

    function fish_user_key_bindings
        # Start in insert mode; retain native Fish Vi editing.
        fish_vi_key_bindings insert

        # Atuin: history search, insert selection without execution
        if type -q atuin
            atuin init fish --disable-ctrl-r | source
        end

        # Pfeiltasten nutzen Atuins optimierte Suche
        if functions -q _atuin_bind_up
            bind -M insert up _atuin_bind_up
            bind -M default up _atuin_bind_up
        end

        # Optional autopair plugin.
        if functions -q _autopair_install
            _autopair_install
        end

        # Ctrl-H / Ctrl-L: directory history when possible, word movement otherwise.
        bind -M insert \ch prevd-or-backward-word
        bind -M insert \cl nextd-or-forward-word
        bind -M default \ch prevd-or-backward-word
        bind -M default \cl nextd-or-forward-word

        # Ctrl-Escape: clear terminal.
        bind -M insert \ec 'clear; commandline -f repaint'
        bind -M default \ec 'clear; commandline -f repaint'

        # Ctrl-S: list files in current directory.
        bind -M insert \cs 'commandline -r "ls -la"; commandline -f execute'
        bind -M default \cs 'commandline -r "ls -la"; commandline -f execute'

        # Ctrl-Y: Yazi file manager.
        if type -q yazi
            bind -M insert \cy 'yazi; commandline -f repaint'
            bind -M default \cy 'yazi; commandline -f repaint'
        end

        # Ctrl-N: open current directory in Neovim.
        if type -q nvim
            bind -M insert \cn 'nvim .; commandline -f repaint'
            bind -M default \cn 'nvim .; commandline -f repaint'
        end

        # Ctrl-G: Lazygit.
        if type -q lazygit
            bind -M insert \cg 'lazygit; commandline -f repaint'
            bind -M default \cg 'lazygit; commandline -f repaint'
        end

        # Ctrl-K: optional lazy_navi helper.
        if type -q lazy_navi
            bind -M insert \ck 'lazy_navi; commandline -f repaint'
            bind -M default \ck 'lazy_navi; commandline -f repaint'
        end

        # Ctrl-X, Ctrl-E: edit the current command line.
        if type -q nvim
            bind -M insert \cx\ce edit-commandline
            bind -M default \cx\ce edit-commandline
        end

        # Ctrl-R: let fzf.fish manage its own binding, if installed.
        if functions -q fzf_configure_bindings
            fzf_configure_bindings --history=ctrl-r
        end

    end

    # if test "$TERM" != "linux"
    #     alias ls 'eza --icons=auto'
    # end

    # if test "$TERM" = xterm-kitty
    #     alias ssh 'kitten ssh'
    # end

    # set -gx EDITOR nvim
    # set -gx VISUAL nvim
end
