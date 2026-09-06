#!/usr/bin/env python3
"""
Arch Linux + Hyprland unattended installer.

Run ONLY from the official Arch Linux ISO as root.

The installer asks for exactly:
  1. Language
  2. Keyboard layout
  3. Target disk
  4. Username
  5. Password twice

After that it runs unattended.

The Python file is already part of the user's existing dotfiles checkout.
This script does not clone, download, or install another dotfiles repository.

Architecture:
  - Python collects the five answers.
  - Python installs/updates archinstall in the live ISO.
  - Python generates a current archinstall guided configuration.
  - archinstall performs the complete disk partitioning, filesystem creation,
    Btrfs subvolume creation, base installation, fstab, bootloader, users,
    locale, kernel and package installation.
  - archinstall custom_commands finish the installed Hyprland system.
"""

from __future__ import annotations

import getpass
import json
import os
import platform
import re
import socket
import subprocess
import sys
import time
import uuid
from pathlib import Path
from typing import NoReturn


WORK = Path("/root/arch-hyprland-installer")
CONFIG = WORK / "user_configuration.json"
CREDS = WORK / "user_credentials.json"
LOG = WORK / "installer.log"

LANGUAGES = [
    ("de", "German", "de_DE.UTF-8"),
    ("en", "English", "en_US.UTF-8"),
]

KEYBOARDS = [
    ("de", "German (DE)"),
    ("us", "English (US)"),
    ("gb", "English (UK)"),
    ("fr", "French (FR)"),
    ("es", "Spanish (ES)"),
    ("it", "Italian (IT)"),
]

CORE_PACKAGES = [
    # Vollständige Arch-Basis / Administration
    "base",
    "base-devel",
    "linux",
    "linux-firmware",
    "btrfs-progs",
    "dosfstools",
    "sudo",
    "networkmanager",
    "git",
    "curl",
    "wget",
    "openssh",
    "vim",
    "nano",
    "bash-completion",
    "man-db",
    "man-pages",
    "texinfo",
    "which",
    "polkit",
    "polkit-gnome",

    # Audio / Bluetooth
    "pipewire",
    "pipewire-audio",
    "pipewire-pulse",
    "wireplumber",
    "bluez",
    "bluez-utils",

    # XDG / Wayland
    "xdg-utils",
    "xdg-user-dirs",
    "xdg-user-dirs-gtk",
    "xdg-desktop-portal",
    "xdg-desktop-portal-hyprland",

    # Hyprland-Stack
    "hyprland",
    "hyprpaper",
    "hyprlock",
    "hypridle",
    "hyprpicker",
    "hyprcursor",
    "hyprpolkitagent",
    "quickshell",

    # Desktop-Anwendungen / Dienstprogramme
    "kitty",
    "waybar",
    "wofi",
    "mako",
    "grim",
    "slurp",
    "wl-clipboard",
    "qt5-wayland",
    "qt6-wayland",
    "qt6ct",
    "brightnessctl",
    "playerctl",
    "pavucontrol",
    "network-manager-applet",
    "blueman",
    "thunar",
    "file-roller",
    "unzip",
    "unrar",
    "tar",
    "gzip",
    "btop",
    "fastfetch",
    "jq",
    "firefox",

    # Python / Build-Werkzeuge
    "python",
    "python-pip",
    "python-gobject",
    "python-pywal",
    "meson",
    "ninja",
    "cmake",
    "gcc",
    "make",
    "pkgconf",

    # Schriftarten
    "ttf-dejavu",
    "ttf-liberation",
    "noto-fonts",
    "noto-fonts-emoji",
    "otf-font-awesome",

    # zram
    "zram-generator",
]

GPU_PACKAGES = {
    "amd": [
        "mesa",
        "vulkan-radeon",
        "lib32-mesa",
        "lib32-vulkan-radeon",
    ],
    "intel": [
        "mesa",
        "vulkan-intel",
        "lib32-mesa",
        "lib32-vulkan-intel",
    ],
    "nvidia": [
        "nvidia",
        "nvidia-utils",
        "lib32-nvidia-utils",
    ],
}

MICROCODE = {
    "AuthenticAMD": "amd-ucode",
    "GenuineIntel": "intel-ucode",
}


