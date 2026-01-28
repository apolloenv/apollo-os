#!/bin/bash

#####################################################################
# Apollo OS - Waybar Toggle Script
# Copyright © 2025 by Manuel Kraibacher
#
# Description: Toggles Waybar visibility in Niri
# Keybinding: Super+J
#####################################################################

WAYBAR_CONFIG="$HOME/.config/waybar/config-niri"

# Check if Waybar is running
if pgrep -x "waybar" > /dev/null; then
    # Waybar is running, kill it
    pkill waybar
    notify-send "Apollo OS" "Waybar: HIDDEN" -t 1500
else
    # Waybar is not running, start it
    waybar -c "$WAYBAR_CONFIG" &
    disown
    notify-send "Apollo OS" "Waybar: VISIBLE" -t 1500
fi
