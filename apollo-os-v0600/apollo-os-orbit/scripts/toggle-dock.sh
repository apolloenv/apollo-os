#!/bin/bash

#####################################################################
# Apollo OS - macOS Dock Toggle Script
# Copyright © 2025 by Manuel Kraibacher
#
# Description: Toggles macOS-style Dock visibility in Niri
# Keybinding: Super+J (only in macOS mode)
#####################################################################

DOCK_CONFIG="$HOME/.config/waybar/config-niri-macos-dock"
DOCK_STYLE="$HOME/.config/waybar/style-macos-dock.css"
DOCK_PIDFILE="/tmp/apollo-os-dock.pid"

# Check if dock is running
is_dock_running() {
    if [ -f "$DOCK_PIDFILE" ]; then
        local pid=$(cat "$DOCK_PIDFILE")
        if kill -0 "$pid" 2>/dev/null; then
            return 0
        fi
    fi
    return 1
}

# Start dock
start_dock() {
    waybar -c "$DOCK_CONFIG" -s "$DOCK_STYLE" &
    echo $! > "$DOCK_PIDFILE"
    disown
    notify-send "Apollo OS" "Dock: VISIBLE" -t 1500
}

# Stop dock
stop_dock() {
    if [ -f "$DOCK_PIDFILE" ]; then
        local pid=$(cat "$DOCK_PIDFILE")
        kill "$pid" 2>/dev/null
        rm -f "$DOCK_PIDFILE"
    fi
    notify-send "Apollo OS" "Dock: HIDDEN" -t 1500
}

# Toggle dock
if is_dock_running; then
    stop_dock
else
    start_dock
fi
