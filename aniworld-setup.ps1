#Requires -Version 5.1
# =============================================================================
# AniWorld-Downloader Auto-Setup Script fuer Windows
# =============================================================================

param(
    [switch]$Docker,
    [switch]$Native,
    [switch]$Both,
    [switch]$Help
)

$ErrorActionPreference = "Stop"

# --- Farben / Styling ---
function Write-Banner {
    Write-Host ""
    Write-Host "    _    _       _ __          __        ___  _ _         ____        _           _           " -ForegroundColor Cyan
    Write-Host "   / \  (_)_ __ (_) \ \        / /__ _ _ / _ \| (_)_ __   |  _ \  ___| | ___  ___| |_ ___ _ _ " -ForegroundColor Cyan
    Write-Host "  / _ \ | | '_ \| | |\ \ /\ / / _ \ '_| | | | | | | '_ \  | | | |/ _ \ |/ _ \/ __| __/ _ | '__|" -ForegroundColor Cyan
    Write-Host " / ___ \| | | | | | | \ V  V /  __/ | | |_| | | | | | | | |_| |  __/ |  __/ (__| ||  __| |   " -ForegroundColor Cyan
    Write-Host "/_/   \_|_|_| |_|_|_|  \_/\_/ \___|_|  \___/|_|_|_| |_| |____/ \___|_|\___|\___|\__\___|_|   " -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  Auto-Setup Script v1.1 (Windows Edition)" -ForegroundColor Cyan
    Write-Host ""
}

function Write-Info  { param([string]$msg) Write-Host "[INFO]  $msg" -ForegroundColor Green }
function Write-Warn  { param([string]$msg) Write-Host "[WARN]  $msg" -ForegroundColor Yellow }
function Write-ErrorX { param([string]$msg) Write-Host "[ERROR] $msg" -ForegroundColor Red }
function Write-Step  { param([string]$msg) Write-Host "[STEP]  $msg" -ForegroundColor Blue }

# --- Hilfsfunktionen ---

function Test-Command {
    param([string]$cmd)
    return [bool](Get-Command $cmd -ErrorAction SilentlyContinue)
}

function Get-PythonCommand {
    $candidates = @("python", "py", "python3")
    foreach ($c in $candidates) {
        if (Test-Command $c) {
            try {
                $verStr = & $c --version 2>$null
                if ($verStr -match "Python\s+(\d+)\.(\d+)") {
                    $major = [int]$matches[1]
                    $minor = [int]$matches[2]
                    if ($major -gt 3 -or ($major -eq 3 -and $minor -ge 10)) {
                        return $c
                    }
                }
            } catch { }
        }
    }
    return $null
}

function Invoke-With-Banner {
    Write-Banner

    if ($Help) {
        Write-Host "Verwendung: .\aniworld-setup.ps1 [OPTION]" -ForegroundColor White
        Write-Host ""
        Write-Host "Optionen:" -ForegroundColor White
        Write-Host "  -Docker    Nur Docker Compose Setup (Docker Desktop erforderlich)"
        Write-Host "  -Native    Nur native Python Installation"
        Write-Host "  -Both      Beides installieren"
        Write-Host "  -Help      Diese Hilfe anzeigen"
        Write-Host ""
        Write-Host "Das Skript erkennt Python automatisch und installiert alle noetigen Abhaengigkeiten."
        Write-Host ""
        exit 0
    }
}

function Ask-InstallMode {
    Write-Host ""
    Write-Host "Wie moechtest du AniWorld-Downloader installieren?" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  1) Docker Compose (empfohlen fuer dauerhaft laufende Web UI)"
    Write-Host "  2) Native Python (pip, CLI + Web UI via 'aniworld -w')"
    Write-Host "  3) Beides"
    Write-Host ""
    $choice = Read-Host "Auswahl [1-3]"
    switch ($choice) {
        "1" { return "docker" }
        "2" { return "native" }
        "3" { return "both" }
        default { Write-ErrorX "Ungueltige Auswahl. Abbruch."; exit 1 }
    }
}

# --- Installation: Native Python ---

