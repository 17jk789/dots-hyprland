# ============================================================
#
# Fish configuration — C Security Research
#
# Arch Linux
# C23
# GCC / Clang
# clangd
# CMake
# GDB / Pwndbg
# LLDB / CodeLLDB
# ELF / DWARF analysis
# ASan / UBSan / MSan / TSan
# Valgrind
# Static analysis
#
# Intended for C development, debugging and authorized
# defensive/security research.
#
# ============================================================


# ============================================================
# ENVIRONMENT
# ============================================================

set -gx EDITOR nvim
set -gx VISUAL nvim

set -gx PAGER less
set -gx MANPAGER 'less -R'

set -gx analysis_results

# User binaries
fish_add_path $HOME/.local/bin
fish_add_path $HOME/bin

# LLVM tools
if test -d /usr/lib/llvm/bin
    fish_add_path /usr/lib/llvm/bin
end

# Optional LLVM tools installed elsewhere
if test -d /usr/lib/llvm
    set -gx LLVM_DIR /usr/lib/llvm
end


# ============================================================
# FISH
# ============================================================

set -g fish_greeting ""

function reload
    source ~/.config/fish/config.fish
    echo "Fish configuration reloaded."
end


# ============================================================
# BASIC SHELL
# ============================================================

alias v nvim
alias vi nvim

alias ll 'ls -lah'
alias la 'ls -la'
alias l 'ls -lah'

alias c clear
alias cls clear

alias .. 'cd ..'
alias ... 'cd ../..'
alias .... 'cd ../../..'

alias q exit


# ============================================================
# GIT
# ============================================================

alias gs 'git status'
alias ga 'git add'
alias gc 'git commit'
alias gp 'git push'
alias gl 'git log --oneline --graph --decorate --all'


# ============================================================
# CMAKE
# ============================================================

alias cm cmake

function c-config
    cmake -S . -B build \
        -DCMAKE_BUILD_TYPE=Debug \
        -DCMAKE_EXPORT_COMPILE_COMMANDS=ON

    if test $status -ne 0
        return 1
    end

    # Make clangd database available at project root.
    if test -e build/compile_commands.json
        if test -L compile_commands.json
            rm compile_commands.json
        else if test -e compile_commands.json
            rm compile_commands.json
        end

        ln -s build/compile_commands.json compile_commands.json
    end
end


function c-build
    if not test -d build
        echo "No build directory."
        echo "Run: c-config"
        return 1
    end

    cmake --build build --parallel
end


function c-rebuild
    if test -d build
        rm -rf build
    end

    c-config
    or return 1

    c-build
end


function c-clean
    if test -d build
        rm -rf build
    end

    if test -d build-asan
        rm -rf build-asan
    end

    if test -d build-ubsan
        rm -rf build-ubsan
    end

    if test -d build-msan
        rm -rf build-msan
    end

    if test -d build-tsan
        rm -rf build-tsan
    end

    if test -d build-release
        rm -rf build-release
    end

    if test -L compile_commands.json
        rm compile_commands.json
    end

    echo "C build directories cleaned."
end


function c-test
    if not test -d build
        echo "No build directory."
        echo "Run: c-config"
        return 1
    end

    ctest --test-dir build --output-on-failure
end


function c-check
    c-build
    or return 1

    c-test
    or return 1

    if command -q clang-tidy
        cmake --build build --target analyze-clang-tidy
        or return 1
    end

    if command -q cppcheck
        cmake --build build --target analyze-cppcheck
        or return 1
    end

    echo "Security/quality checks completed."
end


function c-debug
    c-config
    or return 1

    c-build
end


# ============================================================
# DIRECT GCC C23 DEBUG BUILD
#
# Usage:
#   gcc-debug source.c -o app
# ============================================================

function gcc-debug
    if test (count $argv) -eq 0
        echo "Usage: gcc-debug <source.c> [-o output]"
        return 1
    end

    gcc \
        -std=c23 \
        -O0 \
        -g3 \
        -fno-omit-frame-pointer \
        -Wall \
        -Wextra \
        -Wpedantic \
        -Wconversion \
        -Wsign-conversion \
        -Wshadow \
        -Wformat=2 \
        -Wformat-overflow=2 \
        -Wformat-truncation=2 \
        -Wundef \
        -Wstrict-prototypes \
        -Wmissing-prototypes \
        -Wold-style-definition \
        -Wvla \
        -Wdouble-promotion \
        -Wnull-dereference \
        $argv
end


# ============================================================
# DIRECT CLANG C23 DEBUG BUILD
# ============================================================

function clang-debug
    if test (count $argv) -eq 0
        echo "Usage: clang-debug <source.c> [-o output]"
        return 1
    end

    clang \
        -std=c23 \
        -O0 \
        -g3 \
        -fno-omit-frame-pointer \
        -Wall \
        -Wextra \
        -Wpedantic \
        -Wconversion \
        -Wsign-conversion \
        -Wshadow \
        -Wformat=2 \
        -Wundef \
        -Wstrict-prototypes \
        -Wmissing-prototypes \
        -Wold-style-definition \
        -Wnull-dereference \
        $argv
end


# ============================================================
# GCC STATIC ANALYSIS
# ============================================================

function gcc-check
    if test (count $argv) -eq 0
        echo "Usage: gcc-check <source.c> [arguments...]"
        return 1
    end

    if not command -q gcc
        echo "Error: gcc not found. Install it with: sudo apt install gcc"
        return 1
    end

    echo "▶ GCC comprehensive static check..."
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    gcc \
        -std=c23 \
        -O0 \
        -g3 \
        -Wall \
        -Wextra \
        -Wpedantic \
        -Wconversion \
        -Wsign-conversion \
        -Wshadow \
        -Wformat=2 \
        -Wformat-overflow=2 \
        -Wformat-truncation=2 \
        -Wformat-security \
        -Warray-bounds=2 \
        -Warray-parameter=2 \
        -Wstringop-overflow=4 \
        -Wstringop-overread \
        -Wstringop-truncation \
        -Wrestrict \
        -Wnonnull \
        -Wnonnull-compare \
        -Walloca \
        -Wvla \
        -Wvla-larger-than=4096 \
        -Wnull-dereference \
        -Wuse-after-free=3 \
        -Wfree-nonheap-object \
        -Wmismatched-dealloc \
        -Wstrict-prototypes \
        -Wmissing-prototypes \
        -Wmissing-declarations \
        -Wold-style-definition \
        -Wold-style-declaration \
        -Wduplicated-cond \
        -Wduplicated-branches \
        -Wlogical-op \
        -Wlogical-not-parentheses \
        -Wshift-overflow=2 \
        -Wshift-negative-value \
        -Wshift-count-negative \
        -Wshift-count-overflow \
        -Wpointer-arith \
        -Wcast-align=strict \
        -Wcast-qual \
        -Wwrite-strings \
        -Wtrampolines \
        -Wdate-time \
        -Wstack-protector \
        -Wstack-usage=4096 \
        -Wlarger-than=4096 \
        -Wstrict-overflow=5 \
        -Wtype-limits \
        -Wundef \
        -Wunused \
        -Wunused-function \
        -Wunused-variable \
        -Wunused-parameter \
        -Wunused-value \
        -Wunused-but-set-variable \
        -Wunused-but-set-parameter \
        -Wuninitialized \
        -Wmaybe-uninitialized \
        -Wfloat-equal \
        -Wdouble-promotion \
        -Wswitch \
        -Wswitch-enum \
        -Wswitch-default \
        -Wswitch-unreachable \
        -Wreturn-type \
        -Wimplicit-function-declaration \
        -Wimplicit-fallthrough \
        -Wmissing-braces \
        -Wparentheses \
        -Wsequence-point \
        -Wstrict-aliasing=3 \
        -Wtrigraphs \
        -Wunknown-pragmas \
        -Werror=implicit-function-declaration \
        -Werror=incompatible-pointer-types \
        -Werror=return-type \
        -Werror=format-security \
        -Werror=implicit-int \
        -Werror=int-conversion \
        -fanalyzer \
        -Wanalyzer-too-complex \
        -Wanalyzer-null-dereference \
        -Wanalyzer-use-after-free \
        -Wanalyzer-double-free \
        -Wanalyzer-free-of-non-heap \
        -Wanalyzer-malloc-leak \
        -Wanalyzer-possible-null-dereference \
        -Wanalyzer-possible-null-argument \
        -Wanalyzer-null-argument \
        -Wanalyzer-unsafe-call-within-signal-handler \
        -Wanalyzer-tainted-array-index \
        -Wanalyzer-tainted-offset \
        -Wanalyzer-tainted-size \
        -Wanalyzer-tainted-divisor \
        -Wanalyzer-out-of-bounds \
        -Wanalyzer-overlapping-buffers \
        -Wanalyzer-stale-setjmp-buffer \
        -Wanalyzer-jump-through-null \
        -Wanalyzer-infinite-loop \
        -Wanalyzer-write-to-const \
        -Wanalyzer-use-of-pointer-in-stale-stack-frame \
        -fno-common \
        -fstack-protector-strong \
        -fstack-clash-protection \
        -fno-omit-frame-pointer \
        -fstrict-flex-arrays=3 \
        -fdiagnostics-show-option \
        -fdiagnostics-show-caret \
        -fdiagnostics-show-line-numbers \
        -fdiagnostics-show-context=2 \
        -fmax-errors=0 \
        $argv

    set status_code $status

    echo ""
    echo "▶ Result"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    set msg_ok "✓ GCC compiler + static analyzer: OK"
    set msg_err "✗ GCC compiler + static analyzer: ISSUES FOUND"

    if test $status_code -eq 0
        if not string match -q "$msg_ok" $analysis_results
            echo "$msg_ok"
            set analysis_results $analysis_results $msg_ok
        else
            echo "✓ GCC compiler + static analyzer: OK (bereits protokolliert)"
        end
    else
        if not string match -q "$msg_err" $analysis_results
            echo "$msg_err"
            set analysis_results $analysis_results $msg_err
        else
            echo "✗ GCC compiler + static analyzer: ISSUES FOUND (bereits protokolliert)"
        end
    end

    return $status_code
end

# ============================================================
# CLANG STATIC ANALYSIS
# ============================================================

