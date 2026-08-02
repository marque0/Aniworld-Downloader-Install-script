#!/usr/bin/env bash
# =============================================================================
# AniWorld-Downloader Docker Setup Script
# Plattformübergreifend: Linux, macOS, WSL, Windows (via WSL)
# =============================================================================

set -euo pipefail

SCRIPT_NAME="$(basename "$0")"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

log_info()  { echo -e "${GREEN}[INFO]${NC}  $*"; }
log_warn()  { echo -e "${YELLOW}[WARN]${NC}  $*"; }
log_error() { echo -e "${RED}[ERROR]${NC} $*"; }
log_step()  { echo -e "${BLUE}[STEP]${NC}  $*"; }

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
  echo -e "${CYAN}Docker Setup Script v1.0${NC}"
  echo ""
}

detect_os() {
  if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS="linux"
  elif [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macos"
  else
    OS="unknown"
  fi
}

check_docker() {
  if ! command -v docker &>/dev/null; then
    log_error "Docker ist nicht installiert oder nicht im PATH."
    log_info "Windows: Docker Desktop starten oder installieren (https://www.docker.com/products/docker-desktop/)"
    log_info "Linux:   sudo apt-get install docker.io docker-compose-plugin"
    log_info "macOS:   brew install --cask docker"
    exit 1
  fi

  if ! docker compose version &>/dev/null; then
    log_error "Docker Compose Plugin nicht verfügbar."
    log_info "Bitte Docker Desktop oder Docker Compose Plugin installieren."
    exit 1
  fi
}

setup_docker() {
  log_step "Erstelle Docker Compose Konfiguration..."

  local compose_dir
  compose_dir="$SCRIPT_DIR"
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

  log_info "Docker Compose Dateien erstellt in: $compose_dir"
}

start_container() {
  log_step "Starte AniWorld Container..."
  cd "$SCRIPT_DIR"

  # Erstelle Downloads-Ordner falls Docker ihn als root erstellen würde
  mkdir -p ./Downloads

  if docker compose up -d; then
    log_info "AniWorld Container gestartet!"
    log_info ""
    log_info "Web UI erreichbar unter: ${CYAN}http://localhost:8080${NC}"
    log_info "Downloads landen in:    ${CYAN}$SCRIPT_DIR/Downloads${NC}"
    log_info ""
    log_info "Nützliche Befehle:"
    log_info "  Stoppen:   cd '$SCRIPT_DIR' && docker compose down"
    log_info "  Logs:      cd '$SCRIPT_DIR' && docker compose logs -f"
    log_info "  Update:    cd '$SCRIPT_DIR' && docker compose pull && docker compose up -d"
  else
    log_error "Docker Compose Start fehlgeschlagen."
    log_warn "Prüfe die Logs mit: cd '$SCRIPT_DIR' && docker compose logs"
    exit 1
  fi
}

main() {
  print_banner

  detect_os
  log_info "Betriebssystem erkannt: $OS"

  check_docker
  setup_docker
  start_container

  echo ""
  echo -e "${GREEN}══════════════════════════════════════════════════════════════${NC}"
  echo -e "${GREEN}  Setup abgeschlossen! Viel Spaß mit AniWorld-Downloader 🎉${NC}"
  echo -e "${GREEN}══════════════════════════════════════════════════════════════${NC}"
}

main "$@"
