#Requires -Version 5.1
# =============================================================================
# AniWorld-Downloader Auto-Setup Script fuer Windows
# Installiert Docker Desktop + WSL2, delegiert Docker Setup an Bash-Skript
# =============================================================================

param(
    [switch]$Help
)

$ErrorActionPreference = "Stop"

function Write-Banner {
    Write-Host ""
    Write-Host "    _    _       _ __          __        ___  _ _         ____        _           _           " -ForegroundColor Cyan
    Write-Host "   / \  (_)_ __ (_) \ \        / /__ _ _ / _ \| (_)_ __   |  _ \  ___| | ___  ___| |_ ___ _ _ " -ForegroundColor Cyan
    Write-Host "  / _ \ | | '_ \| | |\ \ /\ / / _ \ '_| | | | | | | '_ \  | | | |/ _ \ |/ _ \/ __| __/ _ | '__|" -ForegroundColor Cyan
    Write-Host " / ___ \| | | | | | | \ V  V /  __/ | | |_| | | | | | | | |_| |  __/ |  __/ (__| ||  __| |   " -ForegroundColor Cyan
    Write-Host "/_/   \_|_|_| |_|_|_|  \_/\_/ \___|_|  \___/|_|_|_| |_| |____/ \___|_|\___|\___|\__\___|_|   " -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  Windows Auto-Setup Script v1.2 (Docker + WSL2 Edition)" -ForegroundColor Cyan
    Write-Host ""
}

function Write-Info  { param([string]$msg) Write-Host "[INFO]  $msg" -ForegroundColor Green }
function Write-Warn  { param([string]$msg) Write-Host "[WARN]  $msg" -ForegroundColor Yellow }
function Write-ErrorX { param([string]$msg) Write-Host "[ERROR] $msg" -ForegroundColor Red }
function Write-Step  { param([string]$msg) Write-Host "[STEP]  $msg" -ForegroundColor Blue }

if ($Help) {
    Write-Banner
    Write-Host "Verwendung: .\aniworld-setup.ps1 [-Help]" -ForegroundColor White
    Write-Host ""
    Write-Host "Dieses Skript richtet AniWorld-Downloader auf Windows ein:" -ForegroundColor White
    Write-Host "  1. Prüft / Installiert Docker Desktop" -ForegroundColor White
    Write-Host "  2. Prüft / Aktiviert WSL2" -ForegroundColor White
    Write-Host "  3. Startet das Docker Setup via WSL Bash" -ForegroundColor White
    Write-Host ""
    exit 0
}

Write-Banner

# --- 1. Docker Desktop prüfen/installieren ---

$dockerPath = "${env:ProgramFiles}\Docker\Docker\Docker Desktop.exe"
$dockerLocal = "${env:LOCALAPPDATA}\Programs\Docker\Docker\Docker Desktop.exe"
$dockerFound = $false

function Test-DockerDesktop {
    if (Test-Path $dockerPath) { return $true }
    if (Test-Path $dockerLocal) { return $true }
    # Auch via Registry prüfen
    try {
        $reg = Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Docker Desktop" -ErrorAction SilentlyContinue
        if ($reg -and $reg.DisplayName) { return $true }
    } catch { }
    try {
        $reg = Get-ItemProperty "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\Docker Desktop" -ErrorAction SilentlyContinue
        if ($reg -and $reg.DisplayName) { return $true }
    } catch { }
    return $false
}

if (Test-DockerDesktop) {
    Write-Info "Docker Desktop ist installiert."
    $dockerFound = $true
} else {
    Write-Warn "Docker Desktop nicht gefunden."
    Write-Step "Installiere Docker Desktop..."

    $wingetAvailable = [bool](Get-Command winget -ErrorAction SilentlyContinue)

    if ($wingetAvailable) {
        Write-Info "Nutze winget fuer Docker Desktop Installation..."
        try {
            winget install Docker.DockerDesktop --accept-source-agreements --accept-package-agreements
            Write-Info "Docker Desktop wurde installiert."
        } catch {
            Write-ErrorX "winget Installation fehlgeschlagen: $_"
            Write-Host ""
            Write-Host "Bitte Docker Desktop manuell installieren:" -ForegroundColor Yellow
            Write-Host "  https://www.docker.com/products/docker-desktop/" -ForegroundColor White
            Write-Host ""
            exit 1
        }
    } else {
        Write-ErrorX "winget nicht verfuegbar. Docker Desktop muss manuell installiert werden."
        Write-Host ""
        Write-Host "Download: https://www.docker.com/products/docker-desktop/" -ForegroundColor Yellow
        Write-Host ""
        exit 1
    }

    Write-Warn "Docker Desktop wurde gerade installiert. Bitte starte Docker Desktop einmalig."
    Write-Warn "Starte anschliessend dieses Skript erneut."
    Write-Host ""
    Read-Host "Enter druecken zum Beenden"
    exit 0
}

# --- 2. Docker Desktop läuft? ---

$dockerRunning = $false
try {
    docker version | Out-Null
    if ($LASTEXITCODE -eq 0) {
        $dockerRunning = $true
    }
} catch { }

