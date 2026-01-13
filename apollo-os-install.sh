#!/bin/bash

#####################################################################
# Apollo OS - Master Installer v0.4.5
# Copyright © 2026 by Manuel Kraibacher
#
# Description: Transforms Fedora 43 Workstation into Apollo OS
# Base: Fedora 43 Workstation (Gnome)
# Window Managers: Niri (Scrollable Tiling) & Sway (Classic Tiling)
#
# v0.4.5 Changes:
# - Switch from greetd/tuigreet to GDM (stability)
# - Plymouth spinner theme (no Fedora logo at boot)
# - GTK dark theme support for Niri and Sway
# - Session naming: GLASS (Waybar), PRO (minimal), DEV (standard)
# - Piper TTS with LUNA voice (en_GB-jenny_dioco-medium)
# - Login greeting notification with time-based message
# - Fixed mako config (quoted app-name)
# - Fixed TTS audio playback in autostart
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
    echo -e "${CYAN}  Apollo OS Installer v0.4.1${NC}"
    echo -e "${YELLOW}  Next-Generation Custom Layer for Fedora 43${NC}"
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
        error "This installer requires Fedora Linux"
    fi

    # Check Fedora version
    FEDORA_VERSION=$(rpm -E %fedora)
    if [[ "$FEDORA_VERSION" != "43" ]]; then
        warn "This installer is designed for Fedora 43. Current version: $FEDORA_VERSION"
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
    echo -e "${CYAN}  Apollo Intelligence Configuration${NC}"
    echo -e "${MAGENTA}══════════════════════════════════════════════════════${NC}\n"

    # Google Gemini API Key
    echo -e "${YELLOW}Google Gemini API Key${NC}"
    echo "Apollo OS uses Google Gemini for AI-powered interactions."
    echo "Get your API key from: https://makersuite.google.com/app/apikey"
    echo -e "${CYAN}(Press Enter to skip and configure later in ~/.config/apollo-os/config.env)${NC}"
    prompt_password "Enter Gemini API Key (will be hidden): " GEMINI_API_KEY

    echo
    # Telegram Configuration
    echo -e "${YELLOW}Telegram Bot Configuration${NC}"
    echo "Apollo OS can send notifications via Telegram."
    echo "Create a bot via @BotFather on Telegram."
    echo -e "${CYAN}(Press Enter to skip and configure later)${NC}"
    prompt_password "Enter Telegram Bot Token (will be hidden): " TELEGRAM_BOT_TOKEN
    prompt_user "Enter your Telegram User ID: " TELEGRAM_USER_ID

    echo
    # Ollama Configuration (Local LLM Fallback)
    echo -e "${YELLOW}Local LLM Configuration${NC}"
    echo "Apollo OS uses Ollama with qwen2.5:0.5b as offline fallback (fast, no reasoning overhead)."
    echo "This will be installed and configured automatically."
    echo -e "${GREEN}No user input required.${NC}"

    # Save configuration
    mkdir -p "$HOME/.config/apollo-os"
    cat > "$CONFIG_FILE" <<EOF
# Apollo OS Configuration
# Generated on $(date)
# Edit this file to update your API keys and settings

# AI Configuration
GEMINI_API_KEY="$GEMINI_API_KEY"
GEMINI_MODEL="gemini-2.0-flash"

# Telegram Configuration
TELEGRAM_BOT_TOKEN="$TELEGRAM_BOT_TOKEN"
TELEGRAM_USER_ID="$TELEGRAM_USER_ID"

# Ollama Configuration
OLLAMA_MODEL="qwen2.5:0.5b"
OLLAMA_PRELOAD="true"