def die(message: str, code: int = 1) -> NoReturn:
    print(f"\n\033[1;31m[ERROR]\033[0m {message}", file=sys.stderr)
    raise SystemExit(code)


def info(message: str) -> None:
    print(f"\033[36m[INFO]\033[0m {message}")


def ok(message: str) -> None:
    print(f"\033[32m[ OK ]\033[0m {message}")


def warn(message: str) -> None:
    print(f"\033[33m[WARN]\033[0m {message}")


def run(
    cmd: list[str],
    *,
    check: bool = True,
    capture: bool = False,
    input_text: str | None = None,
    env: dict[str, str] | None = None,
) -> subprocess.CompletedProcess[str]:
    shown = " ".join(cmd)
    print(f"\033[90m$ {shown}\033[0m")

    with LOG.open("a", encoding="utf-8") as log:
        log.write(f"$ {shown}\n")
        proc = subprocess.run(
            cmd,
            check=False,
            text=True,
            input=input_text,
            stdout=subprocess.PIPE if capture else None,
            stderr=subprocess.STDOUT if capture else None,
            env=env,
        )

        if capture and proc.stdout:
            log.write(proc.stdout)

    if check and proc.returncode != 0:
        die(f"Command failed ({proc.returncode}): {shown}")

    return proc


def require_root() -> None:
    if os.geteuid() != 0:
        die("Please run this in the official Arch ISO terminal as root.")


def read_os_release() -> dict[str, str]:
    result: dict[str, str] = {}

    try:
        for line in Path("/etc/os-release").read_text(
            encoding="utf-8"
        ).splitlines():
            if "=" in line:
                key, value = line.split("=", 1)
                result[key] = value.strip().strip('"')
    except OSError:
        pass

    return result


def check_arch_iso() -> None:
    os_release = read_os_release()

    looks_like_arch = (
        os_release.get("ID") in {"arch", "archiso"}
        or Path("/run/archiso").exists()
        or Path("/etc/arch-release").exists()
    )

    if not looks_like_arch:
        die("This does not appear to be the official Arch Linux ISO.")

    if platform.machine() != "x86_64":
        die("This installer currently supports x86_64 only.")


def network_ok() -> bool:
    for host in ("archlinux.org", "github.com"):
        try:
            with socket.create_connection((host, 443), timeout=5):
                return True
        except OSError:
            continue

    return False


def select_language() -> tuple[str, str]:
    print("\n=== LANGUAGE ===")

    for index, (_, name, _) in enumerate(LANGUAGES, 1):
        print(f"  {index}) {name}")

    while True:
        answer = input("Selection [1-2]: ").strip()

        if answer in {"1", "2"}:
            code, _, locale = LANGUAGES[int(answer) - 1]
            return code, locale

        warn("Invalid selection.")


def select_keyboard() -> str:
    print("\n=== KEYBOARD ===")

    for index, (_, name) in enumerate(KEYBOARDS, 1):
        print(f"  {index}) {name}")

    while True:
        answer = input(f"Selection [1-{len(KEYBOARDS)}]: ").strip()

        if answer.isdigit() and 1 <= int(answer) <= len(KEYBOARDS):
            return KEYBOARDS[int(answer) - 1][0]

        warn("Invalid selection.")


def get_block_devices() -> list[dict]:
    proc = run(
        [
            "lsblk",
            "-J",
            "-b",
            "-o",
            "NAME,KNAME,PATH,SIZE,TYPE,MODEL,TRAN,RM,RO,MOUNTPOINTS",
        ],
        capture=True,
    )

    try:
        return json.loads(proc.stdout)["blockdevices"]
    except Exception as exc:
        die(f"Could not process lsblk output: {exc}")


def human_size(size: int) -> str:
    value = float(size)

    for unit in ("B", "KiB", "MiB", "GiB", "TiB"):
        if value < 1024 or unit == "TiB":
            return f"{value:.1f} {unit}"
        value /= 1024

    return str(size)


