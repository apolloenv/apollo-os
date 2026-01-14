#!/bin/bash
#####################################################################
# Apollo OS - Welcome TTS
# Copyright © 2026 by Manuel Kraibacher
#####################################################################

sleep 5

# Use LUNA voice (British English) - check both possible locations
PIPER_MODEL="$HOME/.local/share/apollo-os/voices/luna.onnx"

# Fallback locations
if [[ ! -f "$PIPER_MODEL" ]]; then
    PIPER_MODEL="$HOME/.local/share/apollo-os/piper-voices/luna.onnx"
fi
if [[ ! -f "$PIPER_MODEL" ]]; then
    PIPER_MODEL="$HOME/.local/share/piper-voices/en_US-lessac-medium.onnx"
fi

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

if [[ -f "$HOME/.local/bin/piper" ]] && [[ -f "$PIPER_MODEL" ]]; then
    echo "$MESSAGE" | \
        "$HOME/.local/bin/piper" --model "$PIPER_MODEL" --length_scale 1.15 --output_file /tmp/welcome.wav 2>/dev/null
    
    if [[ -f /tmp/welcome.wav ]]; then
        paplay /tmp/welcome.wav 2>/dev/null || aplay /tmp/welcome.wav 2>/dev/null
        rm -f /tmp/welcome.wav
    fi
fi
