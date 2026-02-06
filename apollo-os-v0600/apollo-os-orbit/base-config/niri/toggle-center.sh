#!/bin/bash

#####################################################################
# Apollo OS - Window Center Toggle Script
# Copyright © 2025 by Manuel Kraibacher
#
# Description: Toggles permanent window centering in Niri
# Keybinding: Super+C
#####################################################################

NIRI_CONFIG="$HOME/.config/niri/config.kdl"

# Check current state
if grep -q 'center-focused-column "always"' "$NIRI_CONFIG"; then
    # Currently centered, disable it
    sed -i 's/center-focused-column "always"/center-focused-column "never"/' "$NIRI_CONFIG"
    notify-send "Apollo OS" "Window centering: OFF" -t 1500
    
    # Reload Niri config
    niri msg action load-config-file
else
    # Currently not centered, enable it
    sed -i 's/center-focused-column "never"/center-focused-column "always"/' "$NIRI_CONFIG"
    notify-send "Apollo OS" "Window centering: ON" -t 1500
    
    # Reload Niri config
    niri msg action load-config-file
fi