if (-not $dockerRunning) {
    Write-Warn "Docker Desktop ist installiert, aber laeuft nicht."
    Write-Info "Starte Docker Desktop..."

    if (Test-Path $dockerPath) {
        Start-Process $dockerPath
    } elseif (Test-Path $dockerLocal) {
        Start-Process $dockerLocal
    }

    Write-Info "Warte auf Docker Desktop..."
    $maxWait = 60
    $waited = 0
    while ($waited -lt $maxWait) {
        Start-Sleep -Seconds 2
        try {
            docker version | Out-Null
            if ($LASTEXITCODE -eq 0) {
                $dockerRunning = $true
                break
            }
        } catch { }
        $waited += 2
        Write-Host "." -NoNewline
    }
    Write-Host ""

    if (-not $dockerRunning) {
        Write-ErrorX "Docker Desktop startet nicht oder braucht zu lange."
        Write-Warn "Bitte Docker Desktop manuell starten und das Skript erneut ausfuehren."
        exit 1
    }
    Write-Info "Docker Desktop laeuft!"
}

# --- 3. WSL2 prüfen/aktivieren ---

Write-Step "Pruefe WSL2..."
$wslAvailable = $false
try {
    wsl --status | Out-Null
    $wslAvailable = ($LASTEXITCODE -eq 0)
} catch { }

if (-not $wslAvailable) {
    Write-Warn "WSL2 ist nicht aktiviert. Aktiviere jetzt..."
    Write-Info "Fuehre 'wsl --install' aus (erfordert evtl. Neustart)..."
    try {
        wsl --install --no-distribution
        Write-Warn "WSL2 wurde aktiviert. Ein Neustart ist evtl. erforderlich."
        Write-Warn "Bitte starte Windows neu und fuehre das Skript erneut aus."
        Read-Host "Enter druecken zum Beenden"
        exit 0
    } catch {
        Write-ErrorX "WSL2 Aktivierung fehlgeschlagen. Bitte manuell ueber 'Windows Features' aktivieren."
        exit 1
    }
}

# Prüfe ob WSL2 Default
$wslDefault = ""
try {
    $wslDefault = (wsl --list --verbose 2>$null | Select-String "\*" | ForEach-Object { $_.ToString().Trim().Split()[0] }) -join ""
} catch { }

if (-not $wslDefault) {
    Write-Warn "Keine Standard-WSL-Distribution gefunden."
    Write-Info "Installiere Ubuntu als Standard-Distribution..."
    try {
        wsl --install -d Ubuntu --no-launch
        Write-Warn "Ubuntu wird installiert. Bitte starte Windows neu und führe das Skript erneut aus."
        Read-Host "Enter druecken zum Beenden"
        exit 0
    } catch {
        Write-ErrorX "Ubuntu Installation fehlgeschlagen: $_"
        exit 1
    }
}

Write-Info "WSL2 mit Distribution '$wslDefault' verfuegbar."

# --- 4. Skript in WSL kopieren & ausführen ---

Write-Step "Übergebe Setup an WSL Bash..."

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$bashScript = Join-Path $scriptDir "docker-setup.sh"

if (-not (Test-Path $bashScript)) {
    Write-ErrorX "docker-setup.sh nicht gefunden im Skript-Verzeichnis: $scriptDir"
    Write-Info "Stelle sicher, dass docker-setup.sh im selben Ordner liegt wie dieses PS1-Skript."
    exit 1
}

Write-Info "Kopiere docker-setup.sh in WSL..."
$wslHome = (wsl bash -c "echo \`$HOME").Trim()
$wslTarget = "$wslHome/aniworld-docker-setup"

wsl bash -c "mkdir -p '$wslTarget'"
$wslScriptPath = "$wslTarget/docker-setup.sh"

# Kopiere via wsl cp
wsl cp -f "/mnt/$($scriptDir -replace ':','').ToLower().Replace('\','/')/docker-setup.sh" "$wslScriptPath"

# Oder alternativ via PowerShell Get-Content
# Das ist zuverlässiger bei verschiedenen Pfad-Konvertierungen
$bashContent = Get-Content -Path $bashScript -Raw -Encoding UTF8
$tempBash = [System.IO.Path]::GetTempFileName() + ".sh"
[System.IO.File]::WriteAllText($tempBash, $bashContent, [System.Text.Encoding]::UTF8)

# Kopiere temp file nach WSL
$wslTempPath = "/tmp/aniworld-docker-setup-temp.sh"
$wslFullPath = wsl wslpath -u "$tempBash"
wsl cp "$wslFullPath" "$wslScriptPath"
wsl chmod +x "$wslScriptPath"

Write-Info "Fuehre docker-setup.sh in WSL aus..."
Write-Host ""
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  Docker Setup via WSL Bash" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

wsl bash "$wslScriptPath"

Write-Host ""
Write-Host "===============================================================" -ForegroundColor Green
Write-Host "  Windows Setup abgeschlossen!" -ForegroundColor Green
Write-Host "===============================================================" -ForegroundColor Green
Write-Host ""
Write-Host "Docker Desktop und AniWorld Container laufen jetzt." -ForegroundColor White
Write-Host "Web UI: http://localhost:8080" -ForegroundColor Cyan
Write-Host ""
