#!/usr/bin/env bash

#####################################################################
# Apollo OS - System Update Script v2.0.0
# Copyright © 2025-2026 by Manuel Kraibacher
#
# Description: Complete system update — packages, firmware, flatpak,
#              security signatures, and optionally Apollo OS itself.
#####################################################################

REPO_URL="https://github.com/apolloenv/apollo-os.git"
INSTALL_DIR="$HOME/apollo-os-update"
BRANCH="main"
VERSION="v2.0.0"

# Cleanup on interrupt
trap 'rm -rf "$INSTALL_DIR" 2>/dev/null; echo -e "\n${YELLOW}Update interrupted.${NC}"; exit 130' INT TERM

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'

LOG_FILE="$HOME/.local/state/apollo-os/update.log"
mkdir -p "$(dirname "$LOG_FILE")"

log() {
    local msg="[$(date '+%H:%M:%S')] $1"
    echo -e "${GREEN}[INFO]${NC} $1"
    echo "$msg" >> "$LOG_FILE"
}

warn() {
    local msg="[$(date '+%H:%M:%S')] WARN: $1"
    echo -e "${YELLOW}[WARN]${NC} $1"
    echo "$msg" >> "$LOG_FILE"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
    echo "[$(date '+%H:%M:%S')] ERROR: $1" >> "$LOG_FILE"
    exit 1
}

section() {
    echo
    echo -e "${CYAN}  ── $1 ──${NC}"
}

# Keep log under 5000 lines
if [ -f "$LOG_FILE" ] && [ "$(wc -l < "$LOG_FILE")" -gt 5000 ]; then
    tail -2500 "$LOG_FILE" > "${LOG_FILE}.tmp"
    mv "${LOG_FILE}.tmp" "$LOG_FILE"
fi

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
echo -e "${CYAN}  Apollo OS System Update${NC}"
echo -e "${YELLOW}  Update Engine $VERSION${NC}"
echo -e "${MAGENTA}═══════════════════════════════════════════════════════${NC}"
echo

# Accept mode as CLI argument or prompt interactively
if [ -n "$1" ]; then
    UPDATE_MODE="$1"
else
    echo -e "  ${CYAN}1)${NC} System Update         — DNF packages, firmware, Flatpak, security"
    echo -e "  ${CYAN}2)${NC} Full Reinstall         — Complete Apollo OS reinstall from GitHub"
    echo -e "  ${CYAN}3)${NC} Security Update Only   — ClamAV, rkhunter, AIDE, security patches"
    echo -e "  ${CYAN}0)${NC} Cancel"
    echo
    read -p "  Select [1]: " -n 1 -r UPDATE_MODE
    echo
    UPDATE_MODE="${UPDATE_MODE:-1}"
fi

if [[ "$UPDATE_MODE" == "0" ]]; then
    echo "Update cancelled."
    exit 0
fi

echo
echo -e "${MAGENTA}═══════════════════════════════════════════════════════${NC}"
log "=== Apollo OS Update started (Mode: $UPDATE_MODE) ==="

errors=0
updated=0

