#!/usr/bin/env bash

#####################################################################
# Apollo OS - Toggle Floating with Auto-Size
# Copyright © 2025 by Manuel Kraibacher
#
# Description: Schaltet Fenster auf Floating und setzt Größe auf 60%
#####################################################################

# Get window state before toggle
window_info=$(niri msg -j focused-window 2>/dev/null)
was_floating=$(echo "$window_info" | jq -r '.is_floating // false')

# Toggle floating
niri msg action toggle-window-floating

# If window is now floating (was tiled before), resize it
if [ "$was_floating" = "false" ]; then
    sleep 0.15
    
    # Get screen width from logical dimensions
    screen_width=$(niri msg -j outputs | jq -r '.[] | .logical.width' | head -1)
    
    # Fallback to 1920 if no output found
    if [ -z "$screen_width" ] || [ "$screen_width" = "null" ]; then
        screen_width=1920
    fi
    
    # Calculate target width (60% of screen)
    target_width=$(awk "BEGIN {printf \"%.0f\", $screen_width * 0.6}")
    
    # Get current window size
    window_info=$(niri msg -j focused-window 2>/dev/null)
    current_width=$(echo "$window_info" | jq -r '.size.w // 0')
    
    # Calculate difference
    diff=$((target_width - current_width))
    
    # Set width to 60% of screen if there's a difference
    if [ $diff -ne 0 ] && [ $current_width -gt 0 ]; then
        niri msg action set-window-width "$diff"
    fi
fi





