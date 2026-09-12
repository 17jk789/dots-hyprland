# JK-ARCH Installer

# Vollständige JSON-Konfigurationsreferenz

## Inhaltsverzeichnis

- [JK-ARCH Installer](#jk-arch-installer)
- [Vollständige JSON-Konfigurationsreferenz](#vollständige-json-konfigurationsreferenz)
  - [Inhaltsverzeichnis](#inhaltsverzeichnis)
- [1. Grundprinzip](#1-grundprinzip)
- [2. installations.json](#2-installationsjson)
- [3. Das Feld "installations"](#3-das-feld-installations)
- [4. Minimaler Installationseintrag](#4-minimaler-installationseintrag)
- [5. Feld: id](#5-feld-id)
  - [Typ](#typ)
  - [Pflicht](#pflicht)
- [6. Feld: file](#6-feld-file)
  - [Typ](#typ-1)
  - [Pflicht](#pflicht-1)
- [7. Feld: variant](#7-feld-variant)
  - [Typ](#typ-2)
  - [Optional](#optional)
- [8. Feld: default\_selected](#8-feld-default_selected)
  - [Typ](#typ-3)
  - [Optional](#optional-1)
- [9. Feld: substeps](#9-feld-substeps)
  - [Typ](#typ-4)
  - [Optional](#optional-2)
- [10. Vollständiges installations.json Beispiel](#10-vollständiges-installationsjson-beispiel)
- [11. Aufbau einer Step-Datei](#11-aufbau-einer-step-datei)
- [12. Pflichtfelder einer Step-Datei](#12-pflichtfelder-einer-step-datei)
- [13. Mehrsprachige Texte](#13-mehrsprachige-texte)
- [14. Optionales Feld: optional](#14-optionales-feld-optional)
- [15. Optionales Feld: continue\_on\_error](#15-optionales-feld-continue_on_error)
- [16. Optionales Feld: exclusive\_group](#16-optionales-feld-exclusive_group)
- [17. commands Array](#17-commands-array)
- [18. Command Felder](#18-command-felder)
- [19. command](#19-command)
- [20. requires\_root](#20-requires_root)
- [21. distros](#21-distros)
- [22. checks](#22-checks)
- [23. Verfügbare Check-Typen](#23-verfügbare-check-typen)
  - [package\_installed](#package_installed)
  - [command\_exists](#command_exists)
  - [file\_exists](#file_exists)
  - [always](#always)
- [24. Komplettes professionelles Beispiel](#24-komplettes-professionelles-beispiel)

# 1. Grundprinzip

Der Installer verwendet zwei Ebenen:

```
installations.json
        |
        |
        v
steps/*.json
        |
        |
        v
commands
```

Also:

`installations.json`

sagt:

> Welche Installationen gibt es?

Die Step-Datei sagt:

> Was muss ausgeführt werden?

# 2. installations.json

Minimal:

```json
{
    "installations": []
}
```

Die Datei muss immer ein Objekt sein.

Erlaubt:

```json
{
    "installations": [
        
    ]
}
```

Nicht erlaubt:

```json
[
    {
        "id": "test"
    }
]
```

# 3. Das Feld "installations"

Typ:

```
Array
```

Pflicht:

Ja

Beispiel:

```json
{
    "installations": [
        {
            "id": "base",
            "file": "01_base.json"
        }
    ]
}
```

Jeder Eintrag entspricht einem Installationsschritt.

# 4. Minimaler Installationseintrag

Der kleinste gültige Eintrag:

```json
{
    "id": "base",
    "file": "01_base.json"
}
```

Bedeutung:

| Feld | Bedeutung                  |
| ---- | -------------------------- |
| id   | eindeutige interne ID      |
| file | JSON-Datei im steps-Ordner |

# 5. Feld: id

## Typ

String

## Pflicht

Ja

Beispiel:

```json
{
    "id": "neovim",
    "file": "20_neovim.json"
}
```

Die ID muss eindeutig sein.

Nicht:

```json
[
 {
   "id":"docker"
 },
 {
   "id":"docker"
 }
]
```

Fehler:

```
Duplicate installation id
```

# 6. Feld: file

## Typ

String

## Pflicht

Ja

Beispiel:

```json
{
    "file": "30_docker.json"
}
```

Die Datei muss existieren:

```
steps/
 └──30_docker.json
```

# 7. Feld: variant

## Typ

String

## Optional

Ja

Wählt eine Variante innerhalb einer Step-Datei.

Beispiel:

```json
{
    "id": "editor",
    "file": "editor.json",
    "variant": "neovim"
}
```

Dazu:

```
steps/editor.json
```

Datei:

```json
{
    "variants": {

        "neovim": {

        },

        "vscode": {

        }

    }
}
```

# 8. Feld: default_selected

## Typ

Boolean

## Optional

Ja

Standard:

```json
true
```

Beispiel:

```json
{
    "id": "gaming",
    "file": "gaming.json",
    "default_selected": false
}
```

Ergebnis:

Bei Auswahl:

```
[ ] gaming
```

statt:

```
[x] gaming
```

# 9. Feld: substeps

## Typ

Array

## Optional

Ja

Damit können mehrere Unterpunkte unter einem Hauptpunkt erzeugt werden.

Beispiel:

```json
{
    "id": "development",
    "file": "development.json",

    "substeps": [

        {
            "id": "python",
            "name": {
                "de": "Python",
                "en": "Python"
            }
        },

        {
            "id": "rust",
            "name": {
                "de": "Rust",
                "en": "Rust"
            }
        }

    ]
}
```

Anzeige:

```
01.1 Python
01.2 Rust
```

# 10. Vollständiges installations.json Beispiel

```json
{
    "installations": [

        {
            "id": "base",
            "file": "01_base.json",
            "default_selected": true
        },


        {
            "id": "terminal",
            "file": "10_terminal.json"
        },


        {
            "id": "development",
            "file": "20_development.json",

            "substeps": [

                {
                    "id": "python",
                    "variant": "python"
                },

                {
                    "id": "rust",
                    "variant": "rust"
                }

            ]
        }

    ]
}
```

# 11. Aufbau einer Step-Datei

Beispiel:

```
steps/10_terminal.json
```

Minimal:

```json
{
    "id": "terminal",

    "name": {
        "de": "Terminal Werkzeuge",
        "en": "Terminal tools"
    },

    "description": {
        "de": "Installiert wichtige CLI Programme",
        "en": "Installs important CLI programs"
    },

    "question": {
        "de": "Terminal installieren?",
        "en": "Install terminal tools?"
    },


    "commands": []

}
```

# 12. Pflichtfelder einer Step-Datei

| Feld        | Typ           | Pflicht |
| ----------- | ------------- | ------- |
| id          | String        | ja      |
| name        | String/Object | ja      |
| description | String/Object | ja      |
| question    | String/Object | ja      |
| commands    | Array         | ja      |

# 13. Mehrsprachige Texte

Alle Texte können so geschrieben werden:

```json
"name":
{
    "de":"Docker",
    "en":"Docker"
}
```

oder:

```json
"name":
"Docker Installation"
```

Beides funktioniert.

# 14. Optionales Feld: optional

Typ:

Boolean

Beispiel:

```json
{
    "optional": true
}
```

Bedeutung:

Der Schritt ist nicht zwingend.

# 15. Optionales Feld: continue_on_error

Typ:

Boolean

Beispiel:

```json
{
    "continue_on_error": true
}
```

Normal:

```
Fehler
 |
STOP
```

Mit:

```json
"continue_on_error":true
```

:

```
Fehler
 |
weiter
```

# 16. Optionales Feld: exclusive_group

Sehr wichtig.

Damit kann man Alternativen definieren.

Beispiel:

```json
{
    "id":"nvidia",

    "exclusive_group":"gpu_driver"
}
```

und:

```json
{
    "id":"amd",

    "exclusive_group":"gpu_driver"
}
```

Ergebnis:

Nur eines kann gewählt werden:

```
[x] Nvidia
[ ] AMD
```

Wenn Nvidia aktiviert wird:

```
[ ] Nvidia
[x] AMD
```

wird verhindert.

# 17. commands Array

Das Herzstück.

Beispiel:

```json
"commands":[

{
    "command":[
        "pacman",
        "-S",
        "--noconfirm",
        "git"
    ],

    "requires_root":true,

    "distros":[
        "arch_based"
    ]

}

]
```

# 18. Command Felder

| Feld              | Typ           | Pflicht  |
| ----------------- | ------------- | -------- |
| command           | Array String  | ja       |
| distros           | Array String  | ja       |
| requires_root     | Boolean       | optional |
| description       | String/Object | optional |
| working_directory | String        | optional |

# 19. command

Wichtig:

Es ist KEIN Shell-String.

Falsch:

```json
"command":
"pacman -S git"
```

Richtig:

```json
"command":
[
"pacman",
"-S",
"git"
]
```

Warum?

Sicherheit.

Keine Shell-Injection.

# 20. requires_root

Standard:

```json
true
```

Root:

```json
"requires_root":true
```

Benutzer:

```json
"requires_root":false
```

# 21. distros

Pflicht!

Beispiele:

Nur Arch:

```json
"distros":[
"arch"
]
```

Arch + CachyOS:

```json
"distros":[
"arch",
"cachyos"
]
```

Alle Arch-Systeme:

```json
"distros":[
"arch_based"
]
```

# 22. checks

Checks bestimmen:

"ist schon installiert?"

Beispiel:

```json
"checks":[

{
"type":"package_installed",
"package":"neovim"
}

]
```

# 23. Verfügbare Check-Typen

## package_installed

```json
{
"type":"package_installed",
"package":"docker"
}
```

prüft:

```
pacman -Q docker
```

## command_exists

```json
{
"type":"command_exists",
"command":"nvim"
}
```

## file_exists

```json
{
"type":"file_exists",
"path":"/etc/docker/daemon.json"
}
```

## always

```json
{
"type":"always"
}
```

Immer erfolgreich.

# 24. Komplettes professionelles Beispiel

Datei:

```
steps/docker.json
```

```json
{
    "id":"docker",

    "name":{
        "de":"Docker",
        "en":"Docker"
    },


    "description":{
        "de":"Installiert Docker und aktiviert den Dienst.",
        "en":"Installs Docker and enables the service."
    },


    "question":{
        "de":"Docker installieren?",
        "en":"Install Docker?"
    },


    "checks":[
        {
            "type":"package_installed",
            "package":"docker"
        }
    ],


    "optional":true,


    "commands":[


        {
            "command":[
                "pacman",
                "-S",
                "--noconfirm",
                "docker"
            ],

            "requires_root":true,

            "distros":[
                "arch_based"
            ]
        },


        {
            "command":[
                "systemctl",
                "enable",
                "--now",
                "docker"
            ],

            "requires_root":true,

            "distros":[
                "arch_based"
            ]
        }

    ]

}
```
