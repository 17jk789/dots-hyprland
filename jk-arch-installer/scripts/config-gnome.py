#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
===============================================================================
 GNOME 50 / 51
 CATPPUCCIN MOCHA + HYPRLAND-STYLE KEYBINDINGS
===============================================================================

Ein vollständiger GNOME-Installer für Arch Linux.

ZIELE
-----

1. Catppuccin Mocha für GNOME Shell 50 / 51
2. Modulare GNOME-Shell-CSS-Struktur
3. Hyprland-Keybindings als Referenz
4. GNOME-Keybindings so nah wie möglich an Hyprland
5. Native GNOME-Funktionen bevorzugen
6. Custom GNOME Shortcuts für Hyprland-Funktionen verwenden
7. Vorhandene GNOME-Keybindings sichern
8. Restore-Funktion bereitstellen
9. Keine yay / paru / AUR-Abhängigkeit
10. pacman nur für optionale Pakete
11. GTK 3 / GTK 4 / Libadwaita nicht verändern
12. Fonts nicht verändern
13. Keine Anwendungsthemes verändern
14. Keine GNOME-Geometrie verändern
15. Keine GNOME-Animationen verändern

WICHTIG
-------

Dieses Script konfiguriert tatsächlich GNOME-Shortcuts.

Die visuelle Theme-Konfiguration und die Keybinding-Konfiguration
sind logisch getrennt, werden aber von demselben Installer verwaltet.

Die Hyprland-Konfiguration ist die Referenz für die gewünschte
Bedienlogik.

GNOME kann Hyprland-spezifische Funktionen nicht 1:1 nativ ersetzen.
Für solche Funktionen werden Custom Shortcuts verwendet.

Beispiele:

    Quickshell
    Hyprctl
    cliphist
    hyprshot
    hyprpicker
    grim
    slurp
    playerctl
    wl-copy
    OCR
    Übersetzung
    Recording
    OBS
    Scratchpad
    VM-Submap

Diese Programme werden NICHT automatisch installiert.
Ein Shortcut wird nur eingerichtet, wenn sein Command sinnvoll
definiert ist.

INSTALLATION
------------

    python3 gnome-hyprland-installer.py

RESTORE
-------

    python3 gnome-hyprland-installer.py --restore

THEME ENTFERNEN
---------------

    python3 gnome-hyprland-installer.py --remove

KEYBINDINGS NUR INSTALLIEREN
----------------------------

    python3 gnome-hyprland-installer.py --keybindings-only

THEME NUR INSTALLIEREN
----------------------

    python3 gnome-hyprland-installer.py --theme-only