function clang-check
    if test (count $argv) -eq 0
        echo "Usage: clang-check <source.c> [arguments...]"
        return 1
    end

    if not command -q clang
        echo "Error: clang not found. Install it with: sudo apt install clang"
        return 1
    end

    echo "▶ Clang comprehensive static check..."
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    clang \
        -std=c23 \
        -O0 \
        -g3 \
        -Weverything \
        -Werror=implicit-function-declaration \
        -Werror=incompatible-pointer-types \
        -Werror=return-type \
        -Werror=format-security \
        -Wconversion \
        -Wsign-conversion \
        -Wshadow \
        -Wformat=2 \
        -Wformat-security \
        -Wnull-dereference \
        -Warray-bounds \
        -Warray-parameter \
        -Wconditional-uninitialized \
        -Wuninitialized \
        -Wtautological-compare \
        -Wtautological-constant-out-of-range-compare \
        -Wunreachable-code \
        -Wunreachable-code-aggressive \
        -Wpointer-arith \
        -Wcast-align \
        -Wcast-qual \
        -Wwrite-strings \
        -Wswitch \
        -Wswitch-enum \
        -Wswitch-default \
        -Wstrict-prototypes \
        -Wmissing-prototypes \
        -Wmissing-variable-declarations \
        -Wold-style-definition \
        -Wundef \
        -Wvla \
        -Wvla-extension \
        -Walloca \
        -Wfloat-equal \
        -Wdouble-promotion \
        -Wcomma \
        -Wextra-semi \
        -Wcovered-switch-default \
        -Wloop-analysis \
        -Wrange-loop-analysis \
        -Wimplicit-fallthrough \
        -Wdeprecated \
        -Wdeprecated-declarations \
        -Wdocumentation \
        -Wframe-larger-than=4096 \
        -fno-common \
        -fstack-protector-strong \
        -fstack-clash-protection \
        -fno-omit-frame-pointer \
        $argv

    set compile_status $status

    echo ""
    echo "▶ Clang Static Analyzer..."
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    clang \
        --analyze \
        -std=c23 \
        -Weverything \
        -Wconversion \
        -Wsign-conversion \
        -Wshadow \
        -Wnull-dereference \
        -Warray-bounds \
        -Warray-parameter \
        -Wconditional-uninitialized \
        -Wuninitialized \
        -Wtautological-compare \
        -Wtautological-constant-out-of-range-compare \
        -Wunreachable-code \
        -Wunreachable-code-aggressive \
        -Wpointer-arith \
        -Wcast-align \
        -Wcast-qual \
        -Wswitch \
        -Wswitch-enum \
        -Wswitch-default \
        -Wstrict-prototypes \
        -Wmissing-prototypes \
        -Wmissing-variable-declarations \
        -Wold-style-definition \
        -Wvla \
        -Walloca \
        -Wfloat-equal \
        -Wdouble-promotion \
        -Wundef \
        -Wimplicit-fallthrough \
        -Xanalyzer -analyzer-checker=core \
        -Xanalyzer -analyzer-checker=deadcode \
        -Xanalyzer -analyzer-checker=security \
        -Xanalyzer -analyzer-checker=unix \
        $argv

    set analyzer_status $status

    echo ""
    echo "▶ Result"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    if test $compile_status -eq 0
        set msg "✓ Clang compiler checks: OK"
    else
        set msg "✗ Clang compiler checks: FAILED"
    end
    echo "$msg"
    if not string match -q "$msg" $analysis_results
        set analysis_results $analysis_results $msg
    end

    if test $analyzer_status -eq 0
        set msg "✓ Clang Static Analyzer: OK"
    else
        set msg "✗ Clang Static Analyzer: ISSUES FOUND"
    end
    echo "$msg"
    if not string match -q "$msg" $analysis_results
        set analysis_results $analysis_results $msg
    end

    if test $compile_status -ne 0; or test $analyzer_status -ne 0
        return 1
    end

    return 0
end

# ============================================================
# COMPREHENSIVE ANALYSIS
# ============================================================

