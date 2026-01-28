#!/bin/bash

#####################################################################
# Apollo OS - Display Scaling Setter
# Copyright © 2025 by Manuel Kraibacher
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

# Update scale in niri config for all outputs
sed -i "/^output /,/^}/ s/^\(    scale \)[0-9.]\+$/\1$SCALE/" "$NIRI_CONFIG"

# Notify user that they need to logout/login
notify-send "Apollo OS" "Display scaling set to ${SCALE}x\nLogout/Login required for changes" -t 5000
