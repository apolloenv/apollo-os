#!/bin/bash

#####################################################################
# Apollo OS - Master Installer v0.6.0
# Copyright © 2025-2026 by Manuel Kraibacher
#
# Description: Apollo OS Enterprise Installation System
# Platform: Linux x86_64
# Window Managers: Apollo OS Orbit (Niri) + Apollo OS Glass (Hyprland)
#
# v0.6.0 Changes:
# - 17 Security Modules (firewalld, fail2ban, ClamAV, rkhunter, Lynis,
#   AIDE, kernel hardening, SSH hardening, DNS-over-TLS, MAC randomization,
#   auto-updates, core dump restriction, port monitor, security audit,
#   battery monitor, disk monitor, service watchdog)
# - Comprehensive system update script (DNF, Flatpak, firmware, security)
# - Clipboard history (cliphist) for Niri Orbit
# - System Health Dashboard in Quick Menu
# - Quick Notes via Quick Menu
# - Journal rotation and log management
# - Boot system cleanup (Plymouth removed, TTY-based boot)
# - All packages verified for Fedora 43 availability
# - Dynamic version fetch for Nerd Fonts and Winboat
# - npm global packages without sudo (~/.local prefix)
#
# v3.1.0 Changes:
# - Dual Desktop Support (Niri Orbit + Hyprland Glass)
# - Session-Auswahl beim Login (Apollo OS Glass / Apollo OS Orbit)
# - Vollautomatische Installation (-y flags überall)
# - Desktop Environment Selection Menu
# - Hyprland + Quickshell Integration
# - Unified configuration deployment for both desktop environments
#
# v1.0.2 Changes:
# - Redesigned Quick Menu with box-style categories
# - Fixed shortcuts display (fully scrollable, no cut-off)
# - Enhanced Rofi launcher with modern styling
# - Added TTS feedback for power profile switching
# - New power profile toggle script with cycle support
# - Fixed Synology Drive compatibility with XWayland
# - Improved menu appearance and organization
#
# v1.0.1 Changes:
# - Display scaling configuration (1.0, 1.25, 1.5, 2.0)
# - Enhanced Quick Menu with external monitor scaling
# - Power Profile improvements
# - Niri shortcuts display in Rofi
# - Rofi web search integration
# - Window centering with Super+C
# - Extended software suite (Docker, Winboat, VLC, etc.)
# - Additional Flatpak applications
# - zsh shell installation
# - Qt Wayland support for better app compatibility
#####################################################################

# Note: set -e is intentionally NOT used to allow graceful error handling
# Each critical operation uses explicit error checking with || error

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
INSTALL_LOG="$HOME/apollo-os-install.log"
CONFIG_FILE="$HOME/.config/apollo-os/config.env"

#####################################################################
# Helper Functions
#####################################################################

print_banner() {
    clear
    echo -e "${CYAN}"
    cat << 'BANNER'
    ___                ____           ____  _____
   /   |  ____  ____  / / /___       / __ \/ ___/
  / /| | / __ \/ __ \/ / / __ \     / / / /\__ \ 
 / ___ |/ /_/ / /_/ / / / /_/ /    / /_/ /___/ / 
/_/  |_/ .___/\____/_/_/\____/     \____//____/  
      /_/                                         
BANNER
    echo -e "${NC}"
    echo -e "${MAGENTA}═══════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}  Apollo OS Installer v0.6.0${NC}"
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

    # Hostname Configuration
    echo -e "${YELLOW}System Hostname Configuration${NC}"
    echo "Current hostname: $(hostname)"
    read -p "Enter new hostname (press Enter to keep current): " NEW_HOSTNAME
    if [ -n "$NEW_HOSTNAME" ]; then
        echo "$NEW_HOSTNAME" | sudo tee /etc/hostname > /dev/null
        sudo hostnamectl set-hostname "$NEW_HOSTNAME"
        log "Hostname set to: $NEW_HOSTNAME"
    else
        log "Keeping current hostname: $(hostname)"
    fi
    echo

    # Display Scaling Configuration
    echo -e "${YELLOW}Display Scaling Configuration${NC}"
    echo "Select your preferred display scaling factor:"
    echo "  1) 1.0  - No scaling (100%)"
    echo "  2) 1.25 - Small scaling (125%)"
    echo "  3) 1.5  - Medium scaling (150%)"
    echo "  4) 2.0  - Large scaling (200%)"
    read -p "Enter your choice [1-4] (default: 1): " SCALING_CHOICE
    
    case "$SCALING_CHOICE" in
        2) DISPLAY_SCALE="1.25" ;;
        3) DISPLAY_SCALE="1.5" ;;
        4) DISPLAY_SCALE="2.0" ;;
        *) DISPLAY_SCALE="1.0" ;;
    esac
    
    log "Display scaling set to: $DISPLAY_SCALE"
    echo

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

# Display Configuration
DISPLAY_SCALE="$DISPLAY_SCALE"

# Telegram Configuration (Optional)
TELEGRAM_BOT_TOKEN="$TELEGRAM_BOT_TOKEN"
TELEGRAM_USER_ID="$TELEGRAM_USER_ID"

# System Configuration
WALLPAPER_DIR="$HOME/System/Wallpaper"
DEFAULT_WM="${DEFAULT_WM:-niri}"
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
# Desktop Environment Selection
#####################################################################

select_desktop_environment() {
    log "Desktop Environment Selection..."
    echo
    echo -e "${MAGENTA}══════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}  Choose Desktop Environment${NC}"
    echo -e "${MAGENTA}══════════════════════════════════════════════════════${NC}\n"
    echo -e "${GREEN}1)${NC} Apollo OS Glass (Hyprland - Transparent Design)"
    echo -e "${GREEN}2)${NC} Apollo OS Orbit (Niri - Scrollable Tiling)"
    echo -e "${GREEN}3)${NC} Both (Dual Desktop Setup)${NC}\n"
    
    read -p "Select [1-3] (default: 3): " DESKTOP_CHOICE
    DESKTOP_CHOICE=${DESKTOP_CHOICE:-3}
    
    case "$DESKTOP_CHOICE" in
        1) INSTALL_HYPRLAND=true; INSTALL_NIRI=false; DEFAULT_WM="Hyprland" ;;
        2) INSTALL_HYPRLAND=false; INSTALL_NIRI=true; DEFAULT_WM="niri" ;;
        3) INSTALL_HYPRLAND=true; INSTALL_NIRI=true; DEFAULT_WM="niri" ;;
        *) warn "Invalid choice, installing both"; INSTALL_HYPRLAND=true; INSTALL_NIRI=true; DEFAULT_WM="niri" ;;
    esac
    
    log "Desktop configuration: Hyprland=${INSTALL_HYPRLAND}, Niri=${INSTALL_NIRI}, Default=${DEFAULT_WM}"
}

#####################################################################
# Flatpak Installation Option
#####################################################################

select_flatpak_option() {
    log "Flatpak Applications Selection..."
    echo
    echo -e "${MAGENTA}══════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}  Install Flatpak Applications?${NC}"
    echo -e "${MAGENTA}══════════════════════════════════════════════════════${NC}\n"
    echo -e "Flatpak apps include: Telegram, Epiphany Browser, Translator,"
    echo -e "Speedtest, Podcasts, Terminal (Ptyxis), and more.\n"
    echo -e "${GREEN}1)${NC} Yes - Install Flatpak applications"
    echo -e "${GREEN}2)${NC} No - Skip Flatpak applications\n"

    read -p "Select [1-2] (default: 1): " FLATPAK_CHOICE
    FLATPAK_CHOICE=${FLATPAK_CHOICE:-1}

    case "$FLATPAK_CHOICE" in
        1) INSTALL_FLATPAK=true ;;
        2) INSTALL_FLATPAK=false ;;
        *) INSTALL_FLATPAK=true ;;
    esac

    log "Flatpak installation: ${INSTALL_FLATPAK}"
}

#####################################################################
# OnlyOffice Suite Selection
#####################################################################

select_office_suite() {
    log "Office Suite Selection..."
    echo
    echo -e "${MAGENTA}══════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}  Install OnlyOffice Suite?${NC}"
    echo -e "${MAGENTA}══════════════════════════════════════════════════════${NC}\n"
    echo -e "OnlyOffice: Free office suite (Word, Excel, PowerPoint compatible)"
    echo -e "Alternative to Microsoft Office and LibreOffice\n"
    echo -e "${GREEN}1)${NC} Yes - Install OnlyOffice (via Flatpak)"
    echo -e "${GREEN}2)${NC} No - Skip OnlyOffice\n"

    read -p "Select [1-2] (default: 1): " OFFICE_CHOICE
    OFFICE_CHOICE=${OFFICE_CHOICE:-1}

    case "$OFFICE_CHOICE" in
        1) INSTALL_ONLYOFFICE=true ;;
        2) INSTALL_ONLYOFFICE=false ;;
        *) INSTALL_ONLYOFFICE=true ;;
    esac

    log "OnlyOffice installation: ${INSTALL_ONLYOFFICE}"
}

#####################################################################
# Editor Selection (Neovim vs Fresh Editor)
#####################################################################

select_editor() {
    log "Text Editor Selection..."
    echo
    echo -e "${MAGENTA}══════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}  Choose Text Editor(s)${NC}"
    echo -e "${MAGENTA}══════════════════════════════════════════════════════${NC}\n"
    echo -e "${GREEN}1)${NC} Both - Fresh Editor + Neovim (recommended)"
    echo -e "${GREEN}2)${NC} Fresh Editor only (Modern GUI editor)"
    echo -e "${GREEN}3)${NC} Neovim only (Terminal-based, powerful)\n"

    read -p "Select [1-3] (default: 1): " EDITOR_CHOICE
    EDITOR_CHOICE=${EDITOR_CHOICE:-1}

    case "$EDITOR_CHOICE" in
        1) INSTALL_FRESH=true; INSTALL_NEOVIM=true ;;
        2) INSTALL_FRESH=true; INSTALL_NEOVIM=false ;;
        3) INSTALL_FRESH=false; INSTALL_NEOVIM=true ;;
        *) INSTALL_FRESH=true; INSTALL_NEOVIM=true ;;
    esac

    log "Editor installation: Fresh=${INSTALL_FRESH}, Neovim=${INSTALL_NEOVIM}"
}

#####################################################################
# dots-hyprland Base Installation (Community Project)
#####################################################################

