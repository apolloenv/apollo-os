#!/bin/bash

#####################################################################
# Apollo OS - Sway Wrapper Script
# Copyright © 2026 by Manuel Kraibacher
#
# Description: Launches Sway with the correct profile configuration
# Usage: apollo-os-wrapper-sway.sh [pro|mod] [dark|light]
#####################################################################

set -e

# Default configuration
CONFIG_DIR="$HOME/.config/sway"
APOLLO_CONFIG="$HOME/.config/apollo-os/config.env"
WAYBAR_CONFIG_DIR="$HOME/.config/waybar"

# Load Apollo OS configuration
if [[ -f "$APOLLO_CONFIG" ]]; then
    source "$APOLLO_CONFIG"
else
    # Fallback defaults
    DEFAULT_PROFILE="pro"
    DEFAULT_THEME="dark"
fi

# Parse arguments
PROFILE="${1:-${DEFAULT_PROFILE:-pro}}"
THEME="${2:-${DEFAULT_THEME:-dark}}"

# Validate profile
if [[ ! "$PROFILE" =~ ^(pro|mod)$ ]]; then
    echo "ERROR: Invalid profile '$PROFILE'. Must be 'pro' or 'mod'."
    exit 1
fi

# Validate theme
if [[ ! "$THEME" =~ ^(dark|light)$ ]]; then
    echo "ERROR: Invalid theme '$THEME'. Must be 'dark' or 'light'."
    exit 1
fi

# Determine config file
if [[ "$THEME" == "dark" ]]; then
    SWAY_CONFIG="$CONFIG_DIR/apollo-os-config-${PROFILE}"
    WAYBAR_CONFIG="$WAYBAR_CONFIG_DIR/apollo-os-config-sway-${PROFILE}"
    WAYBAR_STYLE="$WAYBAR_CONFIG_DIR/apollo-os-style-sway-${PROFILE}.css"
    MAKO_CONFIG="$HOME/.config/mako/apollo-os-config-dark"
    ROFI_THEME="$HOME/.config/rofi/apollo-os-theme-dark.rasi"
else
    SWAY_CONFIG="$CONFIG_DIR/apollo-os-config-${PROFILE}-light"
    WAYBAR_CONFIG="$WAYBAR_CONFIG_DIR/apollo-os-config-sway-${PROFILE}-light"
    WAYBAR_STYLE="$WAYBAR_CONFIG_DIR/apollo-os-style-sway-${PROFILE}-light.css"
    MAKO_CONFIG="$HOME/.config/mako/apollo-os-config-light"
    ROFI_THEME="$HOME/.config/rofi/apollo-os-theme-light.rasi"
fi

# Check if config exists
if [[ ! -f "$SWAY_CONFIG" ]]; then
    echo "ERROR: Sway configuration not found: $SWAY_CONFIG"
    exit 1
fi

# Export environment variables for the session
export APOLLO_WM="sway"
export APOLLO_PROFILE="$PROFILE"
export APOLLO_THEME="$THEME"

# GTK Theme for dark mode
if [[ "$THEME" == "dark" ]]; then
    export GTK_THEME="adw-gtk3-dark"
    export ADW_DEBUG_COLOR_SCHEME="prefer-dark"
else
    export GTK_THEME="adw-gtk3"
    export ADW_DEBUG_COLOR_SCHEME="default"
fi

export WAYBAR_CONFIG_FILE="$WAYBAR_CONFIG"
export WAYBAR_STYLE_FILE="$WAYBAR_STYLE"
export MAKO_CONFIG_FILE="$MAKO_CONFIG"
export ROFI_THEME_FILE="$ROFI_THEME"

# Additional Sway-specific environment
export XDG_CURRENT_DESKTOP=sway
export XDG_SESSION_TYPE=wayland
export XDG_SESSION_DESKTOP=sway

# Log session start
echo "[Apollo OS] Starting Sway session"
echo "  Profile: $PROFILE"
echo "  Theme: $THEME"
echo "  Config: $SWAY_CONFIG"

# Note: Login greeting is handled by exec in sway config

# Launch Sway with the selected config
exec sway --config "$SWAY_CONFIG"
