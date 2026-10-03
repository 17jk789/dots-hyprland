#!/usr/bin/env python3
"""
Selektiver Diff zwischen den Dotfile-Profilen.

WICHTIG:
Dieses Script ersetzt NICHT deine komplette ~/.config oder ~/.local.

Es macht ausschließlich Folgendes:

1. erkennt die aktuell laufende Desktop-Umgebung,
2. lässt GNOME oder Hyprland als Ziel auswählen,
3. verwendet diese Profilbäume:

       GNOME:
           ~/dots-hyprland/dots-gnome/

       Hyprland:
           ~/dots-hyprland/dots/

4. betrachtet ausschließlich .config und .local,
5. ermittelt NUR Dateien, die im gewählten Zielprofil vorhanden
   und gegenüber der aktuell installierten Datei unterschiedlich sind,
6. zeigt VOR der Änderung exakt an, welche Dateien geändert werden,
7. mit "y" kann der vollständige Diff angesehen werden,
8. erst danach wird ausdrücklich bestätigt, ob die Änderungen
   angewendet werden sollen,
9. erstellt Backups NUR von Dateien, die tatsächlich überschrieben
   oder gezielt gelöscht werden,
10. schreibt NUR die bestätigten Unterschiede,
11. löscht normale Dateien NIEMALS,
12. beim GNOME-Ziel werden ausschließlich diese beiden
    Hyprland-Funktionen entfernt:

       .config/fish/functions/glasstoggle.fish
       .config/fish/functions/border-visible.fish

13. beim Hyprland-Ziel werden diese beiden Dateien aus dem
    Hyprland-Profil übernommen,
14. glasstoggle-full.fish wird NIEMALS berücksichtigt,
15. gnome-toggle.py wird NIEMALS automatisch verändert,
16. verändert KEINEN Bootloader,
17. führt KEINEN Reboot durch,
18. verwendet KEIN gsettings und verändert keine GNOME-Keybindings.

Das Script ist absichtlich KEIN vollständiger Profil-Switcher.
Es ist ein selektiver Datei-Merger mit zwei ausdrücklich erlaubten
Hyprland-Fish-Ausnahmen.
"""

from __future__ import annotations

import argparse
import difflib
import hashlib
import os
import shutil
import sys
import tempfile
from datetime import datetime
from pathlib import Path


# ===========================================================================
# Pfade
# ===========================================================================

SCRIPT = Path(__file__).resolve()

REPO_ROOT = Path.home() / "dots-hyprland"

# GNOME:
#   ~/dots-hyprland/dots-gnome
GNOME_ROOT = REPO_ROOT / "dots-gnome"

# Hyprland:
#   ~/dots-hyprland/dots
DOTS_ROOT = REPO_ROOT / "dots"


# ===========================================================================
# Spezielle Dateien
# ===========================================================================

# Diese beiden Dateien gehören ausschließlich zum Hyprland-Ziel.
HYPRLAND_ONLY_PATHS = (
    Path(".config/fish/functions/glasstoggle.fish"),
    Path(".config/fish/functions/border-visible.fish"),
)


# Diese Dateien dürfen niemals vom normalen Profilscan erfasst werden.
#
# glasstoggle-full.fish:
#     niemals anfassen.
#
# gnome-toggle.py:
#     Das Script selbst darf niemals durch einen Profil-Merge
#     überschrieben werden.
EXCLUDED_PATHS = {
    Path(".config/fish/functions/glasstoggle-full.fish"),
    Path(".config/fish/functions/gnome-toggle.py"),
}


# Nur diese beiden Dateien dürfen beim GNOME-Ziel
# gezielt gelöscht werden.
GNOME_REMOVE_PATHS = {
    Path(".config/fish/functions/glasstoggle.fish"),
    Path(".config/fish/functions/border-visible.fish"),
}


# ===========================================================================
# Backup-Verzeichnis
# ===========================================================================

BACKUP_ROOT = (
    Path(
        os.environ.get(
            "XDG_STATE_HOME",
            Path.home() / ".local" / "state",
        )
    ).expanduser()
    / "dots-hyprland"
    / "desktop-diff-backups"
)