# System Configuration
WALLPAPER_DIR="$HOME/System/Wallpaper"
DEFAULT_WM="niri"
DEFAULT_PROFILE="pro"
DEFAULT_THEME="dark"
EOF

    chmod 600 "$CONFIG_FILE"
    log "Configuration saved to $CONFIG_FILE ✓"
    
    if [[ -z "$GEMINI_API_KEY" ]] || [[ -z "$TELEGRAM_BOT_TOKEN" ]]; then
        echo
        echo -e "${YELLOW}⚠️  Note: Some configuration values are empty.${NC}"
        echo -e "${YELLOW}   You can add them later by editing:${NC}"
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

    # Install COPR repositories for Niri and other components
    log "Enabling COPR repositories..."
    sudo -v  # Refresh sudo
    sudo dnf copr enable -y errornix/niri || warn "Failed to enable niri COPR repo (will try from standard repos)"

    # Refresh DNF cache after adding repos
    sudo dnf makecache --refresh

    # Core Window Managers & Wayland
    log "Installing Window Managers..."
    sudo -v  # Refresh sudo
    
    # Install Sway first (critical)
    sudo dnf install -y sway waybar || error "Critical: Sway installation failed - check repositories"
    
    # Install Wayland components
    sudo dnf install -y wayland-protocols wayland-devel || warn "Wayland dev packages failed"

    # Install Niri (may need to be built from source)
    if ! command -v niri &>/dev/null; then
        log "Installing Niri Window Manager..."
        sudo dnf install -y niri || warn "Niri installation failed - system will use Sway only"
    else
        log "Niri already installed ✓"
    fi

    # UI Components - Split into critical and optional
    log "Installing UI components..."
    sudo -v  # Refresh sudo
    
    # Critical UI components
    sudo dnf install -y rofi-wayland mako grim slurp wl-clipboard || error "Critical UI components failed"
    
    # Optional UI components
    sudo dnf install -y dunst swaylock-effects swayidle swayosd || warn "Some optional UI packages failed"

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
        blueman \
        pavucontrol \
        brightnessctl \
        playerctl \
        btop \
        fastfetch \
        jq \
        wget \
        unzip \
        || warn "Some system tools failed to install"
    
    # Fonts
    log "Installing fonts..."
    sudo dnf install -y \
        jetbrains-mono-fonts-all \
        google-noto-emoji-fonts \
        fontawesome-fonts \
        || warn "Some fonts failed to install"
    
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

    # Python & AI Dependencies
    log "Installing Python and AI dependencies..."
    sudo dnf install -y \
        python3 \
        python3-pip \
        python3-devel \
        || error "Python installation failed"

    pip3 install --user \
        google-generativeai \
        python-telegram-bot \
        psutil \
        pyyaml \
        || warn "Some Python packages failed to install"

    # Install Ollama
    log "Installing Ollama..."
    sudo -v  # Refresh sudo
    if ! command -v ollama &>/dev/null; then
        curl -fsSL https://ollama.com/install.sh | sh || warn "Ollama installation failed"
    else
        log "Ollama already installed ✓"
    fi

    # Pull Ollama model (retry on failure)
    if command -v ollama &>/dev/null; then
        log "Pulling Ollama model (qwen2.5:0.5b - fast, no reasoning overhead)..."
        
        # Start ollama service first
        systemctl --user enable --now ollama 2>/dev/null || sudo systemctl enable --now ollama 2>/dev/null
        sleep 2
        
        # Try to pull model with timeout
        timeout 180 ollama pull qwen2.5:0.5b || {
            warn "Ollama model pull timed out or failed - will retry in background"
            # Schedule background retry
            (sleep 10 && ollama pull qwen2.5:0.5b &>/dev/null &)
        }
    fi

    # Login Manager
    log "Installing greetd and tuigreet..."
    sudo dnf install -y greetd || warn "greetd not available, will use default login manager"

    # Fonts
    log "Installing fonts..."
    sudo dnf install -y \
        google-noto-sans-fonts \
        google-noto-emoji-fonts \
        fira-code-fonts \
        fontawesome-fonts \
        || warn "Font installation incomplete"

    log "Package installation complete ✓"
}

#####################################################################
# Verify Critical Packages
#####################################################################