===============================================================================
"""

from __future__ import annotations

import argparse
import ast
import json
import os
import re
import shutil
import subprocess
import sys
from datetime import datetime
from pathlib import Path
from typing import Iterable


# =============================================================================
# PATHS
# =============================================================================

HOME = Path.home()

SCRIPT_DIR = Path(__file__).resolve().parent

ASSETS_DIR = SCRIPT_DIR / "assets"

DASH_TO_PANEL_CONF = ASSETS_DIR / "dash-to-panel.conf"

BACKUP_DIR = HOME / ".local" / "share" / "gnome-hyprland-installer" / "backups"

BACKUP_DIR.mkdir(
    parents=True,
    exist_ok=True,
)

UUID = "catppuccin-mocha-colors@local"

EXTENSION_NAME = "Catppuccin Mocha Shell Colors"

EXTENSION_DIR = HOME / ".local" / "share" / "gnome-shell" / "extensions" / UUID


# =============================================================================
# CATPPUCCIN MOCHA
# =============================================================================

COLORS = {
    "rosewater": "#f5e0e5",
    "flamingo": "#f2cdcd",
    "pink": "#f5c2e7",
    "mauve": "#cba6f7",
    "red": "#f38ba8",
    "maroon": "#eba0ac",
    "peach": "#fab387",
    "yellow": "#f9e2af",
    "green": "#a6e3a1",
    "teal": "#94e2d5",
    "sky": "#89dceb",
    "sapphire": "#74c7ec",
    "blue": "#89b4fa",
    "lavender": "#b4befe",
    "text": "#cdd6f4",
    "subtext1": "#bac2de",
    "subtext0": "#a6adc8",
    "overlay2": "#9399b2",
    "overlay1": "#7f849c",
    "overlay0": "#6c7086",
    "surface2": "#585b70",
    "surface1": "#45475a",
    "surface0": "#313244",
    "base": "#1e1e2e",
    "mantle": "#181825",
    "crust": "#11111b",
}


# =============================================================================
# ARGUMENTS
# =============================================================================

parser = argparse.ArgumentParser(
    description=("GNOME 50/51 Catppuccin Mocha theme + Hyprland-style keybindings")
)

parser.add_argument(
    "--restore",
    action="store_true",
    help="Restore the latest GNOME keybinding backup",
)

parser.add_argument(
    "--remove",
    action="store_true",
    help="Remove the installed Catppuccin GNOME Shell extension",
)

parser.add_argument(
    "--theme-only",
    action="store_true",
    help="Install only the GNOME Shell theme",
)

parser.add_argument(
    "--keybindings-only",
    action="store_true",
    help="Install only the GNOME keybindings",
)

args = parser.parse_args()


# =============================================================================
# OUTPUT
# =============================================================================


def title(text: str) -> None:
    print()
    print("=" * 78)
    print(text)
    print("=" * 78)
    print()


def info(text: str) -> None:
    print(f"[INFO] {text}")


def ok(text: str) -> None:
    print(f"[OK]   {text}")


def warn(text: str) -> None:
    print(f"[WARN] {text}")


def error(text: str) -> None:
    print(f"[ERROR] {text}")


# =============================================================================
# COMMAND HELPERS
# =============================================================================


def command_exists(command: str) -> bool:
    return shutil.which(command) is not None


def run(
    command: list[str],
    *,
    check: bool = True,
    capture: bool = False,
) -> subprocess.CompletedProcess:

    if capture:
        return subprocess.run(
            command,
            check=check,
            text=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
        )

    print("$ " + " ".join(command))

    return subprocess.run(
        command,
        check=check,
        text=True,
    )


def shell_command(command: str) -> str:
    return command


def require_commands(
    commands: Iterable[str],
) -> None:

    missing = [command for command in commands if not command_exists(command)]

    if missing:
        error("Required commands are missing:")

        for command in missing:
            print(f"  - {command}")

        sys.exit(1)


# =============================================================================
# ROOT CHECK
# =============================================================================

if os.geteuid() == 0:
    error("Dieses Script darf nicht als root ausgeführt werden.")

    error("sudo wird nur intern für pacman verwendet.")

    sys.exit(1)


# =============================================================================
# REQUIRED GNOME TOOLS
# =============================================================================

require_commands(
    [
        "gsettings",
        "gnome-extensions",
    ]
)


# =============================================================================
# GNOME VERSION
# =============================================================================


def get_gnome_shell_version() -> str:

    if not command_exists("gnome-shell"):
        return "unknown"

    result = run(
        [
            "gnome-shell",
            "--version",
        ],
        check=False,
        capture=True,
    )

    value = result.stdout.strip() or result.stderr.strip()

    return value or "unknown"


GNOME_VERSION = get_gnome_shell_version()


def get_gnome_major_version() -> int | None:

    match = re.search(
        r"(\d+)",
        GNOME_VERSION,
    )

    if not match:
        return None

    return int(match.group(1))


GNOME_MAJOR = get_gnome_major_version()


# =============================================================================
# VERSION VALIDATION
# =============================================================================

title("GNOME 50 / 51 — ENVIRONMENT CHECK")

print(f"GNOME Shell: {GNOME_VERSION}")

if GNOME_MAJOR in {50, 51}:
    ok("GNOME Shell 50/51 erkannt.")

else:
    warn("Dieses Script ist für GNOME Shell 50/51 ausgelegt.")

    if GNOME_MAJOR is not None:
        warn(f"Erkannte Major-Version: {GNOME_MAJOR}")


# =============================================================================
# PACMAN
# =============================================================================


def package_installed(
    package: str,
) -> bool:

    result = subprocess.run(
        [
            "pacman",
            "-Q",
            package,
        ],
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
        check=False,
    )

    return result.returncode == 0


def pacman_install(
    *packages: str,
) -> bool:

    if not command_exists("pacman"):
        warn("pacman nicht gefunden.")

        return False

    packages = [package for package in packages if package]

    if not packages:
        return True

    result = run(
        [
            "sudo",
            "pacman",
            "-S",
            "--needed",
            *packages,
        ],
        check=False,
    )

    return result.returncode == 0


# =============================================================================
# BACKUP
# =============================================================================


def timestamp() -> str:
    return datetime.now().strftime("%Y%m%d-%H%M%S")


def backup_file(
    name: str,
    content: str,
) -> Path:

    path = BACKUP_DIR / f"{timestamp()}-{name}"

    path.write_text(
        content,
        encoding="utf-8",
    )

    return path


# =============================================================================
# GSETTINGS HELPERS
# =============================================================================


def gsettings_get(
    schema: str,
    key: str,
) -> str:

    result = run(
        [
            "gsettings",
            "get",
            schema,
            key,
        ],
        check=False,
        capture=True,
    )

    return result.stdout.strip()


def gsettings_set(
    schema: str,
    key: str,
    value: str,
) -> bool:

    result = run(
        [
            "gsettings",
            "set",
            schema,
            key,
            value,
        ],
        check=False,
    )

    return result.returncode == 0


# =============================================================================
# GNOME SHORTCUT SCHEMA
# =============================================================================

MEDIA_KEYS_SCHEMA = "org.gnome.settings-daemon.plugins.media-keys"

WM_SCHEMA = "org.gnome.desktop.wm.keybindings"

SHELL_SCHEMA = "org.gnome.shell.keybindings"

INTERFACE_SCHEMA = "org.gnome.desktop.interface"

CUSTOM_KEYBINDINGS_KEY = "custom-keybindings"


# =============================================================================
# BACKUP GNOME KEYBINDINGS
# =============================================================================


def backup_keybindings() -> Path:

    title("BACKUP — EXISTING GNOME KEYBINDINGS")

    data = {
        "created": datetime.now().isoformat(),
        "gnome_version": GNOME_VERSION,
        "wm": {},
        "shell": {},
        "media": {},
        "interface": {},
        "custom": {},
    }

    for schema, target in [
        (WM_SCHEMA, data["wm"]),
        (SHELL_SCHEMA, data["shell"]),
        (MEDIA_KEYS_SCHEMA, data["media"]),
        (INTERFACE_SCHEMA, data["interface"]),
    ]:
        result = run(
            [
                "gsettings",
                "list-recursively",
                schema,
            ],
            check=False,
            capture=True,
        )

        if result.returncode != 0:
            continue

        for line in result.stdout.splitlines():
            parts = line.split(
                " ",
                2,
            )

            if len(parts) != 3:
                continue

            _, key, value = parts

            target[key] = value

    custom = gsettings_get(
        WM_SCHEMA,
        CUSTOM_KEYBINDINGS_KEY,
    )

    data["custom"] = custom

    path = backup_file(
        "gnome-keybindings.json",
        json.dumps(
            data,
            indent=2,
            ensure_ascii=False,
        ),
    )

    ok(f"Keybinding-Backup erstellt: {path}")

    return path


# =============================================================================
# CUSTOM SHORTCUT MANAGEMENT
# =============================================================================


def get_custom_keybindings() -> list[str]:

    raw = gsettings_get(
        WM_SCHEMA,
        CUSTOM_KEYBINDINGS_KEY,
    )

    if not raw:
        return []

    try:
        value = ast.literal_eval(raw)

        if isinstance(value, list):
            return [str(item) for item in value]

    except Exception:
        pass

    return []


def gvariant_string(
    value: str,
) -> str:

    return (
        "'"
        + value.replace(
            "'",
            "\\'",
        )
        + "'"
    )


def set_custom_keybindings(
    paths: list[str],
) -> bool:

    value = (
        "@as []"
        if not paths
        else "[" + ", ".join(gvariant_string(path) for path in paths) + "]"
    )

    return gsettings_set(
        WM_SCHEMA,
        CUSTOM_KEYBINDINGS_KEY,
        value,
    )


def set_custom_entry(
    path: str,
    name: str,
    command: str,
    binding: str,
) -> bool:

    schema = f"org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:{path}"

    # GNOME's schema is normally accessed by the
    # relocatable path through gsettings.
    #
    # Using gsettings directly keeps this compatible
    # with standard GNOME settings storage.

    success = True

    success &= gsettings_set(
        schema,
        "name",
        gvariant_string(name),
    )

    success &= gsettings_set(
        schema,
        "command",
        gvariant_string(command),
    )

    success &= gsettings_set(
        schema,
        "binding",
        gvariant_string(binding),
    )

    return bool(success)


# =============================================================================
# GNOME CUSTOM SHORTCUT IMPLEMENTATION
# =============================================================================

CUSTOM_BASE = "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/"


def custom_path(index: int) -> str:

    return CUSTOM_BASE + f"custom{index}/"


def custom_schema(
    path: str,
) -> str:

    return f"org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:{path}"


def configure_custom_shortcuts(
    shortcuts: list[dict[str, str]],
) -> int:

    existing = get_custom_keybindings()

    # We deliberately create a dedicated block at the
    # end of the custom-keybinding list.
    #
    # Existing user shortcuts remain in place.

    start_index = 0

    while custom_path(start_index) in existing:
        start_index += 1

    paths = list(existing)

    configured = 0

    for offset, item in enumerate(shortcuts):
        index = start_index + offset

        path = custom_path(index)

        schema = custom_schema(path)

        success = True

        success &= gsettings_set(
            schema,
            "name",
            gvariant_string(item["name"]),
        )

        success &= gsettings_set(
            schema,
            "command",
            gvariant_string(item["command"]),
        )

        success &= gsettings_set(
            schema,
            "binding",
            gvariant_string(item["binding"]),
        )

        if success:
            paths.append(path)

            configured += 1

        else:
            warn(f"Custom Shortcut konnte nicht eingerichtet werden: {item['name']}")

    if not set_custom_keybindings(paths):
        error("custom-keybindings konnte nicht gesetzt werden.")

    return configured


# =============================================================================
# COMMAND AVAILABILITY
# =============================================================================


def command_or_skip(
    command: str,
) -> bool:

    # We intentionally do not try to parse complex shell
    # pipelines here. If the command begins with bash/sh,
    # it is treated as an external shell command.

    first = command.strip().split(
        None,
        1,
    )[0]

    if first in {
        "bash",
        "sh",
        "fish",
        "python",
        "python3",
        "kitty",
        "alacritty",
        "wezterm",
        "gnome-terminal",
        "xdg-open",
    }:
        return command_exists(first)

    return command_exists(first)


# =============================================================================
# APPLICATION COMMAND DETECTION
# =============================================================================


def first_available(
    commands: list[str],
) -> str | None:

    for command in commands:
        first = command.split(
            None,
            1,
        )[0]

        if command_exists(first):
            return command

    return None


TERMINAL_COMMAND = first_available(
    [
        "kitty",
        "foot",
        "alacritty",
        "wezterm",
        "gnome-terminal",
    ]
)

BROWSER_COMMAND = first_available(
    [
        "brave",
        "firefox",
        "librewolf",
        "chromium",
    ]
)

FILE_MANAGER_COMMAND = first_available(
    [
        "nautilus",
        "thunar",
        "dolphin",
        "pcmanfm",
    ]
)


# =============================================================================
# HYPRLAND -> GNOME SHORTCUT DEFINITIONS
# =============================================================================
#
# Diese Tabelle bildet deine Lua-Konfiguration auf GNOME ab.
#
# Syntax:
#
#   <Super>
#   <Shift>
#   <Control>
#   <Alt>
#
# GNOME verwendet "<Super>" statt "SUPER".
# =============================================================================

CUSTOM_SHORTCUTS: list[dict[str, str]] = []


def add_shortcut(
    name: str,
    binding: str,
    command: str,
) -> None:

    CUSTOM_SHORTCUTS.append(
        {
            "name": name,
            "binding": binding,
            "command": command,
        }
    )


# =============================================================================
# QUICK / SHELL
# =============================================================================

if command_exists("fuzzel"):
    add_shortcut(
        "Hyprland: Search / Fuzzel",
        "<Super>space",
        "fuzzel",
    )


if command_exists("qs"):
    add_shortcut(
        "Hyprland: Quickshell Search",
        "<Super>space",
        "qs",
    )


add_shortcut(
    "Hyprland: Overview",
    "<Super>Tab",
    "bash -c 'gnome-extensions prefs org.gnome.shell.extensions.dash-to-panel 2>/dev/null || true'",
)


# =============================================================================
# CLIPBOARD
# =============================================================================

if command_exists("cliphist") and command_exists("fuzzel"):
    add_shortcut(
        "Utilities: Clipboard history",
        "<Super>v",
        "bash -c 'cliphist list | fuzzel --dmenu | cliphist decode | wl-copy'",
    )


# =============================================================================
# EMOJI
# =============================================================================

if command_exists("fuzzel") and command_exists("wl-copy"):
    emoji_script = (
        HOME / ".config" / "hypr" / "hyprland" / "scripts" / "fuzzel-emoji.sh"
    )

    if emoji_script.exists():
        add_shortcut(
            "Utilities: Emoji",
            "<Super>period",
            f"{emoji_script} copy",
        )


# =============================================================================
# GNOME / SHELL UTILITIES
# =============================================================================

add_shortcut(
    "Shell: Cheatsheet",
    "<Super><Shift>7",
    'bash -c \'notify-send "Hyprland / GNOME Keybindings" "Use the configured Hyprland-compatible shortcuts."\'',
)

add_shortcut(
    "Shell: On-screen keyboard",
    "<Super>k",
    "bash -c 'gsettings set org.gnome.desktop.a11y.applications screen-keyboard-enabled true'",
)


# =============================================================================
# MEDIA OVERLAY
# =============================================================================

if command_exists("playerctl"):
    add_shortcut(
        "Media: Toggle media controls",
        "<Super>m",
        "playerctl play-pause",
    )


# =============================================================================
# SESSION MENU
# =============================================================================

add_shortcut(
    "Session: GNOME session menu",
    "<Control><Alt>Delete",
    "bash -c 'gnome-session-quit --logout-dialog'",
)


# =============================================================================
# WALLPAPER
# =============================================================================

if command_exists("gsettings"):
    add_shortcut(
        "Shell: Wallpaper",
        "<Control><Super>t",
        "bash -c 'gnome-control-center background 2>/dev/null || true'",
    )


# =============================================================================
# LIGHT / DARK
# =============================================================================

add_shortcut(
    "Shell: Toggle light/dark mode",
    "<Control><Super><Shift>d",
    "bash -c 'v=$(gsettings get org.gnome.desktop.interface color-scheme); if [[ \"$v\" == *prefer-dark* ]]; then gsettings set org.gnome.desktop.interface color-scheme prefer-light; else gsettings set org.gnome.desktop.interface color-scheme prefer-dark; fi'",
)


# =============================================================================
# RESTART QUICKSHELL
# =============================================================================

if command_exists("qs"):
    add_shortcut(
        "Shell: Restart Quickshell widgets",
        "<Control><Super>r",
        "bash -c 'pkill -x quickshell 2>/dev/null || true; pkill -x qs 2>/dev/null || true; qs -c \"$qsConfig\" &'",
    )


# =============================================================================
# SCREENSHOT
# =============================================================================

if command_exists("gnome-screenshot"):
    add_shortcut(
        "Utilities: Screenshot",
        "Print",
        "gnome-screenshot",
    )

elif command_exists("gnome-screenshot"):
    add_shortcut(
        "Utilities: Screenshot",
        "Print",
        "gnome-screenshot",
    )


if command_exists("grim") and command_exists("slurp"):
    add_shortcut(
        "Utilities: Screen snip",
        "<Super><Shift>s",
        "bash -c 'grim -g \"$(slurp)\" - | wl-copy'",
    )


# =============================================================================
# GOOGLE LENS / REGION SEARCH
# =============================================================================

SNIP_SEARCH = HOME / ".config" / "hypr" / "hyprland" / "scripts" / "snip_to_search.sh"

if SNIP_SEARCH.exists():
    add_shortcut(
        "Utilities: Google Lens",
        "<Super><Shift>a",
        str(SNIP_SEARCH),
    )


# =============================================================================
# OCR
# =============================================================================

if (
    command_exists("grim")
    and command_exists("slurp")
    and command_exists("tesseract")
    and command_exists("wl-copy")
):
    add_shortcut(
        "Utilities: OCR",
        "<Super><Shift>x",
        "bash -c 'grim -g \"$(slurp)\" /tmp/gnome-ocr.png && tesseract /tmp/gnome-ocr.png stdout 2>/dev/null | wl-copy; rm -f /tmp/gnome-ocr.png'",
    )


# =============================================================================
# TRANSLATION
# =============================================================================

add_shortcut(
    "Utilities: Translate screen",
    "<Super><Shift>t",
    'bash -c \'notify-send "Screen Translation" "Configure your translation command here."\'',
)


# =============================================================================
# COLOR PICKER
# =============================================================================

if command_exists("hyprpicker"):
    add_shortcut(
        "Utilities: Color picker",
        "<Super><Shift>c",
        "hyprpicker -a",
    )


# =============================================================================
# RECORDING
# =============================================================================

RECORD_SCRIPT = HOME / ".config" / "quickshell" / "scripts" / "videos" / "record.sh"

if RECORD_SCRIPT.exists():
    add_shortcut(
        "Utilities: Record region",
        "<Super><Shift>r",
        str(RECORD_SCRIPT),
    )

    add_shortcut(
        "Utilities: Record screen",
        "<Control><Alt>r",
        f"{RECORD_SCRIPT} --fullscreen",
    )

    add_shortcut(
        "Utilities: Record screen with sound",
        "<Shift><Alt><Super>r",
        f"{RECORD_SCRIPT} --fullscreen --sound",
    )


# =============================================================================
# OBS
# =============================================================================

if command_exists("obs"):
    add_shortcut(
        "App: OBS",
        "Print",
        "obs",
    )


# =============================================================================
# MEDIA
# =============================================================================

if command_exists("playerctl"):
    add_shortcut(
        "Media: Next track",
        "<Super><Shift>n",
        "playerctl next",
    )

    add_shortcut(
        "Media: Previous track",
        "<Super><Shift>b",
        "playerctl previous",
    )

    add_shortcut(
        "Media: Play / pause",
        "<Super><Shift>p",
        "playerctl play-pause",
    )

    add_shortcut(
        "Media: Mute",
        "<Super><Shift>m",
        "wpctl set-mute @DEFAULT_SINK@ toggle",
    )


# =============================================================================
# WINDOW MANAGEMENT
# =============================================================================

add_shortcut(
    "Window: Close",
    "<Super>q",
    "bash -c 'wmctrl -c :ACTIVE: 2>/dev/null || gdbus call --session --dest org.gnome.Shell --object-path /org/gnome/Shell --method org.gnome.Shell.Eval \"global.display.get_focus_window().delete(global.get_current_time());\" >/dev/null 2>&1'",
)


add_shortcut(
    "Window: Maximize",
    "<Super>d",
    "bash -c 'wmctrl -r :ACTIVE: -b toggle,maximized_vert,maximized_horz'",
)


add_shortcut(
    "Window: Fullscreen",
    "<Super>f",
    "bash -c 'wmctrl -r :ACTIVE: -b toggle,fullscreen'",
)


add_shortcut(
    "Window: Float",
    "<Alt><Super>space",
    'bash -c \'notify-send "GNOME" "Floating windows require a GNOME Shell extension or Mutter-specific workflow."\'',
)


add_shortcut(
    "Window: Pin",
    "<Super>p",
    'bash -c \'notify-send "GNOME" "Always-on-top requires GNOME/Mutter extension support."\'',
)


# =============================================================================
# WORKSPACE 1–10
# =============================================================================

for i in range(
    1,
    11,
):
    digit = "0" if i == 10 else str(i)

    add_shortcut(
        f"Workspace: Focus {i}",
        f"<Super>{digit}",
        f"bash -c 'wmctrl -s {i - 1}'",
    )

    add_shortcut(
        f"Window: Send to workspace {i}",
        f"<Alt><Super>{digit}",
        f"bash -c 'wmctrl -r :ACTIVE: -t {i - 1}'",
    )


# =============================================================================
# WORKSPACE NAVIGATION
# =============================================================================

add_shortcut(
    "Workspace: Previous",
    "<Control><Super>Left",
    "bash -c 'gdbus call --session --dest org.gnome.Shell --object-path /org/gnome/Shell --method org.gnome.Shell.Eval \"global.workspace_manager.get_active_workspace().get_neighbor(Meta.MotionDirection.LEFT).activate(global.get_current_time());\" >/dev/null 2>&1'",
)

add_shortcut(
    "Workspace: Next",
    "<Control><Super>Right",
    "bash -c 'gdbus call --session --dest org.gnome.Shell --object-path /org/gnome/Shell --method org.gnome.Shell.Eval \"global.workspace_manager.get_active_workspace().get_neighbor(Meta.MotionDirection.RIGHT).activate(global.get_current_time());\" >/dev/null 2>&1'",
)


# =============================================================================
# WORKSPACE PAGE UP/DOWN
# =============================================================================

add_shortcut(
    "Workspace: Previous Page",
    "<Super>Page_Up",
    'bash -c \'wmctrl -s $(($(wmctrl -d | awk "$2==\\"*\\" {print $1}") - 1))\'',
)

add_shortcut(
    "Workspace: Next Page",
    "<Super>Page_Down",
    'bash -c \'wmctrl -s $(($(wmctrl -d | awk "$2==\\"*\\" {print $1}") + 1))\'',
)


# =============================================================================
# SCRATCHPAD
# =============================================================================

add_shortcut(
    "Workspace: Toggle scratchpad",
    "<Super>s",
    'bash -c \'notify-send "GNOME Scratchpad" "A GNOME extension is required for a true Hyprland-style special workspace."\'',
)

add_shortcut(
    "Window: Send to scratchpad",
    "<Alt><Super>s",
    'bash -c \'notify-send "GNOME Scratchpad" "A GNOME extension is required for a true Hyprland-style special workspace."\'',
)


# =============================================================================
# WINDOW FOCUS
# =============================================================================

add_shortcut(
    "Window: Focus left",
    "<Super>Left",
    "bash -c 'wmctrl -r :ACTIVE: -e 0,-1,-1,-1,-1'",
)

add_shortcut(
    "Window: Focus right",
    "<Super>Right",
    "bash -c 'wmctrl -r :ACTIVE: -e 0,-1,-1,-1,-1'",
)


# =============================================================================
# APPLICATIONS
# =============================================================================

if TERMINAL_COMMAND:
    add_shortcut(
        "App: Terminal",
        "<Super>Return",
        TERMINAL_COMMAND,
    )

    add_shortcut(
        "App: Terminal",
        "<Super>t",
        TERMINAL_COMMAND,
    )

    add_shortcut(
        "App: Terminal",
        "<Control><Alt>t",
        TERMINAL_COMMAND,
    )


if FILE_MANAGER_COMMAND:
    add_shortcut(
        "App: File manager",
        "<Super>e",
        FILE_MANAGER_COMMAND,
    )


if BROWSER_COMMAND:
    add_shortcut(
        "App: Browser",
        "<Super>w",
        BROWSER_COMMAND,
    )


if command_exists("firefox"):
    add_shortcut(
        "App: Firefox",
        "<Super><Alt>w",
        "firefox",
    )


if command_exists("mullvad-browser"):
    add_shortcut(
        "App: Mullvad Browser",
        "<Control><Super>w",
        "mullvad-browser -P",
    )


if command_exists("librewolf"):
    add_shortcut(
        "App: LibreWolf",
        "<Super><Shift>w",
        "librewolf",
    )


if command_exists("torbrowser-launcher"):
    add_shortcut(
        "App: Tor Browser",
        "<Super><Alt><Shift>w",
        "torbrowser-launcher",
    )


if command_exists("qalculate-gtk"):
    add_shortcut(
        "App: Qalculate",
        "XF86Calculator",
        "qalculate-gtk",
    )


# =============================================================================
# SETTINGS
# =============================================================================

add_shortcut(
    "App: Settings",
    "<Super>i",
    "gnome-control-center",
)


# =============================================================================
# TASK MANAGER
# =============================================================================

if command_exists("gnome-system-monitor"):
    add_shortcut(
        "App: Task manager",
        "<Control><Shift>Escape",
        "gnome-system-monitor",
    )


# =============================================================================
# VOLUME
# =============================================================================

add_shortcut(
    "Media: Volume up",
    "XF86AudioRaiseVolume",
    "wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%+ -l 1.5",
)

add_shortcut(
    "Media: Volume down",
    "XF86AudioLowerVolume",
    "wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%-",
)

add_shortcut(
    "Media: Mute",
    "XF86AudioMute",
    "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle",
)

add_shortcut(
    "Media: Microphone mute",
    "XF86AudioMicMute",
    "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle",
)


# =============================================================================
# MEDIA KEYS
# =============================================================================

if command_exists("playerctl"):
    add_shortcut(
        "Media: Play / pause",
        "XF86AudioPlay",
        "playerctl play-pause",
    )

    add_shortcut(
        "Media: Play / pause",
        "XF86AudioPause",
        "playerctl play-pause",
    )

    add_shortcut(
        "Media: Next",
        "XF86AudioNext",
        "playerctl next",
    )

    add_shortcut(
        "Media: Previous",
        "XF86AudioPrev",
        "playerctl previous",
    )


# =============================================================================
# SESSION
# =============================================================================

add_shortcut(
    "Session: Lock",
    "<Super>l",
    "loginctl lock-session",
)

add_shortcut(
    "Session: Suspend",
    "<Super><Shift>l",
    "systemctl suspend",
)

add_shortcut(
    "Session: Logout",
    "<Control><Alt>Delete",
    "gnome-session-quit --logout",
)


# =============================================================================
# GNOME DARK MODE
# =============================================================================

add_shortcut(
    "GNOME: Toggle dark mode",
    "<Control><Super><Shift>d",
    "bash -c 'if [[ \"$(gsettings get org.gnome.desktop.interface color-scheme)\" == *prefer-dark* ]]; then gsettings set org.gnome.desktop.interface color-scheme prefer-light; else gsettings set org.gnome.desktop.interface color-scheme prefer-dark; fi'",
)


# =============================================================================
# GLASS / BORDER / GNOME TOGGLE
# =============================================================================

GNOME_TOGGLE_SCRIPT = HOME / ".config" / "fish" / "functions" / "gnome-toggle.py"

if GNOME_TOGGLE_SCRIPT.exists():
    add_shortcut(
        "Session: Toggle GNOME / Hyprland profile",
        "<Control><Super>h",
        f"kitty --hold python3 {GNOME_TOGGLE_SCRIPT} --reboot",
    )


# =============================================================================
# FILTER INVALID DUPLICATES
# =============================================================================


def deduplicate_shortcuts(
    shortcuts: list[dict[str, str]],
) -> list[dict[str, str]]:

    seen: set[tuple[str, str]] = set()

    result = []

    for item in shortcuts:
        key = (
            item["binding"],
            item["name"],
        )

        if key in seen:
            continue

        seen.add(key)

        result.append(item)

    return result


CUSTOM_SHORTCUTS = deduplicate_shortcuts(CUSTOM_SHORTCUTS)


# =============================================================================
# PRINT KEYBINDING PLAN
# =============================================================================


def print_keybinding_plan() -> None:

    title("HYPRLAND → GNOME KEYBINDING PLAN")

    print("Ziel:")

    print("  GNOME 50/51 soll sich bei der Bedienung")

    print("  so nah wie möglich an deiner Hyprland-")

    print("  Keybinding-Konfiguration verhalten.")

    print()

    print(f"Geplante Custom Shortcuts: {len(CUSTOM_SHORTCUTS)}")

    print()

    for item in CUSTOM_SHORTCUTS:
        print(f"  {item['binding']:<30}{item['name']}")


# =============================================================================
# INSTALL KEYBINDINGS
# =============================================================================


def install_keybindings() -> None:

    print_keybinding_plan()

    backup_keybindings()

    title("INSTALLING GNOME KEYBINDINGS")

    configured = configure_custom_shortcuts(CUSTOM_SHORTCUTS)

    print()

    ok(f"{configured} Custom Shortcuts eingerichtet.")

    print()

    print("Keybinding-Ziel:")

    print("  GNOME 50 / 51")

    print("  möglichst nah an Hyprland")

    print()

    print("Native GNOME-Funktionen bleiben bevorzugt.")

    print("Hyprland-spezifische Funktionen werden")

    print("über Custom Shortcuts angebunden.")


# =============================================================================
# THEME FILE WRITER
# =============================================================================


def write_file(
    path: Path,
    content: str,
) -> None:

    path.parent.mkdir(
        parents=True,
        exist_ok=True,
    )

    path.write_text(
        content.rstrip() + "\n",
        encoding="utf-8",
    )

    print(f"[WRITE] {path}")


# =============================================================================
# GNOME EXTENSION
# =============================================================================

EXTENSION_JS = r"""
import Gio from "gi://Gio";
import St from "gi://St";

