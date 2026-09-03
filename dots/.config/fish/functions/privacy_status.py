#!/usr/bin/env python3

import re
import shutil
import subprocess
import glob


ANSI_ESCAPE = re.compile(r"\x1b\[[0-9;]*m")


def visible_length(text: str) -> int:
    return len(ANSI_ESCAPE.sub("", text))


def run_command(cmd):
    try:
        result = subprocess.run(
            cmd,
            capture_output=True,
            text=True,
            timeout=5,
        )

        output = result.stdout.strip()

        if not output:
            output = result.stderr.strip()

        return output or "Keine Ausgabe."

    except subprocess.TimeoutExpired:
        return "Timeout."

    except Exception as e:
        return f"Fehler: {e}"


def pw_top_snapshot():
    """
    Erstellt eine brauchbare PipeWire Momentaufnahme.
    pw-top braucht zwei Durchläufe, damit aktive Nodes (R)
    erkannt werden.
    """

    output = run_command(["pw-top", "-b", "-n", "2"])

    blocks = output.split("S   ID")

    if len(blocks) < 3:
        return "Keine aktiven PipeWire Streams."

    # letzten Messblock nehmen
    last_block = "S   ID" + blocks[-1]

    result = []

    for line in last_block.splitlines():
        # nur Running Nodes
        if not line.startswith("R"):
            continue

        parts = line.split()

        if len(parts) < 3:
            continue

        node_id = parts[1]

        # Alles nach Format/Rate Bereich als Name behalten
        match = re.search(r"(?:S16LE|S32LE|F32LE|BGRA).*?\s+(.+)$", line)

        if match:
            name = match.group(1)
        else:
            name = line

        result.append(f"{node_id:<5} {name}")

    return "\n".join(result) or "Keine aktiven Streams."


def print_box(title, content):
    lines = [line.expandtabs(4) for line in content.splitlines()] or [""]

    longest = max(
        visible_length(title),
        *(visible_length(line) for line in lines),
    )

    width = longest + 2

    CYAN = "\033[96m"
    WHITE = "\033[97m"
    RESET = "\033[0m"

    print(f"{CYAN}╔{'═' * width}╗{RESET}")

    print(f"{CYAN}║{WHITE}{title.center(width)}{CYAN}║{RESET}")

    print(f"{CYAN}╠{'═' * width}╣{RESET}")

    for line in lines:
        padding = width - visible_length(line)

        print(f"{CYAN}║{RESET}{line}{' ' * padding}{CYAN}║{RESET}")

    print(f"{CYAN}╚{'═' * width}╝{RESET}")

    print()


def command_exists(cmd):
    return shutil.which(cmd) is not None


def audio_users():
    """
    Zeigt Audio-Nutzer:
    - Hardware-Zugriff über lsof
    - Anwendungen über PipeWire Clients
    - aktive Audio Streams über wpctl
    """

    output = []

    # =========================
    # Hardware Layer (ALSA)
    # =========================

    devices = glob.glob("/dev/snd/pcm*")

    if devices:
        lsof = run_command(["lsof"] + devices)

        if lsof != "Keine Ausgabe.":
            output.append("Hardware:")
            output.append(lsof)

    # =========================
    # PipeWire Layer
    # =========================

    wpctl = run_command(["wpctl", "status"])

    # Clients
    if "Clients:" in wpctl:
        clients_section = wpctl.split("Clients:", 1)[1]

        clients_section = clients_section.split("Audio", 1)[0]

        clients = []

        for line in clients_section.splitlines():
            if "pid:" in line and "[" in line:
                clients.append(line.rstrip())

        if clients:
            output.append("")

            output.append("PipeWire Clients:")

            output.extend(clients)

    # Aktive PipeWire Streams mit Kontext
    if "Streams:" in wpctl:
        streams = wpctl.split("Streams:", 1)[1]

        stream_lines = []
        current_app = None

        for line in streams.splitlines():
            stripped = line.strip()

            # App-Zeile (z.B. Chromium, vesktop)
            if stripped and not (
                "input_" in stripped
                or "output_" in stripped
                or "<" in stripped
                or ">" in stripped
            ):
                if stripped[0].isdigit():
                    current_app = stripped

            # aktive Ports
            if (
                "input_" in stripped
                or "output_" in stripped
                or "<" in stripped
                or ">" in stripped
            ):
                if current_app:
                    stream_lines.append(current_app)
                    current_app = None

                stream_lines.append("    " + stripped)

        if stream_lines:
            output.append("")
            output.append("Active Audio Streams:")
            output.extend(stream_lines)

    return "\n".join(output) if output else "Keine Audio-Nutzer."


def main():

    print_box("PIPEWIRE STATUS", run_command(["wpctl", "status"]))

    print_box("PIPEWIRE LIVE SNAPSHOT", pw_top_snapshot())

    print_box("AUDIO HARDWARE USERS", audio_users())

    checks = [
        ("CAMERA USERS (fuser)", ["fuser", "-v", "/dev/video0", "/dev/video1"]),
        ("CAMERA USERS (lsof)", ["lsof", "/dev/video0", "/dev/video1"]),
    ]

    for title, cmd in checks:
        if not command_exists(cmd[0]):
            print_box(title, f"{cmd[0]} ist nicht installiert.")
            continue

        print_box(title, run_command(cmd))


if __name__ == "__main__":
    main()
