#!/usr/bin/env bash

#####################################################################
# Apollo OS - Service Watchdog v0.6.0
# Copyright © 2025-2026 by Manuel Kraibacher
#
# Description: Monitors critical Apollo OS services and restarts
#              them if they crash. Runs as background daemon.
#####################################################################

CHECK_INTERVAL=30

# Services to monitor (user-level systemd services)
WATCHED_SERVICES=(
    "apollo-os-port-monitor.timer"
    "apollo-os-notification-handler.service"
    "screen-corners.service"
)

log() {
    logger -t "apollo-watchdog" "$1"
}

restart_service() {
    local svc="$1"
    log "Service $svc is not running. Restarting..."
    systemctl --user restart "$svc" 2>/dev/null
    if systemctl --user is-active --quiet "$svc" 2>/dev/null; then
        log "Service $svc restarted successfully ✓"
    else
        log "Failed to restart $svc"
    fi
}

while true; do
    for svc in "${WATCHED_SERVICES[@]}"; do
        # Only watch services that exist AND are enabled
        if systemctl --user list-unit-files "$svc" &>/dev/null \
            && systemctl --user is-enabled --quiet "$svc" 2>/dev/null; then
            if ! systemctl --user is-active --quiet "$svc" 2>/dev/null; then
                restart_service "$svc"
            fi
        fi
    done
    sleep "$CHECK_INTERVAL"
done
