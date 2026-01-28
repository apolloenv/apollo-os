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

# Determine greeting based on time (English only for TTS)
if [[ $HOUR -ge 5 && $HOUR -lt 12 ]]; then
    GREETING_EN="Good morning"
    TTS_GREETING="Good morning"
    ICON="weather-clear"
elif [[ $HOUR -ge 12 && $HOUR -lt 18 ]]; then
    GREETING_EN="Good afternoon"
    TTS_GREETING="Good afternoon"
    ICON="weather-clear"
elif [[ $HOUR -ge 18 && $HOUR -lt 22 ]]; then
    GREETING_EN="Good evening"
    TTS_GREETING="Good evening"
    ICON="weather-clear-night"
else
    GREETING_EN="Good night"
    TTS_GREETING="Good night"
    ICON="weather-clear-night"
fi

# Format current time
CURRENT_TIME=$(date +"%H:%M")
CURRENT_DATE=$(date +"%A, %d %B %Y")

# Show notification (English, with username)
if command -v notify-send &>/dev/null; then
    notify-send \
        --app-name="Apollo OS" \
        --icon="$ICON" \
        --urgency=low \
        "$GREETING_EN, $USER_NAME!" \
        "It's $CURRENT_TIME\n$CURRENT_DATE\n\nWelcome to Apollo OS"
fi

# Wait a moment for audio system to be ready
sleep 2

# TTS greeting (English, NO username for privacy)
if command -v apollo-speak &>/dev/null; then
    apollo-speak "$TTS_GREETING. Welcome to Apollo OS. All systems operational." &
fi
