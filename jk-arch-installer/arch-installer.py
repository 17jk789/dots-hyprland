#!/usr/bin/env python3

from __future__ import annotations

import argparse
import curses
import json
import os
import platform
import shlex
import shutil
import signal
import socket
import subprocess
import sys
import time

from dataclasses import dataclass
from datetime import datetime
from pathlib import Path
from typing import Any


# ============================================================
# ARCH LINUX + HYPRLAND ULTIMATE INSTALLER
# ============================================================
#
# Designed for:
#
#     Official Arch Linux ISO
#
# Main purpose:
#
#     1. Check live environment
#     2. Install archinstall if missing
#     3. Generate an archinstall configuration
#     4. Launch official archinstall
#     5. Install Arch Linux
#     6. Install ONLY the Hyprland desktop/compositor stack
#
# NO:
#
#     GNOME
#     KDE Plasma
#     XFCE
#     Cinnamon
#     MATE
#     LXQt
#     Other desktop environments
#
# Hyprland is installed using official Arch packages.
#
# IMPORTANT:
#
# Partitioning is intentionally left to archinstall's UI.
# The Python launcher never guesses which disk the user wants.
#
# ============================================================


# ============================================================
# PATHS
# ============================================================

BASE_DIR = Path(__file__).resolve().parent

LOG_DIR = BASE_DIR / "logs"

CONFIG_DIR = BASE_DIR / "generated"

LOG_DIR.mkdir(
    parents=True,
    exist_ok=True,
)

CONFIG_DIR.mkdir(
    parents=True,
    exist_ok=True,
)

TIMESTAMP = datetime.now().strftime(
    "%Y-%m-%d_%H-%M-%S"
)

LOG_FILE = (
    LOG_DIR
    / f"arch_hyprland_{TIMESTAMP}.log"
)

ARCHINSTALL_CONFIG = (
    CONFIG_DIR
    / f"archinstall_hyprland_{TIMESTAMP}.json"
)


# ============================================================
# GLOBAL STATE
# ============================================================

STOP_REQUESTED = False

LANGUAGE = "de"


# ============================================================
# COLORS
# ============================================================

class Colors:

    RESET = "\033[0m"

    BOLD = "\033[1m"

    RED = "\033[31m"
    GREEN = "\033[32m"
    YELLOW = "\033[33m"
    BLUE = "\033[34m"
    CYAN = "\033[36m"
    MAGENTA = "\033[35m"
    WHITE = "\033[37m"


def paint(
    text: str,
    color: str,
) -> str:

    if not sys.stdout.isatty():

        return text

    return (
        f"{color}"
        f"{text}"
        f"{Colors.RESET}"
    )


def info(text: str) -> None:

    print(
        paint(
            f"[INFO] {text}",
            Colors.BLUE,
        )
    )


def success(text: str) -> None:

    print(
        paint(
            f"[ OK ] {text}",
            Colors.GREEN,
        )
    )


def warning(text: str) -> None:

    print(
        paint(
            f"[WARN] {text}",
            Colors.YELLOW,
        )
    )


def error(text: str) -> None:

    print(
        paint(
            f"[ERROR] {text}",
            Colors.RED,
        ),
        file=sys.stderr,
    )


def command_output(text: str) -> None:

    print(
        paint(
            f"[CMD ] {text}",
            Colors.CYAN,
        )
    )


# ============================================================
# TRANSLATIONS
# ============================================================

