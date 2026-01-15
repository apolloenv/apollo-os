#!/bin/bash

#####################################################################
# Apollo OS - Notification Handler
# Copyright © 2026 by Manuel Kraibacher
#
# Description: Handles notification actions for Apollo OS
# This script runs as a daemon to monitor notification actions
#####################################################################

# Configuration
FIFO_PATH="/tmp/apollo-notification-actions"

# Create FIFO if it doesn't exist
if [[ ! -p "$FIFO_PATH" ]]; then
    mkfifo "$FIFO_PATH" 2>/dev/null || true
fi

# Function to handle notification action
handle_action() {
    local action="$1"

    case "$action" in
        open-settings)
            # Open system settings
            gnome-control-center &
            ;;
        open-network)
            # Open network settings
            nm-connection-editor &
            ;;
        open-bluetooth)
            # Open bluetooth manager
            blueman-manager &
            ;;
        dismiss)
            # Dismiss all notifications
            makoctl dismiss --all 2>/dev/null
            ;;
        *)
            # Log unknown action
            echo "[$(date)] Unknown action: $action" >> /tmp/apollo-notification.log
            ;;
    esac
}

# Monitor for mako actions
monitor_mako() {
    while true; do
        if command -v makoctl &>/dev/null; then
            # Check for pending notifications
            sleep 5
        else
            sleep 30
        fi
    done
}

# Main
echo "[$(date)] Apollo Notification Handler started" >> /tmp/apollo-notification.log

# Method 1: Monitor FIFO for manual triggers
while true; do
    if [[ -p "$FIFO_PATH" ]]; then
        if read -t 1 line < "$FIFO_PATH" 2>/dev/null; then
            handle_action "$line"
        fi
    fi
    sleep 1
done &

# Method 2: Monitor mako
monitor_mako &

# Wait for background processes
wait
