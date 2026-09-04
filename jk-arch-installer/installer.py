#!/usr/bin/env python3

from __future__ import annotations

import argparse
import json
import os
import platform
import shlex
import shutil
import signal
import subprocess
import sys
import time

from dataclasses import dataclass
from datetime import datetime
from pathlib import Path
from typing import Any


# ============================================================
# PATHS
# ============================================================

BASE_DIR = Path(__file__).resolve().parent
INSTALLATIONS_FILE = BASE_DIR / "installations.json"
STEPS_DIR = BASE_DIR / "steps"
LOG_DIR = BASE_DIR / "logs"

LOG_DIR.mkdir(parents=True, exist_ok=True)


# ============================================================
# GLOBAL STATE
# ============================================================

STOP_REQUESTED = False
LANGUAGE = "en"


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


def paint(text: str, color: str) -> str:
    if not sys.stdout.isatty():
        return text

    return f"{color}{text}{Colors.RESET}"


def info(text: str) -> None:
    print(paint(f"[INFO] {text}", Colors.BLUE))


def success(text: str) -> None:
    print(paint(f"[ OK ] {text}", Colors.GREEN))


def warning(text: str) -> None:
    print(paint(f"[WARN] {text}", Colors.YELLOW))


def error(text: str) -> None:
    print(
        paint(f"[ERROR] {text}", Colors.RED),
        file=sys.stderr,
    )


def command_output(text: str) -> None:
    print(paint(f"[CMD ] {text}", Colors.CYAN))


# ============================================================
# TRANSLATION
# ============================================================

TRANSLATIONS = {
    "de": {
        "title": "ARCH LINUX INSTALLER",
        "subtitle": "Sicherer, modularer JSON-basierter Installationsmanager",
        "language": "Sprache auswählen",
        "german": "Deutsch",
        "english": "Englisch",
        "language_invalid": "Bitte 1 oder 2 auswählen.",
        "arch_detected": "Arch-basierte Distribution erkannt",
        "root_ok": "Root-Rechte vorhanden.",
        "programs_ok": "Benötigte Programme vorhanden.",
        "dry_run": "DRY-RUN ist aktiv. Es werden keine Änderungen vorgenommen.",
        "start": "Soll die Installation gestartet werden?",
        "skip": "Schritt wird übersprungen.",
        "already": "Dieser Installationsschritt scheint bereits installiert zu sein.",
        "reinstall": "Trotzdem erneut ausführen?",
        "step": "Schritt",
        "successful": "Erfolgreich",
        "failed": "Fehlgeschlagen",
        "finished": "Installation abgeschlossen.",
        "abort": "Installation abgebrochen.",
        "continue": "Soll mit dem nächsten Schritt fortgefahren werden?",
        "not_allowed": "Dieser Command ist für die erkannte Distribution nicht freigegeben.",
        "command_success": "Befehl erfolgreich beendet",
        "command_failed": "Befehl fehlgeschlagen",
        "step_selection": "Installationsschritte auswählen",
        "step_selection_help": "Pfeile: bewegen | Leertaste: an/aus | Tab: Details | Bild hoch/runter: scrollen | a: alle | n: keine | Enter: bestätigen | q: abbrechen",
        "step_selection_count": "{selected}/{total} Schritte ausgewählt",
        "step_selection_empty": "Bitte mindestens einen Schritt auswählen.",
        "exclusive_selection": "Nur eine Methode aus dieser Gruppe kann ausgewählt werden.",
        "exclusive_marker": "exklusiv",
        "step_description": "Details:",
        "step_command": "Befehl",
        "step_question": "Rückfrage",
        "step_requires_root": "Benötigt Root",
        "step_allowed_distros": "Erlaubte Distributionen",
        "yes": "ja",
        "no": "nein",
        "selection_cancelled": "Auswahl abgebrochen.",
        "selection_noninteractive": "Kein interaktives Terminal erkannt; alle Schritte werden ausgewählt.",
        "selected_plan": "Folgende Installationsschritte werden jetzt ausgeführt:",
    },

    "en": {
        "title": "ARCH LINUX INSTALLER",
        "subtitle": "Secure, modular JSON-based installation manager",
        "language": "Select language",
        "german": "German",
        "english": "English",
        "language_invalid": "Please select 1 or 2.",
        "arch_detected": "Arch-based distribution detected",
        "root_ok": "Root privileges available.",
        "programs_ok": "Required programs are available.",
        "dry_run": "DRY-RUN is active. No changes will be made.",
        "start": "Start the installation?",
        "skip": "Step skipped.",
        "already": "This installation step appears to be already installed.",
        "reinstall": "Run it again anyway?",
        "step": "Step",
        "successful": "Successful",
        "failed": "Failed",
        "finished": "Installation completed.",
        "abort": "Installation aborted.",
        "continue": "Continue with the next step?",
        "not_allowed": "This command is not allowed for the detected distribution.",
        "command_success": "Command completed successfully",
        "command_failed": "Command failed",
        "step_selection": "Select installation steps",
        "step_selection_help": "Arrows: move | Space: toggle | Tab: details | Page Up/Down: scroll | a: all | n: none | Enter: confirm | q: cancel",
        "step_selection_count": "{selected}/{total} steps selected",
        "step_selection_empty": "Please select at least one step.",
        "exclusive_selection": "Only one method from this group can be selected.",
        "exclusive_marker": "exclusive",
        "step_description": "Details:",
        "step_command": "Command",
        "step_question": "Prompt",
        "step_requires_root": "Requires root",
        "step_allowed_distros": "Allowed distributions",
        "yes": "yes",
        "no": "no",
        "selection_cancelled": "Selection cancelled.",
        "selection_noninteractive": "No interactive terminal detected; all steps will be selected.",
        "selected_plan": "The following installation steps will now be executed:",
    },
}


