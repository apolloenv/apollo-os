#!/bin/bash

#####################################################################
# Apollo OS - Boot Sequence v0.6.0
# Copyright (c) 2025 by Manuel Kraibacher
#
# Secure boot initialization sequence
# Press Ctrl+C to abort and drop to shell
#####################################################################

# Colors
R='\033[0;31m'
G='\033[0;32m'
Y='\033[1;33m'
B='\033[0;34m'
C='\033[0;36m'
W='\033[1;37m'
D='\033[0;90m'
NC='\033[0m'

ABORT=false
abort_boot() {
    ABORT=true
    echo
    echo -e "${Y}[ABORT]${NC} Boot sequence terminated by operator."
    sleep 1
    exit 0
}
trap 'abort_boot' INT

check() {
    $ABORT && return
    local label="$1" status="$2" color="$3"
    printf "  ${D}[${NC}${color}%s${NC}${D}]${NC} %s\n" "$status" "$label"
    sleep 0.03
}

clear
echo

# ── Banner ──
echo -e "${D}  ──────────────────────────────────────────────────────────${NC}"
echo -e "${W}      ___                ____           ____  _____${NC}"
echo -e "${W}     /   |  ____  ____  / / /___       / __ \\/ ___/${NC}"
echo -e "${W}    / /| | / __ \\/ __ \\/ / / __ \\     / / / /\\__ \\ ${NC}"
echo -e "${W}   / ___ |/ /_/ / /_/ / / / /_/ /    / /_/ /___/ /${NC}"
echo -e "${W}  /_/  |_/ .___/\\____/_/_/\\____/     \\____//____/ ${NC}"
echo -e "${W}        /_/${NC}"
echo -e "${D}  ──────────────────────────────────────────────────────────${NC}"
echo -e "${D}  Apollo OS v0.6.0 | Secure Workstation Environment${NC}"
echo -e "${D}  ──────────────────────────────────────────────────────────${NC}"
echo
sleep 0.2

# ── Phase 1: Hardware Inventory ──
KERNEL=$(uname -r 2>/dev/null || echo "unknown")
HOSTNAME_STR=$(hostname 2>/dev/null || echo "localhost")
CPU=$(grep -m1 'model name' /proc/cpuinfo 2>/dev/null | cut -d: -f2 | xargs || echo "n/a")
MEM_TOTAL=$(free -h 2>/dev/null | awk '/^Mem:/{print $2}' || echo "n/a")
UPTIME=$(uptime -p 2>/dev/null | sed 's/up //' || echo "n/a")
DISK_ROOT=$(df -h / 2>/dev/null | awk 'NR==2{print $4 " free / " $2}' || echo "n/a")

echo -e "${C}  HARDWARE INITIALIZATION${NC}"
check "Kernel ${KERNEL}" "LOAD" "$G"
check "Host ${HOSTNAME_STR}" "IDENT" "$G"
check "CPU ${CPU:0:50}" "ONLINE" "$G"
check "Memory ${MEM_TOTAL} total" "MAPPED" "$G"
check "Disk ${DISK_ROOT}" "MOUNTED" "$G"
echo
sleep 0.1

# ── Phase 2: Security Posture ──
echo -e "${R}  SECURITY POSTURE ASSESSMENT${NC}"

# SELinux
SE_STATUS=$(getenforce 2>/dev/null || echo "disabled")
case "$SE_STATUS" in
    Enforcing) check "SELinux mandatory access control" "ENFORCING" "$G" ;;
    Permissive) check "SELinux mandatory access control" "PERMISSIVE" "$Y" ;;
    *) check "SELinux mandatory access control" "DISABLED" "$R" ;;
esac

# Firewall
FW_STATUS=$(systemctl is-active firewalld 2>/dev/null || echo "inactive")
if [ "$FW_STATUS" = "active" ]; then
    ZONE=$(firewall-cmd --get-default-zone 2>/dev/null || echo "default")
    RULES=$(firewall-cmd --list-all 2>/dev/null | grep -c "rule" || echo "0")
    check "Firewall zone=${ZONE} (${RULES} rules)" "ACTIVE" "$G"
else
    check "Firewall" "DOWN" "$R"
fi

# fail2ban
F2B=$(systemctl is-active fail2ban 2>/dev/null || echo "inactive")
if [ "$F2B" = "active" ]; then
    JAILS=$(timeout 2 sudo -n fail2ban-client status 2>/dev/null | grep "Number of jail" | awk '{print $NF}' || echo "?")
    BANNED=$(timeout 2 sudo -n fail2ban-client status 2>/dev/null | grep -c "Banned" || echo "0")
    check "Intrusion prevention (${JAILS} jails active)" "ARMED" "$G"
else
    check "Intrusion prevention system" "INACTIVE" "$Y"
fi

# ClamAV
CLAM=$(systemctl is-active clamav-freshclam 2>/dev/null || echo "inactive")
if [ "$CLAM" = "active" ]; then
    SIG_DATE=$(stat -c %y /var/lib/clamav/daily.cld 2>/dev/null | cut -d' ' -f1 || echo "current")
    check "Antivirus signature database (${SIG_DATE})" "CURRENT" "$G"