TRANSLATIONS = {

    "de": {

        "title":
            "ARCH LINUX + HYPRLAND INSTALLER",

        "subtitle":
            "Automatisierter Archinstall-Launcher mit reinem Hyprland-Profil",

        "language":
            "Sprache auswählen",

        "language_invalid":
            "Bitte 1 oder 2 auswählen.",

        "system_check":
            "SYSTEMPRÜFUNG",

        "environment":
            "Umgebung",

        "distribution":
            "Distribution",

        "kernel":
            "Kernel",

        "architecture":
            "Architektur",

        "machine":
            "Hardware",

        "firmware":
            "Firmware",

        "uefi":
            "UEFI",

        "bios":
            "Legacy BIOS",

        "root":
            "Root-Rechte vorhanden.",

        "root_required":
            "Dieses Programm muss als root ausgeführt werden.",

        "pacman":
            "pacman verfügbar.",

        "python":
            "Python verfügbar.",

        "archinstall":
            "archinstall verfügbar.",

        "archinstall_missing":
            "archinstall wurde nicht gefunden.",

        "install_archinstall":
            "archinstall jetzt über pacman installieren?",

        "network":
            "Netzwerk",

        "network_ok":
            "Internetverbindung scheint verfügbar zu sein.",

        "network_failed":
            "Internetverbindung konnte nicht geprüft werden.",

        "arch_warning":
            "Das System sieht nicht wie das offizielle Arch-Linux-ISO aus.",

        "continue":
            "Trotzdem fortfahren?",

        "profile":
            "INSTALLATIONSPROFIL",

        "profile_arch":
            "Arch Linux",

        "profile_hyprland":
            "Hyprland",

        "profile_only":
            "Nur Arch Linux + Hyprland",

        "profile_no_other":
            "Keine GNOME-, KDE-, XFCE- oder andere Desktop-Umgebung.",

        "packages":
            "Hyprland-Pakete",

        "mode":
            "STARTMODUS",

        "guided":
            "Archinstall Guided",

        "guided_description":
            "Normale Archinstall-Oberfläche mit automatisch vorbereitetem Hyprland-Profil.",

        "dry_run":
            "Dry-Run",

        "dry_description":
            "Konfiguration prüfen, ohne die Installation auszuführen.",

        "start":
            "Installation starten?",

        "security":
            "SICHERHEITSHINWEIS",

        "disk_warning":
            "Die von dir in archinstall ausgewählte Festplatte kann gelöscht/formatiert werden.",

        "backup":
            "Stelle sicher, dass wichtige Daten gesichert sind.",

        "generated":
            "Konfiguration erzeugt.",

        "launch":
            "Archinstall wird gestartet.",

        "finished":
            "Archinstall wurde beendet.",

        "exit_code":
            "Exit-Code",

        "log":
            "Log",

        "cancelled":
            "Abgebrochen.",

        "failed":
            "Fehlgeschlagen.",

        "ready":
            "System ist bereit.",

        "hyprland_only":
            "DESKTOP: HYPRLAND ONLY",

        "selection_help":
            "↑↓ bewegen | ENTER auswählen | Q abbrechen",

        "yes":
            "ja",

        "no":
            "nein",

        "invalid":
            "Bitte j/n eingeben.",

        "post_install":
            "Hyprland wird als Teil der Archinstall-Konfiguration installiert.",

    },

    "en": {

        "title":
            "ARCH LINUX + HYPRLAND INSTALLER",

        "subtitle":
            "Automated archinstall launcher with a Hyprland-only profile",

        "language":
            "Select language",

        "language_invalid":
            "Please select 1 or 2.",

        "system_check":
            "SYSTEM CHECK",

        "environment":
            "Environment",

        "distribution":
            "Distribution",

        "kernel":
            "Kernel",

        "architecture":
            "Architecture",

        "machine":
            "Hardware",

        "firmware":
            "Firmware",

        "uefi":
            "UEFI",

        "bios":
            "Legacy BIOS",

        "root":
            "Root privileges available.",

        "root_required":
            "This program must be executed as root.",

        "pacman":
            "pacman available.",

        "python":
            "Python available.",

        "archinstall":
            "archinstall available.",

        "archinstall_missing":
            "archinstall was not found.",

        "install_archinstall":
            "Install archinstall using pacman now?",

        "network":
            "Network",

        "network_ok":
            "Internet connection appears to be available.",

        "network_failed":
            "Internet connection could not be verified.",

        "arch_warning":
            "The environment does not look like the official Arch Linux ISO.",

        "continue":
            "Continue anyway?",

        "profile":
            "INSTALLATION PROFILE",

        "profile_arch":
            "Arch Linux",

        "profile_hyprland":
            "Hyprland",

        "profile_only":
            "Arch Linux + Hyprland only",

        "profile_no_other":
            "No GNOME, KDE, XFCE or other desktop environment.",

        "packages":
            "Hyprland packages",

        "mode":
            "START MODE",

        "guided":
            "Archinstall Guided",

        "guided_description":
            "Normal Archinstall interface with a prepared Hyprland profile.",

        "dry_run":
            "Dry-Run",

        "dry_description":
            "Validate the configuration without performing installation.",

        "start":
            "Start installation?",

        "security":
            "SECURITY WARNING",

        "disk_warning":
            "The disk selected inside archinstall may be erased/formatted.",

        "backup":
            "Make sure important data is backed up.",

        "generated":
            "Configuration generated.",

        "launch":
            "Starting archinstall.",

        "finished":
            "Archinstall has exited.",

        "exit_code":
            "Exit code",

        "log":
            "Log",

        "cancelled":
            "Cancelled.",

        "failed":
            "Failed.",

        "ready":
            "System is ready.",

        "hyprland_only":
            "DESKTOP: HYPRLAND ONLY",

        "selection_help":
            "↑↓ move | ENTER select | Q cancel",

        "yes":
            "yes",

        "no":
            "no",

        "invalid":
            "Please enter y/n.",

        "post_install":
            "Hyprland will be installed as part of the archinstall configuration.",

    },
}


