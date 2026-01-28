#!/bin/bash
#####################################################################
# Apollo OS - Welcome TTS - Amala Voice
# Copyright © 2025 by Manuel Kraibacher
#####################################################################

sleep 5

# Ensure environment
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"

# Fixed voice: Amala (German)
VOICE_MODEL="de-DE-AmalaNeural"

# Find edge-tts
EDGE_TTS=""
for p in "$HOME/.local/bin/edge-tts" "/usr/local/bin/edge-tts" "/usr/bin/edge-tts"; do
    [ -x "$p" ] && EDGE_TTS="$p" && break
done

[ -z "$EDGE_TTS" ] && exit 0

# Check network connection
if nmcli -t -f STATE general 2>/dev/null | grep -q "connected"; then
    NETWORK_STATUS="Netzwerkverbindung etabliert. Datenlink aktiv."
else
    NETWORK_STATUS="Kein Netzwerk verbunden. Offline-Modus aktiv."
fi

# Build message (German for Amala)
MESSAGE="Apollo OS System Core gestartet. Alle Module initialisiert. Diagnose abgeschlossen. ${NETWORK_STATUS} Bereit für Einsatz."

# Generate and play TTS
TMPFILE="/tmp/apollo-welcome-$$.mp3"
"$EDGE_TTS" -t "$MESSAGE" -v "$VOICE_MODEL" --write-media "$TMPFILE" 2>/dev/null

if [ -f "$TMPFILE" ]; then
    pw-play "$TMPFILE" 2>/dev/null || paplay "$TMPFILE" 2>/dev/null || mpg123 -q "$TMPFILE" 2>/dev/null
    rm -f "$TMPFILE"
fi
