#!/usr/bin/env python3
"""
ARCH LINUX + HYPRLAND SECURE INSTALLER
======================================

Run from the official Arch Linux ISO as root.

Design goals:
- UEFI + GPT only
- Btrfs with sensible subvolumes
- Optional LUKS2 full-disk encryption
- systemd-boot + UKI on UEFI
- NetworkManager + PipeWire/WirePlumber
- Hyprland desktop
- CPU microcode + automatic GPU packages
- zram
- no autologin
- no AUR, no third-party repos
- AppArmor/UFW/fail2ban deliberately NOT configured here

WARNING:
The selected target disk is completely erased.
"""
from __future__ import annotations

import getpass
import json
import os
import platform
import re
import shutil
import socket
import subprocess
import sys
import time
from pathlib import Path

WORK = Path("/root/arch-hyprland-installer")
LOG = WORK / "installer.log"
TARGET = Path("/mnt")

BASE = [
    "base", "linux", "linux-firmware", "btrfs-progs",
    "cryptsetup", "dosfstools", "efibootmgr", "sudo", "networkmanager",
    "polkit", "fish",
    "pipewire", "pipewire-audio", "pipewire-pulse", "wireplumber",
    "bluez", "bluez-utils",
    "xdg-utils", "xdg-user-dirs", "xdg-user-dirs-gtk",
    "xdg-desktop-portal", "xdg-desktop-portal-hyprland",
    "hyprland", "hyprcursor", "hyprpolkitagent",
    "waybar", "mako", "grim", "slurp", "wl-clipboard",
    "pavucontrol", "network-manager-applet", "blueman",
    "thunar", "file-roller", "unzip", "tar",
    "ttf-dejavu", "ttf-liberation", "noto-fonts", "noto-fonts-emoji",
    "otf-font-awesome", "zram-generator",
]

GPU = {
    "amd": ["mesa", "vulkan-radeon", "lib32-mesa", "lib32-vulkan-radeon"],
    "intel": ["mesa", "vulkan-intel", "lib32-mesa", "lib32-vulkan-intel"],
    "nvidia": ["nvidia", "nvidia-utils", "lib32-nvidia-utils"],
}

MICROCODE = {"AuthenticAMD": "amd-ucode", "GenuineIntel": "intel-ucode"}

def die(msg: str) -> "NoReturn":
    print(f"\nERROR: {msg}", file=sys.stderr)
    raise SystemExit(1)

def log(msg: str) -> None:
    WORK.mkdir(parents=True, exist_ok=True)
    with LOG.open("a", encoding="utf-8") as f:
        f.write(msg + "\n")

def run(cmd: list[str], *, check=True, capture=False, input_text=None) -> subprocess.CompletedProcess[str]:
    shown = " ".join(cmd)
    print(f"\033[90m$ {shown}\033[0m")
    log("$ " + shown)
    p = subprocess.run(
        cmd, text=True, input=input_text,
        stdout=subprocess.PIPE if capture else None,
        stderr=subprocess.STDOUT if capture else None,
        check=False,
    )
    if capture and p.stdout:
        log(p.stdout)
    if check and p.returncode:
        die(f"Command failed ({p.returncode}): {shown}")
    return p

def require_root() -> None:
    if os.geteuid() != 0:
        die("Run this installer as root.")

def require_uefi() -> None:
    if not Path("/sys/firmware/efi").exists():
        die("UEFI mode is required. Boot the official Arch ISO in UEFI mode.")

def require_archiso() -> None:
    if not Path("/run/archiso").exists() and not Path("/etc/arch-release").exists():
        die("This does not look like the official Arch ISO.")

def internet() -> None:
    try:
        socket.create_connection(("archlinux.org", 443), timeout=5).close()
    except OSError:
        die("No internet connection.")

def sync_clock() -> None:
    run(["timedatectl", "set-ntp", "true"], check=False)

def cpu_vendor() -> str:
    try:
        s = Path("/proc/cpuinfo").read_text(errors="ignore")
    except OSError:
        return ""
    for v in MICROCODE:
        if v in s:
            return v
    return ""

def gpu_vendor() -> str:
    p = run(["lspci"], capture=True, check=False)
    s = (p.stdout or "").lower()
    if "nvidia" in s:
        return "nvidia"
    if "advanced micro devices" in s or "amd/ati" in s or "radeon" in s:
        return "amd"
    if "intel" in s:
        return "intel"
    return "unknown"