# ===========================================================================
# Typ für geplante Aktionen
# ===========================================================================

# action:
#
#   "write"   -> Datei neu anlegen oder überschreiben
#   "delete"  -> Datei gezielt löschen
#
# relative:
#   relativer Pfad innerhalb des Dotfile-Profils
#
# source:
#   Quelldatei aus dem Profil, bei delete None
#
# destination:
#   aktuelle Datei im Home, bei nicht vorhandener Datei None
#
# Beispiel:
#
#   (
#       Path(".config/kitty/kitty.conf"),
#       source,
#       destination,
#       "write",
#   )
#
# oder:
#
#   (
#       Path(".config/fish/functions/glasstoggle.fish"),
#       None,
#       destination,
#       "delete",
#   )
#
Change = tuple[
    Path,
    Path | None,
    Path | None,
    str,
]


# ===========================================================================
# XDG / Home
# ===========================================================================


def live_file(relative: Path) -> Path:
    """
    Bildet einen Repository-Pfad auf die tatsächlich verwendete
    Datei im Home-Verzeichnis ab.

    .config -> XDG_CONFIG_HOME
    .local/share -> XDG_DATA_HOME
    .local/state -> XDG_STATE_HOME
    alles andere unter ~/.local
    """

    if not relative.parts:
        raise RuntimeError("Leerer relativer Pfad.")

    # ------------------------------------------------------------------
    # ~/.config
    # ------------------------------------------------------------------

    if relative.parts[0] == ".config":
        config_home = Path(
            os.environ.get(
                "XDG_CONFIG_HOME",
                Path.home() / ".config",
            )
        ).expanduser()

        return config_home / Path(*relative.parts[1:])

    # ------------------------------------------------------------------
    # ~/.local
    # ------------------------------------------------------------------

    if relative.parts[0] == ".local":
        remaining = relative.parts[1:]

        # ~/.local/share
        if remaining[:1] == ("share",):
            data_home = Path(
                os.environ.get(
                    "XDG_DATA_HOME",
                    Path.home() / ".local" / "share",
                )
            ).expanduser()

            return data_home / Path(*remaining[1:])

        # ~/.local/state
        if remaining[:1] == ("state",):
            state_home = Path(
                os.environ.get(
                    "XDG_STATE_HOME",
                    Path.home() / ".local" / "state",
                )
            ).expanduser()

            return state_home / Path(*remaining[1:])

        return Path.home() / ".local" / Path(*remaining)

    raise RuntimeError(f"Nicht unterstützter Profilpfad: {relative}")


# ===========================================================================
# Hash / Vergleich
# ===========================================================================


def digest(path: Path) -> str:
    """Berechnet den SHA256-Hash einer Datei."""

    hasher = hashlib.sha256()

    with path.open("rb") as stream:
        for chunk in iter(
            lambda: stream.read(1024 * 1024),
            b"",
        ):
            hasher.update(chunk)

    return hasher.hexdigest()


def files_equal(
    first: Path,
    second: Path,
) -> bool:
    """Prüft, ob zwei Dateien bytegenau identisch sind."""

    if not first.is_file() or not second.is_file():
        return False

    return digest(first) == digest(second)


# ===========================================================================
# Profilbäume
# ===========================================================================


def profile_root(profile: str) -> Path:
    """
    Liefert den korrekten Profilbaum.

    GNOME:
        ~/dots-hyprland/dots-gnome

    Hyprland:
        ~/dots-hyprland/dots
    """

    if profile == "gnome":
        return GNOME_ROOT

    if profile == "hyprland":
        return DOTS_ROOT

    raise RuntimeError(f"Unbekanntes Profil: {profile}")