def tr(
    key: str,
) -> str:

    return TRANSLATIONS[
        LANGUAGE
    ].get(
        key,
        key,
    )


# ============================================================
# LOGGER
# ============================================================

class Logger:

    def __init__(
        self,
        path: Path,
    ) -> None:

        self.path = path

    def write(
        self,
        message: str,
    ) -> None:

        timestamp = datetime.now().strftime(
            "%Y-%m-%d %H:%M:%S"
        )

        with self.path.open(
            "a",
            encoding="utf-8",
        ) as file:

            file.write(
                f"[{timestamp}] "
                f"{message}\n"
            )


LOGGER = Logger(
    LOG_FILE
)


def log(
    message: str,
) -> None:

    LOGGER.write(
        message
    )


# ============================================================
# SIGNALS
# ============================================================

def handle_signal(
    signum: int,
    frame: Any,
) -> None:

    global STOP_REQUESTED

    STOP_REQUESTED = True

    warning(
        (
            "Abbruch angefordert."
            if LANGUAGE == "de"
            else
            "Abort requested."
        )
    )

    log(
        f"Received signal {signum}"
    )


signal.signal(
    signal.SIGINT,
    handle_signal,
)

signal.signal(
    signal.SIGTERM,
    handle_signal,
)


# ============================================================
# SYSTEM DETECTION
# ============================================================

def read_os_release() -> dict[str, str]:

    result: dict[str, str] = {}

    path = Path(
        "/etc/os-release"
    )

    if not path.exists():

        return result

    try:

        lines = path.read_text(
            encoding="utf-8",
            errors="replace",
        ).splitlines()

    except OSError:

        return result

    for line in lines:

        if "=" not in line:

            continue

        key, value = line.split(
            "=",
            1,
        )

        value = value.strip()

        if (
            len(value) >= 2
            and value.startswith('"')
            and value.endswith('"')
        ):

            value = value[1:-1]

        result[key] = value

    return result


def distribution_id() -> str:

    return read_os_release().get(
        "ID",
        "unknown",
    ).lower()


def pretty_distribution() -> str:

    return read_os_release().get(
        "PRETTY_NAME",
        "Unknown Linux",
    )


def architecture() -> str:

    return platform.machine()


def kernel() -> str:

    return platform.release()


def hardware() -> str:

    return platform.platform()


def uefi_available() -> bool:

    return Path(
        "/sys/firmware/efi"
    ).exists()


# ============================================================
# COMMAND UTILITIES
# ============================================================

def command_exists(
    command: str,
) -> bool:

    return shutil.which(
        command
    ) is not None


def run_quiet(
    command: list[str],
    timeout: int = 10,
) -> bool:

    try:

        result = subprocess.run(
            command,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
            timeout=timeout,
            check=False,
        )

        return result.returncode == 0

    except (
        OSError,
        subprocess.SubprocessError,
    ):

        return False


# ============================================================
# NETWORK
# ============================================================

def network_available() -> bool:

    if command_exists("ping"):

        if run_quiet(
            [
                "ping",
                "-c",
                "1",
                "-W",
                "3",
                "archlinux.org",
            ],
            timeout=6,
        ):

            return True

    if command_exists("curl"):

        if run_quiet(
            [
                "curl",
                "-fsS",
                "--max-time",
                "5",
                "https://archlinux.org/",
            ],
            timeout=7,
        ):

            return True

    return False


# ============================================================
# LANGUAGE
# ============================================================

