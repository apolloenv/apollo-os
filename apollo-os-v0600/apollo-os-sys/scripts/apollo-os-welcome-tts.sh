#!/bin/bash
#####################################################################
# Apollo OS - Welcome TTS - Amala Voice
# Copyright © 2025 by Manuel Kraibacher
#####################################################################

# Wait for audio system to initialize (optimized from 5s)
sleep 2

# Ensure environment
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"

# Check if TTS is disabled
TTS_CONFIG="$HOME/.config/apollo-os/tts.conf"
if [ -f "$TTS_CONFIG" ] && grep -q "^TTS_ENABLED=false" "$TTS_CONFIG"; then
    exit 0
fi

# Fixed voice: Amala (German)
VOICE_MODEL="de-DE-AmalaNeural"

# Find edge-tts
EDGE_TTS=""
for p in "$HOME/.local/bin/edge-tts" "/usr/local/bin/edge-tts" "/usr/bin/edge-tts"; do
    [ -x "$p" ] && EDGE_TTS="$p" && break
done

[ -z "$EDGE_TTS" ] && exit 0

# Build message (German for Amala)
MESSAGE="Willkommen zurück."

# Generate and play TTS
TMPFILE="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/apollo-welcome-$$.mp3"
"$EDGE_TTS" -t "$MESSAGE" -v "$VOICE_MODEL" --write-media "$TMPFILE" 2>/dev/null

if [ -f "$TMPFILE" ]; then
    pw-play "$TMPFILE" 2>/dev/null || paplay "$TMPFILE" 2>/dev/null || mpg123 -q "$TMPFILE" 2>/dev/null
    rm -f "$TMPFILE"
fi
