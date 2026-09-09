function jtime --description "Modern benchmarking, profiling and tracing tool"

    # Hilfe anzeigen, falls keine Argumente übergeben wurden
    if test (count $argv) -eq 0
        echo "Usage: jtime [OPTION] [COMMAND]"
        echo ""
        echo "Options:"
        echo "  -full       Uses GNU time for detailed system statistics"
        echo "  -bench      Uses hyperfine for precise CLI benchmarks (including warmup & no-shell)"
        echo "  -ram        Uses Valgrind Massif for RAM profiling over time"
        echo "  -perf       Uses Linux perf stat for CPU cycles and cache misses"
        echo "  -syscall    Uses strace for a tabular overview of all system calls"
        echo "  -lib        Uses ltrace for calls to dynamic libraries (libc)"
        echo "  [COMMAND]   Without an option, uses Fish's built-in standard time"
        return 1
    end

    # Parameter auswerten
    switch $argv[1]
        case -full
            # GNU time erwartet Optionen VOR dem Befehl. --color=always entfernt, da inkompatibel.
            /usr/bin/time -v $argv[2..-1]
        case -bench
            # Hyperfine optimiert für schnelle Programme mit Warmup und ohne Shell-Overhead
            hyperfine -N --warmup 10 $argv[2..-1]
        case -ram
            # Speicher-Profiling mit Valgrind Massif
            valgrind --tool=massif $argv[2..-1]
            echo "-> Analysis completed. Use 'ms_print massif.out.<pid>' to visualize."
        case -perf
            # Hardware-Zähler der CPU auslesen
            perf stat $argv[2..-1]
        case -syscall
            # Tabellarische Zusammenfassung aller Kernel-Systemaufrufe
            strace -c $argv[2..-1]
        case -lib
            # Aufrufe von Shared Libraries (z.B. printf, malloc) loggen
            ltrace $argv[2..-1]
        case '*'
            # Standard-Fallback: Nutzt das Fish-eigene time-Builtin
            time $argv
    end

end
