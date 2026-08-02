#!/usr/bin/env bash
# =============================================================================
# AniWorld-Downloader Auto-Setup Script
# Plattformübergreifend (Linux, macOS, WSL)
# =============================================================================

set -euo pipefail

SCRIPT_NAME="$(basename "$0")"
INSTALL_MODE=""
SKIP_DOCKER=false
SKIP_NATIVE=false

# Farben
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# --- Hilfsfunktionen ---
print_banner() {
  echo -e "${CYAN}"
  cat <<'EOF'
    _    _       _ __          __        ___  _ _         ____        _           _           
   / \  (_)_ __ (_) \ \        / /__ _ _ / _ \| (_)_ __   |  _ \  ___| | ___  ___| |_ ___ _ _ 
  / _ \ | | '_ \| | |\ \ /\ / / _ \ '_| | | | | | | '_ \  | | | |/ _ \ |/ _ \/ __| __/ _ | '__|
 / ___ \| | | | | | | \ V  V /  __/ | | |_| | | | | | | | |_| |  __/ |  __/ (__| ||  __| |   
/_/   \_|_|_| |_|_|_|  \_/\_/ \___|_|  \___/|_|_|_| |_| |____/ \___|_|\___|\___|\__\___|_|   
EOF
  echo -e "${NC}"
  echo -e "${CYAN}Auto-Setup Script v1.0${NC}"
  echo ""
}

log_info()  { echo -e "${GREEN}[INFO]${NC}  $*"; }
log_warn()  { echo -e "${YELLOW}[WARN]${NC}  $*"; }
log_error() { echo -e "${RED}[ERROR]${NC} $*"; }
log_step()  { echo -e "${BLUE}[STEP]${NC}  $*"; }

# --- Kompatibilität ---
detect_os() {
  if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS="linux"
    if command -v apt &>/dev/null; then
      PKG_MGR="apt"
    elif command -v dnf &>/dev/null; then
      PKG_MGR="dnf"
    elif command -v pacman &>/dev/null; then
      PKG_MGR="pacman"
    elif command -v zypper &>/dev/null; then
      PKG_MGR="zypper"
    else
      PKG_MGR=""
    fi
  elif [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macos"
    if command -v brew &>/dev/null; then
      PKG_MGR="brew"
    else
      PKG_MGR=""
    fi
  elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]]; then
    OS="windows"
    PKG_MGR=""
  else
    OS="unknown"
    PKG_MGR=""
  fi
}

# --- Abhängigkeiten ---

check_python() {
  local python_cmd=""
  if command -v python3 &>/dev/null; then
    python_cmd="python3"
  elif command -v python &>/dev/null; then
    python_cmd="python"
  fi

  if [[ -z "$python_cmd" ]]; then
    log_error "Python ist nicht installiert. Bitte installiere Python 3.10 oder neuer."
    if [[ "$OS" == "linux" ]]; then
      log_info "Versuche: sudo $PKG_MGR install python3 python3-pip python3-venv"
    elif [[ "$OS" == "macos" ]]; then
      log_info "Versuche: brew install python@3.13"
    fi
    exit 1
  fi

  local py_version
  py_version="$($python_cmd -c 'import sys; print(f"{sys.version_info.major}.{sys.version_info.minor}")' 2>/dev/null)"
  
  # Vergleiche Major.Minor
  local major minor req_major req_minor
  major=$(echo "$py_version" | cut -d. -f1)
  minor=$(echo "$py_version" | cut -d. -f2)
  req_major=3
  req_minor=10

  if [[ "$major" -lt "$req_major" ]] || { [[ "$major" -eq "$req_major" ]] && [[ "$minor" -lt "$req_minor" ]]; }; then
    log_error "Python ${major}.${minor} gefunden, aber mindestens Python 3.10 wird benötigt."
    exit 1
  fi

  PYTHON_CMD="$python_cmd"
  log_info "Python $py_version gefunden ($PYTHON_CMD)"
}