def select_disk() -> str:
    devices = [
        device
        for device in get_block_devices()
        if device.get("type") == "disk"
        and device.get("path")
        and str(device.get("rm", 0)) == "0"
        and str(device.get("ro", 0)) == "0"
        and not str(device.get("path", "")).startswith("/dev/loop")
    ]

    if not devices:
        die("No suitable internal drive found.")

    print("\n=== TARGET DISK ===")

    for index, device in enumerate(devices, 1):
        print(
            f"  {index}) "
            f"{device['path']:<18} "
            f"{human_size(int(device.get('size', 0))):>10}  "
            f"{str(device.get('tran') or '?'):<5} "
            f"{device.get('model') or 'unknown'}"
        )

    while True:
        answer = input(f"Selection [1-{len(devices)}]: ").strip()

        if answer.isdigit() and 1 <= int(answer) <= len(devices):
            selected = devices[int(answer) - 1]
            path = str(selected["path"])
            size = int(selected.get("size", 0))

            if size < 32 * 1024**3:
                die(
                    f"{path} is too small at {human_size(size)}. "
                    "At least 32 GiB is recommended."
                )

            print(
                f"\n\033[1;31m"
                f"WARNING: {path} ({human_size(size)}) will be "
                f"completely erased.\033[0m"
            )
            print("No further input will be required after this point.")

            return path

        warn("Invalid selection.")


def validate_username(username: str) -> bool:
    return bool(re.fullmatch(r"[a-z_][a-z0-9_-]{0,31}", username))


def select_user() -> tuple[str, str]:
    print("\n=== USER ===")

    while True:
        username = input("Username: ").strip().lower()

        if validate_username(username):
            break

        warn(
            "Invalid username. Allowed characters are a-z, 0-9, _ and -. "
            "It must start with a-z or _."
        )

    while True:
        password1 = getpass.getpass("Password: ")
        password2 = getpass.getpass("Repeat password: ")

        if not password1:
            warn("The password cannot be empty.")
            continue

        if password1 != password2:
            warn("The passwords do not match.")
            continue

        return username, password1


def detect_cpu_vendor() -> str:
    try:
        cpuinfo = Path("/proc/cpuinfo").read_text(errors="ignore")
    except OSError:
        return ""

    if "AuthenticAMD" in cpuinfo:
        return "AuthenticAMD"

    if "GenuineIntel" in cpuinfo:
        return "GenuineIntel"

    return ""


def detect_gpu() -> str:
    proc = run(["lspci"], capture=True, check=False)
    text = (proc.stdout or "").lower()

    if "nvidia" in text:
        return "nvidia"

    if (
        "amd" in text
        or "advanced micro devices" in text
        or "radeon" in text
    ):
        return "amd"

    if "intel" in text:
        return "intel"

    return "unknown"


def get_disk_size_bytes(disk: str) -> int:
    for device in get_block_devices():
        if device.get("path") == disk and device.get("type") == "disk":
            return int(device.get("size", 0))

    die(f"Could not determine the size of {disk}.")


def package_exists(package: str) -> bool:
    return (
        run(
            ["pacman", "-Si", package],
            capture=True,
            check=False,
        ).returncode
        == 0
    )


def available_packages(packages: list[str]) -> list[str]:
    available: list[str] = []

    for package in packages:
        if package_exists(package):
            available.append(package)
        else:
            warn(f"Package not found in the current repository: {package}")

    return available


def install_archinstall_live() -> None:
    info("Updating the package database of the Arch ISO …")
    run(["pacman", "-Sy", "--noconfirm"])

    info("Installing archinstall and the required live environment tools …")
    run(
        [
            "pacman",
            "-S",
            "--noconfirm",
            "--needed",
            "archinstall",
            "gptfdisk",
            "btrfs-progs",
            "dosfstools",
            "util-linux",
            "openssl",
        ]
    )


def archinstall_version() -> str:
    proc = run(
        ["archinstall", "--version"],
        capture=True,
        check=False,
    )

    match = re.search(
        r"(\d+\.\d+(?:\.\d+)?)",
        proc.stdout or "",
    )

    if match:
        return match.group(1)

    return "3.0.10"


def uuid_string() -> str:
    return str(uuid.uuid4())


def size_spec_bytes(value: int) -> dict:
    return {
        "sector_size": {
            "unit": "B",
            "value": 512,
        },
        "unit": "B",
        "value": value,
    }


