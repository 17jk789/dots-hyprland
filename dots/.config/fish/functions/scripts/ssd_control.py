#!/usr/bin/env python3
"""
SSD-/Datenträger-Steuerung für Arch-basierte Systeme.

Modi:
  OFF          Beide verwalteten Datenträger aushängen
  READ         Beide Datenträger read-only einhängen
  READ_ONLY    Alias für READ
  WRITE        Beide Datenträger read-write einhängen
  EXTERNAL_OFF Nur MAIN_DATA einhängen; EXTERNAL_DATA bleibt aus
  BLOCK        Nur ein flüchtiges tmpfs im RAM verwenden
  WRITE_ONLY   Absichtlich nicht unterstützt; schaltet sicher auf OFF

WICHTIG:
- Nur die hier eingetragenen Datenpartitionen werden verwaltet.
- Niemals die Root-/Systempartition als main oder external eintragen.
- Die Mount-Verzeichnisse müssen exklusiv diesem Skript gehören.
- OFF/READ/BLOCK setzen zusätzlich den Kernel-Schreibschutz der Partitionen.
- Das sperrt KEINE Lesezugriffe und schützt nicht gegen Zugriffe auf das
  übergeordnete ganze Laufwerk (z. B. /dev/sdX).
"""

from __future__ import annotations

import argparse
import os
import stat
import subprocess
import sys

from pathlib import Path
from typing import Optional


# ---------------------------------------------------------------------------
# KONFIGURATION – UUIDs anpassen
# ---------------------------------------------------------------------------

BASE_MOUNTPOINT = Path("/mnt/ssd-control")

DEVICES = {
    "main": {
        "device": "/dev/disk/by-uuid/UUID-DER-INTERNEN-DATENPARTITION",
        "mountpoint": BASE_MOUNTPOINT / "main",
    },

    "external": {
        "device": "/dev/disk/by-uuid/UUID-DER-EXTERNEN-DATENPARTITION",
        "mountpoint": BASE_MOUNTPOINT / "external",
    },
}


# Maximale Größe des temporären RAM-Dateisystems.
RAM_SIZE = "8G"

# Besitzer des RAM-Verzeichnisses.
# UID und GID mit id -u BENUTZER und id -g BENUTZER ermitteln.
# mode=0700 bedeutet: Nur dieser Benutzer darf darauf zugreifen.

RAM_UID = 1000
RAM_GID = 1000

# Eindeutige Quelle für unser tmpfs.
RAM_SOURCE = "ssd-control-ram"

# Sicherheitsoptionen für alle Mounts.
SECURE_MOUNT_FLAGS = "nosuid,nodev,noexec"


# ---------------------------------------------------------------------------
# HILFSFUNKTIONEN
# ---------------------------------------------------------------------------

def run(
    *args: str,
    check: bool = True,
    capture: bool = False
) -> subprocess.CompletedProcess:
    """Führt einen Befehl ohne Shell aus."""

    return subprocess.run(
        [str(arg) for arg in args],
        check=check,
        text=True,
        stdout=subprocess.PIPE if capture else None,
        stderr=subprocess.PIPE if capture else None,
    )


def is_mountpoint(path: Path) -> bool:
    """Prüft, ob ein Pfad ein eigener Mountpoint ist."""

    return run(
        "mountpoint",
        "-q",
        str(path),
        check=False
    ).returncode == 0


def mount_info(path: Path) -> Optional[tuple[str, str]]:
    """Liefert Dateisystemtyp und Quelle eines Mountpoints."""

    if not is_mountpoint(path):
        return None

    result = run(
        "findmnt",
        "-rn",
        "-o",
        "FSTYPE,SOURCE",
        "--target",
        str(path),
        check=False,
        capture=True,
    )

    if result.returncode != 0 or not result.stdout.strip():
        raise RuntimeError(
            f"Mount-Informationen für {path} konnten nicht gelesen werden."
        )

    fields = result.stdout.strip().split(maxsplit=1)

    if len(fields) != 2:
        raise RuntimeError(
            f"Unerwartete Mount-Information für {path}: "
            f"{result.stdout.strip()}"
        )

    return fields[0], fields[1]