function c-analyze
    set -l files $argv
    set -l start_time (date +%s)
    set -l result_file /tmp/c-analyze-results.txt
    rm -f $result_file
    touch $result_file

    if test (count $files) -eq 0
        if test -d src
            set files src/*.c
        else
            echo "Error: No source files specified and src/ directory not found"
            return 1
        end
    end

    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║         COMPREHENSIVE C CODE ANALYSIS                      ║"
    echo "╚════════════════════════════════════════════════════════════╝"
    echo ""
    echo "Files: $files"
    echo ""

    set -l gcc_issues 0
    set -l clang_issues 0
    set -l tidy_issues 0
    set -l cppcheck_issues 0
    set -l flawfinder_issues 0
    set -l splint_issues 0

    echo "▶ GCC Static Analyzer..."
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    gcc-check $files 2>&1
    gcc-check $files 2>&1 | tee /tmp/gcc-output.txt >/dev/null
    set gcc_issues (grep -c -E "error:|warning:" /tmp/gcc-output.txt 2>/dev/null)

    if test $status -ne 0
        set gcc_issues 0
    end

    echo ""

    if command -q clang
        echo "▶ Clang Static Analyzer..."
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        clang-check $files 2>&1
        clang-check $files 2>&1 | tee /tmp/clang-output.txt >/dev/null
        set clang_issues (grep -c -E "error:|warning:" /tmp/clang-output.txt 2>/dev/null)

        if test $status -ne 0
            set clang_issues 0
        end

        echo ""
    else
        echo "⚠️  clang not found"
        echo ""
    end

    if command -q clang-tidy
        echo "▶ Clang-Tidy HARDENED SECURITY SCAN..."
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

        set project_root (pwd)
        set include_path "$project_root/include"

        # Nur diese Projektbereiche werden analysiert
        set scan_dirs \
            "$project_root/src" \
            "$project_root/include" \
            "$project_root/tests" \
            "$project_root/fuzz"

        set files

        for dir in $scan_dirs
            if test -d "$dir"
                for file in (find "$dir" \
                -type f \
                \( \
                    -name '*.c' \
                    -o -name '*.cc' \
                    -o -name '*.cpp' \
                    -o -name '*.cxx' \
                    -o -name '*.h' \
                    -o -name '*.hpp' \
                    -o -name '*.hh' \
                    -o -name '*.hxx' \
                    -o -name '*.h++' \
                \) \
                -not -path '*/build/*' \
                -not -path '*/.git/*' \
                -not -path '*/CMakeFiles/*' \
                -not -path '*/third_party/*' \
                -not -path '*/vendor/*' \
                -not -path '*/external/*' \
                -not -path '*/generated/*' \
            )
                    set files $files $file
                end
            end
        end

        if test (count $files) -eq 0
            echo "⚠️  Keine Projekt-Quelldateien gefunden"
            return 1
        end

        echo "▶ Scan-Dateien:"
        for file in $files
            echo "  • "(string replace "$project_root/" "" "$file")
        end

        echo ""

        # HARD SECURITY PROFILE
        set tidy_checks \
            '-*' \
            'clang-analyzer-*' \
            'clang-analyzer-security.*' \
            'clang-analyzer-unix.*' \
            'clang-analyzer-core.*' \
            'cert-*' \
            'security-*' \
            'bugprone-*' \
            'clang-diagnostic-*' \
            -bugprone-easily-swappable-parameters \
            -bugprone-branch-clone \
            -bugprone-narrowing-conversions \
            -bugprone-signed-char-misuse \
            '-readability-*' \
            '-modernize-*' \
            '-cppcoreguidelines-*' \
            '-hicpp-*' \
            '-llvm-*' \
            '-google-*' \
            '-fuchsia-*' \
            '-zircon-*' \
            '-llvmlibc-*'

        set checks (string join -- ',' $tidy_checks)

        set tidy_output /tmp/clang-tidy-output.txt

        if test -f compile_commands.json
            clang-tidy \
                $files \
                -p=. \
                -checks="$checks" \
                -warnings-as-errors='*' \
                -header-filter="^$project_root/(src|include|tests|fuzz)/" \
                -- \
                -std=c23 \
                -Wall \
                -Wextra \
                -Wpedantic \
                -Wconversion \
                -Wsign-conversion \
                -Wshadow \
                -Wformat=2 \
                -Wundef \
                -Wstrict-prototypes \
                -Wmissing-prototypes \
                -Wnull-dereference \
                -Wcast-align \
                -Wcast-qual \
                -Wwrite-strings \
                -isystem "$include_path" 2>&1 | tee $tidy_output

        else if test -f build/compile_commands.json
            clang-tidy \
                $files \
                -p=build \
                -checks="$checks" \
                -warnings-as-errors='*' \
                -header-filter="^$project_root/(src|include|tests|fuzz)/" \
                -- \
                -std=c23 \
                -Wall \
                -Wextra \
                -Wpedantic \
                -Wconversion \
                -Wsign-conversion \
                -Wshadow \
                -Wformat=2 \
                -Wundef \
                -Wstrict-prototypes \
                -Wmissing-prototypes \
                -Wnull-dereference \
                -Wcast-align \
                -Wcast-qual \
                -Wwrite-strings \
                -isystem "$include_path" 2>&1 | tee $tidy_output

        else
            clang-tidy \
                $files \
                -checks="$checks" \
                -warnings-as-errors='*' \
                -header-filter="^$project_root/(src|include|tests|fuzz)/" \
                -- \
                -std=c23 \
                -Wall \
                -Wextra \
                -Wpedantic \
                -Wconversion \
                -Wsign-conversion \
                -Wshadow \
                -Wformat=2 \
                -Wundef \
                -Wstrict-prototypes \
                -Wmissing-prototypes \
                -Wnull-dereference \
                -Wcast-align \
                -Wcast-qual \
                -Wwrite-strings \
                -isystem "$include_path" 2>&1 | tee $tidy_output
        end

        set tidy_status $pipestatus[1]

        set tidy_errors (
            grep -Ec "error:|warning:|error|warning" $tidy_output 2>/dev/null
            or echo 0
        )

        set tidy_issues (grep -c -E "error:|warning:|error|warning" $tidy_output 2>/dev/null)

        if test $status -ne 0
            set tidy_issues 0
        end

        echo ""
        echo "▶ Result"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

        if test $tidy_status -ne 0
            echo "✗ CLANG-TIDY SECURITY FAIL"
            echo "  Findings: $tidy_errors"
            set analysis_results $analysis_results "✗ CLANG-TIDY SECURITY FAIL ($tidy_errors findings)"
        else
            echo "✓ CLANG-TIDY SECURITY PASS"
            set analysis_results $analysis_results "✓ CLANG-TIDY SECURITY PASS"
        end

        echo ""

    else
        echo "⚠️ clang-tidy nicht installiert"
    end

    if command -q cppcheck
        echo "▶ Cppcheck..."
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        cppcheck \
            --enable=all \
            --std=c23 \
            --inconclusive \
            --force \
            --inline-suppr \
            --quiet \
            --template='{file}:{line}:{column}: {severity}: {id}: {message}' \
            --suppress=missingIncludeSystem \
            --suppress=unusedFunction \
            $files 2>&1 | tee /tmp/cppcheck-output.txt
        set cppcheck_issues (grep -c -E "error:|warning:|error|warning" /tmp/cppcheck-output.txt 2>/dev/null)

        if test $status -ne 0
            set cppcheck_issues 0
        end

        echo ""
        echo "▶ Result"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

        if test $cppcheck_issues -gt 0
            set analysis_results $analysis_results "✗ Cppcheck: $cppcheck_issues findings"
        else
            set analysis_results $analysis_results "✓ Cppcheck: OK"
        end

        echo ""
    else
        echo "⚠️  cppcheck not found"
        echo ""
    end

    if command -q flawfinder
        echo "▶ Flawfinder..."
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

        set reports_dir "$project_root/reports"
        set flawfinder_html "$reports_dir/flawfinder-report.html"
        set flawfinder_pdf "$reports_dir/flawfinder-report.pdf"

        # Erstelle reports-Verzeichnis
        mkdir -p "$reports_dir"

        # HTML-Report generieren
        flawfinder \
            --context \
            --minlevel=0 \
            --columns \
            --html \
            $files >"$flawfinder_html" 2>&1

        set flawfinder_status $status

        # HTML zu PDF konvertieren (wenn wkhtmltopdf verfügbar)
        if command -q wkhtmltopdf
            wkhtmltopdf "$flawfinder_html" "$flawfinder_pdf" 2>/dev/null
            if test $status -eq 0
                echo "✓ PDF generiert: $flawfinder_pdf"
            end
        else if command -q weasyprint
            weasyprint "$flawfinder_html" "$flawfinder_pdf" 2>/dev/null
            if test $status -eq 0
                echo "✓ PDF generiert: $flawfinder_pdf"
            end
        else
            echo "⚠️  wkhtmltopdf/weasyprint nicht gefunden - nur HTML verfügbar"
        end

        echo ""
        echo "▶ Result"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "📄 HTML Report: $flawfinder_html"
        if test -f "$flawfinder_pdf"
            echo "📑 PDF Report:  $flawfinder_pdf"
        end

        set flawfinder_issues (grep -o "Hits = [0-9]*" "$flawfinder_html" 2>/dev/null | string replace "Hits = " "")

        if test (count $flawfinder_issues) -eq 0 || test -z "$flawfinder_issues"
            set flawfinder_issues 0
        end

        echo "Gefundene Issues (Hits): $flawfinder_issues"

        # Entscheide basierend auf der Anzahl der Hits, nicht nur dem Exit-Code
        if test $flawfinder_issues -gt 0
            echo "✗ Flawfinder: ISSUES FOUND ($flawfinder_issues)"
            set analysis_results $analysis_results "✗ Flawfinder: ISSUES FOUND ($flawfinder_issues)"
        else
            echo "✓ Flawfinder: OK"
            set analysis_results $analysis_results "✓ Flawfinder: OK"
        end

        echo ""

    else
        echo "⚠️  flawfinder not found (install: sudo pacman -S flawfinder)"
        echo ""
    end

    if command -q splint
        echo "▶ Splint..."
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

        splint \
            +bounds \
            +bufferoverflowhigh \
            +null \
            +nullassign \
            +nullpass \
            +nullret \
            +memchecks \
            +strict \
            +warnposix \
            +type \
            +matchanyintegral \
            +formatconst \
            +formatcode \
            +formatlint \
            +globstate \
            +modifies \
            +mustfree \
            +mustdefine \
            +mustfreeonly \
            +branchstate \
            +compdef \
            +declundef \
            +exportlocal \
            +exportheader \
            +dependenttrans \
            +dependenttrans \
            $files 2>&1 | tee /tmp/splint-output.txt

        set splint_status $pipestatus[1]

        set splint_issues (grep -c -E "error:|warning:|error|warning" /tmp/splint-output.txt 2>/dev/null)

        if test $status -ne 0
            set splint_isszes 0
        end

        echo ""
        echo "▶ Result"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

        if test $splint_status -eq 0
            echo "✓ Splint: OK"
            set analysis_results $analysis_results "✓ Splint: OK"
        else
            echo "✗ Splint: ISSUES FOUND ($splint_issues)"
            set analysis_results $analysis_results "✗ Splint: ISSUES FOUND ($splint_issues)"
        end

        echo ""
    else
        echo "⚠️  splint not found (install: sudo pacman -S splint)"
        echo ""
    end

    # ============================================================
    # FINAL RESULT
    # ============================================================

    set -l end_time (date +%s)

    if test -n "$start_time"
        set -l duration (math "$end_time - $start_time")
    else
        set -l duration 0
    end

    # ------------------------------------------------------------
    # Safe integer converter
    # ------------------------------------------------------------

    function __c_safe_int
        if test (count $argv) -eq 0
            echo 0
            return
        end

        set -l value $argv[1]

        if string match -rq '^[0-9]+$' -- "$value"
            echo "$value"
        else
            echo 0
        end
    end

    # ------------------------------------------------------------
    # Normalize counters
    # ------------------------------------------------------------

    set gcc_issues (__c_safe_int $gcc_issues)
    set clang_issues (__c_safe_int $clang_issues)
    set tidy_issues (__c_safe_int $tidy_issues)
    set cppcheck_issues (__c_safe_int $cppcheck_issues)
    set flawfinder_issues (__c_safe_int $flawfinder_issues)
    set splint_issues (__c_safe_int $splint_issues)

    # ------------------------------------------------------------
    # Calculate totals
    # ------------------------------------------------------------

    set -l total_issues (math \
        "$gcc_issues + $clang_issues + $tidy_issues + $cppcheck_issues + $flawfinder_issues + $splint_issues")

    # ------------------------------------------------------------
    # Normalize statuses
    # ------------------------------------------------------------

    set -l failed_checks 0

    for check_status in \
        "$gcc_status" \
        "$clang_status" \
        "$tidy_status" \
        "$cppcheck_status" \
        "$flawfinder_status" \
        "$splint_status"

        if not string match -rq '^0$' -- "$check_status"
            set failed_checks (math "$failed_checks + 1")
        end
    end

    # ------------------------------------------------------------
    # Center helper
    # ------------------------------------------------------------

    function __c_analyze_center
        set -l text "$argv"
        set -l width 62
        set -l length (string length -- "$text")

        set -l padding (math "$width - $length")

        if test $padding -lt 0
            set padding 0
        end

        set -l left (math "floor($padding / 2)")
        set -l right (math "$padding - $left")

        printf "║%*s%s%*s║\n" $left "" "$text" $right ""
    end

    # ------------------------------------------------------------
    # Output
    # ------------------------------------------------------------

    echo ""
    echo "╔══════════════════════════════════════════════════════════════╗"

    __c_analyze_center "C CODE ANALYSIS COMPLETE"

    echo "╠══════════════════════════════════════════════════════════════╣"
    echo "║                                                              ║"

    __c_analyze_center "GCC          $gcc_issues issues"
    __c_analyze_center "Clang        $clang_issues issues"
    __c_analyze_center "Clang-Tidy   $tidy_issues issues"
    __c_analyze_center "Cppcheck     $cppcheck_issues issues"
    __c_analyze_center "Flawfinder   $flawfinder_issues issues"
    __c_analyze_center "Splint       $splint_issues issues"

    echo "║                                                              ║"
    echo "╠══════════════════════════════════════════════════════════════╣"

    __c_analyze_center "TOTAL ISSUES: $total_issues"
    __c_analyze_center "FAILED CHECKS: $failed_checks"
    # __c_analyze_center "DURATION: $duration"s

    echo "║                                                              ║"
    echo "╠══════════════════════════════════════════════════════════════╣"

    if test $total_issues -eq 0
        __c_analyze_center "✓✓✓  NO ISSUES DETECTED  ✓✓✓"
    else
        __c_analyze_center "✗✗✗  ISSUES DETECTED  ✗✗✗"
    end

    echo "╚══════════════════════════════════════════════════════════════╝"

    echo ""
    echo "╔══════════════════════════════════════════════════════════════╗"
    __c_analyze_center "FINAL TOOL RESULTS"
    echo "╠══════════════════════════════════════════════════════════════╣"
    echo "║                                                              ║"

    for result in $analysis_results
        __c_analyze_center "$result"
    end

    echo "║                                                              ║"
    echo "╚══════════════════════════════════════════════════════════════╝"

    # cleanup helper functions
    functions -e __c_analyze_center
    functions -e __c_safe_int
end



# ============================================================
# MAXIMUM HARDENED GCC BUILD
#
# Production-oriented defensive build.
# Target: GNU/Linux, preferably x86-64.
# ============================================================

function gcc-hardened
    if test (count $argv) -eq 0
        echo "Usage: gcc-hardened <source.c> [-o output]"
        return 1
    end

    gcc \
        -std=c23 \
        -O2 \
        -flto=auto \
        -fhardened \
        -fharden-compares \
        -fharden-conditional-branches \
        -fharden-control-flow-redundancy \
        -fvisibility=hidden \
        -fzero-call-used-regs=used-gpr \
        -Wall \
        -Wextra \
        -Wpedantic \
        -Wconversion \
        -Wsign-conversion \
        -Wshadow \
        -Wformat=2 \
        -Wformat-security \
        -Werror=format-security \
        -Werror=implicit-function-declaration \
        -Werror=incompatible-pointer-types \
        -Werror=return-type \
        -Werror=strict-prototypes \
        -Werror=missing-prototypes \
        -Werror=missing-declarations \
        -Werror=write-strings \
        $argv
end


# ============================================================
# MAXIMUM HARDENED CLANG BUILD
#
# Production-oriented defensive build with LLVM CFI.
# Target: GNU/Linux, preferably x86-64.
# ============================================================

function clang-hardened
    if test (count $argv) -eq 0
        echo "Usage: clang-hardened <source.c> [-o output]"
        return 1
    end

    clang \
        -std=c23 \
        -O2 \
        -flto=full \
        -fvisibility=hidden \
        -fPIE \
        -D_FORTIFY_SOURCE=3 \
        -fstack-protector-strong \
        -fstack-clash-protection \
        -ftrivial-auto-var-init=zero \
        -fzero-call-used-regs=used-gpr \
        -fcf-protection=full \
        -fsanitize=cfi \
        -fsanitize-trap=cfi \
        -Wall \
        -Wextra \
        -Wpedantic \
        -Wconversion \
        -Wsign-conversion \
        -Wshadow \
        -Wformat=2 \
        -Wformat-security \
        -Werror=format-security \
        -Werror=implicit-function-declaration \
        -Werror=incompatible-pointer-types \
        -Werror=return-type \
        -Werror=strict-prototypes \
        -Werror=missing-prototypes \
        -Werror=missing-declarations \
        -Werror=write-strings \
        $argv \
        -pie \
        -Wl,-z,relro \
        -Wl,-z,now \
        -Wl,-z,noexecstack \
        -Wl,-z,separate-code \
        -Wl,-z,defs \
        -Wl,-z,pack-relative-relocs \
        -Wl,-z,shstk
end


# ============================================================
# GDB / PWNDGB
#
# If Pwndbg is configured through GDB startup files,
# simply launching gdb will use it automatically.
# 
# But I alreade create a nocther cuntion gdb wich is 
# more powerful and can be used to launch gdb with arguments.
# ============================================================

alias gdb-debug gdb
alias gdb-pwndbg gdb

function gd
    if test (count $argv) -eq 0
        echo "Usage: gd <program> [arguments...]"
        return 1
    end

    gdb --args $argv
end


function gapp
    set target ./build/app

    if test (count $argv) -ge 1
        set target $argv[1]
    end

    if not test -x "$target"
        echo "Executable not found: $target"
        return 1
    end

    gdb "$target"
end


function gapp-args
    if test (count $argv) -eq 0
        echo "Usage: gapp-args <program> [arguments...]"
        return 1
    end

    set target $argv[1]
    set args $argv[2..-1]

    if not test -x "$target"
        echo "Executable not found: $target"
        return 1
    end

    gdb --args "$target" $args
end


function gdb-info
    if not command -q gdb
        echo "GDB: missing"
        return 1
    end

    gdb --version | head -1

    if test -f ~/.gdbinit
        echo "GDB init: ~/.gdbinit"
    end

    gdb -q -ex 'python import sys; print(sys.version)' -ex quit
end


# ============================================================
# LLDB / CODELLDB
# ============================================================

alias lldb-debug lldb

function ld
    if test (count $argv) -eq 0
        echo "Usage: ld <program> [arguments...]"
        return 1
    end

    lldb -- $argv
end


function lapp
    set target ./build/app

    if test (count $argv) -ge 1
        set target $argv[1]
    end

    if not test -x "$target"
        echo "Executable not found: $target"
        return 1
    end

    lldb "$target"
end


function codelldb-check
    if command -q codelldb
        echo "CodeLLDB: available"
        command -v codelldb
    else
        echo "CodeLLDB: not found"
        echo "CodeLLDB is normally provided through the VS Code extension."
    end
end


# ============================================================
# RUN C PROGRAM
# ============================================================

function runapp
    set target ""

    if test -x ./build/app
        set target ./build/app
    else if test -x ./app
        set target ./app
    else
        echo "No ./build/app or ./app found."
        return 1
    end

    "$target" $argv
end


# ============================================================
# DEBUG INFORMATION / DWARF
# ============================================================

function debug-info
    set target ./build/app

    if test (count $argv) -ge 1
        set target $argv[1]
    end

    if not test -e "$target"
        echo "File not found: $target"
        return 1
    end

    echo "============================================================"
    echo "FILE"
    echo "============================================================"
    file "$target"

    echo ""
    echo "============================================================"
    echo "DEBUG SECTIONS"
    echo "============================================================"

    if command -q readelf
        readelf -S "$target" 2>/dev/null \
            | grep -E '\.debug_|\.zdebug_|\.eh_frame'
    end

    echo ""
    echo "============================================================"
    echo "DWARF INFO"
    echo "============================================================"

    if command -q readelf
        readelf --debug-dump=info "$target" 2>/dev/null | head -100
    end

    echo ""
    echo "============================================================"
    echo "SYMBOLS"
    echo "============================================================"

    nm -C "$target" 2>/dev/null | head -100
end


# ============================================================
# ELF INFORMATION
# ============================================================

function elf-info
    if test (count $argv) -eq 0
        echo "Usage: elf-info <binary>"
        return 1
    end

    set -l target $argv[1]

    if not test -e "$target"
        echo "File not found: $target"
        return 1
    end

    if not command -q readelf
        echo "readelf not found."
        return 1
    end

    echo "============================================================"
    echo "BASIC & SECURITY PROPERTIES"
    echo "============================================================"

    echo ""
    echo "File type:"
    file "$target"

    # ========================================================
    # NX / GNU_STACK
    # ========================================================

    echo ""
    echo -n "NX / Executable Stack: "

    set -l stack_line (readelf -W -l "$target" 2>/dev/null | grep 'GNU_STACK')

    if test (count $stack_line) -eq 0
        echo "UNKNOWN (No GNU_STACK segment found)"
    else
        set -l stack_flags (string split -n ' ' -- $stack_line | tail -1)

        if string match -q '*X*' -- "$stack_flags"
            echo "DISABLED (Stack is executable!)"
        else
            echo "ENABLED (Stack is non-executable)"
        end
    end

    # ========================================================
    # RELRO
    # ========================================================

    echo -n "RELRO: "

    set -l relro (readelf -W -l "$target" 2>/dev/null | grep 'GNU_RELRO')

    if test (count $relro) -eq 0
        echo "No RELRO"
    else
        set -l bind_now (readelf -W -d "$target" 2>/dev/null | grep -E 'BIND_NOW|FLAGS.*NOW')

        if test (count $bind_now) -gt 0
            echo "Full RELRO"
        else
            echo "Partial RELRO"
        end
    end

    # ========================================================
    # STACK CANARY
    # ========================================================

    echo -n "Stack Canary: "

    if readelf -Ws "$target" 2>/dev/null | grep -q '__stack_chk_fail'
        echo "ENABLED (__stack_chk_fail found)"
    else
        echo "DISABLED / Not detected"
    end

    # ========================================================
    # FORTIFY SOURCE
    # ========================================================

    echo -n "Fortify Source: "

    if readelf -Ws "$target" 2>/dev/null | grep -q -E '_chk(@|$)'
        echo "ENABLED (Fortified functions found)"
    else
        echo "DISABLED / Not detected"
    end

    # ========================================================
    # RPATH / RUNPATH
    # ========================================================

    echo -n "RPATH / RUNPATH: "

    set -l paths (readelf -W -d "$target" 2>/dev/null \
        | grep -E 'RPATH|RUNPATH' \
        | sed -E 's/.*\[(.*)\].*/\1/')

    if test (count $paths) -gt 0
        string join ', ' $paths
    else
        echo "None"
    end

    # ========================================================
    # GNU PROPERTIES
    # ========================================================

    echo ""
    echo "============================================================"
    echo "GNU PROPERTIES (.note.gnu.property)"
    echo "============================================================"

    set -l gnu_properties (readelf -n "$target" 2>/dev/null \
        | grep -A 8 -E 'GNU_PROPERTY|GNU properties')

    if test (count $gnu_properties) -gt 0
        printf '%s\n' $gnu_properties
    else
        echo "No GNU properties found."
        echo "Examples: IBT / SHSTK"
    end

    # ========================================================
    # DYNAMIC SYMBOLS
    # ========================================================

    echo ""
    echo "============================================================"
    echo "DYNAMIC SYMBOLS (dynsym)"
    echo "============================================================"

    set -l dynsyms (readelf --dyn-syms -W "$target" 2>/dev/null | head -150)

    if test (count $dynsyms) -gt 0
        printf '%s\n' $dynsyms
    else
        echo "No dynamic symbols."
    end

    # ========================================================
    # RELOCATIONS
    # ========================================================

    echo ""
    echo "============================================================"
    echo "RELOCATIONS"
    echo "============================================================"

    set -l relocations (readelf -r -W "$target" 2>/dev/null | head -150)

    if test (count $relocations) -gt 0
        printf '%s\n' $relocations
    else
        echo "No relocations."
    end

    # ========================================================
    # ELF HEADER
    # ========================================================

    echo ""
    echo "============================================================"
    echo "STANDARD ELF HEADER"
    echo "============================================================"

    readelf -W -h "$target"

    # ========================================================
    # PROGRAM HEADERS
    # ========================================================

    echo ""
    echo "============================================================"
    echo "PROGRAM HEADERS"
    echo "============================================================"

    readelf -W -l "$target"

    # ========================================================
    # SECTIONS
    # ========================================================

    echo ""
    echo "============================================================"
    echo "SECTIONS"
    echo "============================================================"

    readelf -W -S "$target"

    # ========================================================
    # DYNAMIC INFORMATION
    # ========================================================

    echo ""
    echo "============================================================"
    echo "DYNAMIC INFORMATION"
    echo "============================================================"

    readelf -W -d "$target" 2>/dev/null
