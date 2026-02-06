#!/bin/bash
# Apollo OS Sleep/Wake Monitor - Amala Voice
# Copyright © 2025 by Manuel Kraibacher
#
# Uses gdbus to monitor PrepareForSleep signal from logind
# Triggers TTS notifications before sleep and after wake

export XDG_RUNTIME_DIR="/run/user/$(id -u)"

SLEEP_MARKER="/tmp/apollo-os-sleeping"
SOUND_SLEEP="$HOME/.local/share/apollo-os/sounds/sleep.mp3"
SOUND_WAKE="$HOME/.local/share/apollo-os/sounds/wake.mp3"

# Monitor PrepareForSleep signal from logind
gdbus monitor --system --dest org.freedesktop.login1 --object-path /org/freedesktop/login1 2>/dev/null | while read -r line; do
    if echo "$line" | grep -q "PrepareForSleep.*true"; then
        # Going to sleep
        touch "$SLEEP_MARKER"
        [ -f "$SOUND_SLEEP" ] && pw-play "$SOUND_SLEEP" 2>/dev/null
    elif echo "$line" | grep -q "PrepareForSleep.*false"; then
        # Waking up
        sleep 2
        [ -f "$SOUND_WAKE" ] && pw-play "$SOUND_WAKE" 2>/dev/null
        rm -f "$SLEEP_MARKER"
    fi
done