def select_language() -> None:

    global LANGUAGE

    print()

    print(
        "=" * 70
    )

    print(
        "ARCH LINUX + HYPRLAND INSTALLER"
    )

    print(
        "Select language / Sprache auswählen"
    )

    print(
        "=" * 70
    )

    print()

    print(
        "1. Deutsch"
    )

    print(
        "2. English"
    )

    print()

    while True:

        try:

            choice = input(
                "Auswahl / Choice [1/2]: "
            ).strip()

        except EOFError:

            LANGUAGE = "de"

            return

        if choice == "1":

            LANGUAGE = "de"

            return

        if choice == "2":

            LANGUAGE = "en"

            return

        warning(
            tr("language_invalid")
        )


# ============================================================
# YES / NO
# ============================================================

def ask_yes_no(
    question: str,
    default: bool = False,
) -> bool:

    if LANGUAGE == "de":

        suffix = (
            "[J/n]"
            if default
            else
            "[j/N]"
        )

    else:

        suffix = (
            "[Y/n]"
            if default
            else
            "[y/N]"
        )

    while True:

        try:

            answer = input(
                f"{question} {suffix}: "
            ).strip().lower()

        except EOFError:

            return default

        if not answer:

            return default

        if answer in {
            "j",
            "ja",
            "y",
            "yes",
        }:

            return True

        if answer in {
            "n",
            "nein",
            "no",
        }:

            return False

        warning(
            tr("invalid")
        )


# ============================================================
# HEADER
# ============================================================

def clear_screen() -> None:

    if sys.stdout.isatty():

        print(
            "\033[2J\033[H",
            end="",
        )


def header() -> None:

    print()

    print(
        paint(
            "=" * 70,
            Colors.CYAN,
        )
    )

    print(
        paint(
            tr("title"),
            Colors.BOLD + Colors.CYAN,
        )
    )

    print(
        tr("subtitle")
    )

    print()

    print(
        paint(
            tr("hyprland_only"),
            Colors.BOLD + Colors.MAGENTA,
        )
    )

    print(
        paint(
            "=" * 70,
            Colors.CYAN,
        )
    )


# ============================================================
# SYSTEM INFORMATION
# ============================================================

def show_system_information() -> None:

    print()

    print(
        paint(
            tr("environment"),
            Colors.BOLD + Colors.MAGENTA,
        )
    )

    print(
        "-" * 70
    )

    print(
        f"{tr('distribution'):<18}: "
        f"{pretty_distribution()}"
    )

    print(
        f"{tr('kernel'):<18}: "
        f"{kernel()}"
    )

    print(
        f"{tr('architecture'):<18}: "
        f"{architecture()}"
    )

    print(
        f"{tr('machine'):<18}: "
        f"{hardware()}"
    )

    firmware = (
        tr("uefi")
        if uefi_available()
        else
        tr("bios")
    )

    print(
        f"{tr('firmware'):<18}: "
        f"{firmware}"
    )


# ============================================================
# ARCHINSTALL PACKAGE INSTALL
# ============================================================

def install_archinstall() -> bool:

    print()

    command_output(
        "pacman -Sy --needed archinstall"
    )

    log(
        "Installing archinstall."
    )

    try:

        process = subprocess.Popen(
            [
                "pacman",
                "-Sy",
                "--needed",
                "archinstall",
            ],
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            text=True,
            bufsize=1,
        )

        assert process.stdout is not None

        for line in process.stdout:

            line = line.rstrip()

            print(line)

            log(
                f"PACMAN: {line}"
            )

        code = process.wait()

        if code == 0:

            success(
                tr("archinstall")
            )

            return True

        error(
            f"pacman exited with code {code}"
        )

        return False

    except KeyboardInterrupt:

        try:
            process.terminate()
        except Exception:
            pass

        return False

    except OSError as exc:

        error(
            str(exc)
        )

        return False


# ============================================================
# SYSTEM CHECK
# ============================================================

