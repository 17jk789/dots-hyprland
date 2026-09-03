function lazy_navi --description "Lazily loads and runs navi cheatsheets"
    # Check if navi has already been loaded
    if not functions -q __navi_loaded
        # Optionally ensure the repository is added
        navi repo add denisidoro/cheats 2>/dev/null
        # Dummy function as a loading marker
        function __navi_loaded
        end
    end
    command navi $argv
end