def tr(key: str) -> str:
    return TRANSLATIONS[LANGUAGE].get(key, key)


def localized(value: Any) -> str:
    """
    Supports:

        "description": {
            "de": "...",
            "en": "..."
        }

    and simple strings.
    """

    if isinstance(value, str):
        return value

    if isinstance(value, dict):
        selected = value.get(LANGUAGE)

        if isinstance(selected, str):
            return selected

        fallback = value.get("en") or value.get("de")

        if isinstance(fallback, str):
            return fallback

    return ""


# ============================================================
# LOGGING
# ============================================================

class Logger:
    def __init__(self) -> None:
        timestamp = datetime.now().strftime(
            "%Y-%m-%d_%H-%M-%S"
        )

        self.path = (
            LOG_DIR /
            f"installer_{timestamp}.log"
        )

    def write(self, message: str) -> None:
        timestamp = datetime.now().strftime(
            "%Y-%m-%d %H:%M:%S"
        )

        with self.path.open(
            "a",
            encoding="utf-8",
        ) as file:
            file.write(
                f"[{timestamp}] {message}\n"
            )


LOGGER = Logger()


def log(message: str) -> None:
    LOGGER.write(message)


# ============================================================
# SIGNAL HANDLING
# ============================================================

def handle_signal(
    signum: int,
    frame: Any,
) -> None:

    global STOP_REQUESTED

    STOP_REQUESTED = True

    warning(
        "Abbruch angefordert. "
        "Der aktuelle Prozess darf sauber beendet werden."
        if LANGUAGE == "de"
        else "Abort requested. "
        "The current process will be allowed to exit cleanly."
    )

    log(f"Received signal: {signum}")


signal.signal(
    signal.SIGINT,
    handle_signal,
)

signal.signal(
    signal.SIGTERM,
    handle_signal,
)


# ============================================================
# EXCEPTIONS
# ============================================================

class InstallerError(Exception):
    pass


class ConfigurationError(InstallerError):
    pass


class CommandError(InstallerError):
    pass


# ============================================================
# DATA STRUCTURES
# ============================================================

@dataclass
class Command:
    command: list[str]
    description: Any
    requires_root: bool
    distros: list[str]


@dataclass
class InstallationStep:
    id: str
    name: Any
    description: Any
    question: Any
    commands: list[Command]
    checks: list[dict[str, Any]]
    optional: bool
    continue_on_error: bool
    exclusive_group: str | None


# ============================================================
# JSON
# ============================================================

def load_json(path: Path) -> dict[str, Any]:

    if not path.exists():
        raise ConfigurationError(
            f"JSON file does not exist: {path}"
        )

    try:
        with path.open(
            "r",
            encoding="utf-8",
        ) as file:
            data = json.load(file)

    except json.JSONDecodeError as exc:
        raise ConfigurationError(
            f"Invalid JSON in {path}: {exc}"
        ) from exc

    if not isinstance(data, dict):
        raise ConfigurationError(
            f"{path} must contain a JSON object."
        )

    return data


def load_installation_table() -> list[dict[str, Any]]:

    data = load_json(
        INSTALLATIONS_FILE
    )

    installations = data.get(
        "installations"
    )

    if not isinstance(
        installations,
        list,
    ):
        raise ConfigurationError(
            "'installations' must be a JSON array."
        )

    return installations


