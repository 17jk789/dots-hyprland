<pre align="center">
     ██╗██╗  ██╗      █████╗ ██████╗  ██████╗██╗  ██╗
     ██║██║ ██╔╝     ██╔══██╗██╔══██╗██╔════╝██║  ██║
     ██║█████╔╝█████╗███████║██████╔╝██║     ███████║
██   ██║██╔═██╗╚════╝██╔══██║██╔══██╗██║     ██╔══██║
╚█████╔╝██║  ██╗     ██║  ██║██║  ██║╚██████╗██║  ██║
 ╚════╝ ╚═╝  ╚═╝     ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝
</pre>

# Manual

In diesem Handbuch werden die Schritte zur Installation und Konfiguration von Arch Linux mit dem JK-Arch-Installer beschrieben. Es umfasst die Einrichtung der im Installer vorgesehenen Entwicklungsumgebungen, Sicherheitsmaßnahmen und Softwarepakete.

Der Inhalt orientiert sich vollständig an den Funktionen und Installationsschritten von `inateller.py`. Es werden keine zusätzlichen Schritte oder Konfigurationen beschrieben, die nicht Bestandteil der eigentlichen Installation sind.

- [Manual](#manual)
- [Meine Arch Config → GO!!!](#meine-arch-config--go)
  - [Entwicklung Plugins](#entwicklung-plugins)
    - [Zum Startpunkt wechseln](#zum-startpunkt-wechseln)
    - [Die schnellsten Mirrors finden](#die-schnellsten-mirrors-finden)
    - [✨ DNS temporär auf Cloudflare (1.1.1.1) setzen](#-dns-temporär-auf-cloudflare-1111-setzen)
    - [Das System aktualisieren](#das-system-aktualisieren)
    - [Die Werkzeuge für den Bau von Software installieren](#die-werkzeuge-für-den-bau-von-software-installieren)
    - [Die Firewall sofort einschalten und dauerhaft aktivieren](#die-firewall-sofort-einschalten-und-dauerhaft-aktivieren)
    - [UFW später verwalten](#ufw-später-verwalten)
    - [Die end-4/jk-arch Hyperland Konfiguration herunterladen und die Installation starten](#die-end-4jk-arch-hyperland-konfiguration-herunterladen-und-die-installation-starten)
    - [Den Quellcode von yay herunterladen und das Programm bauen und installieren](#den-quellcode-von-yay-herunterladen-und-das-programm-bauen-und-installieren)
    - [Kern-Werkzeuge und Entwickler-Tools installieren](#kern-werkzeuge-und-entwickler-tools-installieren)
      - [Basis-Tools](#basis-tools)
      - [Compiler \& Toolchain](#compiler--toolchain)
      - [Debugging](#debugging)
      - [Reverse Engineering](#reverse-engineering)
      - [Fuzzing \& Performance](#fuzzing--performance)
      - [GUI-Bibliotheken](#gui-bibliotheken)
      - [Desktop-Integration](#desktop-integration)
      - [Lua-Entwicklung](#lua-entwicklung)
    - [Die Programmiersprache Lua in der Version 5.1 installieren](#die-programmiersprache-lua-in-der-version-51-installieren)
      - [✨ GDB-Konfiguration](#-gdb-konfiguration)
    - [Das Multilib-Repository in den Systemquellen aktivieren](#das-multilib-repository-in-den-systemquellen-aktivieren)
    - [Rust und Cargo installieren](#rust-und-cargo-installieren)
    - [Plugin für Decompilation in radare2 (Terminal)](#plugin-für-decompilation-in-radare2-terminal)
    - [Go und Make über den Paketmanager installieren](#go-und-make-über-den-paketmanager-installieren)
      - [Weitere optionale Tools](#weitere-optionale-tools)
    - [✨ C/C++ Advanced Debugging installieren](#-cc-advanced-debugging-installieren)
    - [Mehrere Java-Versionen sowie Gradle und Maven installieren](#mehrere-java-versionen-sowie-gradle-und-maven-installieren)
    - [Java-Versionen installieren](#java-versionen-installieren)
    - [Maven installieren](#maven-installieren)
    - [Gradle installieren](#gradle-installieren)
    - [Den x86-Assembler und grundlegende Binär-Werkzeuge installieren](#den-x86-assembler-und-grundlegende-binär-werkzeuge-installieren)
    - [Das Exploit-Entwicklungs-Framework Pwntools installieren](#das-exploit-entwicklungs-framework-pwntools-installieren)
    - [✨ Die Programmiersprache und Compiler-Toolchain Zig installieren](#-die-programmiersprache-und-compiler-toolchain-zig-installieren)
    - [Die JetBrains Toolbox installieren und starten](#die-jetbrains-toolbox-installieren-und-starten)
    - [Docker und Erweiterungen installieren](#docker-und-erweiterungen-installieren)
    - [Nützliche Systemwerkzeuge und Python einrichten](#nützliche-systemwerkzeuge-und-python-einrichten)
    - [Ultraschnelle Textsuche installieren](#ultraschnelle-textsuche-installieren)
    - [✨ Die intelligente Ordner-Navigation einrichten](#-die-intelligente-ordner-navigation-einrichten)
    - [JavaScript-Laufzeitumgebung und Paketmanager installieren](#javascript-laufzeitumgebung-und-paketmanager-installieren)
    - [.NET SDK installieren](#net-sdk-installieren)
      - [.NET globale Tools verfügbar machen](#net-globale-tools-verfügbar-machen)
    - [Das Standard-Kompressionswerkzeug installieren](#das-standard-kompressionswerkzeug-installieren)
    - [✨ TypeScript installieren](#-typescript-installieren)
    - [Die ultimative LaTeX-Umgebung installieren](#die-ultimative-latex-umgebung-installieren)
    - [Die Rechtschreibprüfung für Deutsch und Englisch installieren](#die-rechtschreibprüfung-für-deutsch-und-englisch-installieren)
    - [Moderne Terminal-Emulatoren installieren](#moderne-terminal-emulatoren-installieren)
    - [✨ Akku- und Hardware-Informationen auslesen](#-akku--und-hardware-informationen-auslesen)
    - [✨ Java-Laufzeitumgebung installieren](#-java-laufzeitumgebung-installieren)
    - [✨ Erweiterte Grammatik- und Stilprüfung mit LanguageTool](#-erweiterte-grammatik--und-stilprüfung-mit-languagetool)
    - [✨ LazyVim und JetBrains Mono Nerd Font installieren](#-lazyvim-und-jetbrains-mono-nerd-font-installieren)
      - [✨ LazyVim Starter-Konfiguration herunterladen](#-lazyvim-starter-konfiguration-herunterladen)
      - [✨ JetBrains Mono Nerd Font installieren](#-jetbrains-mono-nerd-font-installieren)
  - [Linux Power Tools](#linux-power-tools)
    - [Das System-Informationswerkzeug Fastfetch installieren](#das-system-informationswerkzeug-fastfetch-installieren)
    - [Den interaktiven Prozess-Viewer htop installieren](#den-interaktiven-prozess-viewer-htop-installieren)
    - [Den hochentwickelten System-Monitor btop installieren](#den-hochentwickelten-system-monitor-btop-installieren)
    - [✨ Den GPU-Prozess-Monitor nvtop installieren](#-den-gpu-prozess-monitor-nvtop-installieren)
    - [Den ultraschnellen Terminal-Dateimanager Yazi installieren](#den-ultraschnellen-terminal-dateimanager-yazi-installieren)
    - [✨ Den Terminal-Dateimanager und die Bildvorschau installieren](#-den-terminal-dateimanager-und-die-bildvorschau-installieren)
    - [Das Zeitmessungs-Werkzeug time installieren](#das-zeitmessungs-werkzeug-time-installieren)
    - [Installiere Radare2 (oft r2 genannt), den fortgeschrittenen Hex-Editor und Reverse-Engineering-Framework](#installiere-radare2-oft-r2-genannt-den-fortgeschrittenen-hex-editor-und-reverse-engineering-framework)
    - [Das professionelle Benchmarking-Werkzeug Hyperfine installieren](#das-professionelle-benchmarking-werkzeug-hyperfine-installieren)
    - [✨ Den Terminal-Multiplexer tmux installieren](#-den-terminal-multiplexer-tmux-installieren)
    - [✨ Den Anwendungsstarter Wofi installieren](#-den-anwendungsstarter-wofi-installieren)
    - [Den Hex-Editor GHex installieren](#den-hex-editor-ghex-installieren)
    - [Die moderne cat-Alternative bat installieren](#die-moderne-cat-alternative-bat-installieren)
    - [Das interaktive Git-Terminalwerkzeug LazyGit installieren](#das-interaktive-git-terminalwerkzeug-lazygit-installieren)
    - [Den Verzeichnisbaum-Generator tree installieren](#den-verzeichnisbaum-generator-tree-installieren)
    - [Das blitzschnelle Dateisuch-Werkzeug fd installieren](#das-blitzschnelle-dateisuch-werkzeug-fd-installieren)
    - [Die moderne und farbenfrohe ls-Alternative eza installieren](#die-moderne-und-farbenfrohe-ls-alternative-eza-installieren)
    - [✨ Die vereinfachten Community-Handbücher tldr installieren](#-die-vereinfachten-community-handbücher-tldr-installieren)
    - [✨ Den JSON-Datenprozessor jq installieren](#-den-json-datenprozessor-jq-installieren)
    - [Die grafische Monitor-Konfiguration nwg-displays installieren](#die-grafische-monitor-konfiguration-nwg-displays-installieren)
    - [Das Bildverarbeitungs-Framework ImageMagick installieren](#das-bildverarbeitungs-framework-imagemagick-installieren)
    - [✨ Den Tippfehler-Korrektor thefuck installieren](#-den-tippfehler-korrektor-thefuck-installieren)
    - [Microsoft Visual Studio Code (VS Code) installieren](#microsoft-visual-studio-code-vs-code-installieren)
    - [GitKraken über yay installieren](#gitkraken-über-yay-installieren)
    - [Den Discord-Client (Vesktop) über den Paketmanager installieren](#den-discord-client-vesktop-über-den-paketmanager-installieren)
    - [Den Signal Messenger installieren](#den-signal-messenger-installieren)
    - [Den Firefox Browser installieren](#den-firefox-browser-installieren)
    - [Den Brave Browser über yay installieren](#den-brave-browser-über-yay-installieren)
    - [✨ Den datenschutzfokussierten Mullvad Browser installieren](#-den-datenschutzfokussierten-mullvad-browser-installieren)
    - [✨ Google Chrome über den AUR-Helfer installieren](#-google-chrome-über-den-aur-helfer-installieren)
    - [✨ Den datenschutzfokussierten LibreWolf Browser installieren](#-den-datenschutzfokussierten-librewolf-browser-installieren)
    - [✨ Die Firefox Developer Edition installieren](#-die-firefox-developer-edition-installieren)
    - [Das grafische Archivierungsprogramm Ark installieren](#das-grafische-archivierungsprogramm-ark-installieren)
    - [Den erweiterten KDE-Texteditor Kate installieren](#den-erweiterten-kde-texteditor-kate-installieren)
    - [Der grafische Bildbetrachter Gwenview installieren](#der-grafische-bildbetrachter-gwenview-installieren)
    - [Der universelle Dokumentenbetrachter Okular installieren](#der-universelle-dokumentenbetrachter-okular-installieren)
    - [Den universellen Medienplayer VLC installieren](#den-universellen-medienplayer-vlc-installieren)
    - [✨ Den Audio-Editor Audacity installieren](#-den-audio-editor-audacity-installieren)
    - [✨ Die Wissensdatenbank Obsidian installieren](#-die-wissensdatenbank-obsidian-installieren)
    - [Den grafischen Plasma-Systemmonitor installieren](#den-grafischen-plasma-systemmonitor-installieren)
    - [✨ Den Taskmanager Mission Center über yay installieren](#-den-taskmanager-mission-center-über-yay-installieren)
    - [✨ Das digitale Mal- und Zeichenprogramm Krita installieren](#-das-digitale-mal--und-zeichenprogramm-krita-installieren)
    - [✨ Das Bildbearbeitungsprogramm GIMP installieren](#-das-bildbearbeitungsprogramm-gimp-installieren)
    - [✨ Das professionelle Videoschnittprogramm Kdenlive installieren](#-das-professionelle-videoschnittprogramm-kdenlive-installieren)
    - [✨ Das professionelle All-in-One-Videoschnittprogramm DaVinci Resolve installieren](#-das-professionelle-all-in-one-videoschnittprogramm-davinci-resolve-installieren)
    - [✨ Das plattformübergreifende Videoschnittprogramm Shotcut installieren](#-das-plattformübergreifende-videoschnittprogramm-shotcut-installieren)
    - [✨ Die 3D-Grafik- und Animations-Suite Blender installieren](#-die-3d-grafik--und-animations-suite-blender-installieren)
    - [✨ Den E-Mail- und Kalender-Client Thunderbird installieren](#-den-e-mail--und-kalender-client-thunderbird-installieren)
    - [Den wissenschaftlichen Taschenrechner Qalculate! installieren](#den-wissenschaftlichen-taschenrechner-qalculate-installieren)
    - [✨ Den Screenshot- und Bildschirmaufnahme-Manager Flameshot installieren](#-den-screenshot--und-bildschirmaufnahme-manager-flameshot-installieren)
    - [Die Streaming- und Aufnahme-Software OBS Studio installieren](#die-streaming--und-aufnahme-software-obs-studio-installieren)
    - [Das Software-Zentrum Discover und das Flatpak-System installieren](#das-software-zentrum-discover-und-das-flatpak-system-installieren)
    - [Die Desktop-Uhr KClock installieren](#die-desktop-uhr-kclock-installieren)
    - [✨ Den Morgen Calendar über yay installieren](#-den-morgen-calendar-über-yay-installieren)
    - [Das Smartphone-Integrationswerkzeug KDE Connect installieren](#das-smartphone-integrationswerkzeug-kde-connect-installieren)
    - [✨ Eine ältere Python-Version (3.12) über yay installieren](#-eine-ältere-python-version-312-über-yay-installieren)
    - [✨ Die Office-Suite LibreOffice installieren](#-die-office-suite-libreoffice-installieren)
    - [✨ Das Sandbox-Sicherheitswerkzeug Firejail installieren](#-das-sandbox-sicherheitswerkzeug-firejail-installieren)
    - [✨ Das vollständige Linux-Drucksystem CUPS für Hyprland mit KDE-Tools einrichten](#-das-vollständige-linux-drucksystem-cups-für-hyprland-mit-kde-tools-einrichten)
    - [✨ Die moderne LaTeX-Alternative Tectonic und den Dokumenten-Konverter Pandoc einrichten](#-die-moderne-latex-alternative-tectonic-und-den-dokumenten-konverter-pandoc-einrichten)
    - [✨ Die Rust-Alternative für den sudo-Befehl installieren](#-die-rust-alternative-für-den-sudo-befehl-installieren)
    - [Die HEIF- und AVIF-Bildbibliothek libheif installieren](#die-heif--und-avif-bildbibliothek-libheif-installieren)
    - [Die erweiterten Bildformat-Plugins für KDE installieren](#die-erweiterten-bildformat-plugins-für-kde-installieren)
    - [Den Netzwerk-Bandbreiten-Monitor bandwhich installieren](#den-netzwerk-bandbreiten-monitor-bandwhich-installieren)
    - [Den Netzwerk-Protokollanalysator Wireshark installieren](#den-netzwerk-protokollanalysator-wireshark-installieren)
    - [Den zweispaltigen Dateimanager Krusader installieren](#den-zweispaltigen-dateimanager-krusader-installieren)
    - [Das offizielle 7-Zip-Kompressionswerkzeug installieren](#das-offizielle-7-zip-kompressionswerkzeug-installieren)
    - [QEMU, KVM und die grafische Verwaltung Virt-Manager installieren](#qemu-kvm-und-die-grafische-verwaltung-virt-manager-installieren)
      - [Das Highlight: Der optimale QEMU-Startbefell für Ubuntu 26.04 LTS, Kali Linux 2026, Cachy OS + BlackArch Linux](#das-highlight-der-optimale-qemu-startbefell-für-ubuntu-2604-lts-kali-linux-2026-cachy-os--blackarch-linux)
        - [Ubuntu](#ubuntu)
          - [Ubuntu: Installation mit GTK und Sicherheits-Sandbox](#ubuntu-installation-mit-gtk-und-sicherheits-sandbox)
          - [Ubuntu: Standard-Start mit GTK-Display und Hardware-GL](#ubuntu-standard-start-mit-gtk-display-und-hardware-gl)
          - [Ubuntu: Erweiterte Ausführung mit SDL-OpenGL und Hardware-Virtualisierung](#ubuntu-erweiterte-ausführung-mit-sdl-opengl-und-hardware-virtualisierung)
          - [Ubuntu: Full-Featured mit Spice-Unterstützung und Audio-PipeWire](#ubuntu-full-featured-mit-spice-unterstützung-und-audio-pipewire)
          - [Ubuntu: High-Performance mit Cache=none und Native AIO](#ubuntu-high-performance-mit-cachenone-und-native-aio)
          - [Ubuntu: Spice-Server mit RNG-Entropie und Vollem Sicherheits-Setup](#ubuntu-spice-server-mit-rng-entropie-und-vollem-sicherheits-setup)
          - [Ubuntu: **Empfohlener Standard** (Optimiert für Performance \& Sicherheit)](#ubuntu-empfohlener-standard-optimiert-für-performance--sicherheit)
        - [Kali](#kali)
          - [Kali Linux: Minimal-Konfiguration für schnelle Tests](#kali-linux-minimal-konfiguration-für-schnelle-tests)
          - [Kali Linux: Erweitertes Setup mit hochauflösender Grafik](#kali-linux-erweitertes-setup-mit-hochauflösender-grafik)
          - [Kali Linux: Komfortabel mit Spice und Clipboard-Integration](#kali-linux-komfortabel-mit-spice-und-clipboard-integration)
          - [Kali Linux: Maximal sicher mit Q35-Maschine und RNG](#kali-linux-maximal-sicher-mit-q35-maschine-und-rng)
          - [Kali Linux: Kompakt mit 1080p-Auflösung und Spice](#kali-linux-kompakt-mit-1080p-auflösung-und-spice)
          - [Kali Linux: SDL-Display mit Hardware-Virtualisierung und Audio](#kali-linux-sdl-display-mit-hardware-virtualisierung-und-audio)
          - [Kali Linux: Hochperformant mit Cache=none und Native AIO](#kali-linux-hochperformant-mit-cachenone-und-native-aio)
          - [Kali Linux: **Empfohlene Standard-Konfiguration** (Sicher \& Schnell)](#kali-linux-empfohlene-standard-konfiguration-sicher--schnell)
          - [Kali Linux: **Minimales Sicherheits-Setup** für Isolation](#kali-linux-minimales-sicherheits-setup-für-isolation)
        - [Cachy OS + Black Arch](#cachy-os--black-arch)
          - [Cachy OS \& BlackArch: Vorbereitung (Disk \& UEFI-Variablen)](#cachy-os--blackarch-vorbereitung-disk--uefi-variablen)
          - [Cachy OS \& BlackArch: Installation mit UEFI und Sandbox](#cachy-os--blackarch-installation-mit-uefi-und-sandbox)
          - [Cachy OS \& BlackArch: **Empfohlene Konfiguration** (UEFI, OpenGL, PipeWire)](#cachy-os--blackarch-empfohlene-konfiguration-uefi-opengl-pipewire)
          - [Cachy OS \& BlackArch: **Minimales Sicherheits-Setup** ohne UEFI-Komplexität](#cachy-os--blackarch-minimales-sicherheits-setup-ohne-uefi-komplexität)
      - [Ubuntu Configuration](#ubuntu-configuration)
        - [Bei Ubuntu noch](#bei-ubuntu-noch)
      - [BlackArch Configuration](#blackarch-configuration)
        - [BlackArch installieren](#blackarch-installieren)
          - [Cool bei Kde Plasma](#cool-bei-kde-plasma)
        - [Pentesting Tools installieren](#pentesting-tools-installieren)
      - [Kali-Linux Configuration](#kali-linux-configuration)
        - [Passwort ändern](#passwort-ändern)
        - [Snap installieren](#snap-installieren)
        - [Basis-Tools](#basis-tools-1)
        - [Compiler \& Toolchain](#compiler--toolchain-1)
        - [Debugging](#debugging-1)
        - [Reverse Engineering](#reverse-engineering-1)
        - [Fuzzing \& Performance](#fuzzing--performance-1)
        - [GUI-Bibliotheken](#gui-bibliotheken-1)
        - [Benchmarking \& Profiling](#benchmarking--profiling)
        - [Rust](#rust)
        - [Java](#java)
        - [Docker](#docker)
        - [Ghidra](#ghidra)
        - [Fish](#fish)
        - [Update NeoVim](#update-neovim)
      - [Metaexploitable 2](#metaexploitable-2)
        - [Blackarch starten](#blackarch-starten)
        - [Metasploitable 2 starten](#metasploitable-2-starten)
        - [In Blackarch](#in-blackarch)
        - [In Metasploitable 2](#in-metasploitable-2)
        - [Verbindung testen: Von BlackArch aus](#verbindung-testen-von-blackarch-aus)
          - [Ping Metasploitable](#ping-metasploitable)
          - [Ping Internet (muss fehlschlagen)](#ping-internet-muss-fehlschlagen)
          - [Prüfe Firewall-Regeln](#prüfe-firewall-regeln)
        - [Metasploit starten](#metasploit-starten)
    - [✨ Den grafischen Audio-Mixer pwvucontrol installieren](#-den-grafischen-audio-mixer-pwvucontrol-installieren)
    - [✨ Den grafischen Audio-Verkabelungs-Manager qpwgraph installieren](#-den-grafischen-audio-verkabelungs-manager-qpwgraph-installieren)
    - [✨ Die lokale KI-Laufzeitumgebung Ollama installieren](#-die-lokale-ki-laufzeitumgebung-ollama-installieren)
    - [✨ Den Remote-Desktop-Client KRDC installieren](#-den-remote-desktop-client-krdc-installieren)
    - [✨ Den ultraschnellen Download-Manager aria2 installieren](#-den-ultraschnellen-download-manager-aria2-installieren)
    - [✨ Das strukturelle Diff-Werkzeug Difftastic installieren](#-das-strukturelle-diff-werkzeug-difftastic-installieren)
    - [✨ Das offizielle GitHub-Kommandozeilenwerkzeug (GitHub CLI) installieren](#-das-offizielle-github-kommandozeilenwerkzeug-github-cli-installieren)
    - [Das Software-Reverse-Engineering-Framework Ghidra über yay installieren](#das-software-reverse-engineering-framework-ghidra-über-yay-installieren)
    - [✨ Das universitäre WLAN (eduroam) fehlerfrei einrichten](#-das-universitäre-wlan-eduroam-fehlerfrei-einrichten)
    - [✨ Die offizielle Open-Source-Alternative für Universitäts-VPNs installieren](#-die-offizielle-open-source-alternative-für-universitäts-vpns-installieren)
    - [Nützliche Fish plugins](#nützliche-fish-plugins)
    - [Modernes Datei-Listing und ein interaktiver Terminal-Spickzettel](#modernes-datei-listing-und-ein-interaktiver-terminal-spickzettel)
      - [Die offizielle Spickzettel-Datenbank für navi hinzufügen](#die-offizielle-spickzettel-datenbank-für-navi-hinzufügen)
    - [✨ Die CachyOS-spezifischen Spickzettel für navi hinzufügen (Optional)](#-die-cachyos-spezifischen-spickzettel-für-navi-hinzufügen-optional)
    - [Für yazi: Die Desktop-Integrationswerkzeuge xdg-utils installieren](#für-yazi-die-desktop-integrationswerkzeuge-xdg-utils-installieren)
    - [Für yazi: Die MIME-Typ-Erkennung perl-file-mimeinfo installieren](#für-yazi-die-mime-typ-erkennung-perl-file-mimeinfo-installieren)
    - [✨ Mauszeiger-Animationen (Cursor Shaders) für Ghostty einrichten](#-mauszeiger-animationen-cursor-shaders-für-ghostty-einrichten)
    - [Einen modularen Fish-Konfigurationsordner erstellen](#einen-modularen-fish-konfigurationsordner-erstellen)
    - [✨ Den praktischen Befehls-Ausführer just installieren](#-den-praktischen-befehls-ausführer-just-installieren)
    - [✨ Das Begrüßungsprogramm von CachyOS entfernen](#-das-begrüßungsprogramm-von-cachyos-entfernen)
    - [✨ Die moderne Schachdatenbank- und Analyse-Software En Croissant installieren](#-die-moderne-schachdatenbank--und-analyse-software-en-croissant-installieren)
    - [✨ Den Boot-Bildschirm (Plymouth) anpassen und das System-Abbild neu bauen](#-den-boot-bildschirm-plymouth-anpassen-und-das-system-abbild-neu-bauen)
  - [Nach der Neovim-Konfiguration](#nach-der-neovim-konfiguration)
    - [Code über den LSP-Server im Editor formatieren](#code-über-den-lsp-server-im-editor-formatieren)
  - [Emfehlungen bei end-4 -\> fix soon](#emfehlungen-bei-end-4---fix-soon)
- [✨ UFW ist langsam](#-ufw-ist-langsam)
- [✨ Langsames Internet über WLAN beheben](#-langsames-internet-über-wlan-beheben)
- [✨ Firefox ist langsam](#-firefox-ist-langsam)
- [✨ Librewulf Google securtiy](#-librewulf-google-securtiy)
- [✨ Haskell-Pakete reparieren](#-haskell-pakete-reparieren)
- [✨ Cloudflare WARP („1.1.1.1“) installieren und einrichten](#-cloudflare-warp-1111-installieren-und-einrichten)
    - [✨ Wichtige WARP-Befehle](#-wichtige-warp-befehle)
- [✨ Tailscale installieren und einrichten](#-tailscale-installieren-und-einrichten)
    - [✨ Wichtige Tailscale-Befehle](#-wichtige-tailscale-befehle)
- [✨ ZRAM konfigurieren](#-zram-konfigurieren)
- [✨ CachyOS optimieren](#-cachyos-optimieren)
    - [✨ UKSM (Ultra Kernel Samepage Merging) aktivieren](#-uksm-ultra-kernel-samepage-merging-aktivieren)
- [✨ Remote Desktop Connection (Windows ↔ Linux)](#-remote-desktop-connection-windows--linux)
- [✨ Remote Desktop für Hyprland (Windows ↔ Linux)](#-remote-desktop-für-hyprland-windows--linux)
  - [Linux (Hyprland)](#linux-hyprland)
    - [✨ Sunshine installieren](#-sunshine-installieren)
    - [✨ Sunshine als User-Service einrichten](#-sunshine-als-user-service-einrichten)
    - [✨ Sunshine starten](#-sunshine-starten)
    - [✨ Sunshine-Firewall für das lokale Netzwerk konfigurieren](#-sunshine-firewall-für-das-lokale-netzwerk-konfigurieren)
    - [✨ Sunshine-Weboberfläche öffnen](#-sunshine-weboberfläche-öffnen)
    - [✨ Audio- und Monitorprobleme beheben](#-audio--und-monitorprobleme-beheben)
    - [✨ Cursor-Probleme unter Hyprland beheben](#-cursor-probleme-unter-hyprland-beheben)
  - [Windows](#windows)
    - [✨ Moonlight installieren](#-moonlight-installieren)
    - [✨ Mit dem Linux-PC verbinden](#-mit-dem-linux-pc-verbinden)
- [✨ OpenClaw installieren und einrichten](#-openclaw-installieren-und-einrichten)
- [✨ Nach der Installation: System prüfen und absichern](#-nach-der-installation-system-prüfen-und-absichern)
  - [1. ✨ System aktualisieren und Fehler prüfen](#1--system-aktualisieren-und-fehler-prüfen)
  - [2. ✨ Netzwerk- und Portanalyse](#2--netzwerk--und-portanalyse)
  - [3. ✨ Paketdatenbank und Paketintegrität prüfen](#3--paketdatenbank-und-paketintegrität-prüfen)
    - [3.1 Paketdateien überprüfen](#31-paketdateien-überprüfen)
    - [3.2 ✨ Installierte Pakete und verdächtige Dateien untersuchen](#32--installierte-pakete-und-verdächtige-dateien-untersuchen)
    - [3.3 ✨ Kürzlich installierte Pakete anzeigen](#33--kürzlich-installierte-pakete-anzeigen)
    - [3.4 ✨ Laufende Dienste überprüfen](#34--laufende-dienste-überprüfen)
  - [4. ✨ Bei Fehlern Logs überprüfen](#4--bei-fehlern-logs-überprüfen)
  - [5. ✨ Bei beschädigten Paketen](#5--bei-beschädigten-paketen)
- [✨ Arch Linux Security-Hardening](#-arch-linux-security-hardening)
  - [1. ✨ AUR-Paketquellen auf verdächtige Befehle überprüfen](#1--aur-paketquellen-auf-verdächtige-befehle-überprüfen)
  - [2. ✨ Nach der Malware-Signatur `atomic-lockfile` suchen](#2--nach-der-malware-signatur-atomic-lockfile-suchen)
  - [3. ✨ Fremdpakete und Paketmanager-Historie überprüfen](#3--fremdpakete-und-paketmanager-historie-überprüfen)
  - [4. ✨ Virenscan mit ClamAV durchführen](#4--virenscan-mit-clamav-durchführen)
  - [5. ✨ Rootkits mit Rootkit Hunter überprüfen](#5--rootkits-mit-rootkit-hunter-überprüfen)
  - [6. ✨ Zusätzliche Rootkit-Prüfung mit chkrootkit](#6--zusätzliche-rootkit-prüfung-mit-chkrootkit)
  - [7. ✨ System mit Lynis überprüfen](#7--system-mit-lynis-überprüfen)
  - [✨ AppArmor sauber aktivieren](#-apparmor-sauber-aktivieren)
  - [✨ Globales Menü aktivieren](#-globales-menü-aktivieren)
  - [✨ SSH-Server deaktivieren](#-ssh-server-deaktivieren)
- [✨ Arch Linux AUR auf Malware überprüfen](#-arch-linux-aur-auf-malware-überprüfen)
  - [✨ AUR-Malware-Check installieren](#-aur-malware-check-installieren)
  - [✨ Risikofreien Testlauf durchführen](#-risikofreien-testlauf-durchführen)
  - [✨ Vollständigen Malware-Scan durchführen](#-vollständigen-malware-scan-durchführen)
  - [✨ Bei einem positiven Malware-Befund](#-bei-einem-positiven-malware-befund)
- [Use JK-Arch](#use-jk-arch)

# Meine Arch Config → GO!!!

Bevor wir mit der eigentlichen Konfiguration anfangen, bereiten wir erstmal unser System vor. Wir installieren die wichtigsten Werkzeuge, aktualisieren das System und holen anschließend die JK-Arch Config.

## Entwicklung Plugins

### Zum Startpunkt wechseln

```bash
cd ~
```

### Die schnellsten Mirrors finden

> Nur bei CachyOS, sonst überspringen.

```bash
sudo cachyos-rate-mirrors
```

### ✨ DNS temporär auf Cloudflare (1.1.1.1) setzen

> Falls dein DNS gerade mal wieder so performt, als würde dein Router die Anfrage persönlich mit der Post verschicken.

```bash
echo "nameserver 1.1.1.1" | sudo tee /etc/resolv.conf
```

### Das System aktualisieren

> Am besten regelmäßig machen – dein System mag Updates ungefähr so sehr wie du Kaffee am Morgen.

```bash
sudo pacman -Syu
```

### Die Werkzeuge für den Bau von Software installieren

> Wir brauchen `git`, um später die JK-Arch Config zu klonen. `base-devel` enthält außerdem die wichtigsten Werkzeuge, die wir für das Bauen und Installieren einiger Pakete benötigen.

```bash
sudo pacman -S --needed git base-devel
```

### Die Firewall sofort einschalten und dauerhaft aktivieren

> Wichtig -> Firewall aktivieren!!!

Für JK-Arch kannst du entweder **UFW** oder **firewalld** verwenden. Beide gleichzeitig solltest du nicht betreiben.

<details>
<summary>UFW installieren, falls noch nicht geschehen</summary>

```bash
sudo pacman -S ufw
```

</details>

UFW aktivieren und direkt starten:

```bash
sudo systemctl enable --now ufw
```

<details>
<summary>✨ Alternative zu UFW -> firewalld</summary>

Falls du lieber `firewalld` verwenden möchtest, installiere es stattdessen:

```bash
sudo pacman -S firewalld
```

Wenn UFW bereits aktiviert ist, solltest du es vorher stoppen und aus dem Autostart entfernen:

```bash
sudo systemctl stop ufw
sudo systemctl disable ufw
```

Danach `firewalld` aktivieren und starten:

```bash
sudo systemctl enable --now firewalld
```

</details>

<details>
<summary>Schnellstart mit UFW</summary>

Falls du einfach nur schnell eine funktionierende Firewall mit UFW möchtest:

```bash
sudo ufw default deny incoming # Alles, was von außen auf deinen Rechner möchte, wird standardmäßig abgelehnt.
sudo ufw default allow outgoing # Programme auf deinem Rechner dürfen standardmäßig Verbindungen nach außen aufbauen.
sudo ufw enable # UFW wird eingeschaltet und die vorher festgelegten Regeln werden aktiv.
```

Status überprüfen:

```bash
sudo systemctl status ufw
sudo ufw status verbose
```

### UFW später verwalten

Du kannst UFW jederzeit manuell aktivieren oder deaktivieren:

- Firewall aktivieren:

```bash
sudo ufw enable
```

- Firewall deaktivieren:

```bash
sudo ufw disable
```

- Status und Regeln anzeigen:

```bash
sudo ufw status verbose
```

- Alle Regeln anzeigen:

```bash
sudo ufw status numbered
```

Wenn du eine Regel über ihre Nummer entfernen möchtest:

```bash
sudo ufw delete <NUMMER>
```

> **Tipp:** UFW bleibt auch nach einem Neustart aktiviert, solange du es nicht mit `sudo ufw disable` deaktivierst. Der systemd-Dienst sorgt zusätzlich dafür, dass UFW beim Booten gestartet wird.

</details>

### Die end-4/jk-arch Hyperland Konfiguration herunterladen und die Installation starten

Als Nächstes installieren wir die end-4 Hyprland-Konfiguration. Sie dient als Grundlage für JK-Arch und wird später entsprechend angepasst.

Zuerst klonen wir das Repository und wechseln in das Verzeichnis:

```bash
git clone https://github.com/17jk789/dots-hyprland.git
cd dots-hyprland
```

Bevor wir das Installationsscript ausführen, schauen wir kurz nach, woher das Repository kommt, welchen Stand wir gerade verwenden und ob sich darin auffällige Befehle befinden.

Repository und Remote überprüfen:

```bash
git remote -v
```

Die letzten Commits anzeigen:

```bash
git log --oneline -5
```

Anschließend können wir nach einigen häufig verwendeten Befehlen suchen, die in Installationsscripts relevant sein können:

```bash
grep -RinE "curl|wget|bash -c|sh -c|eval|base64|sudo rm|rm -rf" .
```

Wenn alles für dich passt, kannst du die Installation starten:

```bash
./setup install
```

> **Wichtig**: Lies dir die Ausgaben des Installers durch und bestätige nur Schritte, bei denen du weißt, was sie machen. Ein Installationsscript solltest du grundsätzlich nicht blind mit sudo oder Root-Rechten ausführen.

### Den Quellcode von yay herunterladen und das Programm bauen und installieren

> `yay` ist ein AUR-Helper, mit dem du später bequem Pakete aus dem Arch User Repository (AUR) installieren und aktualisieren kannst.

Zuerst wechseln wir nach `/tmp`, klonen das offizielle yay-Repository vom AUR und bauen anschließend das Paket:

```bash
cd /tmp
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
```

`makepkg -si` übernimmt dabei das Bauen des Pakets und installiert anschließend das erzeugte Paket inklusive der benötigten Abhängigkeiten.

### Kern-Werkzeuge und Entwickler-Tools installieren

Jetzt wird's spaßig. 😎

Jetzt installieren wir die wichtigsten Werkzeuge für Entwicklung, Debugging, Reverse Engineering, Fuzzing und Security. Das ist der Teil, bei dem wir aus einer normalen Arch-Installation langsam eine richtige Power-User-Kiste machen.

#### Basis-Tools

> `curl` und `wget` laden Dateien aus dem Internet, `unzip` entpackt ZIP-Archive, `git-delta` macht Git-Diffs deutlich angenehmer lesbar, `fzf` bietet eine schnelle interaktive Suche im Terminal, `cmark` verarbeitet Markdown und `shellcheck` findet Fehler und typische Probleme in Shell-Scripts.

```bash
sudo pacman -S curl wget unzip git-delta fzf cmark shellcheck
```

#### Compiler & Toolchain

> `gcc`, `clang` und `llvm` bilden die Compiler-Toolchain, `lldb` und `clang-tools-extra` liefern zusätzliche Entwicklungs- und Debugging-Werkzeuge, `cmake` und `ninja` kümmern sich um Build-Systeme, `valgrind` analysiert Speicherfehler und `flawfinder`, `splint` und `bear` helfen bei Codeanalyse und der Entwicklung größerer C/C++-Projekte.

```bash
sudo pacman -S gcc lib32-gcc-libs llvm clang lldb cmake ninja valgrind clang-tools-extra flawfinder splint bear
```

#### Debugging

> `gdb` ist der klassische GNU-Debugger, `gef` und `pwndbg` erweitern GDB speziell für modernes Debugging und Binary Exploitation, während `strace` und `ltrace` zeigen, welche System- bzw. Library-Aufrufe ein Programm ausführt.

```bash
sudo pacman -S gdb gef pwndbg strace ltrace
```

#### Reverse Engineering

> `rizin` dient zur Analyse und zum Reverse Engineering von Binaries, `binwalk` untersucht Firmware und Binärdateien, `yara` erkennt Dateien anhand definierter Regeln, `elfutils` liefert Werkzeuge für ELF-Dateien und `checksec` zeigt wichtige Security-Eigenschaften von Binaries.

```bash
sudo pacman -S rizin binwalk yara elfutils checksec
```

#### Fuzzing & Performance

> `afl++` ist ein leistungsfähiger Fuzzer zum automatisierten Finden von Bugs, `perf` analysiert die Performance von Programmen und dem Linux-Kernel und `cppcheck` sucht nach möglichen Fehlern und Problemen in C/C++-Code.

```bash
sudo pacman -S afl++ perf cppcheck
```

#### GUI-Bibliotheken

> `gtk4` und `libadwaita` bilden die Grundlage für moderne Linux-GUIs, `librsvg` rendert SVG-Grafiken und `adwaita-icon-theme` stellt passende Icons für GTK-Anwendungen bereit.

```bash
sudo pacman -S gtk4 libadwaita librsvg adwaita-icon-theme
```

#### Desktop-Integration

> `network-manager-applet` stellt eine grafische Oberfläche für NetworkManager bereit und `polkit-gnome` ermöglicht grafische Authentifizierungsdialoge für Anwendungen.

```bash
sudo pacman -S network-manager-applet polkit-gnome
```

#### Lua-Entwicklung

> `luarocks` ist der Paketmanager für Lua und wird benötigt, um Lua-Bibliotheken und Module einfach zu installieren und zu verwalten. Sowohl die Hyprland-Konfiguration als auch meine NeoVim-Konfiguration benötigen Lua bzw. Lua-Module, daher installieren wir es direkt mit.

```bash
sudo pacman -S luarocks
```

### Die Programmiersprache Lua in der Version 5.1 installieren

> Lua 5.1 wird von einigen älteren Lua-Modulen und Tools benötigt und kann parallel zu neueren Lua-Versionen installiert werden. Für bestimmte Neovim-Plugins oder Entwicklungsumgebungen ist diese Version weiterhin relevant.

```bash
sudo pacman -S --needed lua51
```

#### ✨ GDB-Konfiguration

Die zusätzliche GDB-Konfiguration musst du **nicht manuell** einrichten.

JK-Arch bringt dafür bereits eine eigene Fish-Funktion mit:

```text
~/.config/fish/functions/gdb.fish
```

Diese kümmert sich um die benötigte GDB-Konfiguration, sodass du normalerweise nichts weiter machen musst.

<details>
<summary>✨ Falls du die GDB-Konfiguration trotzdem manuell einrichten möchtest</summary>

Wenn du GEF verwenden möchtest, kannst du es über `~/.gdbinit` laden:

```bash
echo "source /usr/share/gef/gef.py" >> ~/.gdbinit
```

Alternativ kannst du Pwndbg laden:

```bash
echo "source /usr/share/pwndbg/gdbinit.py" >> ~/.gdbinit
```

> **Wichtig:** Lade nicht einfach beide Konfigurationen gleichzeitig. Entscheide dich für **GEF oder Pwndbg**, da beide GDB erweitern und sich gegenseitig in die Quere kommen können.

Falls du zusätzlich Core Dumps aktivieren möchtest, kannst du das temporär mit folgendem Befehl konfigurieren:

```bash
echo core | sudo tee /proc/sys/kernel/core_pattern
```

> **Hinweis:** Diese Einstellung für `core_pattern` ist nicht dauerhaft und kann nach einem Neustart wieder zurückgesetzt werden. JK-Arch übernimmt die entsprechende Konfiguration bereits für dich.

</details>

### Das Multilib-Repository in den Systemquellen aktivieren

> Das `multilib`-Repository stellt 32-Bit-Bibliotheken und Programme für ein 64-Bit-Arch-Linux-System bereit. Einige Anwendungen, Spiele, Entwicklungs- und Debugging-Tools benötigen diese Pakete.

Aktiviere `multilib`, falls es noch nicht in deiner `/etc/pacman.conf` eingetragen ist:

```bash
sudo bash -c 'grep -q "^\[multilib\]" /etc/pacman.conf || printf "\n[multilib]\nInclude = /etc/pacman.d/mirrorlist\n" >> /etc/pacman.conf'
```

Danach die Paketdatenbank aktualisieren:

```bash
sudo pacman -Sy
```

### Rust und Cargo installieren

> Rust wird für verschiedene Entwicklungs- und Security-Projekte benötigt. Wir installieren deshalb neben der Rust-Toolchain auch einige nützliche Cargo-Tools für Testing, Auditing, Debugging und Performance-Analyse.

Falls Rust noch nicht installiert ist, kannst du es mit dem offiziellen Installationsscript von Rustup installieren. Dieser Befehl wird von Rustup selbst als Installationsmethode empfohlen (23.08.2026):

```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

<details>
<summary>✨ Sichere Rustup-Installation – Script vorher ansehen</summary>

**Du willst lieber vorher wissen, was ausgeführt wird? Kein Problem.**

Anstatt das von Rustup empfohlene Script direkt über `curl | sh` auszuführen, kannst du es zuerst herunterladen und dir den Inhalt ansehen.

```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs -o /tmp/rustup.sh
```

Script anzeigen:

```bash
less /tmp/rustup.sh
```

Zusätzlich kannst du nach einigen Befehlen suchen, die bei Installationsscripts besonders interessant sind:

```bash
grep -nE "curl|wget|sudo|rm -rf|eval|exec|base64|bash|sh" /tmp/rustup.sh
```

> **Hinweis:** Das ist kein vollständiger Security-Audit. Es gibt dir lediglich einen schnellen Überblick darüber, welche potenziell relevanten Befehle im Script vorkommen.

Wenn du dir das Script angesehen hast und alles für dich passt, kannst du es lokal ausführen:

```bash
sh /tmp/rustup.sh
```

Anschließend kannst du das temporäre Script wieder löschen:

```bash
rm /tmp/rustup.sh
```

> Damit kannst du die von Rustup bereitgestellte Installationsroutine **vor der Ausführung selbst einsehen**, anstatt sie direkt über `curl | sh` auszuführen.

</details>

Danach die Shell-Konfiguration neu laden oder ein neues Terminal öffnen.

> `cargo-nextest` führt Rust-Tests schneller und komfortabler aus, `cargo-audit` prüft Dependencies auf bekannte Sicherheitslücken, `bacon` bietet einen schnellen Entwicklungs-Loop mit automatischem Prüfen und Testen, `flamegraph` und `samply` helfen bei Performance-Analysen, während `cargo-expand` Makros expandiert, `cargo-show-asm` generierten Assembly-Code sichtbar macht und `cargo-deny` Dependencies auf verschiedene Probleme und Richtlinienverletzungen prüft.

Jetzt installieren wir die wichtigsten Cargo-Tools:

```bash
cargo install --locked cargo-nextest
cargo install --locked cargo-audit
cargo install --locked bacon
cargo install --locked flamegraph
cargo install --locked samply
cargo install --locked cargo-expand
cargo install --locked cargo-show-asm
cargo install --locked cargo-deny
```

<details>
<summary>✨ Optionale Rust-Tools</summary>

> `rustfmt` formatiert Rust-Code automatisch, `probe-rs-tools` stellt Werkzeuge für Embedded- und Debugging-Workflows bereit, `cargo-auditable` erstellt überprüfbare Dependency-Informationen in Binaries, `cargo-watch` führt Cargo-Commands automatisch bei Änderungen aus, `cargo-bloat` analysiert die Größe von Rust-Binaries und `cargo-binutils` stellt zusätzliche Binary-Analysewerkzeuge für Rust bereit.

Falls du zusätzlich mit Embedded-Systemen, Binary-Analyse oder detaillierter Performance-Analyse arbeitest, kannst du folgende Tools installieren:

```bash
rustup component add rustfmt
```

```bash
cargo install --locked probe-rs-tools
```

```bash
cargo install --locked cargo-auditable
cargo install --locked cargo-watch
cargo install --locked cargo-bloat
cargo install --locked cargo-binutils
```

</details>

### Plugin für Decompilation in radare2 (Terminal)

> `radare2` ist ein mächtiges Framework zur Analyse und zum Reverse Engineering von Binaries. `r2ghidra` bringt die Ghidra-Decompiler-Engine direkt in radare2 und ermöglicht es dir, kompilierten Code wieder in eine besser lesbare Darstellung zu dekompilieren.

Installation:

```bash
sudo pacman -Syu radare2 r2ghidra
```

✨ Falls du zusätzlich mit `r2pipe` arbeiten möchtest, kannst du die Python-Bindings installieren:

<details>
<summary>Installieren</summary>

```bash
sudo pacman -S python-r2pipe
```

</details>

<details>
<summary>✨ Alternative: r2pm verwenden</summary>

Falls du `r2ghidra` nicht über dein Paketmanagement installieren möchtest, kannst du das Plugin alternativ über den radare2 Package Manager (`r2pm`) installieren:

```bash
r2pm -U
r2pm -init
r2pm -i r2ghidra
```

> **Hinweis:** Verwende am besten **eine** der beiden Methoden und installiere `r2ghidra` nicht doppelt.

</details>

### Go und Make über den Paketmanager installieren

> `Go` ist eine schnelle, kompakte Programmiersprache, die besonders häufig für Backend-Entwicklung, Netzwerktools, Security-Tools und CLI-Anwendungen verwendet wird. `make` automatisiert Build-Prozesse und wird von vielen C/C++- und anderen Projekten verwendet.

Installiere beides direkt über `pacman`:

```bash
sudo pacman -S make go
```

<details>
<summary>✨ Empfohlene Go-Tools</summary>

Falls du aktiv mit Go entwickelst, kannst du zusätzlich `gopls` und `goimports` installieren:

```bash
go install golang.org/x/tools/gopls@latest
go install golang.org/x/tools/cmd/goimports@latest
```

> `gopls` ist der Language Server für Go und liefert deinem Editor Funktionen wie Autovervollständigung, Fehlermeldungen, Navigation und Codeanalyse. `goimports` formatiert Go-Code und verwaltet automatisch die benötigten Imports.

#### Weitere optionale Tools

**golangci-lint** bündelt zahlreiche Linter und statische Analysewerkzeuge für Go-Projekte:

```bash
curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s -- -b "$(go env GOPATH)/bin" v1.59.2
```

> **Hinweis:** Das Installationsscript wird direkt aus dem Internet geladen und ausgeführt. Wenn du den Inhalt vorher prüfen möchtest, kannst du es – wie beim Rustup-Installer – zunächst herunterladen und anschließend ausführen.

Für Debugging kannst du außerdem **Delve** installieren:

```bash
go install github.com/go-delve/delve/cmd/dlv@latest
```

> `dlv` (Delve) ist der Debugger für Go und ermöglicht unter anderem Breakpoints, das Untersuchen von Variablen und das schrittweise Ausführen deines Codes.

</details>

### ✨ C/C++ Advanced Debugging installieren

> `rr` ist ein fortgeschrittenes Debugging-Tool für C/C++-Programme. Es zeichnet die Ausführung eines Programms auf und ermöglicht danach eine deterministische Wiederholung. Dadurch kannst du Fehler Schritt für Schritt rückwärts und vorwärts analysieren – besonders hilfreich bei schwer reproduzierbaren Bugs.

<details>
<summary>Installieren</summary>

```bash
yay -S rr
```

</details>

> **Hinweis:** `rr` benötigt bestimmte Kernel-Features und funktioniert am besten auf Systemen mit passender Hardware- und Kernel-Konfiguration. Falls es nicht direkt funktioniert, überprüfe die Kernel-Meldungen und die offizielle Dokumentation von `rr`.

### Mehrere Java-Versionen sowie Gradle und Maven installieren

> Java wird in vielen Bereichen eingesetzt – von klassischen Anwendungen über Server-Software bis hin zu Android- und Enterprise-Entwicklung. Wir installieren mehrere Java-Versionen, damit du je nach Projekt flexibel wechseln kannst.
>
> `Maven` und `Gradle` sind Build-Tools, die Abhängigkeiten verwalten und den automatischen Bau von Java-Projekten übernehmen.

### Java-Versionen installieren

Wir installieren mehrere JDK-Versionen:

```bash
sudo pacman -S jdk21-openjdk jdk25-openjdk jdk-openjdk
```

> **Was machen die Pakete?**
> `jdk21-openjdk` installiert Java 21 (LTS-Version), `jdk25-openjdk` installiert die aktuelle Java-Version und `jdk-openjdk` stellt das Standard-OpenJDK-Paket bereit.

Welche Java-Version aktuell verwendet wird, kannst du prüfen mit:

```bash
archlinux-java status
```

Falls du eine bestimmte Version als Standard setzen möchtest:

```bash
sudo archlinux-java set java-21-openjdk
```

### Maven installieren

> `maven` ist ein weit verbreitetes Build-System für Java-Projekte. Es verwaltet Bibliotheken, führt Tests aus und erstellt fertige Builds.

```bash
sudo pacman -S maven
```

### Gradle installieren

> `gradle` ist ein modernes Build-System, das besonders häufig bei größeren Java-Projekten und Android-Entwicklung verwendet wird.

```bash
sudo pacman -S gradle
```

<details>
<summary>✨ Alternative Installationsmethoden für Gradle</summary>

Falls du lieber eine andere Version von Gradle verwenden möchtest:

Über das AUR:

```bash
yay -S gradle
```

Oder über SDKMAN (23.08.2026):

```bash
sdk install gradle 9.7
```

> **Hinweis:** SDKMAN eignet sich besonders, wenn du häufig zwischen verschiedenen Java-, Gradle- oder Maven-Versionen wechseln möchtest.

</details>

### Den x86-Assembler und grundlegende Binär-Werkzeuge installieren

> `nasm` ist ein moderner x86/x86-64-Assembler. Damit kannst du direkt Assembler-Code schreiben und in ausführbare Objektdateien übersetzen.
>
> `binutils` enthält eine Sammlung wichtiger Binärwerkzeuge wie `objdump`, `readelf`, `nm` und `ld`. Damit kannst du Binärdateien analysieren, Symbole anzeigen, ELF-Dateien untersuchen und Programme linken.

```bash
sudo pacman -S nasm binutils
```

### Das Exploit-Entwicklungs-Framework Pwntools installieren

> `pwntools` stellt eine Sammlung von Python-Tools bereit, die häufig bei Binary Exploitation verwendet werden. Dazu gehören unter anderem:
>
> - Kommunikation mit lokalen Programmen und entfernten Servern
> - Erstellen und Senden von Exploit-Payloads
> - Arbeiten mit Registern, Speicheradressen und Binaries
> - Unterstützung bei ROP-Chains (Return-Oriented Programming)
> - Automatisierung von Exploit-Tests

```bash
sudo pacman -S python-pwntools
```

Nach der Installation kannst du prüfen, ob Pwntools funktioniert:

```bash
python -c "from pwn import *; print('Pwntools funktioniert!')"
```

> **Hinweis:** Pwntools ist vor allem für Lernumgebungen, CTFs, Security-Forschung und autorisierte Tests gedacht. Verwende es nur auf Systemen und Programmen, für die du die Erlaubnis hast.

### ✨ Die Programmiersprache und Compiler-Toolchain Zig installieren

> `zig` enthält den Zig-Compiler, den Build-Manager und verschiedene Werkzeuge für die Entwicklung von nativer Software.
>
> Besonders interessant sind:
>
> - direkte Kontrolle über Speicher und Ressourcen
> - einfache Cross-Kompilierung für andere Plattformen
> - schneller Build-Prozess
> - gute Integration mit C-Code
> - moderne Alternative für viele Low-Level-Projekte

<details>
<summary>Installieren</summary>

```bash
sudo pacman -S zig
```

</details>

### Die JetBrains Toolbox installieren und starten

> Auch wenn NeoVim der Haupteditor in JK-Arch ist, gibt es Situationen, in denen eine vollwertige IDE einfach angenehmer ist – besonders bei großen Projekten, komplexem Debugging oder umfangreichen Build-Systemen.

Die **JetBrains Toolbox** verwaltet deine JetBrains-Programme zentral und ermöglicht es dir, IDEs wie **IntelliJ IDEA**, **CLion**, **PyCharm** oder andere JetBrains-Tools einfach zu installieren, aktualisieren und verwalten.

Download:

[https://www.jetbrains.com/toolbox-app/](https://www.jetbrains.com/toolbox-app/)

Nach dem Download die Toolbox entpacken und starten:

```bash
cd Downloads/
tar -xzf jetbrains-toolbox-[VERSION].tar.gz
cd jetbrains-toolbox-[VERSION]/bin
./jetbrains-toolbox
```

> Ersetze `[VERSION]` durch die tatsächliche Version der heruntergeladenen Toolbox-Datei.

<details>
<summary>Empfehlungen für die Entwicklung</summary>

> **Java-Entwicklung**  
> Installiere **IntelliJ IDEA** über die JetBrains Toolbox. Für das tägliche Coding kannst du weiterhin NeoVim mit `jdtls` verwenden. Wenn ein Projekt größer oder komplizierter wird, öffnest du es einfach zusätzlich in IntelliJ IDEA – beide Werkzeuge ergänzen sich perfekt.

> **Rust-Entwicklung**  
> NeoVim ist mit `rust-analyzer` eine extrem starke Entwicklungsumgebung und für die meisten Rust-Projekte völlig ausreichend.

> **C/C++-Entwicklung**  
> Für kleinere Projekte reicht NeoVim mit den passenden LSP-Tools vollkommen aus. Bei komplexen CMake-Projekten, größerem Debugging oder umfangreichen Codebasen lohnt es sich jedoch, **CLion** als zusätzliche IDE über die Toolbox installiert zu haben.

> **Kurz gesagt:**  
> NeoVim bleibt dein schneller, flexibler Haupteditor für den Alltag. JetBrains-IDEen sind dein Spezialwerkzeug für große Projekte, komplexes Debugging und Situationen, in denen eine vollständige IDE einfach Vorteile bringt.

</details>

### Docker und Erweiterungen installieren

> Docker ermöglicht es dir, Anwendungen und komplette Umgebungen isoliert in Containern auszuführen. Das ist besonders praktisch für Entwicklung, Tests, Server-Setups und Projekte mit vielen Abhängigkeiten.
> `docker` ist die eigentliche Container-Engine und führt Container aus.
>
> `docker-compose` ermöglicht es, mehrere Container über eine gemeinsame Konfigurationsdatei (`compose.yml` oder `docker-compose.yml`) zu verwalten – zum Beispiel eine Anwendung mit Datenbank und Backend.
>
> `docker-buildx` erweitert Docker um moderne Build-Funktionen und unterstützt unter anderem bessere Builds, Multi-Platform-Images und fortgeschrittene Build-Workflows.

Installation:

```bash
sudo pacman -S docker docker-compose docker-buildx
```

Docker-Dienst aktivieren und direkt starten:

```bash
sudo systemctl enable --now docker
```

Überprüfen, ob Docker korrekt installiert ist:

```bash
docker --version
```

<details>
<summary>✨ Docker ohne sudo verwenden</summary>

Standardmäßig benötigt Docker Root-Rechte. Wenn du Docker als normaler Benutzer verwenden möchtest, kannst du deinen Benutzer zur Docker-Gruppe hinzufügen:

```bash
sudo usermod -aG docker $USER
```

Danach einmal ab- und wieder anmelden oder die Gruppe neu laden:

```bash
newgrp docker
```

Test:

```bash
docker run hello-world
```

> **Wichtig:** Mitglieder der `docker`-Gruppe haben praktisch Root-Rechte auf dem System, da Docker-Container mit weitreichenden Berechtigungen gestartet werden können. Nutze diese Option nur, wenn du dir dessen bewusst bist.

</details>

### Nützliche Systemwerkzeuge und Python einrichten

> `wl-clipboard` stellt die Clipboard-Werkzeuge für Wayland bereit (`wl-copy` und `wl-paste`). Viele moderne Wayland-Anwendungen und Scripts benötigen diese Befehle für Copy & Paste.
>
> `fd` ist eine moderne Alternative zu `find`. Es ist schneller, einfacher zu benutzen und wird von vielen modernen CLI-Tools unterstützt.
>
> `python` installiert die Python-Laufzeitumgebung und wird von vielen Entwicklungswerkzeugen, Scripts und Security-Tools benötigt.
>
> `python-pip` ist der Paketmanager für Python und ermöglicht das Installieren zusätzlicher Python-Bibliotheken.

```bash
sudo pacman -S wl-clipboard fd python python-pip
```

<details>
<summary>✨ Optionale Python-Entwicklungswerkzeuge</summary>

> `pipx` installiert Python-Anwendungen in eigenen virtuellen Umgebungen, sodass dein System-Python sauber bleibt.
>
> `black` formatiert Python-Code automatisch nach einem einheitlichen Standard.
>
> `ruff` ist ein extrem schneller Python-Linter und findet Fehler, schlechte Patterns und Stilprobleme im Code.

Falls du häufiger Python-Projekte entwickelst, kannst du zusätzlich `pipx` installieren:

```bash
sudo pacman -S python-pipx
```

Danach den Python-Bin-Pfad einrichten:

```bash
pipx ensurepath
```

Jetzt kannst du Python-Tools isoliert installieren:

```bash
pipx install black
pipx install ruff
```

</details>

### Ultraschnelle Textsuche installieren

> `ripgrep` (`rg`) durchsucht Dateien nach Textmustern und berücksichtigt dabei automatisch Dinge wie `.gitignore`. Dadurch eignet es sich perfekt für die Suche in Softwareprojekten, Konfigurationsdateien und großen Verzeichnissen.

```bash
sudo pacman -S ripgrep
```

### ✨ Die intelligente Ordner-Navigation einrichten

> `zoxide` lernt deine meistgenutzten Verzeichnisse und erstellt daraus eine intelligente Navigation. Je öfter du einen Ordner verwendest, desto besser funktioniert die Suche.

<details>
<summary>Installieren</summary>

```bash
sudo pacman -S zoxide
```

</details>

### JavaScript-Laufzeitumgebung und Paketmanager installieren

> `nodejs` ist die Laufzeitumgebung, mit der JavaScript-Code außerhalb eines Browsers ausgeführt werden kann. Viele moderne Tools wie Build-Systeme, Entwickler-Server und Automatisierungsscripte basieren darauf.
>
> `npm` (Node Package Manager) ist der Paketmanager für JavaScript und ermöglicht das Installieren, Verwalten und Aktualisieren von JavaScript-Bibliotheken und Entwicklerwerkzeugen. **Außerdem wird npm häufig von NeoVim-Plugins und LSP-Tools benötigt, zum Beispiel für die Installation und Verwaltung von Language-Servern, Formatierern und weiteren Entwicklungswerkzeugen über die NeoVim-Konfiguration.**

```bash
sudo pacman -S nodejs npm
```

### .NET SDK installieren

> `.NET` ist eine moderne Entwicklungsplattform von Microsoft und wird häufig für Backend-Anwendungen, Web-APIs, Desktop-Anwendungen, Cloud-Services und verschiedene Enterprise-Projekte verwendet. Mit dem SDK kannst du eigene .NET-Anwendungen entwickeln, bauen und testen.
>
> `dotnet-sdk` enthält alles, was du zum Entwickeln mit .NET benötigst: Compiler, Build-Tools, Templates und die komplette Entwicklungsumgebung für C# und andere .NET-Sprachen.
>
> `dotnet-runtime` stellt die Laufzeitumgebung bereit, die benötigt wird, um fertige .NET-Anwendungen auszuführen.
>
> `aspnet-runtime` erweitert die Laufzeit um Komponenten für ASP.NET-Anwendungen, also Webserver, Web-APIs und moderne Webanwendungen.

```bash
sudo pacman -S dotnet-sdk
sudo pacman -S dotnet-runtime aspnet-runtime
```

#### .NET globale Tools verfügbar machen

Viele .NET-Erweiterungen und Entwicklerwerkzeuge werden über `dotnet tool install` installiert. Damit diese Tools direkt im Terminal gefunden werden, fügen wir den Tool-Pfad zu Fish hinzu:

```fish
fish_add_path $HOME/.dotnet/tools
```

Nach der Installation kannst du prüfen, ob alles funktioniert:

```bash
dotnet --version
```

> Wenn eine Versionsnummer ausgegeben wird, ist die .NET-Umgebung erfolgreich eingerichtet.

### Das Standard-Kompressionswerkzeug installieren

> `gzip` komprimiert und entpackt Dateien mit dem `.gz`-Format. Es wird häufig zusammen mit `tar` verwendet, zum Beispiel bei Linux-Archiven (`.tar.gz`).

```bash
sudo pacman -S gzip
```

### ✨ TypeScript installieren

> `typescript` stellt den TypeScript-Compiler (`tsc`) bereit. Dieser übersetzt TypeScript-Code (`.ts`) in normales JavaScript, das anschließend von Browsern oder Node.js ausgeführt werden kann.

<details>
<summary>Installieren</summary>

```bash
sudo npm install -g typescript
```

</details>

### Die ultimative LaTeX-Umgebung installieren

> LaTeX ist das Standardwerkzeug für hochwertige wissenschaftliche Dokumente, technische Dokumentationen, Papers, Abschlussarbeiten und mathematische Texte. Wir installieren eine komplette Umgebung mit Compiler, Erweiterungen, PDF-Viewer und NeoVim-Unterstützung.
>
> `texlive-meta` installiert die grundlegende LaTeX-Distribution mit den wichtigsten Paketen und Werkzeugen.
>
> `texlive-latexextra` erweitert LaTeX um viele zusätzliche Pakete für fortgeschrittene Dokumente, Layouts, Tabellen und Formatierungen.
>
> `texlive-pictures` stellt Pakete für Grafiken und Diagramme bereit, unter anderem für TikZ-basierte Zeichnungen.
>
> `texlive-langgerman`, `texlive-langenglish` und `texlive-langgreek` fügen Sprachunterstützung, Trennregeln und passende typografische Einstellungen für verschiedene Sprachen hinzu.
>
> `biber` ist ein moderner Literaturverwaltungs-Prozessor und wird häufig zusammen mit `biblatex` für Quellenverwaltung verwendet.
>
> `zathura` ist ein minimalistischer, tastaturgesteuerter PDF-Viewer, der besonders gut zu einem Terminal- und NeoVim-Workflow passt.
>
> `zathura-pdf-poppler` ergänzt Zathura um die PDF-Unterstützung über Poppler.
>
> `texlab` ist ein LaTeX Language Server und ermöglicht Funktionen wie Autovervollständigung, Fehlermeldungen, Navigation und Dokumentanalyse in NeoVim.
>
> `tectonic` ist ein moderner LaTeX-Compiler, der automatisch benötigte Pakete verwalten kann und einen vereinfachten Build-Workflow bietet.

```bash
# sudo pacman -S texlive-meta latexmk zathura zathura-pdf-poppler
# sudo pacman -S texlive-latexextra texlive-pictures, texlive-langgerman texlive-langenglish biber
# sudo pacman -S texlab
# sudo pacman -S tectonic
# sudo pacman -S texlive-langgreek
sudo pacman -S texlive-meta texlive-latexextra texlive-pictures texlive-langgerman texlive-langenglish texlive-langgreek biber zathura zathura-pdf-poppler texlab tectonic
```

### Die Rechtschreibprüfung für Deutsch und Englisch installieren

> `hunspell` ist die eigentliche Rechtschreibprüfungs-Engine und stellt die grundlegende Funktionalität bereit.
>
> `hunspell-de` fügt das deutsche Wörterbuch hinzu und ermöglicht die Prüfung deutscher Texte.
>
> `hunspell-en_us` stellt das englische Wörterbuch (US-Englisch) bereit und ermöglicht die Prüfung englischer Texte.

```bash
sudo pacman -S hunspell hunspell-de hunspell-en_us
```

### Moderne Terminal-Emulatoren installieren

> `kitty` ist der **Standard-Terminal-Emulator von JK-Arch** und wird daher empfohlen. Er bietet GPU-Rendering, Tabs, Splits, Bildunterstützung und viele Anpassungsmöglichkeiten. Die JK-Arch-Konfiguration ist auf diesen Workflow abgestimmt.
>
> `ghostty` ist ein moderner, sehr schneller Terminal-Emulator mit GPU-Beschleunigung und eine gute Alternative, falls du etwas Neues ausprobieren möchtest.
>
> `foot` ist ein minimalistischer, Wayland-nativer Terminal-Emulator. Er passt besonders gut zu Hyprland, wenn du ein extrem leichtgewichtiges Setup bevorzugst.
>
> `alacritty` ist ein schneller, GPU-beschleunigter Terminal-Emulator und auf vielen vorkonfigurierten Arch-Systemen wie CachyOS bereits vorhanden.
>
> `konsole` ist der Terminal-Emulator von KDE Plasma. Er ist hauptsächlich für KDE-Desktops gedacht und bietet eine enge Integration mit KDE-Anwendungen wie Dolphin. Für ein reines Hyprland-/JK-Arch-Setup ist er jedoch nicht die bevorzugte Wahl.

```bash
sudo pacman -S ghostty foot alacritty kitty konsole
```

<details>
<summary>✨ Optionale zusätzliche Tools</summary>

Falls du weitere Terminal- und Entwicklungswerkzeuge möchtest:

> `wezterm` ist ein moderner Terminal-Emulator mit umfangreichen Konfigurationsmöglichkeiten und integrierten Features wie Multiplexing.

```bash
sudo pacman -S wezterm
```

> `terminator` bietet eine grafische Oberfläche mit eingebauten Splits und mehreren Terminal-Fenstern. Praktisch, wenn du lieber mit der Maus arbeitest.

```bash
sudo pacman -S terminator
```

> `gnome-terminal` ist der klassische Terminal-Emulator der GNOME-Desktopumgebung. Er funktioniert zuverlässig, ist aber weniger auf einen modernen Hyprland-/NeoVim-Workflow ausgelegt.

```bash
sudo pacman -S gnome-terminal
```

</details>

### ✨ Akku- und Hardware-Informationen auslesen

> **Nur installieren, wenn du die Akku-Anzeige in meiner NeoVim-Konfiguration verwenden möchtest.**
> `acpi` liest Akku- und Hardware-Informationen über die ACPI-Schnittstelle aus. Diese Funktion kann praktisch sein, verursacht aber zusätzliche Abfragen und kann dadurch Performance kosten.
>
> Deshalb ist die entsprechende Funktion in meiner Konfiguration standardmäßig **auskommentiert** und muss nur aktiviert werden, wenn du sie wirklich nutzen möchtest.

<details>
<summary>Installieren</summary>

```bash
sudo pacman -S acpi
```

</details>

### ✨ Java-Laufzeitumgebung installieren

> `jre-openjdk` installiert die Java-Laufzeitumgebung (Java Runtime Environment). Damit kannst du fertige Java-Programme starten, ohne das komplette Java-Entwicklungspaket (`jdk`) zu installieren.

<details>
<summary>Installieren</summary>

```bash
sudo pacman -S jre-openjdk
```

</details>

### ✨ Erweiterte Grammatik- und Stilprüfung mit LanguageTool

> `languagetool` bietet eine erweiterte Grammatik-, Rechtschreib- und Stilprüfung für verschiedene Sprachen. Es kann von Editoren, Schreibprogrammen und Plugins genutzt werden, um Texte direkt während des Schreibens zu überprüfen.

<details>
<summary>Installieren</summary>

```bash
sudo pacman -S languagetool
```

</details>

### ✨ LazyVim und JetBrains Mono Nerd Font installieren

> [!IMPORTANT]
> Hinweis: Die unten aufgeführten manuellen Schritte zur Einrichtung von LazyVim und der JetBrains Mono Nerd Font sind standardmäßig nicht mehr notwendig. Das neue Installationsskript von doshyperland bringt bereits die vollautomatisierte Funktion install_neovim_lazyvim_nerdfont mit, die alle Pakete, Abhängigkeiten, Konfigurationen und Schriftarten fehlerfrei und in der korrekten Reihenfolge einrichtet.

> NeoVim wird hier zur vollständigen Entwicklungsumgebung ausgebaut. Wir installieren NeoVim, richten LazyVim als moderne Plugin-Basis ein und installieren eine Nerd Font, damit Icons, Symbole und UI-Elemente in NeoVim korrekt dargestellt werden.
>
> `neovim` ist der moderne Vim-Nachfolger und die Grundlage für die JK-Arch-Entwicklungsumgebung.
>
> `vim` wird zusätzlich installiert, da einige Tools und Scripts weiterhin auf die klassische Vim-Kompatibilität zurückgreifen.

```bash
sudo pacman -S neovim vim
```

#### ✨ LazyVim Starter-Konfiguration herunterladen

> Wir legen die Grundlage für unsere NeoVim-Umgebung. Dafür laden wir zuerst die **LazyVim Starter-Konfiguration** herunter. LazyVim ist keine eigene Version von NeoVim, sondern eine moderne vorkonfigurierte Plugin- und Struktur-Basis für NeoVim.
>
> Es kümmert sich unter anderem um Plugin-Verwaltung, eine saubere Ordnerstruktur und viele moderne Entwicklungsfunktionen. Die JK-Arch NeoVim-Konfiguration baut auf dieser Grundlage auf und erweitert sie mit eigenen Plugins, Themes, LSP-Setups und zusätzlichen Anpassungen.

```bash
git clone https://github.com/LazyVim/starter ~/.config/nvim
```

Danach entfernen wir die Git-Historie des Starter-Repositories:

```bash
rm -rf ~/.config/nvim/.git 
```

> Dadurch bleibt nur deine eigene Konfiguration erhalten und sie ist nicht mehr direkt mit dem LazyVim-Starter-Repository verbunden.

#### ✨ JetBrains Mono Nerd Font installieren

> Viele NeoVim-Themes und Plugins verwenden spezielle Symbole und Icons. Ohne eine Nerd Font werden diese oft falsch oder als leere Zeichen dargestellt.

Font-Verzeichnis erstellen:

```bash
mkdir -p ~/.local/share/fonts
cd ~/.local/share/fonts
```

JetBrains Mono Nerd Font herunterladen und entpacken:

```bash
# JetBrains Mono Nerd Font herunterladen und entpacken
wget https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip
unzip JetBrainsMono.zip -d JetBrainsMono
```

Font-Cache aktualisieren:

```bash
# Font-Cache aktualisieren
fc-cache -fv
```

Jetzt kannst du NeoVim starten:

```bash
nvim
```

> Beim ersten Start lädt LazyVim automatisch die benötigten Plugins herunter und richtet die Entwicklungsumgebung ein.

## Linux Power Tools

### Das System-Informationswerkzeug Fastfetch installieren

> `fastfetch` zeigt dir beim Start oder auf Wunsch wichtige Informationen über dein System direkt im Terminal an. Es ist eine moderne Alternative zu `neofetch` und passt besonders gut zu einem minimalistischen, Terminal-zentrierten Setup wie JK-Arch.

```bash
sudo pacman -S fastfetch
```

### Den interaktiven Prozess-Viewer htop installieren

> `htop` ist ein interaktiver Prozess-Viewer, der dir eine visuelle Darstellung der laufenden Prozesse deines Systems zeigt. Es ist eine moderne Alternative zu `top` und bietet eine benutzerfreundliche Oberfläche.

```bash
sudo pacman -S htop
```

### Den hochentwickelten System-Monitor btop installieren

> `btop` ist ein moderner System-Monitor, der eine detaillierte Übersicht über CPU, RAM, Netzwerk, Prozesse und mehr bietet. Er ist besonders für Entwickler und Systemadministratoren nützlich, die eine umfassende Visualisierung ihrer Systemressourcen benötigen.

```bash
sudo pacman -S btop
```

<details>
<summary>Eigene btop-Konfiguration bearbeiten</summary>

Die Konfiguration liegt hier:

```bash
nvim ~/.config/btop/btop.conf
```

Dort kannst du unter anderem Darstellung, Farben, Layout und Verhalten anpassen.

</details>

### ✨ Den GPU-Prozess-Monitor nvtop installieren

> `nvtop` ist ein interaktiver Monitor für NVIDIA-GPUs, der dir eine visuelle Darstellung der laufenden Prozesse deiner GPU zeigt. Es ist besonders nützlich für Entwickler, die ihre GPU-Ressourcen überwachen möchten.

<details>
<summary>Installieren</summary>

```bash
sudo pacman -S nvtop
```

</details>

### Den ultraschnellen Terminal-Dateimanager Yazi installieren

> `yazi` ist ein ultraschneller, moderner Terminal-Dateimanager mit Fokus auf Geschwindigkeit und einer angenehmen Bedienung über die Tastatur. Er eignet sich perfekt für einen Terminal-zentrierten Workflow mit Fish, Kitty und NeoVim.

```bash
sudo pacman -S yazi
```

### ✨ Den Terminal-Dateimanager und die Bildvorschau installieren

> `ranger` ist ein klassischer Terminal-Dateimanager mit einer großen Community und vielen Erweiterungen. Er funktioniert zuverlässig, wird in JK-Arch aber nicht bevorzugt, da `yazi` moderner und schneller ist.
>
> `w3m` wird häufig zusammen mit `ranger` für Bildvorschauen im Terminal verwendet.

<details>
<summary>Installieren</summary>

```bash
sudo pacman -S ranger w3m
```

</details>

### Das Zeitmessungs-Werkzeug time installieren

> `time` misst die Ausführungszeit von Programmen und Skripten. Es ist besonders nützlich, um die Performance von Befehlen zu analysieren und Engpässe zu identifizieren.
>
> **JK-Arch erweitert diesen Workflow mit der eigenen Fish-Funktion `jtime`.**  
> `jtime` ist ein modernes Benchmarking-, Profiling- und Tracing-Werkzeug, das mehrere Analysewerkzeuge unter einem einzigen Befehl zusammenfasst.

```bash
sudo pacman -S time
```

### Installiere Radare2 (oft r2 genannt), den fortgeschrittenen Hex-Editor und Reverse-Engineering-Framework

> `radare2` (kurz `r2`) ist ein leistungsfähiges Open-Source-Framework für Reverse Engineering, Binary-Analyse und Debugging. Es wird verwendet, um ausführbare Dateien zu untersuchen, Assembly-Code zu analysieren und Programme auf einer sehr niedrigen Ebene zu verstehen.
>
> Es ist deutlich mehr als nur ein Hex-Editor: `r2` bietet eine komplette Umgebung für die Analyse von Binaries, inklusive Disassembly, Debugging und teilweise auch Decompilation über Erweiterungen.

```bash
sudo pacman -S radare2
```

### Das professionelle Benchmarking-Werkzeug Hyperfine installieren

> `hyperfine` ist ein modernes Kommandozeilen-Benchmarking-Tool, mit dem du Programme und Befehle sehr genau miteinander vergleichen kannst. Es ist deutlich zuverlässiger als einfach nur `time` zu verwenden, da es mehrere Durchläufe ausführt, Aufwärmphasen berücksichtigt und statistisch auswertbare Ergebnisse liefert.

```bash
sudo pacman -S hyperfine
```

### ✨ Den Terminal-Multiplexer tmux installieren

> `tmux` ist ein Terminal-Multiplexer und ermöglicht es, mehrere Shell-Sitzungen, Fenster und Splits innerhalb eines einzigen Terminals zu verwalten.
>
> In JK-Arch wird `tmux` jedoch **nicht benötigt**. Der Standard-Terminal-Emulator `kitty` bringt bereits eigene Funktionen für Splits, Tabs und Fensterverwaltung mit und deckt damit den täglichen Workflow vollständig ab.
>
> Für ein modernes Hyprland-/NeoVim-Setup mit Kitty ist `tmux` daher meistens überflüssig. Es kann aber weiterhin sinnvoll sein, wenn du:
>
> - über SSH auf Servern arbeitest
> - lange laufende Prozesse unabhängig vom Terminal offen halten möchtest
> - mit minimalen Terminals ohne integrierte Split-Funktionen arbeitest
>
> Für den normalen JK-Arch-Workflow mit `kitty`, `fish` und `NeoVim` kannst du `tmux` einfach überspringen.

<details>
<summary>Installieren</summary>

```bash
sudo pacman -S tmux
```

</details>

### ✨ Den Anwendungsstarter Wofi installieren

> `wofi` ist ein moderner Anwendungsstarter für Wayland, der eine schnelle und einfache Möglichkeit bietet, Programme zu starten. Er ist besonders nützlich in minimalistischen Desktop-Umgebungen wie Hyprland.

<details>
<summary>Installieren</summary>

```bash
sudo pacman -S wofi
```

</details>

### Den Hex-Editor GHex installieren

> `ghex` ist ein grafischer Hex-Editor, der es ermöglicht, Binärdateien direkt zu bearbeiten. Er bietet eine einfache Benutzeroberfläche und ist besonders nützlich für Entwickler, die mit Binärdaten arbeiten.

```bash
sudo pacman -S ghex
```

### Die moderne cat-Alternative bat installieren

> `bat` ist eine moderne Alternative zu `cat`, die Syntax-Highlighting, Zeilennummern und eine bessere Darstellung von Textdateien bietet. Es ist besonders nützlich für Entwickler, die Code oder Konfigurationsdateien im Terminal anzeigen möchten.

```bash
sudo pacman -S bat
```

### Das interaktive Git-Terminalwerkzeug LazyGit installieren

> `lazygit` ist ein interaktives Terminal-Frontend für Git. Es ermöglicht dir, Commits, Branches, Änderungen und den Git-Verlauf bequem über eine grafische Oberfläche im Terminal zu verwalten, ohne ständig lange Git-Befehle eingeben zu müssen.
>
> **Was macht das Tool?**
> `lazygit` bietet unter anderem:
>
> - Übersicht über Änderungen und Commits
> - einfaches Stagen und Zurücksetzen von Dateien
> - Branch-Verwaltung
> - Commit-Erstellung
> - Anzeige der Git-Historie
> - schnelles Wechseln zwischen Repository-Bereichen
>
> **JK-Arch Integration:**
> `lazygit` ist in JK-Arch bereits in den Workflow integriert:
>
> - In **NeoVim** wird es als Git-Oberfläche verwendet.
> - Über die **Fish-Konfiguration** kann es direkt per Tastenkürzel **`Strg + G`** gestartet werden.
>
> Dadurch kannst du Git-Verwaltung schnell aus dem Terminal oder direkt aus deiner Entwicklungsumgebung heraus öffnen.

```bash
sudo pacman -S lazygit
```

### Den Verzeichnisbaum-Generator tree installieren

> `tree` ist ein einfaches Kommandozeilenwerkzeug, das die Verzeichnisstruktur eines Ordners in einer baumartigen Darstellung anzeigt. Es ist besonders nützlich, um schnell einen Überblick über die Ordnerhierarchie zu bekommen.

```bash
sudo pacman -S tree
```

### Das blitzschnelle Dateisuch-Werkzeug fd installieren

> `fd` ist ein modernes, schnelles und benutzerfreundliches Kommandozeilenwerkzeug zur Dateisuche. Es ist eine Alternative zu `find` und bietet eine einfachere Syntax sowie bessere Performance.

```bash
sudo pacman -S fd
```

### Die moderne und farbenfrohe ls-Alternative eza installieren

> `eza` ist eine moderne Alternative zu `ls`, die eine farbenfrohe und übersichtliche Darstellung von Dateien und Verzeichnissen bietet. Es unterstützt unter anderem Icons, Git-Statusanzeigen und eine bessere Formatierung.

```bash
sudo pacman -S eza
```

### ✨ Die vereinfachten Community-Handbücher tldr installieren

> `tldr` ist ein Kommandozeilenwerkzeug, das vereinfachte und leicht verständliche Handbücher für viele Linux-Befehle bereitstellt. Es bietet kurze Beispiele und Erklärungen, um die Nutzung von Befehlen schnell zu erlernen.

<details>
<summary>Installieren</summary>

```bash
sudo pacman -S tldr
```

</details>

### ✨ Den JSON-Datenprozessor jq installieren

> `jq` ist ein leistungsstarkes Kommandozeilenwerkzeug zur Verarbeitung und Manipulation von JSON-Daten. Es ermöglicht es dir, JSON-Objekte zu filtern, zu transformieren und zu analysieren.

<details>
<summary>Installieren</summary>

```bash
sudo pacman -S jq
```

</details>

### Die grafische Monitor-Konfiguration nwg-displays installieren

> `nwg-displays` ist ein grafisches Werkzeug zur Konfiguration von Monitoren und Displays unter Wayland. Es ermöglicht dir, Auflösung, Position, Rotation und andere Anzeigeeinstellungen einfach über eine Benutzeroberfläche anzupassen.

```bash
sudo pacman -S nwg-displays
```

### Das Bildverarbeitungs-Framework ImageMagick installieren

> `ImageMagick` ist ein leistungsfähiges Open-Source-Framework zur Bearbeitung, Konvertierung und Erstellung von Bildern. Es unterstützt eine Vielzahl von Bildformaten und bietet zahlreiche Funktionen wie Skalierung, Filterung, Textüberlagerung und Animationen.

```bash
sudo pacman -S imagemagick
```

### ✨ Den Tippfehler-Korrektor thefuck installieren

> `thefuck` ist ein Kommandozeilenwerkzeug, das Tippfehler in Befehlen erkennt und automatisch korrigiert. Es analysiert die Eingaben im Terminal und schlägt Korrekturen vor, um häufige Fehler zu beheben.

<details>
<summary>Installieren</summary>

```bash
sudo pacman -S thefuck
```

</details>

### Microsoft Visual Studio Code (VS Code) installieren

> **Visual Studio Code** ist ein moderner, erweiterbarer Quellcode-Editor von Microsoft. Er bietet Unterstützung für viele Programmiersprachen, Debugging, Git-Integration und eine große Auswahl an Erweiterungen.
>
> Die AUR-Version `visual-studio-code-bin` enthält die originale Microsoft-Version von VS Code als vorkompiliertes Paket. Dadurch erhältst du die gleiche Version wie auf anderen Plattformen inklusive Microsoft-Features.

```bash
yay -S visual-studio-code-bin
````

<details>
<summary>✨ Open-Source-Version von VS Code installieren</summary>

> **Code - OSS** ist die vollständig quelloffene Variante von Visual Studio Code. Sie basiert auf dem gleichen Quellcode wie VS Code, enthält aber keine proprietären Microsoft-Komponenten wie Telemetrie oder den offiziellen Microsoft-Marktplatz.
>
> Diese Version eignet sich besonders, wenn du eine freie und transparente Entwicklungsumgebung bevorzugst.

Installation über die offiziellen Arch-Repositories:

```bash
sudo pacman -S code
```

</details>

### GitKraken über yay installieren

> **GitKraken** ist ein moderner grafischer Git-Client, der das Arbeiten mit Git-Repositories übersichtlicher macht. Er bietet eine visuelle Darstellung von Branches, Commits und Merge-Vorgängen und erleichtert dadurch komplexe Git-Workflows.
>
> Das Paket `gitkraken` installiert GitKraken über das AUR und integriert es sauber in dein Arch-System.

```bash
yay -S gitkraken
````

<details>
<summary>✨ Offizielle GitKraken-Version manuell installieren</summary>

> Diese Methode installiert die offizielle Linux-Version direkt von GitKraken. Sie ist unabhängig vom AUR und kann verwendet werden, wenn du die vom Hersteller bereitgestellte Version bevorzugst.

```bash
wget https://release.gitkraken.com/linux/gitkraken-amd64.tar.gz
sudo tar -xvzf gitkraken-amd64.tar.gz
sudo mv gitkraken /opt/
sudo ln -s /opt/gitkraken/gitkraken /usr/local/bin/gitkraken
mkdir -p ~/.local/share/applications
printf '%s\n' '[Desktop Entry]' 'Name=GitKraken' 'Comment=Git Client' 'Exec=/opt/gitkraken/gitkraken' 'Icon=/opt/gitkraken/gitkraken.png' 'Terminal=false' 'Type=Application' 'Categories=Development;' > ~/.local/share/applications/gitkraken.desktop
```

</details>

### Den Discord-Client (Vesktop) über den Paketmanager installieren

> **Vesktop** ist ein alternativer Discord-Client für Linux, der auf Discords Web-Version basiert und zusätzliche Funktionen sowie bessere Integration in moderne Linux-Desktop-Umgebungen bietet.
>
> Besonders unter Wayland-Compositors wie Hyprland bietet Vesktop häufig eine bessere Erfahrung als der originale Discord-Client.

```bash
sudo pacman -S vesktop
```

<details>
<summary>✨ Originalen Discord-Client über yay installieren</summary>

> Falls du lieber den offiziellen Discord-Client verwenden möchtest, kannst du ihn über das AUR installieren.
>
> Das Paket `discord` wird dabei von `yay` verwaltet und kann später genauso über den AUR-Update-Workflow aktualisiert werden.

```bash
yay -S discord
```

</details>

<details>
<summary>✨ Probleme mit Bildschirmfreigabe oder Wayland-Portalen beheben</summary>

> Unter Wayland, besonders mit Hyprland, können Probleme mit Bildschirmfreigabe, Fensterauswahl oder Desktop-Integration auftreten.
>
> Die folgenden Befehle starten die Desktop-Portale neu und prüfen anschließend deren Status.

```bash
systemctl --user restart xdg-desktop-portal
systemctl --user restart xdg-desktop-portal-hyprland

systemctl --user status xdg-desktop-portal-hyprland
systemctl --user status xdg-desktop-portal
```

</details>

### Den Signal Messenger installieren

> **Signal** ist ein datenschutzfokussierter Messenger, der Ende-zu-Ende-Verschlüsselung für Nachrichten, Anrufe und Medien bietet. Er ist besonders beliebt bei Nutzern, die Wert auf Sicherheit und Privatsphäre legen.

```bash
sudo pacman -S signal-desktop
# yay -S signal-desktop
```

### Den Firefox Browser installieren

> **Firefox** ist ein freier und quelloffener Webbrowser von Mozilla. Er legt besonderen Wert auf Datenschutz, Sicherheit und die Kontrolle der Nutzer über ihre Daten.
>
> Firefox verwendet keine Chromium-Basis, sondern die eigene Browser-Engine **Gecko** und unterstützt moderne Webstandards, Erweiterungen sowie umfangreiche Datenschutz-Einstellungen.

```bash
sudo pacman -S firefox
# yay -S firefox
```

### Den Brave Browser über yay installieren

> **Brave** ist ein datenschutzfokussierter Webbrowser, der Tracking und Werbung blockiert und auf Chromium basiert. Er bietet zusätzliche Funktionen wie integrierten Werbeblocker, HTTPS Everywhere und Schutz vor Fingerprinting.

```bash
sudo pacman -S brave-bin
# yay -S brave-bin
```

### ✨ Den datenschutzfokussierten Mullvad Browser installieren

> **Mullvad Browser** ist ein datenschutzorientierter Webbrowser, der auf Firefox basiert und von Mullvad entwickelt wurde. Er bietet zusätzliche Sicherheits- und Datenschutzfunktionen, wie z.B. integrierten Schutz vor Tracking, Fingerprinting und Werbung.

<details>
<summary>Installieren</summary>

```bash
yay -S mullvad-browser-bin
```

</details>

### ✨ Google Chrome über den AUR-Helfer installieren

> **Google Chrome** ist ein populärer Webbrowser, der von Google entwickelt wurde. Er bietet eine schnelle und zuverlässige Browsererfahrung mit einer breiten Auswahl an Funktionen und Erweiterungen.

<details>
<summary>Installieren</summary>

```bash
yay -S google-chrome
```

</details>

### ✨ Den datenschutzfokussierten LibreWolf Browser installieren

> **LibreWolf** ist ein datenschutzorientierter Webbrowser, der auf Firefox basiert und von der Community entwickelt wird. Er legt besonderen Wert auf Sicherheit, Datenschutz und die Entfernung von Telemetrie- und Tracking-Funktionen.

<details>
<summary>Installieren</summary>

```bash
yay -S librewolf-bin
```

</details>

### ✨ Die Firefox Developer Edition installieren

> **Firefox Developer Edition** ist eine spezielle Version von Firefox, die für Webentwickler optimiert ist. Sie bietet zusätzliche Entwicklerwerkzeuge, Debugging-Funktionen und experimentelle Features, die in der regulären Version von Firefox nicht verfügbar sind.

<details>
<summary>Installieren</summary>

```bash
sudo pacman -S firefox-developer-edition
```

</details>

### Das grafische Archivierungsprogramm Ark installieren

> `Ark` ist ein grafisches Archivierungsprogramm, das es ermöglicht, verschiedene Archivformate wie ZIP, TAR, RAR und 7z zu erstellen, zu extrahieren und zu verwalten. Es bietet eine benutzerfreundliche Oberfläche für die Arbeit mit komprimierten Dateien.

```bash
sudo pacman -S ark
```

### Den erweiterten KDE-Texteditor Kate installieren

> `Kate` ist ein leistungsfähiger Texteditor für Entwickler und fortgeschrittene Benutzer. Er bietet Syntax-Highlighting, Code-Faltung, Plugins und eine Vielzahl von Funktionen, die das Bearbeiten von Quellcode und Textdateien erleichtern.

```bash
sudo pacman -S kate
```

### Der grafische Bildbetrachter Gwenview installieren

> `Gwenview` ist ein schneller und benutzerfreundlicher Bildbetrachter für KDE. Er unterstützt eine Vielzahl von Bildformaten, bietet grundlegende Bearbeitungsfunktionen und ermöglicht das einfache Durchsuchen von Bildersammlungen.

```bash
sudo pacman -S gwenview
```

### Der universelle Dokumentenbetrachter Okular installieren

> `Okular` ist ein universeller Dokumentenbetrachter, der verschiedene Dateiformate wie PDF, DjVu, TIFF und mehr unterstützt. Er bietet eine benutzerfreundliche Oberfläche für das Lesen und Anzeigen von Dokumenten.

```bash
sudo pacman -S okular
```

### Den universellen Medienplayer VLC installieren

> `VLC` ist ein vielseitiger und plattformübergreifender Medienplayer, der eine breite Palette von Audio- und Videoformaten unterstützt. Er bietet Funktionen wie Streaming, Untertitelunterstützung und Medienkonvertierung.

```bash
sudo pacman -S vlc
```

### ✨ Den Audio-Editor Audacity installieren

> `Audacity` ist ein leistungsstarker Audio-Editor, der zum Aufnehmen, Schneiden und Bearbeiten von Audiodateien verwendet werden kann. Er bietet eine Vielzahl von Funktionen für die Audioverarbeitung und -bearbeitung.

<details>
<summary>Installieren</summary>

```bash
sudo pacman -S audacity
```

</details>

### ✨ Die Wissensdatenbank Obsidian installieren

> `Obsidian` ist eine leistungsstarke Wissensdatenbank und Notiz-App, die auf Markdown basiert. Sie ermöglicht es dir, Notizen zu erstellen, zu verknüpfen und in einem Netzwerk von Ideen zu organisieren. Obsidian eignet sich besonders gut für persönliche Wissensmanagement-Systeme, Forschung und kreative Projekte.

<details>
<summary>Installieren</summary>

```bash
sudo pacman -S obsidian
```

</details>

### Den grafischen Plasma-Systemmonitor installieren

> `plasma-systemmonitor` ist ein grafisches Werkzeug zur Überwachung von Systemressourcen wie CPU, RAM, Festplattennutzung und laufenden Prozessen. Es bietet eine benutzerfreundliche Oberfläche für die Analyse der Systemleistung und -auslastung.

```bash
sudo pacman -S plasma-systemmonitor
```

### ✨ Den Taskmanager Mission Center über yay installieren

> `mission-center` ist ein moderner Taskmanager und Systemmonitor, der eine übersichtliche Darstellung von laufenden Prozessen, Ressourcenverbrauch und Systeminformationen bietet. Er eignet sich besonders für Benutzer, die eine grafische Oberfläche zur Überwachung ihres Systems bevorzugen.

<details>
<summary>Installieren</summary>

```bash
yay -S mission-center
```

</details>

### ✨ Das digitale Mal- und Zeichenprogramm Krita installieren

> `Krita` ist ein professionelles digitales Mal- und Zeichenprogramm, das sich besonders für Illustratoren, Concept Artists und digitale Künstler eignet. Es bietet eine Vielzahl von Pinseltypen, Ebenenfunktionen und Zeichenwerkzeugen.

<details>
<summary>Installieren</summary>

```bash
sudo pacman -S krita
```

</details>

### ✨ Das Bildbearbeitungsprogramm GIMP installieren

> `GIMP` (GNU Image Manipulation Program) ist ein leistungsfähiges Open-Source-Bildbearbeitungsprogramm, das für Fotobearbeitung, Grafikdesign und digitale Kunst verwendet wird. Es bietet eine Vielzahl von Werkzeugen und Funktionen für die Bildbearbeitung.

<details>
<summary>Installieren</summary>

```bash
sudo pacman -S gimp
```

</details>

### ✨ Das professionelle Videoschnittprogramm Kdenlive installieren

> `Kdenlive` ist ein professionelles Videoschnittprogramm, das eine Vielzahl von Funktionen für die Videobearbeitung bietet. Es unterstützt mehrere Spuren, Effekte, Übergänge und bietet eine benutzerfreundliche Oberfläche für die Erstellung von Videos.

<details>
<summary>Installieren</summary>

```bash
sudo pacman -S kdenlive
```

</details>

### ✨ Das professionelle All-in-One-Videoschnittprogramm DaVinci Resolve installieren

> **DaVinci Resolve** ist eine professionelle All-in-One-Software für Videobearbeitung, Farbkorrektur, visuelle Effekte, Motion Graphics und Audio-Postproduktion.
>
> Die Software wird häufig in der Film- und Medienproduktion eingesetzt und kombiniert Schnitt, Color Grading, Effekte und Tonbearbeitung in einer einzigen Anwendung.
>
> Unter Linux benötigt DaVinci Resolve eine korrekt eingerichtete GPU-Unterstützung, besonders für hardwarebeschleunigte Effekte und Rendering.

<details>
<summary>Installieren</summary>

```bash
sudo pacman -S davinci-resolve
````

> **CachyOS:**
> Unter CachyOS reicht die Installation von `davinci-resolve` meistens aus, da benötigte Abhängigkeiten bereits passend eingerichtet sind.
>
> **Andere Arch-basierte Distributionen:**
> Je nach verwendeter Grafikkarte müssen die passenden Compute-Treiber zusätzlich installiert werden.

**NVIDIA:**

```bash
sudo pacman -S cuda opencl-nvidia
```

**AMD:**

```bash
sudo pacman -S rocm-opencl-runtime
```

</details>

<details>
<summary>✨ Videodateien für DaVinci Resolve vorbereiten</summary>

> Einige Kameras und Aufnahmeprogramme erzeugen Formate, die unter Linux oder in DaVinci Resolve nicht optimal funktionieren.
>
> Mit `ffmpeg` können Videos beispielsweise in ein besser geeignetes Schnittformat wie ProRes konvertiert werden.

Einzelne Datei konvertieren:

```bash
ffmpeg -i eingabe.mp4 -c:v prores_ks -profile:v 3 -c:a pcm_s16le ausgabe.mov
```

Mehrere MP4-Dateien automatisch konvertieren:

```bash
mkdir -p konvertiert && for f in *.mp4; do ffmpeg -i "$f" -c:v prores_ks -profile:v 3 -c:a pcm_s16le "konvertiert/${f%.mp4}.mov"; done
```

</details>

### ✨ Das plattformübergreifende Videoschnittprogramm Shotcut installieren

> `Shotcut` ist ein plattformübergreifendes Videoschnittprogramm, das eine Vielzahl von Funktionen für die Videobearbeitung bietet. Es unterstützt mehrere Spuren, Effekte, Übergänge und bietet eine benutzerfreundliche Oberfläche für die Erstellung von Videos.

<details>
<summary>Installieren</summary>

```bash
sudo pacman -S shotcut
```

</details>

### ✨ Die 3D-Grafik- und Animations-Suite Blender installieren

> `Blender` ist eine leistungsstarke Open-Source-Software für 3D-Modellierung, Animation, Rendering und Simulation. Sie wird in der Filmproduktion, Spieleentwicklung und für visuelle Effekte eingesetzt.

<details>
<summary>Installieren</summary>

```bash
sudo pacman -S blender
```

</details>

### ✨ Den E-Mail- und Kalender-Client Thunderbird installieren

> `Thunderbird` ist ein freier und quelloffener E-Mail-Client, der auch Kalender- und Aufgabenfunktionen bietet. Er unterstützt mehrere E-Mail-Konten, Erweiterungen und bietet eine benutzerfreundliche Oberfläche für die Verwaltung von E-Mails.

<details>
<summary>Installieren</summary>

```bash
sudo pacman -S thunderbird
```

</details>

### Den wissenschaftlichen Taschenrechner Qalculate! installieren

> `Qalculate!` ist ein leistungsfähiger wissenschaftlicher Taschenrechner, der sowohl einfache als auch komplexe Berechnungen unterstützt. Er bietet Funktionen wie Einheitenumrechnung, Währungsumrechnung, Statistik, Algebra und vieles mehr.

```bash
sudo pacman -S qalculate-gtk
```

### ✨ Den Screenshot- und Bildschirmaufnahme-Manager Flameshot installieren

> `Flameshot` ist ein leistungsfähiges Screenshot-Tool, das es ermöglicht, Screenshots zu erstellen, zu bearbeiten und zu teilen. Es bietet Funktionen wie Anmerkungen, Hervorhebungen, Zuschneiden und direkte Upload-Optionen.

<details>
<summary>Installieren</summary>

```bash
sudo pacman -S flameshot grim xdg-desktop-portal-hyprland
```

</details>

### Die Streaming- und Aufnahme-Software OBS Studio installieren

> **OBS Studio** (Open Broadcaster Software) ist eine freie und quelloffene Software für Bildschirmaufnahmen, Livestreams und Videoaufzeichnungen.
>
> OBS wird häufig für Streaming auf Plattformen wie Twitch, YouTube oder eigene RTMP-Server verwendet und bietet Funktionen wie Szenenverwaltung, Audio-Mixing, Webcam-Unterstützung, Filter und Hardware-Encoding.
>
> Unter Wayland benötigt OBS eine korrekt eingerichtete Desktop-Portal- und PipeWire-Umgebung, damit Bildschirmaufnahme und Fensteraufnahme zuverlässig funktionieren.

```bash
sudo pacman -S obs-studio
````

<details>
<summary>✨ Wayland- und Hyprland-Unterstützung einrichten</summary>

> Falls Bildschirmaufnahme, Fensteraufnahme oder die Auswahl von Monitoren unter Wayland nicht funktioniert, können die benötigten Portale und Audio-Dienste installiert beziehungsweise neu gestartet werden.

Benötigte Pakete installieren:

```bash
sudo pacman -S xdg-desktop-portal xdg-desktop-portal-hyprland pipewire wireplumber
```

Status der Desktop-Portale prüfen:

```bash
systemctl --user status xdg-desktop-portal
systemctl --user status xdg-desktop-portal-hyprland
```

Dienste neu starten:

```bash
systemctl --user restart xdg-desktop-portal
systemctl --user restart xdg-desktop-portal-hyprland
systemctl --user restart pipewire wireplumber
```

</details>

### Das Software-Zentrum Discover und das Flatpak-System installieren

> `Discover` ist ein grafisches Software-Zentrum für KDE Plasma, das es ermöglicht, Anwendungen zu durchsuchen, zu installieren und zu verwalten. Es unterstützt verschiedene Paketformate wie Flatpak, Snap und native Pakete.

```bash
sudo pacman -S discover flatpak
```

### Die Desktop-Uhr KClock installieren

> `KClock` ist eine Desktop-Uhr für KDE Plasma, die die aktuelle Zeit, Datum und zusätzliche Funktionen wie Wecker, Timer und Weltzeituhr bietet. Sie kann in der Systemleiste oder als eigenständiges Widget angezeigt werden.

```bash
sudo pacman -S kclock
```

### ✨ Den Morgen Calendar über yay installieren

> `Morgen` ist ein moderner Kalender-Client für Linux, der eine übersichtliche Darstellung von Terminen, Aufgaben und Erinnerungen bietet. Er unterstützt verschiedene Kalenderdienste wie Google Calendar, CalDAV und andere.

<details>
<summary>Installieren</summary>

```bash
yay -S morgen-bin
```

</details>

### Das Smartphone-Integrationswerkzeug KDE Connect installieren

> `KDE Connect` ist ein Tool, das die Integration zwischen deinem Linux-Desktop und deinem Smartphone ermöglicht. Es bietet Funktionen wie Dateiübertragung, Benachrichtigungen, Mediensteuerung und mehr.

```bash
sudo pacman -S kdeconnect
```

### ✨ Eine ältere Python-Version (3.12) über yay installieren

> `Python 3.12` ist eine ältere Version von Python, die für bestimmte Anwendungen oder Kompatibilitätsgründe benötigt werden kann.

<details>
<summary>Installieren</summary>

```bash
yay -S python312
```

</details>

### ✨ Die Office-Suite LibreOffice installieren

> **LibreOffice** ist eine freie und quelloffene Office-Suite für Textverarbeitung, Tabellenkalkulation, Präsentationen, Zeichnungen und weitere Büroanwendungen.
>
> Sie bietet eine hohe Kompatibilität zu Microsoft-Office-Dateiformaten wie `.docx`, `.xlsx` und `.pptx` und stellt eine vollständige Alternative zu kommerziellen Office-Paketen dar.

<details>
<summary>Installieren</summary>

```bash
sudo pacman -S libreoffice-fresh libreoffice-fresh-de
```

</details>

<details>
<summary>✨ Microsoft-kompatible Liberation-Schriftarten installieren</summary>

> **Liberation Fonts** sind freie Schriftarten, die metrisch mit bekannten Microsoft-Schriften wie Arial, Times New Roman und Courier New kompatibel sind.
>
> Sie verbessern die Darstellung und den Austausch von Dokumenten zwischen LibreOffice und Microsoft Office.

```bash
sudo pacman -S ttf-liberation
```

</details>

### ✨ Das Sandbox-Sicherheitswerkzeug Firejail installieren

> **Firejail** ist ein Sicherheitswerkzeug, das Anwendungen in einer isolierten Umgebung (Sandbox) ausführt. Es reduziert die Angriffsfläche von Programmen, indem es deren Zugriff auf das System einschränkt und potenzielle Sicherheitsrisiken minimiert.

<details>
<summary>Installieren</summary>

```bash
sudo pacman -S firejail
```

</details>

### ✨ Das vollständige Linux-Drucksystem CUPS für Hyprland mit KDE-Tools einrichten

> **CUPS** (Common UNIX Printing System) ist das zentrale Drucksystem unter Linux und ermöglicht die Verwaltung von lokalen und Netzwerkdruckern.
>
> Es unterstützt moderne Drucker über IPP, stellt Druckwarteschlangen bereit und funktioniert zuverlässig mit Wayland-Umgebungen wie **Hyprland** sowie KDE-Anwendungen.
>
> Mit `cups-filters`, `ghostscript` und `gutenprint` werden wichtige Druckfilter, PostScript-Unterstützung und zusätzliche Treiber für viele Druckermodelle installiert.
>
> `avahi` und `nss-mdns` ermöglichen die automatische Erkennung von Netzwerkdruckern über mDNS/Bonjour, beispielsweise bei WLAN-Druckern und AirPrint-kompatiblen Geräten.
>
> Für KDE-basierte Umgebungen wird zusätzlich `print-manager` verwendet, wodurch Drucker bequem über KDE-Systemwerkzeuge verwaltet werden können.

<details>
<summary>Installieren</summary>

```bash
sudo pacman -S cups cups-filters ghostscript gutenprint avahi nss-mdns print-manager
```

</details>

<details>
<summary>✨ CUPS-Dienst aktivieren und starten</summary>

> Nach der Installation muss der CUPS-Druckdienst aktiviert werden, damit Drucker automatisch verfügbar sind.

```bash
sudo systemctl enable --now cups.service
```

Status prüfen:

```bash
systemctl status cups.service
```

</details>

<details>
<summary>✨ Netzwerkdrucker-Erkennung aktivieren</summary>

> Für die automatische Erkennung von Druckern im lokalen Netzwerk wird **Avahi** verwendet. Dies ermöglicht die Erkennung von IPP-, WLAN- und AirPrint-kompatiblen Druckern.

```bash
sudo systemctl enable --now avahi-daemon.service
```

</details>

<details>
<summary>✨ Offizielle HP-Druckerunterstützung (HPLIP) installieren</summary>

> **HPLIP** (HP Linux Imaging and Printing) ist das offizielle Linux-Treiberpaket von HP für viele HP-Drucker und Multifunktionsgeräte.
>
> Es erweitert CUPS um zusätzliche Funktionen wie Scannen, Tintenstatusanzeige, Gerätekonfiguration und Unterstützung für viele HP LaserJet-, OfficeJet- und DeskJet-Modelle.
>
> Besonders bei HP-Multifunktionsgeräten wird HPLIP empfohlen, da dadurch neben dem Drucken auch Scanner-Funktionen unter Linux verfügbar werden.

```bash
sudo pacman -S hplip
```

</details>

<details>
<summary>✨ HP-Drucker erkennen und einrichten</summary>

> Nach der Installation von HPLIP können HP-Drucker automatisch erkannt und eingerichtet werden.

Geräteerkennung starten:

```bash
hp-setup
```

Installierte HP-Geräte anzeigen:

```bash
hp-info
```

Druckerstatus prüfen:

```bash
hp-status
```

</details>

<details>
<summary>✨ HP-Scanner-Unterstützung aktivieren</summary>

> Bei HP-Multifunktionsgeräten kann zusätzlich die Scan-Unterstützung aktiviert werden.

Scanner testen:

```bash
hp-scan
```

Falls eine grafische Scan-Oberfläche benötigt wird:

```bash
sudo pacman -S simple-scan
```

</details>

<details>
<summary>✨ Zusätzliche Druck- und PDF-Werkzeuge installieren</summary>

> Für die Verarbeitung von Textdateien, PostScript-Dokumenten und PDF-Dateien werden zusätzliche Werkzeuge installiert.
>
> `enscript` kann Textdateien in PostScript umwandeln, während `ghostscript` als Interpreter und Konverter für PostScript- und PDF-Dokumente dient.

```bash
sudo pacman -S enscript ghostscript
```

</details>

<details>
<summary>✨ KDE-Druckverwaltung unter Hyprland verwenden</summary>

> Unter Hyprland können weiterhin KDE-Systemwerkzeuge genutzt werden. `print-manager` integriert sich in KDE-Anwendungen und ermöglicht die grafische Verwaltung von Druckern.

KDE-Druckverwaltung öffnen:

```bash
systemsettings kcm_printer_manager
```

Falls die KDE-Systemeinstellungen fehlen:

<details>
<summary>Installieren</summary>

```bash
sudo pacman -S systemsettings
```

</details>

</details>

### ✨ Die moderne LaTeX-Alternative Tectonic und den Dokumenten-Konverter Pandoc einrichten

> **Tectonic** ist eine moderne LaTeX-Distribution, die das Erstellen von PDF-Dokumenten aus LaTeX-Quelltexten vereinfacht.
>
> Im Gegensatz zu klassischen LaTeX-Installationen verwaltet Tectonic benötigte Pakete automatisch und bietet eine einfache Möglichkeit, wissenschaftliche Dokumente, Berichte und Präsentationen zu erstellen.
>
> **Pandoc** ist ein universeller Dokumenten-Konverter, der Dateien zwischen verschiedenen Formaten wie Markdown, LaTeX, HTML, DOCX und PDF umwandeln kann.

<details>
<summary>Installieren</summary>

```bash
sudo pacman -S pandoc tectonic
```

</details>

### ✨ Die Rust-Alternative für den sudo-Befehl installieren

> **sudo-rs** ist eine moderne Implementierung des bekannten `sudo`-Befehls, geschrieben in der Programmiersprache Rust. Es bietet ähnliche Funktionalitäten wie das traditionelle `sudo`, ermöglicht jedoch eine sicherere und effizientere Ausführung von Befehlen mit erhöhten Rechten.

<details>
<summary>Installieren</summary>

```bash
sudo pacman -S sudo-rs
```

</details>

### Die HEIF- und AVIF-Bildbibliothek libheif installieren

> **libheif** ist eine Bibliothek zur Verarbeitung von HEIF- und AVIF-Bildformaten. Sie ermöglicht das Lesen, Schreiben und Konvertieren von Bildern in diesen modernen Formaten, die für ihre hohe Kompression und Qualität bekannt sind.

```bash
sudo pacman -S libheif
```

### Die erweiterten Bildformat-Plugins für KDE installieren

> **kimageformats** ist ein Paket, das zusätzliche Bildformat-Plugins für KDE-Anwendungen bereitstellt. Es erweitert die Unterstützung für verschiedene Bildformate und ermöglicht eine bessere Integration in KDE-Software wie Gwenview, Krita und andere.

```bash
sudo pacman -S kimageformats
```

### Den Netzwerk-Bandbreiten-Monitor bandwhich installieren

> **bandwhich** ist ein Kommandozeilenwerkzeug, das die aktuelle Netzwerkbandbreite überwacht und anzeigt. Es zeigt an, welche Prozesse und Verbindungen die meiste Bandbreite verbrauchen, und bietet eine übersichtliche Darstellung der Netzwerkaktivität.

```bash
sudo pacman -S bandwhich
```

### Den Netzwerk-Protokollanalysator Wireshark installieren

> **Wireshark** ist ein leistungsfähiger Netzwerk-Protokollanalysator, der es ermöglicht, den Netzwerkverkehr zu überwachen, zu analysieren und zu debuggen. Es unterstützt eine Vielzahl von Protokollen und bietet eine grafische Benutzeroberfläche zur Visualisierung von Netzwerkpaketen.

```bash
sudo pacman -S wireshark-qt
```

### Den zweispaltigen Dateimanager Krusader installieren

> **Krusader** ist ein leistungsstarkes, zweispaltiges Dateimanagement-Tool für KDE. Es bietet eine umfangreiche Funktionalität zur Dateiorganisation, -verwaltung und -bearbeitung.

```bash
sudo pacman -S krusader
```

### Das offizielle 7-Zip-Kompressionswerkzeug installieren

> **7-Zip** ist ein leistungsfähiges Kompressionswerkzeug, das eine hohe Kompressionsrate und Unterstützung für verschiedene Archivformate bietet. Es ermöglicht das Erstellen, Extrahieren und Verwalten von komprimierten Dateien.

```bash
sudo pacman -S 7zip
```

### QEMU, KVM und die grafische Verwaltung Virt-Manager installieren

> **QEMU** ist eine leistungsfähige Open-Source-Virtualisierungslösung, die zusammen mit **KVM** (Kernel-based Virtual Machine) eine nahezu native Geschwindigkeit für virtuelle Maschinen unter Linux ermöglicht.
>
> **libvirt** stellt eine einheitliche Verwaltungs-Schnittstelle für Virtualisierung bereit und ermöglicht die Steuerung von QEMU/KVM über grafische Werkzeuge wie **Virt-Manager**.
>
> **Virt-Manager** ist eine grafische Oberfläche zur Erstellung, Verwaltung und Überwachung virtueller Maschinen. Es eignet sich besonders für Linux-Desktops wie **Hyprland mit KDE-Tools**, da es vollständig unabhängig von der Desktop-Umgebung funktioniert.
>
> Zusätzliche Pakete wie `virt-viewer`, `SPICE`, `virglrenderer` und Video-/Audio-Unterstützung verbessern die Integration, Grafikleistung und Bedienung virtueller Maschinen.

```bash
sudo pacman -Syu qemu-full virt-manager libvirt virt-viewer dnsmasq qemu-ui-gtk qemu-ui-sdl qemu-audio-pa spice-gtk virglrenderer libvdpau libva-mesa-driver spice-vdagent
```

<details>
<summary>✨ Den Virtualisierungsdienst für KVM/QEMU aktivieren</summary>

> Der `libvirtd`-Dienst verwaltet virtuelle Maschinen und stellt die Verbindung zwischen Virt-Manager und QEMU/KVM her.

```bash
sudo systemctl enable --now libvirtd.service
```

Status prüfen:

```bash
systemctl status libvirtd.service
```

</details>

<details>
<summary>✨ Benutzerrechte für KVM und libvirt einrichten</summary>

> Damit virtuelle Maschinen ohne ständige Root-Rechte über Virt-Manager verwaltet werden können, wird der Benutzer den Gruppen `libvirt` und `kvm` hinzugefügt.

```bash
sudo usermod -aG libvirt,kvm $(whoami)
```

> Danach muss sich der Benutzer einmal ab- und wieder anmelden, damit die Gruppenänderungen aktiv werden.

</details>

<details>
<summary>✨ Prüfen, ob Hardware-Virtualisierung verfügbar ist</summary>

> Moderne Prozessoren benötigen aktivierte Virtualisierungserweiterungen wie **Intel VT-x** oder **AMD-V**.
>
> Mit folgendem Befehl kann geprüft werden, ob die CPU Virtualisierung unterstützt:

```bash
LC_ALL=C lscpu | grep Virtualization
```

Unterstützte Kernel-Module prüfen:

```bash
lsmod | grep kvm
```

</details>

<details>
<summary>✨ Netzwerkverwaltung für virtuelle Maschinen einrichten</summary>

> Libvirt verwendet standardmäßig ein NAT-Netzwerk für virtuelle Maschinen. Falls dieses nicht automatisch gestartet wurde, kann es aktiviert werden.

Standard-Netzwerk prüfen:

```bash
sudo virsh net-list --all
```

Standard-Netzwerk aktivieren:

```bash
sudo virsh net-start default
sudo virsh net-autostart default
```

</details>

<details>
<summary>✨ Festplatten-Diagnosewerkzeuge verwenden</summary>

> Mit `smartctl` können Festplatten und SSDs auf Gesundheitszustand, Fehler und SMART-Werte überprüft werden.

Installieren:

```bash
sudo pacman -S smartmontools
```

Festplatten erkennen:

```bash
sudo smartctl --scan
```

</details>

<details>
<summary>✨ Vagrant mit Libvirt-Unterstützung installieren</summary>

> **Vagrant** ist ein Werkzeug zur automatisierten Erstellung und Verwaltung reproduzierbarer virtueller Entwicklungsumgebungen.
>
> Mit dem **vagrant-libvirt**-Plugin können virtuelle Maschinen direkt über QEMU/KVM und libvirt betrieben werden, ohne VirtualBox zu benötigen.

```bash
yay -S vagrant
```

Plugin installieren:

```bash
vagrant plugin install vagrant-libvirt
```

</details>

#### Das Highlight: Der optimale QEMU-Startbefell für Ubuntu 26.04 LTS, Kali Linux 2026, Cachy OS + BlackArch Linux

##### Ubuntu

###### Ubuntu: Installation mit GTK und Sicherheits-Sandbox

```bash
qemu-img create -f qcow2 ubuntu.qcow2 50G
```

###### Ubuntu: Standard-Start mit GTK-Display und Hardware-GL

```bash
qemu-system-x86_64 \
  -enable-kvm \
  -cpu host,kvm=off \
  -smp sockets=1,cores=6,threads=1 \
  -m 10G \
  -vga none \
  -device virtio-vga-gl,xres=3840,yres=2160 \
  -display gtk,gl=on,grab-on-hover=on \
  -drive file=ubuntu.qcow2,if=virtio,cache=writeback,format=qcow2 \
  -cdrom /home/jk/ubuntu/ubuntu-26.04-desktop-amd64.iso \
  -boot d \
  -netdev user,id=net0,restrict=yes \
  -device virtio-net-pci,netdev=net0 \
  -sandbox on,obsolete=deny,elevateprivileges=deny,spawn=deny,resourcecontrol=deny \
  -rtc base=localtime,clock=vm \
  -no-user-config \
  -nodefaults \
  -device qemu-xhci \
  -device usb-tablet \
  -device usb-kbd
```

###### Ubuntu: Erweiterte Ausführung mit SDL-OpenGL und Hardware-Virtualisierung

```bash
qemu-system-x86_64 \
   -enable-kvm \
   -cpu host \
   -smp sockets=1,cores=6,threads=1 \
   -m 10G \
   -device virtio-vga-gl,max_outputs=1,xres=3840,yres=2160 \
   -display gtk,gl=on,zoom-to-fit=on \
   -drive file=ubuntu.qcow2,if=virtio,format=qcow2,cache=writeback \
   -device qemu-xhci \
   -device usb-tablet \
   -device usb-kbd \
   -netdev user,id=net0 \
   -device virtio-net-pci,netdev=net0 \
   -rtc base=localtime,clock=host
```

###### Ubuntu: Full-Featured mit Spice-Unterstützung und Audio-PipeWire

```bash
qemu-system-x86_64 \
  -enable-kvm \
  -cpu host,hv_relaxed,hv_spinlocks=0x1fff,hv_vapic,hv_time,kvm=on \
  -smp 6,sockets=1,cores=6,threads=1 \
  -m 10G \
  -device virtio-vga-gl,max_outputs=1,xres=3840,yres=2160 \
  -display sdl,gl=on,grab-mod=rctrl \
  -device virtio-blk-pci,drive=hd0,num-queues=6 \
  -drive file=ubuntu.qcow2,id=hd0,if=none,format=qcow2,cache=writeback,aio=threads,discard=unmap \
  -device qemu-xhci,id=xhci \
  -device usb-tablet,bus=xhci.0 \
  -netdev user,id=net0 \
  -device virtio-net-pci,netdev=net0 \
  -device virtio-serial-pci \
  -device virtserialport,chardev=spicechannel0,name=com.redhat.spice.0 \
  -chardev spicevmc,id=spicechannel0,name=vdagent \
  -audiodev pipewire,id=audio0 \
  -device virtio-sound-pci,audiodev=audio0 \
  -rtc base=localtime,clock=host
```

###### Ubuntu: High-Performance mit Cache=none und Native AIO

```bash
qemu-system-x86_64 \
  -enable-kvm \
  -cpu host,hv_relaxed,hv_spinlocks=0x1fff,hv_vapic,hv_time \
  -smp 6,sockets=1,cores=6,threads=1 \
  -m 10G \
  -device virtio-vga-gl,max_outputs=1,xres=3840,yres=2160 \
  -display sdl,gl=on,grab-mod=rctrl \
  -device virtio-blk-pci,drive=hd0,num-queues=6 \
  -drive file=ubuntu.qcow2,id=hd0,if=none,format=qcow2,cache=none,aio=native,discard=unmap \
  -device qemu-xhci,id=xhci \
  -device usb-tablet,bus=xhci.0 \
  -netdev user,id=net0 \
  -device virtio-net-pci,netdev=net0 \
  -audiodev pipewire,id=audio0 \
  -device virtio-sound-pci,audiodev=audio0 \
  -rtc base=utc,clock=host \
  -sandbox on,obsolete=deny,elevateprivileges=deny,spawn=deny,resourcecontrol=deny
```

###### Ubuntu: Spice-Server mit RNG-Entropie und Vollem Sicherheits-Setup

```bash
qemu-system-x86_64 \
  -machine type=q35,accel=kvm \
  -enable-kvm \
  -sandbox on,obsolete=deny,elevateprivileges=deny,resourcecontrol=deny \
  -cpu host,migratable=off \
  -smp 6,sockets=1,cores=6,threads=1 \
  -m 10G \
  -device virtio-vga-gl,max_outputs=1,xres=3840,yres=2160 \
  -display spice-app,gl=on \
  -spice gl=on,image-compression=off,streaming-video=all \
  -device virtio-blk-pci,drive=hd0,num-queues=6 \
  -drive file=ubuntu.qcow2,id=hd0,if=none,format=qcow2,cache=none,aio=native,discard=unmap \
  -device qemu-xhci,id=xhci \
  -device usb-tablet,bus=xhci.0 \
  -netdev user,id=net0 \
  -device virtio-net-pci,netdev=net0 \
  -device virtio-serial-pci \
  -device virtserialport,chardev=spicechannel0,name=com.redhat.spice.0 \
  -chardev spicevmc,id=spicechannel0,name=vdagent \
  -object rng-random,id=rng0,filename=/dev/urandom \
  -device virtio-rng-pci,rng=rng0 \
  -audiodev pipewire,id=audio0 \
  -device virtio-sound-pci,audiodev=audio0 \
  -rtc base=localtime,clock=host
```

###### Ubuntu: **Empfohlener Standard** (Optimiert für Performance & Sicherheit)

```bash
qemu-system-x86_64 \
  -enable-kvm \
  -cpu host \
  -smp 6,sockets=1,cores=6,threads=1 \
  -m 10G \
  -device virtio-vga-gl,max_outputs=1,xres=3840,yres=2160 \
  # -global virtio-vga.max_hostmem=268435456 \
  -display sdl,gl=on,grab-mod=rctrl \
  -device virtio-blk-pci,drive=hd0,num-queues=6 \
  -drive file=ubuntu.qcow2,id=hd0,if=none,format=qcow2,cache=none,aio=native,discard=unmap \
  -device qemu-xhci,id=xhci \
  -device usb-tablet,bus=xhci.0 \
  -netdev user,id=net0 \
  -device virtio-net-pci,netdev=net0 \
  -audiodev pipewire,id=audio0 \
  -device virtio-sound-pci,audiodev=audio0 \
  -rtc base=utc,clock=host \
  -sandbox on,obsolete=deny,elevateprivileges=deny,spawn=deny,resourcecontrol=deny
```

##### Kali

###### Kali Linux: Minimal-Konfiguration für schnelle Tests

```bash
qemu-system-x86_64 \
      -enable-kvm \
      -m 6144 \
      -cpu host \
      -smp 6 \
      -netdev user,id=n1 \
      -device virtio-net-pci,netdev=n1 \
      -vga virtio \
      -display gtk,gl=on \
      -drive file=kali-linux-2026.1-qemu-amd64.qcow2,format=qcow2
```

###### Kali Linux: Erweitertes Setup mit hochauflösender Grafik

```bash
qemu-system-x86_64 \
      -enable-kvm \
      -m 6144 \
      -cpu host \
      -smp 6 \
      -netdev user,id=n1 \
      -device virtio-net-pci,netdev=n1 \
      -device virtio-vga-gl,max_outputs=1,xres=3840,yres=2160,vgamem_mb=256 \
      -display gtk,gl=on \
      -drive file=kali-linux-2026.1-qemu-amd64.qcow2,format=qcow2
```

###### Kali Linux: Komfortabel mit Spice und Clipboard-Integration

```bash
qemu-system-x86_64 \
    -enable-kvm \
    -cpu host,hv_relaxed,hv_spinlocks=0x1fff,hv_vapic,hv_time,kvm=on \
    -smp 6,sockets=1,cores=6,threads=1 \
    -m 6G \
    -device virtio-vga-gl,max_outputs=1,xres=3840,yres=2160 \
    -display spice-app,gl=on \
    -device virtio-blk-pci,drive=hd0,num-queues=6 \
    -drive file=kali-linux-2026.2-qemu-amd64.qcow2,id=hd0,if=none,format=qcow2,cache=writeback,aio=threads,discard=unmap \
    -device qemu-xhci,id=xhci \
    -device usb-tablet,bus=xhci.0 \
    -netdev user,id=net0 \
    -device virtio-net-pci,netdev=net0 \
    -device virtio-serial-pci \
    -device virtserialport,chardev=spicechannel0,name=com.redhat.spice.0 \
    -chardev spicevmc,id=spicechannel0,name=vdagent \
    -audiodev pipewire,id=audio0 \
    -device virtio-sound-pci,audiodev=audio0 \
    -rtc base=localtime,clock=host
```

###### Kali Linux: Maximal sicher mit Q35-Maschine und RNG

```bash
qemu-system-x86_64 \
  -machine type=q35,accel=kvm \
  -enable-kvm \
  -sandbox on,obsolete=deny,elevateprivileges=deny,resourcecontrol=deny \
  -cpu host,migratable=off \
  -smp 6,sockets=1,cores=6,threads=1 \
  -m 10G \
  -device virtio-vga-gl,max_outputs=1,xres=3840,yres=2160 \
  -display spice-app,gl=on \
  -spice gl=on,image-compression=off,streaming-video=all \
  -device virtio-blk-pci,drive=hd0,num-queues=6 \
  -drive file=kali-linux-2026.2-qemu-amd64.qcow2,id=hd0,if=none,format=qcow2,cache=none,aio=native,discard=unmap \
  -device qemu-xhci,id=xhci \
  -device usb-tablet,bus=xhci.0 \
  -netdev user,id=net0 \
  -device virtio-net-pci,netdev=net0 \
  -device virtio-serial-pci \
  -device virtserialport,chardev=spicechannel0,name=com.redhat.spice.0 \
  -chardev spicevmc,id=spicechannel0,name=vdagent \
  -object rng-random,id=rng0,filename=/dev/urandom \
  -device virtio-rng-pci,rng=rng0 \
  -audiodev pipewire,id=audio0 \
  -device virtio-sound-pci,audiodev=audio0 \
  -rtc base=localtime,clock=host
```

###### Kali Linux: Kompakt mit 1080p-Auflösung und Spice

```bash
qemu-system-x86_64 \
    -enable-kvm \
    -cpu host,hv_relaxed,hv_spinlocks=0x1fff,hv_vapic,hv_time,kvm=on \
    -smp 6,sockets=1,cores=6,threads=1 \
    -m 6G \
    -device virtio-vga-gl,max_outputs=1,xres=1920,yres=1080 \
    -display spice-app,gl=on \
    -device virtio-blk-pci,drive=hd0,num-queues=6 \
    -drive file=kali-linux-2026.2-qemu-amd64.qcow2,id=hd0,if=none,format=qcow2,cache=writeback,aio=threads,discard=unmap \
    -device qemu-xhci,id=xhci \
    -device usb-tablet,bus=xhci.0 \
    -netdev user,id=net0 \
    -device virtio-net-pci,netdev=net0 \
    -device virtio-serial-pci \
    -device virtserialport,chardev=spicechannel0,name=com.redhat.spice.0 \
    -chardev spicevmc,id=spicechannel0,name=vdagent \
    -audiodev pipewire,id=audio0 \
    -device virtio-sound-pci,audiodev=audio0 \
    -rtc base=localtime,clock=host
```

###### Kali Linux: SDL-Display mit Hardware-Virtualisierung und Audio

```bash
qemu-system-x86_64 \
  -enable-kvm \
  -cpu host,hv_relaxed,hv_spinlocks=0x1fff,hv_vapic,hv_time,kvm=on \
  -smp 6,sockets=1,cores=6,threads=1 \
  -m 10G \
  -device virtio-vga-gl,max_outputs=1,xres=3840,yres=2160 \
  -display sdl,gl=on,grab-mod=rctrl \
  -device virtio-blk-pci,drive=hd0,num-queues=6 \
  -drive file=kali-linux-2026.2-qemu-amd64.qcow2,id=hd0,if=none,format=qcow2,cache=writeback,aio=threads,discard=unmap \
  -device qemu-xhci,id=xhci \
  -device usb-tablet,bus=xhci.0 \
  -netdev user,id=net0 \
  -device virtio-net-pci,netdev=net0 \
  -device virtio-serial-pci \
  -device virtserialport,chardev=spicechannel0,name=com.redhat.spice.0 \
  -chardev spicevmc,id=spicechannel0,name=vdagent \
  -audiodev pipewire,id=audio0 \
  -device virtio-sound-pci,audiodev=audio0 \
  -rtc base=localtime,clock=host
```

###### Kali Linux: Hochperformant mit Cache=none und Native AIO

```bash
qemu-system-x86_64 \
  -enable-kvm \
  -cpu host,hv_relaxed,hv_spinlocks=0x1fff,hv_vapic,hv_time \
  -smp 6,sockets=1,cores=6,threads=1 \
  -m 10G \
  -device virtio-vga-gl,max_outputs=1,xres=3840,yres=2160 \
  -display sdl,gl=on,grab-mod=rctrl \
  -device virtio-blk-pci,drive=hd0,num-queues=6 \
  -drive file=kali-linux-2026.2-qemu-amd64.qcow2,id=hd0,if=none,format=qcow2,cache=none,aio=native,discard=unmap \
  -device qemu-xhci,id=xhci \
  -device usb-tablet,bus=xhci.0 \
  -netdev user,id=net0 \
  -device virtio-net-pci,netdev=net0 \
  -audiodev pipewire,id=audio0 \
  -device virtio-sound-pci,audiodev=audio0 \
  -rtc base=utc,clock=host \
  -sandbox on,obsolete=deny,elevateprivileges=deny,spawn=deny,resourcecontrol=deny
```

###### Kali Linux: **Empfohlene Standard-Konfiguration** (Sicher & Schnell)

```bash
qemu-system-x86_64 \
  -enable-kvm \
  -cpu host \
  -smp 6,sockets=1,cores=6,threads=1 \
  -m 10G \
  -device virtio-vga-gl,max_outputs=1,xres=3840,yres=2160 \
  # -global virtio-vga.max_hostmem=268435456 \
  -display sdl,gl=on,grab-mod=rctrl \
  -device virtio-blk-pci,drive=hd0,num-queues=6 \
  -drive file=kali-linux-2026.2-qemu-amd64.qcow2,id=hd0,if=none,format=qcow2,cache=none,aio=native,discard=unmap \
  -device qemu-xhci,id=xhci \
  -device usb-tablet,bus=xhci.0 \
  -netdev user,id=net0 \
  -device virtio-net-pci,netdev=net0 \
  -audiodev pipewire,id=audio0 \
  -device virtio-sound-pci,audiodev=audio0 \
  -rtc base=utc,clock=host \
  -sandbox on,obsolete=deny,elevateprivileges=deny,spawn=deny,resourcecontrol=deny
```

###### Kali Linux: **Minimales Sicherheits-Setup** für Isolation

```bash
qemu-system-x86_64 \
  -enable-kvm \
  -machine q35 \
  -cpu host \
  -smp 2 \
  -m 4G \
  -display gtk \
  -device virtio-vga \
  -drive file=kali-linux-2026.2-qemu-amd64.qcow2,if=virtio,format=qcow2,cache=none,aio=native,discard=unmap \
  -netdev user,id=net0 \
  -device virtio-net-pci,netdev=net0 \
  -rtc base=utc \
  -sandbox on,obsolete=deny,elevateprivileges=deny,spawn=deny,resourcecontrol=deny \
  -no-user-config
```

####### Fehlerbehebung: Fehlende Bibliotheken reparieren

```bash
sudo pacman -S virglrenderer
```

##### Cachy OS + Black Arch

###### Cachy OS & BlackArch: Vorbereitung (Disk & UEFI-Variablen)

```bash
qemu-img create -f qcow2 cachyos.qcow2 80G
```

```bash
cp /usr/share/edk2/x64/OVMF_VARS.4m.fd cachyos_VARS.fd
```

###### Cachy OS & BlackArch: Installation mit UEFI und Sandbox

```bash
qemu-system-x86_64 \
  -enable-kvm \
  -machine q35 \
  -cpu host \
  -smp sockets=1,cores=6,threads=1 \
  -m 10G \
  -vga none \
  -device virtio-vga-gl,xres=1920,yres=1080 \
  -display gtk,gl=on,grab-on-hover=on \
  -drive file=cachyos.qcow2,if=virtio,cache=writeback,format=qcow2 \
  -drive if=pflash,format=raw,readonly=on,file=/usr/share/edk2/x64/OVMF_CODE.4m.fd \
  -drive if=pflash,format=raw,file=cachyos_VARS.fd \
  -cdrom /home/jk/blackarch/cachyos-desktop-linux-260809.iso \
  -boot d \
  -netdev user,id=net0,restrict=no \
  -device virtio-net-pci,netdev=net0 \
  -sandbox on,obsolete=deny,elevateprivileges=deny,spawn=deny,resourcecontrol=deny \
  -rtc base=localtime,clock=vm \
  -device qemu-xhci \
  -device usb-tablet \
  -device usb-kbd
```

###### Cachy OS & BlackArch: **Empfohlene Konfiguration** (UEFI, OpenGL, PipeWire)

```bash
qemu-system-x86_64 \
  -enable-kvm \
  -machine q35 \
  -cpu host \
  -smp 6,sockets=1,cores=6,threads=1 \
  -m 10G \
  -device virtio-vga-gl,max_outputs=1,xres=3840,yres=2160 \
  # -global virtio-vga.max_hostmem=268435456 \
  -display sdl,gl=on,grab-mod=rctrl \
  -drive file=cachyos.qcow2,if=none,id=hd0,format=qcow2,cache=none,aio=native,discard=unmap \
  -device virtio-blk-pci,drive=hd0,num-queues=6 \
  -drive if=pflash,format=raw,readonly=on,file=/usr/share/edk2/x64/OVMF_CODE.4m.fd \
  -drive if=pflash,format=raw,file=cachyos_VARS.fd \
  -device qemu-xhci,id=xhci \
  -device usb-tablet,bus=xhci.0 \
  -netdev user,id=net0 \
  -device virtio-net-pci,netdev=net0 \
  -audiodev pipewire,id=audio0 \
  -device virtio-sound-pci,audiodev=audio0 \
  -rtc base=utc,clock=host \
  -sandbox on,obsolete=deny,elevateprivileges=deny,spawn=deny,resourcecontrol=deny
```

###### Cachy OS & BlackArch: **Minimales Sicherheits-Setup** ohne UEFI-Komplexität

```bash
qemu-system-x86_64 \
  -enable-kvm \
  -machine q35 \
  -cpu host \
  -smp 6 \
  -m 8G \
  -display gtk \
  -device virtio-vga \
  -drive file=cachyos.qcow2,if=virtio,format=qcow2,cache=none,aio=native,discard=unmap \
  -netdev user,id=net0 \
  -device virtio-net-pci,netdev=net0 \
  -rtc base=utc \
  -sandbox on,obsolete=deny,elevateprivileges=deny,spawn=deny,resourcecontrol=deny \
  -no-user-config
```

####### Fehlerbehebung: Fehlende Bibliotheken reparieren

```bash
sudo pacman -S virglrenderer
```

<details>
<summary>Ubuntu Configuration</summary>

#### Ubuntu Configuration

##### Bei Ubuntu noch

```bash
sudo apt install spice-vdagent
```

</details>

<details>
<summary>BlackArch Configuration</summary>

#### BlackArch Configuration

Du kannst die gleiche config wie bei JK-Arch verwenden nur bitte kein Hyperland in der QEMU VM verweden sonder KDE Plasma oder XFCE.

##### BlackArch installieren

```bash
cd ~
curl -O https://blackarch.org/strap.sh
echo 00688950aaf5e5804d2abebb8d3d3ea1d28525ed strap.sh | sha1sum -c
cat strap.sh
```

```bash
chmod +x strap.sh
sudo ./strap.sh
sudo pacman -Syu
sudo pacman -Sgg | grep blackarch | cut -d' ' -f2 | sort -u
```

###### Cool bei Kde Plasma

```bash
git clone --depth=1 https://github.com/catppuccin/kde catppuccin-kde && cd catppuccin-kde
cat ./install.sh
```

```bash
./install.sh
```

##### Pentesting Tools installieren

```bash
# sudo pacman -S blackarch -> 2.860 Tools

# Web-Hacking: sudo pacman -S blackarch-webapp
# Netzwerk-Werkzeuge: sudo pacman -S blackarch-network
# WLAN-Hacking: sudo pacman -S blackarch-wireless

sudo pacman -Syu \
  nmap \           # Port-Scan und Schwachstellen-Check
  metasploit \     # Exploitation
  hydra \          # Passwort-Cracking
  wireshark-qt \   # Netzwerk-Analyse
  john \           # Passwort-Hash-Cracking
  nikto \          # Web-Scanner (perfekt für Metasploitable)
  whatweb \        # Web-Technologie-Erkennung
  theHarvester \   # OSINT (E-Mails, Domains)
  shodan \         # Shodan-CLI (falls API-Key vorhanden)
  bind-tools \     # host, dig, nslookup
  tcpdump \        # Paket-Mitschnitt
  netcat-openbsd \ # Schweizer Taschenmesser
  koadic \         # C2 Framework
  setoolkit \      # Social Engineering
  sliver \         # Modernes C2 Framework
  powersploit \    # PowerShell Exploits
  sslyze \         # SSL/TLS Analyse
  sslscan \        # SSL/TLS Analyse
  testssl.sh       # SSL/TLS Analyse
  hashcat          # GPU-basiertes Cracking (optional)
```

</details>

<details>
<summary>Kali-Linux Configuration</summary>

#### Kali-Linux Configuration

##### Passwort ändern

```bash
passwd
```

##### Snap installieren

```bash
sudo apt install -y snapd
sudo systemctl enable --now snapd.socket
sudo ln -s /var/lib/snapd/snap /snap
sudo reboot
```

und dann:

```bash
snap version
sudo snap install code --classic
# ✓ C/C++
# ✓ clangd
# ✓ CMake Tools
# ✓ CodeLLDB
# ✓ SonarQube for IDE
# ✓ Hex Editor
# ✓ x86 and x86_64 Assembly
# ✓ Makefile Tools
# ✓ GitLens
# ✓ Error Lens
sudo snap install firefox --beta
# about:config
# Suche nach: devtools
sudo snap install brave
```

##### Basis-Tools

```bash
sudo apt update
sudo apt install -y \
    curl wget unzip git fzf cmark shellcheck
```

##### Compiler & Toolchain

```bash
sudo apt install -y \
    build-essential gcc g++ clang llvm lldb cmake ninja-build clang-tidy valgrind clangd openjdk-21-jdk
```

##### Debugging

```bash
sudo apt install -y \
    gdb gdbserver strace ltrace gef
```

Go to `https://github.com/pwndbg/pwndbg/releases` and:

```bash
sudo apt install ./pwndbg_2026.07.29_amd64.deb
```

##### Reverse Engineering

```bash
sudo apt install -y \
    rizin binwalk yara elfutils
```

Go to `https://github.com/slimm609/checksec/releases` and:

```bash
sudo apt install ./checksec_3.2.0_amd64.deb 
```

##### Fuzzing & Performance

```bash
sudo apt install -y \
    afl++ linux-perf cppcheck
```

> Falls `linux-perf` nicht gefunden wird:

```bash
apt search linux-perf
```

##### GUI-Bibliotheken

```bash
sudo apt install -y \
    libgtk-4-dev libadwaita-1-dev librsvg2-dev adwaita-icon-theme
```

##### Benchmarking & Profiling

```bash
sudo apt install -y time hyperfine
```

##### Rust

```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

##### Java

```bash
curl -s "https://get.sdkman.io" | bash
source "$HOME/.sdkman/bin/sdkman-init.sh"
sdk install gradle
```

##### Docker

```bash
# Ich würde noch Docker installieren
# Add Docker's official GPG key:
sudo apt update
sudo apt install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
# Add the repository to Apt sources:
sudo tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Signed-By: /etc/apt/keyrings/docker.asc
EOF
sudo apt update
sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
docker --version
```

##### Ghidra

```bash
sudo apt install -y ghidra
```

##### Fish

```bash
sudo apt install -y fish
chsh -s /usr/bin/fish
curl -sS https://starship.rs/install.sh | sh
sudo apt install -y zoxide
sudo apt install -y eza
sudo apt install -y neovim
# cargo install yazi-fm yazi-cli
# sudo apt install -y lazygit
# sudo apt install -y navi
sudo apt install -y fonts-firacode
sudo apt install -y ripgrep fd-find bat htop btop
sudo apt install -y kitty alacritty
sudo apt install -y wl-clipboard fd-find
sudo apt install -y python3-venv python3-pip
# sudo apt install pipx
# pipx ensurepath
# pipx install black
# pipx install ruff
sudo apt install -y ripgrep
sudo apt install -y nodejs npm
sudo apt install -y gzip
sudo npm install -g typescript
sudo apt install -y hunspell-de-de hunspell-en-us
sudo apt install -y acpi
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install -y nodejs
```

```bash
cd ~/Downloads
sudo apt install -y libreadline-dev golang-go
cargo install asm-lsp --version 0.10.1
wget https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
tar -xzf nvim-linux-x86_64.tar.gz
sudo mv nvim-linux-x86_64 /opt/nvim
echo 'export PATH="$PATH:/opt/nvim/bin"' >> ~/.bashrc
source ~/.bashrc
# required
# mv ~/.config/nvim{,.bak}
# optional but recommended
# mv ~/.local/share/nvim{,.bak}
# mv ~/.local/state/nvim{,.bak}
# mv ~/.cache/nvim{,.bak}
git clone https://github.com/LazyVim/starter ~/.config/nvim
# Das Entfernen von .git ist Absicht, sonst hängt man am Starter-Repo.
rm -rf ~/.config/nvim/.git 
mkdir -p ~/.local/share/fonts
cd ~/.local/share/fonts

wget https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip
unzip JetBrainsMono.zip -d JetBrainsMono

sudo mkdir -p /usr/share/fonts/truetype/nerd

sudo cp JetBrainsMono/*.ttf /usr/share/fonts/truetype/nerd/

sudo fc-cache -fv

rm JetBrainsMono.zip
cd ~

find_add_path /opt/nvim/bin

nvim
```

```bash
fish
```

```bash
curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish -o fisher.fish
less fisher.fish
```

```bash
source fisher.fish
fisher install jorgebucaran/fisher
fisher install jorgebucaran/autopair.fish nickeb96/fish-vim edc/bass PatrickF1/fzf.fish
```

##### Update NeoVim

```bash
# 1) Alte Version prüfen
/opt/nvim/bin/nvim --version

# 2) Neue Version laden oder von https://neovim.io/
cd ~/Downloads
wget https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz

# 3) Entpacken
tar -xzf nvim-linux-x86_64.tar.gz

# 4) Backup der alten Version (wichtig!)
sudo mv /opt/nvim /opt/nvim.bak

# 5) Neue Version installieren
sudo mv nvim-linux-x86_64 /opt/nvim

# 6) Test
/opt/nvim/bin/nvim --version
```

</details>

<details>
<summary>Metaexploitable 2 (test)</summary>

#### Metaexploitable 2

```bash
# 1. TAP Interface erstellen (sicherstellen, dass Ownership beim User bleibt)
# Wichtig: Wir nutzen 'user $USER', damit QEMU (als User) es nutzen kann.
sudo ip tuntap add dev tap0 mode tap user $USER

# 2. IP auf dem Host-Interface setzen (als "Gateway" für die VMs, aber kein Weiterleitung)
# Wir entfernen vorherige IPs, um Konflikte zu vermeiden
sudo ip addr flush dev tap0
sudo ip addr add 192.168.56.1/24 dev tap0

# 3. Interface aktivieren
sudo ip link set tap0 up

# 4. CRITICAL: IP Forwarding dauerhaft deaktivieren
# Dies verhindert, dass Daten vom TAP-Interface ins Internet weitergeleitet werden
sudo sysctl -w net.ipv4.ip_forward=0
# (Optional: Damit es nach Neustart erhalten bleibt, addiere es zu /etc/sysctl.conf)
# echo "net.ipv4.ip_forward = 0" | sudo tee -a /etc/sysctl.conf

# 5. Firewall-Regeln (Korrekte Reihenfolge!)

# A. Erlaube Verkehr zwischen den VMs im Subnetz (Muss zuerst!)
sudo iptables -A FORWARD -i tap0 -o tap0 -s 192.168.56.0/24 -d 192.168.56.0/24 -j ACCEPT

# B. Erlaube etablierte Verbindungen (für Rückantworten)
sudo iptables -A FORWARD -i tap0 -m state --state ESTABLISHED,RELATED -j ACCEPT
sudo iptables -A INPUT -i tap0 -m state --state ESTABLISHED,RELATED -j ACCEPT

# C. Blockiere ALLEN anderen Verkehr (Muss ganz unten!)
sudo iptables -A INPUT -i tap0 -j DROP
sudo iptables -A FORWARD -i tap0 -j DROP
sudo iptables -A OUTPUT -o tap0 -j DROP

# D. (Optional) ARP blockieren? NEIN, lass es weg für normale Kommunikation.
# sudo iptables -A INPUT -i tap0 -p arp -j DROP

sudo iptables -L -n -v
```

##### Blackarch starten

```bash
qemu-system-x86_64 \
  -enable-kvm \
  -cpu host \
  -smp 4,sockets=1,cores=4,threads=1 \
  -m 8G \
  -drive file=cachy.qcow2,id=hd0,if=none,format=qcow2,cache=none \
  -device virtio-blk-pci,drive=hd0 \
  -device virtio-net-pci,netdev=net0,mac=52:54:00:11:11:11 \
  -netdev tap,id=net0,ifname=tap0,script=no,downscript=no \
  -display sdl,gl=on \
  -name "BlackArch-Attacker" \
  -sandbox on,obsolete=deny,elevateprivileges=deny,spawn=deny,resourcecontrol=deny
```

##### Metasploitable 2 starten

```bash
# etv.: qemu-img convert -f vmdk -O qcow2 metasploitable2.vmdk metasploitable2.qcow2

qemu-system-x86_64 \
  -enable-kvm \
  -cpu host \
  -smp 2,sockets=1,cores=2,threads=1 \
  -m 2G \
  -drive file=metasploitable2.qcow2,id=hd0,if=none,format=qcow2,cache=none \
  -device virtio-blk-pci,drive=hd0 \
  -device virtio-net-pci,netdev=net0,mac=52:54:00:22:22:22 \
  -netdev tap,id=net0,ifname=tap0,script=no,downscript=no \
  -display sdl,gl=on \
  -name "Metasploitable2-Target" \
  -sandbox on,obsolete=deny,elevateprivileges=deny,spawn=deny,resourcecontrol=deny
```

##### In Blackarch

```bash
# sudo ip addr add 192.168.56.100/24 dev eth0
# sudo ip link set eth0 up

# IP setzen (z.B. 192.168.56.100)
sudo ip addr add 192.168.56.100/24 dev eth0
sudo ip link set eth0 up

# Gateway NICHT setzen
sudo route del default

ip addr
```

##### In Metasploitable 2

```bash
# sudo ifconfig eth0 192.168.56.101 netmask 255.255.255.0 up

# IP setzen (z.B. 192.168.56.101)
sudo ifconfig eth0 192.168.56.101 netmask 255.255.255.0 up

# Gateway NICHT setzen (damit kein Internet möglich ist)
# default gateway entfernen, falls vorhanden
sudo route del default

ifconfig
```

##### Verbindung testen: Von BlackArch aus

###### Ping Metasploitable

```bash
ping -c 3 192.168.56.101
# Sollte funktionieren
```

###### Ping Internet (muss fehlschlagen)

```bash
ping -c 3 8.8.8.8
# Sollte fehlschlagen: "Network unreachable" oder "Destination Host Unreachable"
```

###### Prüfe Firewall-Regeln

```bash
sudo iptables -L -n -v
# Du solltest DROP-Regeln für tap0 sehen
```

Wenn das klappt, bist du sicher im isolierten Netzwerk.

##### Metasploit starten

```bash
msfconsole
use exploit/multi/handler
# Oder einen spezifischen Exploit für Metasploitable, z.B. vsftpd
search vsftpd
use exploit/unix/ftp/vsftpd_234_backdoor
set RHOSTS 192.168.56.101
exploit
```

</details>

### ✨ Den grafischen Audio-Mixer pwvucontrol installieren

> `pwvucontrol` ist ein grafisches Frontend für PipeWire, das die Audioverwaltung erleichtert. Es bietet eine benutzerfreundliche Oberfläche zur Steuerung von Audioeingängen, -ausgängen und -geräten.

<details>
<summary>Installieren</summary>

```bash
sudo pacman -S pwvucontrol
```

</details>

### ✨ Den grafischen Audio-Verkabelungs-Manager qpwgraph installieren

> `qpwgraph` ist ein grafisches Tool, das die Verwaltung von Audioverbindungen in PipeWire erleichtert. Es ermöglicht das einfache Verbinden von Audioquellen und -senken über eine visuelle Oberfläche.

<details>
<summary>Installieren</summary>

```bash
sudo pacman -S qpwgraph
```

</details>

### ✨ Die lokale KI-Laufzeitumgebung Ollama installieren

> `Ollama` ist eine lokale KI-Laufzeitumgebung, die es ermöglicht, KI-Modelle direkt auf deinem System auszuführen. Sie bietet eine benutzerfreundliche Oberfläche und unterstützt verschiedene KI-Frameworks.

<details>
<summary>Installieren</summary>

```bash
sudo pacman -S ollama
```

</details>

### ✨ Den Remote-Desktop-Client KRDC installieren

> `KRDC` ist ein Remote-Desktop-Client, der es dir ermöglicht, dich über das Netzwerk mit anderen Computern zu verbinden und diese fernzusteuern.

<details>
<summary>Installieren</summary>

```bash
sudo pacman -S krdc
```

</details>

### ✨ Den ultraschnellen Download-Manager aria2 installieren

> `aria2` ist ein vielseitiger Download-Manager, der mehrere Protokolle unterstützt, darunter HTTP, HTTPS, FTP, BitTorrent und Metalink. Er ermöglicht parallele Downloads und kann die Download-Geschwindigkeit erheblich verbessern.

<details>
<summary>Installieren</summary>

```bash
sudo pacman -S aria2
```

</details>

### ✨ Das strukturelle Diff-Werkzeug Difftastic installieren

> `Difftastic` ist ein strukturelles Diff-Werkzeug, das Unterschiede zwischen Dateien auf einer höheren Ebene analysiert. Es erkennt Änderungen in der Struktur von Code und Text, anstatt nur Zeilenunterschiede zu vergleichen, was es besonders nützlich für die Code-Analyse macht.

<details>
<summary>Installieren</summary>

```bash
sudo pacman -S difftastic
```

</details>

### ✨ Das offizielle GitHub-Kommandozeilenwerkzeug (GitHub CLI) installieren

> `GitHub CLI` ist das offizielle Kommandozeilenwerkzeug für GitHub, das es ermöglicht, GitHub-Operationen direkt von der Kommandozeile aus durchzuführen.

<details>
<summary>Installieren</summary>

```bash
sudo pacman -S github-cli
```

</details>

### Das Software-Reverse-Engineering-Framework Ghidra über yay installieren

> **Ghidra** ist ein Software-Reverse-Engineering-Framework, das von der National Security Agency (NSA) entwickelt wurde. Es bietet eine Vielzahl von Tools zur Analyse von Binärdateien und zur Durchführung von Reverse Engineering.

```bash
sudo pacman -S ghidra
# yay -S ghidra
```

### ✨ Das universitäre WLAN (eduroam) fehlerfrei einrichten

> **eduroam** ist ein weltweites WLAN-Netzwerk für Studierende, Forschende und Mitarbeitende von Bildungseinrichtungen. Es ermöglicht den sicheren Zugang zu WLAN-Diensten an teilnehmenden Institutionen.

<details>
<summary>Installieren</summary>

```bash
sudo pacman -S --needed networkmanager python-dbus ca-certificates
yay -S geteduroam-gui
```

</details>

### ✨ Die offizielle Open-Source-Alternative für Universitäts-VPNs installieren

> **GlobalProtect** ist eine VPN-Lösung, die von Palo Alto Networks entwickelt wurde. Sie ermöglicht den sicheren Zugriff auf Unternehmensnetzwerke und wird häufig in akademischen Einrichtungen verwendet.

<details>
<summary>Installieren</summary>

```bash
# yay -S globalprotect-bin
sudo pacman -S globalprotect-openconnect
```

Grafische Oberfläche starten:

```bash
gpclient launch-gui
```

</details>

### Nützliche Fish plugins

> **Fisher** ist ein Plugin-Manager für die Fish Shell. Mit den folgenden Plugins lassen sich unter anderem automatisch passende Klammern einfügen, Vim-Tastenkürzel verwenden, Umgebungsvariablen aus Bash-Skripten übernehmen und fzf komfortabel in Fish integrieren.

Fisher-Skript herunterladen und überprüfen:

```bash
curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish -o fisher.fish
less fisher.fish
```

Fisher aktivieren und installieren:

```bash
source fisher.fish
fisher install jorgebucaran/fisher
```

Gewünschte Plugins installieren:

```bash
fisher install jorgebucaran/autopair.fish nickeb96/fish-vim edc/bass PatrickF1/fzf.fish
```

### Modernes Datei-Listing und ein interaktiver Terminal-Spickzettel

> **eza** ist ein modernes Ersatzwerkzeug für `ls`, das eine farbige und strukturierte Ausgabe bietet. Es unterstützt unter anderem Dateitypen, Berechtigungen, Größen, Zeitstempel und Git-Informationen.
>
> **navi** ist ein interaktives Kommandozeilenwerkzeug für Spickzettel, mit dem häufig benötigte Befehle schnell durchsucht, ausgewählt und direkt im Terminal verwendet werden können.

```bash
sudo pacman -S eza navi
```

#### Die offizielle Spickzettel-Datenbank für navi hinzufügen

> Die offizielle Spickzettel-Datenbank von navi enthält eine Vielzahl von nützlichen Befehlen und Anleitungen für verschiedene Tools und Anwendungen. Durch das Hinzufügen dieser Datenbank kannst du direkt auf eine umfangreiche Sammlung von Spickzetteln zugreifen.

```bash
navi repo add denisidoro/cheats
```

### ✨ Die CachyOS-spezifischen Spickzettel für navi hinzufügen (Optional)

> Die CachyOS-spezifischen Spickzettel für navi enthalten Anleitungen und Befehle, die speziell auf die CachyOS-Distribution zugeschnitten sind. Durch das Hinzufügen dieser Datenbank kannst du direkt auf eine Sammlung von Spickzetteln zugreifen, die für CachyOS-Benutzer besonders nützlich sind.

<details>
<summary>Installieren</summary>

```bash
navi repo add cachyos/cheats
```

</details>

### Für yazi: Die Desktop-Integrationswerkzeuge xdg-utils installieren

> `xdg-utils` ist ein Satz von Kommandozeilenwerkzeugen, die die Integration von Anwendungen in Desktop-Umgebungen erleichtern. Sie ermöglichen das Öffnen von URLs, Dateien und Anwendungen in der Standardanwendung des Systems.
> 
> Besonders praktisch finde ich xdg-open, da sich damit Dateien, Verzeichnisse und URLs unkompliziert mit der jeweils hinterlegten Standardanwendung öffnen lassen. Dafür habe ich in meiner Fish-Konfiguration zusätzlich den Befehl open als Alias für xdg-open hinzugefügt.

```bash
sudo pacman -S xdg-utils
```

### Für yazi: Die MIME-Typ-Erkennung perl-file-mimeinfo installieren

> `perl-file-mimeinfo` ist ein Perl-Modul, das die Erkennung von MIME-Typen basierend auf Dateiinhalten und -erweiterungen ermöglicht. Es wird häufig in Skripten und Anwendungen verwendet, um den Typ einer Datei zu bestimmen und entsprechend zu verarbeiten.

```bash
sudo pacman -S perl-file-mimeinfo
```

### ✨ Mauszeiger-Animationen (Cursor Shaders) für Ghostty einrichten

> Ghostty ist ein Terminal-Emulator, der Mauszeiger-Animationen (Cursor Shaders) unterstützt. Mit den folgenden Schritten kannst du die Cursor Shaders für Ghostty einrichten und anpassen.

<details>
<summary>Installieren</summary>

```bash
git clone https://github.com/sahaj-b/ghostty-cursor-shaders ~/.config/ghostty/shaders
```

</details>

### Einen modularen Fish-Konfigurationsordner erstellen

> Die Fish Shell unterstützt die Verwendung von modularen Konfigurationsdateien, die in einem speziellen Ordner abgelegt werden können. Dies ermöglicht eine bessere Organisation und Wartung der Konfiguration, da einzelne Module unabhängig voneinander verwaltet werden können.

```bash
mkdir -p ~/.config/fish/conf.d
```

### ✨ Den praktischen Befehls-Ausführer just installieren

> `just` ist ein praktisches Befehls-Ausführungswerkzeug, das es ermöglicht, wiederkehrende Aufgaben und Befehle in sogenannten "Justfiles" zu organisieren. Es bietet eine einfache Möglichkeit, komplexe Befehlsfolgen zu speichern und mit einem einzigen Befehl auszuführen.

<details>
<summary>Installieren</summary>

```bash
sudo pacman -S just
```

</details>

### ✨ Das Begrüßungsprogramm von CachyOS entfernen

> Das Begrüßungsprogramm von CachyOS, auch bekannt als "cachyos-hello", ist ein kleines Tool, das beim ersten Start des Systems angezeigt wird. Wenn du es entfernen möchtest, kannst du die folgenden Befehle verwenden:

<details>
<summary>Installieren</summary>

```bash
sudo pacman -R cachyos-hello
rm ~/.config/autostart/cachyos-hello.desktop
```

</details>

### ✨ Die moderne Schachdatenbank- und Analyse-Software En Croissant installieren

> **En Croissant** ist eine moderne grafische Benutzeroberfläche (GUI) für die Verwaltung von Schachdatenbanken und die Analyse von Schachpartien.
>
> Die Anwendung bietet Funktionen zur Verwaltung von Partien, zum Durchsuchen von Schachdatenbanken und zur Analyse mit Schach-Engines wie **Stockfish**. Sie eignet sich besonders für Spieler, die ihre eigenen Partien analysieren und umfangreiche Schachdatenbanken verwalten möchten.

<details>
<summary>Installieren</summary>

> **En Croissant** wird unter Arch Linux über das **Arch User Repository (AUR)** installiert. Für die grafische Oberfläche werden zusätzlich `webkit2gtk-4.1` und die benötigten GStreamer-Plugins installiert.

```bash
yay -S en-croissant-bin
sudo pacman -S webkit2gtk-4.1 gst-plugins-good
```

> Für die Schachanalyse wird zusätzlich die Schach-Engine **Stockfish** benötigt. Diese kann entweder über das System installiert oder direkt innerhalb von **En Croissant** eingerichtet werden.

```bash
yay -S stockfish
```

</details>

### ✨ Den Boot-Bildschirm (Plymouth) anpassen und das System-Abbild neu bauen

> **Plymouth** ist für die grafische Darstellung während des Systemstarts zuständig. Unter CachyOS kann das vorhandene Plymouth-Theme angepasst oder durch ein anderes Theme ersetzt werden.
>
> Mit `plymouth-set-default-theme` lässt sich das gewünschte Theme auswählen. Der Parameter `-R` sorgt zusätzlich dafür, dass das Initramfs nach der Änderung automatisch neu erstellt wird.

<details>
<summary>✨ Das Arch-Logo-Plymouth-Theme installieren</summary>

> Das Theme `arch-logo` kann aus dem AUR installiert und anschließend als Standard-Theme festgelegt werden.

```bash
yay -S plymouth-theme-arch-logo
sudo plymouth-set-default-theme -R arch-logo
```

Aktuell verwendetes Plymouth-Theme anzeigen:

```bash
plymouth-set-default-theme
```

</details>

<details>
<summary>✨ Das CachyOS-Plymouth-Theme wiederherstellen</summary>

> Falls anschließend wieder das standardmäßige **CachyOS-Plymouth-Theme** verwendet werden soll, kann das zuvor installierte Arch-Theme entfernt und anschließend das Theme `bgrt` aktiviert werden.

```bash
yay -Rns plymouth-theme-arch-logo
sudo plymouth-set-default-theme -R bgrt
```

</details>

<details>
<summary>✨ Ein eigenes Bild für das Plymouth-Theme verwenden</summary>

> Das vorhandene Plymouth-Theme von CachyOS befindet sich unter `/usr/share/plymouth/themes/cachyos/`.
>
> Ein eigenes Bild kann beispielsweise aus dem persönlichen Bilderordner in das Theme-Verzeichnis kopiert werden.

```bash
sudo mv ~/Pictures/auto.png /usr/share/plymouth/themes/cachyos/
```

> Im Theme-Verzeichnis können anschließend vorhandene Bilddateien umbenannt oder durch das eigene Bild ersetzt werden.

```bash
cd /usr/share/plymouth/themes/cachyos/

sudo mv watermark.png watermark3.png
sudo mv auto.png watermark.png
```

</details>

<details>
<summary>✨ Das System-Abbild neu erstellen</summary>

> Nach Änderungen am Plymouth-Theme muss das Initramfs neu erstellt werden, damit die Änderungen bereits während des Systemstarts verfügbar sind.

```bash
sudo mkinitcpio -P
```

> Anschließend kann das System neu gestartet werden, um die Änderungen am Boot-Bildschirm zu überprüfen.

</details>

## Nach der Neovim-Konfiguration

> Nach der Einrichtung von **Neovim** können je nach verwendeten Sprachservern und Plugins noch einige Anpassungen oder Bereinigungen notwendig sein.

<details>
<summary>C/C++: Alte Clang-Format-Dateien entfernen</summary>

> Falls Neovim beziehungsweise ein Plugin automatisch `.clang-format`-Dateien im Cache angelegt hat, können diese entfernt werden.

```bash
find ~ -name ".clang-format" -path "*/.cache/nvim/*" -delete
```

</details>

<details>
<summary>Java: Google Java Format für Neovim bereitstellen</summary>

> Für die Java-Formatierung kann die offizielle **Google Java Style**-Konfiguration verwendet werden.
>
> Zunächst wird das Verzeichnis für zusätzliche Sprachserver- und Konfigurationsdateien erstellt:

```bash
mkdir -p ~/.config/nvim/lang-servers
```

> Anschließend wird die Google-Java-Formatierung direkt aus dem offiziellen Google-Styleguide heruntergeladen:

```bash
curl -L \
https://raw.githubusercontent.com/google/styleguide/gh-pages/intellij-java-google-style.xml \
-o ~/.config/nvim/lang-servers/intellij-java-google-style.xml
```

</details>

<details>
<summary>ASM: Verzeichnis für den Assembly-Language-Server erstellen</summary>

> Für die Konfiguration des **Assembly Language Servers (ASM LSP)** wird ein eigenes Konfigurationsverzeichnis angelegt.

```bash
mkdir -p ~/.config/asm-lsp/
```

</details>

<details>
<summary>Rust: Vorhandenen rust-analyzer entfernen</summary>

> Falls `rust-analyzer` zuvor manuell über Cargo installiert wurde und stattdessen eine andere Installation verwendet werden soll, kann die vorhandene Binary entfernt werden.

```bash
rm ~/.cargo/bin/rust-analyzer
```

</details>

<details>
<summary>Markdown Preview: Änderungen an yarn.lock zurücksetzen</summary>

> Falls die `yarn.lock`-Datei des **markdown-preview.nvim**-Plugins verändert wurde, kann sie auf den ursprünglichen Stand des Git-Repositories zurückgesetzt werden.

```bash
cd ~/.local/share/nvim/lazy/markdown-preview.nvim
git checkout -- app/yarn.lock
```

</details>

### Code über den LSP-Server im Editor formatieren

> **Neovim** kann den aktuell geöffneten Quellcode direkt über den konfigurierten **LSP-Server (Language Server Protocol)** formatieren.
>
> Dadurch wird der Code automatisch entsprechend der vom jeweiligen Sprachserver bereitgestellten Formatierungsregeln formatiert.

Im Editor folgenden Befehl ausführen:

```vim
:lua vim.lsp.buf.format()
```

> Der Befehl formatiert den aktuell geöffneten Buffer. Voraussetzung ist, dass für die verwendete Programmiersprache ein LSP-Server mit aktivierter Formatierungsunterstützung eingerichtet ist.

## Emfehlungen bei end-4 -> fix soon

```bash
nvim ~/.config/quickshell/ii/modules/common/Config.qml
```

Zeile 480:

```qml
// property list<string> excludedSites: ["quora.com", "facebook.com"]
property list<string> excludedSites: []
```

# ✨ UFW ist langsam

> Falls **UFW (Uncomplicated Firewall)** unter Umständen sehr langsam reagiert, kann eine Anpassung der DNS-Konfiguration helfen.
>
> Dazu wird die Datei `/etc/resolv.conf` geöffnet und die verwendeten DNS-Server angepasst. In diesem Beispiel werden **Cloudflare DNS** (`1.1.1.1`) und **Google DNS** (`8.8.8.8`) verwendet.

```bash
sudo nvim /etc/resolv.conf
```

```bash
# Generated by NetworkManager
# nameserver 127.0.0.0
nameserver 1.1.1.1
nameserver 8.8.8.8
options single-request
options edns0 trust-ad
```

# ✨ Langsames Internet über WLAN beheben

> Falls die WLAN-Verbindung unter Linux ungewöhnlich langsam ist oder Verbindungsprobleme auftreten, kann dies bei bestimmten **Realtek-WLAN-Adaptern** an der Energieverwaltung des WLAN-Treibers liegen.
>
> Durch das Deaktivieren verschiedener Energiesparfunktionen des `8821ce`-Treibers kann die Stabilität und Geschwindigkeit der WLAN-Verbindung verbessert werden.

<details>
<summary>✨ Energiesparfunktionen des 8821ce-Treibers deaktivieren</summary>

> Zunächst wird eine Konfigurationsdatei für den `8821ce`-Treiber erstellt beziehungsweise bearbeitet:

```bash
sudo nvim /etc/modprobe.d/8821ce.conf
```

Folgende Optionen eintragen:

```ini
options 8821ce rtw_power_mgnt=0 rtw_enusbss=0 rtw_ips_mode=0
```

> Die Optionen deaktivieren verschiedene Energiesparfunktionen des Treibers. Dadurch kann insbesondere bei problematischen Realtek-WLAN-Adaptern eine stabilere Verbindung erreicht werden.

</details>

<details>
<summary>✨ Initramfs neu erstellen</summary>

> Nach Änderungen an den Kernel-Moduloptionen muss das System-Abbild neu erstellt werden, damit die Änderungen beim nächsten Systemstart berücksichtigt werden.

**Arch Linux mit GRUB:**

```bash
sudo mkinitcpio -P
```

**Arch Linux mit Limine:**

```bash
sudo limine-mkinitcpio
```

> Bei anderen Distributionen beziehungsweise Bootloader-Konfigurationen kann ein anderes Werkzeug zum Erstellen des Initramfs verwendet werden.

Anschließend das System neu starten:

```bash
reboot
```

</details>

<details>
<summary>✨ WLAN-Powersaving überprüfen</summary>

> Mit `iw` kann überprüft werden, ob die Energieverwaltung des WLAN-Adapters aktiviert ist:

```bash
iw dev wlan0 get power_save
```

> Falls `Power save: on` angezeigt wird, kann die WLAN-Energieverwaltung testweise deaktiviert werden:

```bash
sudo iw dev wlan0 set power_save off
```

</details>

<details>
<summary>✨ WLAN-Powersaving dauerhaft deaktivieren</summary>

> Damit NetworkManager die WLAN-Energieverwaltung nicht bei jeder Verbindung erneut aktiviert, kann eine eigene Konfigurationsdatei erstellt werden:

```bash
sudo nvim /etc/NetworkManager/conf.d/wifi-powersave.conf
```

Folgenden Inhalt eintragen:

```ini
[connection]
wifi.powersave = 2
```

> Der Wert `2` deaktiviert die WLAN-Energiesparfunktion in NetworkManager.

Danach NetworkManager neu starten:

```bash
sudo systemctl restart NetworkManager
```

Einstellung überprüfen:

```bash
iw dev wlan0 get power_save
```

Erwartete Ausgabe:

```text
Power save: off
```

</details>

<details>
<summary>✨ Alternativen Realtek-WLAN-Treiber ausprobieren</summary>

> Falls die WLAN-Probleme weiterhin bestehen, kann bei bestimmten Realtek-Adaptern ein alternativer, DKMS-basierter Treiber ausprobiert werden.
>
> Für die Erstellung von Kernel-Modulen werden zunächst die passenden Kernel-Header benötigt.

Für den CachyOS-Kernel:

```bash
sudo pacman -S linux-cachyos-headers
```

> Anschließend kann der alternative `rtw88`-Treiber aus dem AUR installiert werden:

```bash
yay -S rtw88-dkms-git
```

> Der DKMS-Treiber wird für den aktuell verwendeten Kernel gebaut und kann eine Alternative zum im Kernel enthaltenen Realtek-Treiber darstellen, wenn dieser mit der verwendeten WLAN-Hardware Probleme verursacht.

</details>

# ✨ Firefox ist langsam

> Ist nicht notwenig bei modernen Linux OS.
Firefox nutzt unter Linux nicht immer automatisch deine Grafikkarte. So schaltest du sie manuell ein:
- Gib `about:config` in die Adresszeile ein und bestätige die Warnung.
- Suche nach der Einstellung: `layers.acceleration.force-enabled`
- Klicke doppelt darauf, um den Wert auf `true` zu setzen.

> Diese Einstellung sorgt dafür, dass Firefox die SSD nicht mehr beansprucht und stattdessen alle temporären Daten direkt im blitzschnellen Arbeitsspeicher (RAM) ablegt.
Nur RAM-Cache nutzen (Einfachste Methode):
Dies kann durch das Ändern der internen Einstellungen im Firefox erfolgen.
- Öffne `about:config`.
- Suche nach der Einstellung `browser.cache.disk.enable`.
- Klicke doppelt darauf, um den Wert auf `false` zu setzen.

# ✨ Librewulf Google securtiy

> Um die Sicherheit deines Browsers zu erhöhen, kannst du die integrierte Google-Sicherheit in Librewolf aktivieren.

```bash
mkdir -p ~/.librewolf && printf 'defaultPref("browser.safebrowsing.malware.enabled", true);\ndefaultPref("browser.safebrowsing.phishing.enabled", true);\ndefaultPref("browser.safebrowsing.blockedURIs.enabled", true);\n' >> ~/.librewolf/librewolf.overrides.cfg
```

# ✨ Haskell-Pakete reparieren

> Falls Haskell-Pakete oder darauf basierende Anwendungen nach einem Systemupdate nicht mehr korrekt funktionieren, sollte zunächst das System vollständig aktualisiert und die Paketdatenbank auf einen aktuellen Stand gebracht werden.
>
> Die folgenden Schritte aktualisieren die Mirror-Liste, führen ein vollständiges Systemupdate durch, entfernen nicht mehr benötigte Abhängigkeiten und installieren wichtige Werkzeuge anschließend erneut.

<details>
<summary>✨ Haskell-Umgebung reparieren</summary>

> **1. Mirror-Liste aktualisieren**
>
> Mit `cachyos-rate-mirrors` werden die verfügbaren CachyOS-Mirrors überprüft und eine schnelle Mirror-Liste erstellt.

```bash
sudo cachyos-rate-mirrors
```

> **2. System vollständig aktualisieren**
>
> Anschließend wird das gesamte System inklusive aller installierten Haskell-Pakete aktualisiert.

```bash
sudo pacman -Syu
```

> **3. Nicht mehr benötigte Abhängigkeiten entfernen**
>
> Verwaiste Pakete können entfernt werden, wenn sie nicht mehr von anderen installierten Paketen benötigt werden.

```bash
sudo pacman -Rns $(pacman -Qdtq)
```

> **4. Benötigte Werkzeuge erneut installieren**
>
> Falls `ShellCheck` oder `Pandoc` weiterhin Probleme verursachen, können die Pakete erneut installiert und gleichzeitig als ausdrücklich installierte Pakete markiert werden.

```bash
sudo pacman -S --asexplicit shellcheck pandoc
```

</details>

> **Hinweis:** Die frühere Methode, sämtliche installierten Haskell-Pakete mit einem Befehl wie `pacman -S $(pacman -Qq | grep '^haskell-')` erneut zu installieren, ist nicht empfehlenswert. Dadurch werden unter Umständen unnötige Pakete erneut installiert und bestehende Abhängigkeitsprobleme nicht zuverlässig behoben.
>
> Ein vollständiges Systemupdate mit `pacman -Syu` ist unter Arch Linux grundsätzlich der bessere erste Schritt, um eine konsistente Paketbasis wiederherzustellen.

# ✨ Cloudflare WARP („1.1.1.1“) installieren und einrichten

> **Cloudflare WARP** ist ein VPN-ähnlicher Dienst von Cloudflare, der den Internetverkehr über das Cloudflare-Netzwerk leitet. WARP kann unter anderem die Verbindung absichern und DNS-Anfragen über Cloudflare abwickeln.
>
> Unter Arch Linux kann WARP über das AUR installiert und anschließend als Systemdienst aktiviert werden.

<details>
<summary>✨ Cloudflare WARP installieren</summary>

> Das Paket `cloudflare-warp-bin` enthält die aktuelle Binärversion von Cloudflare WARP.

```bash
sudo pacman -S cloudflare-warp-bin
# yay -S cloudflare-warp-bin
```

> Für Systeme ohne grafische Benutzeroberfläche beziehungsweise Server steht alternativ `cloudflare-warp-nox-bin` zur Verfügung. Diese Variante enthält keine grafische Taskleisten-Anwendung.

```bash
yay -S cloudflare-warp-nox-bin
```

</details>

<details>
<summary>✨ WARP-Dienst aktivieren</summary>

> Nach der Installation wird der WARP-Dienst aktiviert und direkt gestartet.

```bash
sudo systemctl enable --now warp-svc
```

</details>

<details>
<summary>✨ WARP registrieren</summary>

> Bevor WARP verwendet werden kann, muss das Gerät zunächst registriert werden.

```bash
# bashwarp-cli register
# warp-cli register
warp-cli registration new
```

</details>

<details>
<summary>✨ WARP aktivieren</summary>

> Nach der Registrierung kann die WARP-Verbindung hergestellt werden.

```bash
# bashwarp-cli connect
warp-cli connect
```

</details>

<details>
<summary>✨ WARP-Status und Einstellungen überprüfen</summary>

> Mit den folgenden Befehlen können der aktuelle Verbindungsstatus und die WARP-Einstellungen überprüft werden.

```bash
warp-cli status
```

```bash
warp-cli settings
```

> Falls WARP zwar aktiviert wurde, aber noch keine Verbindung besteht, kann zusätzlich der Verbindungsaufbau überprüft werden:

```bash
warp-cli connectivity-check
```

</details>

<details>
<summary>✨ WARP-DNS und Family-Filter konfigurieren</summary>

> WARP kann auch zur Verwendung der Cloudflare-DNS-Filter konfiguriert werden. Mit `families malware` werden DNS-Anfragen für bekannte Malware-Domains blockiert.

```bash
warp-cli dns families malware
```

</details>

<details>
<summary>✨ WARP bei Verbindungsproblemen neu registrieren</summary>

> Falls WARP nicht korrekt funktioniert, kann die Registrierung zurückgesetzt und anschließend eine neue Verbindung hergestellt werden.

```bash
warp-cli registration new
warp-cli connect
warp-cli status
```

> **Hinweis:** Nach dem Aktivieren kann es einen kurzen Moment dauern, bis WARP den verschlüsselten Tunnel aufgebaut hat. Falls unmittelbar nach `warp-cli connect` noch keine aktive Verbindung angezeigt wird, sollte zunächst kurz gewartet und anschließend der Status erneut überprüft werden.

</details>

### ✨ Wichtige WARP-Befehle

```bash
warp-cli connect        # WARP aktivieren
warp-cli disconnect     # WARP deaktivieren
warp-cli status         # Verbindungsstatus anzeigen
warp-cli settings       # Einstellungen anzeigen
warp-cli connectivity-check  # Verbindung überprüfen
```

# ✨ Tailscale installieren und einrichten

> **Tailscale** ist ein VPN auf Basis von **WireGuard**, das Geräte über ein privates Netzwerk miteinander verbindet. Dadurch können beispielsweise Linux-PCs, Server, Smartphones oder andere Geräte sicher miteinander kommunizieren, auch wenn sie sich in unterschiedlichen Netzwerken befinden.
>
> Nach der Installation wird der Tailscale-Dienst aktiviert und das Gerät mit dem Tailscale-Netzwerk verbunden.

<details>
<summary>✨ Tailscale installieren</summary>

```bash
sudo pacman -S tailscale
```

> Anschließend wird der Tailscale-Dienst aktiviert und direkt gestartet:

```bash
sudo systemctl enable --now tailscaled
```

</details>

<details>
<summary>✨ Gerät mit Tailscale verbinden</summary>

> Mit `tailscale up` wird das Gerät mit dem eigenen Tailscale-Netzwerk verbunden. Je nach Konfiguration wird anschließend eine Anmeldung über den Webbrowser benötigt.

```bash
sudo tailscale up
```

> Alternativ kann ein Authentifizierungsschlüssel verwendet werden:

```bash
sudo tailscale up --authkey [key]
```

> Der Authentifizierungsschlüssel sollte nicht öffentlich geteilt oder in Konfigurationsdateien gespeichert werden, die für andere Benutzer zugänglich sind.

</details>

<details>
<summary>✨ Tailscale-Verbindung überprüfen</summary>

> Mit `tailscale ip` kann die Tailscale-IP-Adresse des Geräts angezeigt werden:

```bash
tailscale ip
```

> Den aktuellen Verbindungsstatus und die im Tailscale-Netzwerk erreichbaren Geräte kann man mit folgendem Befehl anzeigen:

```bash
tailscale status
```

</details>

<details>
<summary>✨ Verbindung zwischen zwei Geräten testen</summary>

> Jedes Tailscale-Gerät erhält eine private IP-Adresse aus dem Tailscale-Netzwerk. Diese beginnt normalerweise mit `100.`.
>
> Von einem anderen Gerät kann die Verbindung beispielsweise mit `ping` getestet werden:

```bash
ping 100.x.x.x
```

> Dabei muss `100.x.x.x` durch die tatsächliche Tailscale-IP-Adresse des Zielgeräts ersetzt werden.

</details>

<details>
<summary>✨ Tailscale mit UFW erlauben</summary>

> Falls **UFW** den Datenverkehr über das Tailscale-Interface blockiert, kann die Kommunikation über `tailscale0` explizit erlaubt werden.

Eingehenden Datenverkehr erlauben:

```bash
sudo ufw allow in on tailscale0
```

Ausgehenden Datenverkehr erlauben:

```bash
sudo ufw allow out on tailscale0
```

> Anschließend kann die Verbindung erneut mit `tailscale status` oder `ping` überprüft werden.

</details>

### ✨ Wichtige Tailscale-Befehle

```bash
tailscale ip       # Tailscale-IP anzeigen
tailscale status   # Verbindungsstatus anzeigen
tailscale up       # Tailscale aktivieren
tailscale down     # Tailscale deaktivieren
```

# ✨ ZRAM konfigurieren

> **ZRAM** erstellt ein komprimiertes Swap-Gerät im Arbeitsspeicher. Dadurch können Speicherseiten komprimiert im RAM abgelegt werden, bevor das System auf langsameren Speicher auslagern muss.
>
> Die Größe von ZRAM sollte an die Menge des vorhandenen Arbeitsspeichers angepasst werden. Als sinnvoller Ausgangspunkt kann eine ZRAM-Größe von **100 % des verfügbaren RAMs** verwendet werden.
>
> Für ein System mit **32 GB RAM** wird in dieser Anleitung eine ZRAM-Größe von **32 GiB** verwendet.

| Arbeitsspeicher |    ZRAM-Größe |
| --------------: | ------------: |
|           16 GB |     16384 MiB |
|       **32 GB** | **32768 MiB** |
|           64 GB |     65536 MiB |

<details>
<summary>✨ ZRAM für 32 GB RAM konfigurieren</summary>

> Zunächst wird die Konfigurationsdatei des `zram-generator` geöffnet:

```bash
sudo nvim /etc/systemd/zram-generator.conf
```

Für ein System mit **32 GB RAM** folgenden Inhalt eintragen:

```ini
[zram0]
zram-size = 32768
# compression-algorithm = zstd
```

> `zram-size = 32768` erstellt ein ZRAM-Gerät mit einer Größe von **32 GiB**.
>
> Der tatsächliche physische Speicherverbrauch fällt durch die Kompression abhängig von den gespeicherten Daten geringer aus. Wie stark die Daten komprimiert werden können, hängt vom jeweiligen Inhalt ab.

</details>

<details>
<summary>✨ ZRAM-Größe für andere RAM-Konfigurationen anpassen</summary>

> Falls das System nicht über 32 GB RAM verfügt, kann der Wert entsprechend angepasst werden.

**16 GB RAM:**

```ini
[zram0]
zram-size = 16384
```

**32 GB RAM:**

```ini
[zram0]
zram-size = 32768
```

**64 GB RAM:**

```ini
[zram0]
zram-size = 65536
```

> Als allgemeine Orientierung kann die ZRAM-Größe auf ungefähr **100 % des physischen RAMs** gesetzt werden.
>
> Eine deutlich größere ZRAM-Größe ist zwar technisch möglich, aber nicht automatisch besser. Sehr große ZRAM-Geräte können bei starkem Speicherdruck zusätzlichen CPU-Aufwand durch Kompression und Dekompression verursachen.

</details>

<details>
<summary>✨ ZRAM-Dienst neu starten</summary>

> Nach der Änderung der Konfiguration wird die systemd-Konfiguration neu geladen und das ZRAM-Gerät neu gestartet.

```bash
sudo systemctl daemon-reload
sudo systemctl restart systemd-zram-setup@zram0.service
```

> Anschließend kann das System neu gestartet werden:

```bash
reboot
```

</details>

<details>
<summary>✨ ZRAM ohne Neustart neu einrichten</summary>

> Falls ausreichend freier Arbeitsspeicher vorhanden ist, kann das ZRAM-Gerät auch ohne vollständigen Neustart neu eingerichtet werden.

```bash
sudo swapoff /dev/zram0 2>/dev/null || true
sudo systemctl restart systemd-zram-setup@zram0.service
sudo swapon /dev/zram0
```

</details>

<details>
<summary>✨ ZRAM und Swap überprüfen</summary>

> Mit `zramctl` können Größe, Kompressionsalgorithmus und Zustand des ZRAM-Geräts überprüft werden:

```bash
zramctl
```

> Mit `swapon --show` lässt sich überprüfen, ob ZRAM vom System als Swap verwendet wird:

```bash
swapon --show
```

</details>

> **Hinweis:** Die ZRAM-Größe entspricht der maximalen Größe des komprimierten Swap-Geräts und nicht dem tatsächlich dafür reservierten physischen RAM. Der tatsächliche Speicherbedarf hängt vom Kompressionsverhältnis der ausgelagerten Daten ab.

# ✨ CachyOS optimieren

### ✨ UKSM (Ultra Kernel Samepage Merging) aktivieren

> **UKSM (Ultra Kernel Samepage Merging)** ist eine Speicheroptimierung, die identische Speicherseiten verschiedener Prozesse erkennt und zusammenführt. Dadurch kann der RAM-Verbrauch reduziert werden, insbesondere wenn mehrere Anwendungen ähnliche oder identische Speicherinhalte verwenden.
>
> CachyOS stellt hierfür das Paket `cachyos-ksm-settings` bereit, das die entsprechenden Einstellungen und den `uksmd`-Dienst zur Verfügung stellt.

<details>
<summary>✨ Prüfen, ob UKSM aktiv ist</summary>

> Mit `systemctl` kann überprüft werden, ob der `uksmd`-Dienst aktuell ausgeführt wird:

```bash
systemctl status uksmd
```

> Wird der Dienst als `active (running)` angezeigt, ist UKSM aktuell aktiv.

</details>

<details>
<summary>✨ UKSM installieren und aktivieren</summary>

> Falls UKSM noch nicht installiert oder aktiviert ist, kann das benötigte CachyOS-Paket installiert und der Dienst anschließend dauerhaft aktiviert werden:

```bash
sudo pacman -S cachyos-ksm-settings
sudo systemctl enable --now uksmd
```

> Durch `enable --now` wird der Dienst sofort gestartet und gleichzeitig so eingerichtet, dass er bei zukünftigen Systemstarts automatisch gestartet wird.

</details>

<details>
<summary>✨ UKSM deaktivieren</summary>

> Falls UKSM nicht mehr verwendet werden soll, kann der Dienst deaktiviert und gestoppt werden:

```bash
sudo systemctl disable --now uksmd
```

> Das Paket kann anschließend bei Bedarf entfernt werden:

```bash
sudo pacman -R cachyos-ksm-settings
```

</details>

# ✨ Remote Desktop Connection (Windows ↔ Linux)

> Mit **XRDP** kann eine klassische Remote-Desktop-Verbindung von Windows zu einem Linux-System eingerichtet werden. Windows kann sich anschließend über den integrierten Remotedesktop-Client mit dem Linux-PC verbinden.
>
> Für die grafische Sitzung werden zusätzlich `xorgxrdp` und ein funktionierender Xorg-Desktop benötigt.

<details>
<summary>✨ XRDP installieren und aktivieren</summary>

```bash
sudo pacman -S xrdp xorgxrdp
```

> Anschließend wird der XRDP-Dienst aktiviert und gestartet:

```bash
sudo systemctl enable --now xrdp
```

</details>

<details>
<summary>✨ RDP-Verbindung in der Firewall erlauben</summary>

> Der RDP-Dienst verwendet standardmäßig den TCP-Port `3389`. Wenn die Verbindung ausschließlich aus dem lokalen Netzwerk erfolgen soll, kann der Zugriff auf das eigene LAN beschränkt werden.

```bash
sudo ufw allow from 192.168.1.0/24 to any port 3389 proto tcp
```

> Das Netzwerk `192.168.1.0/24` muss gegebenenfalls an das eigene lokale Netzwerk angepasst werden.

</details>

<details>
<summary>✨ Fail2Ban installieren</summary>

> **Fail2Ban** kann verwendet werden, um wiederholte fehlgeschlagene Anmeldeversuche zu erkennen und entsprechende IP-Adressen temporär zu sperren.

```bash
sudo pacman -S fail2ban
sudo systemctl enable --now fail2ban
```

</details>

# ✨ Remote Desktop für Hyprland (Windows ↔ Linux)

> Für **Hyprland** eignet sich **Sunshine** zusammen mit **Moonlight** besser als eine klassische XRDP-Sitzung. Sunshine stellt den Linux-PC als Streaming-Host bereit, während Moonlight unter Windows als Client verwendet wird.
>
> Diese Lösung eignet sich besonders für eine flüssige Desktop-Steuerung mit geringer Latenz und kann neben dem Desktop auch für Spiele und andere grafisch anspruchsvolle Anwendungen verwendet werden.

## Linux (Hyprland)

### ✨ Sunshine installieren

> Sunshine ist der Streaming-Server, der den Bildschirminhalt des Linux-PCs an Moonlight überträgt.

```bash
sudo pacman -S sunshine fail2ban
```

### ✨ Sunshine als User-Service einrichten

> Damit Sunshine als Benutzerprozess ausgeführt werden kann, wird ein eigener systemd-User-Service erstellt.

```bash
mkdir -p ~/.config/systemd/user
nvim ~/.config/systemd/user/sunshine.service
```

Folgenden Inhalt eintragen:

```ini
[Unit]
Description=Sunshine Game Streaming Host
After=graphical-session.target

[Service]
ExecStart=/usr/bin/sunshine
Restart=on-failure

[Install]
WantedBy=default.target
```

### ✨ Sunshine starten

> Anschließend wird der neue User-Service von systemd eingelesen und aktiviert:

```bash
systemctl --user daemon-reload
systemctl --user enable --now sunshine.service
```

Status überprüfen:

```bash
systemctl --user status sunshine.service
```

> Falls Fail2Ban ebenfalls verwendet werden soll, kann der Dienst systemweit aktiviert werden:

```bash
sudo systemctl enable --now fail2ban
```

### ✨ Sunshine-Firewall für das lokale Netzwerk konfigurieren

> Sunshine benötigt mehrere TCP- und UDP-Ports für die Verbindung zwischen Host und Moonlight.
>
> Wenn Sunshine **nur im lokalen Netzwerk** erreichbar sein soll, können die Ports auf das eigene LAN beschränkt werden.

```bash
sudo ufw allow from 192.168.x.x to any port 47984:48010 proto tcp
sudo ufw allow from 192.168.x.x to any port 47998:48010 proto udp
```

> `192.168.x.x` muss durch das eigene Netzwerk beziehungsweise den gewünschten IP-Bereich ersetzt werden.

Die Regeln können bei Bedarf wieder entfernt werden:

```bash
sudo ufw delete allow from 192.168.x.x to any port 47984:48010 proto tcp
sudo ufw delete allow from 192.168.x.x to any port 47998:48010 proto udp
```

### ✨ Sunshine-Weboberfläche öffnen

> Die Konfiguration von Sunshine kann über die integrierte Weboberfläche vorgenommen werden.

```text
https://localhost:47990
```

> Dort können unter anderem Audio-, Video-, Eingabe- und Streaming-Einstellungen angepasst werden.

### ✨ Audio- und Monitorprobleme beheben

> Falls Sunshine keinen korrekten Monitor oder keine passende Audioausgabe verwendet, können die Einstellungen unter **Configuration → Audio/Video** überprüft werden.
>
> Bei Problemen mit mehreren Monitoren kann insbesondere der **Monitor Index** angepasst werden.
>
> Je nach System kann beispielsweise ein Audio-Gerät wie folgendes verwendet werden:

```text
alsa_output.pci-0000_e5_00.1.hdmi-stereo
```

> Die tatsächliche Bezeichnung des Audio-Geräts kann auf jedem System unterschiedlich sein.

Falls Sunshine nach Änderungen nicht korrekt funktioniert, kann der Dienst neu gestartet werden:

```bash
systemctl --user stop sunshine
sleep 2
systemctl --user start sunshine
```

### ✨ Cursor-Probleme unter Hyprland beheben

> Bei Sunshine kann es unter Hyprland in bestimmten Konfigurationen zu Problemen mit dem Cursor beziehungsweise mit Hardware-Cursors kommen.
>
> Insbesondere bei angepassten Hyprland-Konfigurationen wie **end-4** kann es sinnvoll sein, Hardware-Cursors zu deaktivieren.

In der Hyprland-Konfiguration kann beispielsweise Folgendes verwendet werden:

```ini
cursor {
    no_hardware_cursors = true
    inactive_timeout = 0
    zoom_factor = 1
    zoom_rigid = false
    zoom_disable_aa = true
    hotspot_padding = 1
}
```

> Nach Änderungen an der Hyprland-Konfiguration muss Hyprland gegebenenfalls neu geladen oder neu gestartet werden.

## Windows

### ✨ Moonlight installieren

> **Moonlight** ist der Client für Sunshine. Die Anwendung kann unter Windows installiert und anschließend zur Verbindung mit dem Linux-PC verwendet werden.

[Moonlight – offizielle Website](https://moonlight-stream.org/?utm_source=chatgpt.com)

### ✨ Mit dem Linux-PC verbinden

> Nach dem Start von Moonlight wird der Linux-PC normalerweise automatisch im Netzwerk erkannt. Anschließend kann die Verbindung über einen Pairing-Code autorisiert werden.

```text
Moonlight öffnen → Linux-PC auswählen → Pairing-Code eingeben
```

> Nach erfolgreichem Pairing kann der Linux-Desktop über Moonlight gesteuert werden.

# ✨ OpenClaw installieren und einrichten

> **OpenClaw** ist eine Kommandozeilenanwendung, die über npm installiert und anschließend über einen Einrichtungsassistenten konfiguriert werden kann.
>
> Nach der Installation kann OpenClaw als Hintergrunddienst eingerichtet und anschließend beispielsweise mit **GitHub Copilot** als Authentifizierungsquelle verbunden werden.

<details>
<summary>✨ OpenClaw installieren</summary>

> OpenClaw wird über den Node.js-Paketmanager `npm` global installiert:

```bash
npm i -g openclaw@latest
```

> Mit `@latest` wird die aktuellste verfügbare Version installiert.

</details>

<details>
<summary>✨ OpenClaw einrichten und Daemon installieren</summary>

> Der Einrichtungsassistent führt durch die grundlegende Konfiguration und kann gleichzeitig den OpenClaw-Daemon installieren.

```bash
openclaw onboard --install-daemon
```

</details>

<details>
<summary>✨ GitHub Copilot als Authentifizierung einrichten</summary>

> Falls **GitHub Copilot** für die Authentifizierung beziehungsweise als Modellanbieter verwendet werden soll, kann die Anmeldung direkt über OpenClaw gestartet werden:

```bash
openclaw models auth login-github-copilot
```

> Anschließend den angezeigten Anweisungen folgen, um die GitHub-Anmeldung abzuschließen.

</details>

# ✨ Nach der Installation: System prüfen und absichern

> Nach der Einrichtung des Systems empfiehlt es sich, einmal das gesamte System zu aktualisieren, die Integrität der installierten Pakete zu überprüfen und nach fehlgeschlagenen Diensten oder ungewöhnlichen Netzwerkverbindungen zu suchen.
>
> Die folgenden Befehle bieten eine grundlegende Übersicht über den Zustand des Systems und können dabei helfen, Fehler oder unbekannte Dienste frühzeitig zu erkennen.

## 1. ✨ System aktualisieren und Fehler prüfen

> Zunächst sollte das System vollständig aktualisiert werden. Anschließend können die installierten Dateien der Pakete sowie fehlgeschlagene systemd-Dienste überprüft werden.

```bash
sudo pacman -Syu
```

Installierte Pakete auf fehlende oder beschädigte Dateien überprüfen:

```bash
sudo pacman -Qk
```

Fehlgeschlagene systemd-Dienste anzeigen:

```bash
systemctl --failed
```

## 2. ✨ Netzwerk- und Portanalyse

> Ein wichtiger Sicherheitscheck ist die Überprüfung der aktuell geöffneten beziehungsweise lauschenden Netzwerkports. Dadurch lässt sich erkennen, welche Dienste Verbindungen aus dem Netzwerk annehmen.

```bash
ss -tulpen
```

> Achte insbesondere auf Dienste, die du nicht kennst oder die auf `0.0.0.0` beziehungsweise `::` lauschen. Solche Dienste können grundsätzlich Verbindungen von mehreren beziehungsweise allen Netzwerkinterfaces annehmen.
>
> Ein offener Port bedeutet allerdings nicht automatisch, dass das System unsicher ist. Entscheidend ist, welcher Dienst dahinter läuft und ob der Zugriff durch die Firewall entsprechend eingeschränkt wird.

## 3. ✨ Paketdatenbank und Paketintegrität prüfen

### 3.1 Paketdateien überprüfen

> Mit `pacman -Qk` kann überprüft werden, ob bei installierten Paketen Dateien fehlen.

```bash
pacman -Qk
```

> Mit `pacman -Qkk` wird eine ausführlichere Integritätsprüfung durchgeführt, bei der zusätzlich Dateieigenschaften überprüft werden.

```bash
pacman -Qkk
```

Nur Pakete mit Auffälligkeiten anzeigen:

```bash
sudo pacman -Qkk | grep -v "0 altered files"
```

> Mit `pacman -Qm` können außerdem Pakete angezeigt werden, die nicht aus den offiziellen Arch-Repositories stammen, beispielsweise Pakete aus dem AUR.

```bash
pacman -Qm
```

### 3.2 ✨ Installierte Pakete und verdächtige Dateien untersuchen

> Das Pacman-Log kann verwendet werden, um kürzlich installierte, aktualisierte oder entfernte Pakete nachzuvollziehen.

```bash
grep installed /var/log/pacman.log | tail -100
```

> Bei AUR-Paketen können außerdem die im `yay`-Cache vorhandenen Dateien nach häufig in Installationsskripten verwendeten Befehlen durchsucht werden.

```bash
grep -RinE "curl|wget|base64|eval|bash -c|sh -c" ~/.cache/yay
```

> Das Ergebnis sollte nicht automatisch als Schadsoftware interpretiert werden. Befehle wie `curl`, `wget` oder `bash -c` können in legitimen Build- und Installationsskripten vollkommen normal sein. Unbekannte oder unerwartete Skripte sollten jedoch genauer überprüft werden.

### 3.3 ✨ Kürzlich installierte Pakete anzeigen

> Mit `expac` können Pakete nach ihrem Installationszeitpunkt sortiert angezeigt werden.

```bash
expac --timefmt='%Y-%m-%d %T' '%l %n' | sort -r | head -50
```

> Dadurch lassen sich insbesondere kürzlich installierte Pakete schnell überprüfen.

### 3.4 ✨ Laufende Dienste überprüfen

> Mit folgendem Befehl können alle aktuell laufenden systemd-Dienste angezeigt werden:

```bash
systemctl --type=service --state=running
```

> Prüfe insbesondere Dienste, die du nicht selbst installiert oder bewusst aktiviert hast.

## 4. ✨ Bei Fehlern Logs überprüfen

> Falls Anwendungen oder Systemdienste nicht korrekt funktionieren, können zunächst fehlgeschlagene Dienste und kritische Fehlermeldungen des aktuellen Systemstarts überprüft werden.

Fehlgeschlagene Dienste anzeigen:

```bash
sudo systemctl --failed
```

Kritische Fehlermeldungen des aktuellen Systemstarts anzeigen:

```bash
sudo journalctl -p 3 -xb
```

> `journalctl -p 3` zeigt Meldungen mit der Priorität **Error** beziehungsweise höher an. Dadurch lassen sich häufig relevante Fehler schneller finden, ohne das komplette System-Log durchsuchen zu müssen.

## 5. ✨ Bei beschädigten Paketen

> Falls bei der Paketintegritätsprüfung fehlende oder beschädigte Dateien festgestellt werden, kann das entsprechende Paket erneut installiert werden.

```bash
sudo pacman -S <paketname>
```

> Vor einer Neuinstallation sollte jedoch geprüft werden, ob tatsächlich ein beschädigtes Paket die Ursache des Problems ist. Bei systemweiten Fehlern ist es häufig sinnvoller, zunächst die Logs und Abhängigkeiten zu untersuchen.

# ✨ Arch Linux Security-Hardening

> Nach der Einrichtung eines Arch-Linux-Systems kann es sinnvoll sein, die installierten Fremdpakete, AUR-Buildskripte, Paketmanager-Protokolle und wichtige Entwicklungsverzeichnisse auf Auffälligkeiten zu überprüfen.
>
> Die folgenden Werkzeuge ersetzen keine vollständige Sicherheitsanalyse. Sie dienen hauptsächlich dazu, verdächtige Dateien, unbekannte Pakete, ungewöhnliche Installationsskripte und mögliche Fehlkonfigurationen frühzeitig zu erkennen.

## 1. ✨ AUR-Paketquellen auf verdächtige Befehle überprüfen

> Bei Paketen aus dem **Arch User Repository (AUR)** können die verwendeten `PKGBUILD`-Dateien vor der Installation eingesehen werden. Besonders interessant sind Befehle, die Dateien aus dem Internet herunterladen oder dynamisch Code ausführen.
>
> Die folgende Suche sucht beispielsweise nach `npm`, `curl`, `wget`, `bash -c`, `eval`, `base64`, `openssl`, `nc`, `socat` und ähnlichen Befehlen.

```bash id="5u4z7n"
grep -RinE \
'npm|node|curl.*\||wget.*\||bash -c|sh -c|eval|base64|openssl|nc |socat|python -c' \
~/.cache/yay/*/PKGBUILD
```

> Ein Treffer bedeutet **nicht automatisch Schadcode**. Viele dieser Befehle können in legitimen Buildskripten verwendet werden. Unbekannte oder unerwartete Downloads und Codeausführungen sollten jedoch genauer untersucht werden.

Installierte AUR- beziehungsweise Fremdpakete anzeigen:

```bash id="q8v3kc"
pacman -Qm
```

Nach `npm install` im `yay`-Cache suchen:

```bash id="k6f2wp"
grep -R "npm install" ~/.cache/yay 2>/dev/null
```

Nach der bekannten Zeichenfolge `atomic-lockfile` im temporären Verzeichnis suchen:

```bash id="j4r9mx"
grep -R "atomic-lockfile" /tmp 2>/dev/null
```

## 2. ✨ Nach der Malware-Signatur `atomic-lockfile` suchen

> Falls gezielt nach der bekannten Bezeichnung `atomic-lockfile` gesucht werden soll, können das Home-Verzeichnis, globale npm-Pakete sowie verschiedene Paket- und Build-Caches durchsucht werden.

```bash id="z2c7vh"
find ~ -iname "*atomic-lockfile*" 2>/dev/null
```

Globale npm-Pakete überprüfen:

```bash id="e7n4qs"
npm list -g 2>/dev/null | grep atomic-lockfile
```

Paket- und AUR-Caches durchsuchen:

```bash id="s5m8dx"
grep -R "atomic-lockfile" /var/cache 2>/dev/null
grep -R "atomic-lockfile" ~/.cache/yay 2>/dev/null
```

> Wird die Zeichenfolge gefunden, sollte die betreffende Datei beziehungsweise das Paket genauer untersucht werden. Eine einzelne Übereinstimmung ist noch kein Beweis dafür, dass das System kompromittiert wurde.

## 3. ✨ Fremdpakete und Paketmanager-Historie überprüfen

> Mit `pacman -Qm` beziehungsweise `yay -Qm` können Pakete angezeigt werden, die nicht aus den offiziellen Arch-Repositories stammen.
>
> Das ist besonders nützlich, wenn überprüft werden soll, welche AUR- oder anderen Fremdpakete auf dem System installiert sind.

```bash id="r3v7mp"
yay -Qm
```

AUR-Cache anzeigen:

```bash id="n9c4wk"
ls ~/.cache/yay
```

> Die Paketmanager-Historie befindet sich bei Arch Linux in `/var/log/pacman.log`. Dort können Installationen und Aktualisierungen nachvollzogen werden.

Beispielsweise die Einträge eines bestimmten Monats anzeigen:

```bash id="u6x1za"
grep "2026-06" /var/log/pacman.log | tail -100
```

Installierte und aktualisierte Pakete anzeigen:

```bash id="p8k5cf"
grep -E "installed|upgraded" /var/log/pacman.log | tail -200
```

## 4. ✨ Virenscan mit ClamAV durchführen

> **ClamAV** ist ein Open-Source-Virenscanner für Linux. Besonders bei der Entwicklung mit vielen Drittanbieterpaketen können gezielte Scans sinnvoll sein.
>
> Zunächst wird ClamAV installiert und die Virensignaturen aktualisiert:

```bash id="w2q6mv"
sudo pacman -S clamav
sudo freshclam
```

> Anschließend können wichtige Entwicklungs- und Konfigurationsverzeichnisse überprüft werden.

Neovim-Konfiguration und Cache:

```bash id="a7d3xr"
clamscan -r -i ~/.config/nvim ~/.local/share/nvim ~/.local/state/nvim ~/.cache/nvim
```

Entwicklungsumgebungen und heruntergeladene Pakete:

```bash id="c5m9qt"
clamscan -r -i ~/.cargo ~/.sdkman ~/.npm ~/.local/lib/python3*/site-packages ~/Downloads
```

AUR-Build-Cache:

```bash id="h8v4nb"
clamscan -r -i ~/.cache/yay
```

> `-r` führt einen rekursiven Scan durch und `-i` zeigt nur infizierte beziehungsweise verdächtige Dateien an.

## 5. ✨ Rootkits mit Rootkit Hunter überprüfen

> **Rootkit Hunter (rkhunter)** untersucht das System unter anderem auf bekannte Rootkits, verdächtige Dateien und ungewöhnliche Änderungen an Systemdateien.

```bash id="m3w7qp"
sudo pacman -S rkhunter
```

Signaturen und Daten aktualisieren:

```bash id="x6k2vd"
sudo rkhunter --update
```

> **Wichtig:** `--propupd` sollte nicht blind als erster Schritt ausgeführt werden. Dieser Befehl aktualisiert die gespeicherte Referenzdatenbank der Dateieigenschaften. Wenn sich bereits manipulierte Dateien auf dem System befinden, könnten diese dadurch als neuer Ausgangszustand übernommen werden.
>
> Nach einer bewussten Überprüfung beziehungsweise bei einem vertrauenswürdigen Ausgangszustand kann die Referenzdatenbank aktualisiert werden:

```bash
sudo rkhunter --propupd
```

System überprüfen:

```bash id="q9c5xr"
sudo rkhunter --check
```

## 6. ✨ Zusätzliche Rootkit-Prüfung mit chkrootkit

> **chkrootkit** ist ein weiteres Werkzeug zur Erkennung bestimmter bekannter Rootkits und verdächtiger Systemzustände.
>
> Falls das Paket aus einer geeigneten Paketquelle verfügbar ist, kann es installiert und anschließend als Root ausgeführt werden.

```bash id="v4m8zs"
yay -S chkrootkit
sudo chkrootkit
```

## 7. ✨ System mit Lynis überprüfen

> **Lynis** führt ein umfassendes Sicherheits-Audit des Linux-Systems durch. Dabei werden unter anderem Systemkonfiguration, Berechtigungen, Dienste, Netzwerkoptionen und verschiedene Sicherheitsmechanismen überprüft.

```bash id="b7n3kw"
sudo pacman -S lynis
```

System-Audit starten:

```bash id="d5q9mc"
sudo lynis audit system
```

> Nach dem Scan zeigt Lynis Empfehlungen und mögliche Sicherheitsverbesserungen an. Die Ergebnisse sollten einzeln geprüft werden, bevor Änderungen am System vorgenommen werden.

## ✨ AppArmor sauber aktivieren

> **AppArmor** ist ein Mandatory-Access-Control-System (MAC), das Anwendungen anhand von Sicherheitsprofilen auf bestimmte Dateien, Verzeichnisse und Systemressourcen beschränkt.
>
> Unter CachyOS beziehungsweise Arch Linux kann AppArmor zusätzlich zur normalen Linux-Berechtigungsverwaltung eingesetzt werden.

<details>
<summary>✨ AppArmor installieren und aktivieren</summary>

```bash
sudo pacman -S apparmor apparmor.d
```

> Anschließend wird der AppArmor-Dienst aktiviert und direkt gestartet:

```bash
sudo systemctl enable --now apparmor
```

</details>

<details>
<summary>✨ AppArmor im Kernel aktivieren</summary>

> Damit AppArmor bereits beim Systemstart als Linux Security Module (LSM) geladen wird, muss es in der Kernel-Kommandozeile aktiviert werden.
>
> Bei einem System mit **Limine** wird dazu die Limine-Konfiguration geöffnet:

```bash
sudo nvim /boot/limine.conf
```

> In der entsprechenden `cmdline`-Zeile wird `apparmor` zur LSM-Liste hinzugefügt:

```ini
lsm=landlock,lockdown,yama,integrity,apparmor,bpf
```

> Beispiel:

```ini
# CachyOS Limine theme

...

/+CachyOS
  //linux-cachyos

  ...

  cmdline: quiet nowatchdog splash rw rootflags=subvol=/@ ... lsm=landlock,lockdown,yama,integrity,apparmor,bpf

```

> Die vorhandenen Kernel-Parameter sollten dabei **nicht ersetzt**, sondern lediglich um die benötigte LSM-Konfiguration ergänzt werden.

</details>

<details>
<summary>✨ AppArmor-Profil-Caching aktivieren</summary>

> AppArmor kann seine kompilierten Profile zwischenspeichern. Dadurch kann der Start von AppArmor beschleunigt werden, insbesondere wenn viele Profile geladen werden.

Konfigurationsdatei öffnen:

```bash
sudo nvim /etc/apparmor/parser.conf
```

Folgende Einstellungen eintragen:

```ini
write-cache
Optimize=compress-fast
cache-loc /etc/apparmor/earlypolicy/
```

> Das Caching reduziert den Aufwand, AppArmor-Profile bei jedem Systemstart erneut zu verarbeiten. Die genaue Cache-Konfiguration kann je nach verwendeter AppArmor-Version und Distribution variieren. Der Standard-Cache von AppArmor liegt bei aktuellen Versionen unter `/var/cache/apparmor`.

</details>

<details>
<summary>✨ AppArmor überprüfen</summary>

> Nach der Konfiguration wird das System neu gestartet:

```bash
sudo reboot
```

> Nach dem Neustart kann überprüft werden, ob AppArmor aktiv ist:

```bash
sudo aa-status
```

> Zusätzlich kann überprüft werden, ob der AppArmor-Dienst erfolgreich gestartet wurde:

```bash
systemctl status apparmor
```

</details>

## ✨ Globales Menü aktivieren

> Für Anwendungen, die das **AppMenu-/DBusMenu-System** verwenden, können die entsprechenden GTK- und D-Bus-Komponenten installiert werden.

```bash
sudo pacman -S appmenu-gtk-module libdbusmenu-glib
```

## ✨ SSH-Server deaktivieren

> Wenn auf dem Rechner kein SSH-Zugriff benötigt wird, sollte der SSH-Server deaktiviert werden. Dadurch wird verhindert, dass der Dienst unnötig einen Netzwerkport für eingehende SSH-Verbindungen bereitstellt.

```bash
sudo systemctl disable --now sshd
```

> Falls SSH später wieder benötigt wird, kann der Dienst erneut aktiviert und gestartet werden:

```bash
sudo systemctl enable --now sshd
```

# ✨ Arch Linux AUR auf Malware überprüfen

> Im Juni 2026 wurde eine große Supply-Chain-Kampagne gegen das **Arch User Repository (AUR)** bekannt. Dabei wurden zahlreiche AUR-Pakete kompromittiert und unter anderem Payloads über `npm`, `bun` und manipulierte Build- beziehungsweise Installationsskripte verteilt. Das von der Community gepflegte Projekt `aur-malware-check` dokumentiert die Kampagne und stellt automatisierte Prüfungen bereit.
>
> Das Tool wurde inzwischen zu einem kampagnenbasierten Scanner erweitert und kann neben der ursprünglichen `atomic-lockfile`-Kampagne auch weitere bekannte Kampagnen berücksichtigen.

## ✨ AUR-Malware-Check installieren

> Das Projekt ist Python-basiert und benötigt laut Projektbeschreibung Python 3.14 oder neuer sowie keine zusätzlichen Python-Abhängigkeiten.

Repository klonen:

```bash
git clone https://github.com/lenucksi/aur-malware-check.git
cd aur-malware-check
```

> Das Repository sollte vor der Ausführung auf den aktuellen Stand gebracht werden:

```bash
git pull
```

## ✨ Risikofreien Testlauf durchführen

> Zunächst kann ein Testlauf durchgeführt werden, bei dem die aktuellen Kampagneninformationen aktualisiert und die geplanten Prüfungen angezeigt werden, ohne Änderungen am System vorzunehmen:

```bash
python -m aur_check --refresh-campaigns --dry-run
```

> Dadurch kann zunächst überprüft werden, welche Kampagnen beziehungsweise Datenquellen verwendet werden.

## ✨ Vollständigen Malware-Scan durchführen

> Für eine umfassendere Untersuchung kann anschließend der vollständige Scan ausgeführt werden:

```bash
sudo python -m aur_check --refresh --full
```

> Der vollständige Scan kann unter anderem installierte Pakete, Pacman-Logs, systemd-Dienste sowie verschiedene Entwicklungs- und Paketmanager-Caches untersuchen. Die genauen Prüfungen hängen von der aktuellen Version des Projekts und den aktivierten Kampagnen ab.

> **Wichtig:** Ein Ergebnis wie `CLEAN` bedeutet, dass bei den durchgeführten Prüfungen keine bekannten beziehungsweise vom Scanner erfassten Indikatoren gefunden wurden. Es ist **keine Garantie dafür, dass das System vollständig frei von Schadsoftware ist**.

## ✨ Bei einem positiven Malware-Befund

> Falls der Scanner einen ernsthaften Treffer meldet, sollte das System zunächst als potenziell kompromittiert betrachtet werden.
>
> Besonders wenn Zugangsdaten, SSH-Schlüssel, Browserdaten oder Entwickler-Credentials auf dem System vorhanden waren, sollten diese **von einem vertrauenswürdigen Gerät aus** geändert beziehungsweise widerrufen werden.
>
> Bei einem begründeten Verdacht auf eine vollständige Systemkompromittierung ist eine Neuinstallation aus einem vertrauenswürdigen Installationsmedium in der Regel zuverlässiger als der Versuch, sämtliche Schadsoftware manuell zu entfernen.

> **Tipp:** AUR-Pakete sollten grundsätzlich vor der Installation überprüft werden. Besonders bei unbekannten, neuen oder verwaisten Paketen lohnt sich ein Blick auf das `PKGBUILD` und die Änderungen, bevor `yay` oder ein anderer AUR-Helper das Paket baut.

# Use JK-Arch
