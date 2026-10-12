#!/usr/bin/env python3
"""
JK GRAY LINUX / ARCH-HYPRLAND SECURITY WORKSTATION INSTALLER
===========================================================

A modular, conservative installer for the official Arch Linux live ISO.
The initial install creates a usable Hyprland desktop; offensive security
toolsets are intentionally deferred to a separately reviewed post-install
stage. No BlackArch repository is enabled by this installer.

IMPORTANT
---------
- Destructive: the selected target disk is erased after a final confirmation.
- UEFI/GPT only; run from the official Arch Linux ISO as root.
- Review this script before use. Test in a VM first.
- This is an installer foundation, not a claim of a formally audited OS.
"""

from __future__ import annotations

import getpass
import json
import os
import re
import shutil
import socket
import subprocess
import sys
import time
from dataclasses import dataclass
from pathlib import Path
from typing import NoReturn

APP = "jk-gray-linux-installer"
VERSION = "0.2.0"
TARGET = Path("/mnt")
STATE = Path("/root") / APP
LOG = STATE / "installer.log"

BASE_PACKAGES = [
    "base",
    "linux",
    "linux-firmware",
    "mkinitcpio",
    "btrfs-progs",
    "cryptsetup",
    "dosfstools",
    "efibootmgr",
    "sudo",
    "git",
    "networkmanager",
    "polkit",
    "fish",
    "bash-completion",
    "pipewire",
    "pipewire-audio",
    "pipewire-alsa",
    "pipewire-pulse",
    "wireplumber",
    "bluez",
    "bluez-utils",
    "firefox",
    "kitty",
    "wofi",
    "hyprland",
    "hyprlock",
    "hypridle",
    "hyprcursor",
    "hyprpolkitagent",
    "waybar",
    "mako",
    "grim",
    "slurp",
    "wl-clipboard",
    "thunar",
    "file-roller",
    "pavucontrol",
    "network-manager-applet",
    "blueman",
    "xdg-utils",
    "xdg-user-dirs",
    "xdg-desktop-portal",
    "xdg-desktop-portal-hyprland",
    "qt5-wayland",
    "qt6-wayland",
    "ttf-dejavu",
    "ttf-liberation",
    "noto-fonts",
    "noto-fonts-emoji",
    "otf-font-awesome",
    "zram-generator",
    "reflector",
    "man-db",
    "man-pages",
    "less",
    "vim",
    "nano",
    "unzip",
    "zip",
]
GPU_PACKAGES = {
    "amd": ["mesa", "vulkan-radeon"],
    "intel": ["mesa", "vulkan-intel"],
    "nvidia": ["nvidia", "nvidia-utils"],
}
MICROCODE = {"AuthenticAMD": "amd-ucode", "GenuineIntel": "intel-ucode"}
LOCALES = {"1": ("en_US.UTF-8", "us"), "2": ("de_DE.UTF-8", "de")}


@dataclass(frozen=True)
class InstallConfig:
    disk: str
    username: str
    hostname: str
    locale: str
    keymap: str
    timezone: str
    encrypted: bool
    gpu: str
    cpu: str


def log(message: str) -> None:
    STATE.mkdir(parents=True, exist_ok=True)
    stamp = time.strftime("%Y-%m-%d %H:%M:%S")
    with LOG.open("a", encoding="utf-8") as stream:
        stream.write(f"[{stamp}] {message}\n")


def say(message: str = "") -> None:
    print(message, flush=True)


def die(message: str, code: int = 1) -> NoReturn:
    say(f"\n[ERROR] {message}")
    log("ERROR: " + message)
    raise SystemExit(code)


def run(
    args: list[str],
    *,
    check: bool = True,
    capture: bool = False,
    input_text: str | None = None,
    env: dict[str, str] | None = None,
) -> subprocess.CompletedProcess[str]:
    """Run commands without a shell; redact secrets by never passing them in argv."""
    say("$ " + " ".join(args))
    log("$ " + " ".join(args))
    try:
        result = subprocess.run(
            args,
            text=True,
            input=input_text,
            stdout=subprocess.PIPE if capture else None,
            stderr=subprocess.STDOUT if capture else None,
            check=False,
            env=env,
        )
    except OSError as exc:
        die(f"Could not execute {args[0]}: {exc}")
    if capture and result.stdout:
        log(result.stdout.rstrip())
    if check and result.returncode:
        die(f"Command failed with exit code {result.returncode}: {args[0]}")
    return result


