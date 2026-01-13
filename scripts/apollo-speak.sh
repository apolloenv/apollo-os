#!/bin/bash

#####################################################################
# Apollo OS - Voice System (TTS Helper)
# Copyright © 2026 by Manuel Kraibacher
#
# Description: Text-to-Speech helper using Piper TTS
# Voice: LUNA (en_GB-jenny_dioco-medium)
#####################################################################

# Ensure environment is set for Wayland/PulseAudio
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"

# Paths
PIPER_DIR="$HOME/.local/share/apollo-os/piper/piper"
VOICE_DIR="$HOME/.local/share/apollo-os/voices"
SOUNDS_DIR="$HOME/.local/share/apollo-os/sounds"
CACHE_DIR="/tmp/apollo-tts-cache"
VOICE_MODEL="$VOICE_DIR/luna.onnx"
CHIME_SOUND="$SOUNDS_DIR/chime.wav"

# Config
LENGTH_SCALE="1.1"  # Slightly slower for natural speech

# Set library path for Piper
export LD_LIBRARY_PATH="$PIPER_DIR:$LD_LIBRARY_PATH"

#####################################################################
# Predefined Messages
#####################################################################

declare -A MESSAGES=(
    ["boot"]="Apollo Core initialized. All systems operational."
    ["welcome"]="Identity confirmed. Welcome back."
    ["lock"]="System secured. Standing by."
    ["unlock"]="Access granted. Resuming session."
    ["shutdown"]="Shutting down services. Until next time."
    ["battery_low"]="Warning. Energy levels at 20 percent."
    ["battery_critical"]="Critical alert. Energy reserves critical. Connect power immediately."
    ["uplink_ready"]="Nexus uplink established."
    ["uplink_lost"]="Connection lost. Local processing only."
    ["error"]="An error occurred"
    ["success"]="Operation completed successfully"
)

#####################################################################
# Functions
#####################################################################

speak() {
    local text="$1"
    
    # Check if Piper is available
    if [[ ! -x "$PIPER_DIR/piper" ]]; then
        # Fallback to espeak-ng
        if command -v espeak-ng &>/dev/null; then
            espeak-ng -v en-gb -s 140 "$text" 2>/dev/null &
        fi
        return
    fi
    
    # Check if voice model exists
    if [[ ! -f "$VOICE_MODEL" ]]; then
        # Fallback to espeak-ng
        if command -v espeak-ng &>/dev/null; then
            espeak-ng -v en-gb -s 140 "$text" 2>/dev/null &
        fi
        return
    fi
    
    # Create cache directory
    mkdir -p "$CACHE_DIR"
    
    # Generate cache filename (MD5 hash of text)
    local hash=$(echo -n "$text" | md5sum | cut -d' ' -f1)
    local cache_file="$CACHE_DIR/$hash.wav"
    
    # Generate TTS if not in cache
    if [[ ! -f "$cache_file" ]]; then
        echo "$text" | "$PIPER_DIR/piper" \
            --model "$VOICE_MODEL" \
            --length_scale "$LENGTH_SCALE" \
            --output_file "$cache_file" 2>/dev/null
    fi
    
    # Play audio
    if [[ -f "$cache_file" ]]; then
        # Play chime first if available
        if [[ -f "$CHIME_SOUND" ]] && command -v paplay &>/dev/null; then
            paplay "$CHIME_SOUND" 2>/dev/null
            sleep 0.3
        fi
        
        # Play the speech (synchronous, no & to ensure completion)
        if command -v paplay &>/dev/null; then
            paplay "$cache_file" 2>/dev/null
        elif command -v aplay &>/dev/null; then
            aplay -q "$cache_file" 2>/dev/null
        fi
    fi
}

#####################################################################
# Main
#####################################################################

if [[ $# -eq 0 ]]; then
    echo "Usage: apollo-speak <message|text>"
    echo "Predefined: boot, welcome, lock, unlock, shutdown, battery_low, battery_critical, uplink_ready, uplink_lost, error, success"
    echo ""
    echo "Voice: LUNA (British English)"
    echo "TTS Engine: Piper"
    exit 0
fi

MSG="$1"
if [[ -n "${MESSAGES[$MSG]}" ]]; then
    speak "${MESSAGES[$MSG]}"
else
    speak "$MSG"
fi
