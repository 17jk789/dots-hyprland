#!/usr/bin/env python3

import os
import re
import shutil
import subprocess
import sys
from pathlib import Path


APPARMOR_LSM_VALUE = "landlock,lockdown,yama,integrity,apparmor,bpf"
APPARMOR_LSM = f"lsm={APPARMOR_LSM_VALUE}"

LIMINE_CONF = Path("/boot/limine.conf")
SYSTEMD_BOOT_ENTRIES = Path("/boot/loader/entries")
GRUB_DEFAULT = Path("/etc/default/grub")


def run(command, check=False):
    print(f"+ {' '.join(command)}")

    result = subprocess.run(
        command,
        check=False,
    )

    if check and result.returncode != 0:
        print(
            f"Command failed with exit code {result.returncode}: "
            f"{' '.join(command)}",
            file=sys.stderr,
        )
        sys.exit(result.returncode)

    return result.returncode


def backup_file(path):
    if not path.exists():
        return

    backup = Path(str(path) + ".jk-backup")

    if backup.exists():
        print(f"Backup already exists: {backup}")
        return

    shutil.copy2(path, backup)
    print(f"Created backup: {backup}")


def read_cmdline():
    try:
        return Path("/proc/cmdline").read_text().strip()
    except OSError as error:
        print(f"Warning: could not read /proc/cmdline: {error}")
        return ""


def check_running_kernel():
    current_cmdline = read_cmdline()

    if "lsm=" in current_cmdline:
        print(f"Current kernel command line contains: {current_cmdline}")
    else:
        print("Current kernel command line contains no lsm= parameter.")

    if "apparmor" in current_cmdline:
        print("AppArmor is present in the current kernel command line.")
    else:
        print(
            "AppArmor is not present in the current kernel command line. "
            "A reboot may be required after configuration."
        )


def update_limine():
    if not LIMINE_CONF.exists():
        return False

    print(f"Configuring Limine: {LIMINE_CONF}")

    backup_file(LIMINE_CONF)

    content = LIMINE_CONF.read_text()

    if APPARMOR_LSM in content:
        print("AppArmor LSM parameter is already present in limine.conf.")
        return True

    lines = content.splitlines()

    changed = False
    new_lines = []

    for line in lines:
        stripped = line.strip()

        if stripped.startswith("cmdline:"):
            if re.search(r"\blsm=[^\s]+", line):
                print(
                    "An existing lsm= parameter was found in a Limine cmdline."
                )
                print(
                    "It will not be overwritten automatically. "
                    "Review the existing LSM configuration manually."
                )
                new_lines.append(line)
                continue

            newline = f"{line} {APPARMOR_LSM}"
            new_lines.append(newline)
            changed = True
            continue

        new_lines.append(line)

    if not changed:
        print(
            "No 'cmdline:' entry was found in /boot/limine.conf. "
            "Add the following kernel parameter manually:"
        )
        print(f"  {APPARMOR_LSM}")
        return True

    trailing_newline = "\n" if content.endswith("\n") else ""
    LIMINE_CONF.write_text("\n".join(new_lines) + trailing_newline)

    print(f"Updated {LIMINE_CONF}.")
    print(f"Added kernel parameter: {APPARMOR_LSM}")

    return True


def update_systemd_boot():
    if not SYSTEMD_BOOT_ENTRIES.exists():
        return False

    entry_files = list(SYSTEMD_BOOT_ENTRIES.glob("*.conf"))

    if not entry_files:
        print(
            f"No systemd-boot entries found in {SYSTEMD_BOOT_ENTRIES}."
        )
        return True

    print("Configuring systemd-boot entries...")

    for entry in entry_files:
        backup_file(entry)

        content = entry.read_text()

        if APPARMOR_LSM in content:
            print(f"{entry}: AppArmor LSM parameter already present.")
            continue

        lines = content.splitlines()
        changed = False
        new_lines = []

        for line in lines:
            if line.strip().startswith("options "):
                if re.search(r"\blsm=[^\s]+", line):
                    print(
                        f"{entry}: existing lsm= parameter found; "
                        "not modifying it automatically."
                    )
                    new_lines.append(line)
                    continue

                new_lines.append(f"{line} {APPARMOR_LSM}")
                changed = True
            else:
                new_lines.append(line)

        if changed:
            trailing_newline = "\n" if content.endswith("\n") else ""
            entry.write_text(
                "\n".join(new_lines) + trailing_newline
            )
            print(f"Updated {entry}.")

    return True