def resolve_block_device(
    device: str,
    required: bool = True
) -> Optional[Path]:
    """Löst eine UUID-Verknüpfung auf und prüft das Blockgerät."""

    path = Path(device)

    if not path.exists():

        if required:
            raise FileNotFoundError(
                f"Gerät fehlt: {device}. "
                "UUID in der Konfiguration kontrollieren."
            )

        return None

    resolved = path.resolve(strict=True)

    mode = resolved.stat().st_mode

    if not stat.S_ISBLK(mode):
        raise RuntimeError(
            f"{device} zeigt nicht auf ein Blockgerät: {resolved}"
        )

    return resolved


def ensure_safe_directory(path: Path) -> None:
    """Erzeugt einen sicheren root-eigenen Mount-Ordner."""

    path.mkdir(
        parents=True,
        exist_ok=True,
        mode=0o755
    )

    if path.is_symlink():
        raise RuntimeError(
            f"Mount-Verzeichnis darf kein Symlink sein: {path}"
        )

    st = path.lstat()

    if not stat.S_ISDIR(st.st_mode):
        raise RuntimeError(
            f"Mount-Pfad ist kein Verzeichnis: {path}"
        )

    if st.st_uid != 0 or (st.st_mode & 0o022):
        raise RuntimeError(
            f"Unsichere Rechte für {path}: "
            "Verzeichnis muss root gehören und darf "
            "nicht gruppen-/weltbeschreibbar sein."
        )


def validate_configuration() -> None:
    """Prüft Geräte und Mountpunkte."""

    if "main" not in DEVICES or "external" not in DEVICES:
        raise RuntimeError(
            "DEVICES muss mindestens main und external enthalten."
        )

    base = BASE_MOUNTPOINT.resolve()

    mountpoints: set[Path] = set()
    device_ids: set[int] = set()

    for name, config in DEVICES.items():

        mountpoint = config["mountpoint"].resolve()

        if mountpoint == base or base not in mountpoint.parents:
            raise RuntimeError(
                f"Mountpoint {name} muss innerhalb von "
                f"{BASE_MOUNTPOINT} liegen."
            )

        if mountpoint in mountpoints:
            raise RuntimeError(
                f"Doppelt verwendeter Mountpoint: {mountpoint}"
            )

        mountpoints.add(mountpoint)

        device = resolve_block_device(
            config["device"],
            required=False
        )

        if device is not None:

            device_id = device.stat().st_rdev

            if device_id in device_ids:
                raise RuntimeError(
                    f"Ein Blockgerät ist mehrfach eingetragen: {device}"
                )

            device_ids.add(device_id)


def mounts_for_device(device: Path) -> list[str]:
    """Liefert bekannte Mountpoints eines Blockgeräts."""

    result = run(
        "findmnt",
        "-rn",
        "-S",
        str(device),
        "-o",
        "TARGET",
        check=False,
        capture=True,
    )

    if result.returncode != 0:
        return []

    return [
        line.strip()
        for line in result.stdout.splitlines()
        if line.strip()
    ]


def same_device(source: str, device: Path) -> bool:
    """Vergleicht eine Mount-Quelle mit dem konfigurierten Gerät."""

    source_path = source.split("[", maxsplit=1)[0]

    try:
        return Path(source_path).resolve(strict=True) == device

    except (OSError, RuntimeError):
        return False


def ensure_devices_not_mounted_elsewhere() -> None:
    """Verhindert fremde parallele Mounts."""

    for name, config in DEVICES.items():

        device = resolve_block_device(
            config["device"],
            required=False
        )

        if device is None:
            continue

        targets = mounts_for_device(device)

        allowed = str(config["mountpoint"])

        unexpected = [
            target
            for target in targets
            if target != allowed
        ]

        if unexpected:
            raise RuntimeError(
                f"{name}: Gerät {device} ist bereits "
                "an einem anderen Ort eingehängt: "
                + ", ".join(unexpected)
            )


