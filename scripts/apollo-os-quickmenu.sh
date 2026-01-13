#!/bin/bash

#####################################################################
# Apollo OS - Quick Action Menu
# Copyright © 2026 by Manuel Kraibacher
#
# Description: Rofi-based quick action menu
# Keybinding: Super+Shift+Space
#####################################################################

set -e

# Load config for theme detection
CONFIG_FILE="$HOME/.config/apollo-os/config.env"
if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
fi

# Define actions (v0.5.0 - without AI features)
actions=(
    " Lock Screen"
    " Toggle Theme"
    " Show Statistics"
    " Next Wallpaper"
    " Power Profiles"
    " Reload Waybar"
    " Reload Mako"
    " Logout"
    " Restart WM"
    " Shutdown"
    " Reboot"
)

# Show menu
selected=$(printf '%s\n' "${actions[@]}" | rofi -dmenu -p "Apollo Quick Menu" -i)

# Execute selected action
case "$selected" in
    " Lock Screen")
        # Use swaylock with black background
        if command -v swaylock &>/dev/null; then
            swaylock -f -c 000000
        else
            notify-send "Apollo OS" "swaylock not installed"
        fi
        ;;

    " Toggle Theme")
        "$HOME/.local/bin/apollo-os-theme-switcher.sh" toggle
        ;;

    " Show Statistics")
        "$HOME/.local/bin/apollo-os-stats.sh"
        ;;

    " Next Wallpaper")
        "$HOME/.local/bin/apollo-os-wallpaper-cycle.sh"
        ;;

    " Power Profiles")
        # Get available profiles
        if command -v powerprofilesctl &>/dev/null; then
            profiles=$(powerprofilesctl list 2>/dev/null | grep -E '^\*?\s+\w+' | sed 's/^\*\?\s*//' || echo "balanced")
            selected_profile=$(echo "$profiles" | rofi -dmenu -p "Power Profile")
            if [ -n "$selected_profile" ]; then
                powerprofilesctl set "$selected_profile" 2>/dev/null && \
                    notify-send "Apollo OS" "Power profile: $selected_profile"
            fi
        else
            notify-send "Apollo OS" "Power profiles not available"
        fi
        ;;

    " Reload Waybar")
        pkill -x waybar 2>/dev/null || true
        sleep 0.5
        waybar -c "$HOME/.config/waybar/config" -s "$HOME/.config/waybar/style.css" &
        notify-send "Apollo OS" "Waybar reloaded"
        ;;

    " Reload Mako")
        pkill -x mako 2>/dev/null || true
        sleep 0.2
        mako --config "$HOME/.config/mako/config" &
        notify-send "Apollo OS" "Mako reloaded"
        ;;

    " Logout")
        # Confirm
        confirm=$(echo -e "No\nYes" | rofi -dmenu -p "Logout?")
        if [ "$confirm" = "Yes" ]; then
            if pgrep -x niri >/dev/null; then
                niri msg action quit
            fi
        fi
        ;;

    " Restart WM")
        # Confirm
        confirm=$(echo -e "No\nYes" | rofi -dmenu -p "Restart Window Manager?")
        if [ "$confirm" = "Yes" ]; then
            if pgrep -x niri >/dev/null; then
                niri msg action quit
                # Note: This will exit to login manager, user needs to re-login
            fi
        fi
        ;;

    " Shutdown")
        # Confirm
        confirm=$(echo -e "No\nYes" | rofi -dmenu -p "Shutdown System?")
        if [ "$confirm" = "Yes" ]; then
            systemctl poweroff
        fi
        ;;

    " Reboot")
        # Confirm
        confirm=$(echo -e "No\nYes" | rofi -dmenu -p "Reboot System?")
        if [ "$confirm" = "Yes" ]; then
            systemctl reboot
        fi
        ;;
esac
