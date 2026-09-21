function set-jk-settings-stable --description "Configures the stable JK illogical-impulse settings for Hyprland"

    set -l config "$HOME/.config/illogical-impulse/config.json"

    mkdir -p (dirname "$config")

    set -l json (string collect -- '
{
    "ai": {
        "extraModels": [
        ],
        "systemPrompt": "",
        "tool": "functions"
    },
    "appearance": {
        "extraBackgroundTint": false,
        "fakeScreenRounding": 0,
        "fonts": {
            "expressive": "Space Grotesk",
            "iconNerd": "JetBrains Mono NF",
            "main": "Google Sans Flex",
            "monospace": "JetBrains Mono NF",
            "numbers": "Google Sans Flex",
            "reading": "Readex Pro",
            "title": "Google Sans Flex"
        },
        "palette": {
            "accentColor": "",
            "type": "auto"
        },
        "transparency": {
            "automatic": false,
            "backgroundTransparency": 0,
            "contentTransparency": 0,
            "enable": false
        },
        "wallpaperTheming": {
            "enableAppsAndShell": false,
            "enableQtApps": false,
            "enableTerminal": false,
            "terminalGenerationProps": {
                "forceDarkMode": true,
                "harmonizeThreshold": 100,
                "harmony": 0.6,
                "termFgBoost": 0.35
            }
        }
    },
    "apps": {
        "bluetooth": "kcmshell6 kcm_bluetooth",
        "changePassword": "kitty -1 --hold=yes fish -i -c 'passwd'",
        "manageUser": "kcmshell6 kcm_users",
        "network": "kcmshell6 kcm_networkmanagement",
        "networkEthernet": "kcmshell6 kcm_networkmanagement",
        "taskManager": "plasma-systemmonitor --page-name Processes",
        "terminal": "kitty -1",
        "update": "kitty -1 --hold=yes fish -i -c 'pkexec pacman -Syu'",
        "volumeMixer": "~/.config/hypr/hyprland/scripts/launch_first_available.sh \"pavucontrol-qt\" \"pavucontrol\""
    },
    "audio": {
        "protection": {
            "enable": true,
            "maxAllowed": 99,
            "maxAllowedIncrease": 10
        }
    },
    "background": {
        "hideWhenFullscreen": true,
        "parallax": {
            "autoVertical": false,
            "enableSidebar": false,
            "enableWorkspace": false,
            "vertical": false,
            "widgetsFactor": 1,
            "workspaceZoom": 1
        },
        "thumbnailPath": "",
        "wallpaperPath": "/home/jk/Pictures/image.jpg",
        "widgets": {
            "clock": {
                "cookie": {
                    "aiStyling": false,
                    "constantlyRotate": false,
                    "dateInClock": true,
                    "dateStyle": "bubble",
                    "dialNumberStyle": "full",
                    "hourHandStyle": "fill",
                    "hourMarks": false,
                    "minuteHandStyle": "medium",
                    "secondHandStyle": "dot",
                    "sides": 14,
                    "timeIndicators": true,
                    "useSineCookie": false
                },
                "digital": {
                    "adaptiveAlignment": false,
                    "animateChange": false,
                    "font": {
                        "family": "Google Sans Flex",
                        "roundness": 0,
                        "size": 132.87483496335517,
                        "weight": 389.88893592746103,
                        "width": 103.78497292418773
                    },
                    "showDate": false,
                    "vertical": false
                },
                "enable": false,
                "placementStrategy": "leastBusy",
                "quote": {
                    "enable": false,
                    "text": "JK-Arch"
                },
                "showOnlyWhenLocked": false,
                "style": "digital",
                "styleLocked": "digital",
                "x": 1016,
                "y": 240
            },
            "weather": {
                "enable": false,
                "placementStrategy": "free",
                "x": 400,
                "y": 100
            }
        }
    },
    "bar": {
        "autoHide": {
            "enable": false,
            "hoverRegionWidth": 2,
            "pushWindows": false,
            "showWhenPressingSuper": {
                "delay": 140,
                "enable": true
            }
        },
        "borderless": false,
        "bottom": false,
        "cornerStyle": 0,
        "floatStyleShadow": false,
        "indicators": {
            "notifications": {
                "showUnreadCount": true
            }
        },
        "resources": {
            "alwaysShowCpu": true,
            "alwaysShowSwap": true,
            "cpuWarningThreshold": 90,
            "memoryWarningThreshold": 95,
            "swapWarningThreshold": 85
        },
        "screenList": [
        ],
        "showBackground": true,
        "tooltips": {
            "clickToShow": false
        },
        "topLeftIcon": "spark",
        "utilButtons": {
            "showColorPicker": false,
            "showDarkModeToggle": false,
            "showKeyboardToggle": false,
            "showMicToggle": false,
            "showPerformanceProfileToggle": false,
            "showScreenRecord": false,
            "showScreenSnip": false
        },
        "verbose": false,
        "vertical": false,
        "weather": {
            "city": "basel",
            "enable": false,
            "enableGPS": false,
            "fetchInterval": 10,
            "useUSCS": false
        },
        "workspaces": {
            "alwaysShowNumbers": false,
            "monochromeIcons": false,
            "numberMap": [
            ],
            "showAppIcons": false,
            "showNumberDelay": 300,
            "shown": 10,
            "useNerdFont": false
        }
    },
    "battery": {
        "automaticSuspend": true,
        "critical": 5,
        "full": 101,
        "low": 20,
        "suspend": 3
    },
    "calendar": {
        "locale": "en-GB"
    },
    "cheatsheet": {
        "fontSize": {
            "comment": 12,
            "key": 12
        },
        "splitButtons": false,
        "superKey": "󰣇",
        "useFnSymbol": false,
        "useMacSymbol": false,
        "useMouseSymbol": false
    },
    "conflictKiller": {
        "autoKillNotificationDaemons": false,
        "autoKillTrays": false
    },
    "crosshair": {
        "code": "0;P;d;1;0l;10;0o;2;1b;0"
    },
    "dock": {
        "enable": false,
        "height": 60,
        "hoverRegionHeight": 2,
        "hoverToReveal": false,
        "ignoredAppRegexes": [
        ],
        "monochromeIcons": true,
        "pinnedApps": [
            "org.kde.dolphin",
            "kdesystemsettings",
            "firefox",
            "firefox-developer-edition",
            "brave-browser",
            "librewolf",
            "mullvad browser",
            "mullvad-vpn",
            "kitty",
            "alacritty",
            "com.mitchellh.ghostty",
            "code",
            "jetbrains-idea",
            "jetbrains-clion",
            "ghidra-ghidra",
            "gitkraken",
            "vesktop",
            "signal",
            "org.wireshark.wireshark",
            "blender",
            "qemu-system-x86_64",
            "de.haeckerfelix.shortwave"
        ],
        "pinnedOnStartup": false
    },
    "hacks": {
        "arbitraryRaceConditionDelay": 20
    },
    "interactions": {
        "deadPixelWorkaround": {
            "enable": false
        },
        "scrolling": {
            "fasterTouchpadScroll": false,
            "mouseScrollDeltaThreshold": 120,
            "mouseScrollFactor": 120,
            "touchpadScrollFactor": 450
        }
    },
    "language": {
        "translator": {
            "engine": "auto",
            "sourceLanguage": "auto",
            "targetLanguage": "auto"
        },
        "ui": "en_US"
    },
    "launcher": {
        "pinnedApps": [
            "org.kde.dolphin",
            "kitty",
            "cmake-gui",
            "vim",
            "nvim",
            "org.gnome.Maps",
            "blender",
            "Alacritty",
            "brave-browser",
            "firefox",
            "ghidra",
            "gitkraken",
            "code",
            "vesktop",
            "signal",
            "org.wireshark.Wireshark",
            "gimp",
            "org.kde.gwenview",
            "org.gnome.Calculator",
            "yazi",
            "systemsettings",
            "virt-manager",
            "com.mitchellh.ghostty",
            "dev.noctalia.Noctalia",
            "org.kde.konsole",
            "foot-server",
            "htop",
            "cups",
            "com.shellyorg.shelly",
            "org.kde.plasma-systemmonitor",
            "com.saivert.pwvucontrol",
            "nwg-displays",
            "jetbrains-clion-f135d4e6-0ed5-4bd9-82f8-210175edfc9d",
            "firefox-developer-edition",
            "jetbrains-toolbox",
            "org.kde.kdeconnect.app",
            "org.kde.kate",
            "org.kde.krdc",
            "libreoffice-startcenter"
        ]
    },
    "light": {
        "antiFlashbang": {
            "enable": false
        },
        "night": {
            "automatic": true,
            "colorTemperature": 3628,
            "from": "19:00",
            "to": "06:30"
        }
    },
    "lock": {
        "blur": {
            "enable": false,
            "extraZoom": 1.1,
            "radius": 100
        },
        "centerClock": false,
        "launchOnStartup": false,
        "materialShapeChars": false,
        "security": {
            "requirePasswordToPower": true,
            "unlockKeyring": false
        },
        "showLockedText": false,
        "useHyprlock": false
    },
    "media": {
        "filterDuplicatePlayers": true
    },
    "musicRecognition": {
        "interval": 4,
        "timeout": 16
    },
    "networking": {
        "userAgent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36"
    },
    "notifications": {
        "monitor": {
            "enable": false,
            "name": ""
        },
        "timeout": 7000
    },
    "osd": {
        "timeout": 1000
    },
    "osk": {
        "layout": "qwerty_full",
        "pinnedOnStartup": false
    },
    "overlay": {
        "clickthroughOpacity": 0.8,
        "darkenScreen": false,
        "floatingImage": {
            "imageSource": "",
            "scale": 0.4
        },
        "openingZoomAnimation": false
    },
    "overview": {
        "centerIcons": true,
        "columns": 5,
        "enable": true,
        "orderBottomUp": false,
        "orderRightLeft": false,
        "rows": 4,
        "scale": 0.19
    },
    "panelFamily": "ii",
    "policies": {
        "ai": 0,
        "weeb": 0
    },
    "regionSelector": {
        "annotation": {
            "useSatty": false
        },
        "circle": {
            "padding": 10,
            "strokeWidth": 6
        },
        "rect": {
            "showAimLines": true
        },
        "targetRegions": {
            "content": true,
            "contentRegionOpacity": 0.8,
            "layers": true,
            "opacity": 0.3,
            "selectionPadding": 5,
            "showLabel": false,
            "windows": true
        }
    },
    "resources": {
        "historyLength": 60,
        "updateInterval": 3000
    },
    "screenRecord": {
        "savePath": "/home/jk/Videos"
    },
    "screenSnip": {
        "savePath": ""
    },
    "search": {
        "engineBaseUrl": "https://www.google.com/search?q=",
        "excludedSites": [
        ],
        "imageSearch": {
            "imageSearchEngineBaseUrl": "https://lens.google.com/uploadbyurl?url=",
            "useCircleSelection": false
        },
        "nonAppResultDelay": 30,
        "prefix": {
            "action": "/",
            "app": ">",
            "clipboard": ";",
            "emojis": ":",
            "math": "=",
            "shellCommand": "$",
            "showDefaultActionsWithoutPrefix": true,
            "webSearch": "?"
        },
        "sloppy": true
    },
    "sidebar": {
        "ai": {
            "textFadeIn": false
        },
        "booru": {
            "allowNsfw": false,
            "defaultProvider": "yandere",
            "limit": 20,
            "zerochan": {
                "username": "[unset]"
            }
        },
        "cornerOpen": {
            "bottom": false,
            "clickless": false,
            "clicklessCornerEnd": false,
            "clicklessCornerVerticalOffset": 1,
            "cornerRegionHeight": 5,
            "cornerRegionWidth": 250,
            "enable": false,
            "valueScroll": false,
            "visualize": false
        },
        "keepRightSidebarLoaded": false,
        "quickSliders": {
            "enable": false,
            "showBrightness": true,
            "showMic": true,
            "showVolume": true
        },
        "quickToggles": {
            "android": {
                "columns": 6,
                "toggles": [
                    {
                        "size": 2,
                        "type": "network"
                    },
                    {
                        "size": 2,
                        "type": "bluetooth"
                    },
                    {
                        "size": 2,
                        "type": "idleInhibitor"
                    },
                    {
                        "size": 2,
                        "type": "audio"
                    },
                    {
                        "size": 2,
                        "type": "mic"
                    },
                    {
                        "size": 2,
                        "type": "nightLight"
                    },
                    {
                        "size": 2,
                        "type": "cloudflareWarp"
                    },
                    {
                        "size": 1,
                        "type": "notifications"
                    },
                    {
                        "size": 1,
                        "type": "gameMode"
                    },
                    {
                        "size": 1,
                        "type": "easyEffects"
                    },
                    {
                        "size": 1,
                        "type": "darkMode"
                    }
                ]
            },
            "style": "android"
        },
        "translator": {
            "delay": 300,
            "enable": false
        }
    },
    "sounds": {
        "battery": false,
        "pomodoro": false,
        "theme": "freedesktop"
    },
    "time": {
        "dateFormat": "ddd, dd/MM",
        "dateWithYearFormat": "dd/MM/yyyy",
        "format": "hh:mm",
        "pomodoro": {
            "breakTime": 300,
            "cyclesBeforeLongBreak": 4,
            "focus": 1500,
            "longBreak": 900
        },
        "secondPrecision": false,
        "shortDateFormat": "dd/MM"
    },
    "tray": {
        "filterPassive": true,
        "invertPinnedItems": false,
        "monochromeIcons": true,
        "pinnedItems": [
            "Fcitx",
            "mbsyC3QNnb",
            "chrome_status_icon_1",
            "qd3Flq-OX1",
            "hp-systray"
        ],
        "showItemId": false
    },
    "updates": {
        "adviseUpdateThreshold": 75,
        "checkInterval": 120,
        "enableCheck": false,
        "stronglyAdviseUpdateThreshold": 200
    },
    "waffles": {
        "actionCenter": {
            "toggles": [
                "network",
                "bluetooth",
                "powerProfile",
                "idleInhibitor",
                "nightLight",
                "darkMode",
                "mic",
                "notifications"
            ]
        },
        "bar": {
            "bottom": true,
            "leftAlignApps": false
        },
        "calendar": {
            "force2CharDayOfWeek": true
        },
        "tweaks": {
            "smootherMenuAnimations": false,
            "smootherSearchBar": false,
            "switchHandlePositionFix": true
        }
    },
    "wallpaperSelector": {
        "useSystemFileDialog": false
    },
    "windows": {
        "centerTitle": true,
        "showTitlebar": true
    },
    "workSafety": {
        "enable": {
            "clipboard": false,
            "wallpaper": false
        },
        "triggerCondition": {
            "fileKeywords": [
                "anime",
                "booru",
                "ecchi",
                "hentai",
                "yande.re",
                "konachan",
                "breast",
                "nipples",
                "pussy",
                "nsfw",
                "spoiler",
                "girl"
            ],
            "linkKeywords": [
                "hentai",
                "porn",
                "sukebei",
                "hitomi.la",
                "rule34",
                "gelbooru",
                "fanbox",
                "dlsite"
            ],
            "networkNameKeywords": [
                "airport",
                "cafe",
                "college",
                "company",
                "eduroam",
                "free",
                "guest",
                "public",
                "school",
                "university"
            ]
        }
    }
}
')

    # /home/jk durch den aktuellen Benutzer ersetzen
    set json (string replace -a "/home/jk" "$HOME" "$json")

    printf '%s\n' "$json" >"$config"

    echo "Config written: $config"

end
