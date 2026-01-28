#!/bin/bash

#####################################################################
# Apollo OS - Power Profile Toggle with TTS
# Copyright © 2025 by Manuel Kraibacher
#
# Description: Toggle power profiles with TTS feedback
#####################################################################

# Ensure XDG_RUNTIME_DIR for TTS
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"

# Check if powerprofilesctl is available
if ! command -v powerprofilesctl &>/dev/null; then
    notify-send "Apollo OS" "Power profiles not available"
    exit 1
fi

# Get current profile
current=$(powerprofilesctl get 2>/dev/null || echo "balanced")

# Toggle to next profile (power-saver -> balanced -> performance -> power-saver)
case "$current" in
    power-saver)
        next="balanced"
        ;;
    balanced)
        next="performance"
        ;;
    performance)
        next="power-saver"
        ;;
    *)
        next="balanced"
        ;;
esac

# Set new profile
if powerprofilesctl set "$next" 2>/dev/null; then
    notify-send "Apollo OS" "Power profile: $next"

    # TTS feedback
    if [ -x "$HOME/.local/bin/apollo-os-tts-notify.sh" ]; then
        "$HOME/.local/bin/apollo-os-tts-notify.sh" "$next" >/dev/null 2>&1 &
    fi
else
    notify-send "Apollo OS" "Failed to set power profile"
fi