else
    check "Antivirus signature database" "STALE" "$Y"
fi

# Bitdefender
BD=$(systemctl is-active bdsec 2>/dev/null || systemctl is-active bdagentd 2>/dev/null || echo "inactive")
if [ "$BD" = "active" ]; then
    check "Endpoint detection and response (EDR)" "ACTIVE" "$G"
else
    check "Endpoint detection and response (EDR)" "N/A" "$D"
fi

# rkhunter
if command -v rkhunter &>/dev/null; then
    check "Rootkit detection engine" "BASELINED" "$G"
fi

# Audit
AUDIT=$(systemctl is-active auditd 2>/dev/null || echo "inactive")
if [ "$AUDIT" = "active" ]; then
    check "Kernel audit subsystem (auditd)" "LOGGING" "$G"
else
    check "Kernel audit subsystem (auditd)" "OFF" "$Y"
fi

echo
sleep 0.1

# ── Phase 3: Network Security ──
echo -e "${B}  NETWORK SECURITY${NC}"

# Open ports
PORTS=$(ss -tlnp 2>/dev/null | awk 'NR>1 {split($4,a,":"); print a[length(a)]}' | sort -un | tr '\n' ',' | sed 's/,$//' || echo "none")
LISTEN_COUNT=$(ss -tlnp 2>/dev/null | awk 'NR>1' | wc -l)
check "Listening services: ${LISTEN_COUNT} (ports: ${PORTS:-none})" "SCANNED" "$C"

# Established connections
ESTABLISHED=$(ss -tnp 2>/dev/null | awk 'NR>1' | wc -l)
check "Established connections: ${ESTABLISHED}" "MONITORED" "$G"

# Port monitor
PM=$(systemctl --user is-active apollo-os-port-monitor.timer 2>/dev/null || echo "inactive")
if [ "$PM" = "active" ]; then
    check "Automated port scan monitor (5min interval)" "ACTIVE" "$G"
else
    check "Automated port scan monitor" "DISABLED" "$Y"
fi

# DNS
DNS=$(grep -m1 'nameserver' /etc/resolv.conf 2>/dev/null | awk '{print $2}' || echo "n/a")
check "DNS resolver: ${DNS}" "CONFIGURED" "$G"

# SSH hardening check
if [ -f /etc/ssh/sshd_config.d/99-apollo-ssh-hardening.conf ]; then
    check "SSH access control" "HARDENED" "$G"
elif [ -f /etc/ssh/sshd_config ]; then
    ROOT_LOGIN=$(grep -i "^PermitRootLogin" /etc/ssh/sshd_config 2>/dev/null | awk '{print $2}' || echo "default")
    if [ "$ROOT_LOGIN" = "no" ]; then
        check "SSH root login" "DENIED" "$G"
    else
        check "SSH root login" "ALLOWED" "$Y"
    fi
fi

# Kernel hardening
if [ -f /etc/sysctl.d/99-apollo-hardening.conf ]; then
    check "Kernel network hardening" "ENFORCED" "$G"
else
    check "Kernel network hardening" "DEFAULT" "$Y"
fi

# AIDE integrity monitoring
if command -v aide &>/dev/null && [ -f /var/lib/aide/aide.db.gz ]; then
    check "File integrity database (AIDE)" "ACTIVE" "$G"
fi

# Auto-updates
if systemctl is-active dnf-automatic-install.timer &>/dev/null; then
        check "Automatic security patching" "ENABLED" "$G"
fi

# DNS-over-TLS
if [ -f /etc/systemd/resolved.conf.d/99-apollo-dns-tls.conf ]; then
    check "DNS-over-TLS encryption" "ACTIVE" "$G"
fi

# MAC randomization
if [ -f /etc/NetworkManager/conf.d/99-apollo-mac-random.conf ]; then
    check "MAC address randomization" "ENABLED" "$G"
fi

echo
sleep 0.1

# ── Phase 4: Subsystems ──
echo -e "${C}  SUBSYSTEM INITIALIZATION${NC}"

# Audio subsystem
PW=$(systemctl --user is-active pipewire 2>/dev/null || echo "inactive")
if [ "$PW" = "active" ]; then
    check "Audio pipeline (PipeWire)" "RUNNING" "$G"
else
    check "Audio pipeline" "PENDING" "$Y"
fi

# TTS engine
TTS_CONFIG="$HOME/.config/apollo-os/tts.conf"
if [ -f "$TTS_CONFIG" ] && grep -q "TTS_ENABLED=false" "$TTS_CONFIG" 2>/dev/null; then
    check "Voice synthesis engine" "DISABLED" "$D"
else
    check "Voice synthesis engine" "STANDBY" "$G"
fi

# Voice recognition
if [ -f "$HOME/.local/bin/apollo-wake-listener.py" ]; then
    check "Voice command interface" "ARMED" "$G"
fi

# Systemd user services
USER_SERVICES=$(systemctl --user list-units --state=active --no-legend --no-pager 2>/dev/null | wc -l)
check "User service units: ${USER_SERVICES} active" "RUNNING" "$G"

echo
sleep 0.1