function Install-Native {
    Write-Step "Installiere AniWorld-Downloader ueber pip..."

    $pythonCmd = Get-PythonCommand
    if (-not $pythonCmd) {
        Write-ErrorX "Python 3.10+ wurde nicht gefunden."
        Write-Host ""
        Write-Host "Bitte installiere Python von einer der folgenden Quellen:" -ForegroundColor Yellow
        Write-Host "  1) Microsoft Store: Such nach 'Python 3.13' und installiere es"
        Write-Host "  2) https://www.python.org/downloads/ (Haken bei 'Add Python to PATH' setzen!)"
        Write-Host "  3) winget:  winget install Python.Python.3.13"
        Write-Host ""
        Write-Host "Danach PowerShell neu starten und das Skript erneut ausfuehren."
        exit 1
    }

    Write-Info "Python gefunden: $pythonCmd"

    # Upgrade pip
    Write-Info "Upgrade pip..."
    & $pythonCmd -m pip install --upgrade pip -q

    # Installiere aniworld
    Write-Info "Installiere 'aniworld' Paket..."
    & $pythonCmd -m pip install -U aniworld

    # Pruefe ffmpeg
    if (Test-Command ffmpeg) {
        Write-Info "ffmpeg bereits installiert."
    } else {
        Write-Warn "ffmpeg nicht gefunden. Wird fuer Downloads benoetigt."
        Write-Info "Installiere ueber winget: winget install Gyan.FFmpeg"
        $installFfmpeg = Read-Host "Soll ich ffmpeg jetzt automatisch installieren? (j/n)"
        if ($installFfmpeg -eq "j" -or $installFfmpeg -eq "J") {
            if (Test-Command winget) {
                winget install Gyan.FFmpeg --accept-source-agreements --accept-package-agreements
                Write-Info "ffmpeg wurde installiert. PowerShell bitte neu starten, damit PATH greift."
            } else {
                Write-Warn "winget nicht verfuegbar. Bitte ffmpeg manuell von https://ffmpeg.org/download.html installieren."
            }
        }
    }

    # Pruefe mpv
    if (Test-Command mpv) {
        Write-Info "mpv bereits installiert."
    } else {
        Write-Warn "mpv nicht gefunden. Fuer 'Watch' Funktionalitaet empfohlen."
        $installMpv = Read-Host "Soll ich mpv jetzt automatisch installieren? (j/n)"
        if ($installMpv -eq "j" -or $installMpv -eq "J") {
            if (Test-Command winget) {
                winget install mpv.net --accept-source-agreements --accept-package-agreements
                Write-Info "mpv wurde installiert."
            } else {
                Write-Warn "winget nicht verfuegbar. Bitte mpv manuell installieren."
            }
        }
    }

    Write-Info "Native Installation abgeschlossen!"
    Write-Info "Terminal-Menu:  aniworld"
    Write-Info "Web UI:       aniworld -w  -> http://localhost:8080"
    Write-Info "Direkt-CLI:   aniworld --no-menu <URL>"
}

# --- Installation: Docker ---

function Install-Docker {
    Write-Step "Richte Docker Compose Setup ein..."

    if (-not (Test-Command docker)) {
        Write-ErrorX "Docker ist nicht installiert."
        Write-Host ""
        Write-Host "Bitte installiere Docker Desktop:" -ForegroundColor Yellow
        Write-Host "  https://www.docker.com/products/docker-desktop/"
        Write-Host ""
        Write-Host "Nach der Installation PowerShell neu starten und das Skript erneut ausfuehren."
        exit 1
    }

    # Pruefe Docker Compose
    try {
        docker compose version | Out-Null
    } catch {
        Write-ErrorX "Docker Compose nicht verfuegbar. Bitte Docker Desktop aktualisieren."
        exit 1
    }

    $composeDir = "$env:USERPROFILE\aniworld-docker"
    New-Item -ItemType Directory -Force -Path "$composeDir\Downloads" | Out-Null

    # docker-compose.yaml
    @"
services:
  aniworld:
    image: ghcr.io/phoenixthrush/aniworld-downloader:latest
    container_name: aniworld-downloader
    ports:
      - "8080:8080"
    volumes:
      - ./Downloads:/app/Downloads
      - aniworld-data:/home/aniworld/.aniworld
    environment:
      ANIWORLD_LANGUAGE: "German Dub"
      ANIWORLD_PROVIDER: "VOE"
    restart: unless-stopped

volumes:
  aniworld-data:
"@ | Set-Content -Path "$composeDir\docker-compose.yaml" -Encoding UTF8

    # Start-Script
    @"
@ECHO OFF
cd /d %~dp0
docker compose up -d
echo AniWorld Web UI laeuft unter http://localhost:8080
pause
"@ | Set-Content -Path "$composeDir\start.bat" -Encoding UTF8

    # Stop-Script
    @"
@ECHO OFF
cd /d %~dp0
docker compose down
echo AniWorld gestoppt.
pause
"@ | Set-Content -Path "$composeDir\stop.bat" -Encoding UTF8

    # Update-Script
    @"
@ECHO OFF
cd /d %~dp0
docker compose pull
docker compose up -d
echo AniWorld aktualisiert.
pause
"@ | Set-Content -Path "$composeDir\update.bat" -Encoding UTF8

    Write-Info "Docker Compose Dateien erstellt in: $composeDir"

    # Starte Container
    Set-Location $composeDir
    docker compose up -d
    if ($LASTEXITCODE -eq 0) {
        Write-Info "AniWorld Container gestartet!"
        Write-Info "Web UI erreichbar unter: http://localhost:8080"
        Write-Info "Downloads landen in: $composeDir\Downloads"
    } else {
        Write-ErrorX "Docker Compose Start fehlgeschlagen."
        Write-Warn "Pruefe die Logs mit: cd '$composeDir' ; docker compose logs"
        exit 1
    }
}

# --- Hauptablauf ---

Invoke-With-Banner

# Modus bestimmen
$mode = $null
if ($Docker) { $mode = "docker" }
elseif ($Native) { $mode = "native" }
elseif ($Both) { $mode = "both" }
else { $mode = Ask-InstallMode }

# Native
if ($mode -eq "native" -or $mode -eq "both") {
    Install-Native
    Write-Host ""
}

# Docker
if ($mode -eq "docker" -or $mode -eq "both") {
    Install-Docker
    Write-Host ""
}

Write-Host "===============================================================" -ForegroundColor Green
Write-Host "  Setup abgeschlossen! Viel Spass mit AniWorld-Downloader!" -ForegroundColor Green
Write-Host "===============================================================" -ForegroundColor Green
