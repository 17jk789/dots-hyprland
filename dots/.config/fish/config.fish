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


# # Commands to run in interactive sessions can go here
if status is-interactive
    status is-interactive; or return

    # ---------------------------------------------------------------------------
    # Environment
    # ---------------------------------------------------------------------------

    set -gx SHELL_NAME fish
    set -gx EDITOR nvim
    set -gx VISUAL nvim
    set -gx PAGER 'less -FRX'
    set -gx LESSHISTFILE -

    set -g fish_greeting
    set -g fish_key_bindings fish_vi_key_bindings
    set -g fish_cursor_default block
    set -g fish_cursor_insert line
    set -g fish_cursor_replace underscore

    # Disable terminal flow control so Ctrl-S can work as a key binding.
    if isatty stdin
        command stty -ixon 2>/dev/null
    end

    # ---------------------------------------------------------------------------
    # Shared history: Atuin
    # ---------------------------------------------------------------------------
    # Atuin records commands through its shell hooks. Never import its full
    # database on every prompt; that creates avoidable subprocess overhead.
    # Atuin owns Up; our fzf widget owns Ctrl-R.

    if type -q atuin
        atuin init fish --disable-ctrl-r | source
    end

    # ---------------------------------------------------------------------------
    # Prompt: Starship
    # ---------------------------------------------------------------------------

    function starship_transient_prompt_func
        starship module character
    end

    if test "$TERM" != linux; and type -q starship
        starship init fish | source

        if functions -q enable_transience
            enable_transience
        end
    end

    # ---------------------------------------------------------------------------
    # Modern CLI
    # ---------------------------------------------------------------------------

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
    alias grep 'grep --color=auto'
    alias diff 'diff --color=auto'

    # Optional modern directory navigation.
    if type -q zoxide
        zoxide init fish | source
    end

    # ---------------------------------------------------------------------------
    # fzf defaults: file search only, never global history imports
    # ---------------------------------------------------------------------------

    if type -q fd
        set -gx FZF_DEFAULT_COMMAND \
            'fd --type f --hidden --follow --exclude .git --exclude node_modules'
    else if type -q rg
        set -gx FZF_DEFAULT_COMMAND \
            'rg --files --hidden -g !.git -g !node_modules'
    end

    if set -q FZF_DEFAULT_COMMAND
        set -gx FZF_CTRL_T_COMMAND $FZF_DEFAULT_COMMAND
    end

    set -gx FZF_DEFAULT_OPTS \
        '--height=80% --layout=reverse-list --border=rounded --info=inline --margin=1 --padding=1'

    # ---------------------------------------------------------------------------
    # History picker: current Atuin database -> fzf -> editable command line
    # ---------------------------------------------------------------------------

    function _nightwatch_fzf_history --description 'Search shared shell history'
        if not type -q fzf
            echo 'NIGHTWATCH: fzf is not installed.' >&2
            return 127
        end

        if type -q atuin
            set -l selected (
                command atuin history list --cmd-only --reverse=true 2>/dev/null |
                    command fzf \
                        --scheme=history \
                        --no-multi \
                        --layout=reverse-list \
                        --height=80% \
                        --border=rounded \
                        --border-label=' Shared History ' \
                        --prompt='history> ' \
                        --pointer='>' \
                        --query=(commandline)
            )

            # Cancellation leaves the current command line untouched.
            if test $status -eq 0; and test -n "$selected"
                commandline --replace -- "$selected"
            end
        else
            set -l selected (
                builtin history |
                    command fzf \
                        --scheme=history \
                        --no-multi \
                        --layout=reverse-list \
                        --height=80% \
                        --border=rounded \
                        --prompt='history> ' \
                        --query=(commandline)
            )

            if test $status -eq 0; and test -n "$selected"
                commandline --replace -- "$selected"
            end
        end

        commandline -f repaint
    end

    # ---------------------------------------------------------------------------
    # Small, explicit helpers
    # ---------------------------------------------------------------------------

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

        switch "$argv[1]"
            case '*.tar.bz2' '*.tbz2'
                command tar -xjf "$argv[1]"
            case '*.tar.gz' '*.tgz'
                command tar -xzf "$argv[1]"
            case '*.tar.xz' '*.txz'
                command tar -xJf "$argv[1]"
            case '*.tar.zst' '*.tzst'
                command tar --zstd -xf "$argv[1]"
            case '*.tar'
                command tar -xf "$argv[1]"
            case '*.bz2'
                command bunzip2 -- "$argv[1]"
            case '*.gz'
                command gunzip -- "$argv[1]"
            case '*.xz'
                command unxz -- "$argv[1]"
            case '*.zip'
                command unzip "$argv[1]"
            case '*.7z'
                command 7z x "$argv[1]"
            case '*'
                echo "extract: unsupported archive: $argv[1]" >&2
                return 1
        end
    end

    function croot --description 'Search project files'
        if type -q rg
            command rg --hidden \
                --glob '!.git' \
                --glob '!node_modules' \
                --glob '!vendor' $argv
        else
            command grep -RIn \
                --exclude-dir=.git \
                --exclude-dir=node_modules \
                --exclude-dir=vendor -- $argv
        end
    end

    function dns --description 'Perform an explicit DNS query'
        type -q dig; or begin
            echo 'dns: install bind (dig)' >&2
            return 127
        end

        test (count $argv) -gt 0; or begin
            echo 'Usage: dns DOMAIN [dig options]' >&2
            return 2
        end

        command dig $argv
    end

    function pubip --description 'Query public IP on explicit request'
        type -q curl; or begin
            echo 'pubip: curl is not installed' >&2
            return 127
        end

        command curl -fsS --max-time 5 https://api.ipify.org
        and echo
    end

    function httphead --description 'Inspect HTTP response headers'
        type -q curl; or begin
            echo 'httphead: curl is not installed' >&2
            return 127
        end

        test (count $argv) -eq 1; or begin
            echo 'Usage: httphead URL' >&2
            return 2
        end

        command curl -sS -I -L --max-time 10 -- "$argv[1]"
    end

    function shellinfo --description 'Show shell environment'
        echo "Shell:     "(fish --version)
        echo "Kernel:    "(uname -sr)
        echo "Directory: $PWD"

        if type -q atuin
            echo 'History:   Atuin'
        else
            echo 'History:   Fish native'
        end

        if type -q starship
            echo 'Prompt:    Starship'
        else
            echo 'Prompt:    Fish default'
        end
    end

    function edit-commandline --description 'Edit current command in Neovim'
        type -q nvim; or begin
            echo 'nvim is not installed.' >&2
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

    # ---------------------------------------------------------------------------
    # Key bindings
    # ---------------------------------------------------------------------------

    function fish_user_key_bindings
        # Start in insert mode; retain native Fish Vi editing.
        fish_vi_key_bindings insert

        # Atuin owns Up/Down when its widget is available.
        if functions -q _atuin_bind_up
            bind -M insert up _atuin_bind_up
            bind -M default up _atuin_bind_up
        end

        # Our custom shared-history picker owns Ctrl-R.
        bind -M insert \cr _nightwatch_fzf_history
        bind -M default \cr _nightwatch_fzf_history

        # Optional autopair plugin.
        if functions -q _autopair_install
            _autopair_install
        end

        # Word navigation.
        bind -M insert \ch prevd-or-backward-word
        bind -M insert \cl nextd-or-forward-word
        bind -M default \ch prevd-or-backward-word
        bind -M default \cl nextd-or-forward-word

        # Clear terminal.
        bind -M insert \ec 'clear; commandline -f repaint'
        bind -M default \ec 'clear; commandline -f repaint'

        # Useful interactive tools.
        bind -M insert \cs 'commandline -r "ls -la"; commandline -f execute'
        bind -M default \cs 'commandline -r "ls -la"; commandline -f execute'

        bind -M insert \cy 'yazi; commandline -f repaint'
        bind -M default \cy 'yazi; commandline -f repaint'

        bind -M insert \cn 'nvim .; commandline -f repaint'
        bind -M default \cn 'nvim .; commandline -f repaint'

        bind -M insert \cg 'lazygit; commandline -f repaint'
        bind -M default \cg 'lazygit; commandline -f repaint'

        bind -M insert \ck 'lazy_navi; commandline -f repaint'
        bind -M default \ck 'lazy_navi; commandline -f repaint'

        # Ctrl-X, Ctrl-E: edit current command in Neovim.
        bind -M insert \cx\ce edit-commandline
        bind -M default \cx\ce edit-commandline
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