def start_spec_mib(value: int) -> dict:
    return {
        "sector_size": {
            "unit": "B",
            "value": 512,
        },
        "unit": "MiB",
        "value": value,
    }


def make_partition(
    *,
    fs_type: str,
    mountpoint: str | None,
    flags: list[str],
    start_mib: int,
    size_bytes: int,
    btrfs: list[dict] | None = None,
    mount_options: list[str] | None = None,
) -> dict:
    return {
        "btrfs": btrfs or [],
        "dev_path": None,
        "flags": flags,
        "fs_type": fs_type,
        "mount_options": mount_options or [],
        "mountpoint": mountpoint,
        "obj_id": uuid_string(),
        "size": size_spec_bytes(size_bytes),
        "start": start_spec_mib(start_mib),
        "status": "create",
        "type": "primary",
    }


def build_disk_config(
    disk: str,
    uefi: bool,
) -> dict:
    total_bytes = get_disk_size_bytes(disk)

    # Eine kleine Ausrichtungsreserve am Ende des Laufwerks beibehalten.
    usable_bytes = total_bytes - 4 * 1024**2

    if usable_bytes < 32 * 1024**3:
        die("The target disk is too small for this installation.")

    partitions: list[dict] = []

    if uefi:
        # GPT + 1 MiB alignment + 1 GiB EFI System Partition.
        efi_size = 1 * 1024**3
        root_start_mib = 1025

        partitions.append(
            make_partition(
                fs_type="fat32",
                mountpoint="/boot",
                flags=["boot", "esp"],
                start_mib=1,
                size_bytes=efi_size,
            )
        )
    else:
        # GPT BIOS boot partition for GRUB.
        bios_size = 2 * 1024**2
        root_start_mib = 3

        partitions.append(
            make_partition(
                fs_type="fat32",
                mountpoint=None,
                flags=["bios_grub"],
                start_mib=1,
                size_bytes=bios_size,
            )
        )

    root_start_bytes = root_start_mib * 1024**2
    root_size = usable_bytes - root_start_bytes

    if root_size < 30 * 1024**3:
        die(
            "Too little space remains for Arch Linux "
            "after the boot partition."
        )

    subvolumes = [
        {"mountpoint": "/", "name": "@"},
        {"mountpoint": "/home", "name": "@home"},
        {"mountpoint": "/var/log", "name": "@log"},
        {"mountpoint": "/var/cache/pacman/pkg", "name": "@cache"},
        {"mountpoint": "/.snapshots", "name": "@snapshots"},
        {"mountpoint": "/tmp", "name": "@tmp"},
    ]

    partitions.append(
        make_partition(
            fs_type="btrfs",
            mountpoint=None,
            flags=[],
            start_mib=root_start_mib,
            size_bytes=root_size,
            btrfs=subvolumes,
            mount_options=[
                "compress=zstd:3",
                "noatime",
            ],
        )
    )

    return {
        "config_type": "manual_partitioning",
        "device_modifications": [
            {
                "device": disk,
                "partitions": partitions,
                "wipe": True,
            }
        ],
    }


def crypt_password(password: str) -> str:
    proc = subprocess.run(
        ["openssl", "passwd", "-6", "-stdin"],
        input=password + "\n",
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        check=False,
    )

    if proc.returncode != 0 or not proc.stdout.strip():
        die("The password could not be hashed.")

    return proc.stdout.strip()


def shell_quote(value: str) -> str:
    return "'" + value.replace("'", "'\"'\"'") + "'"


