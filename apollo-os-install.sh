#!/bin/bash

#####################################################################
# Apollo OS - Master Installer v0.5.0
# Copyright © 2026 by Manuel Kraibacher
#
# Description: Apollo OS Enterprise Installation System
# Platform: Linux x86_64
# Window Manager: Apollo OS Orbit (Scrollable Tiling)
#
# v0.5.0 Changes:
# - Apollo OS Orbit-only installation (Sway removed)
# - Simplified configuration (PRO Dark theme only)
# - AI integration removed (Gemini/Ollama)
# - Plymouth spinner theme with custom watermark
# - GTK dark theme support for Apollo OS Orbit
# - Piper TTS with LUNA voice (en_GB-jenny_dioco-medium)
# - Login greeting notification with time-based message
#####################################################################

set -e  # Exit on error

# Color Codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_LOG="/tmp/apollo-os-install.log"
CONFIG_FILE="$HOME/.config/apollo-os/config.env"

#####################################################################
# Helper Functions
#####################################################################

print_banner() {
    clear
    echo -e "${CYAN}"
    cat "$SCRIPT_DIR/assets/apollo-os-boot-logo.txt" 2>/dev/null || echo "APOLLO OS"
    echo -e "${NC}"
    echo -e "${MAGENTA}═══════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}  Apollo OS Installer v0.5.0${NC}"
    echo -e "${YELLOW}  APOLLO OS Enterprise Edition${NC}"
    echo -e "${MAGENTA}═══════════════════════════════════════════════════════${NC}\n"
}

log() {
    echo -e "${GREEN}[INFO]${NC} $1" | tee -a "$INSTALL_LOG"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1" | tee -a "$INSTALL_LOG"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1" | tee -a "$INSTALL_LOG"
    exit 1
}

prompt_user() {
    local prompt="$1"
    local var_name="$2"
    echo -e "${CYAN}$prompt${NC}"
    read -r "$var_name"
}

prompt_password() {
    local prompt="$1"
    local var_name="$2"
    echo -e "${CYAN}$prompt${NC}"
    read -rs "$var_name"
    echo
}

#####################################################################
# Pre-flight Checks
#####################################################################

check_system() {
    log "Running system checks..."

    # Check if Fedora
    if [[ ! -f /etc/fedora-release ]]; then
        error "This installer requires a compatible Linux distribution"
    fi

    # Check Fedora version
    FEDORA_VERSION=$(rpm -E %fedora)
    if [[ "$FEDORA_VERSION" != "43" ]]; then
        warn "This installer is optimized for system version 43. Current version: $FEDORA_VERSION"
        read -p "Continue anyway? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi

    # Check if running as regular user (not root)
    if [[ "$EUID" -eq 0 ]]; then
        error "Please run this installer as a regular user, not as root"
    fi

    # Check sudo access
    if ! sudo -n true 2>/dev/null; then
        log "This installer requires sudo privileges. You may be prompted for your password."
        sudo -v || error "Failed to obtain sudo privileges"
    fi

    # Check internet connection
    if ! ping -c 1 8.8.8.8 &>/dev/null; then
        error "No internet connection detected. Please connect to the internet and try again."
    fi

    log "System checks passed ✓"
}

#####################################################################
# User Configuration
#####################################################################

gather_user_config() {
    log "Gathering user configuration..."

    echo
    echo -e "${MAGENTA}══════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}  Apollo OS Configuration${NC}"
    echo -e "${MAGENTA}══════════════════════════════════════════════════════${NC}\n"

    # Telegram Configuration (optional)
    echo -e "${YELLOW}Telegram Bot Configuration (Optional)${NC}"
    echo "Apollo OS can send notifications via Telegram."
    echo "Create a bot via @BotFather on Telegram."
    echo -e "${CYAN}(Press Enter to skip and configure later)${NC}"
    prompt_password "Enter Telegram Bot Token (will be hidden): " TELEGRAM_BOT_TOKEN
    prompt_user "Enter your Telegram User ID: " TELEGRAM_USER_ID

    # Save configuration
    mkdir -p "$HOME/.config/apollo-os"
    cat > "$CONFIG_FILE" <<EOF
# Apollo OS Configuration
# Generated on $(date)
# Edit this file to update your settings

# Telegram Configuration (Optional)
TELEGRAM_BOT_TOKEN="$TELEGRAM_BOT_TOKEN"
TELEGRAM_USER_ID="$TELEGRAM_USER_ID"

# System Configuration
WALLPAPER_DIR="$HOME/System/Wallpaper"
DEFAULT_WM="niri"
DEFAULT_PROFILE="pro"
DEFAULT_THEME="dark"
EOF

    chmod 600 "$CONFIG_FILE"
    log "Configuration saved to $CONFIG_FILE ✓"

    if [[ -z "$TELEGRAM_BOT_TOKEN" ]]; then
        echo
        echo -e "${YELLOW}⚠️  Note: Telegram configuration is empty.${NC}"
        echo -e "${YELLOW}   You can add it later by editing:${NC}"
        echo -e "${CYAN}   $CONFIG_FILE${NC}"
        echo
    fi
}