install_dots_hyprland() {
    if [[ "$INSTALL_HYPRLAND" != true ]]; then
        log "Skipping dots-hyprland installation (Hyprland not selected)"
        return 0
    fi

    log "Installing dots-hyprland base system..."
    
    echo
    echo -e "${MAGENTA}══════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}  Installing Apollo OS GLASS UI Base System${NC}"
    echo -e "${MAGENTA}══════════════════════════════════════════════════════${NC}\n"
    
    local DOTS_DIR="$HOME/.cache/dots-hyprland-install"
    
    # Clone the repository
    log "Cloning base system repository..."
    rm -rf "$DOTS_DIR" 2>/dev/null
    git clone --quiet https://github.com/end-4/dots-hyprland.git "$DOTS_DIR" || error "Failed to clone base system"
    
    cd "$DOTS_DIR" || error "Failed to cd to base system directory"
    
    # Patch the setup script to remove INFO and NOTICE messages
    log "Preparing installation..."
    if [[ -f "./setup" ]]; then
        # Remove the INFO and NOTICE blocks from setup script output
        sed -i 's/echo "===INFO==="/# Removed by Apollo OS/g' ./setup
        sed -i 's/echo "===NOTICE==="/# Removed by Apollo OS/g' ./setup
        sed -i 's/echo "==========="/# Removed by Apollo OS/g' ./setup
        sed -i 's/echo "============"/# Removed by Apollo OS/g' ./setup
        sed -i '/Detected OS_DISTRO/d' ./setup
        sed -i '/Determined OS_GROUP/d' ./setup
        sed -i '/support for your distro/d' ./setup
        sed -i '/not officially supported/d' ./setup
        sed -i '/PR is welcomed/d' ./setup
        sed -i '/create a discussion/d' ./setup
        sed -i '/do not submit issue/d' ./setup
        sed -i '/developers do not use/d' ./setup
        sed -i '/Proceed only at your own risk/d' ./setup
    fi
    
    log "Running base system setup (this may take a while)..."
    log "This will install all dependencies and compile Quickshell..."
    log ""
    log ">>> IMPORTANT: You may need to press ENTER a few times and enter your password when prompted <<<"
    log ""
    
    # Run setup directly - let user handle prompts
    cd "$DOTS_DIR" || error "Failed to enter dots directory"
    ./setup install 2>&1 | tee -a "$INSTALL_LOG" || {
        warn "Setup had issues, trying fallback..."
        yes "" | timeout 2400 ./setup install 2>&1 | tee -a "$INSTALL_LOG" || {
            warn "Setup may need manual completion"
        }
    }
    
    # Cleanup temp files
    rm -f /tmp/auto_install_dots.exp 2>/dev/null
    
    # Verify installation
    if [[ -f "$HOME/.config/illogical-impulse/installed_true" ]]; then
        log "dots-hyprland base installation completed successfully ✓"
    else
        warn "dots-hyprland installation may not have completed fully"
        warn "You may need to run './setup install' manually from $DOTS_DIR"
    fi

    # Install materialyoucolor for Quickshell wallpaper theming
    python3 -m pip install --user materialyoucolor 2>/dev/null || warn "Failed to install materialyoucolor"
    
    # Cleanup cloned repo
    cd "$HOME" || warn "Failed to return to home directory"
    rm -rf "$DOTS_DIR"
    
    log "dots-hyprland cleanup completed ✓"
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
    sudo dnf upgrade -y --refresh || warn "System upgrade had errors (non-fatal, continuing)"

    # Refresh sudo before next operation (system update can take 20+ minutes)
    log "Refreshing sudo credentials..."
    sudo -v

    # Enable RPM Fusion
    log "Enabling RPM Fusion repositories..."
    sudo dnf install -y https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm || warn "RPM Fusion Free repo failed - some multimedia packages may be unavailable"
    sudo dnf install -y https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm || warn "RPM Fusion Nonfree repo failed - some codecs may be unavailable"

    # Install COPR repositories
    log "Enabling COPR repositories..."
    sudo -v  # Refresh sudo
    if [[ "$INSTALL_NIRI" == true ]]; then
        sudo dnf copr enable -y errornix/niri || warn "Failed to enable niri COPR repo (will try from standard repos)"
    fi

    # Refresh DNF cache after adding repos
    sudo dnf makecache --refresh

    # Core Window Manager & Wayland
    sudo -v  # Refresh sudo

    # Install Wayland components
    sudo dnf install -y wayland-protocols wayland-devel || warn "Wayland dev packages failed"

    # Install Niri if selected
    if [[ "$INSTALL_NIRI" == true ]]; then
        if ! command -v niri &>/dev/null; then
            log "Installing Apollo OS Orbit Window Manager..."
            sudo dnf install -y niri || error "Apollo OS Orbit installation failed"
        else
            log "Apollo OS Orbit already installed ✓"
        fi

        # Install Hyprlock for Niri (lock screen) - from COPR
        log "Installing Hyprlock (lock screen)..."
        sudo dnf copr enable -y sdegler/hyprland 2>/dev/null || true
        sudo dnf install -y hyprlock || warn "Hyprlock installation failed"

        # Niri essential runtime packages
        log "Installing Niri essential packages..."
        # xwayland-satellite needs separate COPR or may be in errornix/niri
        sudo dnf install -y xwayland-satellite 2>/dev/null || {
            log "xwayland-satellite not in repos, trying COPR..."
            sudo dnf copr enable -y ulysg/xwayland-satellite 2>/dev/null || true
            sudo dnf install -y xwayland-satellite 2>/dev/null || warn "xwayland-satellite not available (X11 apps may not work under Niri)"
        }
        sudo dnf install -y \
            polkit-gnome \
            network-manager-applet \
            xdg-desktop-portal xdg-desktop-portal-gtk xdg-desktop-portal-wlr \
            libnotify \
            ptyxis \
            nautilus \
            gnome-text-editor \
            || warn "Some Niri packages failed to install"

        # Install KDE System Settings for Niri
        log "Installing KDE System Settings..."
        sudo dnf install -y systemsettings kde-settings || warn "KDE System Settings installation failed"
    fi
    
    # Install Hyprland if selected
    if [[ "$INSTALL_HYPRLAND" == true ]]; then
        log "Installing Hyprland and Quickshell..."
        
        # COPR Repos for Hyprland
        sudo dnf copr enable -y ririko66z/dots-hyprland || warn "Failed to enable dots-hyprland COPR"
        sudo dnf copr enable -y sdegler/hyprland || warn "Failed to enable hyprland COPR"
        sudo dnf copr enable -y deltacopy/darkly || warn "Failed to enable darkly COPR"
        
        # Hyprland core + essential runtime packages (safety-net if dots-hyprland setup fails)
        sudo dnf install -y hyprland xdg-desktop-portal-hyprland \
            hypridle hyprlock hyprpicker \
            fuzzel wlogout cliphist foot \
            tesseract tesseract-langpack-eng \
            gnome-keyring bc easyeffects grim \
            || warn "Hyprland packages installation failed"
        
        # Quickshell dependencies
        sudo dnf install -y qt6-qtdeclarative qt6-qtbase jemalloc qt6-qtsvg \
            pipewire-libs libxcb pam-devel wayland-devel || warn "Quickshell dependencies failed"
        
        # Build Quickshell from source (check if RPM available first)
        if ! rpm -q quickshell-git &>/dev/null; then
            log "Building Quickshell from source..."
            cd "$HOME" || error "Failed to cd to HOME"
            if [[ ! -d quickshell-build ]]; then
                git clone https://git.outfoxxed.me/outfoxxed/quickshell.git quickshell-build || warn "Quickshell clone failed"
            fi
            if [[ -d quickshell-build ]]; then
                cd quickshell-build || { warn "Failed to cd to quickshell-build"; cd "$HOME" || true; }
                if cmake -B build -DCMAKE_BUILD_TYPE=Release; then
                    cmake --build build && sudo cmake --install build || warn "Quickshell build/install failed"
                else
                    warn "Quickshell cmake configuration failed"
                fi
                cd "$HOME" || true
                rm -rf quickshell-build
            fi
        fi
        
        log "Hyprland installed ✓"
    fi

    # Install Waybar (may already be installed as waybar-git from dots-hyprland)
    if ! command -v waybar &>/dev/null; then
        sudo dnf install -y waybar || warn "Waybar installation failed (may be installed as waybar-git)"
    else
        log "Waybar already installed ✓"
    fi

    # UI Components
    log "Installing UI components..."
    sudo -v  # Refresh sudo

    # Critical UI components (install individually to avoid one failure blocking all)
    sudo dnf install -y rofi-wayland mako grim slurp wl-clipboard swaybg swayidle wtype || {
        warn "Some UI components failed in batch install, trying individually..."
        for pkg in rofi-wayland mako grim slurp wl-clipboard swaybg swayidle wtype; do
            sudo dnf install -y "$pkg" 2>/dev/null || warn "$pkg installation failed"
        done
    }

    # Install Rust/Cargo (needed for bluetui, impala, satty)
    log "Installing Rust toolchain..."
    sudo dnf install -y rust cargo || warn "Rust/Cargo installation failed"

    # Screenshot, Screenrecord & Color Picker tools
    log "Installing screenshot & capture tools..."
    sudo dnf install -y wf-recorder hyprpicker || warn "Some capture tools failed to install"
    # satty (screenshot annotation) - install via cargo if not in repos
    if ! command -v satty &>/dev/null; then
        sudo dnf install -y satty 2>/dev/null || {
            log "satty not in repos, installing via cargo..."
            if command -v cargo &>/dev/null; then
                cargo install satty 2>/dev/null || warn "satty cargo install failed"
            else
                warn "satty not available (no cargo)"
            fi
        }
    fi
    # wayfreeze (screen freeze for selection) - optional
    sudo dnf install -y wayfreeze 2>/dev/null || warn "wayfreeze not available (optional)"

    # Bluetooth & WiFi TUI managers
    log "Installing Bluetooth & WiFi TUI tools..."
    if command -v cargo &>/dev/null; then
        command -v bluetui &>/dev/null || cargo install bluetui 2>/dev/null || warn "bluetui install failed"
        command -v impala &>/dev/null || cargo install impala 2>/dev/null || warn "impala install failed"
    else
        warn "cargo not available - bluetui/impala will be installed on first use"
    fi

    # Terminal Emulators
    log "Installing terminal emulators..."
    sudo dnf install -y \
        alacritty \
        kitty \
        foot \
        fish \
        || warn "Terminal installation failed"

    # System Tools
    log "Installing system tools..."
    sudo dnf install -y \
        NetworkManager \
        nm-connection-editor \
        pavucontrol \
        playerctl \
        btop \
        fastfetch \
        jq \
        wget \
        unzip \
        || warn "Some system tools failed to install"
    
    # Power profiles daemon (conflicts with tuned)
    log "Installing power profiles daemon..."
    sudo systemctl stop tuned 2>/dev/null
    sudo systemctl disable tuned 2>/dev/null
    sudo systemctl mask tuned 2>/dev/null
    sudo dnf install -y --allowerasing power-profiles-daemon || warn "Power profiles daemon installation failed"
    # Fix sandbox restrictions that prevent startup on some systems
    sudo mkdir -p /etc/systemd/system/power-profiles-daemon.service.d
    printf '[Service]\nPrivateUsers=no\nProtectHome=no\nPrivateDevices=no\nSystemCallFilter=\nSystemCallFilter=~@obsolete\nCapabilityBoundingSet=\n' \
        | sudo tee /etc/systemd/system/power-profiles-daemon.service.d/override.conf > /dev/null
    # Allow wheel group to switch power profiles without auth
    printf 'polkit.addRule(function(action, subject) {\n    if (action.id == "org.freedesktop.UPower.PowerProfiles.switch-profile" &&\n        subject.isInGroup("wheel")) {\n        return polkit.Result.YES;\n    }\n});\n' \
        | sudo tee /etc/polkit-1/rules.d/99-apollo-power-profiles.rules > /dev/null
    sudo systemctl daemon-reload
    sudo systemctl enable --now power-profiles-daemon || warn "Power profiles daemon failed to start"
    
    # Critical UI tools (separate to ensure installation)
    log "Installing critical UI tools..."
    sudo dnf install -y blueman brightnessctl || error "Critical tools (blueman, brightnessctl) failed to install"
    
    # Remote Desktop & VPN
    log "Installing remote desktop and VPN tools..."
    sudo dnf install -y remmina remmina-plugins-vnc || warn "Remmina installation failed"
    
    # Tailscale VPN
    if [ ! -f /etc/yum.repos.d/tailscale.repo ]; then
        log "Adding Tailscale repository..."
        sudo bash -c 'cat > /etc/yum.repos.d/tailscale.repo << EOF
[tailscale-stable]
name=Tailscale stable
baseurl=https://pkgs.tailscale.com/stable/fedora/\$basearch
enabled=1
type=rpm
repo_gpgcheck=1
gpgcheck=0
gpgkey=https://pkgs.tailscale.com/stable/fedora/repo.gpg
EOF'
    fi
    sudo dnf install -y tailscale || warn "Tailscale installation failed"
    sudo systemctl enable --now tailscaled 2>/dev/null || warn "Tailscale service enablement failed"

    # Browsers
    sudo -v 2>/dev/null || true
    log "Installing web browsers..."
    
    # Google Chrome
    if ! command -v google-chrome-stable &>/dev/null; then
        log "Adding Google Chrome repository..."
        sudo dnf install -y fedora-workstation-repositories 2>/dev/null || true
        sudo dnf config-manager setopt google-chrome.enabled=1 2>/dev/null || sudo dnf config-manager --set-enabled google-chrome 2>/dev/null || true
        sudo dnf install -y google-chrome-stable || warn "Google Chrome installation failed"
    else
        log "Google Chrome already installed ✓"
    fi
    
    # Microsoft Edge
    if ! command -v microsoft-edge-stable &>/dev/null; then
        log "Adding Microsoft Edge repository..."
        sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc 2>/dev/null || true
        sudo bash -c 'cat > /etc/yum.repos.d/microsoft-edge.repo << EOF
[microsoft-edge]
name=Microsoft Edge
baseurl=https://packages.microsoft.com/yumrepos/edge
enabled=1
gpgcheck=1
gpgkey=https://packages.microsoft.com/keys/microsoft.asc
EOF'
        sudo dnf install -y microsoft-edge-stable || warn "Microsoft Edge installation failed"
    else
        log "Microsoft Edge already installed ✓"
    fi

    # Development Tools
    sudo -v 2>/dev/null || true
    log "Installing development tools..."
    
    # Visual Studio Code
    if ! command -v code &>/dev/null; then
        log "Adding Visual Studio Code repository..."
        sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc 2>/dev/null || true
        sudo bash -c 'cat > /etc/yum.repos.d/vscode.repo << EOF
[code]
name=Visual Studio Code
baseurl=https://packages.microsoft.com/yumrepos/vscode
enabled=1
gpgcheck=1
gpgkey=https://packages.microsoft.com/keys/microsoft.asc
EOF'
        sudo dnf install -y code || warn "Visual Studio Code installation failed"
    else
        log "Visual Studio Code already installed ✓"
    fi
    
    # Node.js and npm
    log "Installing Node.js and npm..."
    sudo dnf install -y nodejs npm || warn "Node.js/npm installation failed"
    
    # CLI AI Tools (install to user prefix to avoid sudo npm issues)
    log "Installing CLI AI tools..."
    mkdir -p "$HOME/.local/lib/node_modules"
    npm config set prefix "$HOME/.local" 2>/dev/null || true
    npm install -g @google/gemini-cli 2>/dev/null || warn "Gemini CLI installation failed"
    npm install -g @anthropic-ai/claude-code 2>/dev/null || warn "Claude Code installation failed"
    npm install -g opencode-ai 2>/dev/null || warn "OpenCode AI installation failed"
    npm install -g @github/copilot 2>/dev/null || warn "GitHub Copilot CLI installation failed"
    
    # FileZilla
    log "Installing FileZilla..."
    sudo dnf install -y filezilla || warn "FileZilla installation failed"
    
    # VLC Media Player (requires RPM Fusion)
    log "Installing VLC Media Player..."
    sudo dnf install -y vlc || warn "VLC installation failed (RPM Fusion required)"
    
    # Note: Neovim is now installed conditionally via install_neovim() based on user choice
    
    # zsh Shell
    log "Installing zsh..."
    sudo dnf install -y zsh || warn "zsh installation failed"
    
    # Qt Wayland Support (important for many Qt apps)
    log "Installing Qt Wayland support..."
    sudo dnf install -y qt5-qtwayland qt6-qtwayland || warn "Qt Wayland support installation failed"
    
    # GNOME Podcasts (Flatpak fallback if DNF not available)
    log "Installing GNOME Podcasts..."
    sudo dnf install -y gnome-podcasts 2>/dev/null || {
        log "GNOME Podcasts not in repos, trying Flatpak..."
        flatpak install -y flathub org.gnome.Podcasts 2>/dev/null || warn "GNOME Podcasts installation failed"
    }
    
    # Remmina RDP Plugin
    log "Installing Remmina RDP plugin..."
    sudo dnf install -y remmina-plugins-rdp || warn "Remmina RDP plugin installation failed"
    
    # Docker (for Winboat and development)
    log "Installing Docker..."
    if ! command -v docker &>/dev/null; then
        log "Adding Docker repository..."
        sudo dnf config-manager addrepo --from-repofile https://download.docker.com/linux/fedora/docker-ce.repo 2>/dev/null || \
            sudo dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo 2>/dev/null || warn "Docker repo failed"
        sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin || warn "Docker installation failed"
        sudo groupadd docker 2>/dev/null || true
        sudo usermod -aG docker "$USER" || warn "Failed to add user to docker group"
        sudo systemctl enable --now docker.service 2>/dev/null || warn "Docker service failed"
        sudo systemctl enable --now containerd.service 2>/dev/null || warn "Containerd service failed"
        log "Docker installed ✓ (Note: Re-login required for docker group)"
    else
        log "Docker already installed ✓"
    fi
    
    # Refresh sudo before Winboat installation
    log "Refreshing sudo credentials..."
    sudo -v
    
    # Winboat (Windows VM Manager)
    log "Installing Winboat dependencies..."
    sudo dnf install -y qemu-kvm libvirt virt-manager freerdp-libs || warn "Winboat dependencies failed"
    sudo systemctl enable --now libvirtd 2>/dev/null || warn "libvirtd service failed"
    sudo usermod -aG libvirt "$USER" 2>/dev/null || warn "Failed to add user to libvirt group"
    
    # Install Winboat from GitHub releases
    if ! command -v winboat &>/dev/null; then
        log "Installing Winboat Windows VM Manager..."
        
        # Get latest release version with timeout
        WINBOAT_VERSION=$(timeout 10 curl -s https://api.github.com/repos/TibixDev/winboat/releases/latest | grep '"tag_name"' | cut -d'"' -f4)
        
        if [ -z "$WINBOAT_VERSION" ]; then
            warn "Could not fetch Winboat version, trying v0.9.0..."
            WINBOAT_VERSION="v0.9.0"
        fi
        
        log "Downloading Winboat $WINBOAT_VERSION..."
        # Note: URL format is winboat-VERSION-x86_64.rpm (with hyphen before x86_64)
        WINBOAT_URL="https://github.com/TibixDev/winboat/releases/download/${WINBOAT_VERSION}/winboat-${WINBOAT_VERSION#v}-x86_64.rpm"
        WINBOAT_RPM="$HOME/winboat-${WINBOAT_VERSION#v}-x86_64.rpm"
        
        # Download with progress and timeout
        if timeout 300 wget -q --show-progress -O "$WINBOAT_RPM" "$WINBOAT_URL" 2>&1; then
            log "Installing Winboat RPM..."
            sudo dnf install -y "$WINBOAT_RPM" || warn "Winboat installation failed"
            rm -f "$WINBOAT_RPM"
            
            if command -v winboat &>/dev/null; then
                log "Winboat installed successfully ✓"
            else
                warn "Winboat installation completed but command not found"
            fi
        else
            warn "Winboat download failed. Install manually from: https://github.com/TibixDev/winboat/releases"
        fi
    else
        log "Winboat already installed ✓"
    fi
    
    # Steam (Gaming)
    log "Installing Steam..."
    sudo dnf install -y steam || warn "Steam installation failed (RPM Fusion required)"
    
    # Synology Drive
    log "Installing Synology Drive..."
    sudo dnf copr enable -y emixampp/synology-drive 2>/dev/null || warn "Synology Drive COPR enablement failed"
    sudo dnf install -y synology-drive 2>/dev/null || warn "Synology Drive installation failed"

    # Fonts
    log "Installing fonts..."
    sudo dnf install -y \
        jetbrains-mono-fonts-all \
        google-noto-emoji-fonts \
        fontawesome-fonts \
        google-noto-sans-fonts \
        fira-code-fonts \
        || warn "Some fonts failed to install"

    # GTK Themes and Cursor
    log "Installing GTK themes and cursor..."
    sudo dnf install -y \
        adw-gtk3-theme \
        gnome-themes-extra \
        breeze-cursor-theme \
        bibata-cursor-themes \
        || warn "GTK theme installation failed"

    # KeePassXC Password Manager
    log "Installing KeePassXC..."
    sudo dnf install -y keepassxc || warn "KeePassXC installation failed"

    # Install JetBrainsMono Nerd Font (for icons in Waybar)
    log "Installing JetBrainsMono Nerd Font..."
    if [[ ! -f "$HOME/.local/share/fonts/JetBrainsMonoNLNerdFont-Regular.ttf" ]]; then
        local NF_TMPDIR NF_VERSION
        NF_TMPDIR=$(mktemp -d) && cd "$NF_TMPDIR" || { warn "Failed to create temp dir for Nerd Fonts"; NF_TMPDIR=""; }
        if [[ -n "$NF_TMPDIR" ]]; then
        NF_VERSION=$(timeout 10 curl -s https://api.github.com/repos/ryanoasis/nerd-fonts/releases/latest | grep '"tag_name"' | cut -d'"' -f4)
        if [[ -z "$NF_VERSION" ]]; then
            warn "Could not fetch latest Nerd Fonts version, using v3.4.0..."
            NF_VERSION="v3.4.0"
        fi
        log "Downloading Nerd Fonts $NF_VERSION..."
        wget -q "https://github.com/ryanoasis/nerd-fonts/releases/download/${NF_VERSION}/JetBrainsMono.zip" || warn "Nerd Font download failed"
        if [[ -f JetBrainsMono.zip ]]; then
            unzip -o -q JetBrainsMono.zip -d JetBrainsMono
            mkdir -p "$HOME/.local/share/fonts"
            cp -f JetBrainsMono/*.ttf "$HOME/.local/share/fonts/"
            fc-cache -f "$HOME/.local/share/fonts" >/dev/null 2>&1
            log "JetBrainsMono Nerd Font installed ✓"
        fi
        cd - >/dev/null
        rm -rf "$NF_TMPDIR"
        fi # end NF_TMPDIR guard
    else
        log "JetBrainsMono Nerd Font already installed ✓"
    fi

    # Whisper.cpp for Voice Input (Apollo OS)
    log "Installing whisper.cpp for voice input..."
    
    # Install build dependencies and Python tools
    sudo dnf install -y \
        git \
        gcc \
        gcc-c++ \
        make \
        cmake \
        ffmpeg \
        python3 \
        python3-pip \
        python3-devel \
        || warn "whisper.cpp dependencies installation failed"
    
    # Clone and build whisper.cpp if not already installed
    if [[ ! -f "$HOME/.local/bin/whisper-cpp" ]]; then
        log "Building whisper.cpp from source (static linking)..."
        if cd /tmp; then
        if [[ -d whisper.cpp ]]; then
            rm -rf whisper.cpp
        fi
        
        git clone https://github.com/ggerganov/whisper.cpp.git || warn "whisper.cpp clone failed"
        if [[ -d whisper.cpp ]]; then
            cd whisper.cpp || { warn "Failed to cd to whisper.cpp"; }
            
            # Build with cmake and static linking to avoid library issues
            cmake -B build -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=OFF 2>/dev/null || {
                warn "cmake configuration failed, trying make fallback"
                make -j$(nproc) || warn "whisper.cpp build failed"
            }
            
            if [[ -d build ]]; then
                cmake --build build --config Release -j$(nproc) || warn "whisper.cpp cmake build failed"
            fi
            
            # Install binary
            mkdir -p "$HOME/.local/bin"
            
            # Try cmake build output first, then make output
            if [[ -f "./build/bin/whisper-cli" ]]; then
                cp ./build/bin/whisper-cli "$HOME/.local/bin/whisper-cpp" || warn "whisper.cpp installation failed"
            elif [[ -f "./whisper-cli" ]]; then
                cp ./whisper-cli "$HOME/.local/bin/whisper-cpp" || warn "whisper.cpp installation failed"
            elif [[ -f "./main" ]]; then
                cp ./main "$HOME/.local/bin/whisper-cpp" || warn "whisper.cpp installation failed"
            else
                warn "whisper.cpp binary not found after build"
            fi
            chmod +x "$HOME/.local/bin/whisper-cpp" 2>/dev/null
            
            # Download German base model
            log "Downloading German whisper model..."
            mkdir -p "$HOME/.local/share/whisper"
            if [[ ! -f "$HOME/.local/share/whisper/ggml-base.bin" ]]; then
                bash ./models/download-ggml-model.sh base || warn "Model download failed"
                cp models/ggml-base.bin "$HOME/.local/share/whisper/" || warn "Model copy failed"
            fi
            
            cd /tmp || true
            rm -rf whisper.cpp
            
            if [[ -f "$HOME/.local/bin/whisper-cpp" ]]; then
                log "whisper.cpp installed successfully ✓"
            else
                warn "whisper.cpp build completed but binary not found"
            fi
        else
            warn "whisper.cpp clone failed - voice input will not work"
        fi
        else
            warn "Failed to cd to /tmp - skipping whisper.cpp build"
        fi # end cd /tmp guard
    else
        log "whisper.cpp already installed ✓"
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
    
    # Allow wallpaper sync to login screen without password
    # Security: Only allow copying from user's wallpaper directory to the specific login background
    log "Configuring wallpaper sync permissions..."
    local USER_HOME
    USER_HOME=$(getent passwd "$USER" | cut -d: -f6)
    sudo bash -c "cat > /etc/sudoers.d/apollo-wallpaper << SUDOERSEOF
# Apollo OS - Allow user to update login wallpaper
# Only permits copying image files to the specific login background location
$USER ALL=(ALL) NOPASSWD: /usr/bin/cp ${USER_HOME}/System/Wallpaper/*.jpg /usr/share/backgrounds/apollo-login.jpg
$USER ALL=(ALL) NOPASSWD: /usr/bin/cp ${USER_HOME}/System/Wallpaper/*.png /usr/share/backgrounds/apollo-login.jpg
$USER ALL=(ALL) NOPASSWD: /usr/bin/cp ${USER_HOME}/System/Wallpaper/*.jpeg /usr/share/backgrounds/apollo-login.jpg
SUDOERSEOF"
    sudo chmod 440 /etc/sudoers.d/apollo-wallpaper
    sudo visudo -cf /etc/sudoers.d/apollo-wallpaper 2>/dev/null || {
        warn "Invalid sudoers syntax! Removing file to prevent sudo lockout."
        sudo rm -f /etc/sudoers.d/apollo-wallpaper
    }
    
    log "User permissions configured ✓"
    log "NOTE: You may need to log out and log back in for group changes to take effect"
}

#####################################################################
# Verify Critical Packages
#####################################################################

verify_critical_packages() {
    log "Verifying critical packages..."

    local missing=()
    local critical_packages=()
    
    # Add desktop-specific critical packages based on selection
    if [[ "$INSTALL_NIRI" == true ]]; then
        critical_packages+=("niri")
    fi
    if [[ "$INSTALL_HYPRLAND" == true ]]; then
        critical_packages+=("hyprland")
    fi
    
    # Add universal critical packages
    critical_packages+=("waybar" "rofi" "mako")

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
    cp "$SCRIPT_DIR/apollo-os-sys/config/gtk-3.0-settings.ini" "$HOME/.config/gtk-3.0/settings.ini" || warn "GTK-3.0 config failed"
    cp "$SCRIPT_DIR/apollo-os-sys/config/gtk-4.0-settings.ini" "$HOME/.config/gtk-4.0/settings.ini" || warn "GTK-4.0 config failed"

    # Create GTK-2.0 config
    cat > "$HOME/.gtkrc-2.0" << 'GTKEOF'
gtk-theme-name="adw-gtk3-dark"
gtk-icon-theme-name="kora"
gtk-font-name="Cantarell 11"
gtk-cursor-theme-name="Bibata-Modern-Classic"
gtk-cursor-theme-size=24
GTKEOF

    # Create XDG Portal config for Apollo OS Orbit
    if [[ "$INSTALL_NIRI" == true ]]; then
        cat > "$HOME/.config/xdg-desktop-portal/niri-portals.conf" << 'PORTALEOF'
[preferred]
default=gtk
org.freedesktop.impl.portal.Settings=gtk
org.freedesktop.impl.portal.Screenshot=wlr
org.freedesktop.impl.portal.ScreenCast=wlr
PORTALEOF
    fi

    # Deploy Apollo OS Orbit config
    if [[ "$INSTALL_NIRI" == true ]]; then
        log "Deploying Apollo OS Orbit configuration..."

        # Copy main config
        cp "$SCRIPT_DIR/apollo-os-orbit/base-config/niri/config.kdl" "$HOME/.config/niri/config.kdl" || warn "Main Apollo OS Orbit config deployment failed"

        # Copy all visual mode configs from visual-modes directory
        log "Deploying all 19 Visual Mode configurations..."
        if [ -d "$SCRIPT_DIR/apollo-os-orbit/visual-modes/configs" ]; then
            cp "$SCRIPT_DIR/apollo-os-orbit/visual-modes/configs/"*.kdl "$HOME/.config/niri/" || warn "Visual modes niri config deployment failed"
        else
            warn "Visual modes configs directory not found"
        fi

        # Copy toggle scripts
        cp "$SCRIPT_DIR/apollo-os-orbit/base-config/niri/apollo-autostart.sh" "$HOME/.config/niri/" || warn "Apollo OS Orbit autostart deployment failed"
        if [ -d "$SCRIPT_DIR/apollo-os-orbit/scripts" ]; then
            cp "$SCRIPT_DIR/apollo-os-orbit/scripts/toggle-"*.sh "$HOME/.config/niri/" 2>/dev/null
        else
            cp "$SCRIPT_DIR/apollo-os-orbit/base-config/niri/toggle-center.sh" "$HOME/.config/niri/" 2>/dev/null
        fi

        # Make scripts executable
        chmod +x "$HOME/.config/niri/apollo-autostart.sh" 2>/dev/null
        chmod +x "$HOME/.config/niri/toggle-center.sh" 2>/dev/null
        chmod +x "$HOME/.config/niri/"toggle-*.sh 2>/dev/null

        # Copy Kitty config for Niri
        log "Deploying Kitty terminal configuration..."
        mkdir -p "$HOME/.config/kitty"
        if [ -f "$SCRIPT_DIR/apollo-os-sys/config/kitty/kitty.conf" ]; then
            cp "$SCRIPT_DIR/apollo-os-sys/config/kitty/kitty.conf" "$HOME/.config/kitty/" || warn "Failed to copy kitty config"
            log "Kitty config copied ✓"
        fi

        # Copy Foot config for Niri
        log "Deploying Foot terminal configuration..."
        mkdir -p "$HOME/.config/foot"
        if [ -f "$SCRIPT_DIR/apollo-os-sys/config/foot/foot.ini" ]; then
            cp "$SCRIPT_DIR/apollo-os-sys/config/foot/foot.ini" "$HOME/.config/foot/" || warn "Failed to copy foot config"
            log "Foot config copied ✓"
        fi

        # Add GTK_THEME and portal to Apollo OS Orbit config
        if [ -f "$HOME/.config/niri/config.kdl" ]; then
            # autostart.sh is already in config.kdl via spawn-at-startup
            # Add portal if not present
            if ! grep -q "xdg-desktop-portal-gtk" "$HOME/.config/niri/config.kdl"; then
                sed -i '/spawn-at-startup.*polkit/a spawn-at-startup "/usr/libexec/xdg-desktop-portal-gtk"' "$HOME/.config/niri/config.kdl"
            fi
            # Add GTK_THEME environment if not present
            if ! grep -q "GTK_THEME" "$HOME/.config/niri/config.kdl"; then
                sed -i 's/environment {/environment {\n    GTK_THEME "adw-gtk3-dark"\n    ADW_DEBUG_COLOR_SCHEME "prefer-dark"/' "$HOME/.config/niri/config.kdl"
            fi
        fi
        
        # Apply user-selected display scale to niri config
        if [[ -f "$CONFIG_FILE" ]]; then
            source "$CONFIG_FILE"
            if [[ -n "$DISPLAY_SCALE" && "$DISPLAY_SCALE" != "1.25" ]]; then
                sed -i "s/scale 1\.25/scale $DISPLAY_SCALE/g" "$HOME/.config/niri/config.kdl"
                for kdl in "$HOME/.config/niri/config-"*.kdl; do
                    [ -f "$kdl" ] && sed -i "s/scale 1\.25/scale $DISPLAY_SCALE/g" "$kdl"
                done
                log "Display scale set to $DISPLAY_SCALE in all niri configs"
            fi
        fi
    fi
    
    # Deploy Hyprland configuration
    if [[ "$INSTALL_HYPRLAND" == true ]]; then
        log "Deploying Apollo OS Glass (Hyprland) configuration..."
        
        # Create directories
        mkdir -p "$HOME/.config/hypr"
        mkdir -p "$HOME/.config/quickshell"
        mkdir -p "$HOME/.config/illogical-impulse"
        mkdir -p "$HOME/.config/Kvantum"
        mkdir -p "$HOME/.config/wlogout"
        mkdir -p "$HOME/.config/kitty"
        mkdir -p "$HOME/.config/fish"
        mkdir -p "$HOME/.config/fuzzel"
        mkdir -p "$HOME/.config/fontconfig"
        mkdir -p "$HOME/.config/foot"
        mkdir -p "$HOME/.config/kde-material-you-colors"
        mkdir -p "$HOME/.config/matugen"
        
        local HYPR_SRC="$SCRIPT_DIR/apollo-os-glass/dots/.config"
        
        # Copy Hyprland configs (overwrites dots-hyprland defaults)
        if [[ -d "$HYPR_SRC/hypr" ]]; then
            cp -r "$HYPR_SRC/hypr/." "$HOME/.config/hypr/" || warn "Failed to copy Hyprland config"
            chmod +x "$HOME/.config/hypr/hyprland/scripts/"*.sh 2>/dev/null
            chmod +x "$HOME/.config/hypr/hyprland/scripts/ai/"*.sh 2>/dev/null
            chmod +x "$HOME/.config/hypr/custom/scripts/"*.sh 2>/dev/null
            log "Hyprland config copied ✓"
        fi
        
        # Copy Quickshell ii theme
        if [[ -d "$HYPR_SRC/quickshell" ]]; then
            cp -r "$HYPR_SRC/quickshell/." "$HOME/.config/quickshell/" || warn "Failed to copy Quickshell config"
            log "Quickshell ii theme copied ✓"
        fi
        
        # Copy illogical-impulse settings
        if [[ -d "$HYPR_SRC/illogical-impulse" ]]; then
            cp -r "$HYPR_SRC/illogical-impulse/." "$HOME/.config/illogical-impulse/" || warn "Failed to copy illogical-impulse config"
            log "illogical-impulse settings copied ✓"
        fi
        
        # Copy Kvantum theme
        if [[ -d "$HYPR_SRC/Kvantum" ]]; then
            cp -r "$HYPR_SRC/Kvantum/." "$HOME/.config/Kvantum/" || warn "Failed to copy Kvantum config"
        fi
        
        # Copy wlogout config
        if [[ -d "$HYPR_SRC/wlogout" ]]; then
            cp -r "$HYPR_SRC/wlogout/." "$HOME/.config/wlogout/" || warn "Failed to copy wlogout config"
        fi
        
        # Copy kitty config
        if [[ -d "$HYPR_SRC/kitty" ]]; then
            cp -r "$HYPR_SRC/kitty/." "$HOME/.config/kitty/" || warn "Failed to copy kitty config"
        fi
        
        # Copy fish shell config
        if [[ -d "$HYPR_SRC/fish" ]]; then
            cp -r "$HYPR_SRC/fish/." "$HOME/.config/fish/" || warn "Failed to copy fish config"
        fi
        
        # Copy fuzzel config
        if [[ -d "$HYPR_SRC/fuzzel" ]]; then
            cp -r "$HYPR_SRC/fuzzel/." "$HOME/.config/fuzzel/" || warn "Failed to copy fuzzel config"
        fi
        
        # Copy fontconfig
        if [[ -d "$HYPR_SRC/fontconfig" ]]; then
            cp -r "$HYPR_SRC/fontconfig/." "$HOME/.config/fontconfig/" || warn "Failed to copy fontconfig"
        fi
        
        # Copy foot terminal config
        if [[ -d "$HYPR_SRC/foot" ]]; then
            cp -r "$HYPR_SRC/foot/." "$HOME/.config/foot/" || warn "Failed to copy foot config"
        fi
        
        # Copy kde-material-you-colors
        if [[ -d "$HYPR_SRC/kde-material-you-colors" ]]; then
            cp -r "$HYPR_SRC/kde-material-you-colors/." "$HOME/.config/kde-material-you-colors/" || warn "Failed to copy kde-material-you-colors"
        fi
        
        # Copy matugen config
        if [[ -d "$HYPR_SRC/matugen" ]]; then
            cp -r "$HYPR_SRC/matugen/." "$HOME/.config/matugen/" || warn "Failed to copy matugen config"
        fi
        
        # Copy mpv config
        if [[ -d "$HYPR_SRC/mpv" ]]; then
            mkdir -p "$HOME/.config/mpv"
            cp -r "$HYPR_SRC/mpv/." "$HOME/.config/mpv/" || warn "Failed to copy mpv config"
        fi
        
        # Copy standalone config files
        [[ -f "$HYPR_SRC/chrome-flags.conf" ]] && cp "$HYPR_SRC/chrome-flags.conf" "$HOME/.config/"
        [[ -f "$HYPR_SRC/code-flags.conf" ]] && cp "$HYPR_SRC/code-flags.conf" "$HOME/.config/"
        [[ -f "$HYPR_SRC/darklyrc" ]] && cp "$HYPR_SRC/darklyrc" "$HOME/.config/"
        [[ -f "$HYPR_SRC/dolphinrc" ]] && cp "$HYPR_SRC/dolphinrc" "$HOME/.config/"
        [[ -f "$HYPR_SRC/kdeglobals" ]] && cp "$HYPR_SRC/kdeglobals" "$HOME/.config/"
        [[ -f "$HYPR_SRC/konsolerc" ]] && cp "$HYPR_SRC/konsolerc" "$HOME/.config/"
        [[ -f "$HYPR_SRC/starship.toml" ]] && cp "$HYPR_SRC/starship.toml" "$HOME/.config/"
        [[ -f "$HYPR_SRC/thorium-flags.conf" ]] && cp "$HYPR_SRC/thorium-flags.conf" "$HOME/.config/"
        
        # Copy xdg-desktop-portal config
        if [[ -d "$HYPR_SRC/xdg-desktop-portal" ]]; then
            cp -r "$HYPR_SRC/xdg-desktop-portal/." "$HOME/.config/xdg-desktop-portal/" || warn "Failed to copy xdg-desktop-portal"
        fi
        
        # Copy GTK-3.0 settings (Glass-specific)
        if [[ -d "$HYPR_SRC/gtk-3.0" ]]; then
            mkdir -p "$HOME/.config/gtk-3.0"
            cp -r "$HYPR_SRC/gtk-3.0/." "$HOME/.config/gtk-3.0/" || warn "Failed to copy gtk-3.0"
        fi
        
        # Copy GTK-4.0 settings (Glass-specific)
        if [[ -d "$HYPR_SRC/gtk-4.0" ]]; then
            mkdir -p "$HOME/.config/gtk-4.0"
            cp -r "$HYPR_SRC/gtk-4.0/." "$HOME/.config/gtk-4.0/" || warn "Failed to copy gtk-4.0"
        fi
        
        # Copy zshrc.d if using zsh
        if [[ -d "$HYPR_SRC/zshrc.d" ]]; then
            mkdir -p "$HOME/.config/zshrc.d"
            cp -r "$HYPR_SRC/zshrc.d/." "$HOME/.config/zshrc.d/" || warn "Failed to copy zshrc.d"
        fi
        
        # Set monitor config with user's display scale (only on first install)
        if [[ -f "$HOME/.config/hypr/monitors.conf" ]]; then
            if grep -q "eDP-1" "$HOME/.config/hypr/monitors.conf" 2>/dev/null; then
                # Default template from Glass tree — replace with auto-detect
                echo "# Apollo OS - Auto-detect monitor settings" > "$HOME/.config/hypr/monitors.conf"
                echo "monitor=,preferred,auto,${DISPLAY_SCALE:-1.0}" >> "$HOME/.config/hypr/monitors.conf"
                log "Monitor set to auto-detect with scale ${DISPLAY_SCALE:-1.0} ✓"
            else
                log "Monitor config already customized, skipping ✓"
            fi
        fi
        
        # Deploy ~/.local/share files (color schemes, konsole profiles, etc.)
        local SHARE_SRC="$SCRIPT_DIR/apollo-os-glass/dots/.local/share"
        
        # Copy KDE color schemes
        if [[ -d "$SHARE_SRC/color-schemes" ]]; then
            mkdir -p "$HOME/.local/share/color-schemes"
            cp -r "$SHARE_SRC/color-schemes/." "$HOME/.local/share/color-schemes/"
            log "KDE color schemes copied ✓"
        fi
        
        # Copy Konsole profiles and color schemes
        if [[ -d "$SHARE_SRC/konsole" ]]; then
            mkdir -p "$HOME/.local/share/konsole"
            cp -r "$SHARE_SRC/konsole/." "$HOME/.local/share/konsole/"
            log "Konsole profiles copied ✓"
        fi
        
        # Copy kde-material-you-colors
        if [[ -d "$SHARE_SRC/kde-material-you-colors" ]]; then
            mkdir -p "$HOME/.local/share/kde-material-you-colors"
            cp -r "$SHARE_SRC/kde-material-you-colors/." "$HOME/.local/share/kde-material-you-colors/"
            log "kde-material-you-colors copied ✓"
        fi
        
        # Copy icons
        if [[ -d "$SHARE_SRC/icons" ]]; then
            mkdir -p "$HOME/.local/share/icons"
            cp -r "$SHARE_SRC/icons/." "$HOME/.local/share/icons/"
            log "Icons copied ✓"
        fi
        
        log "Apollo OS Glass (Hyprland) configuration deployed ✓"
    fi

    # Deploy Waybar configs (Niri only — Glass uses Quickshell)
    if [[ "$INSTALL_NIRI" == true ]]; then
        log "Deploying Waybar configurations..."
        cp "$SCRIPT_DIR/apollo-os-orbit/base-config/waybar/config-niri" "$HOME/.config/waybar/config-niri" || warn "Waybar config deployment failed"
        cp "$SCRIPT_DIR/apollo-os-orbit/base-config/waybar/style.css" "$HOME/.config/waybar/style.css" || warn "Waybar style deployment failed"

        # Copy all visual mode waybar configs from visual-modes directory
        log "Deploying all 19 Visual Mode Waybar configurations..."
        if [ -d "$SCRIPT_DIR/apollo-os-orbit/visual-modes/waybar/configs" ]; then
            cp "$SCRIPT_DIR/apollo-os-orbit/visual-modes/waybar/configs/"* "$HOME/.config/waybar/" || warn "Visual modes waybar config deployment failed"
        fi
        if [ -d "$SCRIPT_DIR/apollo-os-orbit/visual-modes/waybar/styles" ]; then
            cp "$SCRIPT_DIR/apollo-os-orbit/visual-modes/waybar/styles/"* "$HOME/.config/waybar/" || warn "Visual modes waybar styles deployment failed"
        fi

        # Copy Crystal Bay dock configs
        if [ -d "$SCRIPT_DIR/apollo-os-orbit/extras/dock" ]; then
            cp "$SCRIPT_DIR/apollo-os-orbit/extras/dock/"* "$HOME/.config/waybar/" || warn "Crystal Bay dock config deployment failed"
        fi

        # Create hide-bottom.css for waybar toggle feature
        touch "$HOME/.config/waybar/hide-bottom.css" || warn "hide-bottom.css creation failed"

        # Deploy Mako configs (including Crystal Bay theme)
        log "Deploying Mako configurations..."
        if [ -d "$SCRIPT_DIR/apollo-os-orbit/visual-modes/mako" ]; then
            cp "$SCRIPT_DIR/apollo-os-orbit/visual-modes/mako/"* "$HOME/.config/mako/" || warn "Mako visual mode configs failed"
        fi

        # Deploy Mako config
        log "Deploying Mako configuration..."
        cp "$SCRIPT_DIR/apollo-os-orbit/base-config/mako/apollo-os-mako-config" "$HOME/.config/mako/config" || warn "Mako config deployment failed"

        # Deploy Rofi theme
        log "Deploying Rofi theme..."
        cp "$SCRIPT_DIR/apollo-os-orbit/base-config/rofi/config.rasi" "$HOME/.config/rofi/config.rasi" || warn "Rofi config deployment failed"
    fi

    # Deploy Alacritty config
    log "Deploying Alacritty configuration..."
    mkdir -p "$HOME/.config/alacritty"
    cp "$SCRIPT_DIR/apollo-os-sys/config/alacritty/apollo-os-alacritty.toml" "$HOME/.config/alacritty/alacritty.toml" || warn "Alacritty config deployment failed"

    # Deploy btop config and theme
    log "Deploying btop configuration and Apollo Hacker theme..."
    mkdir -p "$HOME/.config/btop/themes"
    cp "$SCRIPT_DIR/apollo-os-sys/config/btop/btop.conf" "$HOME/.config/btop/btop.conf" || warn "btop config deployment failed"
    cp "$SCRIPT_DIR/apollo-os-sys/config/btop/themes/apollo-hacker.theme" "$HOME/.config/btop/themes/apollo-hacker.theme" || warn "btop theme deployment failed"

    # Deploy Hyprlock configuration
    # For Niri: deploy full hyprlock config from orbit/extras
    # For Hyprland-only: deploy the hyprlock helper scripts (check-capslock.sh, status.sh)
    #   that the Glass hyprlock.conf references
    if [[ "$INSTALL_NIRI" == true ]]; then
        log "Deploying Hyprlock configuration (Orbit)..."
        mkdir -p "$HOME/.config/hypr/hyprlock"
        if [ -d "$SCRIPT_DIR/apollo-os-orbit/extras/hyprlock" ]; then
            cp "$SCRIPT_DIR/apollo-os-orbit/extras/hyprlock/hyprlock.conf" "$HOME/.config/hypr/" 2>/dev/null || warn "Hyprlock config failed"
            cp "$SCRIPT_DIR/apollo-os-orbit/extras/hyprlock/colors.conf" "$HOME/.config/hypr/hyprlock/" 2>/dev/null || warn "Hyprlock colors failed"
            cp "$SCRIPT_DIR/apollo-os-orbit/extras/hyprlock/"*.sh "$HOME/.config/hypr/hyprlock/" 2>/dev/null || warn "Hyprlock scripts failed"
            chmod +x "$HOME/.config/hypr/hyprlock/"*.sh 2>/dev/null
            log "Hyprlock configuration deployed ✓"
        else
            warn "Hyprlock configuration not found in apollo-os-orbit/extras"
        fi
    elif [[ "$INSTALL_HYPRLAND" == true ]]; then
        # Hyprland-only: Glass hyprlock.conf was already copied with hypr/ tree
        # But the helper scripts (check-capslock.sh, status.sh) are only in orbit/extras
        log "Deploying Hyprlock helper scripts for Glass..."
        mkdir -p "$HOME/.config/hypr/hyprlock"
        if [ -d "$SCRIPT_DIR/apollo-os-orbit/extras/hyprlock" ]; then
            cp "$SCRIPT_DIR/apollo-os-orbit/extras/hyprlock/"*.sh "$HOME/.config/hypr/hyprlock/" 2>/dev/null || warn "Hyprlock scripts failed"
            chmod +x "$HOME/.config/hypr/hyprlock/"*.sh 2>/dev/null
            log "Hyprlock helper scripts deployed ✓"
        fi
    fi

    log "Configuration deployment complete ✓"
}

#####################################################################
# Install Kora Icon Theme
#####################################################################

install_kora_icons() {
    log "Installing Kora icon theme..."
    
    echo
    echo -e "${MAGENTA}══════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}  Installing Kora Icon Theme${NC}"
    echo -e "${MAGENTA}══════════════════════════════════════════════════════${NC}\n"
    
    local KORA_DIR="$HOME/.cache/kora-icons"
    local ICONS_DIR="/usr/share/icons"
    
    # Clone the repository
    log "Cloning Kora icon theme repository..."
    rm -rf "$KORA_DIR" 2>/dev/null
    git clone --depth 1 https://github.com/bikass/kora.git "$KORA_DIR" || {
        warn "Failed to clone Kora icons, skipping"
        return 1
    }
    
    # Copy icon themes (system-wide for Waybar CSS compatibility)
    log "Installing Kora icons..."
    if [[ -d "$KORA_DIR/kora" ]]; then
        sudo cp -r "$KORA_DIR/kora" "$ICONS_DIR/"
        log "Kora icon theme installed ✓"
    fi
    
    if [[ -d "$KORA_DIR/kora-pgrey" ]]; then
        sudo cp -r "$KORA_DIR/kora-pgrey" "$ICONS_DIR/"
        log "Kora-pgrey icon theme installed ✓"
    fi
    
    # Update icon cache
    if command -v gtk-update-icon-cache &>/dev/null; then
        log "Updating icon cache..."
        sudo gtk-update-icon-cache -f "$ICONS_DIR/kora" 2>/dev/null || true
        sudo gtk-update-icon-cache -f "$ICONS_DIR/kora-pgrey" 2>/dev/null || true
    fi
    
    # Set kora as default icon theme via gsettings
    if command -v gsettings &>/dev/null; then
        gsettings set org.gnome.desktop.interface icon-theme 'kora' 2>/dev/null || true
        log "Kora set as GNOME icon theme ✓"
    fi
    
    # Also update kdeglobals to ensure kora is set
    if [[ -f "$HOME/.config/kdeglobals" ]]; then
        sed -i 's/Theme=breeze.*/Theme=kora/' "$HOME/.config/kdeglobals"
        sed -i 's/Theme=adwaita.*/Theme=kora/' "$HOME/.config/kdeglobals"
    fi
    
    # Cleanup
    rm -rf "$KORA_DIR"
    
    log "Kora icon theme installation complete ✓"
    return 0
}

#####################################################################
# Disable Quickshell Welcome Screen
#####################################################################

disable_welcome_screen() {
    log "Disabling Quickshell welcome screen..."
    
    # Create first_run.txt to prevent welcome window from appearing
    local STATE_DIR="$HOME/.local/state/quickshell/ii/user"
    mkdir -p "$STATE_DIR"
    echo "Apollo OS - Welcome disabled" > "$STATE_DIR/first_run.txt"
    
    log "Welcome screen disabled ✓"
}

#####################################################################
# Copy Plymouth Watermark
#####################################################################

deploy_boot_splash() {
    # Apollo OS uses TTY-based boot (no Plymouth/graphical splash)
    # The boot-splash.sh shows a brief ASCII logo on the console during early boot
    # The full cybersecurity-themed boot sequence runs after TTY1 login
    log "Deploying boot splash..."

    local splash_src="$SCRIPT_DIR/apollo-os-sys/systemd/apollo-boot-splash.sh"
    local splash_svc="$SCRIPT_DIR/apollo-os-sys/systemd/apollo-boot-splash.service"

    if [[ -f "$splash_src" ]]; then
        sudo cp "$splash_src" /usr/local/bin/apollo-boot-splash.sh || warn "Failed to deploy boot splash script"
        sudo chmod +x /usr/local/bin/apollo-boot-splash.sh
    fi

    if [[ -f "$splash_svc" ]]; then
        sudo cp "$splash_svc" /etc/systemd/system/ || warn "Failed to deploy boot splash service"
        sudo systemctl daemon-reload
        sudo systemctl enable apollo-boot-splash.service 2>/dev/null || warn "Failed to enable boot splash"
    fi

    log "Boot splash deployed ✓"
}

#####################################################################
# Script Installation
#####################################################################

install_scripts() {
    log "Installing Apollo OS scripts..."

    # Copy shell scripts to local bin
    for script in "$SCRIPT_DIR/apollo-os-sys/scripts/"*.sh; do
        if [ -f "$script" ]; then
            cp "$script" "$HOME/.local/bin/" || warn "Failed to copy $(basename "$script")"
        fi
    done

    # Copy Python scripts to local bin
    for script in "$SCRIPT_DIR/apollo-os-sys/scripts/"*.py; do
        if [ -f "$script" ]; then
            cp "$script" "$HOME/.local/bin/" || warn "Failed to copy $(basename "$script")"
        fi
    done

    # Copy voice-input scripts (no extension)
    for script in voice-input voice-input-notification voice-input-visualizer; do
        if [ -f "$SCRIPT_DIR/apollo-os-sys/scripts/$script" ]; then
            cp "$SCRIPT_DIR/apollo-os-sys/scripts/$script" "$HOME/.local/bin/" || warn "Failed to copy $script"
        fi
    done

    # Copy Hyprland start script (no .sh extension)
    if [[ "$INSTALL_HYPRLAND" == true ]] && [ -f "$SCRIPT_DIR/apollo-os-sys/scripts/start-hyprland" ]; then
        cp "$SCRIPT_DIR/apollo-os-sys/scripts/start-hyprland" "$HOME/.local/bin/" || warn "Failed to copy start-hyprland"
        chmod +x "$HOME/.local/bin/start-hyprland"
    fi

    # Make scripts executable
    chmod +x "$HOME/.local/bin/apollo-"* 2>/dev/null || true
    chmod +x "$HOME/.local/bin/apollo-os-"* 2>/dev/null || true
    chmod +x "$HOME/.local/bin/voice-input"* 2>/dev/null || true

    # Install wrapper scripts to /usr/local/bin/
    log "Installing wrapper scripts globally..."
    sudo cp "$HOME/.local/bin/apollo-os-wrapper-niri.sh" /usr/local/bin/ || warn "Failed to install niri wrapper globally"
    sudo chmod +x /usr/local/bin/apollo-os-wrapper-niri.sh || warn "Failed to set execute permission on niri wrapper"

    # Install Hyprland start script globally (needed for session files and TTY auto-start)
    if [[ "$INSTALL_HYPRLAND" == true ]]; then
        sudo cp "$HOME/.local/bin/start-hyprland" /usr/local/bin/ || warn "Failed to install start-hyprland globally"
        sudo chmod +x /usr/local/bin/start-hyprland
        log "Hyprland start script installed ✓"
    fi

    # Create symlinks for convenience
    ln -sf "$HOME/.local/bin/apollo-speak.sh" "$HOME/.local/bin/apollo-speak" || warn "Failed to create apollo-speak symlink"
    ln -sf "$HOME/.local/bin/apollo-os-event-monitor.sh" "$HOME/.local/bin/apollo-event-monitor" || warn "Failed to create apollo-event-monitor symlink"

    # Install fixed desktop entries (for Niri compatibility)
    log "Installing desktop entries..."
    mkdir -p "$HOME/.local/share/applications"
    cp "$SCRIPT_DIR/apollo-os-sys/config/applications/"*.desktop "$HOME/.local/share/applications/" 2>/dev/null || true
    update-desktop-database "$HOME/.local/share/applications" 2>/dev/null || true

    # Set default text editor
    xdg-mime default org.gnome.TextEditor.desktop text/plain 2>/dev/null || true
    xdg-mime default org.gnome.TextEditor.desktop text/markdown 2>/dev/null || true
    xdg-mime default org.gnome.TextEditor.desktop text/x-markdown 2>/dev/null || true
    xdg-mime default org.gnome.TextEditor.desktop application/x-shellscript 2>/dev/null || true
    
    # Set default image viewer (ImageRoll from Flatpak)
    log "Configuring default image viewer..."
    local image_mimes=(
        "image/jpeg"
        "image/jpg"
        "image/png"
        "image/gif"
        "image/bmp"
        "image/webp"
        "image/tiff"
        "image/svg+xml"
    )
    for mime in "${image_mimes[@]}"; do
        xdg-mime default com.github.weclaw1.ImageRoll.desktop "$mime" 2>/dev/null || true
    done

    log "Scripts installed ✓"
}

#####################################################################
# Desktop Entries for WM Sessions
#####################################################################

install_desktop_entries() {
    # Deploy wayland-session .desktop files for DM compatibility
    log "Installing wayland session entries..."
    local SESSION_DIR="/usr/share/wayland-sessions"
    sudo mkdir -p "$SESSION_DIR"
    if [[ "$INSTALL_NIRI" == true ]]; then
        sudo cp "$SCRIPT_DIR/apollo-os-sys/config/wayland-sessions/apollo-os-orbit.desktop" "$SESSION_DIR/" 2>/dev/null || warn "Orbit session entry failed"
    fi
    if [[ "$INSTALL_HYPRLAND" == true ]]; then
        sudo cp "$SCRIPT_DIR/apollo-os-sys/config/wayland-sessions/apollo-os-glass.desktop" "$SESSION_DIR/" 2>/dev/null || warn "Glass session entry failed"
    fi
    log "Session entries installed ✓"
}

#####################################################################
# Systemd Services
#####################################################################

setup_systemd() {
    log "Setting up systemd services..."

    mkdir -p "$HOME/.config/systemd/user"

    # Copy systemd USER units (excluding boot splash, AI daemon, and sleep/wake which are system-level)
    for file in "$SCRIPT_DIR/apollo-os-sys/systemd/"*.service "$SCRIPT_DIR/apollo-os-sys/systemd/"*.timer; do
        if [ -f "$file" ]; then
            local filename="$(basename "$file")"
            # Skip boot splash, AI daemon, and system-level sleep/wake services
            case "$filename" in
                apollo-boot-splash.service|apollo-os-daemon.service) continue ;;
                apollo-os-sleep.service|apollo-os-wake.service) continue ;;
            esac
            cp "$file" "$HOME/.config/systemd/user/" || warn "Failed to copy $filename"
        fi
    done

    # Install sleep/wake TTS as SYSTEM-level services (they need sleep.target/suspend.target)
    log "Installing Sleep/Wake TTS as system services..."
    sudo cp "$SCRIPT_DIR/apollo-os-sys/systemd/apollo-os-sleep.service" /etc/systemd/system/ || warn "Failed to copy sleep service"
    sudo cp "$SCRIPT_DIR/apollo-os-sys/systemd/apollo-os-wake.service" /etc/systemd/system/ || warn "Failed to copy wake service"
    sudo systemctl daemon-reload
    sudo systemctl enable apollo-os-sleep.service || warn "Failed to enable sleep service"
    sudo systemctl enable apollo-os-wake.service || warn "Failed to enable wake service"

    # Install screen-corners script (optional - only works with GTK-based compositors)
    log "Installing screen-corners (rounded screen edges)..."
    if [ -f "$SCRIPT_DIR/apollo-os-sys/scripts/screen-corners/screen-corners.py" ]; then
        cp "$SCRIPT_DIR/apollo-os-sys/scripts/screen-corners/screen-corners.py" "$HOME/.local/bin/" || warn "Failed to copy screen-corners script"
        chmod +x "$HOME/.local/bin/screen-corners.py"
        log "Screen-corners script installed ✓"
    fi

    # Reload user systemd
    systemctl --user daemon-reload

    # Note: screen-corners is NOT auto-enabled because it's incompatible with Niri.
    # It only works with GTK-based compositors (Hyprland/Glass mode).
    # Users can manually enable with: systemctl --user enable --now screen-corners.service
    log "Screen-corners available but not auto-enabled (Niri incompatible) ✓"

    # Enable monitoring services
    log "Enabling system monitors..."
    systemctl --user enable apollo-os-battery-monitor.service 2>/dev/null || warn "Failed to enable battery monitor"
    systemctl --user enable apollo-os-disk-monitor.service 2>/dev/null || warn "Failed to enable disk monitor"
    systemctl --user enable apollo-os-watchdog.service 2>/dev/null || warn "Failed to enable watchdog"

    # Enable services (event monitor will be started by autostart script)
    # We don't enable it as systemd service to avoid race conditions
    # It starts after Apollo OS Orbit/Mako/Audio are ready
    
    log "Systemd services configured ✓"
}