verify_critical_packages() {
    log "Verifying critical packages..."
    
    local missing=()
    local critical_packages=(
        "sway"
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
            case "$pkg" in
                rofi)
                    sudo dnf install -y rofi-wayland || warn "Could not install rofi-wayland"
                    ;;
                *)
                    sudo dnf install -y "$pkg" || warn "Could not install $pkg"
                    ;;
            esac
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
    mkdir -p "$HOME/.config/sway"
    mkdir -p "$HOME/.config/waybar"
    mkdir -p "$HOME/.config/mako"
    mkdir -p "$HOME/.config/rofi"
    mkdir -p "$HOME/.config/swaylock"
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
    
    # Create XDG Portal configs
    cat > "$HOME/.config/xdg-desktop-portal/niri-portals.conf" << 'PORTALEOF'
[preferred]
default=gtk
org.freedesktop.impl.portal.Settings=gtk
org.freedesktop.impl.portal.Screenshot=wlr
org.freedesktop.impl.portal.ScreenCast=wlr
PORTALEOF
    cp "$HOME/.config/xdg-desktop-portal/niri-portals.conf" "$HOME/.config/xdg-desktop-portal/sway-portals.conf"

    # Deploy Niri configs
    log "Deploying Niri configurations..."
    cp "$SCRIPT_DIR/config-data/niri/"* "$HOME/.config/niri/" || warn "Niri config deployment failed"
    
    # Make autostart executable
    chmod +x "$HOME/.config/niri/apollo-autostart.sh" 2>/dev/null
    
    # Add GTK_THEME and portal to Niri configs
    for config in "$HOME/.config/niri/apollo-os-config-pro.kdl" "$HOME/.config/niri/apollo-os-config-mod.kdl"; do
        if [ -f "$config" ]; then
            # Add autostart if not present
            if ! grep -q "apollo-autostart.sh" "$config"; then
                sed -i '/spawn-at-startup.*polkit/a spawn-at-startup "~/.config/niri/apollo-autostart.sh" // Apollo OS Services' "$config"
            fi
            # Add portal if not present
            if ! grep -q "xdg-desktop-portal-gtk" "$config"; then
                sed -i '/spawn-at-startup.*polkit/a spawn-at-startup "/usr/libexec/xdg-desktop-portal-gtk" // GTK Portal for dark theme' "$config"
            fi
            # Add GTK_THEME environment if not present
            if ! grep -q "GTK_THEME" "$config"; then
                sed -i 's/environment {/environment {\n    GTK_THEME "adw-gtk3-dark"\n    ADW_DEBUG_COLOR_SCHEME "prefer-dark"/' "$config"
            fi
        fi
    done

    # Deploy Sway configs
    log "Deploying Sway configurations..."
    cp "$SCRIPT_DIR/config-data/sway/"* "$HOME/.config/sway/" || warn "Sway config deployment failed"
    
    # Remove non-existent omarchy-menu references and add portal
    for config in "$HOME/.config/sway/"apollo-os-config-*; do
        if [ -f "$config" ]; then
            sed -i '/omarchy-menu/d' "$config" 2>/dev/null
            # Add portal if not present
            if ! grep -q "xdg-desktop-portal-gtk" "$config"; then
                sed -i '/exec.*polkit/a exec /usr/libexec/xdg-desktop-portal-gtk' "$config"
            fi
        fi
    done

    # Deploy Waybar configs
    log "Deploying Waybar configurations..."
    cp "$SCRIPT_DIR/config-data/waybar/"* "$HOME/.config/waybar/" || warn "Waybar config deployment failed"

    # Deploy Mako configs
    log "Deploying Mako configurations..."
    cp "$SCRIPT_DIR/config-data/mako/"* "$HOME/.config/mako/" || warn "Mako config deployment failed"

    # Deploy Rofi configs
    log "Deploying Rofi configurations..."
    cp "$SCRIPT_DIR/config-data/rofi/"* "$HOME/.config/rofi/" || warn "Rofi config deployment failed"

    # Deploy Swaylock configs
    log "Deploying Swaylock configurations..."
    mkdir -p "$HOME/.config/swaylock"
    cp "$SCRIPT_DIR/config-data/swaylock/"* "$HOME/.config/swaylock/" || warn "Swaylock config deployment failed"

    # Deploy SwayOSD configs
    log "Deploying SwayOSD configurations..."
    mkdir -p "$HOME/.config/swayosd"
    cp "$SCRIPT_DIR/config-data/swayosd/"* "$HOME/.config/swayosd/" || warn "SwayOSD config deployment failed"

    log "Configuration deployment complete ✓"
}

