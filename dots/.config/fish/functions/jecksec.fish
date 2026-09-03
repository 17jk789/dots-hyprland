function jecksec --description "Schöne checksec-Ausgabe"

    if test (count $argv) -eq 0
        echo "Benutzung:"
        echo "  jecksec file <binary>"
        echo "  jecksec dir <directory>"
        echo "  jecksec <binary>"
        return 1
    end

    python3 ~/.config/fish/functions/checksec.py $argv

end