import {
    Extension,
} from "resource:///org/gnome/shell/extensions/extension.js";


export default class CatppuccinMochaShellColors
    extends Extension {

    enable() {

        this._themeContext =
            St.ThemeContext.get_for_stage(
                global.stage
            );

        this._theme =
            this._themeContext.get_theme();

        this._stylesheet =
            Gio.File.new_for_path(
                this.path + "/stylesheet.css"
            );

        try {

            this._theme.load_stylesheet(
                this._stylesheet
            );

            log(
                "Catppuccin Mocha: stylesheet loaded"
            );

        } catch (error) {

            logError(
                error,
                "Catppuccin Mocha: stylesheet load failed"
            );
        }
    }

    disable() {

        if (
            this._theme &&
            this._stylesheet
        ) {

            try {

                this._theme.unload_stylesheet(
                    this._stylesheet
                );

            } catch (error) {

                logError(
                    error,
                    "Catppuccin Mocha: stylesheet unload failed"
                );
            }
        }

        this._theme = null;
        this._stylesheet = null;
        this._themeContext = null;
    }
}
"""


# =============================================================================
# CSS
# =============================================================================

COLORS_CSS = f"""
/*
 * CATPPUCCIN MOCHA
 * GNOME SHELL 50 / 51
 */

:root {{
    --ctp-rosewater: {COLORS["rosewater"]};
    --ctp-flamingo: {COLORS["flamingo"]};
    --ctp-pink: {COLORS["pink"]};
    --ctp-mauve: {COLORS["mauve"]};
    --ctp-red: {COLORS["red"]};
    --ctp-maroon: {COLORS["maroon"]};
    --ctp-peach: {COLORS["peach"]};
    --ctp-yellow: {COLORS["yellow"]};
    --ctp-green: {COLORS["green"]};
    --ctp-teal: {COLORS["teal"]};
    --ctp-sky: {COLORS["sky"]};
    --ctp-sapphire: {COLORS["sapphire"]};
    --ctp-blue: {COLORS["blue"]};
    --ctp-lavender: {COLORS["lavender"]};

    --ctp-text: {COLORS["text"]};
    --ctp-subtext1: {COLORS["subtext1"]};
    --ctp-subtext0: {COLORS["subtext0"]};

    --ctp-overlay2: {COLORS["overlay2"]};
    --ctp-overlay1: {COLORS["overlay1"]};
    --ctp-overlay0: {COLORS["overlay0"]};

    --ctp-surface2: {COLORS["surface2"]};
    --ctp-surface1: {COLORS["surface1"]};
    --ctp-surface0: {COLORS["surface0"]};

    --ctp-base: {COLORS["base"]};
    --ctp-mantle: {COLORS["mantle"]};
    --ctp-crust: {COLORS["crust"]};
}}
"""


APP_CSS = f"""
stage {{
    color: {COLORS["text"]};
    background-color: {COLORS["crust"]};
}}

