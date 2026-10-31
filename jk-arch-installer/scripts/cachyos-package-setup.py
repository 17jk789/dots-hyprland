#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""CachyOS Package Setup for existing Arch-based systems.

This program is intentionally designed as a security-conscious launcher
for CachyOS' official repository setup.

CPU detection, repository selection, keyring/mirrorlist installation,
and the system upgrade are handled by CachyOS' upstream script itself.

File: cachyos-package-setup.py
Usage: python3 cachyos-package-setup.py
Check without making changes: python3 cachyos-package-setup.py --check

Note: No software can guarantee 100% safety or stability when modifying
package managers or repositories. Therefore, interactive confirmation
is required before making changes, and /etc/pacman.conf is additionally
backed up with a timestamp.
"""

from __future__ import annotations

import argparse
import os
import platform
import re
import shlex
import shutil
import subprocess
import sys
import tarfile
import tempfile
import urllib.request
from datetime import datetime
from pathlib import Path, PurePosixPath
from typing import Dict, List, Optional, Sequence


DOWNLOAD_URL = "https://mirror.cachyos.org/cachyos-repo.tar.xz"
PACMAN_CONF = Path("/etc/pacman.conf")
PACMAN_BACKUP_BY_UPSTREAM = Path("/etc/pacman.conf.bak")
PACMAN_LOCK = Path("/var/lib/pacman/db.lck")
MAX_ARCHIVE_BYTES = 32 * 1024 * 1024
MAX_ARCHIVE_MEMBERS = 256
MAX_EXTRACTED_BYTES = 32 * 1024 * 1024
USER_AGENT = "cachyos-package-setup/1.0"

REQUIRED_FILES = {
    "cachyos-repo.sh",
    "install-repo.awk",
    "install-v4-repo.awk",
    "install-znver4-repo.awk",
    "remove-repo.awk",
}


class SetupError(RuntimeError):
    """Expected setup error that can be displayed clearly."""


def info(message: str) -> None:
    print(f"[INFO] {message}")


def ok(message: str) -> None:
    print(f"[ OK ] {message}")


def warn(message: str) -> None:
    print(f"[WARN] {message}", file=sys.stderr)


def fail(message: str) -> None:
    raise SetupError(message)


def run(
    command: Sequence[str],
    *,
    check: bool = True,
    cwd: Optional[Path] = None
) -> subprocess.CompletedProcess:
    """Execute a command without shell interpretation."""
    try:
        result = subprocess.run(
            list(command),
            cwd=str(cwd) if cwd else None,
            check=False,
            text=True,
        )
    except FileNotFoundError as exc:
        raise SetupError(
            f"Required program not found: {command[0]}"
        ) from exc

    if check and result.returncode != 0:
        raise SetupError(
            f"Command failed (exit code {result.returncode}): "
            f"{' '.join(command)}"
        )

    return result


def read_os_release() -> Dict[str, str]:
    path = Path("/etc/os-release")

    if not path.is_file():
        fail(
            "/etc/os-release is missing; "
            "the distribution cannot be safely identified."
        )

    values: Dict[str, str] = {}

    for raw_line in path.read_text(encoding="utf-8").splitlines():
        line = raw_line.strip()

        if not line or line.startswith("#") or "=" not in line:
            continue

        key, raw_value = line.split("=", 1)

        if key in {"ID", "ID_LIKE", "PRETTY_NAME"}:
            try:
                parsed = shlex.split(raw_value, posix=True)
                values[key] = parsed[0] if parsed else ""
            except ValueError:
                fail(f"Invalid entry in /etc/os-release: {key}")

    return values


def get_privilege_prefix() -> List[str]:
    if os.geteuid() == 0:
        return []

    sudo = shutil.which("sudo")

    if not sudo:
        fail(
            "Root privileges are required. "
            "Install sudo or run the script as root."
        )

    return [sudo]


def preflight() -> List[str]:
    info("Checking system requirements ...")

    if platform.machine().lower() != "x86_64":
        fail(
            "According to the instructions, this CachyOS "
            "repository setup is intended for x86_64 systems."
        )

    os_info = read_os_release()

    distro_id = os_info.get("ID", "").lower()
    id_like = os_info.get("ID_LIKE", "").lower().split()

    known_arch_ids = {
        "arch",
        "cachyos",
        "endeavouros",
        "garuda",
        "arcolinux",
        "manjaro",
    }

    if distro_id not in known_arch_ids and "arch" not in id_like:
        fail(
            "No supported Arch-based distribution detected. "
            f"Detected: {os_info.get('PRETTY_NAME', distro_id or 'unknown')}"
        )

    if not shutil.which("pacman"):
        fail("pacman was not found.")

    if not shutil.which("bash"):
        fail("bash was not found.")

    if not PACMAN_CONF.is_file():
        fail("/etc/pacman.conf was not found.")

    if PACMAN_LOCK.exists():
        fail(
            f"Pacman lock detected: {PACMAN_LOCK}. "
            "Close all other package managers first. "
            "Do not blindly delete the lock file."
        )

    # The official CachyOS implementation uses exactly this backup path.
    # An existing backup must not accidentally be overwritten.
    if PACMAN_BACKUP_BY_UPSTREAM.exists():
        fail(
            f"{PACMAN_BACKUP_BY_UPSTREAM} already exists. "
            "Manually back up and inspect this file before "
            "running the setup again."
        )

    current_conf = PACMAN_CONF.read_text(
        encoding="utf-8",
        errors="replace"
    )

    active_cachyos_repos = re.findall(
        r"(?m)^\s*\[(cachyos(?:-[A-Za-z0-9_-]+)?)\]\s*(?:#.*)?$",
        current_conf,
    )

    if active_cachyos_repos:
        fail(
            "Active CachyOS repositories already exist in "
            "/etc/pacman.conf: "
            + ", ".join(sorted(set(active_cachyos_repos)))
            + ". For safety, another setup run will not be started."
        )

    prefix = get_privilege_prefix()

    if prefix:
        info(
            "Checking sudo permissions "
            "(enter your password if requested) ..."
        )
        run(prefix + ["-v"])

    ok(f"Distribution detected: {os_info.get('PRETTY_NAME', distro_id)}")
    ok("Architecture: x86_64")
    ok("Pacman configuration and database lock checked")

    return prefix


def download_archive(destination: Path) -> None:
    info("Downloading the official CachyOS archive via HTTPS ...")

    request = urllib.request.Request(
        DOWNLOAD_URL,
        headers={"User-Agent": USER_AGENT},
    )

    try:
        with urllib.request.urlopen(request, timeout=45) as response:
            final_url = response.geturl()

            if not final_url.lower().startswith("https://"):
                fail(
                    "The download was redirected "
                    "to a non-HTTPS address."
                )

            content_length = response.headers.get("Content-Length")

            if content_length and int(content_length) > MAX_ARCHIVE_BYTES:
                fail("The download archive is unexpectedly large; aborting.")

            total = 0

            with destination.open("xb") as output:
                while True:
                    chunk = response.read(1024 * 128)

                    if not chunk:
                        break

                    total += len(chunk)

                    if total > MAX_ARCHIVE_BYTES:
                        fail(
                            "The download archive exceeds "
                            "the size limit; aborting."
                        )

                    output.write(chunk)

    except SetupError:
        raise

    except Exception as exc:
        raise SetupError(f"Download failed: {exc}") from exc

    if total == 0:
        fail("The downloaded archive is empty.")

    ok(f"Download completed ({total:,} bytes).")

    warn(
        "CachyOS does not publish a fixed SHA-256 checksum "
        "for this archive in the linked installation instructions. "
        "HTTPS protects the transport but does not replace "
        "independent signature verification."
    )


def safe_extract(archive_path: Path, destination: Path) -> Path:
    """Extract only regular files and directories; reject links and special files."""

    destination.mkdir(
        mode=0o700,
        parents=True,
        exist_ok=True
    )

    root = destination.resolve()

    try:
        with tarfile.open(archive_path, mode="r:xz") as archive:
            members = archive.getmembers()

            if not members or len(members) > MAX_ARCHIVE_MEMBERS:
                fail(
                    "The archive contains no entries "
                    "or too many entries."
                )

            total_size = 0
            planned = []

            for member in members:
                rel = PurePosixPath(member.name)

                if rel.is_absolute() or ".." in rel.parts or not rel.parts:
                    fail(f"Unsafe archive path detected: {member.name!r}")

                if not (member.isdir() or member.isfile()):
                    fail(f"Disallowed archive file type: {member.name!r}")

                if member.mode & (0o4000 | 0o2000):
                    fail(
                        f"Setuid/setgid file rejected in archive: "
                        f"{member.name!r}"
                    )

                total_size += member.size

                if total_size > MAX_EXTRACTED_BYTES:
                    fail(
                        "The extracted archive exceeds "
                        "the size limit."
                    )

                target = destination.joinpath(*rel.parts)

                try:
                    target.resolve().relative_to(root)
                except ValueError:
                    fail(
                        f"Archive path escapes the destination directory: "
                        f"{member.name!r}"
                    )

                planned.append((member, target))

            for member, target in planned:
                if member.isdir():
                    target.mkdir(
                        mode=0o755,
                        parents=True,
                        exist_ok=True
                    )
                    continue

                target.parent.mkdir(
                    mode=0o755,
                    parents=True,
                    exist_ok=True
                )

                # O_NOFOLLOW + O_EXCL prevents symlink following and overwriting.
                flags = os.O_WRONLY | os.O_CREAT | os.O_EXCL
                flags |= getattr(os, "O_NOFOLLOW", 0)

                fd = os.open(target, flags, 0o600)

                try:
                    source = archive.extractfile(member)

                    if source is None:
                        fail(
                            f"Could not read archive file: {member.name}"
                        )

                    with source, os.fdopen(fd, "wb") as output:
                        shutil.copyfileobj(
                            source,
                            output,
                            length=1024 * 128
                        )

                    fd = -1

                finally:
                    if fd >= 0:
                        os.close(fd)

                target.chmod(
                    0o755 if member.mode & 0o111 else 0o644
                )

    except SetupError:
        raise

    except Exception as exc:
        raise SetupError(
            f"Archive validation/extraction failed: {exc}"
        ) from exc

    scripts = list(destination.rglob("cachyos-repo.sh"))

    if len(scripts) != 1:
        fail(
            "The archive does not contain exactly one cachyos-repo.sh."
        )

    installer = scripts[0]

    available = {
        p.name
        for p in installer.parent.iterdir()
        if p.is_file()
    }

    missing = REQUIRED_FILES - available

    if missing:
        fail(
            "Official setup files are missing: "
            + ", ".join(sorted(missing))
        )

    # Check syntax without executing the installation script.
    syntax = run(
        ["bash", "-n", str(installer)],
        check=False
    )

    if syntax.returncode != 0:
        fail(
            "bash -n reported syntax errors "
            "in the downloaded CachyOS script."
        )

    ok("Archive paths, file types, and shell syntax verified.")

    return installer


def create_timestamped_backup(
    privilege_prefix: List[str]
) -> Path:

    timestamp = datetime.now().astimezone().strftime(
        "%Y%m%d-%H%M%S"
    )

    backup = Path(
        f"/etc/pacman.conf.cachyos-package-setup.{timestamp}.bak"
    )

    if backup.exists():
        fail(f"Backup destination already exists: {backup}")

    run(
        privilege_prefix
        + ["cp", "-a", str(PACMAN_CONF), str(backup)]
    )

    if not backup.is_file() or backup.stat().st_size == 0:
        fail(
            "The additional pacman.conf backup "
            "could not be verified."
        )

    ok(f"Additional backup created: {backup}")

    return backup


def ask_for_consent() -> bool:
    print("\nThe official CachyOS setup is about to start.")

    print("It may perform the following operations:")
    print("  • Install the Pacman keyring and CachyOS mirrorlists")
    print("  • Install the customized CachyOS Pacman package")
    print("  • Add appropriate CachyOS repositories based on CPU capabilities")
    print("  • Perform a complete system upgrade (pacman -Syu)")

    print(
        "\nCPU detection and repository selection "
        "are handled by CachyOS itself."
    )

    if not sys.stdin.isatty():
        fail(
            "Interactive confirmation is required; "
            "no terminal detected."
        )

    answer = input(
        "\nEnter CACHYOS exactly to continue: "
    ).strip()

    return answer == "CACHYOS"


def verify_result() -> None:
    try:
        text = PACMAN_CONF.read_text(
            encoding="utf-8",
            errors="replace"
        )

    except OSError as exc:
        fail(
            f"Pacman configuration cannot be read "
            f"after setup: {exc}"
        )

    repos = re.findall(
        r"(?m)^\s*\[(cachyos(?:-[A-Za-z0-9_-]+)?)\]\s*(?:#.*)?$",
        text,
    )

    if "cachyos" not in repos or not any(
        name in repos
        for name in (
            "cachyos-v3",
            "cachyos-v4",
            "cachyos-znver4",
        )
    ):
        fail(
            "The official setup finished, but the expected active "
            "CachyOS repository entries could not be confirmed. "
            "Please inspect /etc/pacman.conf and the setup output."
        )

    ok(
        "CachyOS base repository and "
        "a CPU-optimized repository found."
    )


def main() -> int:
    parser = argparse.ArgumentParser(
        description=(
            "Security-conscious launcher for the official "
            "CachyOS repository setup."
        )
    )

    parser.add_argument(
        "--check",
        action="store_true",
        help=(
            "Only check system requirements; "
            "do not make any changes."
        ),
    )

    args = parser.parse_args()

    print("=" * 66)
    print("              CACHYOS PACKAGE SETUP")
    print("       Official CachyOS Repository Setup for Arch")
    print("=" * 66)

    privilege_prefix = preflight()

    if args.check:
        ok(
            "Preliminary checks passed. "
            "No changes were made."
        )
        return 0

    if not ask_for_consent():
        warn(
            "Not confirmed. "
            "No installation steps were started."
        )
        return 0

    # Create an independent backup before executing the upstream script.
    backup = create_timestamped_backup(privilege_prefix)

    with tempfile.TemporaryDirectory(
        prefix="cachyos-package-setup-"
    ) as tmp:

        temp_dir = Path(tmp)

        archive = temp_dir / "cachyos-repo.tar.xz"
        extract_dir = temp_dir / "extracted"

        download_archive(archive)

        installer = safe_extract(
            archive,
            extract_dir
        )

        print(
            "\nThe official CachyOS script "
            "will now be executed."
        )

        command = privilege_prefix + [str(installer)]

        result = run(
            command,
            check=False,
            cwd=installer.parent
        )

        if result.returncode != 0:
            fail(
                f"CachyOS setup failed "
                f"(exit code {result.returncode}). "
                f"Your additional backup is located at {backup}. "
                "Do not blindly restore it: first inspect "
                "the Pacman output and package status."
            )

    verify_result()

    ok(
        "The official CachyOS setup "
        "completed successfully."
    )

    print(f"Backup: {backup}")
    print("A reboot was not performed automatically.")

    return 0


if __name__ == "__main__":
    try:
        sys.exit(main())

    except SetupError as exc:
        print(
            f"\n[ERROR] {exc}",
            file=sys.stderr
        )
        sys.exit(1)

    except KeyboardInterrupt:
        print(
            "\n[ABORTED] Interrupted by the user.",
            file=sys.stderr
        )
        sys.exit(130)