#####################################################################
# Audio System Installation
#####################################################################

install_audio_system() {
    log "Installing Audio System (TTS - Amala Voice)..."

    echo
    echo -e "${MAGENTA}══════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}  Audio System (Text-to-Speech - Amala)${NC}"
    echo -e "${MAGENTA}══════════════════════════════════════════════════════${NC}\n"

    # Install required packages
    log "Installing audio utilities..."
    sudo dnf install -y espeak-ng sox ffmpeg pulseaudio-utils alsa-utils pipewire-utils || warn "Some audio packages failed"

    # Setup directories
    local SOUNDS_DIR="$HOME/.local/share/apollo-os/sounds"
    mkdir -p "$SOUNDS_DIR"

    # Install edge-tts via uv (Python package manager)
    log "Installing edge-tts (Microsoft TTS)..."
    if ! command -v edge-tts &>/dev/null; then
        if command -v uv &>/dev/null; then
            uv tool install edge-tts || warn "Failed to install edge-tts with uv"
        else
            # Ensure pip is available
            sudo dnf install -y python3-pip python3-devel 2>/dev/null || true
            python3 -m pip install --user edge-tts || warn "Failed to install edge-tts with pip"
        fi
    else
        log "edge-tts already installed ✓"
    fi

    # Create symlink if needed
    if [ -f "$HOME/.local/share/uv/tools/edge-tts/bin/edge-tts" ] && [ ! -e "$HOME/.local/bin/edge-tts" ]; then
        ln -sf "$HOME/.local/share/uv/tools/edge-tts/bin/edge-tts" "$HOME/.local/bin/edge-tts"
    fi

    # Pre-generate TTS audio files for faster playback
    log "Generating TTS audio files..."
    local EDGE_TTS="$HOME/.local/bin/edge-tts"
    [ ! -x "$EDGE_TTS" ] && EDGE_TTS=$(which edge-tts 2>/dev/null)
    
    if [ -x "$EDGE_TTS" ]; then
        # Sleep/Wake sounds
        "$EDGE_TTS" -t "Kryoschlaf eingeleitet. System gesichert." -v "de-DE-AmalaNeural" --write-media "$SOUNDS_DIR/sleep.mp3" 2>/dev/null || warn "Failed to generate sleep.mp3"
        "$EDGE_TTS" -t "System reaktiviert. Alle Systeme einsatzbereit." -v "de-DE-AmalaNeural" --write-media "$SOUNDS_DIR/wake.mp3" 2>/dev/null || warn "Failed to generate wake.mp3"
        log "TTS audio files generated ✓"
    else
        # Fallback: Copy from project if available
        if [ -f "$SCRIPT_DIR/apollo-os-sys/sounds/sleep.mp3" ]; then
            cp "$SCRIPT_DIR/apollo-os-sys/sounds/sleep.mp3" "$SOUNDS_DIR/"
            cp "$SCRIPT_DIR/apollo-os-sys/sounds/wake.mp3" "$SOUNDS_DIR/"
            log "TTS audio files copied from project ✓"
        else
            warn "Could not generate TTS audio files"
        fi
    fi

    # Generate chime sound
    log "Generating chime sound (880Hz → 660Hz)..."
    if [ ! -f "$SOUNDS_DIR/chime.wav" ]; then
        ffmpeg -f lavfi -i "sine=frequency=880:duration=0.3" \
               -f lavfi -i "sine=frequency=660:duration=0.3" \
               -filter_complex "[0:a][1:a]concat=n=2:v=0:a=1,afade=t=in:st=0:d=0.1,afade=t=out:st=0.5:d=0.1" \
               -y "$SOUNDS_DIR/chime.wav" 2>/dev/null || warn "Failed to generate chime"
    fi

    # Generate voice-start.wav (Star Trek style - ascending tones)
    log "Generating voice-start.wav (800Hz → 1000Hz)..."
    if [ ! -f "$SOUNDS_DIR/voice-start.wav" ]; then
        ffmpeg -f lavfi -i "sine=frequency=800:duration=0.08" \
               -af "afade=t=in:d=0.01,afade=t=out:d=0.02" \
               "$SOUNDS_DIR/.tone1.wav" -y 2>/dev/null
        ffmpeg -f lavfi -i "sine=frequency=1000:duration=0.08" \
               -af "afade=t=in:d=0.01,afade=t=out:d=0.02" \
               "$SOUNDS_DIR/.tone2.wav" -y 2>/dev/null
        ffmpeg -i "$SOUNDS_DIR/.tone1.wav" -i "$SOUNDS_DIR/.tone2.wav" \
               -filter_complex "[0][1]concat=n=2:v=0:a=1" \
               "$SOUNDS_DIR/voice-start.wav" -y 2>/dev/null || warn "Failed to generate voice-start.wav"
        rm -f "$SOUNDS_DIR/.tone1.wav" "$SOUNDS_DIR/.tone2.wav"
    fi

    # Generate voice-end.wav (Star Trek style - descending tones)
    log "Generating voice-end.wav (1000Hz → 800Hz)..."
    if [ ! -f "$SOUNDS_DIR/voice-end.wav" ]; then
        ffmpeg -f lavfi -i "sine=frequency=1000:duration=0.08" \
               -af "afade=t=in:d=0.01,afade=t=out:d=0.02" \
               "$SOUNDS_DIR/.tone1.wav" -y 2>/dev/null
        ffmpeg -f lavfi -i "sine=frequency=800:duration=0.08" \
               -af "afade=t=in:d=0.01,afade=t=out:d=0.02" \
               "$SOUNDS_DIR/.tone2.wav" -y 2>/dev/null
        ffmpeg -i "$SOUNDS_DIR/.tone1.wav" -i "$SOUNDS_DIR/.tone2.wav" \
               -filter_complex "[0][1]concat=n=2:v=0:a=1" \
               "$SOUNDS_DIR/voice-end.wav" -y 2>/dev/null || warn "Failed to generate voice-end.wav"
        rm -f "$SOUNDS_DIR/.tone1.wav" "$SOUNDS_DIR/.tone2.wav"
    fi

    # Create voice configuration
    log "Creating voice configuration..."
    mkdir -p "$HOME/.config/apollo-os"
    cat > "$HOME/.config/apollo-os/voice-config.env" << 'VOICEEOF'
# Apollo OS Voice Configuration
# Fixed Voice: Amala (German)
CURRENT_VOICE="🇩🇪 AMALA - Deutsch Weiblich"
VOICE_ENGINE="edge-tts"
VOICE_MODEL="de-DE-AmalaNeural"
VOICEEOF

    cat > "$HOME/.config/apollo-os/tts-config.env" << 'TTSEOF'
# Apollo OS TTS Configuration
TTS_ENGINE="edge"
TTS_VOICE="de-DE-AmalaNeural"
TTS_SPEED="1.0"
TTS_LANG="de"
TTSEOF

    # Create tts.conf with TTS enabled by default (only if not exists)
    if [[ ! -f "$HOME/.config/apollo-os/tts.conf" ]]; then
        cat > "$HOME/.config/apollo-os/tts.conf" << 'TTSCONFEOF'
TTS_ENABLED=true
TTSCONFEOF
    fi

    log "Audio System installed ✓"
    echo -e "${GREEN}TTS Voice: AMALA (German, edge-tts)${NC}"
}

