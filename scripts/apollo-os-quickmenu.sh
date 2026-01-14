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
    "🔒 Lock Screen"
    "🖼️  Next Wallpaper"
    "⚡ Power Profiles"
    "🔍 Display Scaling"
    "🔄 APOLLO OS Update"
    "📊 Reload Infobar"
    "🔔 Reload Notifications"
    "🪐 Reload Apollo OS Orbit"
    "🚪 Logout"
    "⏻  Shutdown"
    "🔄 Reboot"
)

# Show menu
selected=$(printf '%s\n' "${actions[@]}" | rofi -dmenu -p "Apollo Quick Menu" -i)

# Execute selected action
case "$selected" in
    "🔒 Lock Screen")
        # Use swaylock with black background
        if command -v swaylock &>/dev/null; then
            swaylock -f -c 000000
        else
            notify-send "Apollo OS" "swaylock not installed"
        fi
        ;;

    "🔄 APOLLO OS Update")
        alacritty -e bash -c "$HOME/.local/bin/apollo-os-update.sh"
        ;;

    "🖼️  Next Wallpaper")
        "$HOME/.local/bin/apollo-os-wallpaper-cycle.sh"
        ;;

    "⚡ Power Profiles")
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

    "🔍 Display Scaling")
        # Display scaling options
        scales="1.0\n1.25\n1.5"
        selected_scale=$(echo -e "$scales" | rofi -dmenu -p "Display Scaling")
        if [ -n "$selected_scale" ]; then
            "$HOME/.local/bin/apollo-os-scale-setter.sh" "$selected_scale"
        fi
        ;;

    "📊 Reload Infobar")
        WPID=$(pgrep -x waybar)
        if [ -n "$WPID" ]; then
            kill $WPID 2>/dev/null || true
        fi
        sleep 0.5
        waybar -c "$HOME/.config/waybar/config-niri" &
        notify-send "Apollo OS" "Infobar reloaded"
        ;;

    "🔔 Reload Notifications")
        MPID=$(pgrep -x mako)
        if [ -n "$MPID" ]; then
            kill $MPID 2>/dev/null || true
        fi
        sleep 0.2
        mako --config "$HOME/.config/mako/config" &
        notify-send "Apollo OS" "Notifications reloaded"
        ;;

    "🪐 Reload Apollo OS Orbit")
        # Confirm
        confirm=$(echo -e "No\nYes" | rofi -dmenu -p "Reload Window Manager?")
        if [ "$confirm" = "Yes" ]; then
            if pgrep -x niri >/dev/null; then
                niri msg action quit
                # Note: This will exit to login manager, user needs to re-login
            fi
        fi
        ;;

    "🚪 Logout")
        # Confirm
        confirm=$(echo -e "No\nYes" | rofi -dmenu -p "Logout?")
        if [ "$confirm" = "Yes" ]; then
            if pgrep -x niri >/dev/null; then
                niri msg action quit
            fi
        fi
        ;;

    "⏻  Shutdown")
        # Confirm
        confirm=$(echo -e "No\nYes" | rofi -dmenu -p "Shutdown System?")
        if [ "$confirm" = "Yes" ]; then
            systemctl poweroff
        fi
        ;;

    "🔄 Reboot")
        # Confirm
        confirm=$(echo -e "No\nYes" | rofi -dmenu -p "Reboot System?")
        if [ "$confirm" = "Yes" ]; then
            systemctl reboot
        fi
        ;;
esac
