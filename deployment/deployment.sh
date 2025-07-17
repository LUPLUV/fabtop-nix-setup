#!/bin/bash

# FabLab Laptop Deployment Script
# Automatische Installation und Konfiguration von Makerspace-Laptops

set -e

# Konfiguration
REPO_URL="https://github.com/LUPLUV/fablab-nix-setup.git"  # Anpassen!
FABLAB_PASSWORD="fablab"
FABTOP_PASSWORD="fab90763top"

# Farben für Output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Funktionen
log() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
    exit 1
}

# Hostname-Auswahl
select_hostname() {
    echo -e "${BLUE}Verfügbare Laptop-Konfigurationen:${NC}"
    echo "1) fabtop01    2) fabtop02    3) fabtop03    4) fabtop04    5) fabtop05"
    echo "6) fabtop06    7) fabtop07    8) fabtop08    9) fabtop09    10) fabtop10"
    echo "11) Benutzerdefinierten Hostname eingeben"
    echo
    read -p "Wähle eine Option (1-11): " choice
    
    case $choice in
        1) HOSTNAME="fabtop01" ;;
        2) HOSTNAME="fabtop02" ;;
        3) HOSTNAME="fabtop03" ;;
        4) HOSTNAME="fabtop04" ;;
        5) HOSTNAME="fabtop05" ;;
        6) HOSTNAME="fabtop06" ;;
        7) HOSTNAME="fabtop07" ;;
        8) HOSTNAME="fabtop08" ;;
        9) HOSTNAME="fabtop09" ;;
        10) HOSTNAME="fabtop10" ;;
        11) 
            read -p "Hostname eingeben (z.B. fabtop11): " HOSTNAME
            ;;
        *) 
            error "Ungültige Auswahl"
            ;;
    esac
    
    log "Hostname gewählt: $HOSTNAME"
}

# Passwort-Hashes generieren
generate_password_hashes() {
    log "Generiere Passwort-Hashes..."
    
    FABLAB_HASH=$(mkpasswd -m sha-512 "$FABLAB_PASSWORD")
    FABTOP_HASH=$(mkpasswd -m sha-512 "$FABTOP_PASSWORD")
    
    log "Passwort-Hashes generiert"
}

# Repository klonen
clone_repository() {
    log "Klone Repository nach /etc/nixos..."
    
    if [ -d "/etc/nixos" ]; then
        warn "Verzeichnis /etc/nixos existiert bereits"
        read -p "Überschreiben? (y/N): " overwrite
        if [[ $overwrite =~ ^[Yy]$ ]]; then
            rm -rf /etc/nixos
        else
            error "Installation abgebrochen"
        fi
    fi
    
    git clone "$REPO_URL" /etc/nixos
    cd /etc/nixos
}

# Hardware-Konfiguration generieren
generate_hardware_config() {
    log "Generiere Hardware-Konfiguration..."
    nixos-generate-config --show-hardware-config > /etc/nixos/hardware-configuration.nix
    log "Hardware-Konfiguration erstellt"
}

# Passwörter in Konfiguration eintragen
update_passwords() {
    log "Aktualisiere Passwörter in Konfiguration..."
    
    # Backup der ursprünglichen Konfiguration
    cp /etc/nixos/configuration.nix /etc/nixos/configuration.nix.bak
    
    # Passwörter ersetzen
    sed -i "s|hashedPassword = \".*\"; # Generiere mit: mkpasswd -m sha-512 \"fablab\"|hashedPassword = \"$FABLAB_HASH\";|" /etc/nixos/configuration.nix
    sed -i "s|hashedPassword = \".*\"; # Generiere mit: mkpasswd -m sha-512 \"fab90763top\"|hashedPassword = \"$FABTOP_HASH\";|" /etc/nixos/configuration.nix
    
    log "Passwörter aktualisiert"
}

# System installieren
install_system() {
    log "Installiere System für $HOSTNAME..."
    
    # Prüfe ob Konfiguration existiert
    if ! nix flake show 2>/dev/null | grep -q "$HOSTNAME"; then
        error "Konfiguration für $HOSTNAME nicht gefunden in flake.nix"
    fi
    
    # System bauen und aktivieren
    nixos-rebuild switch --flake .#$HOSTNAME
    
    log "System erfolgreich installiert"
}

# Post-Installation
post_install() {
    log "Führe Post-Installation-Schritte aus..."
    
    # Hostname setzen
    hostnamectl set-hostname "$HOSTNAME"
    
    # Services aktivieren
    systemctl enable autoUpdate.timer
    systemctl start autoUpdate.timer
    
    # AppImages herunterladen
    systemctl start appimageDownload
    
    # Laptop-Info generieren
    systemctl start laptopInfo
    
    log "Post-Installation abgeschlossen"
}

# Validierung
validate_installation() {
    log "Validiere Installation..."
    
    # Prüfe Hostname
    if [ "$(hostname)" != "$HOSTNAME" ]; then
        warn "Hostname stimmt nicht überein: $(hostname) != $HOSTNAME"
    fi
    log "Hostname validiert: $HOSTNAME"
    # Prüfe Passwort-Hashes
    if ! grep -q "$FABLAB_HASH" /etc/nixos/configuration.nix; then
        error "Passwort-Hash für fablab nicht gefunden"
    fi
    if ! grep -q "$FABTOP_HASH" /etc/nixos/configuration.nix; then
        error "Passwort-Hash für fabtop nicht gefunden"
    fi
    log "Passwort-Hashes validiert"
    # Prüfe Systemstatus
    if ! systemctl is-active --quiet autoUpdate.timer; then
        error "autoUpdate.timer ist nicht aktiv"
    fi
    log "Systemstatus validiert: autoUpdate.timer ist aktiv"
    # Prüfe AppImages
    if ! systemctl is-active --quiet appimageDownload; then
        error "appimageDownload ist nicht aktiv"
    fi
    log "AppImages validiert: appimageDownload ist aktiv"
    # Prüfe Laptop-Info
    if ! systemctl is-active --quiet laptopInfo; then
        error "laptopInfo ist nicht aktiv"
    fi
    log "Laptop-Info validiert: laptopInfo ist aktiv"
    log "Installation validiert"
}

main() {
  select_hostname
  generate_password_hashes
  clone_repository
  generate_hardware_config
  update_passwords
  install_system
  post_install
  validate_installation
}

main
