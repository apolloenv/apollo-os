#!/bin/bash

#####################################################################
# Apollo OS - Display Scaling Setter
# Copyright © 2026 by Manuel Kraibacher
#
# Description: Changes display scaling in Niri config
# Usage: apollo-os-scale-setter.sh <scale>
#####################################################################

# Set environment for Wayland/DBus
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
export WAYLAND_DISPLAY="${WAYLAND_DISPLAY:-wayland-1}"
export DBUS_SESSION_BUS_ADDRESS="${DBUS_SESSION_BUS_ADDRESS:-unix:path=$XDG_RUNTIME_DIR/bus}"

NIRI_CONFIG="$HOME/.config/niri/config.kdl"
SCALE="$1"

if [ -z "$SCALE" ]; then
    echo "Usage: $0 <scale>"
    echo "Example: $0 1.25"
    exit 1
fi

# Validate scale value
if ! echo "$SCALE" | grep -qE '^[0-9]+\.?[0-9]*$'; then
    notify-send "Apollo OS" "Invalid scale value: $SCALE" -u critical
    exit 1
fi

# Calculate cursor size based on scale (default 24px base size)
BASE_CURSOR_SIZE=24
CURSOR_SIZE=$(echo "$SCALE * $BASE_CURSOR_SIZE" | bc | cut -d. -f1)

# Update scale in niri config for all outputs
sed -i "/^output /,/^}/ s/^\(    scale \)[0-9.]\+$/\1$SCALE/" "$NIRI_CONFIG"

# Update cursor size in niri config
if grep -q "xcursor-size" "$NIRI_CONFIG"; then
    sed -i "s/^\(    xcursor-size \)[0-9]\+$/\1$CURSOR_SIZE/" "$NIRI_CONFIG"
elif grep -q "^cursor {" "$NIRI_CONFIG"; then
    sed -i "/^cursor {/a\    xcursor-size $CURSOR_SIZE" "$NIRI_CONFIG"
else
    # Add cursor section if not present
    echo -e "\ncursor {\n    xcursor-size $CURSOR_SIZE\n}" >> "$NIRI_CONFIG"
fi

# Also set via gsettings for GTK apps
gsettings set org.gnome.desktop.interface cursor-size "$CURSOR_SIZE" 2>/dev/null

# Notify user that they need to logout/login
notify-send "Apollo OS" "Display scaling set to ${SCALE}x\nCursor size: ${CURSOR_SIZE}px\nLogout/Login required" -t 5000
