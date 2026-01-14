#!/usr/bin/env bash

#####################################################################
# Apollo OS - Update Script
# Copyright © 2025 by Manuel Kraibacher
#
# Description: Aktualisiert Apollo OS von GitHub
#####################################################################

set -e

REPO_URL="https://github.com/apolloenv/apollo-os.git"
INSTALL_DIR="$HOME/apollo-os-update"
BRANCH="main"

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}================================================"
echo "  Apollo OS - Update"
echo -e "================================================${NC}"
echo

# Check if git is installed
if ! command -v git &>/dev/null; then
    echo -e "${RED}Error: git ist nicht installiert${NC}"
    exit 1
fi

# Remove old update directory if exists
if [ -d "$INSTALL_DIR" ]; then
    echo -e "${YELLOW}Entferne altes Update-Verzeichnis...${NC}"
    rm -rf "$INSTALL_DIR"
fi

# Clone latest version from GitHub
echo -e "${GREEN}Lade neueste Version von GitHub...${NC}"
git clone --depth 1 --branch "$BRANCH" "$REPO_URL" "$INSTALL_DIR" || {
    echo -e "${RED}Fehler beim Klonen des Repositories${NC}"
    exit 1
}

echo -e "${GREEN}✓${NC} Repository geklont"
echo

# Show version info
if [ -f "$INSTALL_DIR/README.md" ]; then
    VERSION=$(grep -m1 "Apollo OS v" "$INSTALL_DIR/README.md" | sed 's/.*Apollo OS v\([0-9.]*\).*/\1/')
    echo -e "${BLUE}Neue Version: v${VERSION}${NC}"
    echo
fi

# Ask for confirmation
echo -e "${YELLOW}Was möchtest du aktualisieren?${NC}"
echo
echo "1) Nur Konfigurationen (Niri, Waybar, Mako, Rofi)"
echo "2) Nur Scripts"
echo "3) Alles (Configs + Scripts)"
echo "4) Vollständige Neuinstallation"
echo "5) Abbrechen"
echo
read -p "Auswahl (1-5): " choice