def system_check() -> bool:

    print()

    print(
        paint(
            tr("system_check"),
            Colors.BOLD + Colors.MAGENTA,
        )
    )

    print(
        "-" * 70
    )

    distro = distribution_id()

    log(
        f"Detected distro: {distro}"
    )

    # --------------------------------------------------------
    # Root
    # --------------------------------------------------------

    if os.geteuid() == 0:

        success(
            tr("root")
        )

    else:

        error(
            tr("root_required")
        )

        return False

    # --------------------------------------------------------
    # Python
    # --------------------------------------------------------

    if command_exists("python"):

        success(
            tr("python")
        )

    else:

        error(
            tr("python")
        )

        return False

    # --------------------------------------------------------
    # pacman
    # --------------------------------------------------------

    if command_exists("pacman"):

        success(
            tr("pacman")
        )

    else:

        error(
            tr("pacman")
        )

        return False

    # --------------------------------------------------------
    # Environment
    # --------------------------------------------------------

    if distro in {
        "arch",
        "archiso",
    }:

        success(
            "Arch Linux ISO environment detected."
            if LANGUAGE == "en"
            else
            "Arch-Linux-ISO-Umgebung erkannt."
        )

    else:

        warning(
            tr("arch_warning")
        )

        if not ask_yes_no(
            tr("continue"),
            default=False,
        ):

            return False

    # --------------------------------------------------------
    # Network
    # --------------------------------------------------------

    info(
        tr("network")
    )

    if network_available():

        success(
            tr("network_ok")
        )

    else:

        warning(
            tr("network_failed")
        )

        if not ask_yes_no(
            tr("continue"),
            default=False,
        ):

            return False

    # --------------------------------------------------------
    # archinstall
    # --------------------------------------------------------

    if command_exists("archinstall"):

        success(
            tr("archinstall")
        )

    else:

        warning(
            tr("archinstall_missing")
        )

        if not ask_yes_no(
            tr("install_archinstall"),
            default=True,
        ):

            return False

        if not install_archinstall():

            return False

    return True


# ============================================================
# HYPRLAND PACKAGE PROFILE
# ============================================================
#
# These are normal Arch repository packages.
#
# The core Hyprland package is the desktop/compositor.
#
# Supporting components are intentionally limited to the
# Hyprland session itself and essential desktop integration.
#
# No GNOME.
# No KDE.
# No XFCE.
# No alternative desktop.
#
# ============================================================

HYPRLAND_PACKAGES = [

    # --------------------------------------------------------
    # Core
    # --------------------------------------------------------

    "hyprland",

    # --------------------------------------------------------
    # Hyprland ecosystem
    # --------------------------------------------------------

    "hyprpaper",

    "hyprlock",

    "hypridle",

    "hyprpicker",

    "hyprcursor",

    "hyprpolkitagent",

    # --------------------------------------------------------
    # Wayland / portals
    # --------------------------------------------------------

    "xdg-desktop-portal",

    "xdg-desktop-portal-hyprland",

    # --------------------------------------------------------
    # Authentication / session
    # --------------------------------------------------------

    "polkit",

    "polkit-gnome",

    # --------------------------------------------------------
    # Terminal
    #
    # Kitty is a terminal emulator, NOT a desktop environment.
    # --------------------------------------------------------

    "kitty",

    # --------------------------------------------------------
    # Status bar
    # --------------------------------------------------------

    "waybar",

    # --------------------------------------------------------
    # Application launcher
    # --------------------------------------------------------

    "wofi",

    # --------------------------------------------------------
    # Notifications
    # --------------------------------------------------------

    "mako",

    # --------------------------------------------------------
    # Wallpaper / screenshots / clipboard
    # --------------------------------------------------------

    "grim",

    "slurp",

    "wl-clipboard",

    # --------------------------------------------------------
    # Audio
    # --------------------------------------------------------

    "pipewire",

    "pipewire-audio",

    "pipewire-pulse",

    "wireplumber",

    # --------------------------------------------------------
    # Network
    # --------------------------------------------------------

    "networkmanager",

    # --------------------------------------------------------
    # Bluetooth
    # --------------------------------------------------------

    "bluez",

    "bluez-utils",

    # --------------------------------------------------------
    # File / desktop integration
    # --------------------------------------------------------

    "xdg-utils",

    "xdg-user-dirs",

    # --------------------------------------------------------
    # Polkit / session dependencies
    # --------------------------------------------------------

    "seatd",

    # --------------------------------------------------------
    # Fonts
    # --------------------------------------------------------

    "ttf-dejavu",

    "ttf-liberation",

]


# ============================================================
# EXPLICITLY FORBIDDEN DESKTOP PACKAGES
# ============================================================

FORBIDDEN_DESKTOPS = {

    "gnome",

    "gnome-shell",

    "gnome-session",

    "gdm",

    "plasma",

    "plasma-desktop",

    "plasma-meta",

    "sddm",

    "xfce4",

    "xfce4-goodies",

    "lightdm",

    "cinnamon",

    "cinnamon-desktop",

    "mate",

    "mate-desktop",

    "lxqt",

    "lxqt-session",

}


