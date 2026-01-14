#!/bin/bash
# Apollo OS Sleep/Wake Monitor
# Copyright © 2026 by Manuel Kraibacher
#
# Uses gdbus to monitor PrepareForSleep signal from logind
# Triggers TTS notifications before sleep and after wake

export XDG_RUNTIME_DIR="/run/user/$(id -u)"
TTS_SCRIPT="$HOME/.local/bin/apollo-os-tts-notify.sh"
SLEEP_MARKER="/tmp/apollo-os-sleeping"

# Monitor PrepareForSleep signal from logind
gdbus monitor --system --dest org.freedesktop.login1 --object-path /org/freedesktop/login1 2>/dev/null | while read -r line; do
    if echo "$line" | grep -q "PrepareForSleep.*true"; then
        # Going to sleep
        touch "$SLEEP_MARKER"
        "$TTS_SCRIPT" sleep
    elif echo "$line" | grep -q "PrepareForSleep.*false"; then
        # Waking up
        sleep 2
        "$TTS_SCRIPT" wake
        rm -f "$SLEEP_MARKER"
    fi
done