def disk_list() -> list[dict]:
    p = run(["lsblk", "-J", "-b", "-o", "PATH,SIZE,TYPE,MODEL,TRAN,RM,RO,MOUNTPOINTS"],
            capture=True)
    return json.loads(p.stdout)["blockdevices"]

def size(n: int) -> str:
    x = float(n)
    for u in ("B", "KiB", "MiB", "GiB", "TiB"):
        if x < 1024 or u == "TiB":
            return f"{x:.1f} {u}"
        x /= 1024
    return str(n)

def choose_disk() -> str:
    ds = [d for d in disk_list()
          if d.get("type") == "disk" and d.get("path")
          and str(d.get("rm", 0)) == "0" and str(d.get("ro", 0)) == "0"
          and not str(d["path"]).startswith("/dev/loop")]
    if not ds:
        die("No writable internal disk found.")
    print("\nTARGET DISKS:")
    for i, d in enumerate(ds, 1):
        print(f"  {i}) {d['path']:15} {size(int(d.get('size',0))):>10} "
              f"{d.get('tran') or '?':5} {d.get('model') or 'unknown'}")
    while True:
        a = input(f"Select disk [1-{len(ds)}]: ").strip()
        if a.isdigit() and 1 <= int(a) <= len(ds):
            d = ds[int(a)-1]
            path = d["path"]
            if int(d.get("size", 0)) < 32 * 1024**3:
                die("At least 32 GiB is required.")
            print(f"\n\033[1;31m!!! {path} WILL BE COMPLETELY ERASED !!!\033[0m")
            confirm = input("Type ERASE to continue: ")
            if confirm == "ERASE":
                return path
        print("Invalid selection or confirmation.")

def choose_language() -> tuple[str, str, str]:
    print("\nLANGUAGE: 1) German  2) English")
    while True:
        a = input("Selection [1-2]: ").strip()
        if a == "1": return "de_DE.UTF-8", "de_DE.UTF-8", "de"
        if a == "2": return "en_US.UTF-8", "en_US.UTF-8", "en"

def choose_keyboard() -> str:
    choices = ["de", "us", "gb", "fr", "es", "it"]
    print("\nKEYBOARD:")
    for i, x in enumerate(choices, 1):
        print(f"  {i}) {x}")
    while True:
        a = input("Selection: ").strip()
        if a.isdigit() and 1 <= int(a) <= len(choices):
            return choices[int(a)-1]

def choose_encryption() -> bool:
    print("\nDISK ENCRYPTION:")
    print("  1) LUKS2 full-disk encryption (recommended)")
    print("  2) No disk encryption")
    while True:
        a = input("Selection [1-2]: ").strip()
        if a == "1": return True
        if a == "2": return False

def valid_user(u: str) -> bool:
    return bool(re.fullmatch(r"[a-z_][a-z0-9_-]{0,31}", u))

def choose_user() -> tuple[str, str]:
    while True:
        u = input("\nUsername: ").strip().lower()
        if valid_user(u): break
        print("Invalid username.")
    while True:
        p1 = getpass.getpass("User password: ")
        p2 = getpass.getpass("Repeat user password: ")
        if p1 and p1 == p2:
            return u, p1
        print("Passwords do not match or are empty.")

def choose_luks_password() -> str:
    print("\nLUKS2 password protects the disk at boot.")
    print("Use a long unique passphrase. Do NOT reuse your login password.")
    while True:
        p1 = getpass.getpass("LUKS2 passphrase: ")
        p2 = getpass.getpass("Repeat LUKS2 passphrase: ")
        if len(p1) >= 12 and p1 == p2:
            return p1
        print("Passphrases must match and be at least 12 characters.")

def pkg_available(pkg: str) -> bool:
    return run(["pacman", "-Si", pkg], capture=True, check=False).returncode == 0

def packages_for(gpu: str, cpu: str) -> list[str]:
    out = list(BASE)
    if cpu in MICROCODE:
        out.append(MICROCODE[cpu])
    if gpu in GPU:
        out += GPU[gpu]
    # Keep linux-hardened optional; don't make NVIDIA recovery dependent on it.
    return list(dict.fromkeys(out))

def wipe_disk(disk: str) -> None:
    run(["swapoff", "-a"], check=False)
    run(["umount", "-R", str(TARGET)], check=False)
    run(["cryptsetup", "close", "cryptroot"], check=False)
    run(["wipefs", "-af", disk])
    run(["sgdisk", "--zap-all", disk])
    run(["sgdisk", "-og", disk])

