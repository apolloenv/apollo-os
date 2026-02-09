#!/usr/bin/env bash

#####################################################################
# Apollo OS - Battery Monitor v0.6.0
# Copyright © 2025-2026 by Manuel Kraibacher
#
# Description: Monitors battery level and warns via TTS + notification
#              at 15% and 5%. Runs as background daemon.
#####################################################################

export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"

WARN_15=false
WARN_5=false
CHECK_INTERVAL=60

get_battery() {
    local bat_path
    for bat_path in /sys/class/power_supply/BAT*; do
        if [ -f "$bat_path/capacity" ]; then
            cat "$bat_path/capacity"
            return
        fi
    done
    echo ""
}

get_status() {
    local bat_path
    for bat_path in /sys/class/power_supply/BAT*; do
        if [ -f "$bat_path/status" ]; then
            cat "$bat_path/status"
            return
        fi
    done
    echo "Unknown"
}

warn_user() {
    local level="$1"
    local message="$2"
    local urgency="$3"

    notify-send -u "$urgency" "⚡ Battery Warning" "$message" 2>/dev/null

    if [ -x "$HOME/.local/bin/apollo-speak.sh" ]; then
        "$HOME/.local/bin/apollo-speak.sh" "$message" &
    fi
}

# Exit silently if no battery (desktop PC)
if [ -z "$(get_battery)" ]; then
    exit 0
fi

while true; do
    LEVEL=$(get_battery)
    STATUS=$(get_status)

    # Reset warnings when charging
    if [ "$STATUS" = "Charging" ] || [ "$STATUS" = "Full" ]; then
        WARN_15=false
        WARN_5=false
        sleep "$CHECK_INTERVAL"
        continue
    fi

    if [ -n "$LEVEL" ]; then
        if [ "$LEVEL" -le 5 ] && [ "$WARN_5" = false ]; then
            warn_user "$LEVEL" "Akku bei ${LEVEL}%! Sofort laden!" "critical"
            WARN_5=true
        elif [ "$LEVEL" -le 15 ] && [ "$WARN_15" = false ]; then
            warn_user "$LEVEL" "Akku bei ${LEVEL}%. Bitte laden." "normal"
            WARN_15=true
        fi
    fi

    sleep "$CHECK_INTERVAL"
done
