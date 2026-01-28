#!/bin/bash
#####################################################################
# Apollo OS TTS Notification System - Amala Voice
# Copyright 2025 by Manuel Kraibacher
#
# Uses edge-tts with Amala voice (German)
#####################################################################

# Ensure PipeWire/PulseAudio can be reached
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"

# Fixed voice: Amala (German)
VOICE_MODEL="de-DE-AmalaNeural"

# Find edge-tts
EDGE_TTS=""
for p in "$HOME/.local/bin/edge-tts" "/usr/local/bin/edge-tts" "/usr/bin/edge-tts"; do
    [ -x "$p" ] && EDGE_TTS="$p" && break
done

# TTS function - Amala only
speak() {
    local text="$1"
    local tmpfile="/tmp/apollo-tts-$$.mp3"
    
    if [ -z "$EDGE_TTS" ]; then
        return 1
    fi
    
    "$EDGE_TTS" -t "$text" -v "$VOICE_MODEL" --write-media "$tmpfile" 2>/dev/null
    
    if [ -f "$tmpfile" ]; then
        pw-play "$tmpfile" 2>/dev/null || paplay "$tmpfile" 2>/dev/null || mpg123 -q "$tmpfile" 2>/dev/null
        rm -f "$tmpfile"
    fi
}

# Event type from argument
EVENT="$1"

case "$EVENT" in
    # Network events
    wifi-connected)
        speak "Netzwerk verbunden."
        ;;
    wifi-disconnected)
        speak "Netzwerk getrennt."
        ;;
    vpn-connected)
        speak "VPN aktiv."
        ;;
    vpn-disconnected)
        speak "VPN deaktiviert."
        ;;
    
    # Power events
    power-connected)
        speak "Stromversorgung aktiv."
        ;;
    power-disconnected)
        speak "Batteriemodus aktiv."
        ;;
    battery-low)
        speak "Warnung. Akku kritisch."
        ;;
    battery-full)
        speak "Akku vollständig geladen."
        ;;
    
    # Performance modes
    power-saver)
        speak "Energiesparmodus aktiv."
        ;;
    balanced)
        speak "Balancemodus aktiv."
        ;;
    performance)
        speak "Leistungsmodus aktiv."
        ;;
    
    # Bluetooth
    bluetooth-connected)
        speak "Bluetooth verbunden."
        ;;
    bluetooth-disconnected)
        speak "Bluetooth getrennt."
        ;;
    
    # USB/Storage
    usb-connected)
        speak "Gerät erkannt."
        ;;
    usb-removed)
        speak "Gerät entfernt."
        ;;
    
    # System events
    screenshot)
        speak "Screenshot gespeichert."
        ;;
    shutdown)
        speak "System wird heruntergefahren."
        ;;
    reboot)
        speak "Neustart wird eingeleitet."
        ;;
    lock)
        speak "System gesperrt."
        ;;
    unlock)
        speak "System entsperrt."
        ;;
    
    # Sleep/Suspend events
    sleep)
        speak "Ruhemodus aktiv."
        ;;
    wake)
        speak "System reaktiviert."
        ;;
    
    # Audio
    muted)
        speak "Stumm."
        ;;
    unmuted)
        speak "Audio aktiv."
        ;;
    
    # Visual modes
    visual-*)
        speak "Interface geladen."
        ;;
    
    *)
        # Unknown event - speak as-is if not empty
        [ -n "$EVENT" ] && speak "$EVENT"
        ;;
esac
