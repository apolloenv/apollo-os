#!/usr/bin/env bash

#####################################################################
# Apollo OS - Disk Space Monitor v0.6.0
# Copyright © 2025-2026 by Manuel Kraibacher
#
# Description: Monitors disk usage and warns when running low.
#              Runs as background daemon, checks every 10 minutes.
#####################################################################

export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"

WARN_THRESHOLD=90    # Warn at 90% usage
CRIT_THRESHOLD=95    # Critical at 95% usage
CHECK_INTERVAL=600   # 10 minutes
WARNED_PARTS=""
WARN_COOLDOWN=3600   # Don't repeat same warning within 1 hour

declare -A WARN_TIMES

check_partition() {
    local mount="$1"
    local usage pct

    usage=$(df "$mount" 2>/dev/null | tail -1 | awk '{print $5}' | tr -d '%')
    [ -z "$usage" ] && return

    local key
    key=$(echo "$mount" | tr '/' '_')
    local now
    now=$(date +%s)

    if [ "$usage" -ge "$CRIT_THRESHOLD" ]; then
        local last_crit=${WARN_TIMES["CRIT_${key}"]:-0}
        if [ $((now - last_crit)) -ge "$WARN_COOLDOWN" ]; then
            notify-send -u critical "💾 Disk Critical" "${mount}: ${usage}% belegt! Sofort Speicher freigeben!" 2>/dev/null
            if [ -x "$HOME/.local/bin/apollo-speak.sh" ]; then
                "$HOME/.local/bin/apollo-speak.sh" "Warnung: Festplatte ${mount} bei ${usage} Prozent!" &
            fi
            WARN_TIMES["CRIT_${key}"]=$now
        fi
    elif [ "$usage" -ge "$WARN_THRESHOLD" ]; then
        local last_warn=${WARN_TIMES["WARN_${key}"]:-0}
        if [ $((now - last_warn)) -ge "$WARN_COOLDOWN" ]; then
            notify-send -u normal "💾 Disk Warning" "${mount}: ${usage}% belegt" 2>/dev/null
            WARN_TIMES["WARN_${key}"]=$now
        fi
    fi
}

while true; do
    # Check root and home partitions
    check_partition "/"
    check_partition "$HOME"

    # Check any other mounted data partitions
    while IFS= read -r mount; do
        [ -n "$mount" ] && check_partition "$mount"
    done < <(df --output=target -x tmpfs -x devtmpfs -x efivarfs 2>/dev/null | tail -n +2 | grep -v "^/$\|^${HOME}$")

    sleep "$CHECK_INTERVAL"
done