#####################################################################
# Script Installation
#####################################################################

install_scripts() {
    log "Installing Apollo OS scripts..."

    # Copy scripts to local bin
    cp "$SCRIPT_DIR/scripts/"*.sh "$HOME/.local/bin/" || error "Failed to copy scripts"
    cp "$SCRIPT_DIR/scripts/"*.py "$HOME/.local/bin/" || error "Failed to copy Python scripts"

    # Make scripts executable
    chmod +x "$HOME/.local/bin/apollo-os-"* || error "Failed to make scripts executable"
    chmod +x "$HOME/.local/bin/apollo-speak.sh" 2>/dev/null || true
    
    # Install wrapper scripts to /usr/local/bin/ (needed for GDM)
    log "Installing wrapper scripts globally..."
    sudo cp "$HOME/.local/bin/apollo-os-wrapper-niri.sh" /usr/local/bin/ || warn "Failed to install niri wrapper globally"
    sudo cp "$HOME/.local/bin/apollo-os-wrapper-sway.sh" /usr/local/bin/ || warn "Failed to install sway wrapper globally"
    sudo chmod +x /usr/local/bin/apollo-os-wrapper-*.sh

    # Create symlinks for convenience
    ln -sf "$HOME/.local/bin/apollo-os-nl2bash.sh" "$HOME/.local/bin/??" || warn "Failed to create ?? symlink"
    ln -sf "$HOME/.local/bin/apollo-os-diagnose.sh" "$HOME/.local/bin/apollo-diagnose" || warn "Failed to create apollo-diagnose symlink"
    ln -sf "$HOME/.local/bin/apollo-os-chat.sh" "$HOME/.local/bin/apollo-chat" || warn "Failed to create apollo-chat symlink"
    ln -sf "$HOME/.local/bin/apollo-speak.sh" "$HOME/.local/bin/apollo-speak" || warn "Failed to create apollo-speak symlink"

    log "Scripts installed ✓"
}

#####################################################################
# Desktop Entries for WM Sessions
#####################################################################

install_desktop_entries() {
    log "Installing Wayland session entries..."

    # Create directory for user-specific Wayland sessions
    mkdir -p "$HOME/.local/share/wayland-sessions"

    # Copy desktop entries
    cp "$SCRIPT_DIR/wayland-sessions/"*.desktop "$HOME/.local/share/wayland-sessions/" || warn "Failed to copy desktop entries"

    # Also try to install system-wide if we have permissions
    if sudo mkdir -p /usr/share/wayland-sessions 2>/dev/null; then
        sudo cp "$SCRIPT_DIR/wayland-sessions/"*.desktop /usr/share/wayland-sessions/ 2>/dev/null && \
            log "System-wide session entries installed" || \
            log "User-specific session entries installed"
    fi

    log "Desktop entries installed ✓"
}

#####################################################################
# Systemd Services
#####################################################################