end

# ============================================================
# SECURITY PROPERTIES
# ============================================================

function sec
    set target ./build/app

    if test (count $argv) -ge 1
        set target $argv[1]
    end

    if not test -e "$target"
        echo "File not found: $target"
        return 1
    end

    echo "=== checksec ==="

    if command -q checksec
        checksec --file="$target"
    else
        echo "checksec not installed."
    end

    echo ""
    echo "=== ELF ==="
    readelf -W -h "$target"

    echo ""
    echo "=== Program Headers ==="
    readelf -W -l "$target"

    echo ""
    echo "=== Dynamic ==="
    readelf -W -d "$target"
end


function elf-rpath
    if test (count $argv) -eq 0
        echo "Usage: elf-rpath <binary>"
        return 1
    end

    readelf -W -d "$argv[1]" \
        | grep -E 'RPATH|RUNPATH'
end


function elf-needed
    if test (count $argv) -eq 0
        echo "Usage: elf-needed <binary>"
        return 1
    end

    readelf -W -d "$argv[1]" \
        | grep 'NEEDED'
end


function elf-relocs
    if test (count $argv) -eq 0
        echo "Usage: elf-relocs <binary>"
        return 1
    end

    readelf -W --relocs "$argv[1]"
end


function symgrep
    if test (count $argv) -lt 2
        echo "Usage: symgrep <binary> <pattern>"
        return 1
    end

    nm -anC "$argv[1]" \
        | grep -Ei -- "$argv[2]"
end


# ============================================================
# STRINGS
# ============================================================

function strings-find
    if test (count $argv) -lt 2
        echo "Usage: strings-find <binary> <pattern>"
        return 1
    end

    strings -a "$argv[1]" \
        | grep -i -- "$argv[2]"
end


# ============================================================
# DISASSEMBLY
# ============================================================

function disasm
    if test (count $argv) -eq 0
        echo "Usage: disasm <binary>"
        return 1
    end

    objdump \
        -d \
        -M intel \
        "$argv[1]"
end


function disasm-main
    if test (count $argv) -eq 0
        echo "Usage: disasm-main <binary>"
        return 1
    end

    objdump \
        -d \
        -M intel \
        "$argv[1]" \
        | sed -n '/<main>:/,/^$/p'
end


function disasm-symbol
    if test (count $argv) -lt 2
        echo "Usage: disasm-symbol <binary> <symbol>"
        return 1
    end

    objdump \
        -d \
        -M intel \
        "$argv[1]" \
            | sed -n '/<'"$argv[2]"'>:/,/^$/p'
end


# ============================================================
# SOURCE SEARCH
# ============================================================

function cgrep
    if test (count $argv) -eq 0
        echo "Usage: cgrep <pattern>"
        return 1
    end

    grep -RIn \
        --exclude-dir=.git \
        --exclude-dir=build \
        --exclude-dir=build-asan \
        --exclude-dir=build-ubsan \
        --exclude-dir=build-msan \
        --exclude-dir=build-tsan \
        --exclude-dir=build-release \
        --include='*.c' \
        --include='*.h' \
        -- "$argv[1]" .
end


function security-todo
    grep -RIn \
        --exclude-dir=.git \
        --exclude-dir=build \
        --exclude-dir=build-asan \
        --exclude-dir=build-ubsan \
        --exclude-dir=build-msan \
        --exclude-dir=build-tsan \
        --exclude-dir=build-release \
        --include='*.c' \
        --include='*.h' \
        -E 'TODO|FIXME|SECURITY|BUG|XXX|HACK|unsafe|overflow|underflow' \
        .
end


# ============================================================
# ADDRESSSANITIZER + UBSAN
# ============================================================

function asan-build
    cmake -S . -B build-asan \
        -DCMAKE_BUILD_TYPE=Debug \
        -DCMAKE_EXPORT_COMPILE_COMMANDS=ON \
        -DCMAKE_C_FLAGS_DEBUG="-O0 -g3 -fsanitize=address,undefined -fno-omit-frame-pointer" \
        -DCMAKE_EXE_LINKER_FLAGS_DEBUG="-fsanitize=address,undefined"

    if test $status -ne 0
        return 1
    end

    cmake --build build-asan --parallel
end


function asan-run
    if not test -x ./build-asan/app
        echo "build-asan/app not found."
        echo "Run: asan-build"
        return 1
    end

    env \
        ASAN_OPTIONS=detect_leaks=1:abort_on_error=1:strict_string_checks=1 \
        UBSAN_OPTIONS=print_stacktrace=1:halt_on_error=1 \
        ./build-asan/app $argv
end


# ============================================================
# UBSAN ONLY
# ============================================================

