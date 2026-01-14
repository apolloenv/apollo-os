#!/bin/bash
# Apollo OS TTS Notification System
# Copyright 2025 by Manuel Kraibacher

# Find LUNA voice
VOICE_FILE=$(find "$HOME/.local/share" -name 'luna.onnx' 2>/dev/null | head -1)

# Fallback voice paths
if [ -z "$VOICE_FILE" ]; then
    for path in \
        "$HOME/.local/share/apollo-os/voices/luna.onnx" \
        "$HOME/.local/share/apollo-os/piper-voices/luna.onnx" \
        "/usr/share/piper-voices/luna.onnx"; do
        [ -f "$path" ] && VOICE_FILE="$path" && break
    done
fi

# Exit if no voice found
if [ -z "$VOICE_FILE" ] || [ ! -f "$VOICE_FILE" ]; then
    exit 1
fi

# Speed setting (higher = slower)
SPEED=1.15

# TTS function
speak() {
    local text="$1"
    local tmpfile="/tmp/apollo-tts-$$.wav"
    echo "$text" | piper --model "$VOICE_FILE" --length_scale "$SPEED" --output_file "$tmpfile" 2>/dev/null
    pw-play "$tmpfile" 2>/dev/null || paplay "$tmpfile" 2>/dev/null || aplay "$tmpfile" 2>/dev/null
    rm -f "$tmpfile"
}

# Event type from argument
EVENT="$1"

case "$EVENT" in
    # Network events
    wifi-connected)
        speak "Network connection established. Apollo AI Nexus online."
        ;;
    wifi-disconnected)
        speak "Network connection lost. Switching to offline mode."
        ;;
    vpn-connected)
        speak "Secure tunnel established. VPN connection active."
        ;;
    vpn-disconnected)
        speak "VPN connection terminated. Standard network active."
        ;;
    
    # Power events
    power-connected)
        speak "Power supply connected. Charging initiated."
        ;;
    power-disconnected)
        speak "Power supply disconnected. Running on battery."
        ;;
    battery-low)
        speak "Warning. Battery level critical. Connect power supply immediately."
        ;;
    battery-full)
        speak "Battery fully charged. Power efficiency optimized."
        ;;
    
    # Performance modes
    power-saver)
        speak "Power saver mode activated. Optimizing for battery life."
        ;;
    balanced)
        speak "Balanced mode activated. Performance and efficiency optimized."
        ;;
    performance)
        speak "Performance mode activated. Maximum power unleashed."
        ;;
    
    # Bluetooth
    bluetooth-connected)
        speak "Bluetooth device paired and connected."
        ;;
    bluetooth-disconnected)
        speak "Bluetooth device disconnected."
        ;;
    
    # USB/Storage
    usb-connected)
        speak "External device detected and mounted."
        ;;
    usb-removed)
        speak "External device safely removed."
        ;;
    
    # System events
    screenshot)
        speak "Screenshot captured and saved."
        ;;
    shutdown)
        speak "Apollo OS shutting down. Goodbye."
        ;;
    reboot)
        speak "Apollo OS restarting. System will be back online shortly."
        ;;
    lock)
        speak "Apollo OS secured."
        ;;
    unlock)
        speak "Apollo OS login successful."
        ;;
    
    # Audio
    muted)
        speak "Audio muted."
        ;;
    unmuted)
        speak "Audio restored."
        ;;
    
    # Updates
    update-start)
        speak "Apollo OS update initiated. Please stand by."
        ;;
    update-complete)
        speak "Apollo OS update complete. All systems upgraded successfully."
        ;;
    update-failed)
        speak "Apollo OS update failed. Please check the logs."
        ;;
    
    # Display
    night-mode)
        speak "Night mode activated. Display optimized for low light."
        ;;
    day-mode)
        speak "Standard display mode restored."
        ;;
    
    # Wallpaper
    wallpaper-changed)
        speak "Wallpaper updated."
        ;;
    
    # Visual Mode
    visual-classic)
        speak "Classic visual mode activated."
        ;;
    visual-modern)
        speak "Modern visual mode activated."
        ;;
    
    # Custom message
    custom)
        shift
        speak "$*"
        ;;
    
    *)
        echo "Usage: $0 <event>"
        echo ""
        echo "Events:"
        echo "  Network:     wifi-connected, wifi-disconnected, vpn-connected, vpn-disconnected"
        echo "  Power:       power-connected, power-disconnected, battery-low, battery-full"
        echo "  Performance: power-saver, balanced, performance"
        echo "  Bluetooth:   bluetooth-connected, bluetooth-disconnected"
        echo "  USB:         usb-connected, usb-removed"
        echo "  System:      screenshot, shutdown, reboot, lock, unlock"
        echo "  Audio:       muted, unmuted"
        echo "  Updates:     update-start, update-complete, update-failed"
        echo "  Display:     night-mode, day-mode, wallpaper-changed"
        echo "  Visual:      visual-classic, visual-modern"
        echo "  Custom:      custom \"Your message here\""
        exit 1
        ;;
esac
