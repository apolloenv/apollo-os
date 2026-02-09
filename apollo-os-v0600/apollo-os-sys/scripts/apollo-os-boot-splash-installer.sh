#!/bin/bash

#####################################################################
# Apollo OS - Boot Splash Installer
# Copyright © 2025 by Manuel Kraibacher
#
# Description: Configures verbose boot with ASCII splash
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
LOGO_FILE="$SCRIPT_DIR/assets/boot/apollo-os-boot-logo.txt"

echo -e "${CYAN}═══════════════════════════════════════════════════════${NC}"
echo -e "${CYAN}  Apollo OS - Boot Splash Installer${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════════${NC}\n"

# Backup current GRUB config
echo -e "${YELLOW}Backing up GRUB configuration...${NC}"
cp /etc/default/grub /etc/default/grub.backup.$(date +%Y%m%d)

# Modify GRUB for verbose boot
echo -e "${YELLOW}Configuring GRUB for verbose boot...${NC}"

# Remove quiet and splash parameters (preserve other kernel args)
sed -i 's/ quiet//g; s/quiet //g' /etc/default/grub
sed -i 's/ splash//g; s/splash //g' /etc/default/grub
sed -i 's/ rhgb//g; s/rhgb //g' /etc/default/grub

# Set terminal output to console
if ! grep -q "GRUB_TERMINAL_OUTPUT=console" /etc/default/grub; then
    echo 'GRUB_TERMINAL_OUTPUT=console' >> /etc/default/grub
fi

# Enable GRUB_TERMINAL to see boot messages
if ! grep -q "GRUB_TERMINAL=console" /etc/default/grub; then
    echo 'GRUB_TERMINAL=console' >> /etc/default/grub
fi

# Disable Plymouth (graphical boot splash)
echo -e "${YELLOW}Disabling Plymouth...${NC}"
dnf remove -y plymouth plymouth-core-libs 2>/dev/null || true

# Create boot splash service
echo -e "${YELLOW}Creating boot splash service...${NC}"

cat > /etc/systemd/system/apollo-boot-splash.service <<EOF
[Unit]
Description=Apollo OS Boot Splash
DefaultDependencies=no
Before=systemd-user-sessions.service
After=systemd-vconsole-setup.service

[Service]
Type=oneshot
ExecStartPre=/usr/bin/sleep 1
ExecStart=/usr/bin/bash -c 'clear && cat /usr/share/apollo-os/boot-logo.txt && sleep 3'
StandardOutput=tty
StandardError=journal
TTYPath=/dev/tty1
TTYReset=yes
TTYVHangup=yes
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF

# Copy logo to system location
echo -e "${YELLOW}Installing ASCII logo...${NC}"
mkdir -p /usr/share/apollo-os
cp "$LOGO_FILE" /usr/share/apollo-os/boot-logo.txt

# Enable service
systemctl daemon-reload
systemctl enable apollo-boot-splash.service

# Regenerate GRUB config
echo -e "${YELLOW}Regenerating GRUB configuration...${NC}"
if [[ -f /boot/efi/EFI/fedora/grub.cfg ]]; then
    # UEFI system
    grub2-mkconfig -o /boot/efi/EFI/fedora/grub.cfg
elif [[ -f /boot/grub2/grub.cfg ]]; then
    # BIOS system
    grub2-mkconfig -o /boot/grub2/grub.cfg
else
    echo -e "${RED}WARNING: Could not find GRUB config file${NC}"
fi

# Set kernel parameters for better terminal output
echo -e "${YELLOW}Configuring kernel parameters...${NC}"
grubby --update-kernel=ALL --args="systemd.show_status=true"

echo -e "\n${GREEN}═══════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}  Boot Splash Installation Complete!${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════════════${NC}\n"

echo -e "${CYAN}Changes Applied:${NC}"
echo "  ✓ GRUB configured for verbose boot"
echo "  ✓ Plymouth disabled"
echo "  ✓ ASCII splash service installed"
echo "  ✓ Boot messages enabled"
echo
echo -e "${YELLOW}Reboot to see changes${NC}"
echo
echo -e "${CYAN}To revert:${NC}"
echo "  sudo systemctl disable apollo-boot-splash.service"
echo "  sudo cp /etc/default/grub.backup.* /etc/default/grub"
echo "  sudo grub2-mkconfig -o /boot/grub2/grub.cfg (or EFI path)"
echo