def part_path(disk: str, number: int) -> str:
    return f"{disk}p{number}" if "nvme" in disk or "mmcblk" in disk else f"{disk}{number}"

def partition(disk: str) -> tuple[str, str]:
    # 1 GiB ESP, rest Linux filesystem. GPT alignment is handled by sgdisk.
    run(["sgdisk", "-n", "1:1MiB:+1GiB", "-t", "1:ef00", "-c", "1:EFI", disk])
    run(["sgdisk", "-n", "2:0:0", "-t", "2:8300", "-c", "2:CRYPTROOT", disk])
    run(["partprobe", disk], check=False)
    time.sleep(2)
    return part_path(disk, 1), part_path(disk, 2)

def mkfs_and_mount(esp: str, rootpart: str, encrypted: bool, luks_password: str | None) -> tuple[str, str]:
    run(["mkfs.fat", "-F", "32", esp])
    if encrypted:
        run(["cryptsetup", "luksFormat", "--type", "luks2",
             "--pbkdf", "argon2id", "--batch-mode", "--key-file=-", rootpart],
            input_text=luks_password + "\n")
        run(["cryptsetup", "open", "--key-file=-", rootpart, "cryptroot"],
            input_text=luks_password + "\n")
        luks_password = None
        crypt = "/dev/mapper/cryptroot"
    else:
        crypt = rootpart

    run(["mkfs.btrfs", "-f", crypt])
    run(["mount", crypt, str(TARGET)])
    for name in ("@", "@home", "@log", "@cache", "@snapshots", "@tmp"):
        run(["btrfs", "subvolume", "create", str(TARGET / name)])
    run(["umount", str(TARGET)])

    opts = "compress=zstd:3,noatime"
    mounts = [
        ("@", "/", opts),
        ("@home", "/home", opts),
        ("@log", "/var/log", opts),
        ("@cache", "/var/cache/pacman/pkg", opts),
        ("@snapshots", "/.snapshots", opts),
        ("@tmp", "/tmp", opts),
    ]
    run(["mount", "-o", opts + ",subvol=@", crypt, str(TARGET)])
    for subvol, mp, options in mounts[1:]:
        dest = TARGET / mp.lstrip("/")
        dest.mkdir(parents=True, exist_ok=True)
        run(["mount", "-o", options + f",subvol={subvol}", crypt, str(dest)])
    (TARGET / "efi").mkdir(exist_ok=True)
    run(["mount", esp, str(TARGET / "efi")])
    return crypt, opts

def pacstrap(disk: str, pkgs: list[str]) -> None:
    # Install only packages that exist in the current official repositories.
    missing = [p for p in pkgs if not pkg_available(p)]
    if missing:
        die("Unavailable packages in current Arch repos: " + ", ".join(missing))
    run(["pacstrap", "-K", str(TARGET)] + pkgs)

def gen_fstab() -> None:
    # Append generated UUID-based mounts to the target fstab.
    run(["bash", "-c", f"genfstab -U {TARGET} > {TARGET}/etc/fstab"])

def chroot(cmd: str, check=True) -> subprocess.CompletedProcess[str]:
    return run(["arch-chroot", str(TARGET), "bash", "-euc", cmd], check=check)

