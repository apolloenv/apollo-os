#!/bin/bash

#####################################################################
# Apollo OS - Display Scaling Setter
# Copyright © 2026 by Manuel Kraibacher
#
# Description: Changes display scaling in Niri config
# Usage: apollo-os-scale-setter.sh <scale>
#####################################################################

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

# Reload niri config
niri msg action reload-config 2>/dev/null || {
    notify-send "Apollo OS" "Failed to reload config" -u critical
    exit 1
}

# Notify user
notify-send "Apollo OS" "Display scaling set to ${SCALE}x"