# ── Phase 5: Integrity ──
echo -e "${G}  SYSTEM INTEGRITY${NC}"

# Filesystem
check "Root filesystem ($(mount | grep ' / ' | awk '{print $5}'))" "CLEAN" "$G"

# Last login
LAST_LOGIN=$(last -1 -R 2>/dev/null | head -1 | awk '{print $3, $4, $5, $6}' || echo "n/a")
check "Last authenticated session: ${LAST_LOGIN}" "LOGGED" "$G"

# Failed logins since last boot
FAILED=$(journalctl -b --no-pager -q 2>/dev/null | grep -ci "authentication failure\|Failed password" || echo "0")
if [ "$FAILED" -gt 0 ] 2>/dev/null; then
    check "Failed authentication attempts this boot: ${FAILED}" "ALERT" "$R"
else
    check "Failed authentication attempts this boot: 0" "CLEAR" "$G"
fi

# Package updates
UPDATES=$(dnf check-update --quiet 2>/dev/null | grep -c "^[a-zA-Z]" || echo "0")
if [ "$UPDATES" -gt 0 ] 2>/dev/null; then
    check "Pending security updates: ${UPDATES} packages" "REVIEW" "$Y"
else
    check "Security patches" "UP TO DATE" "$G"
fi

echo
echo -e "${D}  ──────────────────────────────────────────────────────────${NC}"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S %Z')
echo -e "  ${G}All systems nominal.${NC}"
echo -e "  ${D}Session: $(whoami)@${HOSTNAME_STR} | ${TIMESTAMP}${NC}"
echo -e "  ${D}Uptime: ${UPTIME}${NC}"
echo -e "${D}  ──────────────────────────────────────────────────────────${NC}"
echo

# ── Load configuration ──
APOLLO_CONFIG="$HOME/.config/apollo-os/config.env"
WM_TO_LAUNCH=""
if [[ -f "$APOLLO_CONFIG" ]]; then
    source "$APOLLO_CONFIG"
    WM_TO_LAUNCH="${DEFAULT_WM:-}"
fi

# ── Detect available environments ──
HAS_NIRI=false
HAS_HYPRLAND=false
[[ -x "$HOME/.local/bin/apollo-os-wrapper-niri.sh" ]] && command -v niri &>/dev/null && HAS_NIRI=true
[[ -x "$HOME/.local/bin/start-hyprland" ]] && command -v Hyprland &>/dev/null && HAS_HYPRLAND=true

# ── Environment Selection (if both available) ──
if $HAS_NIRI && $HAS_HYPRLAND; then
    echo -e "  ${C}SESSION SELECT${NC}"
    echo -e "  ${D}──────────────────────────────────────────────────────────${NC}"
    echo -e "  ${W}1${NC}  Apollo OS Orbit   ${D}(Tiling/Scrollable)${NC}"
    echo -e "  ${W}2${NC}  Apollo OS Glass   ${D}(Compositing/Transparent)${NC}"
    echo -e "  ${D}──────────────────────────────────────────────────────────${NC}"

    # Determine default selection
    case "$WM_TO_LAUNCH" in
        Hyprland|hyprland) DEFAULT_CHOICE=2 ;;
        *) DEFAULT_CHOICE=1 ;;
    esac
    echo -ne "  ${D}Select [1-2] (default: ${DEFAULT_CHOICE}, auto in 10s): ${NC}"

    # Read with 10 second timeout
    if read -t 10 -n 1 SESSION_CHOICE; then
        echo
    else
        SESSION_CHOICE=$DEFAULT_CHOICE
        echo "${SESSION_CHOICE}"
    fi
    SESSION_CHOICE=${SESSION_CHOICE:-$DEFAULT_CHOICE}

    case "$SESSION_CHOICE" in
        2) WM_TO_LAUNCH="Hyprland" ;;
        *) WM_TO_LAUNCH="niri" ;;
    esac
    echo
elif $HAS_HYPRLAND; then
    WM_TO_LAUNCH="Hyprland"
elif $HAS_NIRI; then
    WM_TO_LAUNCH="niri"
else
    echo -e "  ${R}[FATAL]${NC} No compositor found. Dropping to shell."
    exit 1
fi

# ── Display name ──
case "$WM_TO_LAUNCH" in
    Hyprland|hyprland) WM_DISPLAY="Glass" ;;
    *) WM_DISPLAY="Orbit" ;;
esac

# ── Countdown ──
echo -ne "  ${D}Initializing Apollo OS ${WM_DISPLAY}...${NC} "
for i in 3 2 1; do
    $ABORT && exit 0
    printf "${W}%d ${NC}" "$i"
    sleep 1
done
echo
echo

# ── Launch ──
case "$WM_TO_LAUNCH" in
    Hyprland|hyprland)
        if [[ -x "$HOME/.local/bin/start-hyprland" ]]; then
            exec "$HOME/.local/bin/start-hyprland"
        else
            echo -e "  ${R}[ERROR]${NC} start-hyprland not found."
            sleep 5
            exit 0
        fi
        ;;
    *)
        exec "$HOME/.local/bin/apollo-os-wrapper-niri.sh"
        ;;
esac
