#!/bin/bash
# Restore wallpaper on Hyprland start
# Falls back to swaybg with current wallpaper
WALLPAPER="$HOME/System/Wallpaper/current.jpg"
if [ -f "$WALLPAPER" ] || [ -L "$WALLPAPER" ]; then
    swaybg -i "$WALLPAPER" -m fill &
fi
