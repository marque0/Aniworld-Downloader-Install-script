# AniWorld-Downloader Auto-Setup

Dieses Repository enthaelt Setup-Skripte fuer [AniWorld-Downloader](https://github.com/phoenixthrush/AniWorld-Downloader).

---

## Windows

Die Windows-Installation laeuft ueber **Docker Desktop + WSL2**.

### Voraussetzungen

| Voraussetzung | Pruefung |
|---|---|
| Windows 10 (21H2+) oder Windows 11 | `Win + R` → `winver` |
| Virtualisierung im BIOS aktiv (Intel VT-x / AMD-V) | Task-Manager → Leistung → CPU → "Virtualisierung: Aktiviert" |
| WSL2 | `wsl --status` in PowerShell |
| 4 GB RAM, ~10 GB freier Speicher | |

### Option A: Automatisiert (empfohlen)

#### 1. PowerShell als Administrator oeffnen

Rechtsklick auf Start-Button → **Terminal (Administrator)** oder **PowerShell (Administrator)**.

#### 2. Ausfuehrungsrichtlinie setzen (einmalig)

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
```

#### 3. Skript herunterladen

```powershell
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/marque0/Aniworld-Downloader-Install-script/main/aniworld-setup.ps1" -OutFile "aniworld-setup.ps1"
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/marque0/Aniworld-Downloader-Install-script/main/docker-setup.sh" -OutFile "docker-setup.sh"
```

Oder beide Dateien manuell herunterladen (muessen im selben Ordner liegen).

#### 4. Ausfuehren

```powershell
.\aniworld-setup.ps1
```

Das Skript erledigt automatisch:
1. Docker Desktop installieren (falls fehlend, via winget)
2. Docker Desktop starten
3. WSL2 aktivieren (falls fehlend)
4. Ubuntu in WSL installieren (falls fehlend)
5. Docker Compose Setup via `docker-setup.sh` ausfuehren

Danach ist die Web UI unter `http://localhost:8080` erreichbar.

---

### Option B: Manuell Schritt fuer Schritt

Falls das Skript nicht klappt, fuehre die Schritte einzeln aus:

#### 1. Docker Desktop installieren

1. Download: **https://www.docker.com/products/docker-desktop/**
2. Installer ausfuehren, Standardoptionen beibehalten
3. Wichtig beim ersten Start: **WSL2 als Backend** waehlen (Einstellungen → Allgemein → "Use the WSL 2 based engine")
4. Docker Desktop starten und warten, bis das Wal-Symbol in der Taskleiste gruen ist

Alternative via winget (PowerShell als Admin):

```powershell
winget install Docker.DockerDesktop --accept-source-agreements --accept-package-agreements
```

#### 2. WSL2 aktivieren und Ubuntu installieren

```powershell
wsl --install -d Ubuntu
```

- Windows **neu starten**, wenn danach gefragt wird
- Beim ersten Start von Ubuntu einen Benutzernamen + Passwort vergeben
- WSL2 als Standard setzen:

```powershell
wsl --set-default-version 2
```

#### 3. Docker-Setup ausfuehren

In **Ubuntu (WSL)** oder **Git Bash**:

```bash
curl -fsSL https://raw.githubusercontent.com/marque0/Aniworld-Downloader-Install-script/main/docker-setup.sh -o docker-setup.sh
chmod +x docker-setup.sh
./docker-setup.sh
```

#### 4. Web UI oeffnen

Browser aufrufen: **http://localhost:8080**

---

### Docker Desktop: wichtige Einstellungen

| Einstellung | Wo | Warum |
|---|---|---|
| WSL2-Backend | Allgemein → "Use the WSL 2 based engine" | deutlich schneller als Hyper-V |
| Autostart | Allgemein → "Start Docker Desktop when you sign in" | Container starten direkt mit Windows |
| Ressourcen | Ressourcen → Erweitert | mind. 2 CPUs + 4 GB RAM fuer Docker |

### Troubleshooting Windows

- **`docker: command not found` in PowerShell** → Docker Desktop neu starten, ggf. PC neu booten
- **WSL2-Installationsfehler 0x80370102** → Virtualisierung im BIOS pruefen (VT-x/AMD-V)
- **Port 8080 bereits belegt** → in `docker-compose.yml` den Port aendern, z. B. `"8081:8080"`
- **Langsamer Start** → sicherstellen, dass das WSL2-Backend aktiv ist (nicht Hyper-V)

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

### Docker (Linux/macOS/WSL/Windows)

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
