#!/bin/bash
set -e

WALLPAPER_DIR="$HOME/System/Wallpaper"
CURRENT_LINK="$WALLPAPER_DIR/current.jpg"

# Get all wallpapers - exclude current.jpg
mapfile -t wallpapers < <(find "$WALLPAPER_DIR" -maxdepth 1 -type f \( -name "*.jpg" -o -name "*.png" -o -name "*.jpeg" \) ! -name "current.jpg" | sort)

if [ ${#wallpapers[@]} -eq 0 ]; then
    notify-send "Apollo OS" "No wallpapers found"
    exit 1
fi

# Get current wallpaper
current=""
if [ -L "$CURRENT_LINK" ]; then
    current=$(readlink -f "$CURRENT_LINK")
fi

# Find next wallpaper
next_wallpaper="${wallpapers[0]}"

for i in "${!wallpapers[@]}"; do
    if [[ "${wallpapers[$i]}" == "$current" ]]; then
        next_index=$(( (i + 1) % ${#wallpapers[@]} ))
        next_wallpaper="${wallpapers[$next_index]}"
        break
    fi
done

# Update symlink
ln -sf "$next_wallpaper" "$CURRENT_LINK"

# Copy to login wallpaper
sudo cp "$next_wallpaper" /usr/share/backgrounds/apollo-login.jpg 2>/dev/null || true

# Kill old swaybg by PID
SWAYBG_PID=$(pgrep -x swaybg)
if [ -n "$SWAYBG_PID" ]; then
    kill $SWAYBG_PID 2>/dev/null
    sleep 0.5
fi

# Start swaybg - use spawn from niri
swaybg -i "$next_wallpaper" -m fill &

# Notification
wallpaper_name=$(basename "$next_wallpaper")
notify-send "Apollo OS" "Wallpaper: $wallpaper_name"

exit 0