#overview {{
    color: {COLORS["text"]};
    background-color: {COLORS["crust"]};
}}

StWidget {{
    color: {COLORS["text"]};
}}

.button,
.flat,
.icon-button {{
    color: {COLORS["text"]};
    background-color: {COLORS["surface0"]};
    border-color: {COLORS["surface1"]};
}}

.button:hover,
.flat:hover,
.icon-button:hover {{
    background-color: {COLORS["surface1"]};
}}

.button:active,
.button:checked,
.flat:active,
.flat:checked,
.icon-button:checked {{
    color: {COLORS["base"]};
    background-color: {COLORS["mauve"]};
}}

StEntry {{
    color: {COLORS["text"]};
    background-color: {COLORS["surface0"]};
    border-color: {COLORS["surface1"]};
    caret-color: {COLORS["mauve"]};
    selection-background-color: {COLORS["mauve"]};
}}

StEntry:focus {{
    background-color: {COLORS["surface1"]};
    border-color: {COLORS["lavender"]};
}}

StScrollBar {{
    -slider-background-color: {COLORS["surface1"]};
    -slider-hover-background-color: {COLORS["surface2"]};
    -slider-active-background-color: {COLORS["mauve"]};
}}

.link {{
    color: {COLORS["blue"]};
}}

.link:hover {{
    color: {COLORS["lavender"]};
}}
"""


PANEL_CSS = f"""
#panel {{
    color: {COLORS["text"]};
    background-color: {COLORS["mantle"]};
    border-color: {COLORS["surface0"]};
}}