# ============================================================
# PROFILE VALIDATION
# ============================================================

def validate_hyprland_profile() -> None:

    normalized = {
        package.lower()
        for package in HYPRLAND_PACKAGES
    }

    conflicts = (
        normalized
        & FORBIDDEN_DESKTOPS
    )

    if conflicts:

        raise RuntimeError(
            "Hyprland-only profile contains forbidden "
            f"desktop packages: {sorted(conflicts)}"
        )

    if "hyprland" not in normalized:

        raise RuntimeError(
            "Hyprland package missing from profile."
        )


# ============================================================
# ARCHINSTALL CONFIG
# ============================================================

def create_archinstall_config(
    dry_run: bool = False,
) -> Path:

    validate_hyprland_profile()

    # --------------------------------------------------------
    # Important:
    #
    # We intentionally DO NOT define disk_config.
    #
    # This means archinstall keeps its normal disk selection
    # UI instead of this launcher guessing a disk.
    #
    # --------------------------------------------------------

    config: dict[str, Any] = {

        "script":
            "guided",

        "archinstall-language":
            (
                "German"
                if LANGUAGE == "de"
                else
                "English"
            ),

        "audio_config":
            "pipewire",

        "bootloader_config":
            {
                "bootloader":
                    (
                        "Systemd-boot"
                        if uefi_available()
                        else
                        "Grub"
                    ),
                "uki":
                    False,
                "removable":
                    False,
            },

        "bootloader":
            (
                "Systemd-boot"
                if uefi_available()
                else
                "Grub"
            ),

        "debug":
            False,

        "hostname":
            "archlinux",

        "kernels":
            [
                "linux",
            ],

        "locale_config":
            {
                "kb_layout":
                    "de"
                    if LANGUAGE == "de"
                    else
                    "us",

                "sys_enc":
                    "UTF-8",

                "sys_lang":
                    (
                        "de_DE.UTF-8"
                        if LANGUAGE == "de"
                        else
                        "en_US.UTF-8"
                    ),
            },

        "network_config":
            {},

        "no_pkg_lookups":
            False,

        "ntp":
            True,

        "offline":
            False,

        "packages":
            HYPRLAND_PACKAGES,

        "parallel downloads":
            0,

        # ----------------------------------------------------
        # IMPORTANT:
        #
        # No GNOME/KDE/XFCE profile.
        # Hyprland is installed through packages.
        # ----------------------------------------------------

        "profile_config":
            None,

        "save_config":
            str(
                ARCHINSTALL_CONFIG
            ),

        "silent":
            False,

        "swap":
            True,

        "timezone":
            "Europe/Berlin",

    }

    # --------------------------------------------------------
    # Dry-run information
    # --------------------------------------------------------

    if dry_run:

        config[
            "silent"
        ] = False

    # --------------------------------------------------------
    # Write JSON
    # --------------------------------------------------------

    with ARCHINSTALL_CONFIG.open(
        "w",
        encoding="utf-8",
    ) as file:

        json.dump(
            config,
            file,
            indent=4,
            ensure_ascii=False,
        )

    log(
        f"Generated archinstall config: "
        f"{ARCHINSTALL_CONFIG}"
    )

    return ARCHINSTALL_CONFIG


# ============================================================
# CONFIGURATION PREVIEW
# ============================================================

def show_profile() -> None:

    print()

    print(
        paint(
            tr("profile"),
            Colors.BOLD + Colors.MAGENTA,
        )
    )

    print(
        "-" * 70
    )

    print(
        f"{tr('profile_arch'):<25}: "
        "YES"
    )

    print(
        f"{tr('profile_hyprland'):<25}: "
        "YES"
    )

    print(
        f"{tr('profile_only'):<25}: "
        "YES"
    )

    print()

    print(
        paint(
            tr("profile_no_other"),
            Colors.GREEN,
        )
    )

    print()

    print(
        paint(
            tr("packages"),
            Colors.BOLD + Colors.CYAN,
        )
    )

    print(
        "-" * 70
    )

    for package in HYPRLAND_PACKAGES:

        print(
            f"  • {package}"
        )


# ============================================================
# START MODE
# ============================================================

class StartMode:

    GUIDED = "guided"

    DRY_RUN = "dry"