def collect_files(
    root: Path,
    *,
    exclude: set[Path] | None = None,
) -> dict[Path, Path]:
    """
    Sammelt alle regulären Dateien aus .config und .local.

    Dateien aus 'exclude' werden vollständig ignoriert.
    """

    result: dict[Path, Path] = {}

    if exclude is None:
        exclude = set()

    if not root.is_dir():
        raise RuntimeError(f"Profilverzeichnis nicht gefunden: {root}")

    for top_level in (
        ".config",
        ".local",
    ):
        source_root = root / top_level

        if not source_root.is_dir():
            continue

        for path in source_root.rglob("*"):
            if not path.is_file():
                continue

            relative = path.relative_to(root)

            if relative in exclude:
                continue

            result[relative] = path

    return result


# ===========================================================================
# Diff-Ermittlung
# ===========================================================================


def find_changes(
    target: str,
) -> list[Change]:
    """
    Ermittelt alle geplanten Aktionen.

    Normale Dateien:
        Nur schreiben, wenn sie im Zielprofil existieren
        und sich vom aktuellen Home unterscheiden.

    GNOME:
        glasstoggle.fish und border-visible.fish werden gezielt
        entfernt, falls sie aktuell vorhanden sind.

    Hyprland:
        glasstoggle.fish und border-visible.fish werden aus dem
        Hyprland-Profil übernommen.

    Keine andere Datei wird aufgrund ihrer Abwesenheit gelöscht.
    """

    target_root = profile_root(target)

    target_files = collect_files(
        target_root,
        exclude=set(EXCLUDED_PATHS),
    )

    changes: list[Change] = []

    # ------------------------------------------------------------------
    # Normale Dateien aus dem Zielprofil
    # ------------------------------------------------------------------

    for relative in sorted(target_files):
        # Zusätzliche Sicherheitsprüfung.
        if relative in EXCLUDED_PATHS:
            continue

        source = target_files[relative]
        destination = live_file(relative)

        # --------------------------------------------------------------
        # Datei existiert im Zielprofil, aber noch nicht im Home.
        # --------------------------------------------------------------

        if not destination.exists():
            changes.append(
                (
                    relative,
                    source,
                    None,
                    "write",
                )
            )
            continue

        # --------------------------------------------------------------
        # Zielpfad ist kein regulärer File.
        #
        # Wir löschen/ersetzen hier NICHTS automatisch.
        # --------------------------------------------------------------

        if not destination.is_file():
            raise RuntimeError(f"Zielpfad ist keine reguläre Datei:\n  {destination}")

        # --------------------------------------------------------------
        # Identisch -> nichts tun.
        # --------------------------------------------------------------

        if files_equal(
            source,
            destination,
        ):
            continue

        # --------------------------------------------------------------
        # Unterschiedlich -> überschreiben.
        # --------------------------------------------------------------

        changes.append(
            (
                relative,
                source,
                destination,
                "write",
            )
        )

    # ------------------------------------------------------------------
    # HYPRLAND:
    #
    # Die beiden explizit gewünschten Fish-Funktionen.
    #
    # Diese sind zwar normalerweise bereits durch collect_files()
    # erfasst, werden hier trotzdem ausdrücklich behandelt, damit
    # die Sonderregel klar und unabhängig bleibt.
    # ------------------------------------------------------------------

    if target == "hyprland":
        for relative in HYPRLAND_ONLY_PATHS:
            # Sicherheitscheck.
            if relative in EXCLUDED_PATHS:
                continue

            source = target_root / relative

            if not source.is_file():
                print(
                    f"WARNING: requested Hyprland function was not found:\n  {source}",
                    file=sys.stderr,
                )
                continue

            destination = live_file(relative)

            # Bereits durch den normalen Scan enthalten?
            already_present = any(item[0] == relative for item in changes)

            if already_present:
                continue

            if not destination.exists():
                changes.append(
                    (
                        relative,
                        source,
                        None,
                        "write",
                    )
                )
                continue

            if not destination.is_file():
                raise RuntimeError(
                    f"Fish target path is not a regular file:\n  {destination}"
                )

            if not files_equal(
                source,
                destination,
            ):
                changes.append(
                    (
                        relative,
                        source,
                        destination,
                        "write",
                    )
                )

    # ------------------------------------------------------------------
    # GNOME:
    #
    # NUR diese beiden Hyprland-Funktionen dürfen entfernt werden.
    #
    # Alle anderen Dateien, die im GNOME-Profil fehlen, bleiben
    # vollständig unangetastet.
    # ------------------------------------------------------------------

    if target == "gnome":
        for relative in sorted(
            GNOME_REMOVE_PATHS,
            key=lambda path: path.as_posix(),
        ):
            destination = live_file(relative)

            # Nicht vorhanden -> nichts zu tun.
            if not destination.exists():
                continue

            # Wenn es ein Verzeichnis oder anderer Nicht-File ist,
            # wird NICHT gelöscht.
            if not destination.is_file():
                raise RuntimeError(
                    f"Hyprland file to remove is not a regular file:\n  {destination}"
                )

            # Löschen als explizite Aktion vormerken.
            changes.append(
                (
                    relative,
                    None,
                    destination,
                    "delete",
                )
            )

    return sorted(
        changes,
        key=lambda item: item[0].as_posix(),
    )