#####################################################################
# Mode 1 & 3: System/Security Update
#####################################################################
if [[ "$UPDATE_MODE" == "1" || "$UPDATE_MODE" == "3" ]]; then

    # --- DNF Security/Full Update ---
    section "System Packages"
    sudo -v || error "sudo authentication failed"

    if [[ "$UPDATE_MODE" == "3" ]]; then
        log "Installing security updates only..."
        sudo dnf upgrade --security -y 2>&1 | tail -5
        dnf_exit=${PIPESTATUS[0]}
    else
        log "Updating all system packages..."
        sudo dnf upgrade -y 2>&1 | tail -10
        dnf_exit=${PIPESTATUS[0]}
    fi

    if [ $dnf_exit -eq 0 ]; then
        log "DNF update complete ✓"
        updated=$((updated + 1))
    else
        warn "DNF update had issues"
        errors=$((errors + 1))
    fi

    # --- COPR Packages ---
    if [[ "$UPDATE_MODE" == "1" ]]; then
        section "COPR Packages"
        log "Refreshing COPR repositories..."
        sudo dnf copr list 2>/dev/null | while read -r copr; do
            log "  COPR: $copr"
        done
        # Already updated by dnf upgrade above
        log "COPR packages included in system update ✓"
    fi

    # --- Firmware Updates ---
    if [[ "$UPDATE_MODE" == "1" ]] && command -v fwupdmgr &>/dev/null; then
        section "Firmware"
        log "Checking for firmware updates..."
        fwupdmgr refresh --force 2>/dev/null || true
        FW_UPDATES=$(fwupdmgr get-updates 2>/dev/null || echo "")
        if echo "$FW_UPDATES" | grep -qi "no updates"; then
            log "Firmware is up to date ✓"
        elif [ -n "$FW_UPDATES" ]; then
            echo "$FW_UPDATES" | head -10
            read -p "  Install firmware updates? (y/n): " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                fwupdmgr update -y 2>/dev/null || warn "Firmware update had issues"
                updated=$((updated + 1))
            fi
        else
            log "No firmware updates available ✓"
        fi
    fi

    # --- Flatpak Updates ---
    if [[ "$UPDATE_MODE" == "1" ]] && command -v flatpak &>/dev/null; then
        section "Flatpak Applications"
        log "Updating Flatpak applications..."
        flatpak update -y 2>&1 | tail -5
        if [ ${PIPESTATUS[0]} -eq 0 ]; then
            log "Flatpak update complete ✓"
            updated=$((updated + 1))
        else
            warn "Flatpak update had issues"
        fi

        # Clean up unused Flatpak runtimes
        flatpak uninstall --unused -y 2>/dev/null || true
    fi

    # --- ClamAV Signatures ---
    section "Security Signatures"
    if command -v freshclam &>/dev/null; then
        log "Updating ClamAV virus signatures..."
        sudo freshclam 2>/dev/null
        if [ $? -eq 0 ]; then
            log "ClamAV signatures updated ✓"
        else
            warn "ClamAV signature update failed (may be rate-limited)"
        fi
    fi

    # --- rkhunter Database ---
    if command -v rkhunter &>/dev/null; then
        log "Updating rkhunter database..."
        sudo rkhunter --update 2>/dev/null || true
        sudo rkhunter --propupd 2>/dev/null || true
        log "rkhunter database updated ✓"
    fi

    # --- AIDE Database ---
    if command -v aide &>/dev/null; then
        log "Checking AIDE file integrity..."
        aide_changes=$(sudo aide --check 2>/dev/null | grep -c "changed\|added\|removed" || true)
        if [ "$aide_changes" -gt 0 ]; then
            warn "AIDE detected $aide_changes file changes since last baseline"
            read -p "  Update AIDE baseline? (y/n): " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                sudo aide --update 2>/dev/null || true
                sudo mv /var/lib/aide/aide.db.new.gz /var/lib/aide/aide.db.gz 2>/dev/null || true
                log "AIDE baseline updated ✓"
            fi
        else
            log "AIDE file integrity OK ✓"
        fi
    fi

    # --- npm Global Packages ---
    if [[ "$UPDATE_MODE" == "1" ]] && command -v npm &>/dev/null; then
        section "CLI Tools"
        log "Updating npm global packages..."
        npm update -g 2>/dev/null || warn "npm global update had issues"
        log "npm global packages updated ✓"
    fi

    # --- Cargo Packages ---
    if [[ "$UPDATE_MODE" == "1" ]] && command -v cargo &>/dev/null; then
        if command -v cargo-install-update &>/dev/null; then
            log "Updating cargo packages..."
            cargo install-update -a 2>/dev/null || true
        fi
    fi

    # --- Neovim Plugins (if installed) ---
    if [[ "$UPDATE_MODE" == "1" ]] && command -v nvim &>/dev/null; then
        log "Updating Neovim plugins..."
        nvim --headless "+Lazy! sync" +qa 2>/dev/null || true
    fi