def build_custom_commands(
    username: str,
    locale: str,
    keyboard: str,
) -> list[str]:
    profile = (
        "if [ -z \"${DISPLAY:-}\" ] && "
        "[ -z \"${WAYLAND_DISPLAY:-}\" ] && "
        "[ \"$(tty 2>/dev/null)\" = \"/dev/tty1\" ]; then "
        "exec Hyprland; "
        "fi"
    )

    profile_command = (
        "bash -c "
        + shell_quote(
            "PROFILE=/home/"
            + username
            + "/.bash_profile; "
            "touch \"$PROFILE\"; "
            "grep -qxF "
            + shell_quote(profile)
            + " \"$PROFILE\" || "
            "printf '%s\\n' "
            + shell_quote(profile)
            + " >> \"$PROFILE\"; "
            "chown "
            + username
            + ":"
            + username
            + " \"$PROFILE\""
        )
    )

    zram_command = (
        "bash -c "
        + shell_quote(
            "install -d -m 0755 /etc/systemd; "
            "printf '%s\\n' "
            "'[zram0]' "
            "'zram-size = ram / 2' "
            "'compression-algorithm = zstd' "
            "> /etc/systemd/zram-generator.conf"
        )
    )

    getty_command = (
        "bash -c "
        + shell_quote(
            "install -d -m 0755 "
            "/etc/systemd/system/getty@tty1.service.d; "
            "printf '%s\\n' "
            "'[Service]' "
            "'ExecStart=' "
            + f"'ExecStart=-/sbin/agetty --autologin {username} "
            "--noclear %I $TERM' "
            + "> /etc/systemd/system/getty@tty1.service.d/"
            "autologin.conf"
        )
    )

    locale_command = (
        "bash -c "
        + shell_quote(
            "printf 'LANG=%s\\n' "
            + shell_quote(locale)
            + " > /etc/locale.conf; "
            "printf 'KEYMAP=%s\\n' "
            + shell_quote(keyboard)
            + " > /etc/vconsole.conf; "
            "locale-gen"
        )
    )

    xdg_command = (
        "bash -c "
        + shell_quote(
            "su - "
            + username
            + " -c 'xdg-user-dirs-update'"
        )
    )

    return [
        "systemctl enable NetworkManager.service",
        "systemctl enable bluetooth.service",
        "systemctl enable systemd-timesyncd.service",
        zram_command,
        "systemctl enable systemd-zram-setup@zram0.service",
        locale_command,
        getty_command,
        profile_command,
        xdg_command,
        "mkinitcpio -P",
    ]


def build_configuration(
    *,
    disk: str,
    uefi: bool,
    language: str,
    locale: str,
    keyboard: str,
    username: str,
    packages: list[str],
) -> dict:
    version = archinstall_version()
    bootloader = "Systemd-boot" if uefi else "Grub"

    return {
        "additional-repositories": ["multilib"],
        "app_config": {
            "audio_config": {
                "audio": "pipewire",
            },
            "bluetooth_config": {
                "enabled": True,
            },
        },
        "archinstall-language": (
            "German" if language == "de" else "English"
        ),
        "auth_config": {},
        "bootloader": bootloader,
        "bootloader_config": {
            "bootloader": bootloader,
            "uki": False,
            "removable": False,
        },
        "config_version": version,
        "custom_commands": build_custom_commands(
            username,
            locale,
            keyboard,
        ),
        "debug": False,
        "disk_config": build_disk_config(disk, uefi),
        "disk_encryption": None,
        "hostname": "archlinux",
        "kernels": ["linux"],
        "locale_config": {
            "kb_layout": keyboard,
            "sys_enc": "UTF-8",
            "sys_lang": locale,
        },
        "network_config": {
            "type": "nm",
        },
        "no_pkg_lookups": False,
        "ntp": True,
        "offline": False,
        "packages": packages,
        "parallel_downloads": 0,
        "profile_config": {
            "gfx_driver": None,
            "greeter": None,
            "profile": {
                "custom_settings": {},
                "details": [],
                "main": "Minimal",
            },
        },
        "save_config": None,
        "script": "guided",
        "silent": True,
        "skip_ntp": False,
        "skip_version_check": False,
        "swap": False,
        "timezone": "Europe/Berlin",
        "uki": False,
        "version": version,
    }


def write_configuration(
    config: dict,
    username: str,
    password: str,
) -> None:
    WORK.mkdir(parents=True, exist_ok=True)

    CONFIG.write_text(
        json.dumps(config, indent=2),
        encoding="utf-8",
    )

    CREDS.write_text(
        json.dumps(
            {
                "users": [
                    {
                        "username": username,
                        "enc_password": crypt_password(password),
                        "sudo": True,
                    }
                ]
            },
            indent=2,
        ),
        encoding="utf-8",
    )

    os.chmod(CREDS, 0o600)
    os.chmod(CONFIG, 0o600)