function ubsan-build
    cmake -S . -B build-ubsan \
        -DCMAKE_BUILD_TYPE=Debug \
        -DCMAKE_EXPORT_COMPILE_COMMANDS=ON \
        -DCMAKE_C_FLAGS_DEBUG="-O0 -g3 -fsanitize=undefined -fno-omit-frame-pointer" \
        -DCMAKE_EXE_LINKER_FLAGS_DEBUG="-fsanitize=undefined"

    if test $status -ne 0
        return 1
    end

    cmake --build build-ubsan --parallel
end


function ubsan-run
    if not test -x ./build-ubsan/app
        echo "build-ubsan/app not found."
        echo "Run: ubsan-build"
        return 1
    end

    env \
        UBSAN_OPTIONS=print_stacktrace=1:halt_on_error=1 \
        ./build-ubsan/app $argv
end


# ============================================================
# MEMORYSANITIZER
#
# Clang only.
#
# Useful for uninitialized-memory analysis.
# ============================================================

function msan-build
    if not command -q clang
        echo "clang not found."
        return 1
    end

    cmake -S . -B build-msan \
        -DCMAKE_BUILD_TYPE=Debug \
        -DCMAKE_C_COMPILER=clang \
        -DCMAKE_EXPORT_COMPILE_COMMANDS=ON \
        -DCMAKE_C_FLAGS_DEBUG="-O1 -g3 -fsanitize=memory -fno-omit-frame-pointer" \
        -DCMAKE_EXE_LINKER_FLAGS_DEBUG="-fsanitize=memory"

    if test $status -ne 0
        return 1
    end

    cmake --build build-msan --parallel
end


function msan-run
    if not test -x ./build-msan/app
        echo "build-msan/app not found."
        echo "Run: msan-build"
        return 1
    end

    ./build-msan/app $argv
end


# ============================================================
# THREADSANITIZER
# ============================================================

function tsan-build
    cmake -S . -B build-tsan \
        -DCMAKE_BUILD_TYPE=Debug \
        -DCMAKE_EXPORT_COMPILE_COMMANDS=ON \
        -DCMAKE_C_FLAGS_DEBUG="-O1 -g3 -fsanitize=thread -fno-omit-frame-pointer" \
        -DCMAKE_EXE_LINKER_FLAGS_DEBUG="-fsanitize=thread"

    if test $status -ne 0
        return 1
    end

    cmake --build build-tsan --parallel
end


function tsan-run
    if not test -x ./build-tsan/app
        echo "build-tsan/app not found."
        echo "Run: tsan-build"
        return 1
    end

    ./build-tsan/app $argv
end


# ============================================================
# VALGRIND
# ============================================================

function memcheck
    if test (count $argv) -eq 0
        if test -x ./build/app
            valgrind \
                --leak-check=full \
                --show-leak-kinds=all \
                --track-origins=yes \
                --num-callers=30 \
                ./build/app

            return $status
        end

        echo "Usage: memcheck <program> [arguments...]"
        return 1
    end

    valgrind \
        --leak-check=full \
        --show-leak-kinds=all \
        --track-origins=yes \
        --num-callers=30 \
        $argv
end


function massif
    if test (count $argv) -eq 0
        echo "Usage: massif <program> [arguments...]"
        return 1
    end

    valgrind \
        --tool=massif \
        $argv
end


# ============================================================
# SYSTEM CALL TRACING
# ============================================================

function trace
    if test (count $argv) -eq 0
        echo "Usage: trace <program> [arguments...]"
        return 1
    end

    strace \
        -f \
        -yy \
        -s 512 \
        -o trace.log \
        $argv

    echo "Trace written to trace.log"
end


# ============================================================
# LIBRARY CALL TRACING
# ============================================================

function ltrace-app
    if test (count $argv) -eq 0
        echo "Usage: ltrace-app <program> [arguments...]"
        return 1
    end

    ltrace \
        -f \
        $argv
end


# ============================================================
# PROCESS INSPECTION
# ============================================================

function maps
    if test (count $argv) -eq 0
        echo "Usage: maps <pid>"
        return 1
    end

    set pid $argv[1]

    if not test -r "/proc/$pid/maps"
        echo "Cannot read process maps."
        return 1
    end

    cat "/proc/$pid/maps"
end


function fds
    if test (count $argv) -eq 0
        echo "Usage: fds <pid>"
        return 1
    end

    set pid $argv[1]

    if not test -d "/proc/$pid/fd"
        echo "Process not found or inaccessible."
        return 1
    end

    ls -lah "/proc/$pid/fd"
end


function pstatus
    if test (count $argv) -eq 0
        echo "Usage: pstatus <pid>"
        return 1
    end

    set pid $argv[1]

    if not test -r "/proc/$pid/status"
        echo "Process not found or inaccessible."
        return 1
    end

    cat "/proc/$pid/status"
end


# ============================================================
# C COMPILER / TOOLCHAIN INFORMATION
# ============================================================

function c-toolchain
    echo "============================================================"
    echo "C TOOLCHAIN"
    echo "============================================================"

    if command -q gcc
        echo ""
        echo "GCC:"
        gcc --version | head -1
    else
        echo "GCC: missing"
    end

    if command -q clang
        echo ""
        echo "Clang:"
        clang --version | head -1
    else
        echo "Clang: missing"
    end

    if command -q clangd
        echo ""
        echo "clangd:"
        clangd --version | head -1
    else
        echo "clangd: missing"
    end

    if command -q cmake
        echo ""
        echo "CMake:"
        cmake --version | head -1
    else
        echo "CMake: missing"
    end

    if command -q gdb
        echo ""
        echo "GDB:"
        gdb --version | head -1
    else
        echo "GDB: missing"
    end

    if command -q lldb
        echo ""
        echo "LLDB:"
        lldb --version | head -1
    else
        echo "LLDB: missing"
    end

    if command -q checksec
        echo ""
        echo "checksec: available"
    else
        echo ""
        echo "checksec: missing"
    end

    if command -q valgrind
        echo "Valgrind: available"
    else
        echo "Valgrind: missing"
    end

    if command -q strace
        echo "strace: available"
    else
        echo "strace: missing"
    end

    if command -q ltrace
        echo "ltrace: available"
    else
        echo "ltrace: missing"
    end
end


# ============================================================
# CMAKE TOOLCHAIN INFO
# ============================================================

function c-info
    echo "============================================================"
    echo "C PROJECT"
    echo "============================================================"

    if test -f compile_commands.json
        echo "compile_commands.json : available"
    else
        echo "compile_commands.json : missing"
    end

    if test -d build
        echo "build                 : available"
    else
        echo "build                 : missing"
    end

    if test -x ./build/app
        echo "build/app             : executable"
    else
        echo "build/app             : missing"
    end

    echo ""
    echo "Useful commands:"
    echo ""
    echo "  c-config"
    echo "  c-build"
    echo "  c-rebuild"
    echo "  c-clean"
    echo ""
    echo "  gcc-debug"
    echo "  clang-debug"
    echo "  gcc-check"
    echo "  clang-check"
    echo ""
    echo "  gapp"
    echo "  gapp-args"
    echo "  lapp"
    echo "  ld"
    echo ""
    echo "  sec"
    echo "  elf-info"
    echo "  debug-info"
    echo "  disasm"
    echo "  disasm-main"
    echo ""
    echo "  asan-build / asan-run"
    echo "  ubsan-build / ubsan-run"
    echo "  msan-build / msan-run"
    echo "  tsan-build / tsan-run"
    echo ""
    echo "  memcheck"
    echo "  massif"
    echo "  trace"
    echo "  ltrace-app"
end


function target-info
    set target ./build/app

    if test (count $argv) -ge 1
        set target $argv[1]
    end

    if not test -e "$target"
        echo "File not found: $target"
        return 1
    end

    echo "=== File ==="
    file "$target"

    echo ""
    echo "=== Architecture ==="
    readelf -W -h "$target" \
        | grep -E 'Class:|Data:|Machine:|Type:|Entry point'

    echo ""
    echo "=== Security ==="

    if command -q checksec
        checksec --file="$target"
    end

    echo ""
    echo "=== Dependencies ==="
    readelf -W -d "$target" \
        | grep 'NEEDED'
end


# ============================================================
# TOOL AVAILABILITY
# ============================================================

function security-tools
    set tools \
        gcc \
        clang \
        clangd \
        clang-format \
        clang-tidy \
        cppcheck \
        flawfinder \
        cmake \
        ninja \
        gdb \
        lldb \
        readelf \
        llvm-readelf \
        objdump \
        llvm-objdump \
        nm \
        llvm-nm \
        strings \
        llvm-strings \
        addr2line \
        llvm-addr2line \
        c++filt \
        llvm-symbolizer \
        strace \
        ltrace \
        valgrind \
        git \
        nvim

    echo "============================================================"
    echo "C SECURITY / DEBUG TOOLCHAIN"
    echo "============================================================"

    for tool in $tools
        if command -q $tool
            printf "%-16s %s\n" "$tool" "available"
        else
            printf "%-16s %s\n" "$tool" "MISSING"
        end
    end

    echo ""

    if command -q checksec
        printf "%-16s %s\n" "checksec" "available"
    else
        printf "%-16s %s\n" "checksec" "MISSING"
    end

    if command -q codelldb
        printf "%-16s %s\n" "codelldb" "available"
    else
        printf "%-16s %s\n" "codelldb" "not CLI-installed"
    end
end


function addr
    if test (count $argv) -lt 2
        echo "Usage: addr <binary> <address>"
        return 1
    end

    addr2line \
        -e "$argv[1]" \
        -f \
        -C \
        "$argv[2]"
end

# ============================================================
# C PROJECT GENERATOR
# ============================================================

