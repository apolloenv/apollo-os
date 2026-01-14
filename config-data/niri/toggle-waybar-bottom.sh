#!/usr/bin/env bash

#####################################################################
# Apollo OS - Toggle Bottom Waybar
# Copyright © 2025 by Manuel Kraibacher
#
# Description: Blendet die untere Waybar ein/aus mittels CSS-Klasse
#####################################################################

# CSS file for hiding bottom bar
CSS_OVERRIDE="$HOME/.config/waybar/hide-bottom.css"

# Ensure CSS file exists (even if empty)
touch "$CSS_OVERRIDE"

# Check if override has content (bar is hidden)
if [ -s "$CSS_OVERRIDE" ]; then
    # Bottom bar is hidden, show it by emptying the CSS file
    echo "" > "$CSS_OVERRIDE"
else
    # Bottom bar is visible, hide it
    cat > "$CSS_OVERRIDE" << 'EOF'
/* Hide bottom waybar */
window#waybar.bottom {
    opacity: 0 !important;
    transform: translateY(100%) !important;
    pointer-events: none !important;
}
EOF
fi

# Restart waybar to apply changes
WAYBAR_PID=$(pgrep -x waybar)
if [ -n "$WAYBAR_PID" ]; then
    kill $WAYBAR_PID 2>/dev/null
    sleep 0.3
    waybar -c ~/.config/waybar/config-niri &
    disown
fi




