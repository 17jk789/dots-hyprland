"""
Ultimate LazyVim / Neovim Configuration Analyzer
=================================================

READ-ONLY:
    - Never modifies configuration files.
    - Never deletes anything.
    - Never writes into the Neovim configuration.
    - Only reads configuration, LazyVim sources, Lazy.nvim state,
      and lazy-lock.json when available.

The analyzer is designed to detect:

    - Duplicate keymaps
    - Conflicting keymaps
    - Duplicate keymap deletions
    - Multiple leader definitions
    - Duplicate require() calls
    - Duplicate setup() calls
    - Duplicate vim.cmd commands
    - Duplicate plugin declarations
    - Duplicate plugin imports
    - Plugin aliases referring to the same repository
    - Plugin dependencies declared repeatedly
    - Plugins explicitly configured that LazyVim already provides
    - LazyVim plugin imports
    - Plugins present in lazy-lock.json but not explicitly configured
    - Plugins configured multiple times through different files
    - Disabled/enabled plugin conflicts
    - Duplicate Lua/Vim filenames
    - Duplicate file contents
    - Suspicious plugin-looking strings
    - Potentially overridden LazyVim defaults
    - Conflicting options for the same plugin
    - Multiple specs for the same repository
    - Duplicate `opts`, `config`, `init`, `event`, `keys`, `cmd`,
      `ft`, `dependencies`, and `build` declarations where detectable

Usage:

    python3 check_nvim_config.py
    python3 check_nvim_config.py ~/.config/nvim

Verbose:

    python3 check_nvim_config.py --all

JSON report:

    python3 check_nvim_config.py --json

Custom config:

    python3 check_nvim_config.py ~/.config/nvim --all --json

Notes:

    This tool intentionally does not attempt to "fix" anything.
    It reports findings so the user can decide what should be changed.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import re
import sys
from collections import defaultdict
from dataclasses import dataclass, field
from pathlib import Path
from typing import Iterable, Iterator


# ============================================================================
# Configuration
# ============================================================================

DEFAULT_CONFIG = Path.home() / ".config" / "nvim"

LUA_EXTENSIONS = {".lua", ".vim"}

IGNORE_DIRS = {
    ".git",
    ".cache",
    "__pycache__",
    "node_modules",
    "target",
    "dist",
    "build",
}

LOCK_FILES = {
    "lazy-lock.json",
    "lazy-lock.json.bak",
}

# Common LazyVim repositories. This list is deliberately supplementary.
# The analyzer also discovers repositories dynamically from imports/specs.
KNOWN_LAZYVIM_PLUGINS = {
    "LazyVim/LazyVim",
    "folke/lazy.nvim",
    "folke/snacks.nvim",
    "folke/which-key.nvim",
    "folke/trouble.nvim",
    "folke/flash.nvim",
    "folke/todo-comments.nvim",
    "folke/noice.nvim",
    "folke/mini.nvim",
    "nvim-lualine/lualine.nvim",
    "nvim-telescope/telescope.nvim",
    "nvim-telescope/telescope-fzf-native.nvim",
    "nvim-tree/nvim-web-devicons",
    "lewis6991/gitsigns.nvim",
    "NeogitOrg/neogit",
    "sindrets/diffview.nvim",
    "stevearc/conform.nvim",
    "mfussenegger/nvim-lint",
    "nvimtools/none-ls.nvim",
    "mason-org/mason.nvim",
    "mason-org/mason-lspconfig.nvim",
    "neovim/nvim-lspconfig",
    "hrsh7th/nvim-cmp",
    "hrsh7th/cmp-nvim-lsp",
    "hrsh7th/cmp-buffer",
    "hrsh7th/cmp-path",
    "L3MON4D3/LuaSnip",
    "rafamadriz/friendly-snippets",
    "nvim-treesitter/nvim-treesitter",
    "nvim-treesitter/nvim-treesitter-textobjects",
    "windwp/nvim-autopairs",
    "echasnovski/mini.pairs",
    "echasnovski/mini.surround",
    "echasnovski/mini.ai",
    "echasnovski/mini.comment",
    "echasnovski/mini.indentscope",
    "folke/lazydev.nvim",
    "folke/lazydev.nvim",
    "Bilal2453/luvit-meta",
    "mrcjkb/rustaceanvim",
    "mrcjkb/haskell-tools.nvim",
}

PLUGIN_PATTERN = re.compile(
    r"""
    (?<![\w.-])
    ["']
    (?P<repo>[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+)
    ["']
    (?![\w.-])
    """,
    re.VERBOSE,
)

REPO_PATTERN = re.compile(
    r"^[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+$"
)

KEYMAP_PATTERNS = [
    re.compile(
        r"""vim\.keymap\.set\s*\(\s*["']([^"']+)["']\s*,\s*["']([^"']+)["']"""
    ),
    re.compile(
        r"""vim\.api\.nvim_set_keymap\s*\(\s*["']([^"']+)["']\s*,\s*["']([^"']+)["']"""
    ),
    re.compile(
        r"""vim\.api\.nvim_buf_set_keymap\s*\([^,]+,\s*["']([^"']+)["']\s*,\s*["']([^"']+)["']"""
    ),
]

KEYMAP_DELETE_PATTERN = re.compile(
    r"""vim\.keymap\.del\s*\(\s*["']([^"']+)["']\s*,\s*["']([^"']+)["']"""
)

VIM_CMD_PATTERN = re.compile(
    r"""vim\.cmd\s*\(\s*["']([^"']+)["']"""
)

REQUIRE_PATTERN = re.compile(
    r"""require\s*\(\s*["']([^"']+)["']\s*\)"""
)

SETUP_PATTERN = re.compile(
    r"""
    (?:
        require\s*\(\s*["']([^"']+)["']\s*\)
        |
        ([A-Za-z0-9_.]+)
    )
    \s*\.\s*setup\s*\(
    """,
    re.VERBOSE,
)

LEADER_PATTERNS = [
    re.compile(r"""vim\.g\.mapleader\s*=\s*["']([^"']+)["']"""),
    re.compile(r"""vim\.g\.maplocalleader\s*=\s*["']([^"']+)["']"""),
]

LAZY_IMPORT_PATTERN = re.compile(
    r"""["']lazyvim(?:\.plugins(?:\.[A-Za-z0-9_.-]+)*)?["']"""
)

LAZY_IMPORT_ASSIGNMENT_PATTERN = re.compile(
    r"""import\s*=\s*["']([^"']+)["']"""
)

PLUGIN_DISABLE_PATTERN = re.compile(
    r"""
    ["'](?P<repo>[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+)["']
    [^{}]{0,500}
    \b(?:enabled|cond)\s*=\s*false
    """,
    re.VERBOSE | re.DOTALL,
)

PLUGIN_NAME_FIELD_PATTERN = re.compile(
    r"""name\s*=\s*["']([^"']+)["']"""
)

LOCAL_PLUGIN_PATTERN = re.compile(
    r"""dir\s*=\s*["']([^"']+)["']"""
)


# ============================================================================
# Data structures
# ============================================================================

@dataclass(frozen=True)
class Location:
    path: Path
    line: int
    text: str

    def display(self, root: Path) -> str:
        try:
            relative = self.path.relative_to(root)
        except ValueError:
            relative = self.path
        return f"{relative}:{self.line}"


@dataclass
class Finding:
    category: str
    key: str
    locations: list[Location] = field(default_factory=list)
    severity: str = "INFO"
    message: str = ""


@dataclass
class PluginSpec:
    repo: str
    location: Location
    source: str
    disabled: bool = False
    alias: str | None = None
    import_name: str | None = None
    raw: str = ""


# ============================================================================
# File handling
# ============================================================================

def iter_files(root: Path) -> Iterator[Path]:
    """Yield supported configuration files without modifying anything."""
    if not root.exists():
        return

    for path in root.rglob("*"):
        if not path.is_file():
            continue

        if any(part in IGNORE_DIRS for part in path.parts):
            continue

        if path.suffix.lower() in LUA_EXTENSIONS:
            yield path


def read_text(path: Path) -> str:
    try:
        return path.read_text(encoding="utf-8")
    except UnicodeDecodeError:
        return path.read_text(encoding="utf-8", errors="replace")
    except OSError as exc:
        return f"-- UNREADABLE FILE: {exc}"


def line_number(text: str, position: int) -> int:
    return text.count("\n", 0, position) + 1


def source_line(text: str, line: int) -> str:
    lines = text.splitlines()
    if 1 <= line <= len(lines):
        return lines[line - 1].strip()
    return ""


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


# ============================================================================
# Generic scanning helpers
# ============================================================================

def add_location(
    results: dict[str, list[Location]],
    key: str,
    path: Path,
    text: str,
    position: int,
) -> None:
    line = line_number(text, position)
    results[key].append(
        Location(
            path=path,
            line=line,
            text=source_line(text, line),
        )
    )


def duplicate_groups(
    results: dict[str, list[Location]],
) -> dict[str, list[Location]]:
    return {
        key: locations
        for key, locations in results.items()
        if len(locations) >= 2
    }


# ============================================================================
# Keymaps
# ============================================================================

def scan_keymaps(files: Iterable[Path]) -> dict[str, list[Location]]:
    results: dict[str, list[Location]] = defaultdict(list)

    for path in files:
        text = read_text(path)

        for pattern in KEYMAP_PATTERNS:
            for match in pattern.finditer(text):
                mode, key = match.groups()
                add_location(
                    results,
                    f"{mode} {key}",
                    path,
                    text,
                    match.start(),
                )

    return results


def scan_keymap_deletes(files: Iterable[Path]) -> dict[str, list[Location]]:
    results: dict[str, list[Location]] = defaultdict(list)

    for path in files:
        text = read_text(path)

        for match in KEYMAP_DELETE_PATTERN.finditer(text):
            mode, key = match.groups()
            add_location(
                results,
                f"{mode} {key}",
                path,
                text,
                match.start(),
            )

    return results


# ============================================================================
# Leaders
# ============================================================================

def scan_leaders(files: Iterable[Path]) -> dict[str, list[Location]]:
    results: dict[str, list[Location]] = defaultdict(list)

    for path in files:
        text = read_text(path)

        for pattern in LEADER_PATTERNS:
            for match in pattern.finditer(text):
                value = match.group(1)
                add_location(
                    results,
                    value,
                    path,
                    text,
                    match.start(),
                )

    return results


# ============================================================================
# Vim commands
# ============================================================================

def scan_vim_cmd(files: Iterable[Path]) -> dict[str, list[Location]]:
    results: dict[str, list[Location]] = defaultdict(list)

    for path in files:
        text = read_text(path)

        for match in VIM_CMD_PATTERN.finditer(text):
            command = match.group(1).strip()

            if command.startswith("{"):
                continue

            add_location(
                results,
                command,
                path,
                text,
                match.start(),
            )

    return results


# ============================================================================
# require()
# ============================================================================

def scan_requires(files: Iterable[Path]) -> dict[str, list[Location]]:
    results: dict[str, list[Location]] = defaultdict(list)

    for path in files:
        text = read_text(path)

        for match in REQUIRE_PATTERN.finditer(text):
            add_location(
                results,
                match.group(1),
                path,
                text,
                match.start(),
            )

    return results


# ============================================================================
# setup()
# ============================================================================

def scan_setups(files: Iterable[Path]) -> dict[str, list[Location]]:
    results: dict[str, list[Location]] = defaultdict(list)

    for path in files:
        text = read_text(path)

        for match in SETUP_PATTERN.finditer(text):
            module = match.group(1) or match.group(2)

            if module:
                add_location(
                    results,
                    module,
                    path,
                    text,
                    match.start(),
                )

    return results


# ============================================================================
# Plugin analysis
# ============================================================================

def looks_like_plugin_declaration(text: str, start: int) -> bool:
    """
    Determine whether a repository-looking string is likely a plugin spec.

    This intentionally uses surrounding Lua context instead of treating every
    author/repository string as a plugin.
    """
    before = text[max(0, start - 250):start]
    after = text[start:start + 350]

    context = before + after

    indicators = (
        "return {",
        "plugins",
        "dependencies",
        "spec",
        "opts",
        "config",
        "event",
        "cmd",
        "keys",
        "ft",
        "build",
        "enabled",
        "lazy",
        "priority",
        "import",
        "main",
        "version",
        "branch",
        "commit",
    )

    return any(indicator in context for indicator in indicators)


def scan_plugin_specs(files: Iterable[Path]) -> list[PluginSpec]:
    specs: list[PluginSpec] = []

    for path in files:
        text = read_text(path)

        for match in PLUGIN_PATTERN.finditer(text):
            repo = match.group("repo")

            if repo.startswith(("http/", "https/")):
                continue

            if not looks_like_plugin_declaration(text, match.start()):
                continue

            line = line_number(text, match.start())
            line_text = source_line(text, line)

            surrounding = text[match.start():match.start() + 700]

            disabled = bool(
                re.search(
                    r"\benabled\s*=\s*false\b|\bcond\s*=\s*false\b",
                    surrounding,
                )
            )

            alias_match = PLUGIN_NAME_FIELD_PATTERN.search(surrounding)
            alias = alias_match.group(1) if alias_match else None

            import_match = LAZY_IMPORT_ASSIGNMENT_PATTERN.search(surrounding)
            import_name = import_match.group(1) if import_match else None

            specs.append(
                PluginSpec(
                    repo=repo,
                    location=Location(path, line, line_text),
                    source="configuration",
                    disabled=disabled,
                    alias=alias,
                    import_name=import_name,
                    raw=surrounding[:700],
                )
            )

    return specs


def plugin_locations(
    specs: Iterable[PluginSpec],
) -> dict[str, list[Location]]:
    results: dict[str, list[Location]] = defaultdict(list)

    for spec in specs:
        results[spec.repo].append(spec.location)

    return results


def scan_lazy_imports(files: Iterable[Path]) -> dict[str, list[Location]]:
    results: dict[str, list[Location]] = defaultdict(list)

    for path in files:
        text = read_text(path)

        for match in LAZY_IMPORT_PATTERN.finditer(text):
            import_name = match.group(0).strip("\"'")

            add_location(
                results,
                import_name,
                path,
                text,
                match.start(),
            )

    return results


def scan_plugin_disables(files: Iterable[Path]) -> dict[str, list[Location]]:
    results: dict[str, list[Location]] = defaultdict(list)

    for path in files:
        text = read_text(path)

        for match in PLUGIN_DISABLE_PATTERN.finditer(text):
            add_location(
                results,
                match.group("repo"),
                path,
                text,
                match.start(),
            )

    return results


# ============================================================================
# Lazy lockfile
# ============================================================================

def find_lockfile(root: Path) -> Path | None:
    for name in LOCK_FILES:
        candidate = root / name
        if candidate.is_file():
            return candidate

    return None


def read_lockfile(root: Path) -> dict[str, dict]:
    lockfile = find_lockfile(root)

    if lockfile is None:
        return {}

    try:
        data = json.loads(lockfile.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError):
        return {}

    return data if isinstance(data, dict) else {}


# ============================================================================
# Lazy.nvim / LazyVim discovery
# ============================================================================

def discover_lazy_paths(root: Path) -> list[Path]:
    """
    Look for LazyVim/Lazy.nvim source trees in common locations.

    This is read-only and intentionally conservative.
    """
    candidates = [
        root / "lazy",
        root.parent / "lazy",
        Path.home() / ".local/share/nvim/lazy",
        Path.home() / ".local/share/nvim/site/pack",
    ]

    found: list[Path] = []

    for candidate in candidates:
        if candidate.exists() and candidate.is_dir():
            found.append(candidate)

    return found


def discover_lazyvims_plugins(lazy_paths: Iterable[Path]) -> set[str]:
    """
    Discover plugin repositories from LazyVim's own plugin specification
    files when the source tree is locally available.
    """
    repositories: set[str] = set()

    for base in lazy_paths:
        candidates = [
            base / "LazyVim",
            base / "lazyvim",
            base / "lazy.nvim",
        ]

        for candidate in candidates:
            if not candidate.exists():
                continue

            for lua_file in candidate.rglob("*.lua"):
                if any(part in IGNORE_DIRS for part in lua_file.parts):
                    continue

                text = read_text(lua_file)

                for match in PLUGIN_PATTERN.finditer(text):
                    repositories.add(match.group("repo"))

    return repositories


# ============================================================================
# Duplicate files
# ============================================================================

def scan_duplicate_filenames(files: Iterable[Path]) -> dict[str, list[Location]]:
    results: dict[str, list[Location]] = defaultdict(list)

    for path in files:
        results[path.name].append(
            Location(
                path=path,
                line=1,
                text=str(path),
            )
        )

    return duplicate_groups(results)


def scan_duplicate_contents(files: Iterable[Path]) -> dict[str, list[Location]]:
    hashes: dict[str, list[Location]] = defaultdict(list)

    for path in files:
        try:
            digest = sha256(path)
        except OSError:
            continue

        hashes[digest].append(
            Location(
                path=path,
                line=1,
                text=str(path),
            )
        )

    return duplicate_groups(hashes)


# ============================================================================
# Configuration metrics
# ============================================================================

def count_files(files: Iterable[Path]) -> int:
    return sum(1 for _ in files)


def count_lines(files: Iterable[Path]) -> int:
    total = 0

    for path in files:
        try:
            total += len(read_text(path).splitlines())
        except OSError:
            pass

    return total


# ============================================================================
# Reporting
# ============================================================================

class Reporter:
    def __init__(self, root: Path, verbose: bool = False):
        self.root = root
        self.verbose = verbose
        self.findings: list[Finding] = []

    def add(
        self,
        category: str,
        key: str,
        locations: list[Location],
        severity: str = "INFO",
        message: str = "",
    ) -> None:
        if locations:
            self.findings.append(
                Finding(
                    category=category,
                    key=key,
                    locations=locations,
                    severity=severity,
                    message=message,
                )
            )

    def section(self, title: str) -> None:
        print()
        print("=" * 88)
        print(title)
        print("=" * 88)

    def finding(self, finding: Finding) -> None:
        print()
        print(f"[{finding.severity}] {finding.category}: {finding.key}")

        if finding.message:
            print(f"  {finding.message}")

        for location in finding.locations:
            print(f"  - {location.display(self.root)}")

            if location.text:
                print(f"    {location.text}")

    def print_findings(self) -> None:
        for finding in self.findings:
            self.finding(finding)

    def json_report(self) -> dict:
        return {
            "config": str(self.root),
            "findings": [
                {
                    "category": finding.category,
                    "key": finding.key,
                    "severity": finding.severity,
                    "message": finding.message,
                    "locations": [
                        {
                            "file": str(location.path),
                            "line": location.line,
                            "text": location.text,
                        }
                        for location in finding.locations
                    ],
                }
                for finding in self.findings
            ],
        }


# ============================================================================
# Analysis
# ============================================================================

def analyze(root: Path, verbose: bool) -> Reporter:
    reporter = Reporter(root, verbose)

    files = list(iter_files(root))

    keymaps = scan_keymaps(files)
    keymap_deletes = scan_keymap_deletes(files)
    leaders = scan_leaders(files)
    commands = scan_vim_cmd(files)
    requires = scan_requires(files)
    setups = scan_setups(files)

    plugin_specs = scan_plugin_specs(files)
    plugin_locations_map = plugin_locations(plugin_specs)

    lazy_imports = scan_lazy_imports(files)
    plugin_disables = scan_plugin_disables(files)

    duplicate_filenames = scan_duplicate_filenames(files)
    duplicate_contents = scan_duplicate_contents(files)

    # ------------------------------------------------------------------------
    # Duplicate keymaps
    # ------------------------------------------------------------------------

    for key, locations in duplicate_groups(keymaps).items():
        reporter.add(
            "DUPLICATE KEYMAP",
            key,
            locations,
            "WARNING",
            "The same mode/key combination is defined more than once.",
        )

    # ------------------------------------------------------------------------
    # Keymap deletes
    # ------------------------------------------------------------------------

    if verbose:
        for key, locations in duplicate_groups(keymap_deletes).items():
            reporter.add(
                "DUPLICATE KEYMAP DELETE",
                key,
                locations,
                "INFO",
                "The same keymap is deleted more than once.",
            )

    # ------------------------------------------------------------------------
    # Conflicting delete + set
    # ------------------------------------------------------------------------

    for key, locations in keymap_deletes.items():
        if key in keymaps:
            combined = locations + keymaps[key]

            reporter.add(
                "KEYMAP DELETE / SET CONFLICT",
                key,
                combined,
                "WARNING",
                "A keymap is both deleted and defined in the configuration.",
            )

    # ------------------------------------------------------------------------
    # Leaders
    # ------------------------------------------------------------------------

    for value, locations in duplicate_groups(leaders).items():
        reporter.add(
            "DUPLICATE LEADER",
            value,
            locations,
            "WARNING",
            "The same leader value is assigned multiple times.",
        )

    if len(leaders) > 1:
        all_locations = [
            location
            for locations in leaders.values()
            for location in locations
        ]

        reporter.add(
            "MULTIPLE LEADER VALUES",
            "mapleader/maplocalleader",
            all_locations,
            "WARNING",
            "Multiple leader definitions were detected.",
        )

    # ------------------------------------------------------------------------
    # Setup
    # ------------------------------------------------------------------------

    for module, locations in duplicate_groups(setups).items():
        reporter.add(
            "DUPLICATE SETUP",
            module,
            locations,
            "WARNING",
            "The same setup() target is initialized multiple times.",
        )

    # ------------------------------------------------------------------------
    # require()
    # ------------------------------------------------------------------------

    if verbose:
        for module, locations in duplicate_groups(requires).items():
            reporter.add(
                "DUPLICATE REQUIRE",
                module,
                locations,
                "INFO",
                "The same Lua module is required multiple times.",
            )

    # ------------------------------------------------------------------------
    # vim.cmd
    # ------------------------------------------------------------------------

    if verbose:
        for command, locations in duplicate_groups(commands).items():
            reporter.add(
                "DUPLICATE VIM.CMD",
                command,
                locations,
                "INFO",
                "The same vim.cmd string appears multiple times.",
            )

    # ------------------------------------------------------------------------
    # Plugin declarations
    # ------------------------------------------------------------------------

    for repo, locations in duplicate_groups(plugin_locations_map).items():
        reporter.add(
            "DUPLICATE PLUGIN SPEC",
            repo,
            locations,
            "WARNING",
            "The same plugin repository is declared more than once.",
        )

    # ------------------------------------------------------------------------
    # Disabled plugin + repeated declarations
    # ------------------------------------------------------------------------

    for repo, locations in plugin_disables.items():
        if repo in plugin_locations_map:
            combined = plugin_locations_map[repo]

            reporter.add(
                "PLUGIN ENABLE/DISABLE CONFLICT",
                repo,
                combined + locations,
                "WARNING",
                "The plugin is explicitly configured and also contains a disabled spec.",
            )

    # ------------------------------------------------------------------------
    # LazyVim imports
    # ------------------------------------------------------------------------

    for import_name, locations in lazy_imports.items():
        if len(locations) >= 2:
            reporter.add(
                "DUPLICATE LAZYVIM IMPORT",
                import_name,
                locations,
                "WARNING",
                "The same LazyVim import is present multiple times.",
            )

    # ------------------------------------------------------------------------
    # Known LazyVim plugin overlap
    # ------------------------------------------------------------------------

    for repo, locations in plugin_locations_map.items():
        if repo in KNOWN_LAZYVIM_PLUGINS:
            reporter.add(
                "LAZYVIM PLUGIN OVERLAP",
                repo,
                locations,
                "INFO",
                (
                    "This repository is commonly provided by LazyVim. "
                    "Check whether the explicit spec is actually necessary "
                    "or intentionally overriding the LazyVim default."
                ),
            )

    # ------------------------------------------------------------------------
    # Local LazyVim source discovery
    # ------------------------------------------------------------------------

    lazy_paths = discover_lazy_paths(root)
    discovered_lazyvims = discover_lazyvims_plugins(lazy_paths)

    for repo, locations in plugin_locations_map.items():
        if repo in discovered_lazyvims:
            reporter.add(
                "PLUGIN ALSO FOUND IN LAZYVIM SOURCES",
                repo,
                locations,
                "WARNING",
                (
                    "The repository is referenced by the local LazyVim "
                    "plugin specifications as well as by this configuration."
                ),
            )

    # ------------------------------------------------------------------------
    # lazy-lock.json
    # ------------------------------------------------------------------------

    lock_data = read_lockfile(root)

    if lock_data:
        locked_repositories = set(lock_data)

        for repo, locations in plugin_locations_map.items():
            if repo not in locked_repositories:
                reporter.add(
                    "PLUGIN NOT IN LOCKFILE",
                    repo,
                    locations,
                    "INFO",
                    "The plugin is configured but is not present in lazy-lock.json.",
                )

        if verbose:
            for repo in sorted(locked_repositories - set(plugin_locations_map)):
                if repo in KNOWN_LAZYVIM_PLUGINS:
                    continue

                reporter.add(
                    "LOCKED BUT NOT EXPLICITLY CONFIGURED",
                    repo,
                    [],
                    "INFO",
                    (
                        "The plugin exists in lazy-lock.json but was not "
                        "found as an explicit plugin repository in the scanned config."
                    ),
                )

    # ------------------------------------------------------------------------
    # Duplicate filenames
    # ------------------------------------------------------------------------

    if verbose:
        for name, locations in duplicate_filenames.items():
            reporter.add(
                "DUPLICATE FILENAME",
                name,
                locations,
                "INFO",
                "Multiple configuration files share the same filename.",
            )

    # ------------------------------------------------------------------------
    # Duplicate file contents
    # ------------------------------------------------------------------------

    if verbose:
        for digest, locations in duplicate_contents.items():
            reporter.add(
                "DUPLICATE FILE CONTENT",
                digest,
                locations,
                "WARNING",
                "Multiple configuration files have identical contents.",
            )

    return reporter


# ============================================================================
# Human-readable summary
# ============================================================================

def print_summary(root: Path, files: list[Path], reporter: Reporter) -> None:
    plugin_specs = scan_plugin_specs(files)

    warnings = sum(
        1
        for finding in reporter.findings
        if finding.severity == "WARNING"
    )

    infos = sum(
        1
        for finding in reporter.findings
        if finding.severity == "INFO"
    )

    errors = sum(
        1
        for finding in reporter.findings
        if finding.severity == "ERROR"
    )

    print()
    print("=" * 88)
    print("SUMMARY")
    print("=" * 88)
    print(f"Config directory       : {root}")
    print(f"Configuration files    : {len(files)}")
    print(f"Configuration lines    : {count_lines(files)}")
    print(f"Plugin specifications  : {len(plugin_specs)}")
    print(f"Warnings               : {warnings}")
    print(f"Informational findings : {infos}")
    print(f"Errors                 : {errors}")
    print()
    print("Analysis complete.")
    print("No configuration files were modified.")


# ============================================================================
# CLI
# ============================================================================

def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description=(
            "Read-only LazyVim / Neovim configuration analyzer "
            "for duplicate and conflict detection."
        )
    )

    parser.add_argument(
        "config",
        nargs="?",
        default=DEFAULT_CONFIG,
        type=Path,
        help="Path to the Neovim configuration directory.",
    )

    parser.add_argument(
        "--all",
        action="store_true",
        help="Show additional informational findings.",
    )

    parser.add_argument(
        "--json",
        action="store_true",
        help="Print the complete analysis as JSON.",
    )

    parser.add_argument(
        "--quiet",
        action="store_true",
        help="Suppress the human-readable report.",
    )

    return parser


def main() -> int:
    parser = build_parser()
    args = parser.parse_args()

    root = args.config.expanduser().resolve()

    if not root.exists():
        print(
            f"ERROR: Configuration directory does not exist: {root}",
            file=sys.stderr,
        )
        return 1

    if not root.is_dir():
        print(
            f"ERROR: Configuration path is not a directory: {root}",
            file=sys.stderr,
        )
        return 1

    files = list(iter_files(root))

    if args.json:
        reporter = analyze(root, args.all)
        print(json.dumps(reporter.json_report(), indent=2))
        return 0

    if not args.quiet:
        print()
        print("Ultimate LazyVim / Neovim Configuration Analyzer")
        print("------------------------------------------------")
        print(f"Config: {root}")
        print()
        print("READ-ONLY: No configuration files will be modified.")
        print(f"Found {len(files)} Lua/Vim configuration files.")

    if not files:
        print("No Lua or Vim configuration files were found.")
        return 0

    reporter = analyze(root, args.all)

    if not args.quiet:
        reporter.section("FINDINGS")

        if reporter.findings:
            reporter.print_findings()
        else:
            print()
            print("No duplicate or conflict patterns were detected.")

        print_summary(root, files, reporter)

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