def select_start_mode() -> str | None:

    options = [

        (
            StartMode.GUIDED,
            tr("guided"),
            tr("guided_description"),
        ),

        (
            StartMode.DRY_RUN,
            tr("dry_run"),
            tr("dry_description"),
        ),

    ]

    selected = 0

    def draw(
        screen: Any,
    ) -> None:

        screen.erase()

        height, width = screen.getmaxyx()

        screen.addstr(
            0,
            0,
            tr("mode")[
                :max(width - 1, 1)
            ],
            curses.A_BOLD,
        )

        screen.addstr(
            1,
            0,
            tr("selection_help")[
                :max(width - 1, 1)
            ],
        )

        for index, (
            key,
            title,
            description,
        ) in enumerate(options):

            row = 4 + index * 4

            if index == selected:

                screen.attron(
                    curses.A_REVERSE
                )

            screen.addstr(
                row,
                2,
                f"> {title}"[
                    :max(width - 3, 1)
                ],
            )

            if index == selected:

                screen.attroff(
                    curses.A_REVERSE
                )

            screen.addstr(
                row + 1,
                6,
                description[
                    :max(width - 7, 1)
                ],
            )

        screen.refresh()

    def menu(
        screen: Any,
    ) -> str | None:

        nonlocal selected

        curses.curs_set(0)

        screen.keypad(True)

        while True:

            draw(screen)

            key = screen.getch()

            if key in (
                curses.KEY_UP,
                ord("k"),
            ):

                selected = (
                    selected - 1
                ) % len(options)

            elif key in (
                curses.KEY_DOWN,
                ord("j"),
            ):

                selected = (
                    selected + 1
                ) % len(options)

            elif key in (
                10,
                13,
                curses.KEY_ENTER,
            ):

                return options[
                    selected
                ][0]

            elif key in (
                ord("q"),
                ord("Q"),
                27,
            ):

                return None

    try:

        return curses.wrapper(
            menu
        )

    except curses.error:

        return StartMode.GUIDED


# ============================================================
# ARCHINSTALL LAUNCH
# ============================================================

def launch_archinstall(
    config: Path,
    dry_run: bool,
) -> int:

    command = [
        "archinstall",
        "--config",
        str(config),
    ]

    if dry_run:

        command.append(
            "--dry-run"
        )

    print()

    print(
        paint(
            "=" * 70,
            Colors.CYAN,
        )
    )

    print(
        paint(
            tr("launch"),
            Colors.BOLD + Colors.GREEN,
        )
    )

    print()

    command_output(
        shlex.join(command)
    )

    print()

    print(
        paint(
            tr("post_install"),
            Colors.CYAN,
        )
    )

    print(
        paint(
            "=" * 70,
            Colors.CYAN,
        )
    )

    log(
        "Launching archinstall:"
    )

    log(
        shlex.join(command)
    )

    try:

        start = time.monotonic()

        process = subprocess.Popen(
            command
        )

        code = process.wait()

        duration = (
            time.monotonic()
            - start
        )

        log(
            f"archinstall exited "
            f"code={code} "
            f"duration={duration:.2f}s"
        )

        print()

        print(
            paint(
                "=" * 70,
                Colors.CYAN,
            )
        )

        print(
            paint(
                tr("finished"),
                Colors.BOLD + Colors.GREEN,
            )
        )

        print()

        print(
            f"{tr('exit_code')}: "
            f"{code}"
        )

        print(
            f"{tr('log')}: "
            f"{LOGGER.path}"
        )

        print(
            paint(
                "=" * 70,
                Colors.CYAN,
            )
        )

        return code

    except KeyboardInterrupt:

        warning(
            (
                "Archinstall wurde unterbrochen."
                if LANGUAGE == "de"
                else
                "Archinstall was interrupted."
            )
        )

        try:

            process.terminate()

        except Exception:
            pass

        return 130

    except FileNotFoundError:

        error(
            tr("archinstall_missing")
        )

        return 1

    except OSError as exc:

        error(
            str(exc)
        )

        log(
            f"Launch error: {exc}"
        )

        return 1


# ============================================================
# MAIN INSTALLATION
# ============================================================

