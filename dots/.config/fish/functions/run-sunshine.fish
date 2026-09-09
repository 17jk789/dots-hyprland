function run-sunshine --description "Enables and restarts the Sunshine service"

    systemctl --user enable --now sunshine.service
    and systemctl --user stop sunshine
    and sleep 2
    and systemctl --user start sunshine

end
