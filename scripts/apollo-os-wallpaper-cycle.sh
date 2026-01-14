#!/bin/bash

#####################################################################
# Apollo OS - Wallpaper Cycle
# Copyright © 2026 by Manuel Kraibacher
#
# Description: Cycle through wallpapers in ~/System/Wallpaper/
# Keybinding: Ctrl+Super+Space
#####################################################################

WALLPAPER_DIR="$HOME/System/Wallpaper"
CURRENT_LINK="$WALLPAPER_DIR/current.jpg"

# Check if wallpaper directory exists
if [ ! -d "$WALLPAPER_DIR" ]; then
    notify-send "Apollo OS" "Wallpaper directory not found: $WALLPAPER_DIR"
    exit 1
fi

# Get all wallpapers (jpg, png, jpeg)
mapfile -t wallpapers < <(find "$WALLPAPER_DIR" -type f \( -name "*.jpg" -o -name "*.png" -o -name "*.jpeg" \) | sort)

# Check if we have wallpapers
if [ ${#wallpapers[@]} -eq 0 ]; then
    notify-send "Apollo OS" "No wallpapers found in $WALLPAPER_DIR"
    exit 1
fi

# Get current wallpaper
if [ -L "$CURRENT_LINK" ]; then
    current=$(readlink -f "$CURRENT_LINK")
else
    current=""
fi

# Find next wallpaper
next_wallpaper="${wallpapers[0]}"  # Default to first
found=false

for i in "${!wallpapers[@]}"; do
    if [[ "${wallpapers[$i]}" == "$current" ]]; then
        next_index=$(( (i + 1) % ${#wallpapers[@]} ))
        next_wallpaper="${wallpapers[$next_index]}"
        found=true
        break
    fi
done

# Update symlink
ln -sf "$next_wallpaper" "$CURRENT_LINK"

# Copy to login/lockscreen wallpaper (requires sudo)
if [ -f "$next_wallpaper" ]; then
    sudo cp "$next_wallpaper" /usr/share/backgrounds/apollo-login.jpg 2>/dev/null || true
    sudo chmod 644 /usr/share/backgrounds/apollo-login.jpg 2>/dev/null || true
fi

# Reload wallpaper based on WM
if pgrep -x swaybg >/dev/null; then
    # Niri uses swaybg
    pkill -x swaybg
    sleep 0.2
    swaybg -i "$CURRENT_LINK" -m fill &
elif pgrep -x sway >/dev/null; then
    # Sway uses output bg
    swaymsg output "*" bg "$CURRENT_LINK" fill
fi

# Get wallpaper name for notification
wallpaper_name=$(basename "$next_wallpaper")
notify-send "Apollo OS" "Wallpaper: $wallpaper_name" -i dialog-information

# Optional: Voice announcement
if command -v apollo-speak &>/dev/null && [ "${APOLLO_DND:-false}" != "true" ]; then
    apollo-speak "Wallpaper changed" &
fi
