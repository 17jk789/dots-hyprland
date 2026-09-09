function lazy_navi --description "Lazily loads and runs navi cheatsheets"

    if not functions -q __navi_loaded
        navi repo add denisidoro/cheats 2>/dev/null
        function __navi_loaded
        end
    end

    command navi $argv

end
