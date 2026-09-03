# ~/.config/fish/config.fish

# Commands to run in interactive sessions can go here
if status is-interactive

    # ---------------------------------------------------------
    # IPs
    # ---------------------------------------------------------

    # IPs are hidden by default.
    set -gx MY_IP "x.x.x.x"
    set -gx PUB_IP "x.x.x.x"

    # ---------------------------------------------------------
    # Fish / Shell Settings
    # ---------------------------------------------------------

    # Enable Fish's Vi-style key bindings globally.
    # This is required so features such as Autopair work correctly with Vi mode.
    set -g fish_key_bindings fish_vi_key_bindings

    # No greeting
    set fish_greeting

    # ---------------------------------------------------------
    # Starship
    # ---------------------------------------------------------

    function starship_transient_prompt_func
        starship module character
    end

    if test "$TERM" != linux
        starship init fish | source
        enable_transience
    end

    # ---------------------------------------------------------
    # Aliases
    # ---------------------------------------------------------

    if type -q eza
        alias ls 'eza --icons --group-directories-first'
        alias ll 'eza -l --icons --group-directories-first'
        alias la 'eza -a --icons --group-directories-first'
        alias lla 'eza -laa --icons --group-directories-first'
    end

    # ---------------------------------------------------------
    # Edit Commandline in NeoVim
    # ---------------------------------------------------------

    function edit-commandline
        set -l tmpfile (mktemp --suffix=.fish)

        printf '%s\n' (commandline) >$tmpfile

        nvim $tmpfile

        if test $status -eq 0
            commandline -r -- (cat $tmpfile)
            commandline -f repaint
        end

        rm -f -- $tmpfile
    end

    # ---------------------------------------------------------
    # Key Bindings
    # ---------------------------------------------------------

    function fish_user_key_bindings

        # Start Vi mode directly in Insert mode.
        fish_vi_key_bindings insert

        # Autopair
        if functions -q _autopair_install
            _autopair_install
        end

        # Disable Alt+L
        # bind -M insert \el true
        # bind -M default \el true

        # Navigation
        bind -M insert \ch prevd-or-backward-word
        bind -M insert \cl nextd-or-forward-word

        bind -M default \ch prevd-or-backward-word
        bind -M default \cl nextd-or-forward-word

        bind -M insert \ec 'clear; commandline -f repaint'
        bind -M default \ec 'clear; commandline -f repaint'

        # ls -laa
        bind -M insert \cs "commandline -r 'ls -laa'; commandline -f execute"
        bind -M default \cs "commandline -r 'ls -laa'; commandline -f execute"

        # Yazi
        bind -M insert \cy 'yazi; commandline -f repaint'
        bind -M default \cy 'yazi; commandline -f repaint'

        # Neovim
        bind -M insert \cn 'nvim (pwd); commandline -f repaint'
        bind -M default \cn 'nvim (pwd); commandline -f repaint'

        # Lazygit
        bind -M insert \cg 'lazygit; commandline -f repaint'
        bind -M default \cg 'lazygit; commandline -f repaint'

        # Lazy Navi
        bind -M insert \ck 'lazy_navi; commandline -f repaint'
        bind -M default \ck 'lazy_navi; commandline -f repaint'

        # Strg + X + E: aktuelle Commandline in Neovim bearbeiten
        bind -M default \cx\ce edit-commandline
        bind -M insert \cx\ce edit-commandline
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
