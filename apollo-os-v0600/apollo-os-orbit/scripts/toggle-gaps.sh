#!/bin/bash

#####################################################################
# Apollo OS - Window Gaps Toggle Script
# Copyright © 2025 by Manuel Kraibacher
#
# Description: Cycles through predefined gap values in Niri
# Keybinding: Super+G
# Gap values: 0px, 8px, 18px, 24px, 36px
#####################################################################

NIRI_CONFIG="$HOME/.config/niri/config.kdl"

# Array of gap values to cycle through
GAPS=(0 8 18 24 36)

# Get current gap value
CURRENT_GAP=$(grep -oP 'gaps \K\d+' "$NIRI_CONFIG" | head -1)
if [[ -z "$CURRENT_GAP" ]]; then
    CURRENT_GAP=12
fi

# Find current index in array
CURRENT_INDEX=-1
for i in "${!GAPS[@]}"; do
    if [[ "${GAPS[$i]}" == "$CURRENT_GAP" ]]; then
        CURRENT_INDEX=$i
        break
    fi
done

# Calculate next index (cycle back to 0 if at end)
if [[ $CURRENT_INDEX -eq -1 ]] || [[ $CURRENT_INDEX -eq $((${#GAPS[@]} - 1)) ]]; then
    NEXT_INDEX=0
else
    NEXT_INDEX=$((CURRENT_INDEX + 1))
fi

NEXT_GAP=${GAPS[$NEXT_INDEX]}

# Update config file
sed -i "s/gaps $CURRENT_GAP/gaps $NEXT_GAP/" "$NIRI_CONFIG"

# Send notification
notify-send "Apollo OS" "Window Gaps: ${NEXT_GAP}px" -t 1500

# Reload Niri config
niri msg action load-config-file
