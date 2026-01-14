#!/bin/bash
#####################################################################
# Apollo OS - Welcome TTS
# Copyright © 2026 by Manuel Kraibacher
#####################################################################

sleep 5

# Find piper binary
PIPER_BIN=""
for p in "$HOME/.local/bin/piper" "/usr/bin/piper" "/usr/local/bin/piper"; do
    [ -x "$p" ] && PIPER_BIN="$p" && break
done

# Exit if no piper found
if [ -z "$PIPER_BIN" ]; then
    exit 0
fi

# Use LUNA voice (British English) - check possible locations
PIPER_MODEL=""
for path in \
    "$HOME/.local/share/apollo-os/voices/luna.onnx" \
    "$HOME/.local/share/apollo-os/piper-voices/luna.onnx" \
    "$HOME/.local/share/piper-voices/en_US-lessac-medium.onnx"; do
    [ -f "$path" ] && PIPER_MODEL="$path" && break
done

# Exit if no voice found
if [ -z "$PIPER_MODEL" ]; then
    exit 0
fi

# Ensure PipeWire can be reached
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"

# Check network connection
if nmcli -t -f STATE general 2>/dev/null | grep -q "connected"; then
    AI_STATUS="Connected to Apollo AI Nexus."
    NETWORK_STATUS="Network connected. System is online."
else
    AI_STATUS="Connected to Apollo AI Cortex."
    NETWORK_STATUS="No network connected."
fi

# Build message
MESSAGE="Apollo OS. Environment loaded. All systems operational. System is up to date and protected. Diagnostics nominal. ${AI_STATUS} ${NETWORK_STATUS}"

# Generate and play TTS
TMPFILE="/tmp/apollo-welcome-$$.wav"
echo "$MESSAGE" | "$PIPER_BIN" --model "$PIPER_MODEL" --length_scale 1.15 --output_file "$TMPFILE" 2>/dev/null

if [ -f "$TMPFILE" ]; then
    pw-play "$TMPFILE" 2>/dev/null || paplay "$TMPFILE" 2>/dev/null || aplay "$TMPFILE" 2>/dev/null
    rm -f "$TMPFILE"
fi
