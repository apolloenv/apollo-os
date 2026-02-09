#!/bin/bash

#####################################################################
# Apollo OS - Daily Security Audit
# Copyright © 2025 by Manuel Kraibacher
#
# Description: Runs Lynis audit and rkhunter scan, logs results
#              and notifies user of critical findings.
# Runs as: systemd user timer (daily)
#####################################################################

set -euo pipefail

STATE_DIR="$HOME/.local/state/apollo-os"
AUDIT_LOG="$STATE_DIR/security-audit.log"
LOCK_FILE="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/apollo-os-audit.lock"

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

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$AUDIT_LOG"
}

notify_user() {
    notify-send -u "$1" "🛡️ Security Audit" "$2" -t 10000 2>/dev/null || true
}

# Keep log under 5000 lines
if [ -f "$AUDIT_LOG" ] && [ "$(wc -l < "$AUDIT_LOG")" -gt 5000 ]; then
    tail -2500 "$AUDIT_LOG" > "${AUDIT_LOG}.tmp"
    mv "${AUDIT_LOG}.tmp" "$AUDIT_LOG"
fi

log "=== Daily Security Audit Started ==="

warnings=0
criticals=0

# --- 1. rkhunter scan ---
if command -v rkhunter &>/dev/null; then
    log "Running rkhunter scan..."
    rkhunter_out=$(sudo rkhunter --check --skip-keypress --report-warnings-only 2>/dev/null || true)

    if [ -n "$rkhunter_out" ]; then
        rkhunter_warnings=$(echo "$rkhunter_out" | grep -c "Warning" || true)
        warnings=$((warnings + rkhunter_warnings))
        log "rkhunter: $rkhunter_warnings warnings found"
        echo "$rkhunter_out" >> "$AUDIT_LOG"
    else
        log "rkhunter: Clean ✓"
    fi
else
    log "rkhunter: Not installed, skipping"
fi

# --- 2. Lynis audit ---
if command -v lynis &>/dev/null; then
    log "Running Lynis audit..."
    local_report="$STATE_DIR/lynis-report.dat"

    # Run lynis in non-interactive mode
    sudo lynis audit system --no-colors --quiet --report-file "$local_report" 2>/dev/null || true

    if [ -f "$local_report" ]; then
        lynis_warnings=$(grep -c "warning\[\]" "$local_report" 2>/dev/null || true)
        lynis_score=$(grep "hardening_index" "$local_report" 2>/dev/null | cut -d'=' -f2 || echo "?")
        warnings=$((warnings + lynis_warnings))
        log "Lynis: Score $lynis_score/100, $lynis_warnings warnings"
    fi
else
    log "Lynis: Not installed, skipping"
fi

# --- 3. ClamAV signature freshness ---
if command -v freshclam &>/dev/null; then
    clam_log="/var/log/freshclam.log"
    if [ -f "$clam_log" ]; then
        last_update=$(stat -c '%Y' "$clam_log" 2>/dev/null || echo "0")
        now=$(date '+%s')
        age=$(( (now - last_update) / 86400 ))
        if [ "$age" -gt 3 ]; then
            log "ClamAV: Signatures are $age days old (WARNING)"
            warnings=$((warnings + 1))
        else
            log "ClamAV: Signatures up to date ($age days) ✓"
        fi
    fi
fi

# --- 4. Firewalld status ---
if command -v firewall-cmd &>/dev/null; then
    fw_state=$(sudo firewall-cmd --state 2>/dev/null || echo "unknown")
    if [ "$fw_state" != "running" ]; then
        log "Firewall: NOT running! (CRITICAL)"
        criticals=$((criticals + 1))
    else
        active_zone=$(sudo firewall-cmd --get-active-zones 2>/dev/null | head -1 || echo "unknown")
        open_ports=$(sudo firewall-cmd --list-ports 2>/dev/null || echo "none")
        log "Firewall: Running ✓ (Zone: $active_zone, Open: $open_ports)"
    fi
fi

