#!/bin/bash

#####################################################################
# Apollo OS - Login Greeting
# Copyright © 2026 by Manuel Kraibacher
#
# Description: Shows a greeting notification based on time of day
#              and optionally speaks the greeting via TTS
#####################################################################

# Ensure environment variables are set
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
export WAYLAND_DISPLAY="${WAYLAND_DISPLAY:-wayland-1}"

# Get current hour
HOUR=$(date +%H)
USER_NAME="${USER^}"  # Capitalize first letter

# Determine greeting based on time
if [[ $HOUR -ge 5 && $HOUR -lt 12 ]]; then
    GREETING="Guten Morgen"
    GREETING_EN="Good morning"
    ICON="weather-clear"
elif [[ $HOUR -ge 12 && $HOUR -lt 18 ]]; then
    GREETING="Guten Tag"
    GREETING_EN="Good afternoon"
    ICON="weather-clear"
elif [[ $HOUR -ge 18 && $HOUR -lt 22 ]]; then
    GREETING="Guten Abend"
    GREETING_EN="Good evening"
    ICON="weather-clear-night"
else
    GREETING="Gute Nacht"
    GREETING_EN="Good night"
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
        "Es ist $CURRENT_TIME Uhr\n$CURRENT_DATE"
fi

# TTS greeting (optional, only if apollo-speak is available)
if command -v apollo-speak &>/dev/null; then
    apollo-speak "$GREETING_EN, $USER_NAME. Welcome to Apollo OS."
fi
