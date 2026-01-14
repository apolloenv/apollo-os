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
    # Small delay for toggle animation
    sleep 0.2
    
    # Get screen dimensions
    output_info=$(niri msg -j outputs | jq -r 'to_entries | .[0].value.logical')
    screen_width=$(echo "$output_info" | jq -r '.width')
    screen_height=$(echo "$output_info" | jq -r '.height')
    
    # Calculate target dimensions (60% width, 80% height)
    target_width=$(awk "BEGIN {printf \"%.0f\", $screen_width * 0.6}")
    target_height=$(awk "BEGIN {printf \"%.0f\", $screen_height * 0.8}")
    
    # Get current window tile size (includes borders)
    window_info=$(niri msg -j focused-window 2>/dev/null)
    current_width=$(echo "$window_info" | jq -r '.layout.tile_size[0]' | awk '{printf "%.0f", $1}')
    current_height=$(echo "$window_info" | jq -r '.layout.tile_size[1]' | awk '{printf "%.0f", $1}')
    
    # Calculate differences
    width_diff=$((target_width - current_width))
    height_diff=$((target_height - current_height))
    
    # Batch resize commands to minimize flicker
    {
        niri msg action set-window-width "$width_diff"
        niri msg action set-window-height "$height_diff"
    } &>/dev/null
    
    # Wait for resize
    sleep 0.3
    
    # Now center the window
    center_x=$(awk "BEGIN {printf \"%.0f\", ($screen_width - $target_width) / 2}")
    center_y=$(awk "BEGIN {printf \"%.0f\", ($screen_height - $target_height) / 2}")
    
    # Get current position
    window_info=$(niri msg -j focused-window 2>/dev/null)
    current_x=$(echo "$window_info" | jq -r '.layout.tile_pos_in_workspace_view[0]' | awk '{printf "%.0f", $1}')
    current_y=$(echo "$window_info" | jq -r '.layout.tile_pos_in_workspace_view[1]' | awk '{printf "%.0f", $1}')
    
    # Move to center
    move_x=$((center_x - current_x))
    move_y=$((center_y - current_y))
    
    niri msg action move-floating-window -x "$move_x" -y "$move_y"
fi










