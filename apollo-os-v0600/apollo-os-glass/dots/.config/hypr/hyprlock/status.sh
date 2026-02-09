#!/bin/bash
# Show battery and network status
BATTERY=$(cat /sys/class/power_supply/BAT*/capacity 2>/dev/null | head -1)
WIFI=$(nmcli -t -f active,ssid dev wifi 2>/dev/null | grep '^yes' | cut -d: -f2)

STATUS=""
[ -n "$BATTERY" ] && STATUS="󰁹 ${BATTERY}%"
[ -n "$WIFI" ] && STATUS="${STATUS}  󰖩 ${WIFI}"

echo "$STATUS"
