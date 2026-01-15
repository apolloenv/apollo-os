#!/usr/bin/env bash

#####################################################################
# Apollo OS - Update Script v1.0.1
# Copyright © 2026 by Manuel Kraibacher
#
# Description: Updates Apollo OS from GitHub with full package check
#####################################################################

set -e

REPO_URL="https://github.com/apolloenv/apollo-os.git"
INSTALL_DIR="$HOME/apollo-os-update"
BRANCH="main"
VERSION="v1.0.1"

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

echo -e "${BLUE}================================================"
echo "  Apollo OS Update to $VERSION"
echo -e "================================================${NC}"
echo

# Check if git is installed
if ! command -v git &>/dev/null; then
    error "git is not installed"
    exit 1
fi

# Remove old update directory
if [ -d "$INSTALL_DIR" ]; then
    log "Removing old update directory..."
    rm -rf "$INSTALL_DIR"
fi

# Clone latest version
log "Downloading latest version from GitHub..."
git clone --depth 1 --branch "$BRANCH" "$REPO_URL" "$INSTALL_DIR" || {
    error "Failed to clone repository"
    exit 1
}

# Find the v1.0.1 directory
if [ ! -d "$INSTALL_DIR/v1.0.1" ]; then
    error "v1.0.1 directory not found in repository"
    exit 1
fi

UPDATE_SOURCE="$INSTALL_DIR/v1.0.1"

log "Found Apollo OS $VERSION ✓"
echo

# Create backup
log "Creating backup..."
BACKUP_DIR="$HOME/.config/apollo-os-backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP_DIR"

for dir in niri waybar mako rofi alacritty; do
    [ -d "$HOME/.config/$dir" ] && cp -r "$HOME/.config/$dir" "$BACKUP_DIR/"
done

log "Backup created: $BACKUP_DIR ✓"
echo

# Update configurations
log "Updating configurations..."

# Niri configs (6 variants)
for config in config.kdl config-classic.kdl config-developer.kdl config-modern.kdl config-orbit.kdl config-professional.kdl; do
    if [ -f "$UPDATE_SOURCE/config-data/niri/$config" ]; then
        cp "$UPDATE_SOURCE/config-data/niri/$config" "$HOME/.config/niri/"
    fi
done

# Niri scripts
for script in "$UPDATE_SOURCE/config-data/niri/"*.sh; do
    [ -f "$script" ] && cp "$script" "$HOME/.config/niri/" && chmod +x "$HOME/.config/niri/$(basename "$script")"
done

# Waybar configs (6 variants + styles)
for config in config-niri config-niri-classic config-niri-developer config-niri-modern config-niri-orbit config-niri-professional; do
    if [ -f "$UPDATE_SOURCE/config-data/waybar/$config" ]; then
        cp "$UPDATE_SOURCE/config-data/waybar/$config" "$HOME/.config/waybar/"
    fi
done

for style in style.css style-classic.css style-developer.css style-modern.css style-orbit.css style-professional.css hide-bottom.css; do
    if [ -f "$UPDATE_SOURCE/config-data/waybar/$style" ]; then
        cp "$UPDATE_SOURCE/config-data/waybar/$style" "$HOME/.config/waybar/"
    fi
done

# Other configs
[ -f "$UPDATE_SOURCE/config-data/mako/apollo-os-mako-config" ] && cp "$UPDATE_SOURCE/config-data/mako/apollo-os-mako-config" "$HOME/.config/mako/config"
[ -f "$UPDATE_SOURCE/config-data/rofi/config.rasi" ] && cp "$UPDATE_SOURCE/config-data/rofi/config.rasi" "$HOME/.config/rofi/"
[ -f "$UPDATE_SOURCE/config-data/alacritty/apollo-os-alacritty.toml" ] && cp "$UPDATE_SOURCE/config-data/alacritty/apollo-os-alacritty.toml" "$HOME/.config/alacritty/alacritty.toml"

# GTK configs
[ -f "$UPDATE_SOURCE/config-data/gtk-3.0-settings.ini" ] && cp "$UPDATE_SOURCE/config-data/gtk-3.0-settings.ini" "$HOME/.config/gtk-3.0/settings.ini"
[ -f "$UPDATE_SOURCE/config-data/gtk-4.0-settings.ini" ] && cp "$UPDATE_SOURCE/config-data/gtk-4.0-settings.ini" "$HOME/.config/gtk-4.0/settings.ini"

