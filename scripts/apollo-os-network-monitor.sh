#!/bin/bash
# Apollo OS Network Event Monitor
# Copyright 2025 by Manuel Kraibacher
#
# Monitors network events (WiFi connect/disconnect) and triggers TTS notifications
# Should be started at login via spawn-at-startup in niri config

TTS_SCRIPT="$HOME/.local/bin/apollo-os-tts-notify.sh"
LAST_STATE_FILE="/tmp/apollo-network-state"

# Get current network state (1=connected, 0=disconnected)
get_network_state() {
    if nmcli -t -f STATE general 2>/dev/null | grep -q "connected"; then
        echo "1"
    else
        echo "0"
    fi
}

# Initialize - don't announce initial state
LAST_STATE=$(get_network_state)
echo "$LAST_STATE" > "$LAST_STATE_FILE"

# Wait for system to stabilize after login
sleep 10

while true; do
    sleep 5
    
    CURRENT_STATE=$(get_network_state)
    
    # Check for state change
    if [ "$CURRENT_STATE" != "$LAST_STATE" ]; then
        if [ "$CURRENT_STATE" = "1" ]; then
            # Network connected
            "$TTS_SCRIPT" wifi-connected &
            notify-send "Apollo OS" "Network connected"
        else
            # Network disconnected
            "$TTS_SCRIPT" wifi-disconnected &
            notify-send "Apollo OS" "Network disconnected"
        fi
        LAST_STATE="$CURRENT_STATE"
        echo "$LAST_STATE" > "$LAST_STATE_FILE"
    fi
done
