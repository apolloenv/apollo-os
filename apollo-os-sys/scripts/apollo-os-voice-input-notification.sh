#!/bin/bash
# Voice Input Notification - Einfache statische Benachrichtigung

NOTIFICATION_ID="voice-input-recording"
PID_FILE="${XDG_RUNTIME_DIR:-/tmp}/voice-notification.pid"

if [ "$1" = "stop" ]; then
    # Entferne PID-File falls vorhanden
    if [ -f "$PID_FILE" ]; then
        rm "$PID_FILE"
    fi
    # Schließe Benachrichtigung
    makoctl dismiss --all
    exit 0
fi

# Zeige statische Benachrichtigung
notify-send \
    --app-name="voice-input" \
    --urgency=normal \
    --expire-time=0 \
    --category=recording \
    --replace-id=999999 \
    "Spracheingabe" \
    ""

# Markiere als aktiv
touch "$PID_FILE"