#####################################################################
# Package Installation
#####################################################################

install_packages() {
    log "Installing required packages..."

    echo
    echo -e "${MAGENTA}══════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}  Package Installation${NC}"
    echo -e "${MAGENTA}══════════════════════════════════════════════════════${NC}\n"

    # Update system
    log "Updating system packages..."
    sudo dnf upgrade -y --refresh

    # Refresh sudo before next operation (system update can take 20+ minutes)
    log "Refreshing sudo credentials..."
    sudo -v

    # Enable RPM Fusion
    log "Enabling RPM Fusion repositories..."
    sudo dnf install -y https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
    sudo dnf install -y https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

    # Install COPR repositories for Niri
    log "Enabling COPR repositories..."
    sudo -v  # Refresh sudo
    sudo dnf copr enable -y errornix/niri || warn "Failed to enable niri COPR repo (will try from standard repos)"

    # Refresh DNF cache after adding repos
    sudo dnf makecache --refresh

    # Core Window Manager & Wayland
    log "Installing Apollo OS Orbit Window Manager..."
    sudo -v  # Refresh sudo

    # Install Wayland components
    sudo dnf install -y wayland-protocols wayland-devel || warn "Wayland dev packages failed"

    # Install Niri
    if ! command -v niri &>/dev/null; then
        log "Installing Apollo OS Orbit Window Manager..."
        sudo dnf install -y niri || error "Apollo OS Orbit installation failed"
    else
        log "Apollo OS Orbit already installed ✓"
    fi

    # Install Waybar
    sudo dnf install -y waybar || error "Waybar installation failed"

    # UI Components
    log "Installing UI components..."
    sudo -v  # Refresh sudo

    # Critical UI components
    sudo dnf install -y rofi mako grim slurp wl-clipboard swaylock swaybg swayidle || error "Critical UI components failed"

    # Terminal Emulators
    log "Installing terminal emulators..."
    sudo dnf install -y \
        alacritty \
        kitty \
        || warn "Terminal installation failed"

    # System Tools
    log "Installing system tools..."
    sudo dnf install -y \
        NetworkManager \
        nm-connection-editor \
        pavucontrol \
        playerctl \
        power-profiles-daemon \
        btop \
        fastfetch \
        jq \
        wget \
        unzip \
        || warn "Some system tools failed to install"
    
    # Critical UI tools (separate to ensure installation)
    log "Installing critical UI tools..."
    sudo dnf install -y blueman brightnessctl || error "Critical tools (blueman, brightnessctl) failed to install"

    # Fonts
    log "Installing fonts..."
    sudo dnf install -y \
        jetbrains-mono-fonts-all \
        google-noto-emoji-fonts \
        fontawesome-fonts \
        google-noto-sans-fonts \
        fira-code-fonts \
        || warn "Some fonts failed to install"

    # GTK Themes
    log "Installing GTK themes..."
    sudo dnf install -y \
        adw-gtk3-theme \
        gnome-themes-extra \
        || warn "GTK theme installation failed"

    # Install JetBrainsMono Nerd Font (for icons in Waybar)
    log "Installing JetBrainsMono Nerd Font..."
    if [[ ! -d "$HOME/.local/share/fonts/JetBrainsMonoNerdFont" ]]; then
        mkdir -p /tmp/nerdfonts
        cd /tmp/nerdfonts
        wget -q https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/JetBrainsMono.zip || warn "Nerd Font download failed"
        if [[ -f JetBrainsMono.zip ]]; then
            unzip -q JetBrainsMono.zip -d JetBrainsMono
            mkdir -p "$HOME/.local/share/fonts"
            cp JetBrainsMono/*.ttf "$HOME/.local/share/fonts/"
            fc-cache -f
            log "JetBrainsMono Nerd Font installed ✓"
        fi
        cd - >/dev/null
    else
        log "JetBrainsMono Nerd Font already installed ✓"
    fi

    log "Package installation complete ✓"
}

#####################################################################
# Configure User Permissions
#####################################################################

configure_user_permissions() {
    log "Configuring user permissions..."
    
    # Add user to video group for brightness control
    if ! groups | grep -q video; then
        log "Adding user to 'video' group for brightness control..."
        sudo usermod -aG video "$USER" || warn "Failed to add user to video group"
    else
        log "User already in 'video' group ✓"
    fi
    
    # Add user to input group for input device access
    if ! groups | grep -q input; then
        log "Adding user to 'input' group..."
        sudo usermod -aG input "$USER" || warn "Failed to add user to input group"
    else
        log "User already in 'input' group ✓"
    fi
    
    # Create udev rule for brightness control without sudo
    log "Creating udev rules for brightness control..."
    sudo bash -c 'cat > /etc/udev/rules.d/90-backlight.rules' << 'EOF'
# Allow users in video group to control backlight
ACTION=="add", SUBSYSTEM=="backlight", RUN+="/bin/chgrp video /sys/class/backlight/%k/brightness"
ACTION=="add", SUBSYSTEM=="backlight", RUN+="/bin/chmod g+w /sys/class/backlight/%k/brightness"
EOF
    
    # Reload udev rules
    sudo udevadm control --reload-rules || warn "Failed to reload udev rules"
    sudo udevadm trigger --subsystem-match=backlight || warn "Failed to trigger backlight subsystem"
    
    log "User permissions configured ✓"
    log "NOTE: You may need to log out and log back in for group changes to take effect"
}

#####################################################################
# Verify Critical Packages
#####################################################################

verify_critical_packages() {
    log "Verifying critical packages..."

    local missing=()
    local critical_packages=(
        "niri"
        "waybar"
        "rofi"
        "mako"
    )

    for pkg in "${critical_packages[@]}"; do
        if ! command -v "$pkg" &>/dev/null; then
            missing+=("$pkg")
        fi
    done

    if [ ${#missing[@]} -gt 0 ]; then
        warn "Missing critical packages: ${missing[*]}"
        log "Attempting to install missing packages..."

        # Try to install missing packages
        for pkg in "${missing[@]}"; do
            sudo dnf install -y "$pkg" || warn "Could not install $pkg"
        done

        # Verify again
        missing=()
        for pkg in "${critical_packages[@]}"; do
            if ! command -v "$pkg" &>/dev/null; then
                missing+=("$pkg")
            fi
        done

        if [ ${#missing[@]} -gt 0 ]; then
            error "Critical packages still missing after retry: ${missing[*]}"
        fi
    fi

    log "Critical package verification passed ✓"
}

#####################################################################
# Configuration Deployment
#####################################################################

deploy_configs() {
    log "Deploying configuration files..."

    # Create necessary directories
    mkdir -p "$HOME/.config/niri"
    mkdir -p "$HOME/.config/waybar"
    mkdir -p "$HOME/.config/mako"
    mkdir -p "$HOME/.config/rofi"
    mkdir -p "$HOME/.config/gtk-3.0"
    mkdir -p "$HOME/.config/gtk-4.0"
    mkdir -p "$HOME/.config/xdg-desktop-portal"
    mkdir -p "$HOME/.local/bin"

    # Deploy GTK Theme configs (Dark mode)
    log "Deploying GTK theme configurations..."
    cp "$SCRIPT_DIR/config-data/gtk-3.0-settings.ini" "$HOME/.config/gtk-3.0/settings.ini" || warn "GTK-3.0 config failed"
    cp "$SCRIPT_DIR/config-data/gtk-4.0-settings.ini" "$HOME/.config/gtk-4.0/settings.ini" || warn "GTK-4.0 config failed"

    # Create GTK-2.0 config
    cat > "$HOME/.gtkrc-2.0" << 'GTKEOF'
gtk-theme-name="adw-gtk3-dark"
gtk-icon-theme-name="Adwaita"
gtk-font-name="Cantarell 11"
gtk-cursor-theme-name="Adwaita"
gtk-cursor-theme-size=24
GTKEOF

    # Create XDG Portal config for Apollo OS Orbit
    cat > "$HOME/.config/xdg-desktop-portal/niri-portals.conf" << 'PORTALEOF'
[preferred]
default=gtk
org.freedesktop.impl.portal.Settings=gtk
org.freedesktop.impl.portal.Screenshot=wlr
org.freedesktop.impl.portal.ScreenCast=wlr
PORTALEOF

    # Deploy Apollo OS Orbit config
    log "Deploying Apollo OS Orbit configuration..."
    cp "$SCRIPT_DIR/config-data/niri/apollo-os-niri-config.kdl" "$HOME/.config/niri/config.kdl" || warn "Apollo OS Orbit config deployment failed"
    cp "$SCRIPT_DIR/config-data/niri/apollo-autostart.sh" "$HOME/.config/niri/" || warn "Apollo OS Orbit autostart deployment failed"

    # Make autostart executable
    chmod +x "$HOME/.config/niri/apollo-autostart.sh" 2>/dev/null

    # Add GTK_THEME and portal to Apollo OS Orbit config
    if [ -f "$HOME/.config/niri/config.kdl" ]; then
        # Add autostart if not present
        if ! grep -q "apollo-autostart.sh" "$HOME/.config/niri/config.kdl"; then
            sed -i '/spawn-at-startup.*polkit/a spawn-at-startup "~/.config/niri/apollo-autostart.sh" // Apollo OS Services' "$HOME/.config/niri/config.kdl"
        fi
        # Add portal if not present
        if ! grep -q "xdg-desktop-portal-gtk" "$HOME/.config/niri/config.kdl"; then
            sed -i '/spawn-at-startup.*polkit/a spawn-at-startup "/usr/libexec/xdg-desktop-portal-gtk" // GTK Portal for dark theme' "$HOME/.config/niri/config.kdl"
        fi
        # Add GTK_THEME environment if not present
        if ! grep -q "GTK_THEME" "$HOME/.config/niri/config.kdl"; then
            sed -i 's/environment {/environment {\n    GTK_THEME "adw-gtk3-dark"\n    ADW_DEBUG_COLOR_SCHEME "prefer-dark"/' "$HOME/.config/niri/config.kdl"
        fi
    fi

    # Deploy Waybar configs
    log "Deploying Waybar configurations..."
    cp "$SCRIPT_DIR/config-data/waybar/apollo-os-waybar-config" "$HOME/.config/waybar/config-niri" || warn "Waybar config deployment failed"
    cp "$SCRIPT_DIR/config-data/waybar/apollo-os-waybar-style.css" "$HOME/.config/waybar/style.css" || warn "Waybar style deployment failed"
    
    # Create hide-bottom.css for waybar toggle feature
    touch "$HOME/.config/waybar/hide-bottom.css" || warn "hide-bottom.css creation failed"

    # Deploy Mako config
    log "Deploying Mako configuration..."
    cp "$SCRIPT_DIR/config-data/mako/apollo-os-mako-config" "$HOME/.config/mako/config" || warn "Mako config deployment failed"

    # Deploy Rofi theme
    log "Deploying Rofi theme..."
    cp "$SCRIPT_DIR/config-data/rofi/apollo-os-rofi-theme.rasi" "$HOME/.config/rofi/config.rasi" || warn "Rofi config deployment failed"

    # Deploy Alacritty config
    log "Deploying Alacritty configuration..."
    mkdir -p "$HOME/.config/alacritty"
    cp "$SCRIPT_DIR/config-data/alacritty/apollo-os-alacritty.toml" "$HOME/.config/alacritty/alacritty.toml" || warn "Alacritty config deployment failed"

    log "Configuration deployment complete ✓"
}

#####################################################################
# Copy Plymouth Watermark
#####################################################################

copy_plymouth_watermark() {
    log "Installing Plymouth watermark..."
    
    local watermark_source="$SCRIPT_DIR/assets/spinner/watermark.png"
    local watermark_target="/usr/share/plymouth/themes/spinner/watermark.png"
    
    # Check if watermark source exists
    if [[ ! -f "$watermark_source" ]]; then
        warn "Watermark source not found: $watermark_source"
        return 1
    fi
    
    # Check if Plymouth spinner theme directory exists
    if [[ ! -d /usr/share/plymouth/themes/spinner ]]; then
        warn "Plymouth spinner theme directory not found, skipping watermark installation"
        return 0
    fi
    
    # Backup existing watermark if present
    if [[ -f "$watermark_target" ]]; then
        log "Backing up existing watermark..."
        sudo cp "$watermark_target" "${watermark_target}.backup.$(date +%Y%m%d)" || warn "Failed to backup watermark"
    fi
    
    # Copy Apollo OS watermark
    log "Copying Apollo OS watermark to Plymouth..."
    sudo cp "$watermark_source" "$watermark_target" || {
        warn "Failed to copy watermark"
        return 1
    }
    
    # Set correct permissions
    sudo chmod 644 "$watermark_target"
    sudo chown root:root "$watermark_target"
    
    log "Plymouth watermark installed ✓"
    log "Watermark: $watermark_target"
    
    return 0
}

#####################################################################
# Script Installation
#####################################################################

install_scripts() {
    log "Installing Apollo OS scripts..."

    # Copy scripts to local bin (excluding AI scripts)
    for script in "$SCRIPT_DIR/scripts/"*.sh; do
        if [ -f "$script" ]; then
            cp "$script" "$HOME/.local/bin/" || warn "Failed to copy $(basename "$script")"
        fi
    done

    # Make scripts executable
    chmod +x "$HOME/.local/bin/apollo-"* 2>/dev/null || true
    chmod +x "$HOME/.local/bin/apollo-os-"* 2>/dev/null || true

    # Install wrapper script to /usr/local/bin/ (needed for GDM)
    log "Installing wrapper script globally..."
    sudo cp "$HOME/.local/bin/apollo-os-wrapper-niri.sh" /usr/local/bin/ || warn "Failed to install niri wrapper globally"
    sudo chmod +x /usr/local/bin/apollo-os-wrapper-niri.sh

    # Create symlinks for convenience
    ln -sf "$HOME/.local/bin/apollo-speak.sh" "$HOME/.local/bin/apollo-speak" || warn "Failed to create apollo-speak symlink"
    ln -sf "$HOME/.local/bin/apollo-os-event-monitor.sh" "$HOME/.local/bin/apollo-event-monitor" || warn "Failed to create apollo-event-monitor symlink"

    log "Scripts installed ✓"
}

#####################################################################
# Desktop Entries for WM Sessions
#####################################################################

install_desktop_entries() {
    # Note: Session entry is created in configure_login_manager()
    # This function is kept for compatibility but does nothing
    # Apollo OS Orbit is the only session and is configured system-wide
    log "Session entries will be configured in login manager setup ✓"
}

#####################################################################
# Systemd Services
#####################################################################

setup_systemd() {
    log "Setting up systemd services..."

    mkdir -p "$HOME/.config/systemd/user"

    # Copy systemd units (excluding boot splash and AI daemon)
    for file in "$SCRIPT_DIR/systemd/"*.service "$SCRIPT_DIR/systemd/"*.timer; do
        if [ -f "$file" ]; then
            local filename="$(basename "$file")"
            # Skip boot splash and AI daemon
            if [[ "$filename" != "apollo-boot-splash.service" && "$filename" != "apollo-os-daemon.service" ]]; then
                cp "$file" "$HOME/.config/systemd/user/" || warn "Failed to copy $filename"
            fi
        fi
    done

    # Reload systemd
    systemctl --user daemon-reload

    # Enable services (event monitor will be started by autostart script)
    # We don't enable it as systemd service to avoid race conditions
    # It starts after Apollo OS Orbit/Mako/Audio are ready
    
    log "Systemd services configured ✓"
}

#####################################################################
# Audio System Installation
#####################################################################

install_audio_system() {
    log "Installing Audio System (TTS)..."

    echo
    echo -e "${MAGENTA}══════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}  Audio System (Text-to-Speech)${NC}"
    echo -e "${MAGENTA}══════════════════════════════════════════════════════${NC}\n"

    # Install required packages (espeak-ng as fallback, audio utilities)
    log "Installing audio utilities..."
    sudo dnf install -y espeak-ng sox ffmpeg pulseaudio-utils alsa-utils || warn "Some audio packages failed"

    # Setup directories
    local PIPER_DIR="$HOME/.local/share/apollo-os/piper"
    local VOICE_DIR="$HOME/.local/share/apollo-os/voices"
    local SOUNDS_DIR="$HOME/.local/share/apollo-os/sounds"

    mkdir -p "$PIPER_DIR"
    mkdir -p "$VOICE_DIR"
    mkdir -p "$SOUNDS_DIR"

    # Download Piper TTS binary (not in Fedora repos)
    log "Downloading Piper TTS..."
    if [ ! -f "$PIPER_DIR/piper/piper" ]; then
        local piper_url="https://github.com/rhasspy/piper/releases/download/2023.11.14-2/piper_linux_x86_64.tar.gz"
        wget -q --show-progress -O "/tmp/piper.tar.gz" "$piper_url" || warn "Failed to download Piper"
        tar -xzf "/tmp/piper.tar.gz" -C "$PIPER_DIR" || warn "Failed to extract Piper"
        rm -f "/tmp/piper.tar.gz"
        ln -sf "$PIPER_DIR/piper/piper" "$HOME/.local/bin/piper"
    else
        log "Piper TTS already installed ✓"
    fi

    # Download LUNA voice model (en_GB-jenny_dioco-medium)
    log "Downloading LUNA voice model (~63 MB)..."
    if [ ! -f "$VOICE_DIR/luna.onnx" ]; then
        local voice_url="https://huggingface.co/rhasspy/piper-voices/resolve/v1.0.0/en/en_GB/jenny_dioco/medium"
        wget -q --show-progress \
            -O "$VOICE_DIR/luna.onnx" \
            "$voice_url/en_GB-jenny_dioco-medium.onnx" || warn "Failed to download voice model"
        wget -q --show-progress \
            -O "$VOICE_DIR/luna.onnx.json" \
            "$voice_url/en_GB-jenny_dioco-medium.onnx.json" || warn "Failed to download model config"
    else
        log "LUNA voice model already exists ✓"
    fi

    # Generate chime sound
    log "Generating chime sound (880Hz → 660Hz)..."
    if [ ! -f "$SOUNDS_DIR/chime.wav" ]; then
        ffmpeg -f lavfi -i "sine=frequency=880:duration=0.3" \
               -f lavfi -i "sine=frequency=660:duration=0.3" \
               -filter_complex "[0][1]concat=n=2:v=0:a=1" \
               -y "$SOUNDS_DIR/chime.wav" 2>/dev/null || warn "Failed to generate chime"
    fi

    log "Audio System installed ✓"
    echo -e "${GREEN}TTS Voice: LUNA (British English, Piper TTS)${NC}"
}

#####################################################################
# Wallpaper Setup
#####################################################################

setup_wallpapers() {
    log "Setting up wallpaper directory..."

    # Create wallpaper directory
    mkdir -p "$HOME/System/Wallpaper"

    # Copy wallpapers
    cp -r "$SCRIPT_DIR/assets/wallpapers/"* "$HOME/System/Wallpaper/" 2>/dev/null || warn "No wallpapers to copy"

    # Set default wallpaper symlink
    if [[ -f "$HOME/System/Wallpaper/Apollo-OS-01.png" ]]; then
        ln -sf "$HOME/System/Wallpaper/Apollo-OS-01.png" "$HOME/System/Wallpaper/current.jpg"
    fi

    log "Wallpaper directory ready ✓"
}

#####################################################################
# Login Manager Configuration (GDM)
#####################################################################

configure_login_manager() {
    log "Configuring GDM login manager..."

    echo
    echo -e "${MAGENTA}══════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}  Login Manager Configuration${NC}"
    echo -e "${MAGENTA}══════════════════════════════════════════════════════${NC}\n"

    # Configure GDM (clock with seconds)
    log "Configuring GDM appearance..."
    sudo mkdir -p /etc/dconf/db/gdm.d
    sudo bash -c 'cat > /etc/dconf/db/gdm.d/01-apollo << EOF
[org/gnome/login-screen]
logo=""

[org/gnome/desktop/interface]
clock-show-seconds=true
clock-show-date=false
EOF'
    sudo dconf update

    # Remove all other sessions - Apollo OS Orbit is the only option
    log "Removing all other sessions (Apollo OS Orbit-only)..."
    sudo rm -f /usr/share/wayland-sessions/gnome.desktop 2>/dev/null
    sudo rm -f /usr/share/wayland-sessions/gnome-wayland.desktop 2>/dev/null
    sudo rm -f /usr/share/wayland-sessions/gnome-classic.desktop 2>/dev/null
    sudo rm -f /usr/share/wayland-sessions/gnome-classic-wayland.desktop 2>/dev/null
    sudo rm -f /usr/share/wayland-sessions/sway.desktop 2>/dev/null

    # Configure Apollo OS Orbit as the only session
    log "Setting Apollo OS Orbit as default and only session..."
    sudo bash -c 'cat > /usr/share/wayland-sessions/niri.desktop << EOF
[Desktop Entry]
Name=Apollo OS
Comment=APOLLO OS Orbit Window Manager
Exec=/usr/local/bin/apollo-os-wrapper-niri.sh pro dark
Type=Application
DesktopNames=niri
EOF'

    # Note: Plymouth/Boot is not modified here - only watermark.png is replaced via assets
    # The default spinner theme remains unchanged

    log "GDM configured - Apollo OS Orbit is the only available session ✓"
}

#####################################################################
# Final Steps
#####################################################################

finalize_installation() {
    log "Finalizing installation..."

    # Add local bin to PATH if not already there
    if ! grep -q "$HOME/.local/bin" "$HOME/.bashrc"; then
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc"
        log "Added ~/.local/bin to PATH"
    fi

    # Cleanup installation files
    log "Cleaning up installation files..."
    if [ -d "$SCRIPT_DIR" ] && [ "$SCRIPT_DIR" != "$HOME" ]; then
        # Keep only wallpapers and essential files
        if [ -d "$SCRIPT_DIR/wallpapers" ]; then
            log "Preserving wallpapers..."
        fi
        
        # Remove installation scripts and temporary files
        rm -f "$SCRIPT_DIR/apollo-os-install.sh" 2>/dev/null || true
        rm -rf "$SCRIPT_DIR/config-data" 2>/dev/null || true
        rm -rf "$SCRIPT_DIR/scripts" 2>/dev/null || true
        rm -rf "$SCRIPT_DIR/assets" 2>/dev/null || true
        rm -rf "$SCRIPT_DIR/.git" 2>/dev/null || true
        rm -f "$SCRIPT_DIR/.gitignore" 2>/dev/null || true
        rm -f "$SCRIPT_DIR/README.md" 2>/dev/null || true
        
        log "Installation files cleaned up"
    fi

    # Print summary
    echo
    echo -e "${MAGENTA}══════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}  Installation Complete! ${NC}"
    echo -e "${MAGENTA}══════════════════════════════════════════════════════${NC}\n"

    echo -e "${CYAN}Next Steps:${NC}"
    echo "1. Log out of your current session"
    echo "2. Log in - Apollo OS starts automatically"
    echo
    echo -e "${YELLOW}Window Manager:${NC}"
    echo "  • APOLLO OS Orbit Window Manager (default and only session)"
    echo
    echo -e "${CYAN}Quick Commands:${NC}"
    echo "  apollo-speak <text>          - Text-to-Speech with LUNA voice"
    echo "  apollo-os-theme-switcher.sh  - Switch between light/dark themes"
    echo "  apollo-os-stats.sh           - System statistics"
    echo
    echo -e "${GREEN}Installation log saved to: $INSTALL_LOG${NC}"
    echo
}

#####################################################################
# Main Installation Flow
#####################################################################

main() {
    print_banner

    log "Starting Apollo OS installation..."
    log "Installation log: $INSTALL_LOG"

    check_system
    gather_user_config
    install_packages
    configure_user_permissions
    verify_critical_packages
    deploy_configs
    copy_plymouth_watermark
    install_scripts
    install_desktop_entries
    setup_systemd
    install_audio_system
    setup_wallpapers
    configure_login_manager
    finalize_installation

    echo -e "${GREEN}Apollo OS is ready! 🚀${NC}"
    echo
    read -p "Press Enter to continue..."
}

# Run main installation
main
