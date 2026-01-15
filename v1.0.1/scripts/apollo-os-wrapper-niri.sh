#!/bin/bash

#####################################################################
# Apollo OS - Niri Wrapper Script v0.5.0
# Copyright © 2026 by Manuel Kraibacher
#
# Description: Launches Niri with Apollo OS configuration
# Services (Waybar, Mako, etc.) are started by apollo-autostart.sh
#####################################################################

set -e

# Configuration directories
CONFIG_DIR="$HOME/.config/niri"
APOLLO_CONFIG="$HOME/.config/apollo-os/config.env"

# Load Apollo OS configuration if exists
if [[ -f "$APOLLO_CONFIG" ]]; then
    source "$APOLLO_CONFIG"
fi

# Config paths (simplified - configs are copied to standard locations)
NIRI_CONFIG="$CONFIG_DIR/config.kdl"
WAYBAR_CONFIG="$HOME/.config/waybar/config"
WAYBAR_STYLE="$HOME/.config/waybar/style.css"
MAKO_CONFIG="$HOME/.config/mako/config"
ROFI_THEME="$HOME/.config/rofi/config.rasi"

# Check if Niri config exists (fallback to named config)
if [[ ! -f "$NIRI_CONFIG" ]]; then
    NIRI_CONFIG="$CONFIG_DIR/apollo-os-niri-config.kdl"
    if [[ ! -f "$NIRI_CONFIG" ]]; then
        echo "ERROR: Niri configuration not found!"
        exit 1
    fi
fi

# Export environment variables for the session
# These are used by keybindings in niri config
export APOLLO_WM="niri"
export APOLLO_THEME="dark"
export WAYBAR_CONFIG_FILE="$WAYBAR_CONFIG"
export WAYBAR_STYLE_FILE="$WAYBAR_STYLE"
export MAKO_CONFIG_FILE="$MAKO_CONFIG"
export ROFI_THEME_FILE="$ROFI_THEME"

# Log session start
echo "[Apollo OS] Starting Niri session"
echo "  Config: $NIRI_CONFIG"

# Note: Services (Waybar, Mako, swaybg, etc.) are started by
# spawn-at-startup in niri config calling apollo-autostart.sh

# Launch Niri with the config
exec niri --config "$NIRI_CONFIG"