def load_step(
    filename: str,
    variant: str | None = None,
) -> InstallationStep:

    candidate = (STEPS_DIR / filename).resolve()
    steps_root = STEPS_DIR.resolve()

    if candidate != steps_root and steps_root not in candidate.parents:
        raise ConfigurationError(
            f"Step file is outside the steps directory: {filename!r}"
        )

    path = candidate
    data = load_json(path)

    variants = data.get("variants")
    if variants is not None:
        if not isinstance(variants, dict) or not variants:
            raise ConfigurationError(
                f"{path}: 'variants' must be a non-empty object."
            )
        selected_variant = variant or next(iter(variants))
        if selected_variant not in variants:
            raise ConfigurationError(
                f"{path}: unknown variant '{selected_variant}'."
            )
        variant_data = variants[selected_variant]
        if not isinstance(variant_data, dict):
            raise ConfigurationError(
                f"{path}: variant '{selected_variant}' must be an object."
            )
        data = {**data, **variant_data}

    required = [
        "id",
        "name",
        "description",
        "question",
        "commands",
    ]

    for key in required:
        if key not in data:
            raise ConfigurationError(
                f"{path}: missing field '{key}'."
            )

    if not isinstance(
        data["commands"],
        list,
    ):
        raise ConfigurationError(
            f"{path}: 'commands' must be an array."
        )

    commands: list[Command] = []

    for index, raw in enumerate(
        data["commands"]
    ):

        if not isinstance(raw, dict):
            raise ConfigurationError(
                f"{path}: commands[{index}] "
                f"must be an object."
            )

        command = raw.get("command")

        if (
            not isinstance(command, list)
            or not command
            or not all(
                isinstance(x, str)
                for x in command
            )
        ):
            raise ConfigurationError(
                f"{path}: commands[{index}].command "
                f"must be a non-empty string array."
            )

        if "distros" not in raw:
            raise ConfigurationError(
                f"{path}: commands[{index}] is missing required 'distros' field."
            )

        distros = raw["distros"]

        if not isinstance(
            distros,
            list,
        ):
            raise ConfigurationError(
                f"{path}: commands[{index}].distros "
                f"must be an array."
            )

        if not distros or not all(
            isinstance(x, str) and x.strip()
            for x in distros
        ):
            raise ConfigurationError(
                f"{path}: every distro target "
                f"must be a string."
            )

        requires_root = raw.get("requires_root", True)
        if not isinstance(requires_root, bool):
            raise ConfigurationError(
                f"{path}: commands[{index}].requires_root must be boolean."
            )

        commands.append(
            Command(
                command=command,
                description=raw.get(
                    "description",
                    "",
                ),
                requires_root=requires_root,
                distros=[
                    x.lower()
                    for x in distros
                ],
            )
        )

    checks = data.get("checks", [])
    if not isinstance(checks, list):
        raise ConfigurationError(
            f"{path}: 'checks' must be an array."
        )

    optional = data.get("optional", False)
    if not isinstance(optional, bool):
        raise ConfigurationError(
            f"{path}: 'optional' must be boolean."
        )

    continue_on_error = data.get("continue_on_error", False)
    if not isinstance(continue_on_error, bool):
        raise ConfigurationError(
            f"{path}: 'continue_on_error' must be boolean."
        )

    exclusive_group = data.get("exclusive_group")
    if exclusive_group is not None and not isinstance(exclusive_group, str):
        raise ConfigurationError(
            f"{path}: 'exclusive_group' must be a string."
        )

    return InstallationStep(
        id=str(data["id"]),
        name=data["name"],
        description=data["description"],
        question=data["question"],
        commands=commands,
        checks=checks,
        optional=optional,
        continue_on_error=continue_on_error,
        exclusive_group=exclusive_group,
    )


# ============================================================
# DISTRIBUTION DETECTION
# ============================================================

def read_os_release() -> dict[str, str]:

    path = Path("/etc/os-release")

    if not path.exists():
        raise InstallerError(
            "/etc/os-release was not found."
        )

    result: dict[str, str] = {}

    for line in path.read_text(
        encoding="utf-8"
    ).splitlines():

        line = line.strip()

        if not line or "=" not in line:
            continue

        key, value = line.split(
            "=",
            1,
        )

        value = value.strip()

        if (
            len(value) >= 2
            and value[0] == '"'
            and value[-1] == '"'
        ):
            value = value[1:-1]

        result[key] = value

    return result