def require_environment() -> None:
    if os.geteuid() != 0:
        die("Start from the live environment as root.")
    if not Path("/sys/firmware/efi").is_dir():
        die("UEFI boot is required. Reboot the ISO in UEFI mode.")
    if not Path("/run/archiso").exists():
        die("This does not look like the official Arch Linux live ISO.")
    try:
        socket.create_connection(("archlinux.org", 443), timeout=5).close()
    except OSError:
        die("No working internet connection detected.")
    run(["timedatectl", "set-ntp", "true"], check=False)


def detect_cpu() -> str:
    try:
        text = Path("/proc/cpuinfo").read_text(errors="ignore")
    except OSError:
        return ""
    return next((vendor for vendor in MICROCODE if vendor in text), "")


def detect_gpu() -> str:
    result = run(["lspci"], capture=True, check=False)
    text = (result.stdout or "").lower()
    if "nvidia" in text:
        return "nvidia"
    if any(s in text for s in ("advanced micro devices", "amd/ati", "radeon")):
        return "amd"
    if "intel" in text:
        return "intel"
    return "unknown"


def flatten_disks(nodes: list[dict]) -> list[dict]:
    found = []
    for node in nodes:
        if node.get("type") == "disk" and node.get("path"):
            found.append(node)
        found.extend(flatten_disks(node.get("children") or []))
    return found


def human_size(size: int) -> str:
    value = float(size)
    for unit in ("B", "KiB", "MiB", "GiB", "TiB"):
        if value < 1024 or unit == "TiB":
            return f"{value:.1f} {unit}"
        value /= 1024
    return str(size)


def choose_disk() -> str:
    result = run(
        ["lsblk", "-J", "-b", "-o", "PATH,SIZE,TYPE,MODEL,TRAN,RM,RO,MOUNTPOINTS"],
        capture=True,
    )
    disks = [
        d
        for d in flatten_disks(json.loads(result.stdout)["blockdevices"])
        if str(d.get("rm", 0)) == "0"
        and str(d.get("ro", 0)) == "0"
        and not str(d.get("path", "")).startswith("/dev/loop")
        and int(d.get("size") or 0) >= 32 * 1024**3
    ]
    if not disks:
        die("No writable disk of at least 32 GiB was found.")
    say("\nAvailable disks (the selected disk will be erased):")
    for index, disk in enumerate(disks, 1):
        say(
            f"  {index}. {disk['path']:<16} "
            f"{human_size(int(disk.get('size') or 0)):>10}  "
            f"{disk.get('model') or 'Unknown model'}"
        )
    while True:
        answer = input(f"Select disk [1-{len(disks)}]: ").strip()
        if answer.isdigit() and 1 <= int(answer) <= len(disks):
            disk = disks[int(answer) - 1]
            path = disk["path"]
            say(f"\n!!! ALL PARTITIONS AND DATA ON {path} WILL BE DESTROYED !!!")
            if (
                input(f"Type exactly ERASE {path} to continue: ").strip()
                == f"ERASE {path}"
            ):
                return path
            say("Confirmation did not match; nothing has been erased.")


def prompt_config() -> tuple[InstallConfig, str, str]:
    say("\nJK GRAY LINUX SECURITY WORKSTATION")
    say("1) English / US keyboard\n2) Deutsch / deutsches Tastaturlayout")
    choice = input("Language [1]: ").strip() or "1"
    if choice not in LOCALES:
        die("Invalid language selection.")
    locale, keymap = LOCALES[choice]
    hostname = input("Hostname [jk-gray]: ").strip() or "jk-gray"
    if not re.fullmatch(r"[a-zA-Z0-9][a-zA-Z0-9-]{0,62}", hostname):
        die("Hostname must contain only letters, digits and hyphens.")
    username = input("Username: ").strip().lower()
    if not re.fullmatch(r"[a-z_][a-z0-9_-]{0,31}", username):
        die("Invalid username.")
    password = getpass.getpass("User password: ")
    if len(password) < 12 or any(c in password for c in "\n\r:"):
        die(
            "Use a password of at least 12 characters; newline and colon are not allowed."
        )
    if getpass.getpass("Repeat user password: ") != password:
        die("Passwords do not match.")
    encrypted = input("Enable LUKS2 disk encryption? [Y/n]: ").strip().lower() not in {
        "n",
        "no",
    }
    luks_password = ""
    if encrypted:
        luks_password = getpass.getpass("LUKS2 passphrase (12+ characters): ")
        if len(luks_password) < 12 or "\n" in luks_password:
            die("The LUKS2 passphrase must be at least 12 characters.")
        if getpass.getpass("Repeat LUKS2 passphrase: ") != luks_password:
            die("LUKS2 passphrases do not match.")
    timezone = input("Timezone [Europe/Berlin]: ").strip() or "Europe/Berlin"
    if not re.fullmatch(r"[A-Za-z0-9_+./-]+", timezone) or ".." in timezone:
        die("Invalid timezone format.")
    return (
        InstallConfig(
            disk=choose_disk(),
            username=username,
            hostname=hostname,
            locale=locale,
            keymap=keymap,
            timezone=timezone,
            encrypted=encrypted,
            gpu=detect_gpu(),
            cpu=detect_cpu(),
        ),
        password,
        luks_password,
    )


