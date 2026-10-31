function ssd --description "Control SSD access modes (OFF, READ, READ_ONLY, WRITE, EXTERNAL_OFF, BLOCK, WRITE_ONLY) and manage storage access"
    sudo python3 ~/.config/fish/functions/scripts/ssd_control.py $argv
end
