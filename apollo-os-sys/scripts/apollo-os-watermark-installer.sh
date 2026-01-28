#!/usr/bin/env bash

#####################################################################
# Apollo OS - Watermark Installer (Hotfix)
# Installiert das Apollo OS Watermark für Plymouth Boot Splash
#####################################################################

set -e

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Print header
echo -e "${BLUE}================================================"
echo "  Apollo OS - Watermark Installer (Hotfix)"
echo -e "================================================${NC}"
echo

# Check if running as root
if [[ $EUID -eq 0 ]]; then
    echo -e "${RED}ERROR: Do not run this script as root!${NC}"
    echo "Run as normal user: ./apollo-os-watermark-installer.sh"
    exit 1
fi

# Define paths
WATERMARK_SOURCE="$PROJECT_ROOT/assets/spinner/watermark.png"
WATERMARK_TARGET="/usr/share/plymouth/themes/spinner/watermark.png"

# Check if source exists
if [[ ! -f "$WATERMARK_SOURCE" ]]; then
    echo -e "${RED}ERROR: Watermark source not found!${NC}"
    echo "Expected: $WATERMARK_SOURCE"
    exit 1
fi

echo -e "${GREEN}✓${NC} Watermark source found: $WATERMARK_SOURCE"

# Check if Plymouth spinner theme exists
if [[ ! -d /usr/share/plymouth/themes/spinner ]]; then
    echo -e "${YELLOW}WARNING: Plymouth spinner theme directory not found${NC}"
    echo "Directory: /usr/share/plymouth/themes/spinner"
    echo
    echo "This is normal if Plymouth is not installed or using a different theme."
    echo "The watermark is only needed if you're using the spinner theme."
    exit 0
fi

echo -e "${GREEN}✓${NC} Plymouth spinner theme directory exists"
echo

# Backup existing watermark if present
if [[ -f "$WATERMARK_TARGET" ]]; then
    echo -e "${YELLOW}Found existing watermark, creating backup...${NC}"
    BACKUP_FILE="${WATERMARK_TARGET}.backup.$(date +%Y%m%d-%H%M%S)"
    sudo cp "$WATERMARK_TARGET" "$BACKUP_FILE"
    echo -e "${GREEN}✓${NC} Backup created: $BACKUP_FILE"
fi

# Copy Apollo OS watermark
echo "Installing Apollo OS watermark..."
sudo cp "$WATERMARK_SOURCE" "$WATERMARK_TARGET"

# Set permissions
sudo chmod 644 "$WATERMARK_TARGET"
sudo chown root:root "$WATERMARK_TARGET"

echo -e "${GREEN}✓${NC} Watermark installed successfully!"
echo
echo "Watermark location: $WATERMARK_TARGET"
echo -e "${BLUE}The watermark will be visible on next boot if Plymouth is active.${NC}"
echo
