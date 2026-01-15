#!/bin/bash

#####################################################################
# Apollo OS - Quick Action Menu
# Copyright © 2026 by Manuel Kraibacher
#
# Description: Rofi-based quick action menu
# Keybinding: Super+Shift+Space
#####################################################################

set -e

# Ensure XDG_RUNTIME_DIR for TTS/audio
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"

# Load config for theme detection
CONFIG_FILE="$HOME/.config/apollo-os/config.env"
if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
fi

# Define actions (v0.5.0 - without AI features)
actions=(
    "🔒 Lock Screen"
    "🖼️  Next Wallpaper"
    "🎨 Visual Mode"
    "⚡ Power Profiles"
    "🔍 Display Scaling"
    "🖥️  External Monitor Scaling"
    "🔄 APOLLO OS Update"
    "⌨️  Keyboard Shortcuts"
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
        # TTS before terminal opens
        "$HOME/.local/bin/apollo-os-tts-notify.sh" update-start >/dev/null 2>&1
        alacritty -e bash -c "$HOME/.local/bin/apollo-os-update.sh; $HOME/.local/bin/apollo-os-tts-notify.sh update-complete >/dev/null 2>&1"
        ;;

    "⌨️  Keyboard Shortcuts")
        "$HOME/.local/bin/apollo-os-shortcuts.sh"
        ;;

    "🖼️  Next Wallpaper")
        "$HOME/.local/bin/apollo-os-wallpaper-cycle.sh"
        ;;

    "🎨 Visual Mode")
        # Get current mode
        current_mode=$("$HOME/.local/bin/apollo-os-visual-mode.sh" status 2>/dev/null || echo "classic")
        modes="Classic\nModern"
        selected_mode=$(echo -e "$modes" | rofi -dmenu -p "Visual Mode (current: $current_mode)")
        if [ -n "$selected_mode" ]; then
            "$HOME/.local/bin/apollo-os-visual-mode.sh" "$(echo "$selected_mode" | tr '[:upper:]' '[:lower:]')"
        fi
        ;;

    "⚡ Power Profiles")
        # Get available profiles with clearer descriptions
        if command -v powerprofilesctl &>/dev/null; then
            current=$(powerprofilesctl get 2>/dev/null || echo "balanced")
            
            # Create menu with descriptions
            options="🔋 Power Saver - Save battery, lower performance
⚖️  Balanced - Standard mode (default)
⚡ Performance - Maximum performance"
            
            selected_option=$(echo -e "$options" | rofi -dmenu -p "Power Profile (current: $current)" -i)
            
            if [ -n "$selected_option" ]; then
                case "$selected_option" in
                    *"Power Saver"*)
                        profile="power-saver"
                        ;;
                    *"Balanced"*)
                        profile="balanced"
                        ;;
                    *"Performance"*)
                        profile="performance"
                        ;;
                esac
                
                if [ -n "$profile" ]; then
                    powerprofilesctl set "$profile" 2>/dev/null && \
                        notify-send "Apollo OS" "Power profile: $profile activated"
                fi
            fi
        else
            notify-send "Apollo OS" "Power profiles not available"
        fi
        ;;

    "🔍 Display Scaling")
        # Display scaling options for internal display
        scales="1.0 - No scaling (100%)
1.25 - Small scaling (125%)
1.5 - Medium scaling (150%)
2.0 - Large scaling (200%)"
        selected_scale=$(echo -e "$scales" | rofi -dmenu -p "Display Scaling")
        if [ -n "$selected_scale" ]; then
            scale_value=$(echo "$selected_scale" | awk '{print $1}')
            "$HOME/.local/bin/apollo-os-scale-setter.sh" "$scale_value"
        fi
        ;;

    "🖥️  External Monitor Scaling")
        # External monitor scaling
        scales="1.0 - No scaling (100%)
1.25 - Small scaling (125%)
1.5 - Medium scaling (150%)
2.0 - Large scaling (200%)"
        selected_scale=$(echo -e "$scales" | rofi -dmenu -p "External Monitor Scaling")
        if [ -n "$selected_scale" ]; then
            scale_value=$(echo "$selected_scale" | awk '{print $1}')
            "$HOME/.local/bin/apollo-os-scale-setter.sh" "$scale_value" external
            notify-send "Apollo OS" "External monitor scaling set to ${scale_value}x\nReconnect monitor to apply"
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
            # TTS announcement before shutdown
            "$HOME/.local/bin/apollo-os-tts-notify.sh" shutdown
            sleep 1
            systemctl poweroff
        fi
        ;;

    "🔄 Reboot")
        # Confirm
        confirm=$(echo -e "No\nYes" | rofi -dmenu -p "Reboot System?")
        if [ "$confirm" = "Yes" ]; then
            # TTS announcement before reboot
            "$HOME/.local/bin/apollo-os-tts-notify.sh" reboot
            sleep 1
            systemctl reboot
        fi
        ;;
esac