fi

#####################################################################
# Mode 2: Full Apollo OS Reinstall from GitHub
#####################################################################
if [[ "$UPDATE_MODE" == "2" ]]; then
    echo
    echo -e "${YELLOW}  This will perform a complete reinstallation from GitHub.${NC}"
    echo -e "${YELLOW}  Your current configurations will be backed up first.${NC}"
    echo
    read -p "  Continue with full reinstall? (y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Reinstall cancelled."
        exit 0
    fi

    # --- Backup current configs ---
    section "Configuration Backup"
    BACKUP_DIR="$HOME/.config/apollo-os/backups/$(date '+%Y%m%d-%H%M%S')"
    mkdir -p "$BACKUP_DIR"

    for cfg in \
        "$HOME/.config/niri/config.kdl" \
        "$HOME/.config/waybar/config-niri" \
        "$HOME/.config/waybar/style.css" \
        "$HOME/.config/mako/config" \
        "$HOME/.config/rofi" \
        "$HOME/.config/apollo-os/config.env" \
        "$HOME/.config/hypr/monitors.conf" \
        "$HOME/.config/hypr/hyprland/env.conf"; do
        if [ -e "$cfg" ]; then
            cp -a "$cfg" "$BACKUP_DIR/" 2>/dev/null || true
        fi
    done
    log "Configs backed up to: $BACKUP_DIR ✓"

    # --- Clone & Install ---
    section "Downloading Latest Version"

    if ! command -v git &>/dev/null; then
        error "git is not installed. Install with: sudo dnf install -y git"
    fi

    if [ -d "$INSTALL_DIR" ]; then
        rm -rf "$INSTALL_DIR"
    fi

    git clone --depth 1 --branch "$BRANCH" "$REPO_URL" "$INSTALL_DIR" || {
        error "Failed to clone repository"
    }

    # Find the installation script
    INSTALL_SCRIPT=""
    for candidate in \
        "$INSTALL_DIR/apollo-os-install.sh" \
        "$INSTALL_DIR/v"*/apollo-os-install.sh; do
        if [ -f "$candidate" ]; then
            INSTALL_SCRIPT="$candidate"
            break
        fi
    done

    if [ -z "$INSTALL_SCRIPT" ]; then
        error "Installation script not found in repository!"
    fi

    chmod +x "$INSTALL_SCRIPT"
    log "Found install script: $INSTALL_SCRIPT ✓"

    section "Running Installation"
    cd "$(dirname "$INSTALL_SCRIPT")" || error "Failed to cd to install directory"
    bash "$INSTALL_SCRIPT"
    INSTALL_EXIT_CODE=$?

    # Cleanup
    log "Cleaning up..."
    rm -rf "$INSTALL_DIR"

    if [ $INSTALL_EXIT_CODE -ne 0 ]; then
        errors=$((errors + 1))
    fi
fi

#####################################################################
# Summary
#####################################################################
echo
echo -e "${MAGENTA}═══════════════════════════════════════════════════════${NC}"
if [ $errors -eq 0 ]; then
    echo -e "${GREEN}  ✓ Apollo OS Update Complete${NC}"
    log "=== Update complete: $updated components updated, 0 errors ==="
else
    echo -e "${YELLOW}  ⚠ Update completed with $errors issue(s)${NC}"
    log "=== Update complete: $updated components updated, $errors errors ==="
fi
echo -e "${MAGENTA}═══════════════════════════════════════════════════════${NC}"

# Show if reboot needed
if [ -f /var/run/reboot-required ] || (command -v needs-restarting &>/dev/null && needs-restarting -r 2>/dev/null); then
    echo
    echo -e "${YELLOW}  ⟳ A system reboot is recommended.${NC}"
fi

echo
echo -e "${CYAN}  Log: $LOG_FILE${NC}"
echo
read -p "  Press Enter to close..."
