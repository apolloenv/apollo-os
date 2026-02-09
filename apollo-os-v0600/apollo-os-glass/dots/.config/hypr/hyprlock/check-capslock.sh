#!/bin/bash
# Check if Caps Lock is on (Wayland-compatible)
CAPS_STATE=$(cat /sys/class/leds/input*::capslock/brightness 2>/dev/null | head -1)
if [[ "$CAPS_STATE" == "1" ]]; then
    echo "CAPS LOCK"
fi