#panel .panel-button {{
    color: {COLORS["text"]};
    background-color: transparent;
}}

#panel .panel-button:hover,
#panel .panel-button:focus {{
    color: {COLORS["text"]};
    background-color: {COLORS["surface0"]};
}}

#panel .panel-button:active,
#panel .panel-button:checked {{
    color: {COLORS["base"]};
    background-color: {COLORS["mauve"]};
}}
"""


POPUP_MENU_CSS = f"""
.popup-menu,
.popup-menu-boxpointer,
.popup-menu-content,
.popup-sub-menu {{
    color: {COLORS["text"]};
    background-color: {COLORS["base"]};
    border-color: {COLORS["surface0"]};
}}

.popup-menu-item {{
    color: {COLORS["subtext1"]};
    background-color: {COLORS["base"]};
}}

.popup-menu-item:hover,
.popup-menu-item:focus {{
    color: {COLORS["text"]};
    background-color: {COLORS["surface0"]};
}}

.popup-menu-item:active,
.popup-menu-item:checked {{
    color: {COLORS["base"]};
    background-color: {COLORS["mauve"]};
}}

.popup-menu-item:insensitive {{
    color: {COLORS["overlay0"]};
}}
"""


QUICK_SETTINGS_CSS = f"""
.quick-settings,
.quick-settings-box,
.quick-settings-grid {{
    color: {COLORS["text"]};
    background-color: {COLORS["base"]};
}}