install_system_deps() {
  log_step "Installiere System-Abhängigkeiten (ffmpeg, git)..."

  if [[ "$OS" == "linux" ]]; then
    if [[ "$PKG_MGR" == "apt" ]]; then
      sudo apt-get update -qq
      sudo apt-get install -y -qq ffmpeg git curl python3-pip python3-venv
    elif [[ "$PKG_MGR" == "dnf" ]]; then
      sudo dnf install -y ffmpeg git curl python3-pip python3-virtualenv
    elif [[ "$PKG_MGR" == "pacman" ]]; then
      sudo pacman -Sy --needed --noconfirm ffmpeg git curl python-pip python-virtualenv
    elif [[ "$PKG_MGR" == "zypper" ]]; then
      sudo zypper install -y ffmpeg git curl python3-pip python3-virtualenv
    else
      log_warn "Kein bekannter Paketmanager gefunden. Bitte installiere ffmpeg und git manuell."
    fi
  elif [[ "$OS" == "macos" ]]; then
    if [[ "$PKG_MGR" == "brew" ]]; then
      brew install ffmpeg git python
    else
      log_warn "Homebrew nicht gefunden. Bitte installiere ffmpeg und git manuell (https://brew.sh)."
    fi
  elif [[ "$OS" == "windows" ]]; then
    log_warn "Auf Windows bitte ffmpeg von https://ffmpeg.org/download.html#build-windows herunterladen und in PATH hinzufügen."
  fi
}

# --- Native Python Installation ---

install_native() {
  log_step "Installiere AniWorld-Downloader über pip..."

  # Prüfe ob pip verfügbar
  if ! $PYTHON_CMD -m pip --version &>/dev/null; then
    log_error "pip ist nicht verfügbar. Versuche pip zu installieren..."
    if [[ "$OS" == "linux" && "$PKG_MGR" == "apt" ]]; then
      sudo apt-get install -y python3-pip
    else
      log_error "Bitte installiere pip manuell."
      exit 1
    fi
  fi

  # Upgrade pip
  log_info "Upgrade pip..."
  $PYTHON_CMD -m pip install --upgrade pip -q

  # Installiere aniworld
  log_info "Installiere aniworld Paket..."
  $PYTHON_CMD -m pip install -U aniworld

  # Verifiziere
  if command -v aniworld &>/dev/null; then
    log_info "AniWorld-Downloader erfolgreich installiert."
    aniworld --version
  else
    log_warn "'aniworld' nicht in PATH gefunden. Möglicherweise ist der User-Bin-Pfad nicht eingetragen."
    $PYTHON_CMD -m aniworld --version || true
  fi

  # Optional: mpv für "Watch"
  if command -v mpv &>/dev/null; then
    log_info "mpv bereits installiert ✓"
  else
    log_warn "mpv nicht gefunden. Für 'Watch' Funktionalität empfohlen."
    if [[ "$OS" == "linux" && "$PKG_MGR" == "apt" ]]; then
      log_info "Installiere mpv..."
      sudo apt-get install -y mpv
    elif [[ "$OS" == "macos" && "$PKG_MGR" == "brew" ]]; then
      log_info "Installiere mpv..."
      brew install mpv
    fi
  fi
}

# --- Docker Installation ---

check_docker() {
  if ! command -v docker &>/dev/null; then
    log_error "Docker ist nicht installiert."
    log_info "Installiere Docker mit dem offiziellen Install-Script..."
    curl -fsSL https://get.docker.com | sh
    sudo usermod -aG docker "$USER" || true
    log_warn "Du musst dich evtl. ab- und wieder anmelden, damit die Docker-Gruppe greift."
  fi

  if ! command -v docker-compose &>/dev/null && ! docker compose version &>/dev/null; then
    log_error "Docker Compose ist nicht verfügbar."
    if [[ "$OS" == "linux" && "$PKG_MGR" == "apt" ]]; then
      sudo apt-get install -y docker-compose-plugin
    fi
  fi
}

