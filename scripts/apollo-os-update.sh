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

# TTS function - runs synchronously to ensure audio completes
tts_notify() {
    local script="$HOME/.local/bin/apollo-os-tts-notify.sh"
    [ -x "$script" ] && "$script" "$@"
}

echo -e "${BLUE}================================================"
echo "  Apollo OS - Automatisches Update"
echo -e "================================================${NC}"
echo

# TTS: Update started
tts_notify update-start

# Check if git is installed
if ! command -v git &>/dev/null; then
    echo -e "${RED}Error: git ist nicht installiert${NC}"
    tts_notify update-failed
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
    tts_notify update-failed
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
cp "$INSTALL_DIR/config-data/niri/apollo-os-niri-config.kdl" "$HOME/.config/niri/config-classic.kdl"
cp "$INSTALL_DIR/config-data/niri/apollo-os-niri-config-modern.kdl" "$HOME/.config/niri/config-modern.kdl"
cp "$INSTALL_DIR/config-data/waybar/apollo-os-waybar-config" "$HOME/.config/waybar/config-niri"
cp "$INSTALL_DIR/config-data/waybar/apollo-os-waybar-config" "$HOME/.config/waybar/config-niri-classic"
cp "$INSTALL_DIR/config-data/waybar/apollo-os-waybar-config-modern" "$HOME/.config/waybar/config-niri-modern"
cp "$INSTALL_DIR/config-data/waybar/apollo-os-waybar-style.css" "$HOME/.config/waybar/style.css"
cp "$INSTALL_DIR/config-data/waybar/apollo-os-waybar-style.css" "$HOME/.config/waybar/style-classic.css"
cp "$INSTALL_DIR/config-data/waybar/apollo-os-waybar-style-modern.css" "$HOME/.config/waybar/style-modern.css"
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

# Update desktop entries (for Niri compatibility)
echo -e "${GREEN}Aktualisiere Desktop-Einträge...${NC}"
mkdir -p "$HOME/.local/share/applications"
if [ -d "$INSTALL_DIR/config-data/applications" ]; then
    cp "$INSTALL_DIR/config-data/applications/"*.desktop "$HOME/.local/share/applications/" 2>/dev/null || true
    update-desktop-database "$HOME/.local/share/applications" 2>/dev/null || true
fi
echo -e "${GREEN}✓${NC} Desktop-Einträge aktualisiert"
echo

# Install/Update LUNA TTS voice if not present
VOICE_DIR="$HOME/.local/share/apollo-os/voices"
if [ ! -f "$VOICE_DIR/luna.onnx" ]; then
    echo -e "${GREEN}Installiere LUNA TTS Stimme...${NC}"
    mkdir -p "$VOICE_DIR"
    VOICE_URL="https://huggingface.co/rhasspy/piper-voices/resolve/v1.0.0/en/en_GB/jenny_dioco/medium"
    wget -q --show-progress -O "$VOICE_DIR/luna.onnx" "$VOICE_URL/en_GB-jenny_dioco-medium.onnx" 2>/dev/null || true
    wget -q --show-progress -O "$VOICE_DIR/luna.onnx.json" "$VOICE_URL/en_GB-jenny_dioco-medium.onnx.json" 2>/dev/null || true
    echo -e "${GREEN}✓${NC} LUNA Stimme installiert"
    echo
fi

# Install/Update additional applications
echo -e "${GREEN}Prüfe und installiere zusätzliche Anwendungen...${NC}"

# Browsers
command -v google-chrome-stable &>/dev/null || {
    echo "Installiere Google Chrome..."
    sudo dnf install -y fedora-workstation-repositories 2>/dev/null || true
    sudo dnf config-manager setopt google-chrome.enabled=1 2>/dev/null || sudo dnf config-manager --set-enabled google-chrome 2>/dev/null || true
    sudo dnf install -y google-chrome-stable 2>/dev/null || echo "Chrome übersprungen"
}