def unmount_managed_devices() -> None:
    """Hängt ausschließlich verwaltete Mounts aus."""

    resolved_devices = {
        name: resolve_block_device(
            config["device"],
            required=False
        )
        for name, config in DEVICES.items()
    }

    # Erst alle Geräte prüfen.

    for name, config in DEVICES.items():

        device = resolved_devices[name]

        if device is None:
            continue

        targets = mounts_for_device(device)

        allowed = str(config["mountpoint"])

        unexpected = [
            target
            for target in targets
            if target != allowed
        ]

        if unexpected:
            raise RuntimeError(
                f"{name}: Gerät ist außerhalb des "
                "verwalteten Mountpunkts gemountet: "
                + ", ".join(unexpected)
            )

    # In umgekehrter Reihenfolge aushängen.

    for name in reversed(list(DEVICES.keys())):

        config = DEVICES[name]

        mountpoint = config["mountpoint"]

        if not is_mountpoint(mountpoint):
            continue

        device = resolved_devices[name]

        info = mount_info(mountpoint)

        if info is None:
            continue

        _fstype, source = info

        if device is None or not same_device(source, device):
            raise RuntimeError(
                f"{mountpoint} gehört nicht eindeutig "
                f"zum konfigurierten Datenträger {name}."
            )

        run(
            "umount",
            str(mountpoint)
        )

        print(f"{name}: ausgehängt.")


# ---------------------------------------------------------------------------
# RAM-MODUS
# ---------------------------------------------------------------------------

def is_our_ram_mount() -> bool:
    """Prüft, ob unser eigenes tmpfs aktiv ist."""

    info = mount_info(BASE_MOUNTPOINT)

    if info is None:
        return False

    fstype, source = info

    return (
        fstype == "tmpfs"
        and source == RAM_SOURCE
    )


def unmount_ram(discard_ram: bool) -> None:
    """Hängt das RAM-Dateisystem aus."""

    if not is_mountpoint(BASE_MOUNTPOINT):
        return

    if not is_our_ram_mount():
        raise RuntimeError(
            f"{BASE_MOUNTPOINT} ist fremd gemountet. "
            "Sicherheitsabbruch."
        )

    if not discard_ram:
        raise RuntimeError(
            "BLOCK-RAM ist noch aktiv. Beim Wechsel gehen "
            "dessen Daten verloren. Zum bewussten Verwerfen "
            "--discard-ram angeben."
        )

    run(
        "umount",
        str(BASE_MOUNTPOINT)
    )

    print(
        "RAM-Dateisystem ausgehängt; "
        "seine temporären Daten sind nicht mehr verfügbar."
    )


# ---------------------------------------------------------------------------
# KERNEL-SCHREIBSCHUTZ
# ---------------------------------------------------------------------------

def set_block_readonly(
    name: str,
    readonly: bool
) -> None:
    """Setzt den Kernel-Read-only-Status einer Partition."""

    device = resolve_block_device(
        DEVICES[name]["device"],
        required=False
    )

    if device is None:
        return

    flag = "--setro" if readonly else "--setrw"

    run(
        "blockdev",
        flag,
        str(device)
    )


def set_all_block_devices_readonly() -> None:
    """Aktiviert Schreibschutz für alle verwalteten Partitionen."""

    for name in DEVICES:
        set_block_readonly(name, True)


def teardown(discard_ram: bool) -> None:
    """Aushängen und danach Partitionen schreibschützen."""

    unmount_managed_devices()

    unmount_ram(
        discard_ram=discard_ram
    )

    set_all_block_devices_readonly()


# ---------------------------------------------------------------------------
# DATENTRÄGER EINHÄNGEN
# ---------------------------------------------------------------------------