def update_grub():
    if not GRUB_DEFAULT.exists():
        return False

    print(f"Configuring GRUB: {GRUB_DEFAULT}")

    backup_file(GRUB_DEFAULT)

    content = GRUB_DEFAULT.read_text()

    if APPARMOR_LSM in content:
        print("AppArmor LSM parameter is already present in /etc/default/grub.")
        return True

    lines = content.splitlines()
    changed = False
    new_lines = []

    for line in lines:
        if line.startswith("GRUB_CMDLINE_LINUX_DEFAULT="):
            match = re.match(
                r'GRUB_CMDLINE_LINUX_DEFAULT="(.*)"',
                line,
            )

            if not match:
                new_lines.append(line)
                continue

            parameters = match.group(1)

            if re.search(r"\blsm=[^\s]+", parameters):
                print(
                    "An existing lsm= parameter was found in GRUB_CMDLINE_LINUX_DEFAULT."
                )
                print(
                    "It will not be overwritten automatically. "
                    "Review the existing LSM configuration manually."
                )
                new_lines.append(line)
                continue

            parameters = f"{parameters} {APPARMOR_LSM}".strip()

            new_lines.append(
                f'GRUB_CMDLINE_LINUX_DEFAULT="{parameters}"'
            )

            changed = True
        else:
            new_lines.append(line)

    if changed:
        trailing_newline = "\n" if content.endswith("\n") else ""
        GRUB_DEFAULT.write_text(
            "\n".join(new_lines) + trailing_newline
        )

        print(f"Updated {GRUB_DEFAULT}.")
        print(f"Added kernel parameter: {APPARMOR_LSM}")

        if shutil.which("grub-mkconfig"):
            print("Regenerating GRUB configuration...")
            run(
                [
                    "grub-mkconfig",
                    "-o",
                    "/boot/grub/grub.cfg",
                ],
                check=True,
            )

    return True


def configure_kernel_parameter():
    print("Configuring AppArmor kernel parameter...")
    print()

    if update_limine():
        return

    if update_systemd_boot():
        return

    if update_grub():
        return

    print()
    print("No supported bootloader configuration was detected.")
    print()
    print("Add the following kernel parameter manually:")
    print()
    print(f"    {APPARMOR_LSM}")
    print()


def enable_apparmor_service():
    run(
        [
            "systemctl",
            "enable",
            "--now",
            "apparmor.service",
        ],
        check=True,
    )


def check_apparmor_enabled():
    result = run(["aa-enabled"])

    if result == 0:
        print("AppArmor is enabled.")
    else:
        print(
            "Warning: aa-enabled reports that AppArmor "
            "is not currently enabled."
        )
        print(
            "A reboot may be required for the configured "
            "kernel parameter to take effect."
        )


def show_status():
    print()
    print("Current AppArmor status:")
    print()

    run(["aa-status"])


def main():
    if os.geteuid() != 0:
        print(
            "This script must be run as root.",
            file=sys.stderr,
        )
        sys.exit(1)

    print("Configuring AppArmor for Arch Linux...")
    print()

    configure_kernel_parameter()

    print()

    enable_apparmor_service()

    print()

    check_running_kernel()

    print()

    check_apparmor_enabled()

    print()

    show_status()

    print()
    print("AppArmor configuration completed.")
    print()
    print(
        "If the lsm= parameter was newly added, "
        "reboot the system before relying on AppArmor as "
        "the default LSM."
    )


if __name__ == "__main__":
    main()