def detect_distribution() -> str:
    """
    Detect the currently running Linux distribution.

    Supported distributions:
        - Arch Linux
        - CachyOS
        - EndeavourOS
        - Garuda Linux
        - Manjaro

    Returns:
        "arch"
        "cachyos"
        "endeavouros"
        "garuda"
        "manjaro"
        "arch_based"
        "unknown"

    Important:
        The exact /etc/os-release ID has priority.

        ID_LIKE is NEVER used to pretend that an unknown
        distribution is one of the exact supported distributions.

        ID_LIKE may only be used to identify a generic
        Arch-based distribution.
    """

    data = read_os_release()

    distro_id = data.get(
        "ID",
        "",
    ).strip().lower()

    id_like_raw = data.get(
        "ID_LIKE",
        "",
    ).strip().lower()

    pretty_name = data.get(
        "PRETTY_NAME",
        "",
    ).strip()

    # --------------------------------------------------------
    # Normalize ID_LIKE
    # --------------------------------------------------------

    id_like = {
        value.strip().lower()
        for value in id_like_raw.split()
        if value.strip()
    }

    log(
        "OS detection: "
        f"ID={distro_id!r}, "
        f"ID_LIKE={sorted(id_like)!r}, "
        f"PRETTY_NAME={pretty_name!r}"
    )

    # ========================================================
    # EXACT DISTRIBUTION IDs
    # ========================================================
    #
    # Exact ID always wins.
    #
    # This is the most reliable way to identify the actual
    # distribution.
    # ========================================================

    exact_distributions = {
        "arch": "arch",
        "cachyos": "cachyos",
        "endeavouros": "endeavouros",
        "garuda": "garuda",
        "manjaro": "manjaro",
    }

    detected = exact_distributions.get(
        distro_id
    )

    if detected is not None:

        log(
            "Detected supported distribution: "
            f"{detected}"
        )

        return detected

    # ========================================================
    # GENERIC ARCH-BASED FALLBACK
    # ========================================================
    #
    # IMPORTANT:
    #
    # We do NOT convert:
    #
    #     ID_LIKE="arch"
    #
    # into:
    #
    #     "arch"
    #
    # because that would falsely identify the distribution.
    #
    # Instead we return:
    #
    #     "arch_based"
    #
    # This allows commands that explicitly support all
    # Arch-based systems to run, while commands requiring
    # exact distro identification remain blocked.
    # ========================================================

    if "arch" in id_like:

        log(
            "Detected generic Arch-based distribution: "
            f"ID={distro_id!r}"
        )

        return "arch_based"

    # ========================================================
    # UNKNOWN / UNSUPPORTED
    # ========================================================

    log(
        "Unsupported or unknown distribution: "
        f"ID={distro_id!r}, "
        f"PRETTY_NAME={pretty_name!r}"
    )

    return "unknown"


def distribution_display_name(
    distro: str,
) -> str:

    names = {
        "arch": "Arch Linux",
        "cachyos": "CachyOS",
        "endeavouros": "EndeavourOS",
        "garuda": "Garuda Linux",
        "manjaro": "Manjaro",
        "arch_based": "Arch-based Linux",
        "unknown": "Unknown / Unsupported Linux",
    }

    return names.get(
        distro,
        "Unknown / Unsupported Linux",
    )


# ============================================================
# DISTRIBUTION POLICY
# ============================================================

EXACT_DISTRIBUTIONS = {
    "arch",
    "cachyos",
    "endeavouros",
    "garuda",
    "manjaro",
}

SUPPORTED_DISTRIBUTIONS = EXACT_DISTRIBUTIONS | {"arch_based"}


def command_allowed(
    command: Command,
    detected_distro: str,
) -> bool:
    """
    Check whether a command is allowed on the detected distro.

    A command MUST explicitly declare at least one target
    distribution.

    Examples:

        "distros": ["cachyos"]

            -> CachyOS only

        "distros": ["arch"]

            -> Arch Linux only

        "distros": ["arch", "cachyos"]

            -> Arch Linux OR CachyOS

        "distros": ["arch_based"]

            -> Any detected Arch-based distribution

    There is intentionally NO unrestricted "all" target.
    """

    # --------------------------------------------------------
    # Normalize targets
    # --------------------------------------------------------

    targets = {
        target.strip().lower()
        for target in command.distros
        if isinstance(target, str)
        and target.strip()
    }

    # --------------------------------------------------------
    # A command without distro targets is a configuration
    # error. Never silently allow it.
    # --------------------------------------------------------

    if not targets:

        raise ConfigurationError(
            "Command has no distribution target."
        )

    # --------------------------------------------------------
    # Validate distribution targets
    # --------------------------------------------------------

    unknown_targets = (
        targets
        - SUPPORTED_DISTRIBUTIONS
    )

    if unknown_targets:

        raise ConfigurationError(
            "Unknown distribution target(s): "
            + ", ".join(
                sorted(unknown_targets)
            )
        )

    # --------------------------------------------------------
    # Unknown / unsupported operating system
    # --------------------------------------------------------

    if detected_distro not in SUPPORTED_DISTRIBUTIONS:

        log(
            "Command blocked: unsupported "
            f"distribution={detected_distro!r}"
        )

        return False

    # --------------------------------------------------------
    # Exact match
    # --------------------------------------------------------

    if detected_distro in targets:

        return True

    # --------------------------------------------------------
    # Generic Arch-based target
    # --------------------------------------------------------
    #
    # "arch_based" means:
    #
    #     Arch
    #     CachyOS
    #     EndeavourOS
    #     Garuda
    #     Manjaro
    #     other distro explicitly detected as Arch-based
    #
    # It does NOT mean "all Linux".
    # --------------------------------------------------------

    if "arch_based" in targets:

        if detected_distro in SUPPORTED_DISTRIBUTIONS:

            return True

    # --------------------------------------------------------
    # Not allowed
    # --------------------------------------------------------

    log(
        "Command blocked by distribution policy: "
        f"detected={detected_distro!r}, "
        f"allowed={sorted(targets)!r}"
    )

    return False

