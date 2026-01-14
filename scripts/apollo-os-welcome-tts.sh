#!/bin/bash
#####################################################################
# Apollo OS - Welcome TTS
# Copyright © 2026 by Manuel Kraibacher
#
# Description: Text-to-speech welcome message at login
#####################################################################

sleep 5

PIPER_MODEL="$HOME/.local/share/piper-voices/en_US-lessac-medium.onnx"

if [[ -f "$HOME/.local/bin/piper" ]] && [[ -f "$PIPER_MODEL" ]]; then
    echo "System initialized. All services operational." | \
        "$HOME/.local/bin/piper" --model "$PIPER_MODEL" --output_file /tmp/welcome.wav 2>/dev/null
    
    if [[ -f /tmp/welcome.wav ]]; then
        paplay /tmp/welcome.wav 2>/dev/null || aplay /tmp/welcome.wav 2>/dev/null
        rm -f /tmp/welcome.wav
    fi
fi
