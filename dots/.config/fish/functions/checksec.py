#!/usr/bin/env python3

import subprocess
import sys
import os
import re

DISPLAY_NAMES = {
    "relro": "RELRO",
    "canary": "Stack Canary",
    "cfi": "CFI",
    "nx": "NX",
    "pie": "PIE",
    "rpath": "RPATH",
    "runpath": "RUNPATH",
    "symbols": "Symbols",
    "safestack": "SafeStack",
    "stack_clash": "Stack Clash",
    "wx": "W^X Seg",
    "w_x": "W^X Seg",
    "separate_code": "Separate Code (W^X Seg)",
    "selfrando": "Selfrando",
    "sanitizers": "Sanitizers",
    "fortify_level": "FORTIFY Lvl",
    "glibcxx_assert": "GLIBCXX Assert",
    "fortify_source": "FORTIFY",
    "fortified": "Fortified",
    "fortifyable": "Fortifiable",
}


RESET = "\033[0m"
BOLD = "\033[1m"


COLORS = {
    "green": "\033[92m",
    "red": "\033[91m",
    "yellow": "\033[93m",
    "unset": "\033[90m",
    "cyan": "\033[96m",
    "blue": "\033[94m",
}


def strip_color(s):
    return re.sub(r"\033\[[0-9;]*m", "", s)


def colorize(status, value):

    icons = {"green": "✓", "red": "✗", "yellow": "⚠", "unset": "•"}

    return (
        COLORS.get(status, COLORS["unset"])
        + icons.get(status, "•")
        + " "
        + value
        + RESET
    )


def is_elf(path):

    try:
        with open(path, "rb") as f:
            return f.read(4) == b"\x7fELF"

    except:
        return False


def parse_yaml(text):

    checks = {}
    name = ""

    current = None

    for line in text.splitlines():
        line = line.rstrip()

        if line.startswith("  name:"):
            name = line.split(":", 1)[1].strip()
            continue

        m = re.match(r"    (\w+):", line)

        if m:
            current = m.group(1)
            checks[current] = {}
            continue

        if current:
            m = re.match(r"      (status|value): (.*)", line)

            if m:
                key, val = m.groups()

                checks[current][key] = val.strip('"')

    return checks, name


def check_file(path):

    try:
        out = subprocess.check_output(
            ["/usr/bin/checksec", "file", path, "--output", "yaml"], text=True
        )

    except subprocess.CalledProcessError:
        return

    checks, name = parse_yaml(out)

    render(checks, name)


def render(checks, name):

    print()

    print(COLORS["cyan"] + BOLD + "CHECKSEC ANALYSE: " + name + RESET)

    order = list(checks.keys())

    items = []

    for key in order:
        item = checks[key]

        title = DISPLAY_NAMES.get(key, key.replace("_", " ").title())

        items.append(
            (title, colorize(item.get("status", "unset"), item.get("value", "")))
        )

    items.append(("Name", name))

    width1 = max(len(x[0]) for x in items)

    width2 = max(len(strip_color(x[1])) for x in items)

    line = lambda a, b, c: a + "─" * (width1 + 2) + b + "─" * (width2 + 2) + c

    print(COLORS["blue"] + line("┌", "┬", "┐") + RESET)

    for i, (a, b) in enumerate(items):
        print(
            "│ "
            + BOLD
            + a.ljust(width1)
            + RESET
            + " │ "
            + b
            + " " * (width2 - len(strip_color(b)))
            + " │"
        )

        if i != len(items) - 1:
            print(COLORS["blue"] + line("├", "┼", "┤") + RESET)

    print(COLORS["blue"] + line("└", "┴", "┘") + RESET)


def scan_dir(directory):

    print(COLORS["cyan"] + BOLD + "Durchsuche:" + RESET, directory)

    for root, dirs, files in os.walk(directory):
        for f in files:
            path = os.path.join(root, f)

            if is_elf(path):
                print(COLORS["yellow"] + "\n▶ " + path + RESET)

                check_file(path)


def main():

    args = sys.argv[1:]

    if not args:
        print("jecksec file <binary>")
        print("jecksec dir <directory>")

        sys.exit(1)

    if args[0] == "file":
        check_file(args[1])
        return

    if args[0] == "dir":
        scan_dir(args[1])
        return

    target = args[0]

    if os.path.isfile(target):
        check_file(target)

    elif os.path.isdir(target):
        scan_dir(target)

    else:
        print("Nicht gefunden:", target)


if __name__ == "__main__":
    main()