# --- 5. fail2ban status ---
if command -v fail2ban-client &>/dev/null; then
    f2b_status=$(sudo fail2ban-client status 2>/dev/null || echo "not running")
    banned=$(sudo fail2ban-client status sshd 2>/dev/null | grep "Currently banned" | awk '{print $NF}' || echo "0")
    log "fail2ban: $f2b_status (Banned IPs: $banned)"
fi

# --- 6. SELinux status ---
if command -v getenforce &>/dev/null; then
    se_status=$(getenforce 2>/dev/null || echo "unknown")
    if [ "$se_status" != "Enforcing" ]; then
        log "SELinux: $se_status (WARNING - should be Enforcing)"
        warnings=$((warnings + 1))
    else
        log "SELinux: Enforcing ✓"
    fi
fi

# --- 7. SUID/SGID Binary Audit ---
log "Checking for unusual SUID/SGID binaries..."
suid_state="$STATE_DIR/suid-binaries.state"
current_suid=$(find /usr /bin /sbin -perm /6000 -type f 2>/dev/null | sort)

if [ -f "$suid_state" ]; then
    new_suid=$(comm -13 "$suid_state" <(echo "$current_suid"))
    if [ -n "$new_suid" ]; then
        suid_count=$(echo "$new_suid" | wc -l)
        log "SUID/SGID: $suid_count new setuid binaries detected!"
        log "New SUID binaries: $(echo "$new_suid" | tr '\n' ' ')"
        warnings=$((warnings + suid_count))
        notify_user "critical" "⚠️ $suid_count neue SUID-Binaries entdeckt!" 2>/dev/null || true
    else
        log "SUID/SGID: No changes ✓"
    fi
fi
echo "$current_suid" > "$suid_state"

# --- 8. World-Writable Files in System Directories ---
log "Checking for world-writable files..."
world_writable=$(find /etc /usr -xdev -type f -perm -0002 2>/dev/null | head -20)
if [ -n "$world_writable" ]; then
    ww_count=$(echo "$world_writable" | wc -l)
    log "PERMISSIONS: $ww_count world-writable files in system directories!"
    echo "$world_writable" >> "$AUDIT_LOG"
    warnings=$((warnings + 1))
else
    log "PERMISSIONS: No world-writable system files ✓"
fi

# --- 9. AIDE File Integrity Check ---
if command -v aide &>/dev/null && [ -f /var/lib/aide/aide.db.gz ]; then
    log "Running AIDE integrity check..."
    aide_result=$(sudo aide --check 2>/dev/null | tail -5 || echo "AIDE check failed")
    aide_changed=$(echo "$aide_result" | grep -c "changed\|added\|removed" || true)
    if [ "$aide_changed" -gt 0 ]; then
        log "AIDE: File integrity changes detected!"
        echo "$aide_result" >> "$AUDIT_LOG"
        warnings=$((warnings + 1))
    else
        log "AIDE: File integrity OK ✓"
    fi
fi

# --- 10. Listening Services Audit ---
log "Checking listening services..."
unexpected_listeners=""
while IFS= read -r line; do
    port=$(echo "$line" | awk '{print $4}' | rev | cut -d: -f1 | rev)
    # Skip common expected ports
    case "$port" in
        22|53|631|5353|323) continue ;;  # SSH, DNS, CUPS, mDNS, chrony
    esac
    proc=$(echo "$line" | awk '{print $NF}')
    # Flag if listening on 0.0.0.0 or :: (all interfaces)
    if echo "$line" | grep -qE '0\.0\.0\.0:\*|:::\*|\*:'; then
        unexpected_listeners="$unexpected_listeners\n  Port $port ($proc)"
    fi
done < <(ss -tlnp 2>/dev/null | tail -n +2)
if [ -n "$unexpected_listeners" ]; then
    log "SERVICES: Unexpected listeners on all interfaces:$unexpected_listeners"
fi

# --- Summary ---
log "=== Audit Complete: $criticals critical, $warnings warnings ==="

if [ "$criticals" -gt 0 ]; then
    notify_user "critical" "⚠️ $criticals kritische Probleme gefunden!\n$warnings Warnungen\nDetails: $AUDIT_LOG"
elif [ "$warnings" -gt 3 ]; then
    notify_user "normal" "$warnings Warnungen gefunden\nDetails: $AUDIT_LOG"
fi
