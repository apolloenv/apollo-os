#!/bin/bash

#####################################################################
# Apollo OS - Power Profile Switcher
# Copyright © 2026 by Manuel Kraibacher
#
# Description: Cycles through power profiles (power-saver, balanced, performance)
#              Designed to be triggered by Waybar battery click
#####################################################################

# Ensure environment is set
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"

# Check if powerprofilesctl is available
if ! command -v powerprofilesctl &>/dev/null; then
    notify-send "Power Profiles" "powerprofilesctl not found. Install power-profiles-daemon" --urgency=critical
    exit 1
fi

# Get current profile
CURRENT=$(powerprofilesctl get 2>/dev/null)

# Determine next profile
case "$CURRENT" in
    "power-saver")
        NEXT="balanced"
        ICON="⚖️"
        DESCRIPTION="Ausbalanciert"
        ;;
    "balanced")
        NEXT="performance"
        ICON="⚡"
        DESCRIPTION="Leistung"
        ;;
    "performance")
        NEXT="power-saver"
        ICON="🔋"
        DESCRIPTION="Energiesparmodus"
        ;;
    *)
        # Default to balanced if unknown
        NEXT="balanced"
        ICON="⚖️"
        DESCRIPTION="Ausbalanciert"
        ;;
esac

# Set new profile
if powerprofilesctl set "$NEXT" 2>/dev/null; then
    # Send notification
    notify-send \
        --app-name="Apollo OS" \
        --icon="battery" \
        --urgency=low \
        "Power Profile" \
        "$ICON $DESCRIPTION aktiviert"
    
    # Optional: TTS announcement
    if command -v apollo-speak &>/dev/null; then
        case "$NEXT" in
            "power-saver")
                apollo-speak "Power saving mode activated" &
                ;;
            "balanced")
                apollo-speak "Balanced mode activated" &
                ;;
            "performance")
                apollo-speak "Performance mode activated" &
                ;;
        esac
    fi
else
    notify-send \
        --app-name="Apollo OS" \
        --icon="dialog-error" \
        --urgency=critical \
        "Power Profile" \
        "Fehler beim Wechseln des Profils"
fi