function __cpro_scaffold --argument-names name full_scan
    set -l project_dir (pwd)/$name

    if test -e "$project_dir"
        echo "Already exists: $project_dir"
        return 1
    end

    mkdir -p \
        "$project_dir/src" \
        "$project_dir/include" \
        "$project_dir/tests" \
        "$project_dir/fuzz" \
        "$project_dir/scripts"
    or return 1

    cd "$project_dir"
    or return 1

    # ========================================================
    # CMakeLists.txt
    # ========================================================

    set -l cmake_content \
        'cmake_minimum_required(VERSION 3.22)' \
        '' \
        'project(C23SecurityResearch VERSION 0.1.0 LANGUAGES C)' \
        '' \
        'set(CMAKE_C_STANDARD 23)' \
        'set(CMAKE_C_STANDARD_REQUIRED ON)' \
        'set(CMAKE_C_EXTENSIONS OFF)' \
        'set(CMAKE_EXPORT_COMPILE_COMMANDS ON)' \
        '' \
        '# This project targets Linux/ELF with GCC or Clang.' \
        'if(NOT UNIX OR APPLE)' \
        '    message(FATAL_ERROR "C23SecurityResearch currently requires a Linux/ELF environment.")' \
        'endif()' \
        '' \
        'if(NOT CMAKE_BUILD_TYPE)' \
        '    set(CMAKE_BUILD_TYPE Debug CACHE STRING "Build type" FORCE)' \
        'endif()' \
        '' \
        'set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS Debug Release RelWithDebInfo MinSizeRel)' \
        '' \
        'option(ENABLE_ASAN "Enable AddressSanitizer" ON)' \
        'option(ENABLE_UBSAN "Enable UndefinedBehaviorSanitizer" ON)' \
        'option(ENABLE_MSAN "Enable MemorySanitizer (Clang only)" OFF)' \
        'option(ENABLE_TSAN "Enable ThreadSanitizer" OFF)' \
        'option(ENABLE_HARDENING "Enable hardening flags" ON)' \
        'option(ENABLE_WERROR "Treat warnings as errors" OFF)' \
        'option(ENABLE_LTO "Enable link time optimization" OFF)' \
        'option(ENABLE_LIBFUZZER "Enable Clang libFuzzer for fuzz_target" OFF)' \
        '' \
        '# -----------------------------------------------------------------------------' \
        '# Compiler checks' \
        '# -----------------------------------------------------------------------------' \
        '' \
        'if(NOT CMAKE_C_COMPILER_ID MATCHES "GNU|Clang")' \
        '    message(FATAL_ERROR "This project requires GCC or Clang.")' \
        'endif()' \
        '' \
        '# -----------------------------------------------------------------------------' \
        '# Warnings' \
        '# -----------------------------------------------------------------------------' \
        '' \
        'set(PROJECT_WARNINGS' \
        '    -Wall' \
        '    -Wextra' \
        '    -Wpedantic' \
        '    -Wconversion' \
        '    -Wsign-conversion' \
        '    -Wshadow' \
        '    -Wformat=2' \
        '    -Wundef' \
        '    -Wstrict-prototypes' \
        '    -Wmissing-prototypes' \
        '    -Wold-style-definition' \
        '    -Wvla' \
        '    -Wdouble-promotion' \
        ')' \
        '' \
        'if(ENABLE_WERROR)' \
        '    list(APPEND PROJECT_WARNINGS -Werror)' \
        'endif()' \
        '' \
        '# -----------------------------------------------------------------------------' \
        '# Optimization' \
        '# -----------------------------------------------------------------------------' \
        '' \
        'set(PROJECT_OPTIMIZATION)' \
        'if(ENABLE_HARDENING)' \
        '    list(APPEND PROJECT_OPTIMIZATION -O2)' \
        'endif()' \
        '' \
        '# -----------------------------------------------------------------------------' \
        '# Hardening' \
        '# -----------------------------------------------------------------------------' \
        '' \
        'set(PROJECT_HARDENING)' \
        'if(ENABLE_HARDENING)' \
        '    list(APPEND PROJECT_HARDENING' \
        '        -fstack-protector-strong' \
        '        -D_FORTIFY_SOURCE=3' \
        '        -fno-omit-frame-pointer' \
        '        -fPIE' \
        '    )' \
        'endif()' \
        '' \
        'set(PROJECT_HARDENING_LINK)' \
        'if(ENABLE_HARDENING)' \
        '    list(APPEND PROJECT_HARDENING_LINK' \
        '        -pie' \
        '        -Wl,-z,relro,-z,now' \
        '        -Wl,-z,noexecstack' \
        '    )' \
        'endif()' \
        '' \
        '# -----------------------------------------------------------------------------' \
        '# Sanitizers' \
        '# -----------------------------------------------------------------------------' \
        '' \
        'if(ENABLE_ASAN AND ENABLE_TSAN)' \
        '    message(FATAL_ERROR "ASan and TSan cannot be enabled together.")' \
        'endif()' \
        '' \
        'if(ENABLE_ASAN AND ENABLE_MSAN)' \
        '    message(FATAL_ERROR "ASan and MSan cannot be enabled together.")' \
        'endif()' \
        '' \
        'if(ENABLE_TSAN AND ENABLE_MSAN)' \
        '    message(FATAL_ERROR "TSan and MSan cannot be enabled together.")' \
        'endif()' \
        '' \
        'if(ENABLE_MSAN AND NOT CMAKE_C_COMPILER_ID STREQUAL "Clang")' \
        '    message(FATAL_ERROR "MSan requires Clang.")' \
        'endif()' \
        '' \
        'if(ENABLE_LIBFUZZER AND NOT CMAKE_C_COMPILER_ID STREQUAL "Clang")' \
        '    message(FATAL_ERROR "libFuzzer requires Clang.")' \
        'endif()' \
        '' \
        'set(PROJECT_SANITIZERS)' \
        'if(CMAKE_BUILD_TYPE STREQUAL "Debug")' \
        '    if(ENABLE_ASAN)' \
        '        list(APPEND PROJECT_SANITIZERS -fsanitize=address)' \
        '    endif()' \
        '' \
        '    if(ENABLE_UBSAN)' \
        '        list(APPEND PROJECT_SANITIZERS -fsanitize=undefined)' \
        '    endif()' \
        '' \
        '    if(ENABLE_TSAN)' \
        '        list(APPEND PROJECT_SANITIZERS -fsanitize=thread)' \
        '    endif()' \
        '' \
        '    if(ENABLE_MSAN)' \
        '        list(APPEND PROJECT_SANITIZERS -fsanitize=memory)' \
        '    endif()' \
        'endif()' \
        '' \
        '# -----------------------------------------------------------------------------' \
        '# LTO' \
        '# -----------------------------------------------------------------------------' \
        '' \
        'if(ENABLE_LTO)' \
        '    include(CheckIPOSupported)' \
        '    check_ipo_supported(RESULT ipo_ok OUTPUT ipo_msg LANGUAGES C)' \
        '    if(ipo_ok)' \
        '        set(CMAKE_INTERPROCEDURAL_OPTIMIZATION ON)' \
        '    else()' \
        '        message(WARNING "LTO not supported: ${ipo_msg}")' \
        '    endif()' \
        'endif()' \
        '' \
        '# -----------------------------------------------------------------------------' \
        '# Helper function' \
        '# -----------------------------------------------------------------------------' \
        '' \
        'function(configure_security_target target)' \
        '    target_include_directories(${target} PRIVATE' \
        '        ${CMAKE_CURRENT_SOURCE_DIR}/include' \
        '    )' \
        '' \
        '    target_compile_options(${target} PRIVATE' \
        '        ${PROJECT_WARNINGS}' \
        '        ${PROJECT_OPTIMIZATION}' \
        '        ${PROJECT_HARDENING}' \
        '        ${PROJECT_SANITIZERS}' \
        '    )' \
        '' \
        '    target_link_options(${target} PRIVATE' \
        '        ${PROJECT_HARDENING_LINK}' \
        '        ${PROJECT_SANITIZERS}' \
        '    )' \
        'endfunction()' \
        '' \
        '# -----------------------------------------------------------------------------' \
        '# Main application' \
        '# -----------------------------------------------------------------------------' \
        '' \
        'add_executable(app' \
        '    src/main.c' \
        '    src/target.c' \
        ')' \
        '' \
        'configure_security_target(app)' \
        '' \
        '# -----------------------------------------------------------------------------' \
        '# Fuzzing target' \
        '# -----------------------------------------------------------------------------' \
        '' \
        'add_executable(fuzz_target' \
        '    fuzz/fuzz_target.c' \
        '    src/target.c' \
        ')' \
        '' \
        'configure_security_target(fuzz_target)' \
        '' \
        'if(ENABLE_LIBFUZZER)' \
        '    target_compile_options(fuzz_target PRIVATE -fsanitize=fuzzer)' \
        '    target_link_options(fuzz_target PRIVATE -fsanitize=fuzzer)' \
        'endif()' \
        '' \
        '# -----------------------------------------------------------------------------' \
        '# Unit tests' \
        '# -----------------------------------------------------------------------------' \
        '' \
        'enable_testing()' \
        '' \
        'add_executable(unit_tests' \
        '    tests/test_target.c' \
        '    src/target.c' \
        ')' \
        '' \
        'configure_security_target(unit_tests)' \
        '' \
        'add_test(NAME test_target COMMAND unit_tests)' \
        '' \
        '# -----------------------------------------------------------------------------' \
        '# clang-tidy' \
        '# -----------------------------------------------------------------------------' \
        '' \
        'find_program(CLANG_TIDY_EXE NAMES clang-tidy)' \
        '' \
        'if(CLANG_TIDY_EXE)' \
        '    add_custom_target(analyze-clang-tidy' \
        '        COMMAND ${CLANG_TIDY_EXE}' \
        '            -p ${CMAKE_BINARY_DIR}' \
        '            src/main.c' \
        '            src/target.c' \
        '            tests/test_target.c' \
        '            fuzz/fuzz_target.c' \
        '        WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}' \
        '        COMMENT "Running clang-tidy"' \
        '    )' \
        'else()' \
        '    add_custom_target(analyze-clang-tidy' \
        '        COMMAND ${CMAKE_COMMAND} -E echo "clang-tidy not found; skipping"' \
        '    )' \
        'endif()' \
        '' \
        '# -----------------------------------------------------------------------------' \
        '# cppcheck' \
        '# -----------------------------------------------------------------------------' \
        '' \
        'find_program(CPPCHECK_EXE NAMES cppcheck)' \
        '' \
        'if(CPPCHECK_EXE)' \
        '    add_custom_target(analyze-cppcheck' \
        '        COMMAND ${CPPCHECK_EXE}' \
        '            --enable=all' \
        '            --inconclusive' \
        '            --std=c23' \
        '            --error-exitcode=1' \
        '            --quiet' \
        '            --inline-suppr' \
        '            -I include' \
        '            src' \
        '            tests' \
        '            fuzz' \
        '        WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}' \
        '        COMMENT "Running cppcheck"' \
        '    )' \
        'else()' \
        '    add_custom_target(analyze-cppcheck' \
        '        COMMAND ${CMAKE_COMMAND} -E echo "cppcheck not found; skipping"' \
        '    )' \
        'endif()' \
        '' \
        '# -----------------------------------------------------------------------------' \
        '# flawfinder' \
        '# -----------------------------------------------------------------------------' \
        '' \
        'find_program(FLAWFINDER_EXE NAMES flawfinder)' \
        '' \
        'if(FLAWFINDER_EXE)' \
        '    add_custom_target(analyze-flawfinder' \
        '        COMMAND ${FLAWFINDER_EXE}' \
        '            --quiet' \
        '            --dataonly' \
        '            src' \
        '            include' \
        '            tests' \
        '            fuzz' \
        '        WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}' \
        '        COMMENT "Running flawfinder"' \
        '    )' \
        'else()' \
        '    add_custom_target(analyze-flawfinder' \
        '        COMMAND ${CMAKE_COMMAND} -E echo "flawfinder not found; skipping"' \
        '    )' \
        'endif()' \
        '' \
        '# -----------------------------------------------------------------------------' \
        '# ELF inspection' \
        '# -----------------------------------------------------------------------------' \
        '' \
        'find_program(READELF_EXE NAMES readelf llvm-readelf)' \
        '' \
        'if(READELF_EXE)' \
        '    add_custom_target(sec-elf' \
        '        COMMAND ${READELF_EXE} -W -h -l -S -s app' \
        '        DEPENDS app' \
        '        WORKING_DIRECTORY ${CMAKE_BINARY_DIR}' \
        '        COMMENT "Inspect ELF headers, segments, sections and symbols"' \
        '    )' \
        'else()' \
        '    add_custom_target(sec-elf' \
        '        COMMAND ${CMAKE_COMMAND} -E echo "readelf not found; skipping"' \
        '    )' \
        'endif()' \
        '' \
        '# -----------------------------------------------------------------------------' \
        '# Disassembly' \
        '# -----------------------------------------------------------------------------' \
        '' \
        'find_program(OBJDUMP_EXE NAMES objdump llvm-objdump)' \
        '' \
        'if(OBJDUMP_EXE)' \
        '    add_custom_target(sec-disasm' \
        '        COMMAND ${OBJDUMP_EXE} -d -M intel app' \
        '        DEPENDS app' \
        '        WORKING_DIRECTORY ${CMAKE_BINARY_DIR}' \
        '        COMMENT "Disassemble app"' \
        '    )' \
        'else()' \
        '    add_custom_target(sec-disasm' \
        '        COMMAND ${CMAKE_COMMAND} -E echo "objdump not found; skipping"' \
        '    )' \
        'endif()' \
        '' \
        '# -----------------------------------------------------------------------------' \
        '# Symbol inspection' \
        '# -----------------------------------------------------------------------------' \
        '' \
        'find_program(NM_EXE NAMES nm llvm-nm)' \
        '' \
        'if(NM_EXE)' \
        '    add_custom_target(sec-symbols' \
        '        COMMAND ${NM_EXE} -an app' \
        '        DEPENDS app' \
        '        WORKING_DIRECTORY ${CMAKE_BINARY_DIR}' \
        '        COMMENT "Dump symbol table"' \
        '    )' \
        'else()' \
        '    add_custom_target(sec-symbols' \
        '        COMMAND ${CMAKE_COMMAND} -E echo "nm not found; skipping"' \
        '    )' \
        'endif()' \
        '' \
        '# -----------------------------------------------------------------------------' \
        '# Strings' \
        '# -----------------------------------------------------------------------------' \
        '' \
        'find_program(STRINGS_EXE NAMES strings llvm-strings)' \
        '' \
        'if(STRINGS_EXE)' \
        '    add_custom_target(sec-strings' \
        '        COMMAND ${STRINGS_EXE} -a app' \
        '        DEPENDS app' \
        '        WORKING_DIRECTORY ${CMAKE_BINARY_DIR}' \
        '        COMMENT "Extract printable strings"' \
        '    )' \
        'else()' \
        '    add_custom_target(sec-strings' \
        '        COMMAND ${CMAKE_COMMAND} -E echo "strings not found; skipping"' \
        '    )' \
        'endif()' \
        '' \
        '# -----------------------------------------------------------------------------' \
        '# checksec' \
        '# -----------------------------------------------------------------------------' \
        '' \
        'find_program(CHECKSEC_EXE NAMES checksec checksec.sh)' \
        '' \
        'if(CHECKSEC_EXE)' \
        '    add_custom_target(sec-checksec' \
        '        COMMAND ${CHECKSEC_EXE} --file=app' \
        '        DEPENDS app' \
        '        WORKING_DIRECTORY ${CMAKE_BINARY_DIR}' \
        '        COMMENT "Check ELF hardening properties"' \
        '    )' \
        'else()' \
        '    add_custom_target(sec-checksec' \
        '        COMMAND ${CMAKE_COMMAND} -E echo "checksec not found; skipping"' \
        '    )' \
        'endif()' \
        '' \
        '# -----------------------------------------------------------------------------' \
        '# Aggregate security targets' \
        '# -----------------------------------------------------------------------------' \
        '' \
        'add_custom_target(sec-all DEPENDS app)' \
        'add_dependencies(sec-all' \
        '    sec-elf' \
        '    sec-disasm' \
        '    sec-symbols' \
        '    sec-strings' \
        '    sec-checksec' \
        ')' \
        '' \
        'add_custom_target(analyze-all' \
        '    DEPENDS' \
        '        analyze-clang-tidy' \
        '        analyze-cppcheck' \
        '        analyze-flawfinder' \
        ')' \
        '' \
        'message(STATUS "C23SecurityResearch configured")' \
        'message(STATUS "  Build type:       ${CMAKE_BUILD_TYPE}")' \
        'message(STATUS "  Compiler:         ${CMAKE_C_COMPILER_ID}")' \
        'message(STATUS "  C standard:       C${CMAKE_C_STANDARD}")' \
        'message(STATUS "  Hardening:        ${ENABLE_HARDENING}")' \
        'message(STATUS "  ASan:             ${ENABLE_ASAN}")' \
        'message(STATUS "  UBSan:            ${ENABLE_UBSAN}")' \
        'message(STATUS "  MSan:             ${ENABLE_MSAN}")' \
        'message(STATUS "  TSan:             ${ENABLE_TSAN}")' \
        'message(STATUS "  libFuzzer:        ${ENABLE_LIBFUZZER}")' \
        'message(STATUS "  LTO:              ${ENABLE_LTO}")' \
        'message(STATUS "  Werror:           ${ENABLE_WERROR}")'

    printf '%s\n' $cmake_content > CMakeLists.txt

    echo "CMakeLists.txt created successfully."

    # ========================================================
    # include/target.h
    # ========================================================

    set -l target_h_content \
        '#ifndef TARGET_H' \
        '#define TARGET_H' \
        '' \
        '#include <stddef.h>' \
        '' \
        'size_t bounded_strlen(const char *s, size_t max_len);' \
        'int parse_port(const char *input, int *out_port);' \
        '' \
        '#endif'

    printf '%s\n' $target_h_content > include/target.h

    # ========================================================
    # src/target.c
    # ========================================================

    set -l target_c_content \
        '#include "target.h"' \
        '' \
        '#include <errno.h>' \
        '#include <limits.h>' \
        '#include <stddef.h>' \
        '#include <stdlib.h>' \
        '' \
        'size_t bounded_strlen(const char *s, size_t max_len)' \
        '{' \
        '    size_t i;' \
        '' \
        '    if (s == NULL)' \
        '    {' \
        '        return 0;' \
        '    }' \
        '' \
        '    for (i = 0; i < max_len; ++i)' \
        '    {' \
        '        if (s[i] == '\''\0'\'')' \
        '        {' \
        '            return i;' \
        '        }' \
        '    }' \
        '' \
        '    return max_len;' \
        '}' \
        '' \
        'int parse_port(const char *input, int *out_port)' \
        '{' \
        '    char *end = NULL;' \
        '    long value;' \
        '' \
        '    if (input == NULL || out_port == NULL || *input == '\''\0'\'')' \
        '    {' \
        '        return -1;' \
        '    }' \
        '' \
        '    errno = 0;' \
        '    value = strtol(input, &end, 10);' \
        '' \
        '    if (errno != 0 || end == input || *end != '\''\0'\'')' \
        '    {' \
        '        return -1;' \
        '    }' \
        '' \
        '    if (value < 1 || value > 65535 || value > INT_MAX)' \
        '    {' \
        '        return -1;' \
        '    }' \
        '' \
        '    *out_port = (int)value;' \
        '    return 0;' \
        '}'

    printf '%s\n' $target_c_content > src/target.c

    # ========================================================
    # src/main.c
    # ========================================================

    set -l main_c_content \
        '#include "target.h"' \
        '' \
        '#include <stdio.h>' \
        '' \
        'int main(void)' \
        '{' \
        '    int port = 0;' \
        '' \
        '    if (parse_port("8080", &port) != 0)' \
        '    {' \
        '        fputs("parse_port failed\n", stderr);' \
        '        return 1;' \
        '    }' \
        '' \
        '    printf("C23 security research scaffold: port=%d\n", port);' \
        '    return 0;' \
        '}'

    printf '%s\n' $main_c_content > src/main.c

    # ========================================================
    # tests/test_target.c
    # ========================================================

    set -l test_content \
        '#include "target.h"' \
        '' \
        '#include <assert.h>' \
        '#include <stddef.h>' \
        '' \
        'static void test_bounded_strlen(void)' \
        '{' \
        '    assert(bounded_strlen("hello", 10) == 5);' \
        '    assert(bounded_strlen("hello", 3) == 3);' \
        '    assert(bounded_strlen(NULL, 10) == 0);' \
        '}' \
        '' \
        'static void test_parse_port(void)' \
        '{' \
        '    int port = 0;' \
        '' \
        '    assert(parse_port("80", &port) == 0);' \
        '    assert(port == 80);' \
        '' \
        '    assert(parse_port("65535", &port) == 0);' \
        '    assert(port == 65535);' \
        '' \
        '    assert(parse_port("0", &port) != 0);' \
        '    assert(parse_port("65536", &port) != 0);' \
        '    assert(parse_port("abc", &port) != 0);' \
        '    assert(parse_port(NULL, &port) != 0);' \
        '    assert(parse_port("80", NULL) != 0);' \
        '}' \
        '' \
        'int main(void)' \
        '{' \
        '    test_bounded_strlen();' \
        '    test_parse_port();' \
        '    return 0;' \
        '}'

    printf '%s\n' $test_content > tests/test_target.c


    # ========================================================
    # .clangd
    # ========================================================

    set -l clangd_content \
        'CompileFlags:' \
        '  CompilationDatabase: build' \
        '' \
        'Diagnostics:' \
        '  UnusedIncludes: Strict' \
        '' \
        'Index:' \
        '  Background: Build'

    printf '%s\n' $clangd_content > .clangd


    # ========================================================
    # fuzz/fuzz_target.c
    # ========================================================

    set -l fuzz_content \
        '#include "target.h"' \
        '' \
        '#include <stdio.h>' \
        '#include <stdlib.h>' \
        '#include <stddef.h>' \
        '#include <stdint.h>' \
        '' \
        'int LLVMFuzzerTestOneInput(const uint8_t *data, size_t size);' \
        'int LLVMFuzzerTestOneInput(const uint8_t *data, size_t size)' \
        '{' \
        '    int out = 0;' \
        '    char buf[64];' \
        '    size_t i = 0;' \
        '' \
        '    if (data == NULL || size == 0)' \
        '    {' \
        '        return 0;' \
        '    }' \
        '' \
        '    for (i = 0; i < size && i < sizeof(buf) - 1; ++i)' \
        '    {' \
        '        buf[i] = (char)data[i];' \
        '    }' \
        '' \
        '    buf[i] = '\''\0'\'';' \
        '' \
        '    (void)bounded_strlen(buf, sizeof(buf));' \
        '    (void)parse_port(buf, &out);' \
        '' \
        '    return 0;' \
        '}'

    set fuzz_content $fuzz_content \
        '' \
        'int main(void)' \
        '{' \
        '    uint8_t buf[64];' \
        '    size_t n = 0;' \
        '' \
        '    while ((n = fread(buf, 1, sizeof(buf), stdin)) > 0)' \
        '    {' \
        '        (void)LLVMFuzzerTestOneInput(buf, n);' \
        '    }' \
        '' \
        '    if (ferror(stdin))' \
        '    {' \
        '        return EXIT_FAILURE;' \
        '    }' \
        '' \
        '    return EXIT_SUCCESS;' \
        '}'

    printf '%s\n' $fuzz_content > fuzz/fuzz_target.c

    # ========================================================
    # .clang-format
    # ========================================================

    set -l clang_format_content \
        'BasedOnStyle: LLVM' \
        'IndentWidth: 4' \
        'TabWidth: 4' \
        'UseTab: Never' \
        'ColumnLimit: 100' \
        'BreakBeforeBraces: Allman'

    printf '%s\n' $clang_format_content > .clang-format

    # ========================================================
    # .clang-tidy
    # ========================================================

    set -l clang_tidy_content \
        'Checks: >-' \
        '  -*,' \
        '  bugprone-*,' \
        '  cert-*,' \
        '  clang-analyzer-*,' \
        '  concurrency-*,' \
        '  cppcoreguidelines-*,' \
        '  performance-*,' \
        '  portability-*,' \
        '  readability-*' \
        'WarningsAsErrors: '\'''\''' \
        'HeaderFilterRegex: '\''include/.*'\''' \
        'FormatStyle: file'

    printf '%s\n' $clang_tidy_content > .clang-tidy

    # ========================================================
    # .gitignore
    # ========================================================

    set -l gitignore_content \
        'build/' \
        'build-asan/' \
        'build-ubsan/' \
        'build-msan/' \
        'build-tsan/' \
        'build-release/' \
        'compile_commands.json' \
        '' \
        '.vscode/' \
        '.idea/' \
        '' \
        '*.o' \
        '*.a' \
        '*.so' \
        '*.out' \
        '' \
        'core' \
        'core.*' \
        'vgcore.*' \
        'massif.out.*'

    printf '%s\n' $gitignore_content > .gitignore

    # ========================================================
    # CMakePresets.json
    # ========================================================

    set -l presets_content \
        '{' \
        '  "version": 6,' \
        '  "cmakeMinimumRequired": {' \
        '    "major": 3,' \
        '    "minor": 22,' \
        '    "patch": 0' \
        '  },' \
        '  "configurePresets": [' \
        '    {' \
        '      "name": "debug",' \
        '      "generator": "Ninja",' \
        '      "binaryDir": "${sourceDir}/build",' \
        '      "cacheVariables": {' \
        '        "CMAKE_BUILD_TYPE": "Debug",' \
        '        "CMAKE_EXPORT_COMPILE_COMMANDS": "ON"' \
        '      }' \
        '    },' \
        '    {' \
        '      "name": "asan-ubsan",' \
        '      "inherits": "debug",' \
        '      "binaryDir": "${sourceDir}/build-asan",' \
        '      "cacheVariables": {' \
        '        "ENABLE_ASAN": "ON",' \
        '        "ENABLE_UBSAN": "ON",' \
        '        "ENABLE_TSAN": "OFF",' \
        '        "ENABLE_MSAN": "OFF"' \
        '      }' \
        '    },' \
        '    {' \
        '      "name": "tsan",' \
        '      "inherits": "debug",' \
        '      "binaryDir": "${sourceDir}/build-tsan",' \
        '      "cacheVariables": {' \
        '        "ENABLE_ASAN": "OFF",' \
        '        "ENABLE_UBSAN": "OFF",' \
        '        "ENABLE_TSAN": "ON",' \
        '        "ENABLE_MSAN": "OFF"' \
        '      }' \
        '    },' \
        '    {' \
        '      "name": "msan-clang",' \
        '      "inherits": "debug",' \
        '      "binaryDir": "${sourceDir}/build-msan",' \
        '      "cacheVariables": {' \
        '        "CMAKE_C_COMPILER": "clang",' \
        '        "ENABLE_ASAN": "OFF",' \
        '        "ENABLE_UBSAN": "OFF",' \
        '        "ENABLE_TSAN": "OFF",' \
        '        "ENABLE_MSAN": "ON"' \
        '      }' \
        '    },' \
        '    {' \
        '      "name": "release-hardened",' \
        '      "inherits": "debug",' \
        '      "binaryDir": "${sourceDir}/build-release",' \
        '      "cacheVariables": {' \
        '        "CMAKE_BUILD_TYPE": "Release",' \
        '        "ENABLE_ASAN": "OFF",' \
        '        "ENABLE_UBSAN": "OFF",' \
        '        "ENABLE_TSAN": "OFF",' \
        '        "ENABLE_MSAN": "OFF",' \
        '        "ENABLE_LTO": "ON",' \
        '        "ENABLE_HARDENING": "ON"' \
        '      }' \
        '    }' \
        '  ],' \
        '  "buildPresets": [' \
        '    { "name": "debug", "configurePreset": "debug" },' \
        '    { "name": "asan-ubsan", "configurePreset": "asan-ubsan" },' \
        '    { "name": "tsan", "configurePreset": "tsan" },' \
        '    { "name": "msan-clang", "configurePreset": "msan-clang" },' \
        '    { "name": "release-hardened", "configurePreset": "release-hardened" }' \
        '  ],' \
        '  "testPresets": [' \
        '    { "name": "debug", "configurePreset": "debug", "output": { "outputOnFailure": true } },' \
        '    { "name": "asan-ubsan", "configurePreset": "asan-ubsan", "output": { "outputOnFailure": true } },' \
        '    { "name": "tsan", "configurePreset": "tsan", "output": { "outputOnFailure": true } },' \
        '    { "name": "msan-clang", "configurePreset": "msan-clang", "output": { "outputOnFailure": true } },' \
        '    { "name": "release-hardened", "configurePreset": "release-hardened", "output": { "outputOnFailure": true } }' \
        '  ]' \
        '}'

    printf '%s\n' $presets_content > CMakePresets.json

    # ========================================================
    # README.md
    # ========================================================

    set -l readme_content \
        '# C23 Security Research Project' \
        '' \
        '## Tooling' \
        '' \
        '- C23 + CMake' \
        '- GCC / Clang' \
        '- clangd / clang-format / clang-tidy' \
        '- GDB / LLDB' \
        '- ELF/DWARF inspection (readelf, objdump, nm, strings)' \
        '- ASan, UBSan, optional MSan/TSan' \
        '- Valgrind' \
        '- cppcheck / flawfinder (if installed)' \
        '' \
        '## Build' \
        '' \
        '```bash' \
        'cmake --preset debug' \
        'cmake --build --preset debug' \
        'ctest --preset debug' \
        '```' \
        '' \
        '### Classic CMake' \
        '' \
        '```bash' \
        'cmake -S . -B build -DCMAKE_BUILD_TYPE=Debug' \
        'cmake --build build -j' \
        'ctest --test-dir build --output-on-failure' \
        '```' \
        '' \
        '## Static Analysis' \
        '' \
        '```bash' \
        'cmake --build build --target analyze-all' \
        '```' \
        '' \
        '## ELF Analysis' \
        '' \
        '```bash' \
        'cmake --build build --target sec-all' \
        'readelf -W -a build/app' \
        'objdump -d -M intel build/app' \
        '```'

    printf '%s\n' $readme_content > README.md

    # ========================================================
    # Bootstrap
    # ========================================================

    echo ""
    echo "C23 security research project created:"
    echo "  $project_dir"
    echo ""
    echo "Running bootstrap: configure + build + test"
    echo ""

    cmake -S . -B build \
        -DCMAKE_BUILD_TYPE=Debug \
        -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
    or begin
        echo "Bootstrap failed at configure step."
        return 1
    end

    cmake --build build -j
    or begin
        echo "Bootstrap failed at build step."
        return 1
    end

    ctest --test-dir build --output-on-failure
    or begin
        echo "Bootstrap failed at test step."
        return 1
    end

    if test -e build/compile_commands.json
        if test -L compile_commands.json
            rm compile_commands.json
        else if test -e compile_commands.json
            rm compile_commands.json
        end

        ln -s build/compile_commands.json compile_commands.json
    end

    echo ""
    echo "Bootstrap complete."
    echo ""
    echo "Build & test:"
    echo "  cmake --build build"
    echo "  ctest --test-dir build --output-on-failure"
    echo ""
    echo "Static analysis:"
    echo "  cmake --build build --target analyze-clang-tidy"
    echo "  cmake --build build --target analyze-cppcheck"
    echo "  cmake --build build --target analyze-flawfinder"
    echo "  cmake --build build --target analyze-all"
    echo ""
    echo "Binary / ELF security analysis:"
    echo "  cmake --build build --target sec-elf"
    echo "  cmake --build build --target sec-disasm"
    echo "  cmake --build build --target sec-symbols"
    echo "  cmake --build build --target sec-strings"
    echo "  cmake --build build --target sec-checksec"
    echo "  cmake --build build --target sec-all"
    echo ""
    echo "Targets:"
    echo "  app         - main application"
    echo "  unit_tests  - unit test suite"
    echo "  fuzz_target - fuzzing harness"
    echo ""
    echo "Example:"
    echo "  cmake --build build --target sec-all"
    echo ""

    if test "$full_scan" = "1"
        echo ""
        echo "Running full scan: analyze-all + sec-all"
        echo ""

        cmake --build build --target analyze-all
        or begin
            echo "Full scan failed at analyze-all target."
            return 1
        end

        cmake --build build --target sec-all
        or begin
            echo "Full scan failed at sec-all target."
            return 1
        end
    end

    echo ""
    echo "Project ready: $project_dir"
    return 0
end


# ============================================================
# PUBLIC COMMAND
# Usage:
#   create-c-pro new NAME
#   create-c-pro new NAME 1
# ============================================================

function create-c-pro --argument-names command name full_scan
    switch "$command"
        case new
            if test -z "$name"
                echo "Usage: create-c-pro new NAME [full_scan]"
                echo ""
                echo "Examples:"
                echo "  create-c-pro new testnew"
                echo "  create-c-pro new testnew 1"
                return 2
            end

            if test "$full_scan" = "1"
                __cpro_scaffold "$name" 1
            else
                __cpro_scaffold "$name" 0
            end

        case '*'
            echo "Usage: create-c-pro new NAME [full_scan]"
            return 2
    end
end

# function create-c-pro
#     if test (count $argv) -lt 2
#         echo "Usage: create-c-pro new <project-name> [--full-scan]"
#         return 1
#     end

#     set -l action $argv[1]

#     switch $action
#         case new
#             if test (count $argv) -lt 2
#                 echo "Usage: create-c-pro new <project-name> [--full-scan]"
#                 return 1
#             end

#             set -l full_scan 0
#             if test (count $argv) -gt 2
#                 for opt in $argv[3..-1]
#                     switch $opt
#                         case --full-scan
#                             set full_scan 1
#                         case '*'
#                             echo "Unknown option: $opt"
#                             echo "Usage: create-c-pro new <project-name> [--full-scan]"
#                             return 1
#                     end
#                 end
#             end

#             __cpro_scaffold $argv[2] $full_scan
#             return $status
#         case '*'
#             echo "Unknown action: $action"
#             echo "Usage: create-c-pro new <project-name> [--full-scan]"
#             return 1
#     end
# end


function create-c
    if test (count $argv) -ne 1
        echo "Usage: create-c <project-name>"
        return 1
    end

    create-c-pro new $argv[1]
end


# ============================================================
# OPTIONAL FORMAT / LINT HELPERS
# ============================================================

function cformat
    if test (count $argv) -eq 0
        echo "Usage: cformat <file.c> [file.h ...]"
        return 1
    end

    clang-format -i $argv
end


function cformat-check
    if test (count $argv) -eq 0
        echo "Usage: cformat-check <file.c> [file.h ...]"
        return 1
    end

    clang-format --dry-run --Werror $argv
end


function ctidy
    if not test -f compile_commands.json
        echo "compile_commands.json not found."
        echo "Run: c-config"
        return 1
    end

    clang-tidy $argv
end


# ============================================================
# END
# ============================================================