def partition_path(disk: str, number: int) -> str:
    return (
        f"{disk}p{number}"
        if any(x in disk for x in ("nvme", "mmcblk", "loop"))
        else f"{disk}{number}"
    )


def prepare_disk(config: InstallConfig, luks_password: str) -> tuple[str, str]:
    disk = config.disk
    run(["swapoff", "-a"], check=False)
    run(["umount", "-R", str(TARGET)], check=False)
    run(["cryptsetup", "close", "jk-gray-crypt"], check=False)
    run(["wipefs", "--all", "--force", disk])
    run(["sgdisk", "--zap-all", disk])
    run(["sgdisk", "--clear", disk])
    run(
        [
            "sgdisk",
            "--new=1:1MiB:+1GiB",
            "--typecode=1:ef00",
            "--change-name=1:EFI",
            disk,
        ]
    )
    run(["sgdisk", "--new=2:0:0", "--typecode=2:8300", "--change-name=2:ROOT", disk])
    run(["partprobe", disk], check=False)
    time.sleep(2)
    esp, rootpart = partition_path(disk, 1), partition_path(disk, 2)
    run(["mkfs.fat", "-F", "32", esp])
    if config.encrypted:
        # Password travels on stdin, not command-line arguments.
        run(
            [
                "cryptsetup",
                "luksFormat",
                "--type",
                "luks2",
                "--pbkdf",
                "argon2id",
                "--batch-mode",
                "--key-file=-",
                rootpart,
            ],
            input_text=luks_password + "\n",
        )
        run(
            ["cryptsetup", "open", "--key-file=-", rootpart, "jk-gray-crypt"],
            input_text=luks_password + "\n",
        )
        luks_password = ""
        root_device = "/dev/mapper/jk-gray-crypt"
    else:
        root_device = rootpart

    run(["mkfs.btrfs", "--force", root_device])
    run(["mount", root_device, str(TARGET)])
    for name in ("@", "@home", "@var_log", "@var_cache", "@snapshots"):
        run(["btrfs", "subvolume", "create", str(TARGET / name)])
    run(["umount", str(TARGET)])
    opts = "noatime,compress=zstd:3"
    run(["mount", "-o", f"{opts},subvol=@", root_device, str(TARGET)])
    for subvol, mountpoint in (
        ("@home", "home"),
        ("@var_log", "var/log"),
        ("@var_cache", "var/cache/pacman/pkg"),
        ("@snapshots", ".snapshots"),
    ):
        path = TARGET / mountpoint
        path.mkdir(parents=True, exist_ok=True)
        run(["mount", "-o", f"{opts},subvol={subvol}", root_device, str(path)])
    (TARGET / "efi").mkdir(exist_ok=True)
    run(["mount", esp, str(TARGET / "efi")])
    return esp, rootpart


def package_list(config: InstallConfig) -> list[str]:
    packages = list(BASE_PACKAGES)
    if config.cpu in MICROCODE:
        packages.append(MICROCODE[config.cpu])
    packages.extend(GPU_PACKAGES.get(config.gpu, []))
    return list(dict.fromkeys(packages))


def install_packages(packages: list[str]) -> None:
    run(["pacman", "-Sy", "--noconfirm", "archlinux-keyring"])
    run(["pacstrap", "-K", str(TARGET), *packages])


def chroot(command: str, *, check: bool = True) -> subprocess.CompletedProcess[str]:
    return run(["arch-chroot", str(TARGET), "bash", "-euc", command], check=check)


def shell_quote(value: str) -> str:
    return "'" + value.replace("'", "'\"'\"'") + "'"


