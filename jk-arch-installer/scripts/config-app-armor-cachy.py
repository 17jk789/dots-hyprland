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

PARSER_CONF = Path("/etc/apparmor/parser.conf")
APPARMOR_CACHE_DIR = Path("/etc/apparmor/earlypolicy")


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


def configure_limine():
    if not LIMINE_CONF.exists():
        print()
        print(
            f"Warning: {LIMINE_CONF} was not found."
        )
        print()
        print(
            "CachyOS AppArmor configuration requires the AppArmor "
            "LSM kernel parameter to be added to the boot manager."
        )
        print()
        print("Add this parameter manually:")
        print()
        print(f"    {APPARMOR_LSM}")
        print()

        return False

    print(f"Configuring CachyOS Limine configuration: {LIMINE_CONF}")

    backup_file(LIMINE_CONF)

    content = LIMINE_CONF.read_text()

    if APPARMOR_LSM in content:
        print(
            "The complete AppArmor LSM parameter is already "
            "present in limine.conf."
        )
        return True

    lines = content.splitlines()

    changed = False
    new_lines = []

    for line in lines:
        stripped = line.strip()

        if stripped.startswith("cmdline:"):
            existing_lsm = re.search(
                r"\blsm=[^\s]+",
                line,
            )

            if existing_lsm:
                existing_value = existing_lsm.group(0)

                if "apparmor" in existing_value:
                    print(
                        "An existing lsm= parameter containing AppArmor "
                        "was found."
                    )
                    print(
                        f"Existing value: {existing_value}"
                    )
                    print(
                        "The existing LSM configuration will not be "
                        "overwritten."
                    )

                    new_lines.append(line)
                    continue

                print(
                    "An existing lsm= parameter was found:"
                )
                print(
                    f"    {existing_value}"
                )
                print(
                    "It will not be overwritten automatically."
                )
                print(
                    "Review the existing LSM configuration manually."
                )

                new_lines.append(line)
                continue

            new_lines.append(
                f"{line} {APPARMOR_LSM}"
            )

            changed = True
            continue

        new_lines.append(line)

    if not changed:
        print(
            "No 'cmdline:' entry was found in "
            f"{LIMINE_CONF}."
        )
        print()
        print(
            "Add the following parameter manually to the "
            "appropriate Limine cmdline:"
        )
        print()
        print(f"    {APPARMOR_LSM}")
        print()

        return True

    trailing_newline = "\n" if content.endswith("\n") else ""

    LIMINE_CONF.write_text(
        "\n".join(new_lines) + trailing_newline
    )

    print(f"Updated {LIMINE_CONF}.")
    print(f"Added: {APPARMOR_LSM}")

    return True


def configure_parser_cache():
    print()
    print("Configuring AppArmor profile cache...")
    print()

    PARSER_CONF.parent.mkdir(
        parents=True,
        exist_ok=True,
    )

    APPARMOR_CACHE_DIR.mkdir(
        parents=True,
        exist_ok=True,
    )

    if PARSER_CONF.exists():
        backup_file(PARSER_CONF)
        content = PARSER_CONF.read_text()
    else:
        content = ""

    lines = content.splitlines()

    required_settings = {
        "write-cache": "write-cache",
        "Optimize": "Optimize=compress-fast",
        "cache-loc": "cache-loc /etc/apparmor/earlypolicy/",
    }

    found = {
        "write-cache": False,
        "Optimize": False,
        "cache-loc": False,
    }

    new_lines = []

    for line in lines:
        stripped = line.strip()

        if stripped == "write-cache":
            if not found["write-cache"]:
                new_lines.append(
                    required_settings["write-cache"]
                )
                found["write-cache"] = True
            else:
                continue

        elif re.match(r"^Optimize\s*=", stripped):
            if not found["Optimize"]:
                new_lines.append(
                    required_settings["Optimize"]
                )
                found["Optimize"] = True
            else:
                continue

        elif re.match(r"^cache-loc\s*=?", stripped):
            if not found["cache-loc"]:
                new_lines.append(
                    required_settings["cache-loc"]
                )
                found["cache-loc"] = True
            else:
                continue

        else:
            new_lines.append(line)

    if not found["write-cache"]:
        new_lines.append(
            required_settings["write-cache"]
        )

    if not found["Optimize"]:
        new_lines.append(
            required_settings["Optimize"]
        )

    if not found["cache-loc"]:
        new_lines.append(
            required_settings["cache-loc"]
        )

    new_content = "\n".join(new_lines).rstrip() + "\n"

    PARSER_CONF.write_text(new_content)

    print(f"Configured {PARSER_CONF}.")
    print()
    print("Active AppArmor cache configuration:")
    print()
    print("write-cache")
    print("Optimize=compress-fast")
    print("cache-loc /etc/apparmor/earlypolicy/")
    print()
    print(
        f"Cache directory: {APPARMOR_CACHE_DIR}"
    )


def enable_apparmor_service():
    print()
    print("Enabling AppArmor service...")

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
    print()
    print("Checking AppArmor kernel support...")

    result = run(["aa-enabled"])

    if result == 0:
        print("AppArmor is enabled.")
    else:
        print(
            "Warning: aa-enabled reports that AppArmor "
            "is not currently enabled."
        )
        print(
            "A reboot may be required for the new kernel "
            "parameter to take effect."
        )


def show_status():
    print()
    print("Current AppArmor status:")
    print()

    run(["aa-status"])


def show_kernel_cmdline():
    print()
    print("Current kernel command line:")
    print()

    current_cmdline = read_cmdline()

    if current_cmdline:
        print(current_cmdline)
    else:
        print("Unable to read /proc/cmdline.")

    print()

    if APPARMOR_LSM_VALUE in current_cmdline:
        print(
            "The configured AppArmor LSM parameter is active "
            "in the running kernel."
        )
    elif "lsm=" in current_cmdline:
        print(
            "An lsm= parameter is active, but it does not exactly "
            "match the CachyOS AppArmor configuration."
        )
    else:
        print(
            "No lsm= parameter is active in the running kernel."
        )


def main():
    if os.geteuid() != 0:
        print(
            "This script must be run as root.",
            file=sys.stderr,
        )
        sys.exit(1)

    print("Configuring AppArmor for CachyOS...")
    print()

    configure_limine()

    configure_parser_cache()

    enable_apparmor_service()

    check_apparmor_enabled()

    show_kernel_cmdline()

    show_status()

    print()
    print("=" * 70)
    print("CachyOS AppArmor configuration completed.")
    print("=" * 70)
    print()
    print(
        "A reboot is required if the lsm= kernel parameter "
        "was newly added to limine.conf."
    )
    print()
    print(
        "After reboot, verify AppArmor with:"
    )
    print()
    print("    aa-status")
    print()
    print(
        "and:"
    )
    print()
    print("    systemctl status apparmor")
    print()


if __name__ == "__main__":
    main()