log "Configurations updated ✓"
echo

# Update scripts
log "Updating scripts..."
mkdir -p "$HOME/.local/bin"

for script in "$UPDATE_SOURCE/scripts/"*.sh; do
    if [ -f "$script" ]; then
        cp "$script" "$HOME/.local/bin/"
        chmod +x "$HOME/.local/bin/$(basename "$script")"
    fi
done

log "Scripts updated ✓"
echo

# Update desktop entries
log "Updating desktop entries..."
mkdir -p "$HOME/.local/share/applications"

if [ -d "$UPDATE_SOURCE/config-data/applications" ]; then
    cp "$UPDATE_SOURCE/config-data/applications/"*.desktop "$HOME/.local/share/applications/" 2>/dev/null || true
    update-desktop-database "$HOME/.local/share/applications" 2>/dev/null || true
fi

log "Desktop entries updated ✓"
echo

# Check for missing packages (v1.0.1 additions)
log "Checking for missing packages..."

# Docker
if ! command -v docker &>/dev/null; then
    warn "Docker not found. Install manually or run full installation."
fi

# Winboat
if ! command -v winboat &>/dev/null; then
    warn "Winboat not found. Install manually from https://github.com/TibixDev/winboat/releases"
fi

# zsh
if ! command -v zsh &>/dev/null; then
    log "Installing zsh..."
    sudo dnf install -y zsh || warn "zsh installation failed"
fi

# Neovim
if ! command -v nvim &>/dev/null; then
    log "Installing neovim..."
    sudo dnf install -y neovim || warn "neovim installation failed"
fi

# VLC
if ! command -v vlc &>/dev/null; then
    log "Installing VLC..."
    sudo dnf install -y vlc || warn "VLC installation failed"
fi

# Qt Wayland
if ! rpm -q qt5-qtwayland &>/dev/null; then
    log "Installing Qt Wayland support..."
    sudo dnf install -y qt5-qtwayland qt6-qtwayland || warn "Qt Wayland installation failed"
fi

log "Package check complete ✓"
echo

# Check Flatpak apps
log "Checking Flatpak applications..."

if command -v flatpak &>/dev/null; then
    # Add a few essential apps if missing
    flatpak list --app | grep -q "org.gimp.GIMP" || {
        log "Installing GIMP..."
        flatpak install -y flathub org.gimp.GIMP 2>/dev/null || warn "GIMP installation failed"
    }
    
    flatpak list --app | grep -q "org.onlyoffice.desktopeditors" || {
        log "Installing OnlyOffice..."
        flatpak install -y flathub org.onlyoffice.desktopeditors 2>/dev/null || warn "OnlyOffice installation failed"
    }
    
    log "Flatpak check complete ✓"
else
    warn "Flatpak not available. Run full installation for all apps."
fi

echo

# Create Screenshots directory
mkdir -p "$HOME/Screenshots"
log "Screenshots directory ensured ✓"
echo

# Reload configurations
log "Reloading configurations..."

# Reload Waybar
pkill -SIGUSR2 waybar 2>/dev/null || true

# Restart Mako
pkill mako 2>/dev/null || true
sleep 0.5
mako --config "$HOME/.config/mako/config" &>/dev/null & disown

# Apply GTK theme
gsettings set org.gnome.desktop.interface gtk-theme 'adw-gtk3-dark' 2>/dev/null || true
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark' 2>/dev/null || true

log "Configurations reloaded ✓"
echo

# Cleanup
rm -rf "$INSTALL_DIR"

echo
echo -e "${GREEN}================================================"
echo "  Apollo OS updated to $VERSION! ✓"
echo -e "================================================${NC}"
echo
echo -e "${BLUE}Backup location:${NC} $BACKUP_DIR"
echo
echo -e "${YELLOW}Note:${NC}"
echo "• Log out and log back in for all changes to take effect"
echo "• For complete v1.0.1 features, consider running full installation"
echo "• New features: Alt+Enter in launcher for web search"
echo "• Super+C toggles window centering"
echo
read -p "Press Enter to continue..."
