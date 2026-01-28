#!/bin/bash

#####################################################################
# Apollo OS - Theme Switcher
# Copyright © 2025 by Manuel Kraibacher
#
# Description: Switches between dark and light themes
# Usage: apollo-os-theme-switcher.sh [dark|light|toggle]
#
# Note: v0.5.0 only supports dark theme. Light theme switching
#       is prepared but requires additional config files.
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

# Reload components
reload_components() {
    local theme="$1"

    echo "Switching to $theme theme..."

    # Config paths (v0.5.0 simplified - single config files)
    WAYBAR_CONFIG="$CONFIG_DIR/waybar/config"
    WAYBAR_STYLE="$CONFIG_DIR/waybar/style.css"
    MAKO_CONFIG="$CONFIG_DIR/mako/config"

    # Reload Waybar
    if pgrep -x waybar >/dev/null; then
        pkill waybar
        sleep 0.5
        waybar -c "$WAYBAR_CONFIG" -s "$WAYBAR_STYLE" &
        echo "  Waybar reloaded"
    fi

    # Reload Mako
    if pgrep -x mako >/dev/null; then
        pkill mako
        sleep 0.5
        mako --config "$MAKO_CONFIG" &
        echo "  Mako reloaded"
    fi

    # Update GTK theme
    if [[ "$theme" == "dark" ]]; then
        gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark' 2>/dev/null || true
        gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark' 2>/dev/null || true
    else
        gsettings set org.gnome.desktop.interface color-scheme 'prefer-light' 2>/dev/null || true
        gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita' 2>/dev/null || true
    fi
    echo "  GTK theme updated"

    # Send notification
    if command -v notify-send &>/dev/null; then
        notify-send "Apollo OS" "Theme switched to: $theme" -i preferences-color
    fi

    echo "Theme switch complete!"
}

# Apply the theme change
reload_components "$NEW_THEME"

# Note about light theme
if [[ "$NEW_THEME" == "light" ]]; then
    echo ""
    echo "Note: Light theme configs are not included in v0.5.0."
    echo "GTK applications will use light theme, but Waybar/Mako"
    echo "will continue using their current configs."
fi
