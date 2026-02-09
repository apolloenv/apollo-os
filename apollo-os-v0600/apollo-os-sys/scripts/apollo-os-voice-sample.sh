#!/bin/bash
#####################################################################
# Apollo OS Voice Sample - Amala
# Copyright © 2025 by Manuel Kraibacher
#####################################################################

export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"

EDGE_TTS=""
for p in "$HOME/.local/bin/edge-tts" "/usr/local/bin/edge-tts" "/usr/bin/edge-tts"; do
    [ -x "$p" ] && EDGE_TTS="$p" && break
done

[ -z "$EDGE_TTS" ] && exit 1

TMPFILE="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/apollo-sample-$$.mp3"
"$EDGE_TTS" -t "Ich bin Amala, deine Apollo OS Systemstimme." -v "de-DE-AmalaNeural" --write-media "$TMPFILE" 2>/dev/null

if [ -f "$TMPFILE" ]; then
    pw-play "$TMPFILE" 2>/dev/null || paplay "$TMPFILE" 2>/dev/null || mpg123 -q "$TMPFILE" 2>/dev/null
    rm -f "$TMPFILE"
fi
