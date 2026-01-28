#!/bin/bash
# Check if Caps Lock is on
if xset q 2>/dev/null | grep -q "Caps Lock:   on"; then
    echo "CAPS LOCK"
fi
