#!/bin/bash

#####################################################################
# Apollo OS - Theme Switcher
# Copyright © 2026 by Manuel Kraibacher
#
# Description: Switches between dark and light themes
# Usage: apollo-os-theme-switcher.sh [dark|light|toggle]
#####################################################################

set -e

# Paths
APOLLO_CONFIG="$HOME/.config/apollo-os/config.env"
CONFIG_DIR="$HOME/.config"

# Load current configuration
if [[ -f "$APOLLO_CONFIG" ]]; then
    source "$APOLLO_CONFIG"
else
    echo "ERROR: Apollo OS configuration not found!"
    exit 1
fi

# Get current theme
CURRENT_THEME="${DEFAULT_THEME:-dark}"
CURRENT_WM="${APOLLO_WM:-niri}"
CURRENT_PROFILE="${APOLLO_PROFILE:-pro}"

# Parse argument
ACTION="${1:-toggle}"

# Determine new theme
case "$ACTION" in
    dark)
        NEW_THEME="dark"
        ;;
    light)
        NEW_THEME="light"
        ;;
    toggle)
        if [[ "$CURRENT_THEME" == "dark" ]]; then
            NEW_THEME="light"
        else
            NEW_THEME="dark"
        fi
        ;;
    *)
        echo "ERROR: Invalid argument. Use: dark, light, or toggle"
        exit 1
        ;;
esac

# Update Apollo OS config file
sed -i "s/^DEFAULT_THEME=.*/DEFAULT_THEME=\"$NEW_THEME\"/" "$APOLLO_CONFIG"

# Reload components based on current WM
reload_components() {
    local wm="$1"
    local profile="$2"
    local theme="$3"

    echo "Switching to $theme theme..."

    # Determine config paths
    if [[ "$theme" == "dark" ]]; then
        WAYBAR_CONFIG="$CONFIG_DIR/waybar/apollo-os-config-${wm}-${profile}"
        WAYBAR_STYLE="$CONFIG_DIR/waybar/apollo-os-style-${wm}-${profile}.css"
        MAKO_CONFIG="$CONFIG_DIR/mako/apollo-os-config-dark"
        ROFI_THEME="$CONFIG_DIR/rofi/apollo-os-theme-dark.rasi"
    else
        WAYBAR_CONFIG="$CONFIG_DIR/waybar/apollo-os-config-${wm}-${profile}-light"
        WAYBAR_STYLE="$CONFIG_DIR/waybar/apollo-os-style-${wm}-${profile}-light.css"
        MAKO_CONFIG="$CONFIG_DIR/mako/apollo-os-config-light"
        ROFI_THEME="$CONFIG_DIR/rofi/apollo-os-theme-light.rasi"
    fi

    # Reload Waybar
    if pgrep -x waybar >/dev/null; then
        pkill waybar
        sleep 0.5
        waybar -c "$WAYBAR_CONFIG" -s "$WAYBAR_STYLE" &
        echo "  ✓ Waybar reloaded"
    fi

    # Reload Mako
    if pgrep -x mako >/dev/null; then
        pkill mako
        sleep 0.5
        mako --config "$MAKO_CONFIG" &
        echo "  ✓ Mako reloaded"
    fi

    # Reload SwayOSD
    if pgrep -x swayosd-server >/dev/null; then
        pkill swayosd-server
        sleep 0.5
        # Set inverted GTK theme for SwayOSD
        if [[ "$theme" == "dark" ]]; then
            GTK_THEME="Adwaita:light" swayosd-server &
        else
            GTK_THEME="Adwaita:dark" swayosd-server &
        fi
        echo "  ✓ SwayOSD reloaded"
    fi

    # Update GTK theme
    if [[ "$theme" == "dark" ]]; then
        gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark' 2>/dev/null || true
        gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark' 2>/dev/null || true
    else
        gsettings set org.gnome.desktop.interface color-scheme 'prefer-light' 2>/dev/null || true
        gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita' 2>/dev/null || true
    fi
    echo "  ✓ GTK theme updated"

    # Send notification
    if command -v notify-send &>/dev/null; then
        notify-send "Apollo OS" "Theme switched to: $theme" -i preferences-color
    fi

    echo "Theme switch complete! ✓"
}

# Apply the theme change
reload_components "$CURRENT_WM" "$CURRENT_PROFILE" "$NEW_THEME"

# For complete theme change, suggest logout
echo ""
echo "Note: For a complete theme change, please log out and log back in."
echo "Window Manager configs will be updated on next login."