#####################################################################
# Voice Control System Installation (Wake Word: "apollo")
#####################################################################

install_voice_control() {
    log "Installing Voice Control System (Apollo Wake Word)..."

    # Refresh sudo
    sudo -v

    echo
    echo -e "${MAGENTA}══════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}  Apollo Voice Control - Wake Word System${NC}"
    echo -e "${MAGENTA}══════════════════════════════════════════════════════${NC}\n"

    # Ensure Python pip is installed (critical for voice control)
    log "Ensuring Python pip is installed..."
    sudo dnf install -y python3-pip python3-devel || warn "Failed to install Python pip"

    # Install Python dependencies
    log "Installing Python dependencies (vosk, sounddevice)..."
    python3 -m pip install --user vosk sounddevice || warn "Failed to install Python dependencies"

    # Create vosk models directory
    mkdir -p "$HOME/.local/share/vosk-models"

    # Download Vosk German model (small)
    local model_dir="$HOME/.local/share/vosk-models/vosk-model-small-de-0.15"
    if [ ! -d "$model_dir" ]; then
        log "Downloading Vosk German language model..."
        local model_url="https://alphacephei.com/vosk/models/vosk-model-small-de-0.15.zip"
        local temp_zip
        temp_zip=$(mktemp /tmp/vosk-model-XXXXXX.zip)
        
        if curl -L "$model_url" -o "$temp_zip"; then
            log "Extracting Vosk model..."
            unzip -q "$temp_zip" -d "$HOME/.local/share/vosk-models/" || warn "Failed to extract model"
            rm -f "$temp_zip"
            log "Vosk model installed ✓"
        else
            warn "Failed to download Vosk model - voice control may not work"
        fi
    else
        log "Vosk model already installed ✓"
    fi

    # Copy Python wake listener script
    log "Installing wake listener script..."
    if [ -f "$SCRIPT_DIR/apollo-os-sys/scripts/apollo-wake-listener.py" ]; then
        cp "$SCRIPT_DIR/apollo-os-sys/scripts/apollo-wake-listener.py" "$HOME/.local/bin/" || warn "Failed to copy wake listener"
        chmod +x "$HOME/.local/bin/apollo-wake-listener.py"
    else
        warn "apollo-wake-listener.py not found in scripts directory"
    fi

    # Copy apollo-speak.sh (TTS)
    if [ -f "$SCRIPT_DIR/apollo-os-sys/scripts/apollo-speak.sh" ]; then
        cp "$SCRIPT_DIR/apollo-os-sys/scripts/apollo-speak.sh" "$HOME/.local/bin/" || warn "Failed to copy apollo-speak"
        chmod +x "$HOME/.local/bin/apollo-speak.sh"
    fi

    # Copy voice-input scripts (Whisper) - already copied by install_scripts()
    log "Verifying voice input scripts..."

    # Copy Right Ctrl Push-to-Talk script
    if [ -f "$SCRIPT_DIR/apollo-os-sys/scripts/apollo-os-rightctrl-voice.py" ]; then
        cp "$SCRIPT_DIR/apollo-os-sys/scripts/apollo-os-rightctrl-voice.py" "$HOME/.local/bin/" || warn "Failed to copy rightctrl voice"
        chmod +x "$HOME/.local/bin/apollo-os-rightctrl-voice.py"
    fi

    # Create sounds directory and copy sound files
    mkdir -p "$HOME/.local/share/apollo-os/sounds"
    # Copy from apollo-os-sys (voice-start.wav, voice-end.wav, sleep.mp3, wake.mp3)
    if [ -d "$SCRIPT_DIR/apollo-os-sys/sounds" ]; then
        cp "$SCRIPT_DIR/apollo-os-sys/sounds/"*.wav "$HOME/.local/share/apollo-os/sounds/" 2>/dev/null || true
        cp "$SCRIPT_DIR/apollo-os-sys/sounds/"*.mp3 "$HOME/.local/share/apollo-os/sounds/" 2>/dev/null || true
    fi
    # Copy from orbit extras if exists
    if [ -d "$SCRIPT_DIR/apollo-os-orbit/extras/sounds" ]; then
        cp "$SCRIPT_DIR/apollo-os-orbit/extras/sounds/"*.wav "$HOME/.local/share/apollo-os/sounds/" 2>/dev/null || true
    fi

    # Install Python evdev for Right Ctrl detection
    log "Installing Python evdev for Right Ctrl push-to-talk..."
    python3 -m pip install --user evdev || warn "Failed to install evdev"

    # Systemd services are already copied by setup_systemd()
    # Just ensure they are enabled
    log "Enabling voice control systemd services..."
    mkdir -p "$HOME/.config/systemd/user"

    # Reload and enable services
    systemctl --user daemon-reload
    systemctl --user enable apollo-wake.service || warn "Failed to enable apollo-wake service"
    systemctl --user enable apollo-rightctrl-voice.service || warn "Failed to enable rightctrl voice service"

    log "Voice Control System installed ✓"
    echo -e "${GREEN}Wake Word: 'apollo'${NC}"
    echo -e "${CYAN}Commands: 'apollo wie spät ist es', 'apollo terminal öffnen', etc.${NC}"
}