# ===========================================================================
# Ausgabe
# ===========================================================================


def print_header(
    title: str,
) -> None:
    """Gibt einen formatierten Abschnitt aus."""

    print()
    print("=" * 72)
    print(f"  {title}")
    print("=" * 72)


def print_changes(
    changes: list[Change],
    target: str,
) -> None:
    """Zeigt alle geplanten Änderungen an."""

    print_header(f"FOUND CHANGES → {target.upper()}")

    if not changes:
        print()
        print("  No differences found.")
        print("  Nothing will be changed.")
        print()
        return

    write_changes = [item for item in changes if item[3] == "write"]

    delete_changes = [item for item in changes if item[3] == "delete"]

    # ------------------------------------------------------------------
    # Schreiben
    # ------------------------------------------------------------------

    if write_changes:
        print()
        print(f"  {len(write_changes)} file(s) will be written:")
        print()

        for (
            relative,
            source,
            destination,
            action,
        ) in write_changes:
            if destination is None:
                status = "NEW"
            else:
                status = "CHANGE"

            print(f"  [{status:6}] {relative}")

    # ------------------------------------------------------------------
    # Löschen
    # ------------------------------------------------------------------

    if delete_changes:
        print()
        print(f"  {len(delete_changes)} file(s) will be explicitly deleted:")
        print()

        for (
            relative,
            source,
            destination,
            action,
        ) in delete_changes:
            print(f"  [DELETE] {relative}")

    # ------------------------------------------------------------------
    # Sicherheitshinweise
    # ------------------------------------------------------------------

    print()
    print("  IMPORTANT:")
    print("  Normal files will NOT be deleted,")
    print("  only the explicitly allowed Fish files")
    print("  may be removed for the GNOME target.")
    print("  Files that only exist in your current")
    print("  configuration remain untouched.")
    print("  glasstoggle-full.fish will never be modified.")
    print("  gnome-toggle.py will never be modified")
    print("  by the profile merge.")


# ===========================================================================
# Text-Diff
# ===========================================================================


def read_text_lines(
    path: Path | None,
) -> list[str]:
    """Liest eine Textdatei sicher für den Diff ein."""

    if path is None or not path.is_file():
        return []

    try:
        return path.read_text(
            encoding="utf-8",
            errors="replace",
        ).splitlines(keepends=True)

    except OSError:
        return []


def print_single_diff(
    relative: Path,
    source: Path | None,
    destination: Path | None,
    action: str,
) -> None:
    """Gibt den Diff einer einzelnen Datei aus."""

    old_lines = read_text_lines(destination)

    new_lines = read_text_lines(source)

    # ---------------------------------------------------------------
    # Header abhängig von der Aktion.
    # ---------------------------------------------------------------

    if action == "delete":
        from_file = str(destination) if destination is not None else str(relative)

        to_file = "/dev/null"

    else:
        from_file = str(destination) if destination is not None else "/dev/null"

        to_file = str(source) if source is not None else str(relative)

    try:
        diff = difflib.unified_diff(
            old_lines,
            new_lines,
            fromfile=from_file,
            tofile=to_file,
            lineterm="",
        )

        output = "\n".join(diff)

    except Exception:
        output = ""

    print()
    print("-" * 72)
    print(f"FILE: {relative}")
    print("-" * 72)

    if output:
        print(output)
    else:
        print("No text diff available (possibly a binary file).")

    print()


