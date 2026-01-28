#!/usr/bin/env bash

#####################################################################
# Apollo OS - Update Script v1.0.2
# Copyright © 2025 by Manuel Kraibacher
#
# Description: Complete reinstallation from latest GitHub version
#####################################################################

REPO_URL="https://github.com/apolloenv/apollo-os.git"
INSTALL_DIR="$HOME/apollo-os-update"
BRANCH="main"
VERSION="v1.0.2"

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'

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
echo -e "${CYAN}  Apollo OS Complete Update/Reinstall${NC}"
echo -e "${YELLOW}  Version: $VERSION${NC}"
echo -e "${MAGENTA}═══════════════════════════════════════════════════════${NC}\n"

echo -e "${YELLOW}This will perform a complete reinstallation from GitHub.${NC}"
echo -e "${YELLOW}All packages and configurations will be updated.${NC}"
echo -e "${YELLOW}Your current configurations will be backed up.${NC}"
echo
read -p "Continue? (y/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Update cancelled."
    exit 0
fi

echo

# Check if git is installed
if ! command -v git &>/dev/null; then
    error "git is not installed. Install with: sudo dnf install -y git"
fi

# Remove old update directory
if [ -d "$INSTALL_DIR" ]; then
    log "Removing old update directory..."
    rm -rf "$INSTALL_DIR"
fi

# Clone latest version
log "Downloading latest Apollo OS from GitHub..."
echo
git clone --depth 1 --branch "$BRANCH" "$REPO_URL" "$INSTALL_DIR" || {
    error "Failed to clone repository"
}
echo

# Find the installation script
INSTALL_SCRIPT=""
if [ -f "$INSTALL_DIR/apollo-os-install.sh" ]; then
    INSTALL_SCRIPT="$INSTALL_DIR/apollo-os-install.sh"
    log "Found install script in repository root ✓"
elif [ -f "$INSTALL_DIR/v1.0.2/apollo-os-install.sh" ]; then
    INSTALL_SCRIPT="$INSTALL_DIR/v1.0.2/apollo-os-install.sh"
    log "Found install script in v1.0.2 directory ✓"
else
    error "Installation script not found in repository!"
fi

# Make it executable
chmod +x "$INSTALL_SCRIPT"

echo
echo -e "${MAGENTA}═══════════════════════════════════════════════════════${NC}"
echo -e "${CYAN}  Running Complete Installation${NC}"
echo -e "${MAGENTA}═══════════════════════════════════════════════════════${NC}"
echo

# Run the installation script
cd "$(dirname "$INSTALL_SCRIPT")"
bash "$INSTALL_SCRIPT"

INSTALL_EXIT_CODE=$?

echo
if [ $INSTALL_EXIT_CODE -eq 0 ]; then
    echo -e "${GREEN}═══════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}  Apollo OS Update Complete! ✓${NC}"
    echo -e "${GREEN}═══════════════════════════════════════════════════════${NC}"
else
    echo -e "${RED}═══════════════════════════════════════════════════════${NC}"
    echo -e "${RED}  Installation completed with errors${NC}"
    echo -e "${RED}═══════════════════════════════════════════════════════${NC}"
fi

# Cleanup
log "Cleaning up temporary files..."
rm -rf "$INSTALL_DIR"

echo
echo -e "${YELLOW}Note:${NC} Log out and log back in for all changes to take effect."
echo
read -p "Press Enter to continue..."