setup_systemd() {
    log "Setting up systemd services..."

    mkdir -p "$HOME/.config/systemd/user"

    # Copy systemd units (excluding boot splash files)
    for file in "$SCRIPT_DIR/systemd/"*.service "$SCRIPT_DIR/systemd/"*.timer; do
        if [ -f "$file" ] && [ "$(basename "$file")" != "apollo-boot-splash.service" ]; then
            cp "$file" "$HOME/.config/systemd/user/" || warn "Failed to copy $(basename "$file")"
        fi
    done

    # Reload systemd
    systemctl --user daemon-reload

    # Enable services
    systemctl --user enable apollo-os-daemon.service || warn "Failed to enable apollo-daemon"
    systemctl --user enable apollo-os-notification-handler.service || warn "Failed to enable notification-handler"

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
    
    # apollo-speak is already copied by install_scripts()
    
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

    # Configure GDM (remove Fedora logo, clock with seconds)
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
    
    # Remove GNOME sessions from selection (keep only Apollo sessions)
    log "Removing default GNOME sessions..."
    sudo rm -f /usr/share/wayland-sessions/gnome.desktop 2>/dev/null
    sudo rm -f /usr/share/wayland-sessions/gnome-wayland.desktop 2>/dev/null
    sudo rm -f /usr/share/wayland-sessions/gnome-classic.desktop 2>/dev/null
    sudo rm -f /usr/share/wayland-sessions/gnome-classic-wayland.desktop 2>/dev/null
    
    # Rename default Niri/Sway sessions
    log "Configuring session names..."
    sudo bash -c 'cat > /usr/share/wayland-sessions/niri.desktop << EOF
[Desktop Entry]
Name=Apollo Orbit (DEV)
Comment=Niri - Scrollable Tiling Window Manager
Exec=niri
Type=Application
DesktopNames=niri
EOF'
    
    sudo bash -c 'cat > /usr/share/wayland-sessions/sway.desktop << EOF
[Desktop Entry]
Name=Apollo Grid (DEV)
Comment=Sway - i3-compatible Tiling Window Manager
Exec=sway
Type=Application
DesktopNames=sway
EOF'
    
    # Set Plymouth theme to spinner (no Fedora logo)
    log "Setting Plymouth boot theme..."
    sudo plymouth-set-default-theme spinner
    # Remove Fedora watermark from spinner theme
    sudo rm -f /usr/share/plymouth/themes/spinner/watermark.png
    sudo dracut -f
    
    log "GDM and Plymouth configured ✓"
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

    # Start Apollo daemon
    systemctl --user start apollo-os-daemon.service || warn "Failed to start apollo-daemon"

    # Print summary
    echo
    echo -e "${MAGENTA}══════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}  Installation Complete! ${NC}"
    echo -e "${MAGENTA}══════════════════════════════════════════════════════${NC}\n"

    echo -e "${CYAN}Next Steps:${NC}"
    echo "1. Log out of your current session"
    echo "2. Select 'Niri PRO' or 'Sway PRO' from the login manager"
    echo "3. Log in to experience Apollo OS"
    echo
    echo -e "${YELLOW}Available WM Sessions:${NC}"
    echo "  • Niri PRO (Dark)  - Professional, minimal tiling"
    echo "  • Niri MOD (Dark)  - Modified, enhanced tiling"
    echo "  • Sway PRO (Dark)  - Classic i3-style tiling"
    echo "  • Sway MOD (Dark)  - Enhanced Sway experience"
    echo "  (Light variants available via theme switcher)"
    echo
    echo -e "${CYAN}Quick Commands:${NC}"
    echo "  ?? <question>                - Natural language to bash"
    echo "  apollo-diagnose              - AI-powered system diagnostics"
    echo "  apollo-chat                  - Interactive chat with Apollo AI"
    echo "  apollo-speak <text>          - Text-to-Speech with LUNA voice"
    echo "  apollo-os-theme-switcher.sh  - Switch between light/dark themes"
    echo
    echo -e "${CYAN}Optional Post-Installation:${NC}"
    echo "  Boot Splash: sudo $SCRIPT_DIR/scripts/apollo-os-boot-splash-installer.sh"
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
    verify_critical_packages
    deploy_configs
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
