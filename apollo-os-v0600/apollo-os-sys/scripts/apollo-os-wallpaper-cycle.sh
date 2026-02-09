#!/bin/bash
set -e

WALLPAPER_DIR="$HOME/System/Wallpaper"
CURRENT_LINK="$WALLPAPER_DIR/current.jpg"

# Get all wallpapers - exclude current.jpg symlink
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

# Restart swaybg with new wallpaper
SWAYBG_PID=$(pgrep -x swaybg 2>/dev/null || true)
if [ -n "$SWAYBG_PID" ]; then
    /bin/kill "$SWAYBG_PID" 2>/dev/null || true
    sleep 0.3
fi
swaybg -i "$next_wallpaper" -m fill &
disown

# If running under Hyprland with Quickshell, trigger color generation
if [ "$APOLLO_WM" = "Hyprland" ] || [ "$XDG_CURRENT_DESKTOP" = "Hyprland" ]; then
    SWITCHWALL="$HOME/.config/quickshell/ii/scripts/colors/switchwall.sh"
    if [ -x "$SWITCHWALL" ]; then
        bash "$SWITCHWALL" "$next_wallpaper" &>/dev/null &
        disown
    fi
fi

# Notification
wallpaper_name=$(basename "$next_wallpaper")
notify-send "Apollo OS" "Wallpaper: $wallpaper_name"

exit 0
