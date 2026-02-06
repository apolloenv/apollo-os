#!/usr/bin/env bash

# Smart focus: Move focus within workspace, or switch workspace if no window in direction
DIRECTION="$1"

# Get current workspace and window info
CURRENT_WS=$(hyprctl activeworkspace -j | jq -r '.id')
CURRENT_ADDR=$(hyprctl activewindow -j | jq -r '.address')

# Get all windows on current workspace
WINDOWS=$(hyprctl clients -j | jq -r --arg ws "$CURRENT_WS" '[.[] | select(.workspace.id == ($ws | tonumber))] | length')

# If no windows or only one window, switch workspace
if [ "$WINDOWS" -le 1 ]; then
    if [ "$DIRECTION" = "l" ]; then
        hyprctl dispatch workspace r-1
    elif [ "$DIRECTION" = "r" ]; then
        hyprctl dispatch workspace r+1
    fi
    exit 0
fi

# Try to move focus
hyprctl dispatch movefocus "$DIRECTION"

# Check if focus actually changed
NEW_ADDR=$(hyprctl activewindow -j | jq -r '.address')

# If focus didn't change, we're at the edge - switch workspace
if [ "$CURRENT_ADDR" = "$NEW_ADDR" ]; then
    if [ "$DIRECTION" = "l" ]; then
        hyprctl dispatch workspace r-1
    elif [ "$DIRECTION" = "r" ]; then
        hyprctl dispatch workspace r+1
    fi
fi
