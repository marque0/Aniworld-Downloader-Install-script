# AniWorld-Downloader Auto-Setup

Dieses Repository enthaelt Setup-Skripte fuer [AniWorld-Downloader](https://github.com/phoenixthrush/AniWorld-Downloader).

---

## Windows

Die Windows-Installation laeuft ueber **Docker Desktop + WSL2**.

### 1. PowerShell als Administrator oeffnen

Rechtsklick auf Start-Button → **Terminal (Administrator)** oder **PowerShell (Administrator)**.

### 2. Ausfuehrungsrichtlinie setzen (einmalig)

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
```

### 3. Skript herunterladen

```powershell
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/marque0/Aniworld-Downloader-Install-script/main/aniworld-setup.ps1" -OutFile "aniworld-setup.ps1"
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/marque0/Aniworld-Downloader-Install-script/main/docker-setup.sh" -OutFile "docker-setup.sh"
```

Oder beide Dateien manuell herunterladen (muessen im selben Ordner liegen).

### 4. Ausfuehren

```powershell
.\aniworld-setup.ps1
```

Das Skript erledigt automatisch:
1. Docker Desktop installieren (falls fehlend)
2. Docker Desktop starten
3. WSL2 aktivieren (falls fehlend)
4. Ubuntu in WSL installieren (falls fehlend)
5. Docker Compose Setup via `docker-setup.sh` ausfuehren

Danach ist die Web UI unter `http://localhost:8080` erreichbar.

---

## Linux / macOS / WSL

### Docker Setup (empfohlen)

```bash
curl -fsSL https://raw.githubusercontent.com/marque0/Aniworld-Downloader-Install-script/main/docker-setup.sh -o docker-setup.sh
chmod +x docker-setup.sh
./docker-setup.sh
```

Oder fuer Native Python Installation:

```bash
curl -fsSL https://raw.githubusercontent.com/marque0/Aniworld-Downloader-Install-script/main/aniworld-setup.sh -o aniworld-setup.sh
chmod +x aniworld-setup.sh
./aniworld-setup.sh
```

---

## Dateien im Repository

| Datei | Zweck |
|-------|-------|
| `aniworld-setup.ps1` | Windows PowerShell: Docker Desktop + WSL2 + Docker Compose |
| `docker-setup.sh` | Docker Compose Setup (plattformübergreifend via Bash) |
| `aniworld-setup.sh` | Native Python Installation (Linux/macOS) |

---

## Nuetzliche Befehle

### Docker (Linux/macOS/WSL)

```bash
cd ~/aniworld-docker-setup && docker compose up -d    # Starten
cd ~/aniworld-docker-setup && docker compose down    # Stoppen
cd ~/aniworld-docker-setup && docker compose logs -f  # Logs ansehen
```

### Native (Linux/macOS)

```bash
aniworld              # Terminal-Menu
aniworld -w           # Web UI
aniworld --no-menu "https://aniworld.to/anime/..."   # Direkter Download
```

---

## Support

- [Offizielle Dokumentation](https://www.phoenixthrush.com/AniWorld-Downloader-Docs/)
- [GitHub Issues](https://github.com/phoenixthrush/AniWorld-Downloader/issues)
- [Discord](https://discord.gg/BfDvrKd8V5)
