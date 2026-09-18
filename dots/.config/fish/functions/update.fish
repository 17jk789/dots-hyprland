function update --description "Update CachyOS or Arch Linux, AUR packages, Flatpak packages, and dots-hyperland"
    echo "=== System Update ==="
    echo ""

    # CachyOS system update
    if command -q cachy-update
        echo "CachyOS update tool detected: cachy-update"
        read -P "Run cachy-update? [y/N] " answer

        if string match -qi y $answer
            echo "Running cachy-update..."
            sudo cachy-update
        else
            echo "Skipping CachyOS update."
        end
    else
        echo "CachyOS update tool not found."
        read -P "Run the Pacman system update? [y/N] " answer

        if string match -qi y $answer
            echo "Running pacman..."
            sudo pacman -Syu
        else
            echo "Skipping Pacman update."
        end
    end

    echo ""

    # AUR update
    if command -q yay
        echo "yay detected."
        read -P "Update AUR packages with yay? [y/N] " answer

        if string match -qi y $answer
            echo "Running yay..."
            yay -Syu
        else
            echo "Skipping yay update."
        end

    else if command -q paru
        echo "paru detected."
        read -P "Update AUR packages with paru? [y/N] " answer

        if string match -qi y $answer
            echo "Running paru..."
            paru -Syu
        else
            echo "Skipping paru update."
        end

    else
        echo "Neither yay nor paru is installed."
        echo "Skipping AUR update."
    end

    echo ""

    # Flatpak update
    if command -q flatpak
        echo "Flatpak detected."
        read -P "Update Flatpak packages? [y/N] " answer

        if string match -qi y $answer
            echo "Running Flatpak update..."
            flatpak update
        else
            echo "Skipping Flatpak update."
        end
    else
        echo "Flatpak is not installed."
        echo "Skipping Flatpak update."
    end

    echo ""

    # dots-hyperland update
    set -l repo "$HOME/dots-hyperland"

    if test -d $repo
        echo "=== Updating dots-hyperland ==="
        echo "Repository: $repo"
        echo ""

        set -l current_dir $PWD

        if cd $repo
            if test -x ./setup
                read -P "Run ./setup exp-update? [y/N] " answer

                if string match -qi y $answer
                    echo "Running ./setup exp-update..."
                    ./setup exp-update
                else
                    echo "Skipping dots-hyperland update."
                end
            else
                echo "Error: ./setup was not found or is not executable."
            end

            cd $current_dir
        else
            echo "Error: Could not enter $repo"
        end
    else
        echo "dots-hyperland repository not found:"
        echo "$repo"
        echo "Skipping dots-hyperland update."
    end

    echo ""
    echo "=== Update process finished ==="
end