# ============================================================
# SYSTEM VALIDATION
# ============================================================

def require_root() -> None:

    if os.geteuid() != 0:
        raise InstallerError(
            "Root privileges are required."
        )


def check_arch_family(
    distro: str,
) -> None:

    if distro not in SUPPORTED_DISTRIBUTIONS:
        data = read_os_release()

        raise InstallerError(
            "This installer only supports the configured "
            "Arch-family distributions. Detected: "
            f"{data.get('PRETTY_NAME', 'unknown')}"
        )


def check_required_programs() -> None:

    required = [
        "pacman",
        "systemctl",
    ]

    missing = [
        program
        for program in required
        if shutil.which(program) is None
    ]

    if missing:
        raise InstallerError(
            "Missing required programs: "
            + ", ".join(missing)
        )


# ============================================================
# LANGUAGE SELECTION
# ============================================================

def select_language() -> None:

    global LANGUAGE

    print()
    print("=" * 70)
    print("Select language / Sprache auswählen")
    print("=" * 70)
    print()
    print("1. Deutsch")
    print("2. English")
    print()

    while True:

        try:
            answer = input(
                "Auswahl / Choice [1/2]: "
            ).strip()

        except EOFError:
            answer = "2"

        if answer == "1":
            LANGUAGE = "de"
            return

        if answer == "2":
            LANGUAGE = "en"
            return

        print(
            paint(
                tr("language_invalid"),
                Colors.YELLOW,
            )
        )


# ============================================================
# YES / NO
# ============================================================