def configure_system(config: InstallConfig, user_password: str, rootpart: str) -> None:
    locale = config.locale
    chroot(
        f"sed -i 's/^#{re.escape(locale)}/{locale}/' /etc/locale.gen && "
        f"locale-gen && printf 'LANG={locale}\\n' > /etc/locale.conf"
    )
    chroot(
        f"printf '%s\\n' {shell_quote('KEYMAP=' + config.keymap)} > /etc/vconsole.conf"
    )
    chroot(
        f"ln -sf {shell_quote('/usr/share/zoneinfo/' + config.timezone)} /etc/localtime && hwclock --systohc"
    )
    chroot(f"printf '%s\\n' {shell_quote(config.hostname)} > /etc/hostname")
    chroot(
        "cat > /etc/hosts <<'EOF'\n"
        "127.0.0.1 localhost\n::1 localhost\n"
        f"127.0.1.1 {config.hostname}.localdomain {config.hostname}\nEOF"
    )

    hooks = "base systemd autodetect microcode modconf kms keyboard sd-vconsole block"
    if config.encrypted:
        hooks += " sd-encrypt"
    hooks += " filesystems fsck"
    chroot(f"sed -i 's/^HOOKS=.*/HOOKS=({hooks})/' /etc/mkinitcpio.conf")

    if config.encrypted:
        luks_uuid = subprocess.check_output(
            ["blkid", "-s", "UUID", "-o", "value", rootpart], text=True
        ).strip()
        chroot(
            f"printf '%s\\n' {shell_quote('rd.luks.name=' + luks_uuid + '=jk-gray-crypt')} > /etc/crypttab.initramfs"
        )
        btrfs_uuid = subprocess.check_output(
            ["blkid", "-s", "UUID", "-o", "value", "/dev/mapper/jk-gray-crypt"],
            text=True,
        ).strip()
        cmdline = f"rd.luks.name={luks_uuid}=jk-gray-crypt root=UUID={btrfs_uuid} rootflags=subvol=@ rw"
    else:
        btrfs_uuid = subprocess.check_output(
            ["blkid", "-s", "UUID", "-o", "value", rootpart], text=True
        ).strip()
        cmdline = f"root=UUID={btrfs_uuid} rootflags=subvol=@ rw"
    chroot("mkdir -p /efi/EFI/Linux /etc/kernel")
    chroot(
        "printf 'layout=uki\\nuki_generator=mkinitcpio\\n' > /etc/kernel/install.conf"
    )
    chroot(f"printf '%s\\n' {shell_quote(cmdline)} > /etc/kernel/cmdline")

    chroot(
        f"useradd --create-home --groups wheel,audio,video,input,storage {shell_quote(config.username)}"
    )
    # Feed the password through stdin; never expose it in process arguments.
    pwfile = TARGET / "root" / ".jk-gray-user-pw"
    pwfile.write_text(f"{config.username}:{user_password}\n", encoding="utf-8")
    os.chmod(pwfile, 0o600)
    try:
        chroot("chpasswd < /root/.jk-gray-user-pw")
    finally:
        pwfile.unlink(missing_ok=True)
    chroot(
        "install -d -m 0750 /etc/sudoers.d && printf '%s\\n' '%wheel ALL=(ALL:ALL) ALL' > /etc/sudoers.d/10-wheel && chmod 0440 /etc/sudoers.d/10-wheel"
    )

    for service in (
        "NetworkManager.service",
        "bluetooth.service",
        "systemd-timesyncd.service",
        "fstrim.timer",
    ):
        chroot(f"systemctl enable {service}")
    chroot(
        "cat > /etc/systemd/zram-generator.conf <<'EOF'\n"
        "[zram0]\nzram-size = ram / 2\ncompression-algorithm = zstd\n"
        "swap-priority = 100\nEOF"
    )
    chroot(
        "cat > /etc/sysctl.d/90-jk-gray-security.conf <<'EOF'\n"
        "kernel.kptr_restrict = 2\nkernel.dmesg_restrict = 1\n"
        "fs.protected_fifos = 2\nfs.protected_regular = 2\n"
        "net.ipv4.conf.all.accept_redirects = 0\n"
        "net.ipv4.conf.default.accept_redirects = 0\n"
        "net.ipv6.conf.all.accept_redirects = 0\n"
        "net.ipv6.conf.default.accept_redirects = 0\n"
        "net.ipv4.conf.all.rp_filter = 1\n"
        "net.ipv4.conf.default.rp_filter = 1\nEOF"
    )
    chroot("sysctl --system", check=False)
    configure_desktop(config)


