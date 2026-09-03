function jtime --description "Modernes Benchmarking-, Profiling- und Tracing-Werkzeug"
    # Hilfe anzeigen, falls keine Argumente übergeben wurden
    if test (count $argv) -eq 0
        echo "Nutzung: jtime [OPTION] [BEFEHL]"
        echo ""
        echo "Optionen:"
        echo "  -full       Nutzt GNU time für detaillierte Systemstatistiken"
        echo "  -bench      Nutzt hyperfine für präzise CLI-Benchmarks (inkl. Warmup & No-Shell)"
        echo "  -ram        Nutzt Valgrind Massif für RAM-Profiling über Zeit"
        echo "  -perf       Nutzt Linux perf stat für CPU-Zyklen und Cache-Misses"
        echo "  -syscall    Nutzt strace für eine tabellarische Übersicht aller Systemaufrufe"
        echo "  -lib        Nutzt ltrace für Aufrufe von dynamischen Bibliotheken (libc)"
        echo "  [Befehl]    Ohne Option wird das Fish-eigene Standard-time genutzt"
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
            echo "-> Analyse abgeschlossen. Nutze 'ms_print massif.out.<pid>' zum Visualisieren."
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