def show_full_diff(
    changes: list[Change],
) -> None:
    """Zeigt den vollständigen Diff aller geplanten Aktionen an."""

    print_header("FULL DIFF")

    for (
        relative,
        source,
        destination,
        action,
    ) in changes:
        print_single_diff(
            relative,
            source,
            destination,
            action,
        )

    print_header("END OF DIFF")


# ===========================================================================
# Interaktive Bestätigung
# ===========================================================================


def ask_before_apply(
    changes: list[Change],
) -> bool:
    """
    Bietet den Diff an und verlangt danach IMMER eine
    ausdrückliche Bestätigung zum Anwenden.

    Enter beim ersten Prompt:
        Diff überspringen.

    Enter beim zweiten Prompt:
        NICHT anwenden.
    """

    if not changes:
        return False

    # ------------------------------------------------------------------
    # Schritt 1: Optionalen vollständigen Diff anzeigen.
    # ------------------------------------------------------------------

    print()
    print("Before applying the changes, you can review the exact diff.")
    print()
    print("  [y] Show full diff")
    print("  [Enter] Continue without diff")
    print("  [n] Abort")
    print()

    while True:
        try:
            answer = input("Selection [y/Enter/n]: ").strip().lower()

        except EOFError:
            return False

        if answer in (
            "n",
            "no",
            "nein",
            "q",
            "quit",
            "exit",
        ):
            print()
            print("Aborted. No changes were made.")
            return False

        if answer in (
            "y",
            "yes",
            "j",
            "ja",
        ):
            show_full_diff(changes)
            break

        if answer == "":
            break

        print("Please enter y, Enter, or n.")

    # ------------------------------------------------------------------
    # Schritt 2: Immer explizit bestätigen.
    # ------------------------------------------------------------------

    print()
    print("The files listed above are the ONLY")
    print("files that will now be changed or explicitly deleted.")
    print()
    print("Normal files will not be deleted.")
    print("The two allowed Fish files will only be deleted")
    print("for the GNOME target if they exist.")
    print()

    while True:
        try:
            confirmation = input("Apply these changes now? [y/N]: ").strip().lower()

        except EOFError:
            return False

        if confirmation in (
            "y",
            "yes",
            "j",
            "ja",
        ):
            return True

        if confirmation in (
            "",
            "n",
            "no",
            "nein",
            "q",
            "quit",
            "exit",
        ):
            print()
            print("Aborted. No changes were made.")
            return False

        print("Please enter y or n.")


# ===========================================================================
# Backup
# ===========================================================================


def create_backup(
    destination: Path,
    relative: Path,
    backup_root: Path,
) -> Path:
    """
    Sichert eine vorhandene Datei.

    Das gilt sowohl für Dateien, die überschrieben,
    als auch für Dateien, die gezielt gelöscht werden.
    """

    backup_path = backup_root / relative

    backup_path.parent.mkdir(
        parents=True,
        exist_ok=True,
    )

    shutil.copy2(
        destination,
        backup_path,
    )

    return backup_path


# ===========================================================================
# Atomisches Schreiben
# ===========================================================================


def copy_atomically(
    source: Path,
    destination: Path,
) -> None:
    """
    Schreibt eine Datei atomar in das Ziel.

    Zuerst wird eine temporäre Datei geschrieben,
    anschließend wird sie per replace ausgetauscht.
    """

    destination.parent.mkdir(
        parents=True,
        exist_ok=True,
    )

    temporary_path: Path | None = None

    try:
        with tempfile.NamedTemporaryFile(
            dir=destination.parent,
            prefix=".dots-toggle-",
            delete=False,
        ) as temporary:
            temporary_path = Path(temporary.name)

        shutil.copy2(
            source,
            temporary_path,
        )

        temporary_path.replace(destination)

    finally:
        if temporary_path is not None:
            temporary_path.unlink(missing_ok=True)


# ===========================================================================
# Änderungen anwenden
# ===========================================================================


