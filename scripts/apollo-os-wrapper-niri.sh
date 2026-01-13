#!/bin/bash

#####################################################################
# Apollo OS - Niri Wrapper Script
# Copyright © 2026 by Manuel Kraibacher
#
# Description: Launches Niri with the correct profile configuration
# Usage: apollo-os-wrapper-niri.sh [pro|mod] [dark|light]
#####################################################################

set -e

# Default configuration
CONFIG_DIR="$HOME/.config/niri"
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
    NIRI_CONFIG="$CONFIG_DIR/apollo-os-config-${PROFILE}.kdl"
    WAYBAR_CONFIG="$WAYBAR_CONFIG_DIR/apollo-os-config-niri-${PROFILE}"
    WAYBAR_STYLE="$WAYBAR_CONFIG_DIR/apollo-os-style-niri-${PROFILE}.css"
    MAKO_CONFIG="$HOME/.config/mako/apollo-os-config-dark"
    ROFI_THEME="$HOME/.config/rofi/apollo-os-theme-dark.rasi"
else
    NIRI_CONFIG="$CONFIG_DIR/apollo-os-config-${PROFILE}-light.kdl"
    WAYBAR_CONFIG="$WAYBAR_CONFIG_DIR/apollo-os-config-niri-${PROFILE}-light"
    WAYBAR_STYLE="$WAYBAR_CONFIG_DIR/apollo-os-style-niri-${PROFILE}-light.css"
    MAKO_CONFIG="$HOME/.config/mako/apollo-os-config-light"
    ROFI_THEME="$HOME/.config/rofi/apollo-os-theme-light.rasi"
fi

# Check if config exists
if [[ ! -f "$NIRI_CONFIG" ]]; then
    echo "ERROR: Niri configuration not found: $NIRI_CONFIG"
    exit 1
fi

# Export environment variables for the session
export APOLLO_WM="niri"
export APOLLO_PROFILE="$PROFILE"
export APOLLO_THEME="$THEME"
export WAYBAR_CONFIG_FILE="$WAYBAR_CONFIG"
export WAYBAR_STYLE_FILE="$WAYBAR_STYLE"
export MAKO_CONFIG_FILE="$MAKO_CONFIG"
export ROFI_THEME_FILE="$ROFI_THEME"
export SWAYOSD_STYLE="$HOME/.config/swayosd/apollo-os-style-${THEME}.css"
export SWAYLOCK_CONFIG="$HOME/.config/swaylock/apollo-os-config-${THEME}"

# Log session start
echo "[Apollo OS] Starting Niri session"
echo "  Profile: $PROFILE"
echo "  Theme: $THEME"
echo "  Config: $NIRI_CONFIG"

# Start essential services before WM
start_services() {
    # Waybar with profile-specific config
    if command -v waybar &>/dev/null; then
        waybar -c "$WAYBAR_CONFIG" -s "$WAYBAR_STYLE" &
    fi

    # Mako notification daemon
    if command -v mako &>/dev/null; then
        mako --config "$MAKO_CONFIG" &
    fi

    # Wallpaper (swaybg for Niri)
    if command -v swaybg &>/dev/null; then
        WALLPAPER_PATH="$HOME/System/Wallpaper/current.jpg"
        if [ -f "$WALLPAPER_PATH" ]; then
            swaybg -i "$WALLPAPER_PATH" -m fill &
        fi
    fi

    # SwayOSD for volume/brightness overlays
    if command -v swayosd-server &>/dev/null; then
        # Set GTK theme based on APOLLO_THEME for SwayOSD styling
        if [[ "$APOLLO_THEME" == "dark" ]]; then
            export GTK_THEME="Adwaita:light"  # Light theme for dark system (Inversion)
        else
            export GTK_THEME="Adwaita:dark"   # Dark theme for light system (Inversion)
        fi
        swayosd-server &
    fi

    # Idle management
    if command -v swayidle &>/dev/null; then
        swayidle -w \
            timeout 300 "swaylock -f -C $SWAYLOCK_CONFIG" \
            timeout 600 'niri msg action power-off-monitors' \
            resume 'niri msg action power-on-monitors' \
            before-sleep "swaylock -f -C $SWAYLOCK_CONFIG" &
    fi

    # Network Manager applet
    if command -v nm-applet &>/dev/null; then
        nm-applet --indicator &
    fi

    # Bluetooth applet
    if command -v blueman-applet &>/dev/null; then
        blueman-applet &
    fi
}

# Start background services
start_services

# Note: Login greeting is handled by apollo-autostart.sh (spawn-at-startup in niri config)

# Launch Niri with the selected config
exec niri --config "$NIRI_CONFIG"