def mount_device(
    name: str,
    mode: str
) -> None:
    """Mountet einen einzelnen konfigurierten Datenträger."""

    config = DEVICES[name]

    device = resolve_block_device(
        config["device"],
        required=True
    )

    mountpoint = config["mountpoint"]

    existing = mounts_for_device(device)

    if existing:
        raise RuntimeError(
            f"{name}: {device} ist bereits gemountet: "
            + ", ".join(existing)
        )

    ensure_safe_directory(BASE_MOUNTPOINT)
    ensure_safe_directory(mountpoint)

    # Kernel-Schreibschutz zusätzlich zum Mount-Flag.

    set_block_readonly(
        name,
        readonly=(mode == "ro")
    )

    if mode == "ro":

        options = f"ro,{SECURE_MOUNT_FLAGS}"

    elif mode == "rw":

        options = f"rw,{SECURE_MOUNT_FLAGS}"

    else:

        raise ValueError(
            f"Ungültiger Mount-Modus: {mode}"
        )

    run(
        "mount",
        "-o",
        options,
        str(device),
        str(mountpoint)
    )

    # Mount überprüfen.

    info = mount_info(mountpoint)

    if info is None:
        raise RuntimeError(
            f"{name}: Mount konnte nicht verifiziert werden."
        )

    options_result = run(
        "findmnt",
        "-rn",
        "-o",
        "OPTIONS",
        "--target",
        str(mountpoint),
        check=False,
        capture=True,
    )

    mounted_options = options_result.stdout.strip().split(",")

    expected = "ro" if mode == "ro" else "rw"

    if expected not in mounted_options:

        run(
            "umount",
            str(mountpoint),
            check=False
        )

        raise RuntimeError(
            f"{name}: gewünschter Modus "
            f"{expected} wurde nicht bestätigt."
        )

    print(
        f"{name}: {device} -> {mountpoint} ({expected})."
    )


def mount_selected(
    names: list[str],
    mode: str
) -> None:
    """Mountet mehrere Geräte und setzt bei Fehler zurück."""

    mounted: list[Path] = []

    try:

        for name in names:

            mount_device(name, mode)

            mounted.append(
                DEVICES[name]["mountpoint"]
            )

    except Exception:

        for mountpoint in reversed(mounted):

            run(
                "umount",
                str(mountpoint),
                check=False
            )

        set_all_block_devices_readonly()

        raise


def activate_block_mode(discard_ram: bool) -> None:
    """Aktiviert einen ausschließlich temporären RAM-Mount."""

    if is_our_ram_mount():

        print(
            f"BLOCK ist bereits aktiv: "
            f"{BASE_MOUNTPOINT} liegt im RAM."
        )

        return

    teardown(
        discard_ram=discard_ram
    )

    ensure_devices_not_mounted_elsewhere()

    set_all_block_devices_readonly()

    ensure_safe_directory(BASE_MOUNTPOINT)

    options = (
        f"size={RAM_SIZE},"
        f"noswap,"
        f"uid={RAM_UID},"
        f"gid={RAM_GID},"
        f"mode=0700,"
        f"{SECURE_MOUNT_FLAGS}"
    )

    run(
        "mount",
        "-t",
        "tmpfs",
        "-o",
        options,
        RAM_SOURCE,
        str(BASE_MOUNTPOINT)
    )

    # Verzeichnisse liegen nun im RAM.

    for config in DEVICES.values():

        config["mountpoint"].mkdir(
            parents=True,
            exist_ok=True
        )

    print(
        f"BLOCK aktiv: {BASE_MOUNTPOINT} ist tmpfs im RAM "
        f"(Limit {RAM_SIZE}, noswap). "
        "Physische Datenträger sind nicht gemountet."
    )


# ---------------------------------------------------------------------------
# MODI
# ---------------------------------------------------------------------------