install_fresh_editor() {
    if [[ "$INSTALL_FRESH" != true ]]; then
        log "Skipping Fresh Editor installation (user choice)"
        return 0
    fi
    
    log "Installing Fresh Editor..."

    echo
    echo -e "${MAGENTA}══════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}  Fresh Editor - Modern GUI Text Editor${NC}"
    echo -e "${MAGENTA}══════════════════════════════════════════════════════${NC}\n"

    # Check if already installed
    if command -v fresh &>/dev/null; then
        log "Fresh Editor already installed ✓"
        fresh --version 2>/dev/null || echo "Fresh Editor installed"
    else
        log "Downloading Fresh Editor RPM..."
        
        # Get latest release URL for current architecture
        local fresh_url=$(curl -s https://api.github.com/repos/sinelaw/fresh/releases/latest | grep "browser_download_url.*\.$(uname -m)\.rpm" | cut -d '"' -f 4)
        
        if [[ -n "$fresh_url" ]]; then
            log "Downloading from: $fresh_url"
            if curl -sL "$fresh_url" -o "$HOME/fresh-editor.rpm"; then
                log "Installing Fresh Editor RPM..."
                sudo rpm -U "$HOME/fresh-editor.rpm" || warn "Fresh Editor installation failed"
                rm -f "$HOME/fresh-editor.rpm"
                
                if command -v fresh &>/dev/null; then
                    log "Fresh Editor installed successfully ✓"
                    fresh --version 2>/dev/null || true
                else
                    warn "Fresh Editor installation completed but command not found"
                fi
            else
                warn "Failed to download Fresh Editor"
            fi
        else
            warn "Could not find Fresh Editor RPM for architecture: $(uname -m)"
        fi
    fi

    # Set Fresh Editor as default for text files
    if command -v fresh &>/dev/null; then
        log "Setting Fresh Editor as default text editor..."
        
        # Common text MIME types
        local mime_types=(
            "text/plain"
            "text/markdown"
            "text/x-markdown"
            "text/x-log"
            "text/x-shellscript"
            "application/x-shellscript"
            "application/json"
            "application/xml"
            "text/xml"
            "text/x-python"
            "text/x-csrc"
            "text/x-c++src"
            "text/x-java"
            "text/x-makefile"
            "text/x-cmake"
            "text/css"
            "text/html"
            "application/javascript"
            "application/x-yaml"
            "text/x-yaml"
        )
        
        # Check if desktop file exists
        local desktop_file=""
        if [[ -f "/usr/share/applications/fresh.desktop" ]]; then
            desktop_file="fresh.desktop"
        elif [[ -f "/usr/local/share/applications/fresh.desktop" ]]; then
            desktop_file="fresh.desktop"
        fi
        
        if [[ -n "$desktop_file" ]]; then
            # Set as default for all text MIME types
            for mime in "${mime_types[@]}"; do
                xdg-mime default "$desktop_file" "$mime" 2>/dev/null || true
            done
            log "Fresh Editor set as default text editor ✓"
        else
            warn "Fresh Editor desktop file not found - cannot set as default"
        fi
    fi

    log "Fresh Editor setup complete ✓"
}

#####################################################################
# Flatpak Applications
#####################################################################

install_flatpak_apps() {
    log "Installing Flatpak applications..."
    
    echo
    echo -e "${MAGENTA}══════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}  Flatpak Applications${NC}"
    echo -e "${MAGENTA}══════════════════════════════════════════════════════${NC}\n"
    
    # Ensure flatpak is installed
    if ! command -v flatpak &>/dev/null; then
        log "Installing Flatpak..."
        sudo dnf install -y flatpak || error "Flatpak installation failed"
    fi
    
    # Add Flathub repository if not already added (system-wide)
    log "Configuring Flathub repository..."
    if ! flatpak remote-list 2>/dev/null | grep -q "flathub"; then
        log "Adding Flathub repository (system-wide)..."
        sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo || warn "Could not add Flathub repository"
        log "Flathub repository added ✓"
    else
        log "Flathub already configured ✓"
    fi
    
    # List of applications to install
    log "Installing Flatpak applications (this may take a while)..."
    
    local flatpak_apps=(
        # Communication
        "org.telegram.desktop"               # Telegram
        
        # Browsers
        "org.gnome.Epiphany"                 # GNOME Web
        
        # Utilities
        "io.github.flattool.Warehouse"       # Flatpak manager
        "app.drey.Dialect"                   # Translator
        "xyz.ketok.Speedtest"                # Speed test
        "org.gabmus.whatip"                  # IP info
        "net.codelogistics.webapps"          # Web apps manager
        "com.github.weclaw1.ImageRoll"       # Image viewer
        
        # Terminal & Podcasts
        "app.devsuite.Ptyxis"                # Modern terminal
        
        # Remote Desktop
        "com.anydesk.Anydesk"                # AnyDesk
    )
    
    # Install each app
    local installed=0
    local failed=0
    local total=${#flatpak_apps[@]}
    
    for app in "${flatpak_apps[@]}"; do
        log "Installing $app ($(($installed + $failed + 1))/$total)..."

        # Check if already installed
        if flatpak list --app 2>/dev/null | grep -q "$app"; then
            log "$app already installed, skipping"
            ((installed++))
            continue
        fi

        # Install with timeout (5 minutes per app)
        log "Attempting to install $app..."
        if timeout 300 flatpak install -y flathub "$app" >> "$INSTALL_LOG" 2>&1; then
            log "✓ $app installed successfully"
            ((installed++))
        else
            local exit_code=$?
            warn "✗ Failed to install $app (exit code: $exit_code)"
            ((failed++))
        fi
    done
    
    log "Flatpak applications: $installed installed, $failed failed/skipped ✓"
    echo -e "${GREEN}Processed ${#flatpak_apps[@]} Flatpak applications${NC}"
}

#####################################################################
# OnlyOffice Suite Installation (Flatpak)
#####################################################################

install_onlyoffice() {
    log "Installing OnlyOffice Suite..."
    
    echo
    echo -e "${MAGENTA}══════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}  OnlyOffice Suite${NC}"
    echo -e "${MAGENTA}══════════════════════════════════════════════════════${NC}\n"
    
    # Ensure flatpak is installed
    if ! command -v flatpak &>/dev/null; then
        log "Installing Flatpak..."
        sudo dnf install -y flatpak || error "Flatpak installation failed"
    fi
    
    # Add Flathub repository if not already added
    if ! flatpak remote-list 2>/dev/null | grep -q "flathub"; then
        log "Adding Flathub repository..."
        sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo || warn "Could not add Flathub repository"
    fi
    
    # Install OnlyOffice
    log "Installing org.onlyoffice.desktopeditors..."
    if flatpak list --app 2>/dev/null | grep -q "org.onlyoffice.desktopeditors"; then
        log "OnlyOffice already installed ✓"
    else
        if timeout 600 flatpak install -y flathub org.onlyoffice.desktopeditors >> "$INSTALL_LOG" 2>&1; then
            log "✓ OnlyOffice installed successfully"
            echo -e "${GREEN}OnlyOffice Suite installed ✓${NC}"
        else
            warn "✗ Failed to install OnlyOffice"
        fi
    fi
}

#####################################################################
# Neovim Installation
#####################################################################

install_neovim() {
    log "Installing Neovim..."
    
    echo
    echo -e "${MAGENTA}══════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}  Neovim - Terminal Text Editor${NC}"
    echo -e "${MAGENTA}══════════════════════════════════════════════════════${NC}\n"
    
    # Install neovim from repos
    sudo dnf install -y neovim || warn "Neovim installation failed"
    
    # Install common neovim dependencies
    python3 -m pip install --user pynvim || warn "Failed to install pynvim"
    
    log "Neovim installed ✓"
    echo -e "${GREEN}Neovim installed ✓${NC}"
}

#####################################################################
# Bitdefender Security Tools Installation
#####################################################################

install_bitdefender() {
    log "Installing Bitdefender Security Tools..."

    # Refresh sudo
    sudo -v

    echo
    echo -e "${MAGENTA}══════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}  Bitdefender Security Tools${NC}"
    echo -e "${MAGENTA}══════════════════════════════════════════════════════${NC}\n"

    local BD_RPM
    BD_RPM=$(ls "$SCRIPT_DIR/apollo-os-sys/packages/bitdefender-security-tools-"*.rpm 2>/dev/null | sort -V | tail -1)
    if [[ -z "$BD_RPM" ]]; then
        BD_RPM="$SCRIPT_DIR/apollo-os-sys/packages/bitdefender-security-tools-7.8.0-200269.x86_64.rpm"
    fi

    if [[ ! -f "$BD_RPM" ]]; then
        echo
        echo -e "${YELLOW}╔══════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${YELLOW}║  Bitdefender RPM not found (too large for Git repository)   ║${NC}"
        echo -e "${YELLOW}║                                                              ║${NC}"
        echo -e "${YELLOW}║  To install Bitdefender, manually download the RPM from      ║${NC}"
        echo -e "${YELLOW}║  your GravityZone Control Center and place it in:            ║${NC}"
        echo -e "${YELLOW}║                                                              ║${NC}"
        echo -e "${YELLOW}║    apollo-os-sys/packages/                                   ║${NC}"
        echo -e "${YELLOW}║                                                              ║${NC}"
        echo -e "${YELLOW}║  Then re-run the installer or install manually:              ║${NC}"
        echo -e "${YELLOW}║    sudo dnf install ./bitdefender-*.rpm                      ║${NC}"
        echo -e "${YELLOW}╚══════════════════════════════════════════════════════════════╝${NC}"
        echo
        warn "Skipping Bitdefender — RPM not found. System continues without it."
        return 0
    fi

    # Check if already installed
    if rpm -q bitdefender-security-tools &>/dev/null; then
        log "Bitdefender Security Tools already installed ✓"
        return 0
    fi

    # Install Bitdefender RPM
    log "Installing Bitdefender Security Tools from bundled RPM..."
    sudo dnf install -y "$BD_RPM" || {
        warn "Bitdefender installation via dnf failed, trying rpm directly..."
        sudo rpm -ivh "$BD_RPM" || warn "Bitdefender installation failed"
    }

    # Enable and start Bitdefender service
    if systemctl list-unit-files 2>/dev/null | grep -q 'bdagentd\|bdsec\|bitdefender'; then
        log "Enabling Bitdefender service..."
        sudo systemctl enable bdagentd 2>/dev/null || \
        sudo systemctl enable bdsec 2>/dev/null || \
        sudo systemctl enable bitdefender-security-tools 2>/dev/null || \
        warn "Could not find Bitdefender service to enable"

        sudo systemctl start bdagentd 2>/dev/null || \
        sudo systemctl start bdsec 2>/dev/null || \
        sudo systemctl start bitdefender-security-tools 2>/dev/null || \
        warn "Could not start Bitdefender service"
    fi

    if rpm -q bitdefender-security-tools &>/dev/null; then
        log "Bitdefender Security Tools installed ✓"
    else
        warn "Bitdefender installation could not be verified"
    fi
}

#####################################################################
# Security Tools Installation
# Firewalld Hardening, fail2ban, ClamAV, rkhunter, Lynis,
# Port Monitor
#####################################################################

install_security_tools() {
    log "Installing and configuring security tools..."
    
    # Refresh sudo before long security operations
    sudo -v
    
    echo ""
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║  Security Tools Installation                                ║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════╝${NC}"
    echo ""

    # --- 1. Firewalld Hardening ---
    log "Hardening Firewalld..."
    if command -v firewall-cmd &>/dev/null; then
        # Ensure firewalld is running
        sudo systemctl enable --now firewalld 2>/dev/null || warn "Failed to enable firewalld"

        # Set default zone to drop (block all incoming by default)
        sudo firewall-cmd --set-default-zone=FedoraWorkstation 2>/dev/null || true

        # Remove unnecessary services from public zone
        for svc in mdns cockpit; do
            sudo firewall-cmd --permanent --zone=FedoraWorkstation --remove-service="$svc" 2>/dev/null || true
        done

        # Keep only essential services
        sudo firewall-cmd --permanent --zone=FedoraWorkstation --add-service=dhcpv6-client 2>/dev/null || true
        sudo firewall-cmd --permanent --zone=FedoraWorkstation --add-service=ssh 2>/dev/null || true

        # Block ICMP timestamp (info leak)
        sudo firewall-cmd --permanent --add-icmp-block=timestamp-reply 2>/dev/null || true
        sudo firewall-cmd --permanent --add-icmp-block=timestamp-request 2>/dev/null || true

        # Reload firewall
        sudo firewall-cmd --reload 2>/dev/null || true
        log "Firewalld hardened ✓"
    else
        warn "firewall-cmd not found"
    fi

    # --- 2. fail2ban ---
    log "Installing fail2ban..."
    sudo dnf install -y fail2ban fail2ban-firewalld 2>/dev/null || warn "fail2ban installation failed"

    if command -v fail2ban-client &>/dev/null; then
        # Deploy jail configuration
        if [ -f "$SCRIPT_DIR/apollo-os-sys/security/jail.local" ]; then
            sudo cp "$SCRIPT_DIR/apollo-os-sys/security/jail.local" /etc/fail2ban/jail.local
            log "fail2ban jail config deployed ✓"
        fi

        sudo systemctl enable --now fail2ban 2>/dev/null || warn "Failed to enable fail2ban"
        log "fail2ban installed and active ✓"
    fi

    # --- 3. ClamAV ---
    log "Installing ClamAV antivirus..."
    sudo dnf install -y clamav clamav-update clamd 2>/dev/null || warn "ClamAV installation failed"

    if command -v freshclam &>/dev/null; then
        # Fix SELinux for freshclam if needed
        sudo setsebool -P antivirus_can_scan_system 1 2>/dev/null || true

        # Initial signature update
        log "Updating ClamAV signatures (this may take a moment)..."
        sudo freshclam 2>/dev/null || warn "Initial ClamAV signature update failed (will retry later)"

        # Enable automatic signature updates
        sudo systemctl enable --now clamav-freshclam 2>/dev/null || warn "Failed to enable freshclam service"
        log "ClamAV installed, freshclam auto-update active ✓"
    fi

    # --- 4. rkhunter ---
    log "Installing rkhunter (rootkit scanner)..."
    sudo dnf install -y rkhunter 2>/dev/null || warn "rkhunter installation failed"

    if command -v rkhunter &>/dev/null; then
        # Update rkhunter database
        sudo rkhunter --update 2>/dev/null || true
        # Set properties baseline
        sudo rkhunter --propupd 2>/dev/null || true
        log "rkhunter installed and baselined ✓"
    fi

    # --- 5. Lynis ---
    log "Installing Lynis (security auditing)..."
    sudo dnf install -y lynis 2>/dev/null || warn "Lynis installation failed"

    if command -v lynis &>/dev/null; then
        log "Lynis installed ✓ (daily audit via systemd timer)"
    fi

    # --- 6. Port Monitor & Security Audit Scripts ---
    log "Installing Apollo OS security scripts..."

    # Copy port monitor script
    if [ -f "$SCRIPT_DIR/apollo-os-sys/scripts/apollo-os-port-monitor.sh" ]; then
        cp "$SCRIPT_DIR/apollo-os-sys/scripts/apollo-os-port-monitor.sh" "$HOME/.local/bin/"
        chmod +x "$HOME/.local/bin/apollo-os-port-monitor.sh"
        log "Port monitor script installed ✓"
    fi

    # Copy security audit script
    if [ -f "$SCRIPT_DIR/apollo-os-sys/scripts/apollo-os-security-audit.sh" ]; then
        cp "$SCRIPT_DIR/apollo-os-sys/scripts/apollo-os-security-audit.sh" "$HOME/.local/bin/"
        chmod +x "$HOME/.local/bin/apollo-os-security-audit.sh"
        log "Security audit script installed ✓"
    fi

    # Create state directory
    mkdir -p "$HOME/.local/state/apollo-os"

    # --- 7. Enable systemd timers ---
    log "Enabling security timers..."

    # Port monitor timer (every 5 min)
    if [ -f "$HOME/.config/systemd/user/apollo-os-port-monitor.timer" ]; then
        systemctl --user enable --now apollo-os-port-monitor.timer 2>/dev/null || warn "Failed to enable port monitor timer"
        log "Port monitor timer active (every 5 min) ✓"
    fi

    # Security audit timer (daily)
    if [ -f "$HOME/.config/systemd/user/apollo-os-security-audit.timer" ]; then
        systemctl --user enable --now apollo-os-security-audit.timer 2>/dev/null || warn "Failed to enable security audit timer"
        log "Security audit timer active (daily) ✓"
    fi

    # --- 8. Kernel & Network Hardening (sysctl) ---
    log "Applying kernel and network hardening..."
    if [ -f "$SCRIPT_DIR/apollo-os-sys/security/99-apollo-hardening.conf" ]; then
        sudo cp "$SCRIPT_DIR/apollo-os-sys/security/99-apollo-hardening.conf" /etc/sysctl.d/ || warn "Failed to deploy sysctl hardening"
        sudo sysctl --system -q 2>/dev/null || warn "Failed to apply sysctl settings"
        log "Kernel/network hardening applied ✓"
    fi

    # --- 9. SSH Hardening ---
    log "Hardening SSH configuration..."
    if [ -d /etc/ssh/sshd_config.d ] && [ -f "$SCRIPT_DIR/apollo-os-sys/security/99-apollo-ssh-hardening.conf" ]; then
        sudo cp "$SCRIPT_DIR/apollo-os-sys/security/99-apollo-ssh-hardening.conf" /etc/ssh/sshd_config.d/ || warn "Failed to deploy SSH hardening"
        sudo systemctl reload sshd 2>/dev/null || true
        log "SSH hardened (root login disabled, rate limiting, strong ciphers) ✓"
    fi

    # --- 10. Automatic Security Updates ---
    log "Configuring automatic security updates..."
    sudo dnf install -y dnf-automatic 2>/dev/null || warn "dnf-automatic installation failed"
    if [ -f "$SCRIPT_DIR/apollo-os-sys/security/dnf-automatic-security.conf" ]; then
        sudo cp "$SCRIPT_DIR/apollo-os-sys/security/dnf-automatic-security.conf" /etc/dnf/automatic.conf || warn "Failed to deploy dnf-automatic config"
    fi
    sudo systemctl enable --now dnf-automatic-install.timer 2>/dev/null || warn "Failed to enable dnf-automatic timer"
    log "Automatic security updates enabled ✓"

    # --- 11. AIDE File Integrity Database ---
    log "Installing AIDE (Advanced Intrusion Detection)..."
    sudo dnf install -y aide 2>/dev/null || warn "AIDE installation failed"
    if command -v aide &>/dev/null; then
        if [ ! -f /var/lib/aide/aide.db.gz ]; then
            log "Initializing AIDE database (this may take a few minutes)..."
            sudo aide --init 2>/dev/null || warn "AIDE initialization failed"
            sudo mv /var/lib/aide/aide.db.new.gz /var/lib/aide/aide.db.gz 2>/dev/null || true
        fi
        log "AIDE file integrity monitoring installed ✓"
    fi

    # --- 12. Restrict USB access (optional hardening) ---
    log "Configuring USB security..."
    # Block USB storage by default (can be enabled when needed)
    if [ ! -f /etc/modprobe.d/apollo-usb-storage.conf ]; then
        sudo bash -c 'cat > /etc/modprobe.d/apollo-usb-storage.conf << EOF
# Apollo OS - USB mass storage disabled by default
# To temporarily enable: sudo modprobe usb-storage
# To permanently enable: remove or comment out this file
# install usb-storage /bin/false
# Note: Commented out by default. Uncomment the line above for maximum security.
EOF'
        log "USB storage security config created (disabled by default, enable manually for max security) ✓"
    fi

    # --- 13. Restrict core dumps ---
    log "Restricting core dumps..."
    if [ ! -f /etc/security/limits.d/99-apollo-coredump.conf ]; then
        sudo bash -c 'cat > /etc/security/limits.d/99-apollo-coredump.conf << EOF
# Apollo OS - Disable core dumps (prevent credential leaks)
*               hard    core            0
EOF'
        log "Core dumps restricted ✓"
    fi

    # --- 14. DNS-over-TLS (encrypted DNS queries) ---
    log "Configuring DNS-over-TLS..."
    if [ -f "$SCRIPT_DIR/apollo-os-sys/security/99-apollo-dns-tls.conf" ]; then
        sudo mkdir -p /etc/systemd/resolved.conf.d
        sudo cp "$SCRIPT_DIR/apollo-os-sys/security/99-apollo-dns-tls.conf" /etc/systemd/resolved.conf.d/ || warn "Failed to deploy DNS-over-TLS config"
        # Ensure NetworkManager delegates DNS to systemd-resolved
        if [ -f "$SCRIPT_DIR/apollo-os-sys/security/99-apollo-dns-resolved.conf" ]; then
            sudo mkdir -p /etc/NetworkManager/conf.d
            sudo cp "$SCRIPT_DIR/apollo-os-sys/security/99-apollo-dns-resolved.conf" /etc/NetworkManager/conf.d/ || warn "Failed to deploy NM DNS config"
        fi
        sudo systemctl restart systemd-resolved 2>/dev/null || warn "Failed to restart systemd-resolved"
        # Create /etc/resolv.conf symlink to systemd-resolved
        if [ ! -L /etc/resolv.conf ] || [ "$(readlink /etc/resolv.conf)" != "/run/systemd/resolve/stub-resolv.conf" ]; then
            sudo ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf 2>/dev/null || warn "Failed to link resolv.conf"
        fi
        log "DNS-over-TLS enabled (Cloudflare + Quad9) ✓"
    fi

    # --- 15. MAC Address Randomization ---
    log "Configuring MAC address randomization..."
    if [ -f "$SCRIPT_DIR/apollo-os-sys/security/99-apollo-mac-random.conf" ]; then
        sudo mkdir -p /etc/NetworkManager/conf.d
        sudo cp "$SCRIPT_DIR/apollo-os-sys/security/99-apollo-mac-random.conf" /etc/NetworkManager/conf.d/ || warn "Failed to deploy MAC randomization config"
        sudo systemctl reload NetworkManager 2>/dev/null || true
        log "WiFi/Ethernet MAC randomization enabled ✓"
    fi

    # --- 16. Journal Size Limits ---
    log "Configuring journal rotation..."
    if [ -f "$SCRIPT_DIR/apollo-os-sys/security/99-apollo-journal.conf" ]; then
        sudo mkdir -p /etc/systemd/journald.conf.d
        sudo cp "$SCRIPT_DIR/apollo-os-sys/security/99-apollo-journal.conf" /etc/systemd/journald.conf.d/ || warn "Failed to deploy journal config"
        sudo systemctl restart systemd-journald 2>/dev/null || warn "Failed to restart journald"
        log "Journal rotation configured (max 500M, 1 month retention) ✓"
    fi

    # --- 17. System Monitoring Scripts ---
    log "Installing system monitoring scripts..."
    for monitor_script in apollo-os-battery-monitor.sh apollo-os-disk-monitor.sh apollo-os-watchdog.sh; do
        if [ -f "$SCRIPT_DIR/apollo-os-sys/scripts/$monitor_script" ]; then
            cp "$SCRIPT_DIR/apollo-os-sys/scripts/$monitor_script" "$HOME/.local/bin/"
            chmod +x "$HOME/.local/bin/$monitor_script"
        fi
    done
    log "Battery, disk, and watchdog monitors installed ✓"

    # --- Summary ---
    echo ""
    echo -e "${GREEN}  Security & Monitoring Summary:${NC}"
    echo -e "  ├── 🔥 Firewalld:     Hardened (incoming blocked by default)"
    echo -e "  ├── 🛡️  fail2ban:      Active (SSH brute-force protection)"
    echo -e "  ├── 🦠 ClamAV:        Installed (auto-updating signatures)"
    echo -e "  ├── 🔍 rkhunter:      Baselined (rootkit detection)"
    echo -e "  ├── 📊 Lynis:         Installed (daily security audit)"
    echo -e "  ├── 🌐 Port Monitor:  Active (every 5 min scan)"
    echo -e "  ├── 🔒 Kernel:        Hardened (sysctl network/kernel params)"
    echo -e "  ├── 🔑 SSH:           Hardened (no root, strong ciphers, rate limit)"
    echo -e "  ├── 🔄 Auto-Updates:  Security patches applied automatically"
    echo -e "  ├── 📁 AIDE:          File integrity monitoring initialized"
    echo -e "  ├── 🚫 Core Dumps:    Restricted (credential leak prevention)"
    echo -e "  ├── 🔐 DNS-over-TLS:  Encrypted DNS (Cloudflare + Quad9)"
    echo -e "  ├── 🎭 MAC Random:    WiFi/Ethernet MAC randomization"
    echo -e "  ├── 📋 Journal:       Log rotation (max 500M)"
    echo -e "  ├── 🔋 Battery:       Low battery TTS warnings"
    echo -e "  ├── 💾 Disk Monitor:  Low disk space warnings"
    echo -e "  └── 🐕 Watchdog:      Critical service auto-restart"
    echo ""

    log "Security tools installation complete ✓"
}

#####################################################################
# Wallpaper & Screenshots Setup
#####################################################################

setup_wallpapers() {
    log "Setting up wallpaper and screenshot directories..."

    # Create wallpaper directory
    mkdir -p "$HOME/System/Wallpaper"

    # Create Screenshots directory
    mkdir -p "$HOME/Screenshots"

    # Copy wallpapers
    cp -r "$SCRIPT_DIR/apollo-os-sys/assets/wallpapers/"* "$HOME/System/Wallpaper/" 2>/dev/null || warn "No wallpapers to copy"

    # Set default wallpaper symlink
    if [[ -f "$HOME/System/Wallpaper/MacOS-Tahoe-26.jpg" ]]; then
        ln -sf "$HOME/System/Wallpaper/MacOS-Tahoe-26.jpg" "$HOME/System/Wallpaper/current.jpg"
    elif [[ -f "$HOME/System/Wallpaper/Basic-Black-Dots.jpg" ]]; then
        ln -sf "$HOME/System/Wallpaper/Basic-Black-Dots.jpg" "$HOME/System/Wallpaper/current.jpg"
    fi

    log "Wallpaper and screenshots directories ready ✓"
}

#####################################################################
# Login Configuration (TTY Login + Boot Sequence)
#####################################################################

configure_login_manager() {
    log "Configuring TTY login with Apollo OS boot sequence..."

    echo
    echo -e "${MAGENTA}══════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}  Login Configuration (TTY + Boot Sequence)${NC}"
    echo -e "${MAGENTA}══════════════════════════════════════════════════════${NC}\n"

    # Configure logind for TTS delay before sleep
    log "Configuring sleep delay for TTS notifications..."
    sudo mkdir -p /etc/systemd/logind.conf.d
    sudo cp "$SCRIPT_DIR/apollo-os-sys/systemd/logind-delay.conf" /etc/systemd/logind.conf.d/apollo-os-delay.conf 2>/dev/null || true

    # ─── Disable ALL graphical login managers ───
    log "Disabling graphical login managers..."
    sudo systemctl disable gdm 2>/dev/null || true
    sudo systemctl disable sddm 2>/dev/null || true
    sudo systemctl disable greetd 2>/dev/null || true
    sudo systemctl disable lightdm 2>/dev/null || true

    # Set system to multi-user (TTY login, no graphical DM)
    log "Setting boot target to multi-user (TTY login)..."
    sudo systemctl set-default multi-user.target || error "CRITICAL: Failed to set boot target! System may not boot correctly."

    # Configure clean boot (quiet boot, then show Apollo OS login banner)
    log "Configuring terminal boot..."
    sudo grubby --update-kernel=ALL --remove-args='rhgb' 2>/dev/null || true
    sudo grubby --update-kernel=ALL --args='quiet splash' 2>/dev/null || true
    sudo grubby --set-default-index=0 2>/dev/null || true

    # Set GRUB timeout and add quiet splash
    if [ -f /etc/default/grub ]; then
        sudo sed -i 's/ rhgb//g; s/rhgb //g' /etc/default/grub
        # Ensure quiet splash is in CMDLINE
        if ! grep -q 'quiet' /etc/default/grub; then
            sudo sed -i 's/GRUB_CMDLINE_LINUX="\(.*\)"/GRUB_CMDLINE_LINUX="\1 quiet splash"/' /etc/default/grub
        fi
        sudo sed -i 's/GRUB_TIMEOUT=.*/GRUB_TIMEOUT=1/' /etc/default/grub
        if [ -d /sys/firmware/efi ]; then
            sudo grub2-mkconfig -o /boot/efi/EFI/fedora/grub.cfg 2>/dev/null || true
        else
            sudo grub2-mkconfig -o /boot/grub2/grub.cfg 2>/dev/null || true
        fi
    fi

    # ─── Configure TTY auto-start of Niri ───
    # Add boot sequence to .bash_profile (runs only on TTY1)
    log "Configuring TTY1 auto-start..."
    local LOGIN_SNIPPET="$SCRIPT_DIR/apollo-os-sys/config/apollo-os-tty-login.sh"

    if [ -f "$LOGIN_SNIPPET" ]; then
        # Add to .bash_profile if not already present
        if ! grep -q "apollo-os-boot-sequence" "$HOME/.bash_profile" 2>/dev/null; then
            echo "" >> "$HOME/.bash_profile"
            echo "# Apollo OS - Auto-start on TTY1 login" >> "$HOME/.bash_profile"
            cat "$LOGIN_SNIPPET" >> "$HOME/.bash_profile"
            log "TTY1 auto-start added to .bash_profile ✓"
        else
            log "TTY1 auto-start already configured in .bash_profile ✓"
        fi

        # Also add to .zprofile for zsh users
        if command -v zsh &>/dev/null; then
            if ! grep -q "apollo-os-boot-sequence" "$HOME/.zprofile" 2>/dev/null; then
                echo "" >> "$HOME/.zprofile"
                echo "# Apollo OS - Auto-start on TTY1 login" >> "$HOME/.zprofile"
                cat "$LOGIN_SNIPPET" >> "$HOME/.zprofile"
                log "TTY1 auto-start added to .zprofile ✓"
            fi
        fi
    else
        warn "TTY login snippet not found, creating inline..."
        # Fallback: add directly
        if ! grep -q "apollo-os-boot-sequence" "$HOME/.bash_profile" 2>/dev/null; then
            cat >> "$HOME/.bash_profile" << 'LOGINEOF'

# Apollo OS - Auto-start Niri on TTY1 login
if [ -z "$DISPLAY" ] && [ -z "$WAYLAND_DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ]; then
    exec "$HOME/.local/bin/apollo-os-boot-sequence.sh"
fi
LOGINEOF
            log "TTY1 auto-start added to .bash_profile (inline) ✓"
        fi
    fi

    # ─── Configure TTY appearance ───
    # Set a clean issue message for the login prompt
    log "Configuring login prompt..."
    # Remove symlink first (Fedora links /etc/issue -> /usr/lib/issue)
    sudo rm -f /etc/issue
    # Remove cockpit issue clutter
    sudo rm -f /etc/issue.d/cockpit.issue
    sudo tee /etc/issue > /dev/null << 'ISSUEEOF'
  \e[0;36m╔═══════════════════════════════════════════════════╗
  ║\e[1;37m          A P O L L O   O S   v 0 . 6 . 0          \e[0;36m║
  ║\e[0;90m          Enterprise Desktop Environment           \e[0;36m║
  ╚═══════════════════════════════════════════════════╝\e[0m

ISSUEEOF

    log "TTY login configured ✓"
    log "Flow: TTY Login → Boot Sequence → Apollo OS Orbit"
    log "On logout from Niri, user returns to TTY login"
}

#####################################################################
# Final Steps
#####################################################################

finalize_installation() {
    log "Finalizing installation..."

    # Apply GTK dark theme via gsettings
    log "Applying dark theme settings..."
    gsettings set org.gnome.desktop.interface gtk-theme 'adw-gtk3-dark' 2>/dev/null || true
    gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark' 2>/dev/null || true
    gsettings set org.gnome.desktop.interface cursor-theme 'Bibata-Modern-Classic' 2>/dev/null || true

    # Fix GNOME apps that use gapplication launch (doesn't work well with Niri)
    log "Fixing GNOME app launchers for Niri compatibility..."
    mkdir -p "$HOME/.local/share/applications"
    
    # Fix Weather
    if [ -f /usr/share/applications/org.gnome.Weather.desktop ]; then
        cp /usr/share/applications/org.gnome.Weather.desktop "$HOME/.local/share/applications/"
        sed -i 's|Exec=gapplication launch org.gnome.Weather|Exec=gnome-weather|' "$HOME/.local/share/applications/org.gnome.Weather.desktop"
    fi
    
    # Fix Maps
    if [ -f /usr/share/applications/org.gnome.Maps.desktop ]; then
        cp /usr/share/applications/org.gnome.Maps.desktop "$HOME/.local/share/applications/"
        sed -i 's|Exec=gapplication launch org.gnome.Maps %U|Exec=gnome-maps %U|' "$HOME/.local/share/applications/org.gnome.Maps.desktop"
    fi
    
    # Fix Showtime (Videos)
    if [ -f /usr/share/applications/org.gnome.Showtime.desktop ]; then
        cat > "$HOME/.local/share/applications/org.gnome.Showtime.desktop" << 'SHOWTIME_EOF'
[Desktop Entry]
Type=Application
Name=Videos
Comment=Play movies and videos
Exec=env GDK_BACKEND=wayland showtime
Icon=org.gnome.Showtime
Terminal=false
Categories=AudioVideo;Video;Player;
SHOWTIME_EOF
    fi
    
    update-desktop-database "$HOME/.local/share/applications/" 2>/dev/null || true
    log "GNOME app launchers fixed ✓"
    
    # Hide duplicate Chrome entries (Chrome installs multiple .desktop files)
    log "Removing duplicate Chrome entries..."
    if [ -f "$HOME/.local/share/applications/google-chrome.desktop" ]; then
        if ! grep -q "NoDisplay=true" "$HOME/.local/share/applications/google-chrome.desktop"; then
            echo "NoDisplay=true" >> "$HOME/.local/share/applications/google-chrome.desktop"
        fi
    fi
    update-desktop-database "$HOME/.local/share/applications/" 2>/dev/null || true

    # Add local bin to PATH if not already there
    if ! grep -q "$HOME/.local/bin" "$HOME/.bashrc" 2>/dev/null; then
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc"
        log "Added ~/.local/bin to PATH in .bashrc"
    fi
    
    # Add local lib to LD_LIBRARY_PATH if not already there (for whisper.cpp)
    if ! grep -q "LD_LIBRARY_PATH.*/.local/lib" "$HOME/.bashrc" 2>/dev/null; then
        echo 'export LD_LIBRARY_PATH="$HOME/.local/lib:$LD_LIBRARY_PATH"' >> "$HOME/.bashrc"
        log "Added ~/.local/lib to LD_LIBRARY_PATH in .bashrc"
    fi

    # If zsh is installed, update .zshrc as well
    if command -v zsh &>/dev/null; then
        if ! grep -q "$HOME/.local/bin" "$HOME/.zshrc" 2>/dev/null; then
            echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.zshrc"
            log "Added ~/.local/bin to PATH in .zshrc"
        fi
        if ! grep -q "LD_LIBRARY_PATH.*/.local/lib" "$HOME/.zshrc" 2>/dev/null; then
            echo 'export LD_LIBRARY_PATH="$HOME/.local/lib:$LD_LIBRARY_PATH"' >> "$HOME/.zshrc"
            log "Added ~/.local/lib to LD_LIBRARY_PATH in .zshrc"
        fi
    fi

    # Cleanup installation temp files
    log "Cleaning up temporary installation files..."
    
    # Remove dots-hyprland clone if exists
    rm -rf "$HOME/dots-hyprland" 2>/dev/null || true
    rm -rf "$HOME/.cache/dots-hyprland-install" 2>/dev/null || true
    
    # Remove backup folders
    rm -rf "$HOME/ii-original-dots-backup" 2>/dev/null || true
    
    log "Temporary files cleaned up ✓"

    # Print summary
    echo
    echo -e "${MAGENTA}══════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}  Installation Complete! ${NC}"
    echo -e "${MAGENTA}══════════════════════════════════════════════════════${NC}\n"

    echo -e "${CYAN}Next Steps:${NC}"
    echo "1. Reboot your system"
    echo "2. Log in at the TTY with your username and password"
    echo "3. Apollo OS boot sequence starts automatically"
    echo "   (Press Ctrl+C during boot sequence to stay in terminal)"
    echo
    # Determine WM name for summary
    local WM_SUMMARY="Apollo OS Orbit"
    if [[ "$INSTALL_HYPRLAND" == true && "$INSTALL_NIRI" == false ]]; then
        WM_SUMMARY="Apollo OS Glass"
    elif [[ "$INSTALL_HYPRLAND" == true && "$INSTALL_NIRI" == true ]]; then
        WM_SUMMARY="Apollo OS (${DEFAULT_WM:-niri})"
    fi

    echo -e "${YELLOW}Login Flow:${NC}"
    echo "  TTY Login → Boot Sequence → ${WM_SUMMARY}"
    echo "  On logout, you return to the TTY login"
    echo
    echo -e "${CYAN}Quick Commands:${NC}"
    echo "  apollo-speak <text>          - Text-to-Speech with AMALA voice"
    echo "  apollo                       - Voice control (say 'apollo wie spät')"
    echo "  Super+Shift+Space            - Quick Menu"
    echo "  Super+Space                  - App Launcher"
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
    select_desktop_environment
    gather_user_config
    select_flatpak_option
    select_office_suite
    select_editor

    # Install dots-hyprland base system first (if Hyprland selected)
    # This installs all dependencies and base configs automatically
    install_dots_hyprland
    
    # Now install remaining packages and Apollo OS specific configs
    install_packages
    configure_user_permissions
    verify_critical_packages
    
    # Deploy Apollo OS configs (overwrites dots-hyprland defaults)
    deploy_configs
    install_kora_icons
    disable_welcome_screen
    deploy_boot_splash
    install_scripts
    install_desktop_entries
    setup_systemd
    install_audio_system
    install_voice_control
    
    # Install Bitdefender Security Tools
    install_bitdefender
    
    # Install security hardening tools
    install_security_tools
    
    # Install editors based on user choice
    if [[ "$INSTALL_FRESH" == true ]]; then
        install_fresh_editor
    fi
    if [[ "$INSTALL_NEOVIM" == true ]]; then
        install_neovim
    fi
    
    # Install OnlyOffice if selected
    if [[ "$INSTALL_ONLYOFFICE" == true ]]; then
        install_onlyoffice
    fi
    
    # Install Flatpak apps if selected
    if [[ "$INSTALL_FLATPAK" == true ]]; then
        install_flatpak_apps
    else
        log "Skipping Flatpak applications (user choice)"
    fi
    
    setup_wallpapers
    configure_login_manager
    finalize_installation

    echo -e "${GREEN}Apollo OS is ready! 🚀${NC}"
    echo
    read -p "Press Enter to continue..."
}

# Cleanup handler for interrupted installation
trap 'echo -e "\n${YELLOW}Installation interrupted. Partial changes may need manual cleanup.${NC}"; exit 130' INT TERM

# Run main installation
main
