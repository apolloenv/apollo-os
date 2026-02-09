#!/bin/bash
#####################################################################
# Apollo OS Sleep/Wake TTS - Amala Voice
# Copyright © 2025 by Manuel Kraibacher
#####################################################################

export XDG_RUNTIME_DIR="/run/user/$(id -u)"

# Check if TTS is disabled
TTS_CONFIG="$HOME/.config/apollo-os/tts.conf"
if [ -f "$TTS_CONFIG" ] && grep -q "^TTS_ENABLED=false" "$TTS_CONFIG"; then
    exit 0
fi

VOICE_MODEL="de-DE-AmalaNeural"
EDGE_TTS=""
for p in "$HOME/.local/bin/edge-tts" "/usr/local/bin/edge-tts" "/usr/bin/edge-tts"; do
    [ -x "$p" ] && EDGE_TTS="$p" && break
done

ACTION="$1"

speak() {
    local text="$1"
    local tmpfile="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/apollo-sleep-tts-$$.mp3"
    
    if [ -x "$EDGE_TTS" ]; then
        "$EDGE_TTS" -t "$text" -v "$VOICE_MODEL" --write-media "$tmpfile" 2>/dev/null
        if [ -f "$tmpfile" ]; then
            pw-play "$tmpfile" 2>/dev/null || paplay "$tmpfile" 2>/dev/null
            rm -f "$tmpfile"
        fi
    fi
}

case "$ACTION" in
    sleep)
        speak "Ruhemodus."
        ;;
    wake)
        sleep 1
        speak "System bereit."
        ;;
esac