def setup_base(locale: str, keyboard: str, username: str, user_password: str,
               encrypted: bool, rootpart: str, gpu: str, cpu: str) -> None:
    # locale and timezone
    chroot(f"""
sed -i 's/^#\\({re.escape(locale)}\\)/\\1/' /etc/locale.gen
locale-gen
printf 'LANG={locale}\\n' > /etc/locale.conf
printf 'KEYMAP={keyboard}\\n' > /etc/vconsole.conf
ln -sf /usr/share/zoneinfo/Europe/Berlin /etc/localtime
hwclock --systohc
printf 'archlinux\\n' > /etc/hostname
cat > /etc/hosts <<'EOF'
127.0.0.1 localhost
::1 localhost
127.0.1.1 archlinux.localdomain archlinux
EOF
""")
    # mkinitcpio: systemd initrd + sd-encrypt for LUKS2.
    if encrypted:
        hooks = "base systemd autodetect microcode modconf kms keyboard sd-vconsole block sd-encrypt filesystems fsck"
    else:
        hooks = "base systemd autodetect microcode modconf kms keyboard sd-vconsole block filesystems fsck"
    chroot(f"""
sed -i 's/^HOOKS=.*/HOOKS=({hooks})/' /etc/mkinitcpio.conf
""")
    if encrypted:
        # Get UUID from installed target, not from assumptions about device naming.
        luks_uuid = subprocess.check_output(
            ["blkid", "-s", "UUID", "-o", "value", rootpart], text=True
        ).strip()
        chroot(f"printf 'rd.luks.name={luks_uuid}=cryptroot\\\\n' > /etc/crypttab.initramfs")
    # UKI configuration
    chroot(r"""
mkdir -p /efi/EFI/Linux /etc/kernel
printf 'layout=uki\nuki_generator=mkinitcpio\n' > /etc/kernel/install.conf
""")
    # cmdline based on filesystem UUID and LUKS UUID.
    btrfs_uuid = subprocess.check_output(
        ["blkid", "-s", "UUID", "-o", "value",
         str(rootpart if not encrypted else Path("/dev/mapper/cryptroot"))], text=True
    ).strip()
    if encrypted:
        luks_uuid = subprocess.check_output(
            ["blkid", "-s", "UUID", "-o", "value", rootpart], text=True
        ).strip()
        cmdline = f"rd.luks.name={luks_uuid}=cryptroot root=UUID={btrfs_uuid} rootflags=subvol=@ rw"
    else:
        cmdline = f"root=UUID={btrfs_uuid} rootflags=subvol=@ rw"
    chroot(f"printf '%s\\n' {shq(cmdline)} > /etc/kernel/cmdline")

    # user; password is transferred through a mode-600 temporary file, not argv.
    chroot(f"useradd -m -G wheel,audio,video,input,storage {shq(username)}")
    pwfile = TARGET / "root" / ".arch-installer-user-pw"
    pwfile.write_text(f"{username}:{user_password}\\n", encoding="utf-8")
    os.chmod(pwfile, 0o600)
    chroot("chpasswd < /root/.arch-installer-user-pw")
    try:
        pwfile.unlink()
    except FileNotFoundError:
        pass
    chroot("printf '%s\\n' '%wheel ALL=(ALL:ALL) ALL' > /etc/sudoers.d/10-wheel")
    chroot("chmod 440 /etc/sudoers.d/10-wheel")

    # services
    for service in ("NetworkManager.service", "bluetooth.service", "systemd-timesyncd.service"):
        chroot(f"systemctl enable {service}")

    # zram
    chroot(r"""
cat > /etc/systemd/zram-generator.conf <<'EOF'
[zram0]
zram-size = ram / 2
compression-algorithm = zstd
swap-priority = 100
EOF
""")

    # Basic secure sysctl defaults that are low-risk for desktop use.
    chroot(r"""
cat > /etc/sysctl.d/90-desktop-security.conf <<'EOF'
kernel.kptr_restrict = 2
kernel.dmesg_restrict = 1
kernel.unprivileged_bpf_disabled = 1
fs.protected_fifos = 2
fs.protected_regular = 2
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1
net.ipv4.icmp_echo_ignore_broadcasts = 1
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv6.conf.all.accept_redirects = 0
net.ipv6.conf.default.accept_redirects = 0
EOF
sysctl --system || true
""")

    # Polkit agent + Hyprland session. No autologin.
    chroot(f"""
install -d -m 700 /home/{username}/.config/hypr
cat > /home/{username}/.config/hypr/hyprland.conf <<'EOF'
monitor=,preferred,auto,1
$terminal = kitty
$menu = wofi --show drun
exec-once = waybar
exec-once = nm-applet --indicator
exec-once = hyprpolkitagent
exec-once = mako
input {{
    kb_layout = {keyboard}
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
bind = SUPER, M, exit
bind = SUPER, L, exec, hyprlock
EOF
chown -R {username}:{username} /home/{username}/.config
chmod 700 /home/{username}
""")

    # Hyprlock config
    chroot(f"""
cat > /home/{username}/.config/hypr/hyprlock.conf <<'EOF'
general {{
    hide_cursor = true
}}
background {{
    monitor =
    color = rgba(17,17,17,1)
}}
input-field {{
    monitor =
    size = 250, 50
    outline_thickness = 2
    dots_size = 0.2
    dots_spacing = 0.2
    dots_center = true
    outer_color = rgb(aaaaaa)
    inner_color = rgb(222222)
    font_color = rgb(ffffff)
    fade_on_empty = false
    placeholder_text = <i>Password...</i>
}}
EOF
chown {username}:{username} /home/{username}/.config/hypr/hyprlock.conf
""")

    # User environment: start Hyprland only after a normal tty login.
    chroot(f"""
cat > /home/{username}/.bash_profile <<'EOF'
if [ -z "${{WAYLAND_DISPLAY:-}}" ] && [ "$(tty 2>/dev/null)" = "/dev/tty1" ]; then
    exec Hyprland
fi
EOF
chown {username}:{username} /home/{username}/.bash_profile
""")

