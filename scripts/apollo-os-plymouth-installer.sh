#!/bin/bash

#####################################################################
# Apollo OS - Plymouth Boot Splash Installer (Alternative)
# Copyright © 2026 by Manuel Kraibacher
#
# Description: Installiert Plymouth mit Apollo OS Watermark
# Alternative zum ASCII-Boot-Splash
# Must be run with sudo
#####################################################################

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'

# Check if running as root
if [[ "$EUID" -ne 0 ]]; then
    echo -e "${RED}ERROR: This script must be run as root (sudo)${NC}"
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WATERMARK_FILE="$SCRIPT_DIR/assets/spinner/APOLLO OS.png"

echo -e "${CYAN}═══════════════════════════════════════════════════════${NC}"
echo -e "${CYAN}  Apollo OS - Plymouth Splash Installer${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════════${NC}\n"

# Check if watermark exists
if [[ ! -f "$WATERMARK_FILE" ]]; then
    echo -e "${RED}ERROR: Watermark file not found: $WATERMARK_FILE${NC}"
    exit 1
fi

echo -e "${YELLOW}Watermark gefunden: $WATERMARK_FILE${NC}"

# Install Plymouth if not present
if ! rpm -q plymouth &>/dev/null; then
    echo -e "${YELLOW}Installing Plymouth...${NC}"
    dnf install -y plymouth plymouth-system-theme plymouth-scripts plymouth-plugin-script
else
    echo -e "${GREEN}✓ Plymouth already installed${NC}"
fi

# Verify spinner theme exists
if [[ ! -d /usr/share/plymouth/themes/spinner ]]; then
    echo -e "${RED}ERROR: Spinner theme directory not found!${NC}"
    echo -e "${RED}Expected: /usr/share/plymouth/themes/spinner${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Spinner theme directory exists${NC}"

# Backup original watermark if it exists
if [[ -f /usr/share/plymouth/themes/spinner/watermark.png ]]; then
    echo -e "${YELLOW}Backing up original watermark...${NC}"
    cp /usr/share/plymouth/themes/spinner/watermark.png \
       /usr/share/plymouth/themes/spinner/watermark.png.backup.$(date +%Y%m%d)
    echo -e "${GREEN}✓ Original watermark backed up${NC}"
fi

# Copy Apollo OS watermark
echo -e "${YELLOW}Installing Apollo OS watermark...${NC}"
cp "$WATERMARK_FILE" /usr/share/plymouth/themes/spinner/watermark.png

# Verify copy
if [[ ! -f /usr/share/plymouth/themes/spinner/watermark.png ]]; then
    echo -e "${RED}ERROR: Failed to copy watermark!${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Watermark installed successfully${NC}"

# Set correct permissions
echo -e "${YELLOW}Setting permissions...${NC}"
chmod 644 /usr/share/plymouth/themes/spinner/watermark.png
chown root:root /usr/share/plymouth/themes/spinner/watermark.png

# Check current Plymouth theme
CURRENT_THEME=$(plymouth-set-default-theme)
echo -e "${CYAN}Current Plymouth theme: ${CURRENT_THEME}${NC}"

# Set spinner as default theme if not already
if [[ "$CURRENT_THEME" != "spinner" ]]; then
    echo -e "${YELLOW}Setting spinner as default theme...${NC}"
    plymouth-set-default-theme spinner
    echo -e "${GREEN}✓ Spinner theme set as default${NC}"
else
    echo -e "${GREEN}✓ Spinner theme already default${NC}"
fi

# Rebuild initramfs
echo -e "${YELLOW}Rebuilding initramfs (this may take a moment)...${NC}"
dracut -f

# Update GRUB to enable Plymouth
echo -e "${YELLOW}Updating GRUB configuration...${NC}"

# Backup GRUB config
cp /etc/default/grub /etc/default/grub.backup.plymouth.$(date +%Y%m%d)

# Ensure splash is in GRUB_CMDLINE_LINUX
if ! grep -q "splash" /etc/default/grub; then
    sed -i 's/GRUB_CMDLINE_LINUX="\(.*\)"/GRUB_CMDLINE_LINUX="\1 splash"/' /etc/default/grub
fi

# Remove quiet if present (for verbose output with splash)
# Uncomment next line if you want to keep boot messages visible
# sed -i 's/ quiet//' /etc/default/grub

# Regenerate GRUB config
if [[ -f /boot/efi/EFI/fedora/grub.cfg ]]; then
    # UEFI system
    grub2-mkconfig -o /boot/efi/EFI/fedora/grub.cfg
elif [[ -f /boot/grub2/grub.cfg ]]; then
    # BIOS system
    grub2-mkconfig -o /boot/grub2/grub.cfg
else
    echo -e "${RED}WARNING: Could not find GRUB config file${NC}"
fi

echo -e "\n${GREEN}═══════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}  Plymouth Installation Complete!${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════════════${NC}\n"

echo -e "${CYAN}Changes Applied:${NC}"
echo "  ✓ Plymouth installed"
echo "  ✓ Apollo OS watermark copied to /usr/share/plymouth/themes/spinner/"
echo "  ✓ Spinner theme set as default"
echo "  ✓ initramfs rebuilt"
echo "  ✓ GRUB configured for Plymouth"
echo
echo -e "${MAGENTA}Watermark Details:${NC}"
ls -lh /usr/share/plymouth/themes/spinner/watermark.png
echo
echo -e "${YELLOW}⚠ Reboot required to see changes${NC}"
echo
echo -e "${CYAN}To verify after reboot:${NC}"
echo "  plymouth-set-default-theme"
echo "  ls -la /usr/share/plymouth/themes/spinner/watermark.png"
echo
echo -e "${CYAN}To revert to original watermark:${NC}"
echo "  sudo cp /usr/share/plymouth/themes/spinner/watermark.png.backup.* \\"
echo "      /usr/share/plymouth/themes/spinner/watermark.png"
echo "  sudo dracut -f"
echo
