#!/bin/bash
#####################################################################
# Apollo OS - Lock/Unlock TTS
# Copyright © 2026 by Manuel Kraibacher
#####################################################################

ACTION=$1

# Use LUNA voice
PIPER_MODEL="$HOME/.local/share/apollo-os/voices/luna.onnx"
if [[ ! -f "$PIPER_MODEL" ]]; then
    PIPER_MODEL="$HOME/.local/share/apollo-os/piper-voices/luna.onnx"
fi
if [[ ! -f "$PIPER_MODEL" ]]; then
    exit 0
fi

case "$ACTION" in
    lock)
        MESSAGE="Apollo OS secured."
        ;;
    unlock)
        MESSAGE="Apollo OS login successful."
        ;;
    *)
        exit 0
        ;;
esac

if [[ -f "$HOME/.local/bin/piper" ]] && [[ -f "$PIPER_MODEL" ]]; then
    echo "$MESSAGE" | \
        "$HOME/.local/bin/piper" --model "$PIPER_MODEL" --length_scale 1.15 --output_file /tmp/lock-tts.wav 2>/dev/null
    
    if [[ -f /tmp/lock-tts.wav ]]; then
        paplay /tmp/lock-tts.wav 2>/dev/null || aplay /tmp/lock-tts.wav 2>/dev/null
        rm -f /tmp/lock-tts.wav
    fi
fi