def run_installer(
    mode_override: str | None = None,
    force_english: bool = False,
) -> int:

    global LANGUAGE

    if force_english:

        LANGUAGE = "en"

    else:

        select_language()

    clear_screen()

    header()

    log(
        "============================================================"
    )

    log(
        "ARCH LINUX + HYPRLAND INSTALLER"
    )

    log(
        f"Language={LANGUAGE}"
    )

    # --------------------------------------------------------
    # System info
    # --------------------------------------------------------

    show_system_information()

    # --------------------------------------------------------
    # System check
    # --------------------------------------------------------

    if not system_check():

        print()

        error(
            tr("failed")
        )

        return 1

    # --------------------------------------------------------
    # Profile
    # --------------------------------------------------------

    show_profile()

    # --------------------------------------------------------
    # Validate
    # --------------------------------------------------------

    try:

        validate_hyprland_profile()

    except RuntimeError as exc:

        error(
            str(exc)
        )

        log(
            str(exc)
        )

        return 1

    # --------------------------------------------------------
    # Start mode
    # --------------------------------------------------------

    if mode_override:

        mode = mode_override

    else:

        mode = select_start_mode()

    if mode is None:

        warning(
            tr("cancelled")
        )

        return 0

    dry_run = (
        mode == StartMode.DRY_RUN
    )

    # --------------------------------------------------------
    # Generate configuration
    # --------------------------------------------------------

    try:

        config = (
            create_archinstall_config(
                dry_run=dry_run
            )
        )

        success(
            tr("generated")
        )

    except Exception as exc:

        error(
            f"Could not generate configuration: "
            f"{exc}"
        )

        log(
            f"Configuration error: {exc}"
        )

        return 1

    # --------------------------------------------------------
    # Show config path
    # --------------------------------------------------------

    print()

    info(
        f"Config: {config}"
    )

    # --------------------------------------------------------
    # Security warning
    # --------------------------------------------------------

    if not dry_run:

        print()

        print(
            paint(
                "!" * 70,
                Colors.RED,
            )
        )

        print(
            paint(
                tr("security"),
                Colors.BOLD + Colors.RED,
            )
        )

        print()

        print(
            paint(
                tr("disk_warning"),
                Colors.BOLD + Colors.RED,
            )
        )

        print(
            paint(
                tr("backup"),
                Colors.YELLOW,
            )
        )

        print()

        print(
            paint(
                "WICHTIG: Die Festplatte wird NICHT "
                "von diesem Python-Skript ausgewählt."
                if LANGUAGE == "de"
                else
                "IMPORTANT: This Python script does NOT "
                "choose the disk for you.",
                Colors.BOLD,
            )
        )

        print(
            paint(
                "Du wählst das Ziellaufwerk innerhalb von archinstall."
                if LANGUAGE == "de"
                else
                "You choose the target disk inside archinstall.",
                Colors.BOLD,
            )
        )

        print()

        print(
            paint(
                "!" * 70,
                Colors.RED,
            )
        )

        if not ask_yes_no(
            tr("start"),
            default=False,
        ):

            warning(
                tr("cancelled")
            )

            return 0

    else:

        warning(
            (
                "DRY-RUN: Keine Installation wird durchgeführt."
                if LANGUAGE == "de"
                else
                "DRY-RUN: No installation will be performed."
            )
        )

    # --------------------------------------------------------
    # Launch
    # --------------------------------------------------------

    return launch_archinstall(
        config=config,
        dry_run=dry_run,
    )


# ============================================================
# CLI
# ============================================================

def parse_arguments() -> argparse.Namespace:

    parser = argparse.ArgumentParser(
        description=(
            "Arch Linux + Hyprland installer frontend"
        )
    )

    parser.add_argument(
        "--english",
        action="store_true",
        help="Start in English.",
    )

    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Run archinstall in dry-run mode.",
    )

    return parser.parse_args()


# ============================================================
# ENTRY POINT
# ============================================================

def main() -> int:

    args = parse_arguments()

    mode_override = None

    if args.dry_run:

        mode_override = StartMode.DRY_RUN

    try:

        return run_installer(
            mode_override=mode_override,
            force_english=args.english,
        )

    except KeyboardInterrupt:

        print()

        error(
            (
                "Installation interrupted."
                if LANGUAGE == "en"
                else
                "Installation wurde unterbrochen."
            )
        )

        return 130

    except Exception as exc:

        print()

        error(
            f"{type(exc).__name__}: {exc}"
        )

        log(
            f"FATAL: "
            f"{type(exc).__name__}: {exc}"
        )

        return 1


if __name__ == "__main__":

    sys.exit(
        main()
    )
