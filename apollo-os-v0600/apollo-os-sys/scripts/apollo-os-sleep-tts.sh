#!/bin/bash
#####################################################################
# Apollo OS Sleep/Wake TTS - Amala Voice
# Copyright © 2025 by Manuel Kraibacher
#####################################################################

export XDG_RUNTIME_DIR="/run/user/$(id -u)"

VOICE_MODEL="de-DE-AmalaNeural"
EDGE_TTS="$HOME/.local/bin/edge-tts"
[ ! -x "$EDGE_TTS" ] && EDGE_TTS="/usr/local/bin/edge-tts"

ACTION="$1"

speak() {
    local text="$1"
    local tmpfile="/tmp/apollo-sleep-tts-$$.mp3"
    
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
