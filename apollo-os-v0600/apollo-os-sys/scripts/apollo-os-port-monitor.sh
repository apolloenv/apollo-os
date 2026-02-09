#!/bin/bash

#####################################################################
# Apollo OS - Port Monitor & Intrusion Detection
# Copyright © 2025 by Manuel Kraibacher
#
# Description: Monitors open ports and network connections for
#              suspicious activity. Sends desktop notifications
#              on changes or potential threats.
# Runs as: systemd user timer (every 5 minutes)
#####################################################################

set -euo pipefail

STATE_DIR="$HOME/.local/state/apollo-os"
PORT_STATE="$STATE_DIR/ports.state"
ALERT_LOG="$STATE_DIR/security-alerts.log"
LOCK_FILE="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/apollo-os-port-monitor.lock"

mkdir -p "$STATE_DIR"

# Prevent concurrent runs
if [ -f "$LOCK_FILE" ]; then
    pid=$(cat "$LOCK_FILE" 2>/dev/null)
    if kill -0 "$pid" 2>/dev/null; then
        exit 0
    fi
fi
echo $$ > "$LOCK_FILE"
trap 'rm -f "$LOCK_FILE"' EXIT

log_alert() {
    local msg="$1"
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] $msg" >> "$ALERT_LOG"

    # Keep log under 1000 lines
    if [ -f "$ALERT_LOG" ] && [ "$(wc -l < "$ALERT_LOG")" -gt 1000 ]; then
        tail -500 "$ALERT_LOG" > "${ALERT_LOG}.tmp"
        mv "${ALERT_LOG}.tmp" "$ALERT_LOG"
    fi
}

notify_user() {
    local urgency="$1"
    local msg="$2"
    notify-send -u "$urgency" "🛡️ Apollo Security" "$msg" -t 8000 2>/dev/null || true
}

# --- 1. Port Monitoring ---
check_ports() {
    local current_ports
    current_ports=$(ss -tlnp 2>/dev/null | awk 'NR>1 {print $4}' | sort -u)

    if [ ! -f "$PORT_STATE" ]; then
        echo "$current_ports" > "$PORT_STATE"
        log_alert "INIT: Port baseline established"
        return
    fi

    local prev_ports
    prev_ports=$(cat "$PORT_STATE")

    # Find new ports
    local new_ports
    new_ports=$(comm -13 <(echo "$prev_ports") <(echo "$current_ports"))

    # Find closed ports
    local closed_ports
    closed_ports=$(comm -23 <(echo "$prev_ports") <(echo "$current_ports"))

    if [ -n "$new_ports" ]; then
        local port_list
        port_list=$(echo "$new_ports" | tr '\n' ', ' | sed 's/,$//')
        log_alert "NEW PORTS: $port_list"
        notify_user "normal" "Neue Ports geöffnet:\n$port_list"
    fi

    if [ -n "$closed_ports" ]; then
        local port_list
        port_list=$(echo "$closed_ports" | tr '\n' ', ' | sed 's/,$//')
        log_alert "CLOSED PORTS: $port_list"
    fi

    echo "$current_ports" > "$PORT_STATE"
}

# --- 2. Suspicious Connection Detection ---
check_connections() {
    # Check for unusual outbound connections on known malware ports
    local suspicious_ports="4444 5555 6666 6667 8888 9999 31337 12345 65535"
    local found=""

    for port in $suspicious_ports; do
        if ss -tnp 2>/dev/null | grep -q ":${port}\b"; then
            found="$found $port"
        fi
    done

    if [ -n "$found" ]; then
        log_alert "SUSPICIOUS: Connections on known bad ports:$found"
        notify_user "critical" "⚠️ Verdächtige Verbindungen!\nPorts:$found"
    fi

    # Check for excessive outbound connections (possible C2/DDoS)
    local conn_count
    conn_count=$(ss -tnp 2>/dev/null | grep -c 'ESTAB' || true)
    if [ "$conn_count" -gt 200 ]; then
        log_alert "WARNING: High connection count: $conn_count established"
        notify_user "critical" "⚠️ Ungewöhnlich viele Verbindungen: $conn_count"
    fi
}

# --- 3. Failed Login Detection ---
check_auth_failures() {
    local failures
    failures=$(journalctl --user-unit=sshd -p err --since "5 min ago" --no-pager -q 2>/dev/null | wc -l || true)

    # Also check system journal for auth failures
    local sys_failures
    sys_failures=$(journalctl -p err -t sshd --since "5 min ago" --no-pager -q 2>/dev/null | wc -l || true)

    local total=$((failures + sys_failures))

    if [ "$total" -gt 5 ]; then
        log_alert "AUTH: $total failed login attempts in last 5 min"
        notify_user "critical" "⚠️ $total fehlgeschlagene Logins in 5 Min!"
    fi
}

# --- 4. File Integrity Spot-Check ---
check_critical_files() {
    local critical_files=(
        "/etc/passwd"
        "/etc/shadow"
        "/etc/sudoers"
        "/etc/ssh/sshd_config"
    )

    local hash_file="$STATE_DIR/critical-hashes.state"

    if [ ! -f "$hash_file" ]; then
        for f in "${critical_files[@]}"; do
            [ -f "$f" ] && sha256sum "$f" 2>/dev/null
        done > "$hash_file"
        log_alert "INIT: Critical file hashes baselined"
        return
    fi

    local changed=""
    while IFS= read -r line; do
        local stored_hash file
        stored_hash=$(echo "$line" | awk '{print $1}')
        file=$(echo "$line" | awk '{print $2}')
        [ ! -f "$file" ] && continue
        local current_hash
        current_hash=$(sha256sum "$file" 2>/dev/null | awk '{print $1}')
        if [ "$stored_hash" != "$current_hash" ]; then
            changed="$changed $file"
        fi
    done < "$hash_file"

    if [ -n "$changed" ]; then
        log_alert "INTEGRITY: Critical files changed:$changed"
        notify_user "critical" "⚠️ Kritische Systemdateien geändert!\n$changed"
        # Update baseline
        for f in "${critical_files[@]}"; do
            [ -f "$f" ] && sha256sum "$f" 2>/dev/null
        done > "$hash_file"
    fi
}

# --- Run all checks ---
check_ports
check_connections
check_auth_failures
check_critical_files
