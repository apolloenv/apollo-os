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

# Define actions
actions=(
    "🔒 Lock Screen"
    "🌙 Toggle Theme"
    "💬 Open Chat"
    "🔍 System Diagnostics"
    "📊 Show Statistics"
    "🖼️ Next Wallpaper"
    "⚡ Power Profiles"
    "🔄 Reload Waybar"
    "🔄 Reload Mako"
    "🚪 Logout"
    "🔄 Restart WM"
    "⏻ Shutdown"
    "🔁 Reboot"
)

# Show menu
selected=$(printf '%s\n' "${actions[@]}" | rofi -dmenu -p "Apollo Quick Menu" -i)

# Execute selected action
case "$selected" in
    "🔒 Lock Screen")
        THEME="${DEFAULT_THEME:-dark}"
        swaylock -f -C "$HOME/.config/swaylock/apollo-os-config-${THEME}"
        ;;
    
    "🌙 Toggle Theme")
        "$HOME/.local/bin/apollo-os-theme-switcher.sh" toggle
        ;;
    
    "💬 Open Chat")
        "$HOME/.local/bin/apollo-os-chat.sh" &
        ;;
    
    "🔍 System Diagnostics")
        alacritty -e bash -c "$HOME/.local/bin/apollo-os-diagnose.sh 100; read -p 'Press Enter to close...'"
        ;;
    
    "📊 Show Statistics")
        "$HOME/.local/bin/apollo-os-stats.sh"
        ;;
    
    "🖼️ Next Wallpaper")
        "$HOME/.local/bin/apollo-os-wallpaper-cycle.sh"
        ;;
    
    "⚡ Power Profiles")
        # Get available profiles
        profiles=$(powerprofilesctl list 2>/dev/null || echo "balanced")
        selected_profile=$(echo "$profiles" | rofi -dmenu -p "Power Profile")
        if [ -n "$selected_profile" ]; then
            powerprofilesctl set "$selected_profile" 2>/dev/null && \
                notify-send "Apollo OS" "Power profile: $selected_profile"
        fi
        ;;
    
    "🔄 Reload Waybar")
        pkill -x waybar
        sleep 0.5
        
        # Detect WM and load appropriate config
        if pgrep -x niri >/dev/null; then
            PROFILE="${DEFAULT_PROFILE:-pro}"
            THEME="${DEFAULT_THEME:-dark}"
            waybar -c "$HOME/.config/waybar/apollo-os-config-niri-${PROFILE}" \
                   -s "$HOME/.config/waybar/apollo-os-style-niri-${PROFILE}-${THEME}.css" &
        elif pgrep -x sway >/dev/null; then
            PROFILE="${DEFAULT_PROFILE:-pro}"
            THEME="${DEFAULT_THEME:-dark}"
            waybar -c "$HOME/.config/waybar/apollo-os-config-sway-${PROFILE}" \
                   -s "$HOME/.config/waybar/apollo-os-style-sway-${PROFILE}-${THEME}.css" &
        fi
        notify-send "Apollo OS" "Waybar reloaded"
        ;;
    
    "🔄 Reload Mako")
        pkill -x mako
        sleep 0.2
        THEME="${DEFAULT_THEME:-dark}"
        mako -c "$HOME/.config/mako/apollo-os-config-${THEME}" &
        notify-send "Apollo OS" "Mako reloaded"
        ;;
    
    "🚪 Logout")
        # Confirm
        confirm=$(echo -e "No\nYes" | rofi -dmenu -p "Logout?")
        if [ "$confirm" = "Yes" ]; then
            if pgrep -x niri >/dev/null; then
                niri msg action quit
            elif pgrep -x sway >/dev/null; then
                swaymsg exit
            fi
        fi
        ;;
    
    "🔄 Restart WM")
        # Confirm
        confirm=$(echo -e "No\nYes" | rofi -dmenu -p "Restart Window Manager?")
        if [ "$confirm" = "Yes" ]; then
            if pgrep -x niri >/dev/null; then
                niri msg action quit
                # Note: This will exit to login manager, user needs to re-login
            elif pgrep -x sway >/dev/null; then
                swaymsg reload
            fi
        fi
        ;;
    
    "⏻ Shutdown")
        # Confirm
        confirm=$(echo -e "No\nYes" | rofi -dmenu -p "Shutdown System?")
        if [ "$confirm" = "Yes" ]; then
            systemctl poweroff
        fi
        ;;
    
    "🔁 Reboot")
        # Confirm
        confirm=$(echo -e "No\nYes" | rofi -dmenu -p "Reboot System?")
        if [ "$confirm" = "Yes" ]; then
            systemctl reboot
        fi
        ;;
esac