def apply_changes(
    changes: list[Change],
) -> None:
    """
    Wendet nur die zuvor angezeigten und bestätigten Aktionen an.

    Unterstützte Aktionen:

        write
        delete
    """

    if not changes:
        print("No changes required.")
        return

    timestamp = datetime.now().strftime("%Y%m%d-%H%M%S-%f")

    backup_root = BACKUP_ROOT / timestamp

    backups_created: list[Path] = []

    # Dateien, die durch diesen Lauf neu erzeugt wurden.
    newly_created: list[Path] = []

    # Dateien, die vor diesem Lauf bereits existierten.
    existing_before = set()

    for (
        relative,
        source,
        destination,
        action,
    ) in changes:
        if destination is not None:
            existing_before.add(live_file(relative))

    try:
        # ===========================================================
        # Alle bestätigten Aktionen nacheinander durchführen.
        # ===========================================================

        for (
            relative,
            source,
            destination,
            action,
        ) in changes:
            target = live_file(relative)

            # -------------------------------------------------------
            # WRITE
            # -------------------------------------------------------

            if action == "write":
                if source is None:
                    raise RuntimeError(f"WRITE action has no source:\n  {relative}")

                # ---------------------------------------------------
                # Vorhandene Datei sichern.
                # ---------------------------------------------------

                if destination is not None:
                    if not target.is_file():
                        raise RuntimeError(
                            f"Backup target is not a regular file:\n  {target}"
                        )

                    backup_path = create_backup(
                        target,
                        relative,
                        backup_root,
                    )

                    backups_created.append(backup_path)

                # ---------------------------------------------------
                # Neue Datei markieren.
                # ---------------------------------------------------

                else:
                    newly_created.append(target)

                # ---------------------------------------------------
                # Schreiben.
                # ---------------------------------------------------

                copy_atomically(
                    source,
                    target,
                )

                # ---------------------------------------------------
                # Sofort verifizieren.
                # ---------------------------------------------------

                if not files_equal(
                    source,
                    target,
                ):
                    raise RuntimeError(
                        f"Verification failed:\n  Source: {source}\n  Target: {target}"
                    )

                continue

            # -------------------------------------------------------
            # DELETE
            # -------------------------------------------------------

            if action == "delete":
                # Sicherheitsprüfung:
                # Es dürfen ausschließlich die zwei explizit
                # erlaubten GNOME-Dateien gelöscht werden.
                if relative not in GNOME_REMOVE_PATHS:
                    raise RuntimeError(
                        f"Security error: unauthorized delete action:\n  {relative}"
                    )

                if target.exists():
                    if not target.is_file():
                        raise RuntimeError(
                            f"Delete target is not a regular file:\n  {target}"
                        )

                    # ------------------------------------------------
                    # VOR dem Löschen sichern.
                    # ------------------------------------------------

                    backup_path = create_backup(
                        target,
                        relative,
                        backup_root,
                    )

                    backups_created.append(backup_path)

                    # ------------------------------------------------
                    # Nur diese explizit erlaubte Datei löschen.
                    # ------------------------------------------------

                    target.unlink()

                # ---------------------------------------------------
                # Verifizieren.
                # ---------------------------------------------------

                if target.exists():
                    raise RuntimeError(f"Deletion could not be verified:\n  {target}")

                continue

            # -------------------------------------------------------
            # Unbekannte Aktion.
            # -------------------------------------------------------

            raise RuntimeError(f"Unknown action '{action}' for:\n  {relative}")

    except Exception as error:
        # ===========================================================
        # FEHLER -> ROLLBACK
        # ===========================================================

        print()
        print(
            "ERROR: Changes could not be fully applied.",
            file=sys.stderr,
        )
        print(
            f"  {error}",
            file=sys.stderr,
        )

        print()
        print("Attempting to restore the previous state...")

        # -----------------------------------------------------------
        # 1. Dateien aus Backups wiederherstellen.
        #
        # Das deckt sowohl:
        #
        #   überschrieben
        #
        # als auch:
        #
        #   gelöscht
        #
        # ab.
        # -----------------------------------------------------------

        for backup_path in reversed(backups_created):
            try:
                relative = backup_path.relative_to(backup_root)

                target = live_file(relative)

                copy_atomically(
                    backup_path,
                    target,
                )

                print(f"  ✓ Restored: {target}")

            except OSError as restore_error:
                print(
                    "  WARNING: Backup could not be restored:",
                    file=sys.stderr,
                )
                print(
                    f"    {backup_path}",
                    file=sys.stderr,
                )
                print(
                    f"    {restore_error}",
                    file=sys.stderr,
                )

        # -----------------------------------------------------------
        # 2. Dateien entfernen, die vorher NICHT existierten
        #    und durch diesen fehlgeschlagenen Lauf neu entstanden.
        #
        # Das betrifft ausschließlich neu angelegte Dateien.
        # Bestehende Dateien werden hier niemals entfernt.
        # -----------------------------------------------------------

        for target in newly_created:
            if target in existing_before:
                continue

            if not target.exists():
                continue

            try:
                target.unlink()

                print(f"  ✓ Removed new file: {target}")

            except OSError as remove_error:
                print(
                    "  WARNING: Newly created file could not be removed:",
                    file=sys.stderr,
                )
                print(
                    f"    {target}",
                    file=sys.stderr,
                )
                print(
                    f"    {remove_error}",
                    file=sys.stderr,
                )

        print()
        print("Rollback completed as far as possible.")

        raise

    # ==================================================================
    # ERFOLG
    # ==================================================================

    write_changes = [item for item in changes if item[3] == "write"]

    delete_changes = [item for item in changes if item[3] == "delete"]

    print()
    print("=" * 72)
    print("  CHANGES SUCCESSFULLY APPLIED")
    print("=" * 72)
    print()

    # ------------------------------------------------------------------
    # Geschriebene Dateien
    # ------------------------------------------------------------------

    for (
        relative,
        source,
        destination,
        action,
    ) in write_changes:
        target = live_file(relative)

        if destination is None:
            print(f"  ✓ NEW      {target}")
        else:
            print(f"  ✓ CHANGED  {target}")

    # ------------------------------------------------------------------
    # Gelöschte Dateien
    # ------------------------------------------------------------------

    for (
        relative,
        source,
        destination,
        action,
    ) in delete_changes:
        target = live_file(relative)

        print(f"  ✓ DELETED  {target}")

    # ------------------------------------------------------------------
    # Backups
    # ------------------------------------------------------------------

    if backups_created:
        print()
        print(f"Backups: {backup_root}")

    # ------------------------------------------------------------------
    # Sicherheitshinweis
    # ------------------------------------------------------------------

    print()
    print("Normal files were not deleted.")
    print("Only the explicitly allowed Fish files")
    print("were removed for the GNOME target.")


