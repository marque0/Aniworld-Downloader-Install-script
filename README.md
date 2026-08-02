# AniWorld-Downloader Auto-Setup

Dieses Repository enthaelt Setup-Skripte fuer [AniWorld-Downloader](https://github.com/phoenixthrush/AniWorld-Downloader) – plattformuebergreifend fuer **Linux**, **macOS**, **WSL** und **Windows**.

## Was ist das?

AniWorld-Downloader ist ein Cross-Platform Tool zum Suchen, Streamen und Downloaden von Anime, Filmen, Serien und Manga. Dieses Repository macht die Installation vollautomatisch.

---

## Windows (PowerShell)

### 1. Skript herunterladen

```powershell
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/marque0/Aniworld-Downloader-Install-script/main/aniworld-setup.ps1" -OutFile "aniworld-setup.ps1"
```

Oder die `.ps1`-Datei manuell herunterladen.

### 2. Ausfuehren

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
.\aniworld-setup.ps1
```

> **Hinweis:** Falls `Set-ExecutionPolicy` nicht funktioniert, PowerShell als Administrator starten.

### 3. Modus waehlen

| Modus | Wann empfohlen |
|-------|----------------|
| **Docker** | Dauerhaft laufender Server/Web UI |
| **Native Python** | Desktop/Laptop Nutzung |
| **Beides** | Beide parallel |

### 4. Ohne interaktive Abfrage

```powershell
.\aniworld-setup.ps1 -Docker     # Nur Docker
.\aniworld-setup.ps1 -Native     # Nur Python
.\aniworld-setup.ps1 -Both        # Beides
```

---

## Linux / macOS / WSL (Bash)

### 1. Skript herunterladen

```bash
curl -fsSL https://raw.githubusercontent.com/marque0/Aniworld-Downloader-Install-script/main/aniworld-setup.sh -o aniworld-setup.sh
chmod +x aniworld-setup.sh
```

### 2. Ausfuehren

```bash
./aniworld-setup.sh
```

### 3. Ohne interaktive Abfrage

```bash
./aniworld-setup.sh --docker   # Nur Docker
./aniworld-setup.sh --native   # Nur Python
./aniworld-setup.sh --both     # Beides
```

---

## Nuetzliche Befehle

### Native (nach Installation)

```bash
# Terminal-Menu
aniworld

# Web UI starten
aniworld -w

# Direkter Download
aniworld --no-menu "https://aniworld.to/anime/..."

# Update
python -m pip install -U aniworld
```

### Docker

```bash
# Linux/macOS
cd ~/aniworld-docker && docker compose up -d

# Windows (PowerShell)
cd ~\aniworld-docker ; docker compose up -d
```

---

## Voraussetzungen

| Komponente | Windows | Linux/macOS |
|------------|---------|-------------|
| **Docker** | Docker Desktop | Docker Engine |
| **Python** | 3.10+ (Store/winget) | Meist vorinstalliert |
| **ffmpeg** | Automatisch via winget | Automatisch via Paketmanager |

---

## Support

- [Offizielle Dokumentation](https://www.phoenixthrush.com/AniWorld-Downloader-Docs/)
- [GitHub Issues](https://github.com/phoenixthrush/AniWorld-Downloader/issues)
- [Discord](https://discord.gg/BfDvrKd8V5)
