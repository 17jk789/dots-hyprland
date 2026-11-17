local home_dir = os.getenv("HOME")

-- Wayland
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")

-- GTK: Restore compositor blur compatibility
hl.env("GDK_WAYLAND_DISABLE", "ext_background_effect_manager_v1")

-- Applications
local xdg_data_dirs_old = os.getenv("XDG_DATA_DIRS") or ""

hl.env(
    "XDG_DATA_DIRS",
    home_dir .. "/.local/share/flatpak/exports/share:" ..
    "/var/lib/flatpak/exports/share:" ..
    "/usr/local/share:/usr/share:" ..
    xdg_data_dirs_old
)

-- Themes
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("QT_QPA_PLATFORMTHEME", "kde")
hl.env("XDG_MENU_PREFIX", "plasma-")

-- Virtual environment
hl.env(
    "ILLOGICAL_IMPULSE_VIRTUAL_ENV",
    home_dir .. "/.local/state/quickshell/.venv"
)
-- Keyboard input
-- Keep your existing dead-key workaround
hl.env("GTK_IM_MODULE", "simple")