# ===========================================================================
# Desktop-Erkennung
# ===========================================================================


def current_desktop() -> str:
    """Erkennt die aktuell laufende Desktop-Umgebung."""

    values = (
        os.environ.get(
            "XDG_CURRENT_DESKTOP",
            "",
        ),
        os.environ.get(
            "XDG_SESSION_DESKTOP",
            "",
        ),
        os.environ.get(
            "DESKTOP_SESSION",
            "",
        ),
    )

    combined = " ".join(values).lower()

    # Hyprland-Variable ist sehr eindeutig.
    if os.environ.get("HYPRLAND_INSTANCE_SIGNATURE"):
        return "hyprland"

    if "hyprland" in combined:
        return "hyprland"

    if "gnome" in combined:
        return "gnome"

    return "unknown"


def desktop_name(
    desktop: str,
) -> str:
    """Liefert einen schönen Anzeigenamen."""

    if desktop == "gnome":
        return "GNOME"

    if desktop == "hyprland":
        return "Hyprland"

    return "Unknown"


def print_current_desktop() -> str:
    """Zeigt die aktuell erkannte Desktop-Umgebung an."""

    current = current_desktop()

    print_header("CURRENT DESKTOP ENVIRONMENT")

    print(f"  Current: {desktop_name(current)}")

    if current == "unknown":
        print()

        print(
            "  XDG_CURRENT_DESKTOP:",
            os.environ.get(
                "XDG_CURRENT_DESKTOP",
                "<not set>",
            ),
        )

    return current