install_docker() {
  log_step "Richte Docker Compose Setup ein..."

  local compose_dir
  compose_dir="$HOME/aniworld-docker"
  mkdir -p "$compose_dir/Downloads"

  # Erstelle docker-compose.yaml
  cat > "$compose_dir/docker-compose.yaml" <<'EOF'
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
EOF

  # Erstelle Start-Script
  cat > "$compose_dir/start.sh" <<'EOF'
#!/usr/bin/env bash
cd "$(dirname "$0")"
docker compose up -d
echo "AniWorld Web UI läuft unter http://localhost:8080"
EOF

  cat > "$compose_dir/stop.sh" <<'EOF'
#!/usr/bin/env bash
cd "$(dirname "$0")"
docker compose down
echo "AniWorld gestoppt."
EOF

  cat > "$compose_dir/update.sh" <<'EOF'
#!/usr/bin/env bash
cd "$(dirname "$0")"
docker compose pull
docker compose up -d
echo "AniWorld aktualisiert."
EOF

  chmod +x "$compose_dir/start.sh" "$compose_dir/stop.sh" "$compose_dir/update.sh"

  log_info "Docker Compose Dateien erstellt in: $compose_dir"
  
  # Starte Container
  cd "$compose_dir"
  if docker compose up -d; then
    log_info "AniWorld Container gestartet!"
    log_info "Web UI erreichbar unter: http://localhost:8080"
    log_info "Downloads landen in: $compose_dir/Downloads"
  else
    log_error "Docker Compose Start fehlgeschlagen. Prüfe die Logs mit: cd $compose_dir && docker compose logs"
    exit 1
  fi
}

# --- Interaktive Menüs ---

ask_install_mode() {
  echo ""
  echo -e "${CYAN}Wie möchtest du AniWorld-Downloader installieren?${NC}"
  echo ""
  echo "  1) Docker Compose (empfohlen für Server/NAS, Web UI sofort verfügbar)"
  echo "  2) Native Python (pip, CLI + Web UI via 'aniworld -w')"
  echo "  3) Beides (Native + Docker)"
  echo ""
  read -rp "Auswahl [1-3]: " choice
  case "$choice" in
    1) INSTALL_MODE="docker" ;;
    2) INSTALL_MODE="native" ;;
    3) INSTALL_MODE="both" ;;
    *) log_error "Ungültige Auswahl. Abbruch."; exit 1 ;;
  esac
}

# --- Hauptablauf ---

main() {
  print_banner

  # Argumente parsen
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --docker) INSTALL_MODE="docker"; shift ;;
      --native) INSTALL_MODE="native"; shift ;;
      --both)   INSTALL_MODE="both"; shift ;;
      -h|--help)
        cat <<EOF
Verwendung: $SCRIPT_NAME [OPTION]

Optionen:
  --docker    Nur Docker Compose Setup
  --native    Nur native Python Installation
  --both      Beides installieren
  -h, --help  Diese Hilfe anzeigen

Das Skript erkennt dein Betriebssystem automatisch und installiert alle nötigen
Abhängigkeiten (Python, pip, ffmpeg, Docker).
EOF
        exit 0
        ;;
      *) log_error "Unbekannte Option: $1"; exit 1 ;;
    esac
  done

  detect_os
  log_info "Betriebssystem erkannt: $OS"

  # Modus wählen, falls nicht per Flag angegeben
  if [[ -z "$INSTALL_MODE" ]]; then
    ask_install_mode
  fi

  # Native Installation
  if [[ "$INSTALL_MODE" == "native" ]] || [[ "$INSTALL_MODE" == "both" ]]; then
    install_system_deps
    check_python
    install_native
    echo ""
    log_info "Native Installation abgeschlossen!"
    log_info "Terminal-Menu: ${CYAN}aniworld${NC}"
    log_info "Web UI:        ${CYAN}aniworld -w${NC}  → http://localhost:8080"
    log_info "Direkt-CLI:    ${CYAN}aniworld --no-menu <URL>${NC}"
    echo ""
  fi

  # Docker Installation
  if [[ "$INSTALL_MODE" == "docker" ]] || [[ "$INSTALL_MODE" == "both" ]]; then
    if [[ "$OS" == "windows" ]]; then
      log_error "Docker Setup auf Windows bitte manuell durchführen (Docker Desktop)."
    else
      check_docker
      install_docker
      echo ""
      log_info "Docker Installation abgeschlossen!"
      echo ""
    fi
  fi

  echo -e "${GREEN}══════════════════════════════════════════════════════════════${NC}"
  echo -e "${GREEN}  Setup abgeschlossen! Viel Spaß mit AniWorld-Downloader 🎉${NC}"
  echo -e "${GREEN}══════════════════════════════════════════════════════════════${NC}"
}

main "$@"