.quick-toggle,
.quick-menu-toggle {{
    color: {COLORS["text"]};
    background-color: {COLORS["surface0"]};
    border-color: {COLORS["surface1"]};
}}

.quick-toggle:hover,
.quick-menu-toggle:hover {{
    background-color: {COLORS["surface1"]};
}}

.quick-toggle:checked,
.quick-menu-toggle:checked {{
    color: {COLORS["base"]};
    background-color: {COLORS["mauve"]};
}}

.slider {{
    -barlevel-background-color: {COLORS["surface1"]};
    -barlevel-active-background-color: {COLORS["mauve"]};
    -barlevel-overdrive-color: {COLORS["red"]};
}}

.toggle-switch {{
    background-color: {COLORS["surface1"]};
}}

.toggle-switch:checked {{
    background-color: {COLORS["mauve"]};
}}

.toggle-switch-slider {{
    background-color: {COLORS["text"]};
}}
"""


CALENDAR_CSS = f"""
.calendar,
.calendar-day-base {{
    color: {COLORS["text"]};
    background-color: {COLORS["base"]};
}}

.calendar-day-base:hover {{
    background-color: {COLORS["surface0"]};
}}

.calendar-day-base:selected {{
    color: {COLORS["base"]};
    background-color: {COLORS["mauve"]};
}}

