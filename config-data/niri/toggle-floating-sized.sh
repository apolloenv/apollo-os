#!/usr/bin/env bash

#####################################################################
# Apollo OS - Toggle Floating with Auto-Size
# Copyright © 2025 by Manuel Kraibacher
#
# Description: Schaltet Fenster auf Floating und setzt Größe auf
#              60% Breite x 80% Höhe, zentriert
#####################################################################

# Get window state before toggle
window_info=$(niri msg -j focused-window 2>/dev/null)
was_floating=$(echo "$window_info" | jq -r '.is_floating // false')

# Toggle floating
niri msg action toggle-window-floating

# If window was tiled (now floating), resize and center it
if [ "$was_floating" = "false" ]; then
    # Wait for window to become floating
    sleep 0.3
    
    # Get screen dimensions
    output_info=$(niri msg -j outputs | jq -r 'to_entries | .[0].value.logical')
    screen_width=$(echo "$output_info" | jq -r '.width')
    screen_height=$(echo "$output_info" | jq -r '.height')
    
    # Calculate target dimensions (60% width, 80% height)
    target_width=$(awk "BEGIN {printf \"%.0f\", $screen_width * 0.6}")
    target_height=$(awk "BEGIN {printf \"%.0f\", $screen_height * 0.8}")
    
    # Get current window info after toggle
    window_info=$(niri msg -j focused-window 2>/dev/null)
    current_width=$(echo "$window_info" | jq -r '.size.w')
    current_height=$(echo "$window_info" | jq -r '.size.h')
    current_x=$(echo "$window_info" | jq -r '.logical_position.x')
    current_y=$(echo "$window_info" | jq -r '.logical_position.y')
    
    # Only proceed if we have valid dimensions
    if [ "$current_width" != "null" ] && [ "$current_height" != "null" ]; then
        # Calculate width difference
        width_diff=$((target_width - current_width))
        if [ $width_diff -ne 0 ]; then
            niri msg action set-window-width "$width_diff"
        fi
        
        # Calculate height difference
        height_diff=$((target_height - current_height))
        if [ $height_diff -ne 0 ]; then
            niri msg action set-window-height "$height_diff"
        fi
        
        # Wait for resize
        sleep 0.2
        
        # Calculate center position
        center_x=$(awk "BEGIN {printf \"%.0f\", ($screen_width - $target_width) / 2}")
        center_y=$(awk "BEGIN {printf \"%.0f\", ($screen_height - $target_height) / 2}")
        
        # Get updated position after resize
        window_info=$(niri msg -j focused-window 2>/dev/null)
        current_x=$(echo "$window_info" | jq -r '.logical_position.x')
        current_y=$(echo "$window_info" | jq -r '.logical_position.y')
        
        # Calculate movement needed
        if [ "$current_x" != "null" ] && [ "$current_y" != "null" ]; then
            move_x=$((center_x - current_x))
            move_y=$((center_y - current_y))
            
            # Move to center
            if [ $move_x -ne 0 ] || [ $move_y -ne 0 ]; then
                niri msg action move-floating-window -x "$move_x" -y "$move_y"
            fi
        fi
    fi
fi