def shq(s: str) -> str:
    return "'" + s.replace("'", "'\"'\"'") + "'"

def setup_bootloader() -> None:
    chroot(r"""
bootctl --esp-path=/efi install
mkdir -p /efi/EFI/Linux /etc/kernel
cat > /efi/loader/loader.conf <<'EOF'
default @saved
timeout 3
console-mode auto
editor no
EOF
""")
    # Build UKI after kernel and config are present.
    chroot("mkinitcpio -P")
    # Ensure a UKI exists. If preset support changed, kernel-install is the fallback.
    if not list((TARGET / "efi/EFI/Linux").glob("*.efi")):
        modules = [p for p in (TARGET / "usr/lib/modules").iterdir() if p.is_dir()]
        if modules:
            ver = sorted(modules, key=lambda p: p.name)[-1].name
            chroot(f"kernel-install add {shq(ver)} {shq('/usr/lib/modules/' + ver + '/vmlinuz')}", check=False)
    if not list((TARGET / "efi/EFI/Linux").glob("*.efi")):
        die("No UKI was generated in /efi/EFI/Linux.")
    chroot("bootctl status", check=False)

def cleanup() -> None:
    run(["sync"], check=False)
    run(["umount", "-R", str(TARGET)], check=False)
    run(["cryptsetup", "close", "cryptroot"], check=False)

def main() -> None:
    require_root()
    require_archiso()
    require_uefi()
    internet()
    sync_clock()

    WORK.mkdir(parents=True, exist_ok=True)
    LOG.write_text(f"Started {time.ctime()}\n", encoding="utf-8")

    print("""
============================================================
       ARCH LINUX + HYPRLAND SECURE INSTALLER
============================================================
UEFI + GPT + Btrfs + optional LUKS2 + systemd-boot + UKI
No AUR. No third-party repositories. No autologin.
AppArmor/UFW/fail2ban are intentionally left for later.
============================================================
""")

    locale, _, lang = choose_language()
    keyboard = choose_keyboard()
    encrypted = choose_encryption()
    disk = choose_disk()
    username, user_password = choose_user()
    luks_password = choose_luks_password() if encrypted else None

    cpu = cpu_vendor()
    gpu = gpu_vendor()
    print(f"\nDetected CPU: {cpu or 'unknown'}")
    print(f"Detected GPU: {gpu}")

    pkgs = packages_for(gpu, cpu)
    missing = [p for p in pkgs if not pkg_available(p)]
    if missing:
        print("\nWARNING: packages unavailable:")
        print(" ".join(missing))
        if input("Abort? [Y/n]: ").strip().lower() != "n":
            die("Aborted because required packages are unavailable.")

    wipe_disk(disk)
    esp, rootpart = partition(disk)
    mkfs_and_mount(esp, rootpart, encrypted, luks_password)

    # Passwords are no longer needed after formatting/user creation.
    pacstrap(disk, pkgs)
    gen_fstab()
    setup_base(locale, keyboard, username, user_password, encrypted, rootpart, gpu, cpu)
    setup_bootloader()

    # Optional hardening kernel installed only as an additional recovery choice.
    chroot("pacman -S --noconfirm --needed linux-hardened", check=False)
    chroot("mkinitcpio -P", check=False)

    # Remove transient installer state.
    shutil.rmtree(WORK, ignore_errors=True)
    cleanup()

    print("""
============================================================
INSTALLATION COMPLETE
============================================================
Remove the Arch ISO/USB and reboot.

Encrypted installation:
  Enter your LUKS2 passphrase at boot.

Desktop:
  Log in normally on tty1.
  Hyprland starts automatically after the normal user login.

Next security stages can be added separately:
  1. AppArmor
  2. UFW/nftables firewall
  3. Fail2ban
  4. Secure Boot with sbctl
  5. Optional TPM2/FIDO2 unlock
============================================================
""")
    input("Press Enter to reboot...")
    run(["reboot"])

if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print("\nAborted.")
        sys.exit(130)
