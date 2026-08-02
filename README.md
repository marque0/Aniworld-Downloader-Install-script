# AniWorld-Downloader Auto-Setup

Dieses Skript richtet [AniWorld-Downloader](https://github.com/phoenixthrush/AniWorld-Downloader) vollautomatisch auf Linux, macOS oder WSL ein.

## Voraussetzungen

- **Linux/macOS/WSL** (kein Windows direkt, aber WSL geht)
- Internetverbindung
- Für **Docker-Modus**: `curl` und `sudo`-Rechte
- Für **Native-Modus**: Python 3.10+ (wird ggf. automatisch installiert)

## Schnellstart

### 1. Skript herunterladen

```bash
curl -fsSL https://dein-link-zum-script.sh -o aniworld-setup.sh
chmod +x aniworld-setup.sh
```

Oder einfach die Datei `aniworld-setup.sh` in einen Ordner legen.

### 2. Skript ausführen

```bash
./aniworld-setup.sh
```

### 3. Installationsmodus wählen

Das Skript fragt interaktiv, wie du installieren möchtest:

| Modus | Empfohlen für | Beschreibung |
|-------|---------------|--------------|
| **1) Docker Compose** | Server, NAS, dauerhaft laufend | Web UI sofort unter `http://localhost:8080` verfügbar |
| **2) Native Python** | Desktop/Laptop | `aniworld` im Terminal oder `aniworld -w` für Web UI |
| **3) Beides** | – | Beide Varianten parallel installieren |

### 4. Fertig!

- **Docker**: `~/aniworld-docker/start.sh` und `~/aniworld-docker/stop.sh`
- **Native**: Einfach `aniworld` oder `aniworld -w` eingeben

## Nützliche Befehle

```bash
# Terminal-Menu starten
aniworld

# Web UI starten (nur Native)
aniworld -w

# Direkter Download (nur Native)
aniworld --no-menu "https://aniworld.to/anime/..."

# Docker: Container stoppen
cd ~/aniworld-docker && docker compose down

# Docker: Container updaten
cd ~/aniworld-docker && docker compose pull && docker compose up -d
```

## Automatisch ohne interaktive Abfrage

```bash
# Nur Docker
./aniworld-setup.sh --docker

# Nur Native
./aniworld-setup.sh --native

# Beides
./aniworld-setup.sh --both
```

## Was installiert das Skript?

- `ffmpeg` (für Downloads)
- `git` und `curl`
- Python 3 + pip (falls noch nicht vorhanden)
- **Docker Compose** Setup in `~/aniworld-docker/`
- **ODER** das `aniworld` Python-Paket via pip

## Support

Bei Problemen:
- [Dokumentation](https://www.phoenixthrush.com/AniWorld-Downloader-Docs/)
- [GitHub Issues](https://github.com/phoenixthrush/AniWorld-Downloader/issues)
- [Discord](https://discord.gg/BfDvrKd8V5)