def configure_desktop(config: InstallConfig) -> None:
    user = config.username
    home = f"/home/{user}"
    chroot(f"install -d -m 0700 {shell_quote(home + '/.config/hypr')}")
    hypr = f"""# JK Gray Linux Hyprland defaults — adjust for your hardware.
monitor = , preferred, auto, 1
$terminal = kitty
$menu = wofi --show drun
exec-once = waybar
exec-once = nm-applet --indicator
exec-once = hyprpolkitagent
exec-once = mako
exec-once = hypridle
input {{
    kb_layout = {config.keymap}
    follow_mouse = 1
    sensitivity = 0
}}
general {{
    gaps_in = 5
    gaps_out = 10
    border_size = 2
    layout = dwindle
}}
decoration {{
    rounding = 8
}}
misc {{
    disable_hyprland_logo = true
}}
bind = SUPER, RETURN, exec, $terminal
bind = SUPER, D, exec, $menu
bind = SUPER, Q, killactive
bind = SUPER, L, exec, hyprlock
bind = SUPER SHIFT, E, exit
"""
    lock = """general {
    hide_cursor = true
}
background {
    monitor =
    color = rgba(101014ee)
}
input-field {
    monitor =
    size = 280, 55
    outline_thickness = 2
    dots_size = 0.25
    dots_spacing = 0.2
    dots_center = true
    outer_color = rgb(65b9ad)
    inner_color = rgb(171923)
    font_color = rgb(ffffff)
    placeholder_text = Password...
}
"""
    # Write generated config files without shell interpolation.
    for rel, content in (
        (".config/hypr/hyprland.conf", hypr),
        (".config/hypr/hyprlock.conf", lock),
        (
            ".bash_profile",
            'if [ -z "${WAYLAND_DISPLAY:-}" ] && [ "$(tty 2>/dev/null)" = "/dev/tty1" ]; then\n  exec Hyprland\nfi\n',
        ),
    ):
        dest = TARGET / home.lstrip("/") / rel
        dest.parent.mkdir(parents=True, exist_ok=True)
        dest.write_text(content, encoding="utf-8")
        os.chmod(dest, 0o600)
    chroot(
        f"chown -R {shell_quote(user + ':' + user)} {shell_quote(home + '/.config')} {shell_quote(home + '/.bash_profile')}"
    )


def configure_boot() -> None:
    chroot("bootctl --esp-path=/efi install")
    chroot(
        "cat > /efi/loader/loader.conf <<'EOF'\n"
        "default @saved\ntimeout 3\nconsole-mode auto\neditor no\nEOF"
    )
    chroot("mkinitcpio -P")
    images = list((TARGET / "efi/EFI/Linux").glob("*.efi"))
    if not images:
        die(
            "No Unified Kernel Image was generated. Installation stopped before reboot."
        )
    chroot("bootctl --esp-path=/efi status", check=False)


def cleanup() -> None:
    run(["sync"], check=False)
    run(["umount", "-R", str(TARGET)], check=False)
    run(["cryptsetup", "close", "jk-gray-crypt"], check=False)


def main() -> None:
    require_environment()
    STATE.mkdir(parents=True, exist_ok=True)
    LOG.write_text(f"{APP} {VERSION} started at {time.ctime()}\n", encoding="utf-8")
    config, user_password, luks_password = prompt_config()
    say(f"\nDetected CPU vendor: {config.cpu or 'unknown'}")
    say(f"Detected GPU: {config.gpu}")
    say("\nInstall plan:")
    say(f"  Disk: {config.disk}")
    say(f"  Encryption: {'LUKS2' if config.encrypted else 'disabled'}")
    say("  Desktop: Hyprland + Waybar + Firefox + Kitty + Wofi")
    say("  BlackArch tools/repositories: not installed or enabled")
    if (
        input("\nType INSTALL to begin the destructive installation: ").strip()
        != "INSTALL"
    ):
        die("Cancelled before disk changes.", 130)

    try:
        prepare_disk(config, luks_password)
        luks_password = ""
        packages = package_list(config)
        install_packages(packages)
        run(["bash", "-c", f"genfstab -U {TARGET} > {TARGET}/etc/fstab"])
        rootpart = partition_path(config.disk, 2)
        configure_system(config, user_password, rootpart)
        user_password = ""
        configure_boot()
        say(
            "\nJK Gray Linux installation finished. Review the log, remove the live USB, then reboot."
        )
        say(
            "Next steps: verify updates, configure a firewall, review AppArmor, and plan Secure Boot."
        )
        say(
            "Pentesting toolsets should be installed later from verified, documented sources."
        )
    except KeyboardInterrupt:
        die(
            "Interrupted. The disk may be partially configured; do not reboot without inspection.",
            130,
        )
    finally:
        cleanup()


if __name__ == "__main__":
    main()
