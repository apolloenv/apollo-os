#!/bin/bash

#####################################################################
# Apollo OS - System Event Monitor
# Copyright © 2025 by Manuel Kraibacher
#
# Description: Monitors system events and sends TTS notifications
#              - Battery warnings
#              - Network changes
#              - System power events
#####################################################################

# Ensure environment
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
export WAYLAND_DISPLAY="${WAYLAND_DISPLAY:-wayland-1}"

# Logging
LOG_FILE="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/apollo-event-monitor.log"
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

# State tracking
BATTERY_WARNED_LOW=false
BATTERY_WARNED_CRITICAL=false
LAST_NETWORK_STATE=""
LAST_AC_STATE=""

#####################################################################
# Notification Functions
#####################################################################

notify_and_speak() {
    local title="$1"
    local message="$2"
    local urgency="${3:-normal}"
    local tts_message="$4"
    
    # Visual notification
    if command -v notify-send &>/dev/null; then
        notify-send \
            --app-name="Apollo OS" \
            --icon="dialog-warning" \
            --urgency="$urgency" \
            "$title" \
            "$message"
    fi
    
    # TTS announcement (English only)
    if command -v apollo-speak &>/dev/null && [[ -n "$tts_message" ]]; then
        apollo-speak "$tts_message" &
    fi
}

#####################################################################
# Battery Monitor
#####################################################################

check_battery() {
    # Check if battery exists
    if [[ ! -d /sys/class/power_supply/BAT0 ]] && [[ ! -d /sys/class/power_supply/BAT1 ]]; then
        return
    fi
    
    # Find battery
    local battery=""
    for bat in /sys/class/power_supply/BAT*; do
        if [[ -d "$bat" ]]; then
            battery="$bat"
            break
        fi
    done
    
    [[ -z "$battery" ]] && return
    
    # Read battery status
    local capacity=$(cat "$battery/capacity" 2>/dev/null || echo "100")
    local status=$(cat "$battery/status" 2>/dev/null || echo "Unknown")
    
    # Check AC power state
    local ac_online="0"
    if [[ -f /sys/class/power_supply/AC/online ]]; then
        ac_online=$(cat /sys/class/power_supply/AC/online 2>/dev/null || echo "0")
    elif [[ -f /sys/class/power_supply/ADP1/online ]]; then
        ac_online=$(cat /sys/class/power_supply/ADP1/online 2>/dev/null || echo "0")
    fi
    
    # AC power connected/disconnected
    if [[ "$LAST_AC_STATE" != "$ac_online" ]]; then
        if [[ "$ac_online" == "1" ]]; then
            log "AC power connected"
            notify_and_speak \
                "Power Connected" \
                "AC power supply connected" \
                "low" \
                "Power connected"
        else
            log "AC power disconnected"
            notify_and_speak \
                "On Battery Power" \
                "Running on battery at ${capacity}%" \
                "normal" \
                "On battery power. ${capacity} percent remaining"
        fi
        LAST_AC_STATE="$ac_online"
    fi
    
    # Only warn when on battery
    if [[ "$status" == "Discharging" ]]; then
        # Critical warning (10%)
        if [[ $capacity -le 10 ]] && [[ "$BATTERY_WARNED_CRITICAL" == "false" ]]; then
            log "Battery critical: ${capacity}%"
            notify_and_speak \
                "Battery Critical" \
                "Battery at ${capacity}%. Connect power immediately!" \
                "critical" \
                "battery_critical"
            BATTERY_WARNED_CRITICAL=true
            BATTERY_WARNED_LOW=true
        # Low warning (20%)
        elif [[ $capacity -le 20 ]] && [[ "$BATTERY_WARNED_LOW" == "false" ]]; then
            log "Battery low: ${capacity}%"
            notify_and_speak \
                "Battery Low" \
                "Battery at ${capacity}%. Please connect power soon." \
                "normal" \
                "battery_low"
            BATTERY_WARNED_LOW=true
        fi
    else
        # Reset warnings when charging
        if [[ "$status" == "Charging" ]] && [[ $capacity -gt 30 ]]; then
            BATTERY_WARNED_LOW=false
            BATTERY_WARNED_CRITICAL=false
        fi
    fi
}

#####################################################################
# Network Monitor
#####################################################################

check_network() {
    # Check network connectivity
    local is_connected="false"
    
    # Check for active network interface
    for iface in /sys/class/net/*; do
        local ifname=$(basename "$iface")
        [[ "$ifname" == "lo" ]] && continue
        
        if [[ -f "$iface/operstate" ]]; then
            local state=$(cat "$iface/operstate" 2>/dev/null)
            if [[ "$state" == "up" ]]; then
                is_connected="true"
                break
            fi
        fi
    done
    
    # Network state changed
    if [[ "$LAST_NETWORK_STATE" != "$is_connected" ]]; then
        if [[ "$is_connected" == "true" ]]; then
            log "Network connected"
            notify_and_speak \
                "Network Connected" \
                "Internet connection established" \
                "low" \
                "Network connected"
        else
            log "Network disconnected"
            notify_and_speak \
                "Network Disconnected" \
                "Internet connection lost" \
                "normal" \
                "Network disconnected"
        fi
        LAST_NETWORK_STATE="$is_connected"
    fi
}

#####################################################################
# Main Monitor Loop
#####################################################################

log "Apollo OS System Event Monitor started"

# Initial state
LAST_AC_STATE=$(cat /sys/class/power_supply/AC/online 2>/dev/null || echo "0")
LAST_NETWORK_STATE="unknown"

# Monitor loop
while true; do
    check_battery
    check_network
    
    # Check every 30 seconds
    sleep 30
done