def validate_configuration() -> None:
    if not CONFIG.exists():
        die("The archinstall configuration was not created.")

    if not CREDS.exists():
        die("The archinstall credentials were not created.")

    try:
        config = json.loads(CONFIG.read_text(encoding="utf-8"))
        creds = json.loads(CREDS.read_text(encoding="utf-8"))
    except Exception as exc:
        die(f"Configuration files are not valid JSON: {exc}")

    required = [
        "disk_config",
        "kernels",
        "locale_config",
        "packages",
        "silent",
        "bootloader",
    ]

    missing = [key for key in required if key not in config]
    if missing:
        die(f"Missing archinstall configuration fields: {missing}")

    if config["silent"] is not True:
        die("The archinstall configuration is not silent.")

    if not creds.get("users"):
        die("No user found in the archinstall credentials.")


def run_archinstall() -> None:
    info("Starting archinstall fully automated now …")

    print(
        "\n\033[1;32m"
        "NO FURTHER USER INPUT FROM THIS POINT.\n"
        "archinstall will handle partitioning, filesystem creation,\n"
        "Btrfs subvolumes, Arch installation and bootloader.\n"
        "\033[0m"
    )

    run(
        [
            "archinstall",
            "--config",
            str(CONFIG),
            "--creds",
            str(CREDS),
            "--silent",
        ]
    )


def cleanup() -> None:
    for path in (CREDS, CONFIG):
        try:
            path.unlink()
        except FileNotFoundError:
            pass

    run(["sync"], check=False)


def unmount_target() -> None:
    for mountpoint in (
        "/mnt/archinstall",
        "/mnt",
    ):
        if os.path.ismount(mountpoint):
            run(["umount", "-R", mountpoint], check=False)


def main() -> None:
    require_root()

    WORK.mkdir(parents=True, exist_ok=True)
    LOG.write_text(
        f"Arch Linux + Hyprland installer started: {time.ctime()}\n",
        encoding="utf-8",
    )

    print(
        """
\033[1;36m============================================================
       ARCH LINUX + HYPRLAND ULTIMATE INSTALLER
============================================================\033[0m

This installer replaces manual archinstall interaction.

Input:
  1. Language
  2. Keyboard layout
  3. Target disk
  4. Username
  5. Password twice

After that, the entire installation runs automatically.
"""
    )

    check_arch_iso()

    if not network_ok():
        die(
            "No internet connection. "
            "Connect the official Arch ISO to the internet first."
        )

    language, locale = select_language()
    keyboard = select_keyboard()
    disk = select_disk()
    username, password = select_user()

    uefi = Path("/sys/firmware/efi").exists()
    cpu = detect_cpu_vendor()
    gpu = detect_gpu()

    print("\n=== AUTOMATIC HARDWARE DETECTION ===")
    print(f"CPU      : {cpu or 'unknown'}")
    print(f"GPU      : {gpu}")
    print(f"Firmware : {'UEFI' if uefi else 'BIOS'}")
    print(f"Disk     : {disk}")
    print(f"User     : {username}")
    print()

    install_archinstall_live()

    packages = list(CORE_PACKAGES)

    if cpu in MICROCODE:
        packages.append(MICROCODE[cpu])

    if gpu in GPU_PACKAGES:
        packages.extend(GPU_PACKAGES[gpu])

    packages = list(dict.fromkeys(packages))

    info("Checking package names in the current Arch repository …")
    packages = available_packages(packages)

    if "base" not in packages or "linux" not in packages:
        die(
            "The required Arch base packages are not available. "
            "Installation is being aborted for safety."
        )

    config = build_configuration(
        disk=disk,
        uefi=uefi,
        language=language,
        locale=locale,
        keyboard=keyboard,
        username=username,
        packages=packages,
    )

    write_configuration(config, username, password)
    validate_configuration()

    # Das Passwort wird von Python nach dem Schreiben der Credentials nicht mehr benötigt.
    # Es wird absichtlich nicht protokolliert.
    password = ""

    run_archinstall()

    cleanup()
    unmount_target()

    ok("Arch Linux + Hyprland has been installed completely.")
    print(
        "\nThe system will now reboot. "
        "Remove the Arch USB stick afterward."
    )

    time.sleep(3)
    run(["reboot", "now"], check=False)


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        die("Installation aborted.")
