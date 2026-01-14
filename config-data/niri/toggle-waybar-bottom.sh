#!/usr/bin/env bash

#####################################################################
# Apollo OS - Toggle Bottom Waybar
# Copyright © 2025 by Manuel Kraibacher
#
# Description: Blendet die untere Waybar ein/aus mittels CSS-Klasse
#####################################################################

# CSS file for hiding bottom bar
CSS_OVERRIDE="$HOME/.config/waybar/hide-bottom.css"

# Check if override exists
if [ -f "$CSS_OVERRIDE" ]; then
    # Bottom bar is hidden, show it
    rm "$CSS_OVERRIDE"
else
    # Bottom bar is visible, hide it
    cat > "$CSS_OVERRIDE" << 'EOF'
/* Hide bottom waybar */
window#waybar.bottom {
    opacity: 0;
    transform: translateY(100%);
}
EOF
fi

# Reload waybar to apply changes
WAYBAR_PID=$(pgrep -x waybar)
if [ -n "$WAYBAR_PID" ]; then
    kill -SIGUSR2 $WAYBAR_PID 2>/dev/null
fi