def ask_yes_no(
    question: str,
    default: bool = True,
) -> bool:

    suffix = (
        "[J/n]"
        if LANGUAGE == "de" and default
        else "[j/N]"
        if LANGUAGE == "de"
        else "[Y/n]"
        if default
        else "[y/N]"
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

        yes = {
            "j",
            "ja",
            "y",
            "yes",
        }

        no = {
            "n",
            "nein",
            "no",
        }

        if answer in yes:
            return True

        if answer in no:
            return False

        warning(
            "Bitte j/n oder y/n verwenden."
            if LANGUAGE == "de"
            else "Please answer j/n or y/n."
        )


# ============================================================
# CHECKS
# ============================================================

def package_installed(
    package: str,
) -> bool:

    result = subprocess.run(
        [
            "pacman",
            "-Q",
            package,
        ],
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
        check=False,
    )

    return result.returncode == 0


def command_exists(
    command: str,
) -> bool:

    return shutil.which(command) is not None


def file_exists(
    path: str,
) -> bool:

    return Path(path).exists()


def perform_check(
    check: dict[str, Any],
) -> bool:

    if not isinstance(check, dict):
        raise ConfigurationError(
            "Every check must be an object."
        )

    check_type = check.get("type")

    if check_type == "package_installed":
        return package_installed(
            str(check["package"])
        )

    if check_type == "command_exists":
        return command_exists(
            str(check["command"])
        )

    if check_type == "file_exists":
        return file_exists(
            str(check["path"])
        )

    if check_type == "always":
        return True

    raise ConfigurationError(
        f"Unknown check type: {check_type}"
    )


def is_already_installed(
    step: InstallationStep,
) -> bool:

    if not step.checks:
        return False

    return all(
        perform_check(check)
        for check in step.checks
    )


# ============================================================
# COMMAND EXECUTION
# ============================================================

def format_command(
    command: list[str],
) -> str:

    return shlex.join(command)


def execute_command(
    command: Command,
    detected_distro: str,
    dry_run: bool,
) -> bool:

    # --------------------------------------------------------
    # SECURITY: distro policy checked BEFORE execution
    # --------------------------------------------------------

    if not command_allowed(
        command,
        detected_distro,
    ):
        message = (
            f"{tr('not_allowed')} "
            f"Target: {', '.join(command.distros)}; "
            f"Detected: {detected_distro}"
        )

        error(message)

        log(
            f"COMMAND BLOCKED BY DISTRO POLICY: "
            f"{format_command(command.command)}"
        )

        return False

    display = format_command(
        command.command
    )

    print()
    command_output(display)

    description = localized(
        command.description
    )

    if description:
        info(description)

    log(
        f"COMMAND: {display}"
    )

    log(
        f"TARGET DISTROS: "
        f"{','.join(command.distros)}"
    )

    if dry_run:
        warning(
            tr("dry_run")
        )
        return True

    if (
        command.requires_root
        and os.geteuid() != 0
    ):
        raise CommandError(
            f"Command requires root: {display}"
        )

    start = time.monotonic()

    try:
        process = subprocess.Popen(
            command.command,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            text=True,
            bufsize=1,
        )

        assert process.stdout is not None

        for line in process.stdout:
            line = line.rstrip("\\n")
            print(line)
            log(f"OUTPUT: {line}")

        returncode = process.wait()

    except KeyboardInterrupt:
        try:
            process.terminate()
            process.wait(timeout=5)
        except Exception:
            try:
                process.kill()
            except Exception:
                pass

        log(f"COMMAND INTERRUPTED: {display}")
        return False

    except FileNotFoundError:
        error(
            f"Executable not found: "
            f"{command.command[0]}"
        )

        log(
            f"EXECUTABLE NOT FOUND: {display}"
        )

        return False

    except OSError as exc:
        error(
            f"Could not execute command: {exc}"
        )

        log(
            f"EXECUTION ERROR: {exc}"
        )

        return False

    duration = (
        time.monotonic() - start
    )

    if returncode == 0:

        success(
            f"{tr('command_success')} "
            f"({duration:.2f}s)."
        )

        log(
            f"SUCCESS exit=0 "
            f"time={duration:.2f}s"
        )

        return True

    error(
        f"{tr('command_failed')}. "
        f"Exit code: {returncode}"
    )

    log(
        f"FAILED exit={returncode} "
        f"time={duration:.2f}s"
    )

    return False


# ============================================================
# STEP EXECUTION
# ============================================================

def execute_step(
    step: InstallationStep,
    detected_distro: str,
    dry_run: bool,
) -> bool:

    print()
    print("=" * 70)
    print(
        paint(
            f"{step.id}: "
            f"{localized(step.name)}",
            Colors.BOLD + Colors.MAGENTA,
        )
    )
    print("=" * 70)

    print()
    print(
        localized(step.description)
    )

    print()

    if is_already_installed(step):

        success(
            tr("already")
        )

        if not ask_yes_no(
            tr("reinstall"),
            default=False,
        ):
            info(
                tr("skip")
            )
            return True

    for index, command in enumerate(
        step.commands,
        start=1,
    ):

        if STOP_REQUESTED:
            return False

        info(
            f"{tr('step')} "
            f"{index}/{len(step.commands)}"
        )

        result = execute_command(
            command,
            detected_distro,
            dry_run,
        )

        if not result:

            log(
                f"STEP FAILED: {step.id}"
            )

            if step.continue_on_error:

                warning(
                    "Error ignored; continuing."
                    if LANGUAGE == "en"
                    else "Fehler ignoriert; "
                    "Installation wird fortgesetzt."
                )

                continue

            return False

    success(
        localized(step.name)
    )

    log(
        f"STEP SUCCESS: {step.id}"
    )

    return True


# ============================================================
# VALIDATION
# ============================================================

def validate_installations(
    installations: list[dict[str, Any]],
) -> None:

    ids: set[str] = set()

    for index, installation in enumerate(
        installations
    ):

        if not isinstance(
            installation,
            dict,
        ):
            raise ConfigurationError(
                f"installations[{index}] must be an object."
            )

        step_id = installation.get(
            "id"
        )

        if not step_id:
            raise ConfigurationError(
                f"installations[{index}] "
                f"has no id."
            )

        if step_id in ids:
            raise ConfigurationError(
                f"Duplicate installation id: "
                f"{step_id}"
            )

        ids.add(step_id)

        filename = installation.get(
            "file"
        )

        if not filename:
            raise ConfigurationError(
                f"{step_id}: missing 'file'."
            )

        load_step(
            str(filename)
        )


# ============================================================
# TABLE DISPLAY
# ============================================================

def show_installation_table(
    installations: list[dict[str, Any]],
) -> None:

    print()
    print("=" * 70)
    print(
        "Installationsschritte"
        if LANGUAGE == "de"
        else "Installation steps"
    )
    print("=" * 70)

    for index, installation in enumerate(
        installations,
        start=1,
    ):

        display_number = installation.get(
            "display_number",
            f"{index:02d}",
        )
        print(
            f"{display_number}. "
            f"{installation.get('id', '?'):<25} "
            f"{localized(installation.get('name', ''))}"
        )

        description = localized(
            installation.get(
                "description",
                "",
            )
        )

        if description:
            print(
                f"    {description}"
            )


def select_installations(
    installations: list[dict[str, Any]],
) -> list[dict[str, Any]] | None:
    """Let the user toggle the steps before starting the installation."""

    if not sys.stdin.isatty() or not sys.stdout.isatty():
        warning(tr("selection_noninteractive"))
        return installations

    import curses
    import textwrap

    expanded_installations: list[dict[str, Any]] = []
    for index, installation in enumerate(installations, start=1):
        substeps = installation.get("substeps", [])
        if not substeps:
            item = dict(installation)
            item["display_number"] = f"{index:02d}"
            expanded_installations.append(item)
            continue
        for subindex, substep in enumerate(substeps, start=1):
            item = dict(installation)
            item.update(substep)
            item["file"] = installation["file"]
            item["display_number"] = f"{index:02d}.{subindex}"
            expanded_installations.append(item)

    installations = expanded_installations
    step_details = [
        load_step(str(installation["file"]), installation.get("variant"))
        for installation in installations
    ]
    selected = [True] * len(installations)
    exclusive_groups: dict[str, list[int]] = {}
    for index, step in enumerate(step_details):
        if step.exclusive_group:
            exclusive_groups.setdefault(step.exclusive_group, []).append(index)
    for indices in exclusive_groups.values():
        for index in indices[1:]:
            selected[index] = False

    def draw(
        screen: Any,
        cursor: int,
        show_description: bool,
        detail_scroll: int,
    ) -> None:
        screen.erase()
        height, width = screen.getmaxyx()
        screen.addstr(0, 0, tr("step_selection")[:width - 1], curses.A_BOLD)
        screen.addstr(1, 0, tr("step_selection_help")[:width - 1])

        detail_height = min(12, max(height - 8, 4))
        footer_rows = detail_height + 3 if show_description else 5
        available_rows = max(height - footer_rows, 1)
        first = max(
            0,
            min(
                cursor - available_rows + 1,
                len(installations) - available_rows,
            ),
        )

        for row, index in enumerate(
            range(first, min(first + available_rows, len(installations))),
            start=3,
        ):
            installation = installations[index]
            marker = "[x]" if selected[index] else "[ ]"
            name = localized(
                installation.get(
                    "name",
                    installation.get("id", "?"),
                )
            )
            line = f"{marker} {installation.get('display_number', f'{index + 1:02d}')}. {name}"
            if step_details[index].exclusive_group:
                line += f" ({tr('exclusive_marker')})"

            if index == cursor:
                screen.attron(curses.A_REVERSE)
            screen.addstr(row, 0, line[:width - 1])
            if index == cursor:
                screen.attroff(curses.A_REVERSE)

        if show_description:
            step = step_details[cursor]
            detail_lines = [
                *textwrap.wrap(
                    localized(step.description),
                    width=max(width - 4, 1),
                ),
            ]
            for command in step.commands:
                detail_lines.extend([
                    "",
                    f"{tr('step_command')}: {format_command(command.command)}",
                    f"{tr('step_requires_root')}: "
                    f"{tr('yes') if command.requires_root else tr('no')}",
                    f"{tr('step_allowed_distros')}: "
                    f"{', '.join(command.distros)}",
                ])
                detail_lines.extend(textwrap.wrap(
                    localized(command.description),
                    width=max(width - 4, 1),
                ))

            visible_details = detail_lines[
                detail_scroll:detail_scroll + detail_height - 1
            ]
            description_row = height - detail_height - 3
            detail_attr = (
                curses.color_pair(1)
                if curses.has_colors()
                else curses.A_DIM
            )
            header_attr = detail_attr | curses.A_BOLD
            for panel_row in range(description_row, height - 2):
                screen.addstr(
                    panel_row,
                    0,
                    " " * max(width - 1, 1),
                    detail_attr,
                )
            screen.addstr(
                description_row,
                0,
                f" {tr('step_description')} "[:width - 1],
                header_attr,
            )
            for offset, line in enumerate(visible_details, start=1):
                if description_row + offset < height - 2:
                    screen.addstr(
                        description_row + offset,
                        1,
                        line[:width - 2],
                        detail_attr,
                    )

        count = tr("step_selection_count").format(
            selected=sum(selected),
            total=len(installations),
        )
        screen.addstr(height - 2, 0, count[:width - 1], curses.A_BOLD)
        screen.addstr(height - 1, 0, tr("step_selection_empty")[:width - 1])
        screen.refresh()

    def choose(screen: Any) -> list[dict[str, Any]] | None:
        curses.curs_set(0)
        screen.keypad(True)
        if curses.has_colors():
            curses.start_color()
            curses.init_pair(1, curses.COLOR_CYAN, curses.COLOR_BLACK)
        cursor = 0
        show_description = False
        detail_scroll = 0

        while True:
            draw(screen, cursor, show_description, detail_scroll)
            key = screen.getch()

            if key in (curses.KEY_UP, ord("k")):
                if show_description:
                    detail_scroll = max(0, detail_scroll - 1)
                else:
                    cursor = (cursor - 1) % len(installations)
            elif key in (curses.KEY_DOWN, ord("j")):
                if show_description:
                    detail_scroll += 1
                else:
                    cursor = (cursor + 1) % len(installations)
            elif key == ord(" "):
                selected[cursor] = not selected[cursor]
                if selected[cursor]:
                    group = step_details[cursor].exclusive_group
                    if group:
                        for index in exclusive_groups[group]:
                            if index != cursor:
                                selected[index] = False
            elif key in (9, curses.KEY_BTAB):
                show_description = not show_description
                detail_scroll = 0
            elif key == curses.KEY_PPAGE:
                detail_scroll = max(0, detail_scroll - 4)
            elif key == curses.KEY_NPAGE:
                detail_scroll += 4
            elif key in (ord("a"), ord("A")):
                selected[:] = [True] * len(installations)
                for indices in exclusive_groups.values():
                    for index in indices[1:]:
                        selected[index] = False
            elif key in (ord("n"), ord("N")):
                selected[:] = [False] * len(installations)
            elif key in (10, 13, curses.KEY_ENTER):
                if any(selected):
                    return [
                        installation
                        for index, installation in enumerate(installations)
                        if selected[index]
                    ]
            elif key in (ord("q"), ord("Q"), 27):
                return None

    try:
        result = curses.wrapper(choose)
    except curses.error:
        warning(tr("selection_noninteractive"))
        return installations

    if result is None:
        warning(tr("selection_cancelled"))
        log("STEP SELECTION CANCELLED")
        return None

    log(
        "SELECTED STEPS: "
        + ",".join(str(item["id"]) for item in result)
    )
    return result


# ============================================================
# MAIN
# ============================================================

def run_installer(
    dry_run: bool,
) -> int:

    select_language()

    print()
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

    log(
        f"Installer started. "
        f"Language={LANGUAGE}"
    )

    # --------------------------------------------------------
    # Detect distro
    # --------------------------------------------------------

    try:
        detected_distro = detect_distribution()

        check_arch_family(
            detected_distro
        )

        success(
            f"{tr('arch_detected')}: "
            f"{distribution_display_name(detected_distro)}"
        )

        if not dry_run:
            require_root()

            success(
                tr("root_ok")
            )

        check_required_programs()

        success(
            tr("programs_ok")
        )

        installations = (
            load_installation_table()
        )

        validate_installations(
            installations
        )

    except InstallerError as exc:

        error(str(exc))

        log(
            f"FATAL: {exc}"
        )

        return 1

    except Exception as exc:

        error(
            f"Unexpected error: "
            f"{type(exc).__name__}: {exc}"
        )

        log(
            f"UNEXPECTED ERROR: "
            f"{type(exc).__name__}: {exc}"
        )

        return 1

    if dry_run:
        warning(
            tr("dry_run")
        )
        info(
            "Root check is skipped in DRY-RUN mode."
            if LANGUAGE == "en"
            else "Die Root-Prüfung wird im DRY-RUN-Modus übersprungen."
        )

    selected_installations = select_installations(
        installations
    )

    if selected_installations is None:
        return 0

    installations = selected_installations

    print()
    print(paint(tr("selected_plan"), Colors.BOLD + Colors.GREEN))
    show_installation_table(installations)
    print()

    if not ask_yes_no(
        tr("start"),
        default=False,
    ):
        warning(
            tr("abort")
        )

        return 0

    total = len(
        installations
    )

    successful = 0

    for position, installation in enumerate(
        installations,
        start=1,
    ):

        if STOP_REQUESTED:
            break

        step_id = str(
            installation["id"]
        )

        filename = str(
            installation["file"]
        )

        print()
        print(
            paint(
                f"========== "
                f"{position}/{total} "
                f"==========",
                Colors.BOLD,
            )
        )

        try:

            step = load_step(
                filename,
                installation.get("variant"),
            )

            result = execute_step(
                step,
                detected_distro,
                dry_run,
            )

            if result:
                successful += 1

            else:

                error(
                    f"{tr('failed')}: "
                    f"{step_id}"
                )

                if not ask_yes_no(
                    tr("continue"),
                    default=False,
                ):
                    break

        except Exception as exc:

            error(
                f"{step_id}: "
                f"{type(exc).__name__}: {exc}"
            )

            log(
                f"STEP EXCEPTION: "
                f"{step_id}: "
                f"{type(exc).__name__}: {exc}"
            )

            if not ask_yes_no(
                tr("continue"),
                default=False,
            ):
                break

    print()
    print("=" * 70)
    print(
        tr("finished")
    )
    print("=" * 70)

    print(
        f"{tr('successful')}: "
        f"{successful}/{total}"
    )

    print(
        f"Log: {LOGGER.path}"
    )

    log(
        f"Installer finished. "
        f"Successful={successful}/{total}"
    )

    return 0


# ============================================================
# CLI
# ============================================================

def parse_arguments() -> argparse.Namespace:

    parser = argparse.ArgumentParser(
        description=(
            "Secure JSON-based Arch-family installer"
        )
    )

    parser.add_argument(
        "--dry-run",
        action="store_true",
        help=(
            "Show commands without executing them."
        ),
    )

    return parser.parse_args()


def main() -> int:

    args = parse_arguments()

    try:
        return run_installer(
            dry_run=args.dry_run
        )

    except KeyboardInterrupt:

        error(
            "Installation interrupted by user."
        )

        return 130


if __name__ == "__main__":
    sys.exit(main())
