#!/usr/bin/env python3

import os
import shutil
import subprocess
import sys


SELINUX_CONFIG = "/etc/selinux/config"


def run(command, check=False):
    print(f"[+] {' '.join(command)}")
    return subprocess.run(command, check=check)


def command_exists(command):
    return shutil.which(command) is not None


def require_root():
    if os.geteuid() != 0:
        print("[!] Dieses Skript muss als root ausgeführt werden.")
        sys.exit(1)


def check_selinux_tools():
    required = [
        "sestatus",
        "getenforce",
        "setenforce",
        "restorecon",
    ]

    missing = [
        command
        for command in required
        if not command_exists(command)
    ]

    if missing:
        print(
            "[!] Folgende SELinux-Werkzeuge fehlen: "
            + ", ".join(missing)
        )
        sys.exit(1)


def backup_config():
    if not os.path.exists(SELINUX_CONFIG):
        return

    backup = SELINUX_CONFIG + ".bak"

    if not os.path.exists(backup):
        shutil.copy2(
            SELINUX_CONFIG,
            backup
        )

        print(
            f"[+] Backup erstellt: {backup}"
        )
    else:
        print(
            f"[+] Backup existiert bereits: {backup}"
        )


def write_config():
    os.makedirs(
        os.path.dirname(SELINUX_CONFIG),
        exist_ok=True
    )

    backup_config()

    config = """# This file controls the state of SELinux on the system.
#
# SELINUX= can take one of these three values:
#   enforcing  - SELinux policy is enforced.
#   permissive - SELinux prints warnings instead of enforcing.
#   disabled   - No SELinux policy is loaded.
#
# SELinux is intentionally configured as permissive first.
# Switch to enforcing only after the system and policy have
# been tested.

SELINUX=permissive
SELINUXTYPE=refpolicy
"""

    with open(
        SELINUX_CONFIG,
        "w",
        encoding="utf-8"
    ) as file:
        file.write(config)

    print(
        f"[+] SELinux-Konfiguration geschrieben: "
        f"{SELINUX_CONFIG}"
    )


def read_kernel_cmdline():
    try:
        with open(
            "/proc/cmdline",
            "r",
            encoding="utf-8"
        ) as file:
            return file.read().strip()

    except OSError as error:
        print(
            f"[!] Konnte /proc/cmdline nicht lesen: {error}"
        )
        return ""


def check_kernel_cmdline():
    cmdline = read_kernel_cmdline()

    if not cmdline:
        return

    print("\n[+] Aktuelle Kernel-Parameter:")
    print(f"    {cmdline}")

    if "selinux=1" in cmdline:
        print(
            "[+] selinux=1 ist gesetzt."
        )
    else:
        print(
            "[!] selinux=1 ist aktuell NICHT gesetzt."
        )

    lsm_parameter = None

    for parameter in cmdline.split():
        if parameter.startswith("lsm="):
            lsm_parameter = parameter
            break

    if lsm_parameter is None:
        print(
            "[!] Kein lsm= Kernel-Parameter gefunden."
        )

        print(
            "[!] Für SELinux wird laut ArchWiki ein "
            "LSM-Stack wie folgender benötigt:"
        )

        print(
            "    lsm=landlock,lockdown,yama,integrity,selinux,bpf"
        )

        return

    print(
        f"[+] Gefundener LSM-Parameter: {lsm_parameter}"
    )

    lsm_value = lsm_parameter.split("=", 1)[1]
    lsm_modules = lsm_value.split(",")

    if "selinux" in lsm_modules:
        print(
            "[+] SELinux ist im aktuellen LSM-Stack enthalten."
        )

        selinux_index = lsm_modules.index("selinux")

        major_modules = [
            module
            for module in lsm_modules
            if module not in (
                "landlock",
                "lockdown",
                "yama",
                "integrity",
                "bpf",
            )
        ]

        if major_modules and major_modules[0] == "selinux":
            print(
                "[+] SELinux steht an der erwarteten Position "
                "im LSM-Stack."
            )
        else:
            print(
                "[!] SELinux ist im LSM-Stack vorhanden, "
                "aber die Reihenfolge sollte überprüft werden."
            )

    else:
        print(
            "[!] SELinux ist NICHT im aktuellen LSM-Stack enthalten."
        )

    print(
        "\n[!] Der Kernelparameter wird nicht automatisch geändert."
    )

    print(
        "[!] Setze ihn passend zu deinem Bootloader auf:"
    )

    print(
        "    lsm=landlock,lockdown,yama,integrity,selinux,bpf"
    )


def enable_restorecond():
    if not command_exists("systemctl"):
        print(
            "[!] systemctl wurde nicht gefunden."
        )
        return

    print(
        "\n[+] Aktiviere restorecond.service..."
    )

    result = run(
        [
            "systemctl",
            "enable",
            "--now",
            "restorecond.service"
        ],
        check=False
    )

    if result.returncode == 0:
        print(
            "[+] restorecond.service wurde aktiviert."
        )
    else:
        print(
            "[!] restorecond.service konnte nicht aktiviert "
            "werden."
        )


def set_permissive():
    print(
        "\n[+] Setze SELinux für die aktuelle Sitzung "
        "auf permissive..."
    )

    result = run(
        [
            "setenforce",
            "0"
        ],
        check=False
    )

    if result.returncode == 0:
        print(
            "[+] SELinux wurde auf permissive gesetzt."
        )
    else:
        print(
            "[!] Der aktuelle SELinux-Modus konnte nicht "
            "geändert werden."
        )


def show_status():
    print("\n[+] SELinux-Status:")

    run(
        [
            "sestatus"
        ],
        check=False
    )

    print("\n[+] SELinux-Modus:")

    run(
        [
            "getenforce"
        ],
        check=False
    )


def main():
    require_root()

    print(
        "[+] Konfiguriere SELinux für Arch Linux..."
    )

    check_selinux_tools()

    print(
        "\n[+] Schreibe /etc/selinux/config..."
    )

    write_config()

    print(
        "\n[+] Überprüfe Kernel-Parameter..."
    )

    check_kernel_cmdline()

    enable_restorecond()

    set_permissive()

    print(
        "\n[+] SELinux-Konfiguration abgeschlossen."
    )

    print(
        "[!] SELinux bleibt absichtlich im "
        "permissive-Modus."
    )

    print(
        "[!] Vor dem Wechsel auf enforcing müssen "
        "Kernelparameter, PAM, Policy und Dateikontexte "
        "überprüft werden."
    )

    print(
        "[!] Nach einem Neustart sollte bei einer neuen "
        "SELinux-Installation anschließend restorecon -r / "
        "ausgeführt werden."
    )

    show_status()


if __name__ == "__main__":
    main()