case $choice in
    1)
        echo -e "${GREEN}Aktualisiere Konfigurationen...${NC}"
        
        # Backup existing configs
        BACKUP_DIR="$HOME/.config/apollo-os-backup-$(date +%Y%m%d-%H%M%S)"
        mkdir -p "$BACKUP_DIR"
        
        [ -d "$HOME/.config/niri" ] && cp -r "$HOME/.config/niri" "$BACKUP_DIR/"
        [ -d "$HOME/.config/waybar" ] && cp -r "$HOME/.config/waybar" "$BACKUP_DIR/"
        [ -d "$HOME/.config/mako" ] && cp -r "$HOME/.config/mako" "$BACKUP_DIR/"
        [ -d "$HOME/.config/rofi" ] && cp -r "$HOME/.config/rofi" "$BACKUP_DIR/"
        
        echo -e "${GREEN}✓${NC} Backup erstellt: $BACKUP_DIR"
        
        # Copy new configs
        cp "$INSTALL_DIR/config-data/niri/apollo-os-niri-config.kdl" "$HOME/.config/niri/config.kdl"
        cp "$INSTALL_DIR/config-data/waybar/apollo-os-waybar-config" "$HOME/.config/waybar/config-niri"
        cp "$INSTALL_DIR/config-data/waybar/apollo-os-waybar-style.css" "$HOME/.config/waybar/style.css"
        cp "$INSTALL_DIR/config-data/mako/apollo-os-mako-config" "$HOME/.config/mako/config"
        cp "$INSTALL_DIR/config-data/rofi/apollo-os-rofi-theme.rasi" "$HOME/.config/rofi/config.rasi"
        
        # Copy additional niri scripts
        cp "$INSTALL_DIR/config-data/niri/apollo-autostart.sh" "$HOME/.config/niri/"
        chmod +x "$HOME/.config/niri/apollo-autostart.sh"
        
        echo -e "${GREEN}✓${NC} Konfigurationen aktualisiert"
        
        # Reload configs
        niri msg action load-config-file
        pkill -SIGUSR2 waybar 2>/dev/null || true
        
        echo -e "${GREEN}✓${NC} Konfigurationen neu geladen"
        ;;
        
    2)
        echo -e "${GREEN}Aktualisiere Scripts...${NC}"
        
        # Copy scripts
        for script in "$INSTALL_DIR/scripts/"*.sh; do
            if [ -f "$script" ]; then
                cp "$script" "$HOME/.local/bin/"
                chmod +x "$HOME/.local/bin/$(basename "$script")"
            fi
        done
        
        echo -e "${GREEN}✓${NC} Scripts aktualisiert"
        ;;
        
    3)
        echo -e "${GREEN}Aktualisiere alles...${NC}"
        
        # Backup
        BACKUP_DIR="$HOME/.config/apollo-os-backup-$(date +%Y%m%d-%H%M%S)"
        mkdir -p "$BACKUP_DIR"
        [ -d "$HOME/.config/niri" ] && cp -r "$HOME/.config/niri" "$BACKUP_DIR/"
        [ -d "$HOME/.config/waybar" ] && cp -r "$HOME/.config/waybar" "$BACKUP_DIR/"
        [ -d "$HOME/.config/mako" ] && cp -r "$HOME/.config/mako" "$BACKUP_DIR/"
        [ -d "$HOME/.config/rofi" ] && cp -r "$HOME/.config/rofi" "$BACKUP_DIR/"
        
        echo -e "${GREEN}✓${NC} Backup: $BACKUP_DIR"
        
        # Update configs
        cp "$INSTALL_DIR/config-data/niri/apollo-os-niri-config.kdl" "$HOME/.config/niri/config.kdl"
        cp "$INSTALL_DIR/config-data/waybar/apollo-os-waybar-config" "$HOME/.config/waybar/config-niri"
        cp "$INSTALL_DIR/config-data/waybar/apollo-os-waybar-style.css" "$HOME/.config/waybar/style.css"
        cp "$INSTALL_DIR/config-data/mako/apollo-os-mako-config" "$HOME/.config/mako/config"
        cp "$INSTALL_DIR/config-data/rofi/apollo-os-rofi-theme.rasi" "$HOME/.config/rofi/config.rasi"
        cp "$INSTALL_DIR/config-data/niri/apollo-autostart.sh" "$HOME/.config/niri/"
        chmod +x "$HOME/.config/niri/apollo-autostart.sh"
        
        # Update scripts
        for script in "$INSTALL_DIR/scripts/"*.sh; do
            if [ -f "$script" ]; then
                cp "$script" "$HOME/.local/bin/"
                chmod +x "$HOME/.local/bin/$(basename "$script")"
            fi
        done
        
        echo -e "${GREEN}✓${NC} Alles aktualisiert"
        
        # Reload
        niri msg action load-config-file
        pkill -SIGUSR2 waybar 2>/dev/null || true
        
        echo -e "${GREEN}✓${NC} Neu geladen"
        ;;
        
    4)
        echo -e "${YELLOW}Vollständige Neuinstallation wird gestartet...${NC}"
        cd "$INSTALL_DIR"
        bash apollo-os-install.sh
        ;;
        
    5)
        echo -e "${YELLOW}Update abgebrochen${NC}"
        rm -rf "$INSTALL_DIR"
        exit 0
        ;;
        
    *)
        echo -e "${RED}Ungültige Auswahl${NC}"
        rm -rf "$INSTALL_DIR"
        exit 1
        ;;
esac

echo
echo -e "${GREEN}================================================"
echo "  Apollo OS erfolgreich aktualisiert! ✓"
echo -e "================================================${NC}"
echo

# Cleanup
rm -rf "$INSTALL_DIR"

read -p "Drücke Enter zum Beenden..."