command -v microsoft-edge-stable &>/dev/null || {
    echo "Installiere Microsoft Edge..."
    sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc 2>/dev/null || true
    sudo bash -c 'cat > /etc/yum.repos.d/microsoft-edge.repo << EOF
[microsoft-edge]
name=Microsoft Edge
baseurl=https://packages.microsoft.com/yumrepos/edge
enabled=1
gpgcheck=1
gpgkey=https://packages.microsoft.com/keys/microsoft.asc
EOF'
    sudo dnf install -y microsoft-edge-stable 2>/dev/null || echo "Edge übersprungen"
}

# Development Tools
command -v code &>/dev/null || {
    echo "Installiere Visual Studio Code..."
    sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc 2>/dev/null || true
    sudo bash -c 'cat > /etc/yum.repos.d/vscode.repo << EOF
[code]
name=Visual Studio Code
baseurl=https://packages.microsoft.com/yumrepos/vscode
enabled=1
gpgcheck=1
gpgkey=https://packages.microsoft.com/keys/microsoft.asc
EOF'
    sudo dnf install -y code 2>/dev/null || echo "VS Code übersprungen"
}

# Node.js and npm
command -v npm &>/dev/null || {
    echo "Installiere Node.js und npm..."
    sudo dnf install -y nodejs npm 2>/dev/null || echo "Node.js übersprungen"
}

# CLI AI Tools (only if npm is available)
if command -v npm &>/dev/null; then
    echo "Prüfe CLI AI Tools..."
    npm list -g @google/gemini-cli &>/dev/null || sudo npm install -g @google/gemini-cli 2>/dev/null || true
    npm list -g @anthropic-ai/claude-code &>/dev/null || sudo npm install -g @anthropic-ai/claude-code 2>/dev/null || true
    npm list -g opencode-ai &>/dev/null || sudo npm install -g opencode-ai 2>/dev/null || true
    npm list -g @github/copilot &>/dev/null || sudo npm install -g @github/copilot 2>/dev/null || true
fi

# FileZilla
command -v filezilla &>/dev/null || {
    echo "Installiere FileZilla..."
    sudo dnf install -y filezilla 2>/dev/null || echo "FileZilla übersprungen"
}

# Remmina with VNC plugin
rpm -q remmina-plugins-vnc &>/dev/null || {
    echo "Installiere Remmina mit VNC..."
    sudo dnf install -y remmina remmina-plugins-vnc 2>/dev/null || echo "Remmina übersprungen"
}

# Steam
command -v steam &>/dev/null || {
    echo "Installiere Steam..."
    sudo dnf install -y steam 2>/dev/null || echo "Steam übersprungen"
}

# Synology Drive
command -v synology-drive &>/dev/null || {
    echo "Installiere Synology Drive..."
    sudo dnf copr enable -y emixampp/synology-drive 2>/dev/null || true
    sudo dnf install -y synology-drive 2>/dev/null || echo "Synology Drive übersprungen"
}

# Tailscale
command -v tailscale &>/dev/null || {
    echo "Installiere Tailscale..."
    curl -fsSL https://tailscale.com/install.sh | sh 2>/dev/null || echo "Tailscale übersprungen"
    sudo systemctl enable --now tailscaled 2>/dev/null || true
}

echo -e "${GREEN}✓${NC} Anwendungen geprüft"
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

# Reload Waybar
WAYBAR_PID=$(pgrep -x waybar)
if [ -n "$WAYBAR_PID" ]; then
    kill -SIGUSR2 $WAYBAR_PID 2>/dev/null || true
fi

# Restart Mako (reload doesn't work properly, restart needed)
MAKO_PID=$(pgrep -x mako)
if [ -n "$MAKO_PID" ]; then
    kill $MAKO_PID 2>/dev/null || true
    sleep 1
fi
mako --config "$HOME/.config/mako/config" &>/dev/null &
sleep 1

# Apply GTK dark theme via gsettings
gsettings set org.gnome.desktop.interface gtk-theme 'adw-gtk3-dark' 2>/dev/null
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark' 2>/dev/null

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

# TTS: Update complete
tts_notify update-complete

read -p "Drücke Enter zum Beenden..."

