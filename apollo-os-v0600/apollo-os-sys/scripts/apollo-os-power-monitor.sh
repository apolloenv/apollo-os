#!/bin/bash
# Apollo OS Power Event Monitor
# Copyright 2025 by Manuel Kraibacher
#
# Monitors power events (AC/Battery) and triggers TTS notifications
# Should be started at login via spawn-at-startup in niri config

# Prevent multiple instances (secure lockfile)
RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
LOCKFILE="$RUNTIME_DIR/apollo-power-monitor.lock"
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
LAST_STATE_FILE="$RUNTIME_DIR/apollo-power-state"

# Notification wrapper functions
notify() {
    # Desktop notification
    notify-send "Apollo OS" "$1" ${2:+-u "$2"}
}

tts_notify() {
    # TTS + Desktop notification
    if [ -x "$TTS_SCRIPT" ]; then
        "$TTS_SCRIPT" "$1"
    fi
    notify "$2" "${3:-normal}"
}

# Get current power state (1=AC connected, 0=battery)
get_power_state() {
    # Check various AC adapter names
    for ac in /sys/class/power_supply/AC* /sys/class/power_supply/ACAD /sys/class/power_supply/ADP*; do
        if [ -f "$ac/online" ]; then
            cat "$ac/online" 2>/dev/null
            return
        fi
    done
    # No AC adapter found - check if any battery exists
    for bat in /sys/class/power_supply/BAT*; do
        if [ -d "$bat" ]; then
            # Has battery but no AC info - check status
            local status=$(cat "$bat/status" 2>/dev/null)
            if [ "$status" = "Charging" ] || [ "$status" = "Full" ]; then
                echo "1"
            else
                echo "0"
            fi
            return
        fi
    done
    # No battery, assume desktop/plugged in
    echo "1"
}

# Get battery level
get_battery_level() {
    for bat in /sys/class/power_supply/BAT*; do
        if [ -f "$bat/capacity" ]; then
            cat "$bat/capacity"
            return
        fi
    done
    echo "100"
}

# Initialize
LAST_STATE=$(get_power_state)
echo "$LAST_STATE" > "$LAST_STATE_FILE"
LAST_LOW_WARNING=0

# Wait for system to stabilize (optimized from 10s)
sleep 3

while true; do
    sleep 15
    
    CURRENT_STATE=$(get_power_state)
    BATTERY_LEVEL=$(get_battery_level)
    
    # Check for power state change
    if [ "$CURRENT_STATE" != "$LAST_STATE" ]; then
        if [ "$CURRENT_STATE" = "1" ]; then
            # Power connected
            tts_notify "power-connected" "Power supply connected"
        else
            # Power disconnected
            tts_notify "power-disconnected" "Running on battery"
        fi
        LAST_STATE="$CURRENT_STATE"
        echo "$LAST_STATE" > "$LAST_STATE_FILE"
    fi
    
    # Check for low battery (only on battery power)
    if [ "$CURRENT_STATE" = "0" ] && [ "$BATTERY_LEVEL" -le 15 ]; then
        CURRENT_TIME=$(date +%s)
        # Only warn every 5 minutes
        if [ $((CURRENT_TIME - LAST_LOW_WARNING)) -gt 300 ]; then
            tts_notify "battery-low" "Battery critical: ${BATTERY_LEVEL}%" "critical"
            LAST_LOW_WARNING=$CURRENT_TIME
        fi
    fi
    
    # Check for fully charged
    if [ "$CURRENT_STATE" = "1" ] && [ "$BATTERY_LEVEL" -ge 100 ]; then
        # Check if we haven't notified about full battery yet
        FULL_NOTIFIED="$RUNTIME_DIR/apollo-battery-full-notified"
        if [ ! -f "$FULL_NOTIFIED" ]; then
            tts_notify "battery-full" "Battery fully charged"
            touch "$FULL_NOTIFIED"
            chmod 600 "$FULL_NOTIFIED"
        fi
    else
        rm -f "$RUNTIME_DIR/apollo-battery-full-notified"
    fi
done
