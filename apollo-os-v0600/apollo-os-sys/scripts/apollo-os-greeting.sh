#!/bin/bash

#####################################################################
# Apollo OS - Login Greeting
# Copyright © 2025 by Manuel Kraibacher
#
# Description: Shows a greeting notification based on time of day
#              and speaks the greeting via TTS (English only)
#####################################################################

# Ensure environment variables are set
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
export WAYLAND_DISPLAY="${WAYLAND_DISPLAY:-wayland-1}"

# Get current hour
HOUR=$(date +%H)
USER_NAME="${USER^}"  # Capitalize first letter (for notification only)

# Determine greeting based on time
if [[ $HOUR -ge 5 && $HOUR -lt 12 ]]; then
    GREETING="Guten Morgen"
    ICON="weather-clear"
elif [[ $HOUR -ge 12 && $HOUR -lt 18 ]]; then
    GREETING="Guten Tag"
    ICON="weather-clear"
elif [[ $HOUR -ge 18 && $HOUR -lt 22 ]]; then
    GREETING="Guten Abend"
    ICON="weather-clear-night"
else
    GREETING="Gute Nacht"
    ICON="weather-clear-night"
fi

# Format current time
CURRENT_TIME=$(date +"%H:%M")
CURRENT_DATE=$(date +"%A, %d. %B %Y")

# Show notification
if command -v notify-send &>/dev/null; then
    notify-send \
        --app-name="Apollo OS" \
        --icon="$ICON" \
        --urgency=low \
        "$GREETING, $USER_NAME!" \
        "$CURRENT_TIME\n$CURRENT_DATE\n\nWillkommen bei Apollo OS"
fi
