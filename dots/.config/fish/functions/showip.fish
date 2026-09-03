# ~/.config/fish/functions/showip.fish
#
function showip
    # Check if real IPs are stored
    if set -q __HIDDEN_MY_IP
        set -gx MY_IP "$__HIDDEN_MY_IP"
    else
        # Fallback: Fetch again if never saved
        set -gx MY_IP (ip route get 1 2>/dev/null | sed -n 's/.*src \([^ ]*\).*/\1/p' | string trim)
    end

    if set -q __HIDDEN_PUB_IP
        set -gx PUB_IP "$__HIDDEN_PUB_IP"
    else
        # Fallback: Fetch again if never saved
        set -gx PUB_IP (curl -fsS --max-time 5 ifconfig.me 2>/dev/null)
    end

    echo "IPs restored."
end
