#!/bin/bash

#####################################################################
# Apollo OS - greetd Installation Helper
# Copyright © 2026 by Manuel Kraibacher
#
# Description: Installs and configures greetd + tuigreet
# Must be run with sudo
#####################################################################

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# Check if running as root
if [[ "$EUID" -ne 0 ]]; then
    echo -e "${RED}ERROR: This script must be run as root (sudo)${NC}"
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo -e "${CYAN}═══════════════════════════════════════════════════════${NC}"
echo -e "${CYAN}  Apollo OS - greetd Installer${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════════${NC}\n"

# Install greetd and tuigreet
echo -e "${YELLOW}Installing greetd and tuigreet...${NC}"
dnf install -y greetd || {
    echo -e "${YELLOW}greetd not in repos, installing from source...${NC}"
    # Add installation from source if needed
}

# Install tuigreet (may need COPR or build from source)
if ! command -v tuigreet &>/dev/null; then
    echo -e "${YELLOW}Installing tuigreet...${NC}"

    # Try COPR first
    dnf copr enable -y fszymanski/tuigreet || true
    dnf install -y tuigreet || {
        echo -e "${YELLOW}Building tuigreet from source...${NC}"
        dnf install -y cargo rust
        cargo install tuigreet
        cp ~/.cargo/bin/tuigreet /usr/local/bin/
    }
fi

# Copy greetd config
echo -e "${YELLOW}Configuring greetd...${NC}"
mkdir -p /etc/greetd
cp "$SCRIPT_DIR/config-data/greetd/config.toml" /etc/greetd/config.toml

# Copy session selector
echo -e "${YELLOW}Installing session selector...${NC}"
cp "$SCRIPT_DIR/scripts/apollo-session-selector.sh" /usr/local/bin/apollo-session-selector
chmod +x /usr/local/bin/apollo-session-selector

# Copy wrapper scripts to global location (needed for tuigreet)
echo -e "${YELLOW}Installing wrapper scripts to /usr/local/bin/...${NC}"
cp "$SCRIPT_DIR/scripts/apollo-os-wrapper-niri.sh" /usr/local/bin/apollo-os-wrapper-niri.sh
cp "$SCRIPT_DIR/scripts/apollo-os-wrapper-sway.sh" /usr/local/bin/apollo-os-wrapper-sway.sh
chmod +x /usr/local/bin/apollo-os-wrapper-niri.sh
chmod +x /usr/local/bin/apollo-os-wrapper-sway.sh

# Disable current display manager
echo -e "${YELLOW}Disabling current display manager...${NC}"
systemctl disable gdm 2>/dev/null || true
systemctl disable sddm 2>/dev/null || true
systemctl disable lightdm 2>/dev/null || true

# Enable greetd
echo -e "${YELLOW}Enabling greetd...${NC}"
systemctl enable greetd
systemctl set-default graphical.target

echo -e "\n${GREEN}═══════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}  greetd Installation Complete!${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════════════${NC}\n"

echo -e "${CYAN}Next Steps:${NC}"
echo "1. Reboot your system"
echo "2. You will see the tuigreet terminal login"
echo "3. Select your Apollo OS session"
echo
echo -e "${YELLOW}To revert to GDM:${NC}"
echo "  sudo systemctl disable greetd"
echo "  sudo systemctl enable gdm"
echo
