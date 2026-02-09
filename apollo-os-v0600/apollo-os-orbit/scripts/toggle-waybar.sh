#!/bin/bash

#####################################################################
# Apollo OS - Waybar Toggle Script
# Copyright © 2025 by Manuel Kraibacher
#
# Description: Toggles Waybar visibility in Niri
# Keybinding: Super+J
#####################################################################

WAYBAR_CONFIG="$HOME/.config/waybar/config-niri"
WAYBAR_STYLE="$HOME/.config/waybar/style.css"

# Check if main Waybar is running (exclude dock instances)
if pgrep -f "waybar -c.*config-niri[^-]" > /dev/null 2>&1 || pgrep -f "waybar -c.*config-niri$" > /dev/null 2>&1; then
    # Kill only the main Waybar, not the dock
    pgrep -f "waybar -c.*config-niri[^-]" 2>/dev/null | xargs -r kill 2>/dev/null
    pgrep -f "waybar -c.*config-niri$" 2>/dev/null | xargs -r kill 2>/dev/null
    notify-send "Apollo OS" "Waybar: HIDDEN" -t 1500
else
    # Start with style
    waybar -c "$WAYBAR_CONFIG" -s "$WAYBAR_STYLE" &
    disown
    notify-send "Apollo OS" "Waybar: VISIBLE" -t 1500
fi
