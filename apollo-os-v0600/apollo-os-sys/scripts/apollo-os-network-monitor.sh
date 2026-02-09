#!/bin/bash
set -euo pipefail
# Apollo OS Network Event Monitor
# Copyright 2025 by Manuel Kraibacher
#
# Monitors network events (WiFi connect/disconnect) and triggers TTS notifications
# Should be started at login via spawn-at-startup in niri config

# Prevent multiple instances (secure lockfile)
RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
LOCKFILE="$RUNTIME_DIR/apollo-network-monitor.lock"
if [ -f "$LOCKFILE" ]; then
    PID=$(cat "$LOCKFILE")
    if kill -0 "$PID" 2>/dev/null; then
        exit 0  # Already running
    fi
fi
echo $$ > "$LOCKFILE"
chmod 600 "$LOCKFILE"  # Sichere Permissions
trap "rm -f $LOCKFILE" EXIT

TTS_SCRIPT="$HOME/.local/bin/apollo-os-tts-notify.sh"
LAST_STATE_FILE="$RUNTIME_DIR/apollo-network-state"

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

# Wait for system to stabilize after login (optimized from 10s)
sleep 3

SLEEP_MARKER="$RUNTIME_DIR/apollo-os-sleeping"

while true; do
    sleep 10

    # Skip network notifications if system is going to sleep or waking
    if [ -f "$SLEEP_MARKER" ]; then
        LAST_STATE=$(get_network_state)
        continue
    fi
    
    CURRENT_STATE=$(get_network_state)
    
    # Check for state change
    if [ "$CURRENT_STATE" != "$LAST_STATE" ]; then
        if [ "$CURRENT_STATE" = "1" ]; then
            # Network connected
            [ -x "$TTS_SCRIPT" ] && "$TTS_SCRIPT" wifi-connected || true
            notify-send "Apollo OS" "Network connected"
        else
            # Network disconnected
            [ -x "$TTS_SCRIPT" ] && "$TTS_SCRIPT" wifi-disconnected || true
            notify-send "Apollo OS" "Network disconnected"
        fi
        LAST_STATE="$CURRENT_STATE"
        echo "$LAST_STATE" > "$LAST_STATE_FILE"
    fi
done