# ===========================================================================
# Auswahl
# ===========================================================================


def choose_target(
    current: str,
) -> str:
    """Lässt das Zielprofil auswählen."""

    print()
    print("Which profile diff do you want to apply?")
    print()
    print("  [1] GNOME      → ~/dots-hyprland/dots-gnome")
    print("  [2] Hyprland   → ~/dots-hyprland/dots")
    print("  [q] Abort")
    print()

    if current != "unknown":
        print(f"  Currently detected: {desktop_name(current)}")

        print()

    while True:
        try:
            answer = input("Selection [1/2/q]: ").strip().lower()

        except EOFError:
            print()

            return ""

        if answer == "1":
            return "gnome"

        if answer == "2":
            return "hyprland"

        if answer in (
            "q",
            "quit",
            "exit",
        ):
            return ""

        print("Please enter 1, 2, or q.")


# ===========================================================================
# Main
# ===========================================================================


def main() -> int:

    parser = argparse.ArgumentParser(description=__doc__)

    parser.add_argument(
        "--target",
        choices=(
            "gnome",
            "hyprland",
        ),
        help=("Specify the target directly: gnome or hyprland."),
    )

    args = parser.parse_args()

    try:
        # --------------------------------------------------------------
        # Aktuelle Desktop-Umgebung.
        # --------------------------------------------------------------

        current = print_current_desktop()

        # --------------------------------------------------------------
        # Ziel bestimmen.
        # --------------------------------------------------------------

        if args.target:
            target = args.target

            print()

            print(f"Target: {desktop_name(target)}")

        else:
            target = choose_target(current)

            if not target:
                print("Aborted. No changes were made.")

                return 0

        # --------------------------------------------------------------
        # Profilpfad.
        # --------------------------------------------------------------

        target_root = profile_root(target)

        print()

        print(f"Target profile: {target_root}")

        # --------------------------------------------------------------
        # Profil muss existieren.
        # --------------------------------------------------------------

        if not target_root.is_dir():
            raise RuntimeError(f"Target profile does not exist:\n  {target_root}")

        # --------------------------------------------------------------
        # Vergleich.
        # --------------------------------------------------------------

        print()

        print("Comparing only files from the selected target profile")

        print("inside .config and .local.")

        print("Normal missing files will NOT be deleted.")

        if target == "gnome":
            print("Only glasstoggle.fish and border-visible.fish")

            print("may be explicitly removed for the GNOME target.")

        else:
            print("glasstoggle.fish and border-visible.fish")

            print("will be copied from the Hyprland profile.")

        print("glasstoggle-full.fish will never be touched.")

        # --------------------------------------------------------------
        # Unterschiede ermitteln.
        # --------------------------------------------------------------

        changes = find_changes(target)

        # --------------------------------------------------------------
        # Exakt anzeigen.
        # --------------------------------------------------------------

        print_changes(
            changes,
            target,
        )

        # --------------------------------------------------------------
        # Nichts zu tun.
        # --------------------------------------------------------------

        if not changes:
            return 0

        # --------------------------------------------------------------
        # Diff + Bestätigung.
        # --------------------------------------------------------------

        if not ask_before_apply(changes):
            print()

            print("No changes were made.")

            return 0

        # --------------------------------------------------------------
        # Erst jetzt schreiben/löschen.
        # --------------------------------------------------------------

        apply_changes(changes)

        # --------------------------------------------------------------
        # Abschluss.
        # --------------------------------------------------------------

        print()

        print("Done.")

        print("No reboot was performed.")

        print("No bootloader was modified.")

        print("No GNOME keybindings were modified.")

        return 0

    except (
        OSError,
        RuntimeError,
        shutil.Error,
    ) as error:
        print(
            f"gnome-toggle: {error}",
            file=sys.stderr,
        )

        return 1


if __name__ == "__main__":
    raise SystemExit(main())
