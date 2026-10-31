#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""Install a Catppuccin Mocha GNOME Shell theme and Hyprland-inspired shortcuts.

Supported targets: Arch Linux, GNOME Shell 50 and 51.

The installer deliberately does not modify GTK themes, application themes,
fonts, font sizes, GNOME animation settings, or package installations.

Usage:
    python3 config-gnome.py
    python3 config-gnome.py --theme-only
    python3 config-gnome.py --keybindings-only
    python3 config-gnome.py --restore
    python3 config-gnome.py --remove
"""

from __future__ import annotations

import argparse
import ast
import json
import os
import re
import shlex
import shutil
import subprocess
import sys
import tempfile
from datetime import datetime
from pathlib import Path
from typing import Any, Iterable


# =============================================================================
# PATHS AND IDENTIFIERS
# =============================================================================

HOME = Path.home()
XDG_DATA_HOME = Path(os.environ.get("XDG_DATA_HOME", HOME / ".local" / "share")).expanduser()
DATA_HOME = XDG_DATA_HOME

SCRIPT_DIR = Path(__file__).resolve().parent
ASSETS_DIR = SCRIPT_DIR / "assets"
DASH_TO_PANEL_CONF = ASSETS_DIR / "dash-to-panel.conf"

APP_DATA_DIR = DATA_HOME / "gnome-hyprland-installer"
BACKUP_DIR = APP_DATA_DIR / "backups"
EXTENSIONS_DIR = DATA_HOME / "gnome-shell" / "extensions"

EXTENSION_UUID = "catppuccin-mocha-colors@local"
EXTENSION_NAME = "Catppuccin Mocha Shell Colors"
EXTENSION_DIR = EXTENSIONS_DIR / EXTENSION_UUID

CUSTOM_BASE_PATH = "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/"
MANAGED_PATH_PREFIX = "gnome-hyprland-"

MEDIA_KEYS_SCHEMA = "org.gnome.settings-daemon.plugins.media-keys"
CUSTOM_SHORTCUT_SCHEMA = "org.gnome.settings-daemon.plugins.media-keys.custom-keybinding"
WM_SCHEMA = "org.gnome.desktop.wm.keybindings"
SHELL_SCHEMA = "org.gnome.shell.keybindings"
INTERFACE_SCHEMA = "org.gnome.desktop.interface"

# The registry key belongs to MEDIA_KEYS_SCHEMA, not WM_SCHEMA.
CUSTOM_KEYBINDINGS_KEY = "custom-keybindings"


# =============================================================================
# CATPPUCCIN MOCHA PALETTE
# =============================================================================

COLORS = {
    "rosewater": "#f5e0dc",
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
# COMMAND-LINE OPTIONS
# =============================================================================

parser = argparse.ArgumentParser(
    description="Catppuccin Mocha GNOME Shell theme and Hyprland-style shortcuts"
)
mode_group = parser.add_mutually_exclusive_group()
mode_group.add_argument("--restore", action="store_true", help="Restore the latest keybinding backup")
mode_group.add_argument("--remove", action="store_true", help="Remove the installed GNOME Shell theme extension")
mode_group.add_argument("--theme-only", action="store_true", help="Install only the GNOME Shell theme")
mode_group.add_argument("--keybindings-only", action="store_true", help="Install only GNOME keybindings")
args = parser.parse_args()


# =============================================================================
# OUTPUT
# =============================================================================

def title(message: str) -> None:
    print("\n" + "=" * 78)
    print(message)
    print("=" * 78 + "\n")


def info(message: str) -> None:
    print(f"[INFO] {message}")


def success(message: str) -> None:
    print(f"[OK]   {message}")


def warning(message: str) -> None:
    print(f"[WARN] {message}")


def failure(message: str) -> None:
    print(f"[ERROR] {message}")


def timestamp() -> str:
    return datetime.now().strftime("%Y%m%d-%H%M%S-%f")


# =============================================================================
# PROCESS HELPERS
# =============================================================================

def command_exists(command: str) -> bool:
    return shutil.which(command) is not None


def run_command(
    command: list[str],
    *,
    check: bool = False,
    capture: bool = False,
) -> subprocess.CompletedProcess[str]:
    """Run a command without a shell and optionally print its exact argv."""
    if capture:
        return subprocess.run(
            command,
            check=check,
            text=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
        )

    print("$ " + shlex.join(command))
    return subprocess.run(command, check=check, text=True)


def require_commands(commands: Iterable[str]) -> None:
    missing = [name for name in commands if not command_exists(name)]
    if missing:
        for name in missing:
            failure(f"Required command not found: {name}")
        raise SystemExit(1)


def atomic_write(path: Path, content: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    temporary = path.with_name(path.name + ".tmp")
    temporary.write_text(content.rstrip() + "\n", encoding="utf-8")
    os.replace(temporary, path)


# =============================================================================
# GNOME VERSION AND ENVIRONMENT
# =============================================================================

def get_gnome_shell_version() -> str:
    if not command_exists("gnome-shell"):
        return "unknown"
    result = run_command(["gnome-shell", "--version"], capture=True)
    return (result.stdout or result.stderr).strip() or "unknown"


def get_gnome_major(version: str) -> int | None:
    match = re.search(r"(\d+)", version)
    return int(match.group(1)) if match else None


GNOME_VERSION = get_gnome_shell_version()
GNOME_MAJOR = get_gnome_major(GNOME_VERSION)


def check_environment(*, theme: bool, keybindings: bool) -> None:
    title("GNOME 50 / 51 — ENVIRONMENT CHECK")
    print(f"GNOME Shell: {GNOME_VERSION}")

    if GNOME_MAJOR in (50, 51):
        success("Supported GNOME Shell version detected.")
    elif GNOME_MAJOR is None:
        warning("GNOME Shell version could not be detected. Compatibility cannot be confirmed.")
    else:
        warning(f"This installer targets GNOME Shell 50/51; detected version: {GNOME_MAJOR}.")

    if theme:
        require_commands(["gnome-extensions", "gsettings"])
    if keybindings:
        require_commands(["gsettings"])

    if not os.environ.get("DBUS_SESSION_BUS_ADDRESS"):
        warning("No session D-Bus address is available. GNOME settings may be inaccessible.")


# =============================================================================
# GSETTINGS SERIALIZATION AND ACCESS
# =============================================================================

def gvariant_string(value: str) -> str:
    """Return a safely escaped GVariant string literal."""
    escaped = (
        value.replace("\\", "\\\\")
        .replace("'", "\\'")
        .replace("\n", "\\n")
        .replace("\r", "\\r")
        .replace("\t", "\\t")
    )
    return "'" + escaped + "'"


def gvariant_string_array(values: Iterable[str]) -> str:
    return "[" + ", ".join(gvariant_string(value) for value in values) + "]"


def parse_gvariant(value: str) -> Any:
    """Parse common GSettings output (strings, arrays, booleans and numbers)."""
    try:
        return ast.literal_eval(value)
    except (ValueError, SyntaxError):
        return value.strip()


def gsettings_get(schema: str, key: str, *, path: str | None = None) -> str | None:
    # Relocatable schemas use the documented SCHEMA:PATH form.
    target = f"{schema}:{path}" if path is not None else schema
    result = run_command(["gsettings", "get", target, key], capture=True)
    if result.returncode != 0:
        return None
    return result.stdout.strip()


def gsettings_set(schema: str, key: str, value: str, *, path: str | None = None) -> bool:
    target = f"{schema}:{path}" if path is not None else schema
    result = run_command(["gsettings", "set", target, key, value], capture=True)
    if result.returncode != 0:
        detail = (result.stderr or result.stdout).strip()
        warning(f"Could not set {target} {key}: {detail or 'gsettings returned an error'}")
        return False
    return True


def gsettings_has_key(schema: str, key: str) -> bool:
    result = run_command(["gsettings", "list-keys", schema], capture=True)
    return result.returncode == 0 and key in result.stdout.splitlines()


def gsettings_schema_values(schema: str) -> dict[str, str]:
    result = run_command(["gsettings", "list-recursively", schema], capture=True)
    if result.returncode != 0:
        return {}

    values: dict[str, str] = {}
    for line in result.stdout.splitlines():
        parts = line.split(" ", 2)
        if len(parts) == 3:
            _schema_name, key, value = parts
            values[key] = value
    return values


def read_accelerators(value: str) -> list[str]:
    parsed = parse_gvariant(value)
    if isinstance(parsed, list):
        return [item for item in parsed if isinstance(item, str) and item]
    if isinstance(parsed, str) and parsed:
        return [parsed]
    return []


def canonical_binding(binding: str) -> str:
    return re.sub(r"\s+", "", binding).casefold()


# =============================================================================
# KEYBINDING BACKUPS
# =============================================================================

def get_custom_paths() -> list[str]:
    raw = gsettings_get(MEDIA_KEYS_SCHEMA, CUSTOM_KEYBINDINGS_KEY)
    if raw is None:
        return []
    parsed = parse_gvariant(raw)
    if not isinstance(parsed, list):
        warning("The current custom-keybindings registry could not be parsed.")
        return []
    return [str(item) for item in parsed if isinstance(item, str)]


def get_custom_entry(path: str) -> dict[str, str]:
    entry: dict[str, str] = {}
    for key in ("name", "command", "binding"):
        value = gsettings_get(CUSTOM_SHORTCUT_SCHEMA, key, path=path)
        entry[key] = parse_gvariant(value) if value is not None else ""
    return entry


def save_keybinding_backup() -> Path:
    BACKUP_DIR.mkdir(parents=True, exist_ok=True)

    data: dict[str, Any] = {
        "format_version": 2,
        "created": datetime.now().isoformat(timespec="seconds"),
        "gnome_shell_version": GNOME_VERSION,
        "schemas": {
            WM_SCHEMA: gsettings_schema_values(WM_SCHEMA),
            SHELL_SCHEMA: gsettings_schema_values(SHELL_SCHEMA),
            MEDIA_KEYS_SCHEMA: gsettings_schema_values(MEDIA_KEYS_SCHEMA),
            INTERFACE_SCHEMA: {
                "color-scheme": gsettings_get(INTERFACE_SCHEMA, "color-scheme")
            },
        },
        "custom_entries": {},
    }

    paths = get_custom_paths()
    data["custom_entries"] = {path: get_custom_entry(path) for path in paths}

    backup_path = BACKUP_DIR / f"{timestamp()}-gnome-keybindings.json"
    atomic_write(backup_path, json.dumps(data, indent=2, ensure_ascii=False))
    success(f"Keybinding backup created: {backup_path}")
    return backup_path


def restore_latest_keybindings() -> bool:
    title("RESTORE GNOME KEYBINDINGS")
    backups = sorted(BACKUP_DIR.glob("*-gnome-keybindings.json"), reverse=True)
    if not backups:
        failure(f"No keybinding backup found in {BACKUP_DIR}")
        return False

    backup_path = backups[0]
    info(f"Restoring backup: {backup_path}")
    try:
        data = json.loads(backup_path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as exc:
        failure(f"Could not read backup: {exc}")
        return False

    success_count = 0
    failure_count = 0

    # Restore the relocatable shortcut entries before restoring their registry.
    for path, entry in data.get("custom_entries", {}).items():
        for key in ("name", "command", "binding"):
            value = entry.get(key, "")
            if isinstance(value, str) and gsettings_set(
                CUSTOM_SHORTCUT_SCHEMA, key, gvariant_string(value), path=path
            ):
                success_count += 1
            else:
                failure_count += 1

    schemas = data.get("schemas", {})
    for schema in (WM_SCHEMA, SHELL_SCHEMA, MEDIA_KEYS_SCHEMA, INTERFACE_SCHEMA):
        for key, raw_value in schemas.get(schema, {}).items():
            if raw_value is None:
                continue
            if gsettings_set(schema, key, raw_value):
                success_count += 1
            else:
                failure_count += 1

    # Verify the restored custom shortcut registry, which is the critical index.
    expected = data.get("schemas", {}).get(MEDIA_KEYS_SCHEMA, {}).get(CUSTOM_KEYBINDINGS_KEY)
    if expected is not None:
        actual = gsettings_get(MEDIA_KEYS_SCHEMA, CUSTOM_KEYBINDINGS_KEY)
        if parse_gvariant(actual or "") != parse_gvariant(expected):
            failure_count += 1
            failure("The custom shortcut registry does not match the backup after restore.")

    if failure_count == 0:
        success(f"Backup restored and verified ({success_count} settings).")
        return True

    warning(f"Restore completed with {failure_count} failed or unverified settings.")
    return False


# =============================================================================
# NATIVE GNOME / MUTTER KEYBINDINGS
# =============================================================================

# These are configured through their native GNOME schemas, not as custom commands.
# GSettings keybinding values in these schemas are string arrays (type 'as').

def build_native_bindings() -> list[dict[str, str]]:
    bindings: list[dict[str, str]] = [
        {"schema": WM_SCHEMA, "key": "close", "binding": "<Super>q", "label": "Close window"},
        {"schema": WM_SCHEMA, "key": "toggle-maximized", "binding": "<Super>d", "label": "Toggle maximize"},
        {"schema": WM_SCHEMA, "key": "toggle-fullscreen", "binding": "<Super>f", "label": "Toggle fullscreen"},
        {"schema": WM_SCHEMA, "key": "switch-to-workspace-left", "binding": "<Control><Super>Left", "label": "Previous workspace"},
        {"schema": WM_SCHEMA, "key": "switch-to-workspace-right", "binding": "<Control><Super>Right", "label": "Next workspace"},
    ]

    for number in range(1, 11):
        digit = "0" if number == 10 else str(number)
        bindings.append({
            "schema": WM_SCHEMA,
            "key": f"switch-to-workspace-{number}",
            "binding": f"<Super>{digit}",
            "label": f"Switch to workspace {number}",
        })
        bindings.append({
            "schema": WM_SCHEMA,
            "key": f"move-to-workspace-{number}",
            "binding": f"<Alt><Super>{digit}",
            "label": f"Move window to workspace {number}",
        })

    return bindings


def existing_native_bindings() -> dict[str, list[tuple[str, str]]]:
    found: dict[str, list[tuple[str, str]]] = {}
    for schema in (WM_SCHEMA, SHELL_SCHEMA, MEDIA_KEYS_SCHEMA):
        for key, raw in gsettings_schema_values(schema).items():
            for binding in read_accelerators(raw):
                found.setdefault(canonical_binding(binding), []).append((schema, key))
    return found


def existing_custom_bindings() -> dict[str, tuple[str, str]]:
    found: dict[str, tuple[str, str]] = {}
    for path in get_custom_paths():
        entry = get_custom_entry(path)
        binding = entry.get("binding", "")
        if binding:
            found[canonical_binding(binding)] = (entry.get("name", "Custom shortcut"), path)
    return found


def configure_native_bindings() -> tuple[int, int, list[str]]:
    configured = 0
    skipped = 0
    notes: list[str] = []

    active_custom = existing_custom_bindings()
    for item in build_native_bindings():
        schema = item["schema"]
        key = item["key"]
        binding = item["binding"]
        canonical = canonical_binding(binding)

        if not gsettings_has_key(schema, key):
            skipped += 1
            notes.append(f"{item['label']}: schema key is unavailable")
            continue

        custom_collision = active_custom.get(canonical)
        if custom_collision:
            skipped += 1
            notes.append(
                f"{item['label']}: preserved existing custom shortcut '{custom_collision[0]}'"
            )
            continue

        # Do not create two Mutter actions on the same accelerator.
        current = existing_native_bindings()
        conflicts = current.get(canonical, [])
        other_conflicts = [(s, k) for s, k in conflicts if not (s == schema and k == key)]
        if other_conflicts:
            skipped += 1
            notes.append(f"{item['label']}: accelerator already used by {other_conflicts[0][1]}")
            continue

        value = gvariant_string_array([binding])
        if not gsettings_set(schema, key, value):
            skipped += 1
            notes.append(f"{item['label']}: GSettings write failed")
            continue

        actual = gsettings_get(schema, key)
        if actual is not None and read_accelerators(actual) == [binding]:
            configured += 1
        else:
            skipped += 1
            notes.append(f"{item['label']}: value could not be verified")

    return configured, skipped, notes


# =============================================================================
# CUSTOM SHORTCUT DEFINITIONS
# =============================================================================

CUSTOM_SHORTCUTS: list[dict[str, str]] = []
GNOME_APPLICATION_SHORTCUTS: list[dict[str, str]] = []
UNSUPPORTED_FEATURES: list[str] = [
    "Hyprland floating-window mode: no safe native GNOME equivalent is configured.",
    "Hyprland pin/always-on-top mode: requires a compatible GNOME Shell extension.",
    "Hyprland scratchpad/special workspace: requires a dedicated GNOME Shell extension or workflow.",
    "Hyprland directional window focus: not mapped to wmctrl move/resize commands.",
]


def add_shortcut(
    name: str,
    binding: str,
    command: str,
    *,
    group: str = "Hyprland utilities",
) -> None:
    target = GNOME_APPLICATION_SHORTCUTS if group == "GNOME applications" else CUSTOM_SHORTCUTS
    target.append({"name": name, "binding": binding, "command": command, "group": group})


def first_available(commands: Iterable[str]) -> str | None:
    for command in commands:
        executable = command.split(None, 1)[0]
        if command_exists(executable):
            return command
    return None


def build_shortcuts() -> None:
    CUSTOM_SHORTCUTS.clear()
    GNOME_APPLICATION_SHORTCUTS.clear()

    # -------------------------------------------------------------------------
    # GNOME applications: intentionally kept separate from Hyprland apps.
    # -------------------------------------------------------------------------
    if command_exists("nautilus"):
        add_shortcut(
            "GNOME: Files",
            "<Super>e",
            "nautilus --new-window",
            group="GNOME applications",
        )
    else:
        info("GNOME Files shortcut skipped: 'nautilus' is not installed.")

    if command_exists("gnome-control-center"):
        add_shortcut(
            "GNOME: Settings",
            "<Super>i",
            "gnome-control-center",
            group="GNOME applications",
        )
    else:
        info("GNOME Settings shortcut skipped: 'gnome-control-center' is not installed.")

    # -------------------------------------------------------------------------
    # Hyprland-style launcher and application shortcuts.
    # -------------------------------------------------------------------------
    launcher = first_available(["fuzzel", "qs"])
    if launcher:
        label = "Search / Fuzzel" if launcher == "fuzzel" else "Search / Quickshell"
        add_shortcut(f"Launcher: {label}", "<Super>space", launcher)

    terminal = first_available(["kitty", "foot", "alacritty", "wezterm", "gnome-terminal"])
    if terminal:
        add_shortcut("App: Terminal", "<Super>Return", terminal)
        add_shortcut("App: Terminal (alternate)", "<Control><Alt>t", terminal)

    browser = first_available(["brave", "firefox", "librewolf", "chromium"])
    if browser:
        add_shortcut("App: Browser", "<Super>w", browser)

    if command_exists("firefox"):
        add_shortcut("App: Firefox", "<Super><Alt>w", "firefox")
    if command_exists("mullvad-browser"):
        add_shortcut("App: Mullvad Browser", "<Control><Super>w", "mullvad-browser -P")
    if command_exists("librewolf"):
        add_shortcut("App: LibreWolf", "<Super><Shift>w", "librewolf")
    if command_exists("torbrowser-launcher"):
        add_shortcut("App: Tor Browser", "<Super><Alt><Shift>w", "torbrowser-launcher")
    if command_exists("qalculate-gtk"):
        add_shortcut("App: Qalculate", "XF86Calculator", "qalculate-gtk")
    if command_exists("gnome-system-monitor"):
        add_shortcut("App: System monitor", "<Control><Shift>Escape", "gnome-system-monitor")

    # -------------------------------------------------------------------------
    # Clipboard and text utilities.
    # -------------------------------------------------------------------------
    if all(command_exists(item) for item in ("cliphist", "fuzzel", "wl-copy")):
        add_shortcut(
            "Utilities: Clipboard history",
            "<Super>v",
            "bash -lc 'cliphist list | fuzzel --dmenu | cliphist decode | wl-copy'",
        )

    emoji_script = HOME / ".config" / "hypr" / "hyprland" / "scripts" / "fuzzel-emoji.sh"
    if emoji_script.is_file() and command_exists("bash") and command_exists("fuzzel") and command_exists("wl-copy"):
        add_shortcut(
            "Utilities: Emoji picker",
            "<Super>period",
            f"bash {shlex.quote(str(emoji_script))} copy",
        )

    snip_search = HOME / ".config" / "hypr" / "hyprland" / "scripts" / "snip_to_search.sh"
    if snip_search.is_file() and command_exists("bash"):
        add_shortcut(
            "Utilities: Region search",
            "<Super><Shift>a",
            f"bash {shlex.quote(str(snip_search))}",
        )

    if all(command_exists(item) for item in ("grim", "slurp", "tesseract", "wl-copy")):
        add_shortcut(
            "Utilities: OCR selected region",
            "<Super><Shift>x",
            "bash -lc 'tmp=$(mktemp --suffix=.png); trap \"rm -f \\\"$tmp\\\"\" EXIT; grim -g \"$(slurp)\" \"$tmp\" && tesseract \"$tmp\" stdout 2>/dev/null | wl-copy'",
        )

    # GNOME's Print key is intentionally left to its native screenshot UI.
    # Use a separate accelerator for OBS to avoid stealing the screenshot key.
    if command_exists("obs"):
        add_shortcut("App: OBS", "<Control>Print", "obs")

    if command_exists("gnome-screenshot"):
        add_shortcut("Utilities: Interactive screenshot", "<Super><Shift>s", "gnome-screenshot -i")

    if command_exists("hyprpicker"):
        add_shortcut("Utilities: Color picker", "<Super><Shift>c", "hyprpicker -a")

    # -------------------------------------------------------------------------
    # GNOME shell and session utilities.
    # -------------------------------------------------------------------------
    add_shortcut(
        "Shell: Toggle dark mode",
        "<Control><Super><Shift>d",
        "bash -lc 'current=$(gsettings get org.gnome.desktop.interface color-scheme); if [[ $current == *prefer-dark* ]]; then gsettings set org.gnome.desktop.interface color-scheme prefer-light; else gsettings set org.gnome.desktop.interface color-scheme prefer-dark; fi'",
    )

    if command_exists("gnome-control-center"):
        add_shortcut(
            "Shell: Open wallpaper settings",
            "<Control><Super>t",
            "gnome-control-center background",
        )

    if command_exists("playerctl"):
        add_shortcut("Media: Play or pause", "<Super>m", "playerctl play-pause")
        add_shortcut("Media: Next track", "<Super><Shift>n", "playerctl next")
        add_shortcut("Media: Previous track", "<Super><Shift>b", "playerctl previous")
        add_shortcut("Media: Play or pause (alternate)", "<Super><Shift>p", "playerctl play-pause")

    if command_exists("wpctl"):
        add_shortcut("Media: Toggle mute", "<Super><Shift>m", "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle")

    if command_exists("loginctl"):
        add_shortcut("Session: Lock screen", "<Super>l", "loginctl lock-session")
    if command_exists("systemctl"):
        add_shortcut("Session: Suspend", "<Super><Shift>l", "systemctl suspend")

    record_script = HOME / ".config" / "quickshell" / "scripts" / "videos" / "record.sh"
    if record_script.is_file() and command_exists("bash"):
        script = shlex.quote(str(record_script))
        add_shortcut("Utilities: Record selected region", "<Super><Shift>r", f"bash {script}")
        add_shortcut("Utilities: Record full screen", "<Control><Alt>r", f"bash {script} --fullscreen")
        add_shortcut(
            "Utilities: Record screen with audio",
            "<Shift><Alt><Super>r",
            f"bash {script} --fullscreen --sound",
        )

    if command_exists("qs"):
        add_shortcut(
            "Shell: Restart Quickshell",
            "<Control><Super>r",
            "bash -lc 'pkill -x quickshell 2>/dev/null || true; pkill -x qs 2>/dev/null || true; nohup qs >/dev/null 2>&1 &'",
        )


def deduplicate_shortcuts(shortcuts: list[dict[str, str]]) -> tuple[list[dict[str, str]], list[str]]:
    seen: set[str] = set()
    result: list[dict[str, str]] = []
    skipped: list[str] = []

    for item in shortcuts:
        key = canonical_binding(item["binding"])
        if key in seen:
            skipped.append(f"{item['name']} ({item['binding']}): duplicate in installer definition")
            continue
        seen.add(key)
        result.append(item)

    return result, skipped


# =============================================================================
# CUSTOM SHORTCUT INSTALLATION
# =============================================================================

def managed_custom_path(index: int) -> str:
    return f"{CUSTOM_BASE_PATH}{MANAGED_PATH_PREFIX}{index}/"


def write_custom_entry(path: str, item: dict[str, str]) -> bool:
    values = {
        "name": item["name"],
        "command": item["command"],
        "binding": item["binding"],
    }

    for key, value in values.items():
        if not gsettings_set(CUSTOM_SHORTCUT_SCHEMA, key, gvariant_string(value), path=path):
            return False

    for key, expected in values.items():
        actual = gsettings_get(CUSTOM_SHORTCUT_SCHEMA, key, path=path)
        if actual is None or parse_gvariant(actual) != expected:
            warning(f"Verification failed for '{item['name']}' ({key}).")
            return False

    return True


def install_custom_shortcuts(shortcuts: list[dict[str, str]]) -> tuple[int, int, list[str]]:
    if not gsettings_has_key(MEDIA_KEYS_SCHEMA, CUSTOM_KEYBINDINGS_KEY):
        failure(
            f"The required key '{CUSTOM_KEYBINDINGS_KEY}' is not available in {MEDIA_KEYS_SCHEMA}."
        )
        return 0, len(shortcuts), ["Custom shortcut registry key is unavailable"]

    existing_paths = get_custom_paths()
    managed_paths = {path for path in existing_paths if MANAGED_PATH_PREFIX in path}
    preserved_paths = [path for path in existing_paths if path not in managed_paths]

    # Avoid stealing accelerators already assigned to another GNOME action.
    native_in_use = existing_native_bindings()
    custom_in_use = existing_custom_bindings()
    accepted: list[dict[str, str]] = []
    skipped_notes: list[str] = []
    seen: set[str] = set()

    for item in shortcuts:
        binding_key = canonical_binding(item["binding"])
        if binding_key in seen:
            skipped_notes.append(f"{item['name']}: duplicate accelerator in installer definition")
            continue
        seen.add(binding_key)

        if binding_key in native_in_use:
            owners = ", ".join(key for _schema, key in native_in_use[binding_key])
            skipped_notes.append(f"{item['name']} ({item['binding']}): already assigned to native GNOME action ({owners})")
            continue

        existing_custom = custom_in_use.get(binding_key)
        if existing_custom and existing_custom[1] not in managed_paths:
            skipped_notes.append(f"{item['name']} ({item['binding']}): preserved existing custom shortcut '{existing_custom[0]}'")
            continue

        accepted.append(item)

    registered_entries: list[tuple[dict[str, str], str]] = []

    for index, item in enumerate(accepted):
        path = managed_custom_path(index)
        if write_custom_entry(path, item):
            registered_entries.append((item, path))
        else:
            warning(f"Shortcut was not registered: {item['name']}")

    new_paths = [path for _item, path in registered_entries]
    target_registry = preserved_paths + new_paths
    registry_value = gvariant_string_array(target_registry)

    if not gsettings_set(MEDIA_KEYS_SCHEMA, CUSTOM_KEYBINDINGS_KEY, registry_value):
        failure("The custom shortcut registry could not be updated. No new shortcuts are considered installed.")
        # Keep the previous registry intact wherever possible.
        gsettings_set(MEDIA_KEYS_SCHEMA, CUSTOM_KEYBINDINGS_KEY, gvariant_string_array(existing_paths))
        return 0, len(shortcuts), skipped_notes + ["Registry update failed; entries were not activated"]

    actual_registry_raw = gsettings_get(MEDIA_KEYS_SCHEMA, CUSTOM_KEYBINDINGS_KEY)
    actual_registry = parse_gvariant(actual_registry_raw or "")
    if actual_registry != target_registry:
        failure("The custom shortcut registry failed post-write verification.")
        gsettings_set(MEDIA_KEYS_SCHEMA, CUSTOM_KEYBINDINGS_KEY, gvariant_string_array(existing_paths))
        return 0, len(shortcuts), skipped_notes + ["Registry verification failed; previous registry restored"]

    # Verify every registered entry again after the registry commit.
    verified = 0
    verified_paths: list[str] = []
    for item, path in registered_entries:
        entry = get_custom_entry(path)
        if (
            entry.get("name") == item["name"]
            and entry.get("command") == item["command"]
            and entry.get("binding") == item["binding"]
        ):
            verified += 1
            verified_paths.append(path)
        else:
            warning(f"Registered shortcut could not be verified: {item['name']}")

    if verified != len(new_paths):
        # Remove unverified installer-owned entries from the active registry.
        fallback_registry = preserved_paths + verified_paths
        if not gsettings_set(
            MEDIA_KEYS_SCHEMA,
            CUSTOM_KEYBINDINGS_KEY,
            gvariant_string_array(fallback_registry),
        ):
            failure("Could not remove unverified entries from the active shortcut registry.")
            return 0, len(shortcuts), skipped_notes + ["Registry rollback failed"]

    failed_or_skipped = (len(accepted) - verified) + len(skipped_notes)
    return verified, failed_or_skipped, skipped_notes


# =============================================================================
# KEYBINDING REPORTING
# =============================================================================

def print_keybinding_plan() -> None:
    title("HYPRLAND → GNOME KEYBINDINGS")
    print("Goal:")
    print("  Make GNOME 50/51 behave as close as reasonably possible to the")
    print("  existing Hyprland workflow, while preferring native GNOME actions.")
    print()
    print("Native GNOME / Mutter bindings:")
    for item in build_native_bindings():
        print(f"  {item['binding']:<30} {item['label']}")
    print()
    print("GNOME applications (kept separate from Hyprland application shortcuts):")
    for item in GNOME_APPLICATION_SHORTCUTS:
        print(f"  {item['binding']:<30} {item['name']}")
    print()
    print("Custom Hyprland-style shortcuts:")
    for item in CUSTOM_SHORTCUTS:
        print(f"  {item['binding']:<30} {item['name']}")
    print()
    print("Custom shortcuts are checked against existing GNOME bindings before registration.")


def install_keybindings(backup_path: Path) -> dict[str, int]:
    build_shortcuts()
    custom_shortcuts, duplicate_notes = deduplicate_shortcuts(
        GNOME_APPLICATION_SHORTCUTS + CUSTOM_SHORTCUTS
    )
    # Keep GNOME application bindings first so their shortcuts are considered
    # before optional Hyprland application mappings.

    print_keybinding_plan()
    info(f"Using pre-installation backup: {backup_path}")

    title("APPLYING NATIVE GNOME KEYBINDINGS")
    native_ok, native_skipped, native_notes = configure_native_bindings()
    if native_ok:
        success(f"{native_ok} native GNOME/Mutter bindings configured and verified.")
    else:
        info("No native GNOME/Mutter bindings were changed.")

    # Do not create a custom shortcut if its accelerator has just been assigned
    # by one of the native Mutter settings above.
    title("INSTALLING CUSTOM GNOME SHORTCUTS")
    custom_ok, custom_skipped, custom_notes = install_custom_shortcuts(custom_shortcuts)

    if custom_ok:
        success(f"{custom_ok} custom shortcuts registered and verified.")
    else:
        warning("No custom shortcuts were verified as installed.")

    for note in duplicate_notes + native_notes + custom_notes:
        info(f"Skipped: {note}")

    title("KEYBINDING SUMMARY")
    print(f"Native GNOME/Mutter bindings verified: {native_ok}")
    print(f"Custom shortcuts verified:             {custom_ok}")
    print(f"Skipped or unavailable definitions:    {native_skipped + custom_skipped + len(duplicate_notes)}")
    print(f"Backup: {backup_path}")
    print()
    print("GNOME-native window and workspace actions are managed through Mutter.")
    print("Custom commands are registered through the media-keys custom-keybinding schema.")

    return {
        "native": native_ok,
        "custom": custom_ok,
        "skipped": native_skipped + custom_skipped + len(duplicate_notes),
    }


# =============================================================================
# GNOME SHELL EXTENSION SOURCE
# =============================================================================

EXTENSION_JS = r'''import Gio from "gi://Gio";
import St from "gi://St";

import { Extension } from "resource:///org/gnome/shell/extensions/extension.js";

export default class CatppuccinMochaShellColors extends Extension {
    enable() {
        this._theme = St.ThemeContext.get_for_stage(global.stage).get_theme();
        this._stylesheet = Gio.File.new_for_path(`${this.path}/stylesheet.css`);

        try {
            this._theme.load_stylesheet(this._stylesheet);
            log("Catppuccin Mocha: GNOME Shell stylesheet loaded");
        } catch (error) {
            logError(error, "Catppuccin Mocha: failed to load GNOME Shell stylesheet");
            this._theme = null;
            this._stylesheet = null;
            throw error;
        }
    }

    disable() {
        if (this._theme && this._stylesheet) {
            try {
                this._theme.unload_stylesheet(this._stylesheet);
                log("Catppuccin Mocha: GNOME Shell stylesheet unloaded");
            } catch (error) {
                logError(error, "Catppuccin Mocha: failed to unload GNOME Shell stylesheet");
            }
        }

        this._theme = null;
        this._stylesheet = null;
    }
}
'''


# =============================================================================
# MODULAR GNOME SHELL CSS
# =============================================================================

COLORS_CSS = f'''/* Catppuccin Mocha palette reference — GNOME Shell only.
 * The stylesheet uses explicit colors instead of browser-only CSS variables.
 */
/* Rosewater: {COLORS['rosewater']} | Flamingo: {COLORS['flamingo']} | Pink: {COLORS['pink']} */
/* Mauve: {COLORS['mauve']} | Red: {COLORS['red']} | Peach: {COLORS['peach']} */
/* Yellow: {COLORS['yellow']} | Green: {COLORS['green']} | Teal: {COLORS['teal']} */
/* Blue: {COLORS['blue']} | Lavender: {COLORS['lavender']} | Text: {COLORS['text']} */
/* Surface 0: {COLORS['surface0']} | Surface 1: {COLORS['surface1']} | Base: {COLORS['base']} */
'''

APP_CSS = f'''
/* Global GNOME Shell surfaces. This does not theme GTK applications. */
stage {{
    color: {COLORS['text']};
    background-color: {COLORS['crust']};
}}

StWidget {{
    color: {COLORS['text']};
}}

StEntry {{
    color: {COLORS['text']};
    background-color: {COLORS['surface0']};
    border: 1px solid {COLORS['surface1']};
    border-radius: 10px;
    caret-color: {COLORS['mauve']};
    selection-background-color: {COLORS['mauve']};
}}

StEntry:focus {{
    background-color: {COLORS['surface1']};
    border-color: {COLORS['lavender']};
}}

StScrollBar {{
    -slider-background-color: {COLORS['surface1']};
    -slider-hover-background-color: {COLORS['surface2']};
    -slider-active-background-color: {COLORS['mauve']};
    -slider-border-color: transparent;
}}

.link {{ color: {COLORS['blue']}; }}
.link:hover {{ color: {COLORS['lavender']}; }}
'''

PANEL_CSS = f'''
/* Top panel */
#panel {{
    color: {COLORS['text']};
    background-color: {COLORS['mantle']};
    border-bottom: 1px solid {COLORS['surface0']};
}}

#panel .panel-button {{
    color: {COLORS['text']};
    background-color: transparent;
    border-radius: 9px;
}}

#panel .panel-button:hover,
#panel .panel-button:focus {{
    color: {COLORS['text']};
    background-color: {COLORS['surface0']};
}}

#panel .panel-button:active,
#panel .panel-button:checked,
#panel .panel-button:overview {{
    color: {COLORS['base']};
    background-color: {COLORS['mauve']};
}}

#panel StIcon,
#panel .panel-button StLabel {{
    color: {COLORS['text']};
}}
'''

POPUP_MENU_CSS = f'''
/*
 * Popup menu surfaces are intentionally split into two layers.
 * The BoxPointer and arrow are transparent and shadowless. The rounded
 * popup-menu-content actor owns the visible surface. This prevents a square
 * shadow or background from sticking out below rounded popup corners.
 */
.popup-menu-boxpointer,
.candidate-popup-boxpointer {{
    background-color: transparent;
    border: none;
    box-shadow: none;
    -arrow-background-color: transparent;
    -arrow-border-color: transparent;
    -arrow-border-width: 0;
    -arrow-border-radius: 0;
    -arrow-box-shadow: none;
}}

.popup-menu-content {{
    color: {COLORS['text']};
    background-color: {COLORS['base']};
    border: 1px solid {COLORS['surface0']};
    border-radius: 16px;
    box-shadow: none;
    padding: 7px;
}}

.popup-sub-menu {{
    color: {COLORS['text']};
    background-color: {COLORS['base']};
    border: 1px solid {COLORS['surface0']};
    border-radius: 12px;
    box-shadow: none;
}}

.popup-menu-item {{
    color: {COLORS['subtext1']};
    background-color: transparent;
    border-radius: 9px;
    padding-top: 7px;
    padding-bottom: 7px;
}}

.popup-menu-item StLabel,
.popup-menu-item StIcon,
.popup-menu-item .popup-menu-icon,
.popup-inactive-menu-item StLabel,
.popup-inactive-menu-item StIcon {{
    color: {COLORS['subtext1']};
}}

.popup-menu-item:hover,
.popup-menu-item:focus,
.popup-menu-item:selected,
.popup-menu-item.selected {{
    color: {COLORS['text']};
    background-color: {COLORS['surface0']};
}}

.popup-menu-item:hover StLabel,
.popup-menu-item:hover StIcon,
.popup-menu-item:hover .popup-menu-icon,
.popup-menu-item:focus StLabel,
.popup-menu-item:focus StIcon,
.popup-menu-item:focus .popup-menu-icon,
.popup-menu-item:selected StLabel,
.popup-menu-item:selected StIcon,
.popup-menu-item.selected StLabel,
.popup-menu-item.selected StIcon {{
    color: {COLORS['text']};
}}

.popup-menu-item:active,
.popup-menu-item:checked {{
    color: {COLORS['base']};
    background-color: {COLORS['mauve']};
}}

.popup-menu-item:active StLabel,
.popup-menu-item:active StIcon,
.popup-menu-item:active .popup-menu-icon,
.popup-menu-item:checked StLabel,
.popup-menu-item:checked StIcon,
.popup-menu-item:checked .popup-menu-icon {{
    color: {COLORS['base']};
}}

.popup-menu-item:insensitive,
.popup-menu-item:insensitive StLabel,
.popup-menu-item:insensitive StIcon {{
    color: {COLORS['overlay0']};
}}

.popup-menu-ornament {{ color: {COLORS['mauve']}; }}
'''

QUICK_SETTINGS_CSS = f'''
/* Quick Settings and system toggles */
.quick-settings,
.quick-settings-box,
.quick-settings-grid {{
    color: {COLORS['text']};
    background-color: {COLORS['base']};
}}

.quick-toggle,
.quick-menu-toggle {{
    color: {COLORS['text']};
    background-color: {COLORS['surface0']};
    border: 1px solid {COLORS['surface1']};
    border-radius: 13px;
}}

.quick-toggle StIcon,
.quick-menu-toggle StIcon {{ color: {COLORS['text']}; }}

.quick-toggle:hover,
.quick-menu-toggle:hover {{
    color: {COLORS['text']};
    background-color: {COLORS['surface1']};
}}

.quick-toggle:hover StIcon,
.quick-menu-toggle:hover StIcon {{ color: {COLORS['text']}; }}

.quick-toggle:checked,
.quick-menu-toggle:checked {{
    color: {COLORS['base']};
    background-color: {COLORS['mauve']};
    border-color: {COLORS['mauve']};
}}

.quick-toggle:checked StIcon,
.quick-menu-toggle:checked StIcon {{ color: {COLORS['base']}; }}

.quick-toggle:insensitive,
.quick-toggle:insensitive StIcon {{ color: {COLORS['overlay0']}; }}

.toggle-switch {{ background-color: {COLORS['surface1']}; }}
.toggle-switch:checked {{ background-color: {COLORS['mauve']}; }}
.toggle-switch-slider {{ background-color: {COLORS['text']}; }}

.slider {{
    -barlevel-background-color: {COLORS['surface1']};
    -barlevel-active-background-color: {COLORS['mauve']};
    -barlevel-overdrive-color: {COLORS['red']};
}}
'''

CALENDAR_CSS = f'''
/* Calendar and date picker */
.calendar,
.calendar-day-base {{
    color: {COLORS['text']};
    background-color: {COLORS['base']};
}}

.calendar-day-base:hover,
.calendar-day-base:focus {{
    color: {COLORS['text']};
    background-color: {COLORS['surface0']};
}}

.calendar-day-base:selected {{
    color: {COLORS['base']};
    background-color: {COLORS['mauve']};
}}

.calendar-today {{ color: {COLORS['mauve']}; }}
'''

NOTIFICATIONS_CSS = f'''
/* Notification banners and message tray */
.notification-banner,
.message {{
    color: {COLORS['text']};
    background-color: {COLORS['base']};
    border: 1px solid {COLORS['surface0']};
    border-radius: 16px;
    box-shadow: none;
}}

.notification-banner StIcon,
.notification-banner StLabel,
.message StIcon,
.message StLabel {{ color: {COLORS['text']}; }}

.notification-banner:hover,
.message:hover {{ background-color: {COLORS['surface0']}; }}

.notification-button {{
    color: {COLORS['text']};
    background-color: {COLORS['surface0']};
    border-radius: 9px;
}}

.notification-button:hover {{ background-color: {COLORS['surface1']}; }}
'''

OVERVIEW_CSS = f'''
/* Overview, workspace switcher and search results */
#overview {{ color: {COLORS['text']}; background-color: {COLORS['crust']}; }}

.workspace-thumbnail {{
    background-color: {COLORS['mantle']};
    border: 1px solid {COLORS['surface0']};
    border-radius: 12px;
}}

.workspace-thumbnail:selected {{ border-color: {COLORS['mauve']}; }}
.workspace-thumbnail:hover {{ border-color: {COLORS['lavender']}; }}

.switcher-list {{
    color: {COLORS['text']};
    background-color: {COLORS['base']};
    border: 1px solid {COLORS['surface0']};
    border-radius: 16px;
    box-shadow: none;
}}

.switcher-list .item-box {{ color: {COLORS['text']}; border-radius: 10px; }}
.switcher-list .item-box:hover,
.switcher-list .item-box:focus,
.switcher-list .item-box:selected {{
    color: {COLORS['text']};
    background-color: {COLORS['surface0']};
}}

.search-provider-icon,
.list-search-result,
.grid-search-result > .overview-icon {{ border-radius: 12px; }}
'''

DASH_CSS = f'''
/* Dash and application grid */
.dash {{
    color: {COLORS['text']};
    background-color: {COLORS['mantle']};
    border: 1px solid {COLORS['surface0']};
    border-radius: 18px;
}}

.app-well-app-running-dot {{
    background-color: {COLORS['mauve']};
    border-radius: 3px;
}}

.show-apps-icon {{ color: {COLORS['text']}; }}
.show-apps:hover .show-apps-icon,
.show-apps:focus .show-apps-icon,
.show-apps:checked .show-apps-icon {{ color: {COLORS['mauve']}; }}

/* Expanded application folders remain solid Mocha grey at every size. */
.app-folder-dialog,
.app-folder-dialog-container,
.app-folder-popup-bin {{
    color: {COLORS['text']};
    background-color: {COLORS['base']};
    border: 1px solid {COLORS['surface0']};
    border-radius: 20px;
    box-shadow: none;
}}

.app-folder-dialog StLabel,
.app-folder-dialog-container StLabel,
.app-folder-popup-bin StLabel {{ color: {COLORS['text']}; }}

.app-folder-dialog .folder-name-entry,
.app-folder-dialog-container .folder-name-entry {{
    color: {COLORS['text']};
    background-color: {COLORS['surface0']};
    border: 1px solid {COLORS['surface1']};
    border-radius: 9px;
    caret-color: {COLORS['mauve']};
    selection-background-color: {COLORS['mauve']};
}}

.app-folder-popup {{
    -arrow-background-color: transparent;
    -arrow-border-color: transparent;
    -arrow-border-width: 0;
    -arrow-border-radius: 0;
    -arrow-box-shadow: none;
}}

.app-folder-popup-bin {{ padding: 10px; }}
.app-well-app.app-folder > .overview-icon {{
    background-color: {COLORS['surface0']};
    border: 1px solid {COLORS['surface1']};
    border-radius: 14px;
}}
'''

DIALOGS_CSS = f'''
/* GNOME Shell modal dialogs */
.modal-dialog,
.end-session-dialog {{
    color: {COLORS['text']};
    background-color: {COLORS['base']};
    border: 1px solid {COLORS['surface0']};
    border-radius: 18px;
    box-shadow: none;
}}

.modal-dialog StLabel,
.end-session-dialog StLabel {{ color: {COLORS['text']}; }}

.modal-dialog-button,
.modal-dialog-linked-button {{
    color: {COLORS['text']};
    background-color: {COLORS['surface0']};
    border: 1px solid {COLORS['surface1']};
    border-radius: 10px;
}}

.modal-dialog-button:hover,
.modal-dialog-linked-button:hover {{
    color: {COLORS['text']};
    background-color: {COLORS['surface1']};
}}

.modal-dialog-button:default,
.modal-dialog-linked-button:default {{
    color: {COLORS['base']};
    background-color: {COLORS['mauve']};
    border-color: {COLORS['mauve']};
}}

.modal-dialog-button:default StLabel,
.modal-dialog-linked-button:default StLabel {{ color: {COLORS['base']}; }}
'''

SEARCH_CSS = f'''
/* Search field and system actions */
.search-entry,
#searchEntry {{
    color: {COLORS['text']};
    background-color: {COLORS['surface0']};
    border: 1px solid {COLORS['surface1']};
    border-radius: 12px;
    caret-color: {COLORS['mauve']};
    selection-background-color: {COLORS['mauve']};
}}

.search-entry:focus,
#searchEntry:focus {{
    background-color: {COLORS['surface1']};
    border-color: {COLORS['lavender']};
}}

.search-statustext {{ color: {COLORS['subtext0']}; }}

.system-action-icon {{
    color: {COLORS['text']};
    background-color: {COLORS['surface0']};
    border-radius: 14px;
}}

.system-action-icon StIcon {{ color: {COLORS['text']}; }}
.system-action-icon:hover {{
    color: {COLORS['base']};
    background-color: {COLORS['mauve']};
}}
.system-action-icon:hover StIcon {{ color: {COLORS['base']}; }}
'''

WIDGETS_CSS = f'''
/* Tooltips, audio device rows and generic Shell widgets */
.tooltip {{
    color: {COLORS['text']};
    background-color: {COLORS['mantle']};
    border: 1px solid {COLORS['surface0']};
    border-radius: 9px;
    box-shadow: none;
}}

.audio-device-item {{ color: {COLORS['text']}; border-radius: 9px; }}
.audio-device-item:hover {{ background-color: {COLORS['surface0']}; }}
.audio-device-item.selected {{
    color: {COLORS['base']};
    background-color: {COLORS['mauve']};
}}
.audio-device-item.selected StIcon,
.audio-device-item.selected StLabel {{ color: {COLORS['base']}; }}
'''

OSD_CSS = f'''
/* On-screen display */
.osd-window {{
    color: {COLORS['text']};
    background-color: {COLORS['base']};
    border: 1px solid {COLORS['surface0']};
    border-radius: 18px;
    box-shadow: none;
}}

.osd-window StIcon,
.osd-window StLabel {{ color: {COLORS['text']}; }}

.osd-window .level {{
    -barlevel-background-color: {COLORS['surface1']};
    -barlevel-active-background-color: {COLORS['mauve']};
    -barlevel-overdrive-color: {COLORS['red']};
}}
'''

CSS_MODULES: dict[str, str] = {
    "colors.css": COLORS_CSS,
    "app.css": APP_CSS,
    "panel.css": PANEL_CSS,
    "popup-menu.css": POPUP_MENU_CSS,
    "quick-settings.css": QUICK_SETTINGS_CSS,
    "calendar.css": CALENDAR_CSS,
    "notifications.css": NOTIFICATIONS_CSS,
    "overview.css": OVERVIEW_CSS,
    "dash.css": DASH_CSS,
    "dialogs.css": DIALOGS_CSS,
    "search.css": SEARCH_CSS,
    "widgets.css": WIDGETS_CSS,
    "osd.css": OSD_CSS,
}

MASTER_CSS = "\n\n".join(
    ["/* Generated Catppuccin Mocha GNOME Shell stylesheet. */"]
    + [content for name, content in CSS_MODULES.items() if name != "colors.css"]
)

METADATA = {
    "uuid": EXTENSION_UUID,
    "name": EXTENSION_NAME,
    "description": "Catppuccin Mocha theme for GNOME Shell 50 and 51.",
    "version": 2,
    "shell-version": ["50", "51"],
}


def validate_css(css: str) -> bool:
    """Perform basic structural checks before handing CSS to GNOME Shell."""
    if css.count("{") != css.count("}"):
        failure("Generated stylesheet has unbalanced braces.")
        return False
    if "@import" in css or "--ctp-" in css:
        failure("Generated stylesheet contains an unsupported import or variable construct.")
        return False
    return True


# =============================================================================
# THEME INSTALLATION AND ACTIVATION
# =============================================================================

def write_extension_files(target: Path) -> None:
    target.mkdir(parents=True, exist_ok=True)
    atomic_write(target / "metadata.json", json.dumps(METADATA, indent=2, ensure_ascii=False))
    atomic_write(target / "extension.js", EXTENSION_JS)
    for filename, content in CSS_MODULES.items():
        atomic_write(target / filename, content)
    atomic_write(target / "stylesheet.css", MASTER_CSS)


def install_theme() -> bool:
    title("INSTALLING CATPPUCCIN MOCHA GNOME SHELL THEME")
    if GNOME_MAJOR not in (50, 51):
        warning("The detected Shell version is outside the declared compatibility range. Installation will continue, but activation is not guaranteed.")

    if not validate_css(MASTER_CSS):
        return False

    EXTENSIONS_DIR.mkdir(parents=True, exist_ok=True)
    BACKUP_DIR.mkdir(parents=True, exist_ok=True)
    staging = Path(tempfile.mkdtemp(prefix=f".{EXTENSION_UUID}-staging-", dir=EXTENSIONS_DIR))
    rollback_dir: Path | None = None
    backup_path: Path | None = None

    try:
        write_extension_files(staging)
        metadata = json.loads((staging / "metadata.json").read_text(encoding="utf-8"))
        if metadata.get("uuid") != EXTENSION_UUID or not {"50", "51"}.issuperset(metadata.get("shell-version", [])):
            raise ValueError("Generated extension metadata failed validation")

        if EXTENSION_DIR.exists():
            backup_path = BACKUP_DIR / f"{timestamp()}-{EXTENSION_UUID}"
            shutil.copytree(EXTENSION_DIR, backup_path)
            rollback_dir = EXTENSIONS_DIR / f".{EXTENSION_UUID}-previous-{timestamp()}"
            os.replace(EXTENSION_DIR, rollback_dir)

        os.replace(staging, EXTENSION_DIR)
        if rollback_dir and rollback_dir.exists():
            shutil.rmtree(rollback_dir)

        success(f"GNOME Shell extension files installed: {EXTENSION_DIR}")
        if backup_path:
            success(f"Previous extension backed up: {backup_path}")
        for filename in ["metadata.json", "extension.js", "stylesheet.css", *CSS_MODULES.keys()]:
            print(f"[WRITE] {EXTENSION_DIR / filename}")
        return True

    except Exception as exc:
        failure(f"Theme installation failed: {exc}")
        if rollback_dir and rollback_dir.exists() and not EXTENSION_DIR.exists():
            os.replace(rollback_dir, EXTENSION_DIR)
        return False
    finally:
        if staging.exists():
            shutil.rmtree(staging, ignore_errors=True)


def activate_theme() -> bool:
    title("ACTIVATING CATPPUCCIN MOCHA")
    if not EXTENSION_DIR.is_dir() or not (EXTENSION_DIR / "metadata.json").is_file():
        failure("The extension directory or metadata.json is missing.")
        return False

    list_result = run_command(["gnome-extensions", "list"], capture=True)
    listed = list_result.returncode == 0 and EXTENSION_UUID in list_result.stdout.splitlines()
    if not listed:
        info("The extension is not yet present in the GNOME extension registry; requesting activation anyway.")

    enable_result = run_command(["gnome-extensions", "enable", EXTENSION_UUID], capture=True)
    if enable_result.returncode != 0:
        detail = (enable_result.stderr or enable_result.stdout).strip()
        warning(f"GNOME did not enable the extension: {detail or 'unknown extension manager error'}")
        warning("The extension files are installed. Log out and back in, then run: gnome-extensions enable " + EXTENSION_UUID)
        return False

    enabled_result = run_command(["gnome-extensions", "list", "--enabled"], capture=True)
    if enabled_result.returncode == 0 and EXTENSION_UUID in enabled_result.stdout.splitlines():
        success("Catppuccin Mocha GNOME Shell extension is enabled.")
        return True

    info_result = run_command(["gnome-extensions", "info", EXTENSION_UUID], capture=True)
    info_text = (info_result.stdout or "") + (info_result.stderr or "")
    if info_result.returncode == 0 and re.search(r"state\s*:\s*enabled", info_text, re.IGNORECASE):
        success("Catppuccin Mocha GNOME Shell extension is enabled.")
        return True

    warning("GNOME accepted the enable request, but the enabled state could not be verified.")
    warning("Check with: gnome-extensions info " + EXTENSION_UUID)
    return False


def set_dark_mode() -> bool:
    title("GNOME COLOR SCHEME")
    if not gsettings_has_key(INTERFACE_SCHEMA, "color-scheme"):
        warning("The GNOME color-scheme setting is unavailable; it was not changed.")
        return False

    if gsettings_set(INTERFACE_SCHEMA, "color-scheme", gvariant_string("prefer-dark")):
        actual = gsettings_get(INTERFACE_SCHEMA, "color-scheme")
        if actual is not None and parse_gvariant(actual) == "prefer-dark":
            success("GNOME color scheme set to prefer-dark and verified.")
            return True
    warning("Could not verify the GNOME dark color scheme setting.")
    return False


def handle_dash_to_panel_asset() -> None:
    title("DASH-TO-PANEL ASSET")
    if DASH_TO_PANEL_CONF.is_file():
        info(f"Found: {DASH_TO_PANEL_CONF}")
        info("The asset is not executed or imported automatically.")
    else:
        info("No assets/dash-to-panel.conf file was found.")


def remove_theme() -> bool:
    title("REMOVE CATPPUCCIN MOCHA GNOME SHELL THEME")
    if not EXTENSION_DIR.exists():
        info("The Catppuccin Mocha extension is not installed.")
        return True

    run_command(["gnome-extensions", "disable", EXTENSION_UUID], capture=True)
    backup_path = BACKUP_DIR / f"{timestamp()}-{EXTENSION_UUID}-removed"
    BACKUP_DIR.mkdir(parents=True, exist_ok=True)
    shutil.copytree(EXTENSION_DIR, backup_path)
    shutil.rmtree(EXTENSION_DIR)
    success(f"Theme removed. A copy was preserved at: {backup_path}")
    return True


# =============================================================================
# FINAL REPORT
# =============================================================================

def final_report(
    *,
    theme_installed: bool | None,
    theme_enabled: bool | None,
    dark_mode_set: bool | None,
    keybinding_stats: dict[str, int] | None,
) -> None:
    title("INSTALLATION REPORT")
    print(f"GNOME Shell: {GNOME_VERSION}")
    print("Target: GNOME Shell 50 / 51")
    print()

    if theme_installed is not None:
        print("Catppuccin Mocha GNOME Shell theme:")
        print(f"  Files installed: {'yes' if theme_installed else 'no'}")
        if theme_enabled is not None:
            print(f"  Extension enabled: {'yes (verified)' if theme_enabled else 'no / not verified'}")
        print(f"  Theme directory: {EXTENSION_DIR}")
        print()

    if dark_mode_set is not None:
        print(f"GNOME color scheme: {'prefer-dark (verified)' if dark_mode_set else 'not verified'}")
        print()

    if keybinding_stats is not None:
        print("Keybindings:")
        print(f"  Native GNOME / Mutter bindings: {keybinding_stats['native']} verified")
        print(f"  Custom shortcuts:              {keybinding_stats['custom']} verified")
        print(f"  Skipped / unavailable:         {keybinding_stats['skipped']}")
        print("  GNOME applications are listed separately from Hyprland app shortcuts.")
        print(f"  Backup directory: {BACKUP_DIR}")
        print("  Restore: python3 config-gnome.py --restore")
        print()

    print("Not modified directly by this installer:")
    print("  GTK 3 theme files or CSS overrides")
    print("  GTK 4 / Libadwaita theme files or CSS overrides")
    print("  Application theme selections")
    print("  Icon theme")
    print("  Fonts and font sizes")
    print("  GNOME animation settings")
    print("  Package installations")
    print()
    print("Color preference:")
    print("  GNOME color-scheme is set to prefer-dark when the theme is installed.")
    print("  Applications that follow this preference may choose their own dark variant.")
    print()
    print("Scope:")
    print("  Catppuccin styling applies to GNOME Shell UI elements only.")
    print("  GTK application CSS and third-party application windows are not replaced.")
    print("=" * 78)


# =============================================================================
# MAIN
# =============================================================================

def main() -> int:
    if os.geteuid() == 0:
        failure("Do not run this installer as root. Run it as your desktop user.")
        return 1

    if args.restore:
        require_commands(["gsettings"])
        return 0 if restore_latest_keybindings() else 1

    if args.remove:
        require_commands(["gnome-extensions"])
        return 0 if remove_theme() else 1

    do_theme = not args.keybindings_only
    do_keybindings = not args.theme_only
    check_environment(theme=do_theme, keybindings=do_keybindings)

    theme_installed: bool | None = None
    theme_enabled: bool | None = None
    dark_mode_set: bool | None = None
    keybinding_stats: dict[str, int] | None = None
    keybinding_backup: Path | None = None
    critical_failure = False

    # Capture the original color scheme and all relevant shortcut schemas before
    # the theme installer changes prefer-dark or the keybinding installer runs.
    if do_keybindings:
        title("BACKUP — EXISTING GNOME KEYBINDINGS")
        keybinding_backup = save_keybinding_backup()

    title("GNOME 50 / 51 — CATPPUCCIN MOCHA")
    print("The visual theme and keybinding configuration are managed separately.")
    print("GNOME-native actions are preferred; custom shortcuts are used where appropriate.")
    print("GNOME Files and GNOME Settings are kept in a separate application group.")

    if do_theme:
        theme_installed = install_theme()
        if theme_installed:
            dark_mode_set = set_dark_mode()
            theme_enabled = activate_theme()
            handle_dash_to_panel_asset()
        else:
            critical_failure = True

    if do_keybindings:
        assert keybinding_backup is not None
        keybinding_stats = install_keybindings(keybinding_backup)
        if keybinding_stats["native"] == 0 and keybinding_stats["custom"] == 0:
            critical_failure = True

    final_report(
        theme_installed=theme_installed,
        theme_enabled=theme_enabled,
        dark_mode_set=dark_mode_set,
        keybinding_stats=keybinding_stats,
    )

    # A missing extension activation or a failed settings operation must not be
    # presented as a fully successful installation.
    if do_theme and (not theme_installed or not theme_enabled):
        critical_failure = True
    if do_theme and dark_mode_set is False:
        warning("The Shell theme may still be installed, but the dark color scheme was not verified.")

    return 1 if critical_failure else 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except KeyboardInterrupt:
        print()
        warning("Installation cancelled by the user.")
        raise SystemExit(130)
    except Exception as exc:
        print()
        failure(f"Unexpected error: {exc}")
        raise SystemExit(1)