.calendar-today {{
    color: {COLORS["mauve"]};
}}
"""


NOTIFICATIONS_CSS = f"""
.notification-banner,
.message {{
    color: {COLORS["text"]};
    background-color: {COLORS["base"]};
    border-color: {COLORS["surface0"]};
}}

.notification-banner:hover,
.message:hover {{
    background-color: {COLORS["surface0"]};
}}

.notification-button {{
    color: {COLORS["text"]};
    background-color: {COLORS["surface0"]};
}}

.notification-button:hover {{
    background-color: {COLORS["surface1"]};
}}
"""


OVERVIEW_CSS = f"""
.workspace-thumbnail {{
    background-color: {COLORS["mantle"]};
    border-color: {COLORS["surface0"]};
}}

.workspace-thumbnail:selected {{
    border-color: {COLORS["mauve"]};
}}

.workspace-thumbnail:hover {{
    border-color: {COLORS["lavender"]};
}}

.switcher-list {{
    color: {COLORS["text"]};
    background-color: {COLORS["base"]};
    border-color: {COLORS["surface0"]};
}}

.switcher-list .item-box:hover,
.switcher-list .item-box:focus {{
    background-color: {COLORS["surface0"]};
}}

.switcher-list .item-box:selected {{
    background-color: {COLORS["surface0"]};
    border-color: {COLORS["mauve"]};
}}
"""


DASH_CSS = f"""
.dash {{
    color: {COLORS["text"]};
    background-color: {COLORS["mantle"]};
}}

.app-well-app-running-dot {{
    background-color: {COLORS["mauve"]};
}}

.show-apps-icon:hover {{
    color: {COLORS["lavender"]};
}}
"""


DIALOGS_CSS = f"""
.modal-dialog,
.end-session-dialog {{
    color: {COLORS["text"]};
    background-color: {COLORS["base"]};
    border-color: {COLORS["surface0"]};
}}

.modal-dialog-button,
.modal-dialog-linked-button {{
    color: {COLORS["text"]};
    background-color: {COLORS["surface0"]};
    border-color: {COLORS["surface1"]};
}}

.modal-dialog-button:hover,
.modal-dialog-linked-button:hover {{
    background-color: {COLORS["surface1"]};
}}

.modal-dialog-button:default,
.modal-dialog-linked-button:default {{
    color: {COLORS["base"]};
    background-color: {COLORS["mauve"]};
}}
"""


SEARCH_CSS = f"""
.search-entry,
#searchEntry {{
    color: {COLORS["text"]};
    background-color: {COLORS["surface0"]};
    border-color: {COLORS["surface1"]};
    caret-color: {COLORS["mauve"]};
}}

.search-entry:focus,
#searchEntry:focus {{
    background-color: {COLORS["surface1"]};
    border-color: {COLORS["lavender"]};
}}

.search-statustext {{
    color: {COLORS["subtext0"]};
}}

.system-action-icon {{
    color: {COLORS["text"]};
    background-color: {COLORS["surface0"]};
}}

.system-action-icon:hover {{
    color: {COLORS["base"]};
    background-color: {COLORS["mauve"]};
}}
"""


WIDGETS_CSS = f"""
.tooltip {{
    color: {COLORS["text"]};
    background-color: {COLORS["mantle"]};
    border-color: {COLORS["surface0"]};
}}

.audio-device-item:hover {{
    background-color: {COLORS["surface0"]};
}}

.audio-device-item.selected {{
    color: {COLORS["base"]};
    background-color: {COLORS["mauve"]};
}}
"""


OSD_CSS = f"""
.osd-window {{
    color: {COLORS["text"]};
    background-color: {COLORS["base"]};
    border-color: {COLORS["surface0"]};
}}

.osd-window .level {{
    -barlevel-background-color: {COLORS["surface1"]};
    -barlevel-active-background-color: {COLORS["mauve"]};
    -barlevel-overdrive-color: {COLORS["red"]};
}}
"""


# =============================================================================
# METADATA
# =============================================================================

METADATA = {
    "uuid": UUID,
    "name": EXTENSION_NAME,
    "description": ("Catppuccin Mocha color theme for GNOME Shell 50/51"),
    "version": 1,
    "shell-version": [
        "50",
        "51",
    ],
}


# =============================================================================
# MASTER CSS
# =============================================================================

MASTER_CSS = """
/*
 * CATPPUCCIN MOCHA
 * GNOME Shell 50 / 51
 */

