#!/bin/bash

#####################################################################
# Apollo OS - Notification Handler
# Copyright © 2026 by Manuel Kraibacher
#
# Description: Handles notification actions and opens chat interface
# This script runs as a daemon to monitor notification actions
#####################################################################

set -e

# Configuration
FIFO_PATH="/tmp/apollo-notification-actions"

# Create FIFO if it doesn't exist
if [[ ! -p "$FIFO_PATH" ]]; then
    mkfifo "$FIFO_PATH"
fi

# Function to handle notification action
handle_action() {
    local action="$1"

    case "$action" in
        *reply*|*Reply*)
            # Open chat interface
            "$HOME/.local/bin/apollo-os-chat.sh" &
            ;;
        *)
            # Unknown action
            echo "Unknown action: $action"
            ;;
    esac
}

# Monitor for mako/dunst actions
monitor_mako() {
    # Mako actions are sent via signals
    # Listen for action activations
    while true; do
        if command -v makoctl &>/dev/null; then
            # Check for new actions every second
            sleep 1
            # This is a simplified approach; actual implementation
            # would use mako's built-in action handling
        else
            sleep 10
        fi
    done
}

# Main loop
echo "Apollo Notification Handler started"

# Method 1: Monitor FIFO for manual triggers
while true; do
    if read line < "$FIFO_PATH"; then
        handle_action "$line"
    fi
done &

# Method 2: Monitor mako
monitor_mako &

# Wait for background processes
wait
