# ~/.config/fish/functions/hideip.fish

function hideip
    # Save real IPs to hidden variables if they don't exist yet
    if not set -q __HIDDEN_MY_IP
        set -g __HIDDEN_MY_IP (ip route get 1 2>/dev/null | sed -n 's/.*src \([^ ]*\).*/\1/p' | string trim)
    end

    if not set -q __HIDDEN_PUB_IP
        set -g __HIDDEN_PUB_IP (curl -fsS --max-time 5 ifconfig.me 2>/dev/null)
    end

    # Set visible variables to placeholders
    set -gx MY_IP "x.x.x.x"
    set -gx PUB_IP "x.x.x.x"

    echo "IPs hidden (showing x.x.x.x)."
end