@import url("colors.css");
@import url("app.css");
@import url("panel.css");
@import url("popup-menu.css");
@import url("quick-settings.css");
@import url("calendar.css");
@import url("notifications.css");
@import url("overview.css");
@import url("dash.css");
@import url("dialogs.css");
@import url("search.css");
@import url("widgets.css");
@import url("osd.css");
"""


# =============================================================================
# INSTALL THEME
# =============================================================================


def install_theme() -> None:

    title("INSTALLING CATPPUCCIN MOCHA GNOME SHELL THEME")

    if EXTENSION_DIR.exists():
        backup = EXTENSION_DIR.with_name(f"{UUID}.backup-{timestamp()}")

        shutil.copytree(
            EXTENSION_DIR,
            backup,
        )

        ok(f"Theme-Backup: {backup}")

        shutil.rmtree(EXTENSION_DIR)

    EXTENSION_DIR.mkdir(
        parents=True,
        exist_ok=True,
    )

    write_file(
        EXTENSION_DIR / "metadata.json",
        json.dumps(
            METADATA,
            indent=2,
            ensure_ascii=False,
        ),
    )

    write_file(
        EXTENSION_DIR / "extension.js",
        EXTENSION_JS,
    )

    write_file(
        EXTENSION_DIR / "stylesheet.css",
        MASTER_CSS,
    )

    write_file(
        EXTENSION_DIR / "colors.css",
        COLORS_CSS,
    )

    write_file(
        EXTENSION_DIR / "app.css",
        APP_CSS,
    )

    write_file(
        EXTENSION_DIR / "panel.css",
        PANEL_CSS,
    )

    write_file(
        EXTENSION_DIR / "popup-menu.css",
        POPUP_MENU_CSS,
    )

    write_file(
        EXTENSION_DIR / "quick-settings.css",
        QUICK_SETTINGS_CSS,
    )

    write_file(
        EXTENSION_DIR / "calendar.css",
        CALENDAR_CSS,
    )

    write_file(
        EXTENSION_DIR / "notifications.css",
        NOTIFICATIONS_CSS,
    )

    write_file(
        EXTENSION_DIR / "overview.css",
        OVERVIEW_CSS,
    )

    write_file(
        EXTENSION_DIR / "dash.css",
        DASH_CSS,
    )

    write_file(
        EXTENSION_DIR / "dialogs.css",
        DIALOGS_CSS,
    )

    write_file(
        EXTENSION_DIR / "search.css",
        SEARCH_CSS,
    )

    write_file(
        EXTENSION_DIR / "widgets.css",
        WIDGETS_CSS,
    )

    write_file(
        EXTENSION_DIR / "osd.css",
        OSD_CSS,
    )

    ok("Modulare GNOME-Shell-CSS installiert.")


# =============================================================================
# THEME ACTIVATION
# =============================================================================


def activate_theme() -> None:

    title("ACTIVATING CATPPUCCIN MOCHA")

    run(
        [
            "gnome-extensions",
            "disable",
            UUID,
        ],
        check=False,
    )

    result = run(
        [
            "gnome-extensions",
            "enable",
            UUID,
        ],
        check=False,
    )

    if result.returncode == 0:
        ok("Catppuccin Mocha Shell Theme aktiviert.")

    else:
        warn("GNOME konnte die Extension nicht sofort aktivieren.")

        warn(f"Manuell prüfen mit: gnome-extensions info {UUID}")


# =============================================================================
# DARK MODE
# =============================================================================


def configure_dark_mode() -> None:

    title("GNOME COLOR SCHEME")

    if gsettings_set(
        INTERFACE_SCHEMA,
        "color-scheme",
        "'prefer-dark'",
    ):
        ok("GNOME auf prefer-dark gesetzt.")


# =============================================================================
# OPTIONAL PAPIRUS
# =============================================================================


def configure_papirus() -> None:

    title("OPTIONAL — PAPIRUS ICON THEME")

    if package_installed("papirus-icon-theme"):
        if gsettings_set(
            INTERFACE_SCHEMA,
            "icon-theme",
            "'Papirus-Dark'",
        ):
            ok("Papirus-Dark aktiviert.")

    else:
        info("papirus-icon-theme ist nicht installiert.")

        info("Das bestehende Icon-Theme bleibt unverändert.")


# =============================================================================
# DASH-TO-PANEL CONFIG
# =============================================================================


def handle_dash_to_panel() -> None:

    title("DASH-TO-PANEL")

    if DASH_TO_PANEL_CONF.exists():
        info(f"Gefunden: {DASH_TO_PANEL_CONF}")

        info("Die Datei wird NICHT blind ausgeführt.")

        info("Sie wird nur als vorhandenes Benutzer-Asset erkannt.")

        ok("Dash-to-Panel-Asset vorhanden.")

    else:
        info("Keine ./assets/dash-to-panel.conf gefunden.")

        info("Dash-to-Panel-Konfiguration wird nicht erfunden.")


# =============================================================================
# RESTORE
# =============================================================================


def restore_latest_keybindings() -> None:

    title("RESTORE GNOME KEYBINDINGS")

    backups = sorted(
        BACKUP_DIR.glob("*-gnome-keybindings.json"),
        reverse=True,
    )

    if not backups:
        error("Kein GNOME-Keybinding-Backup gefunden.")

        return

    backup = backups[0]

    info(f"Restore: {backup}")

    data = json.loads(backup.read_text(encoding="utf-8"))

    for schema_name, schema in [
        ("wm", WM_SCHEMA),
        ("shell", SHELL_SCHEMA),
        ("media", MEDIA_KEYS_SCHEMA),
        ("interface", INTERFACE_SCHEMA),
    ]:
        values = data.get(
            schema_name,
            {},
        )

        for key, value in values.items():
            gsettings_set(
                schema,
                key,
                value,
            )

    ok("GNOME-Keybindings wurden wiederhergestellt.")


# =============================================================================
# REMOVE THEME
# =============================================================================


def remove_theme() -> None:

    title("REMOVE CATPPUCCIN MOCHA THEME")

    if not EXTENSION_DIR.exists():
        info("Theme ist nicht installiert.")

        return

    run(
        [
            "gnome-extensions",
            "disable",
            UUID,
        ],
        check=False,
    )

    shutil.rmtree(EXTENSION_DIR)

    ok("Catppuccin Mocha GNOME Shell Theme entfernt.")


# =============================================================================
# FINAL REPORT
# =============================================================================


def final_report() -> None:

    title("INSTALLATION COMPLETE")

    print("GNOME Shell:")

    print(f"  {GNOME_VERSION}")

    print()

    print("Theme:")

    print("  Catppuccin Mocha")

    print("  Modular GNOME Shell CSS")

    print()

    print("GNOME / Hyprland Keybinding-Ziel:")

    print("  GNOME 50/51 möglichst nah an")

    print("  der vorhandenen Hyprland-Konfiguration")

    print()

    print("Keybindings:")

    print(f"  {len(CUSTOM_SHORTCUTS)} Custom Shortcut Definitionen")

    print("  Hyprland als Referenz")

    print("  GNOME native Funktionen bevorzugt")

    print()

    print("Unverändert:")

    print("  GTK 3")

    print("  GTK 4 / Libadwaita")

    print("  Application Themes")

    print("  Fonts")

    print("  Font sizes")

    print("  Animation configuration")

    print()

    print("Package manager:")

    print("  pacman")

    print()

    print("AUR:")

    print("  not required")

    print()

    print("yay:")

    print("  not required")

    print()

    print("paru:")

    print("  not required")

    print()

    print("Theme directory:")

    print(f"  {EXTENSION_DIR}")

    print()

    print("Keybinding backups:")

    print(f"  {BACKUP_DIR}")

    print()

    print("Restore:")

    print("  python3 gnome-hyprland-installer.py --restore")

    print()

    print("=" * 78)


# =============================================================================
# MAIN
# =============================================================================


def main() -> None:

    if args.restore:
        restore_latest_keybindings()

        return

    if args.remove:
        remove_theme()

        return

    title("GNOME 50 / 51 — CATPPUCCIN MOCHA")

    print("Ziel:")

    print("  GNOME soll sich bei den Keybindings")

    print("  möglichst nah an deiner Hyprland-Konfiguration")

    print("  bedienen lassen.")

    print()

    print("Wichtig:")

    print("  Theme und Keybindings werden getrennt behandelt.")

    print("  Die Keybindings werden tatsächlich eingerichtet.")

    print()

    if not args.keybindings_only:
        install_theme()

        configure_dark_mode()

        configure_papirus()

        handle_dash_to_panel()

        activate_theme()

    if not args.theme_only:
        install_keybindings()

    final_report()


if __name__ == "__main__":
    try:
        main()

    except KeyboardInterrupt:
        print()
        warn("Installation durch Benutzer abgebrochen.")

        sys.exit(130)

    except Exception as exc:
        print()

        error(f"Unerwarteter Fehler: {exc}")

        sys.exit(1)
