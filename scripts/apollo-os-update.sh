#!/usr/bin/env bash

#####################################################################
# Apollo OS - Update Script
# Copyright © 2025 by Manuel Kraibacher
#
# Description: Aktualisiert Apollo OS von GitHub (automatisch)
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
echo "  Apollo OS - Automatisches Update"
echo -e "================================================${NC}"
echo

# Check if git is installed
if ! command -v git &>/dev/null; then
    echo -e "${RED}Error: git ist nicht installiert${NC}"
    read -p "Drücke Enter zum Beenden..."
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
    read -p "Drücke Enter zum Beenden..."
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

# Create backup
echo -e "${GREEN}Erstelle Backup...${NC}"
BACKUP_DIR="$HOME/.config/apollo-os-backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP_DIR"

[ -d "$HOME/.config/niri" ] && cp -r "$HOME/.config/niri" "$BACKUP_DIR/"
[ -d "$HOME/.config/waybar" ] && cp -r "$HOME/.config/waybar" "$BACKUP_DIR/"
[ -d "$HOME/.config/mako" ] && cp -r "$HOME/.config/mako" "$BACKUP_DIR/"
[ -d "$HOME/.config/rofi" ] && cp -r "$HOME/.config/rofi" "$BACKUP_DIR/"

echo -e "${GREEN}✓${NC} Backup erstellt: $BACKUP_DIR"
echo

# Update everything
echo -e "${GREEN}Aktualisiere Konfigurationen...${NC}"

# Copy configs
cp "$INSTALL_DIR/config-data/niri/apollo-os-niri-config.kdl" "$HOME/.config/niri/config.kdl"
cp "$INSTALL_DIR/config-data/waybar/apollo-os-waybar-config" "$HOME/.config/waybar/config-niri"
cp "$INSTALL_DIR/config-data/waybar/apollo-os-waybar-style.css" "$HOME/.config/waybar/style.css"
cp "$INSTALL_DIR/config-data/mako/apollo-os-mako-config" "$HOME/.config/mako/config"
cp "$INSTALL_DIR/config-data/rofi/apollo-os-rofi-theme.rasi" "$HOME/.config/rofi/config.rasi"
cp "$INSTALL_DIR/config-data/niri/apollo-autostart.sh" "$HOME/.config/niri/"
chmod +x "$HOME/.config/niri/apollo-autostart.sh"

# Copy Niri helper scripts
for script in "$INSTALL_DIR/config-data/niri/"*.sh; do
    if [ -f "$script" ] && [ "$(basename "$script")" != "apollo-autostart.sh" ]; then
        cp "$script" "$HOME/.config/niri/"
        chmod +x "$HOME/.config/niri/$(basename "$script")"
    fi
done

# Copy GTK configs if exist
if [ -f "$INSTALL_DIR/config-data/gtk-3.0-settings.ini" ]; then
    cp "$INSTALL_DIR/config-data/gtk-3.0-settings.ini" "$HOME/.config/gtk-3.0/settings.ini"
fi
if [ -f "$INSTALL_DIR/config-data/gtk-4.0-settings.ini" ]; then
    cp "$INSTALL_DIR/config-data/gtk-4.0-settings.ini" "$HOME/.config/gtk-4.0/settings.ini"
fi

echo -e "${GREEN}✓${NC} Konfigurationen aktualisiert"
echo

# Update scripts
echo -e "${GREEN}Aktualisiere Scripts...${NC}"

mkdir -p "$HOME/.local/bin"
for script in "$INSTALL_DIR/scripts/"*.sh; do
    if [ -f "$script" ]; then
        cp "$script" "$HOME/.local/bin/"
        chmod +x "$HOME/.local/bin/$(basename "$script")"
    fi
done

echo -e "${GREEN}✓${NC} Scripts aktualisiert"
echo

# Update wallpapers if exist
if [ -d "$INSTALL_DIR/assets/wallpapers" ]; then
    echo -e "${GREEN}Aktualisiere Wallpapers...${NC}"
    mkdir -p "$HOME/System/Wallpaper"
    cp -r "$INSTALL_DIR/assets/wallpapers/"* "$HOME/System/Wallpaper/" 2>/dev/null || true
    echo -e "${GREEN}✓${NC} Wallpapers aktualisiert"
    echo
fi

# Check hostname and offer to change if still default
CURRENT_HOSTNAME=$(hostname)
if [ "$CURRENT_HOSTNAME" = "fedora" ] || [ "$CURRENT_HOSTNAME" = "localhost" ]; then
    echo -e "${YELLOW}⚠ Hostname ist noch auf Standard ('$CURRENT_HOSTNAME')${NC}"
    read -p "Möchtest du den Hostname jetzt ändern? (j/n): " change_hostname
    if [[ "$change_hostname" =~ ^[jJyY]$ ]]; then
        read -p "Neuer Hostname: " new_hostname
        if [ -n "$new_hostname" ]; then
            echo -e "${GREEN}Ändere Hostname auf '$new_hostname'...${NC}"
            sudo hostnamectl set-hostname "$new_hostname"
            echo -e "${GREEN}✓${NC} Hostname geändert"
            echo
        fi
    fi
fi

# Reload configurations
echo -e "${GREEN}Lade Konfigurationen neu...${NC}"

# Reload Niri
niri msg action load-config-file 2>/dev/null || true

# Reload Waybar
WAYBAR_PID=$(pgrep -x waybar)
if [ -n "$WAYBAR_PID" ]; then
    kill -SIGUSR2 $WAYBAR_PID 2>/dev/null || true
fi

# Reload Mako
MAKO_PID=$(pgrep -x mako)
if [ -n "$MAKO_PID" ]; then
    kill -SIGUSR1 $MAKO_PID 2>/dev/null || true
fi

echo -e "${GREEN}✓${NC} Neu geladen"
echo

# Cleanup
rm -rf "$INSTALL_DIR"

echo
echo -e "${GREEN}================================================"
echo "  Apollo OS erfolgreich aktualisiert! ✓"
echo -e "================================================${NC}"
echo
echo -e "${BLUE}Backup: $BACKUP_DIR${NC}"
echo

read -p "Drücke Enter zum Beenden..."

