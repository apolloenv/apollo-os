#!/bin/bash
# Apollo OS Power Event Monitor
# Copyright 2025 by Manuel Kraibacher
#
# Monitors power events (AC/Battery) and triggers TTS notifications
# Should be started at login via spawn-at-startup in niri config

TTS_SCRIPT="$HOME/.local/bin/apollo-os-tts-notify.sh"
LAST_STATE_FILE="/tmp/apollo-power-state"

# Get current power state
get_power_state() {
    if [ -f /sys/class/power_supply/AC*/online ]; then
        cat /sys/class/power_supply/AC*/online 2>/dev/null
    elif [ -f /sys/class/power_supply/ACAD/online ]; then
        cat /sys/class/power_supply/ACAD/online
    else
        echo "1"  # Assume plugged in if no battery
    fi
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

while true; do
    sleep 5
    
    CURRENT_STATE=$(get_power_state)
    BATTERY_LEVEL=$(get_battery_level)
    
    # Check for power state change
    if [ "$CURRENT_STATE" != "$LAST_STATE" ]; then
        if [ "$CURRENT_STATE" = "1" ]; then
            # Power connected
            "$TTS_SCRIPT" power-connected &
            notify-send "Apollo OS" "Power supply connected"
        else
            # Power disconnected
            "$TTS_SCRIPT" power-disconnected &
            notify-send "Apollo OS" "Running on battery"
        fi
        LAST_STATE="$CURRENT_STATE"
        echo "$LAST_STATE" > "$LAST_STATE_FILE"
    fi
    
    # Check for low battery (only on battery power)
    if [ "$CURRENT_STATE" = "0" ] && [ "$BATTERY_LEVEL" -le 15 ]; then
        CURRENT_TIME=$(date +%s)
        # Only warn every 5 minutes
        if [ $((CURRENT_TIME - LAST_LOW_WARNING)) -gt 300 ]; then
            "$TTS_SCRIPT" battery-low &
            notify-send -u critical "Apollo OS" "Battery critical: ${BATTERY_LEVEL}%"
            LAST_LOW_WARNING=$CURRENT_TIME
        fi
    fi
    
    # Check for fully charged
    if [ "$CURRENT_STATE" = "1" ] && [ "$BATTERY_LEVEL" -ge 100 ]; then
        # Check if we haven't notified about full battery yet
        if [ ! -f "/tmp/apollo-battery-full-notified" ]; then
            "$TTS_SCRIPT" battery-full &
            notify-send "Apollo OS" "Battery fully charged"
            touch "/tmp/apollo-battery-full-notified"
        fi
    else
        rm -f "/tmp/apollo-battery-full-notified"
    fi
done
