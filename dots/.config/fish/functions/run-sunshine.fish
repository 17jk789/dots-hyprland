function run-sunshine
    systemctl --user enable --now sunshine.service
    and systemctl --user stop sunshine
    and sleep 2
    and systemctl --user start sunshine
end