def set_mode(
    mode: str,
    discard_ram: bool = False
) -> None:

    aliases = {
        "READ_ONLY": "READ",
        "READONLY": "READ",
        "EXTERNAL-OFF": "EXTERNAL_OFF",
        "MAIN_ONLY": "EXTERNAL_OFF",
    }

    mode = aliases.get(mode, mode)

    valid_modes = {
        "OFF",
        "READ",
        "WRITE",
        "EXTERNAL_OFF",
        "BLOCK",
        "WRITE_ONLY",
    }

    if mode not in valid_modes:
        raise ValueError(
            f"Unbekannter Modus: {mode}"
        )

    # -------------------------------------------------------
    # BLOCK
    # -------------------------------------------------------

    if mode == "BLOCK":

        activate_block_mode(discard_ram)

        return

    # -------------------------------------------------------
    # WRITE_ONLY
    # -------------------------------------------------------

    if mode == "WRITE_ONLY":

        teardown(
            discard_ram=discard_ram
        )

        raise RuntimeError(
            "WRITE_ONLY wird nicht angeboten. "
            "Ein normaler Mount kann Schreibzugriff erlauben, "
            "aber Lesezugriff nicht zuverlässig unterbinden. "
            "Die verwalteten Datenträger wurden auf OFF gesetzt. "
            "Für echten Upload-only-Zugriff ist ein separater "
            "Dienst bzw. ein isolierter Upload-Benutzer mit "
            "serverseitiger Zugriffskontrolle nötig."
        )

    # -------------------------------------------------------
    # ALLE ANDEREN MODI
    # -------------------------------------------------------

    teardown(
        discard_ram=discard_ram
    )

    # -------------------------------------------------------
    # OFF
    # -------------------------------------------------------

    if mode == "OFF":

        print(
            "OFF: Alle verwalteten Datenträger sind ausgehängt."
        )

        return

    # -------------------------------------------------------
    # READ
    # -------------------------------------------------------

    if mode == "READ":

        mount_selected(
            list(DEVICES.keys()),
            "ro"
        )

        print(
            "READ: Alle konfigurierten Datenträger "
            "sind nur lesbar."
        )

        return

    # -------------------------------------------------------
    # WRITE
    # -------------------------------------------------------

    if mode == "WRITE":

        mount_selected(
            list(DEVICES.keys()),
            "rw"
        )

        print(
            "WRITE: Alle konfigurierten Datenträger "
            "sind les- und beschreibbar."
        )

        return

    # -------------------------------------------------------
    # EXTERNAL_OFF
    # -------------------------------------------------------

    if mode == "EXTERNAL_OFF":

        # Nur der interne Daten-Datenträger bleibt verfügbar.
        # Das externe Laufwerk bleibt ausgehängt.

        mount_selected(
            ["main"],
            "rw"
        )

        print(
            "EXTERNAL_OFF: Interner Daten-Datenträger aktiv; "
            "externer Datenträger aus."
        )

        return


# ---------------------------------------------------------------------------
# HAUPTPROGRAMM
# ---------------------------------------------------------------------------

def main() -> int:

    parser = argparse.ArgumentParser(
        description=(
            "Mount-Steuerung für konfigurierte "
            "Datenpartitionen (Allowlist)."
        )
    )

    parser.add_argument(
        "mode",
        nargs="?",
        help=(
            "OFF | READ | READ_ONLY | WRITE | "
            "EXTERNAL_OFF | BLOCK | WRITE_ONLY"
        ),
    )

    parser.add_argument(
        "--discard-ram",
        action="store_true",
        help=(
            "Erlaubt beim Verlassen von BLOCK "
            "das Verwerfen temporärer RAM-Daten."
        ),
    )

    args = parser.parse_args()

    # Root-Rechte erforderlich.

    if os.geteuid() != 0:

        print(
            "Fehler: Bitte mit sudo/root ausführen.",
            file=sys.stderr
        )

        return 1

    if not args.mode:

        parser.print_help()

        return 2

    try:

        validate_configuration()

        set_mode(
            args.mode.upper().replace("-", "_"),
            discard_ram=args.discard_ram
        )

    except (
        subprocess.CalledProcessError,
        OSError,
        RuntimeError,
        ValueError
    ) as exc:

        print(
            f"FEHLER: {exc}",
            file=sys.stderr
        )

        return 1

    return 0


if __name__ == "__main__":

    raise SystemExit(main())
