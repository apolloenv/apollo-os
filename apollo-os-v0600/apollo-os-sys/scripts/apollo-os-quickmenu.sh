#!/bin/bash

#####################################################################
# Apollo OS - Quick Action Menu
# Copyright © 2025 by Manuel Kraibacher
#
# Description: Rofi-based quick action menu
# Keybinding: Super+Shift+Space
#####################################################################

# No set -e: rofi returns exit 1 on Escape which is normal behavior

# Ensure XDG_RUNTIME_DIR for TTS/audio
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"

# Load config for theme detection
CONFIG_FILE="$HOME/.config/apollo-os/config.env"
if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
fi

# Define actions - text only, no icons
actions=(
    "Next Wallpaper"
    "Visual Mode"
    "Screenshot"
    "Screenrecord"
    "Color Picker"
    "Clipboard History"
    "Quick Note"
    "Bluetooth"
    "WiFi"
    "Remote Connections"
    "Security Status"
    "System Health"
    "Display Scaling"
    "External Monitor Scaling"
    "Power Profiles"
    "TTS Voice"
    "TTS On/Off"
    "Edit Configs"
    "Keyboard Shortcuts"
    "APOLLO OS Update"
    "Install Winboat (Windows VM)"
    "Reload Infobar"
    "Reload Notifications"
    "Reload Apollo OS Orbit"
    "Lock Screen"
    "Logout"
    "Reboot"
    "Shutdown"
)

# Show menu
selected=$(printf '%s\n' "${actions[@]}" | rofi -dmenu -p "> Quick Menu" -i \
    -theme-str 'window {width: 750px;} listview {lines: 8; scrollbar: true;} element {padding: 8px 12px;}')

# Execute selected action
case "$selected" in
    "Lock Screen")
        if command -v hyprlock &>/dev/null; then
            hyprlock
        else
            notify-send "Apollo OS" "hyprlock not installed"
        fi
        ;;

    "APOLLO OS Update")
        update_options="System Update - DNF, Flatpak, Firmware, Security
Security Update Only - ClamAV, rkhunter, patches
Full Reinstall - Complete Apollo OS from GitHub"

        selected_update=$(echo -e "$update_options" | rofi -dmenu -p "> Update" -i \
            -theme-str 'window {width: 750px;} listview {lines: 4;}')

        case "$selected_update" in
            *"System Update"*)
                "$HOME/.local/bin/apollo-os-tts-notify.sh" update-start >/dev/null 2>&1
                alacritty -e bash -c '"$HOME/.local/bin/apollo-os-update.sh" 1; "$HOME/.local/bin/apollo-os-tts-notify.sh" update-complete >/dev/null 2>&1'
                ;;
            *"Security Update Only"*)
                alacritty -e bash -c '"$HOME/.local/bin/apollo-os-update.sh" 3'
                ;;
            *"Full Reinstall"*)
                confirm=$(echo -e "No\nYes - Full Reinstall" | rofi -dmenu -p "> Confirm Reinstall?")
                if [[ "$confirm" == *"Yes"* ]]; then
                    "$HOME/.local/bin/apollo-os-tts-notify.sh" update-start >/dev/null 2>&1
                    alacritty -e bash -c '"$HOME/.local/bin/apollo-os-update.sh" 2; "$HOME/.local/bin/apollo-os-tts-notify.sh" update-complete >/dev/null 2>&1'
                fi
                ;;
        esac
        ;;

    "Keyboard Shortcuts")
        "$HOME/.local/bin/apollo-os-shortcuts.sh"
        ;;

    "Next Wallpaper")
        "$HOME/.local/bin/apollo-os-wallpaper-cycle.sh"
        ;;

    "Visual Mode")
        current_mode=$("$HOME/.local/bin/apollo-os-visual-mode.sh" status 2>/dev/null || echo "apollo-core")

        modes="Apollo Core - Traditional clean style
Code Forge - Code-focused layout
Command Center - Terminal-style optimized
Frost Byte - Modern professional blue design
Pixel Grid - Tiling WM style with colored blocks
Retro Wave - Retro Linux 70s/80s colors
Neon Edge - High contrast with animations
Zen Flow - Clean vertical sidebar
Nova Pulse - Contemporary design
Crystal Bay - Apple macOS Sequoia style
Star Deck - Futuristic bottom bar
Deep Space - Cosmic futuristic theme
Command Deck - Business-oriented layout
Command Deck Clean - Business layout without bottom bar
Light Bridge - Light professional theme
Cyber Matrix - Ultra-futuristic monochrome
Quantum Flux - Cyberpunk colorful & functional
Silicon Dawn - IRIX Indigo Magic workstation"

        selected_mode=$(echo -e "$modes" | rofi -dmenu -p "> Visual [$current_mode]" -i)

        if [ -n "$selected_mode" ]; then
            case "$selected_mode" in
                *"Apollo Core"*)       mode="apollo-core" ;;
                *"Code Forge"*)        mode="code-forge" ;;
                *"Command Center"*)    mode="command-center" ;;
                *"Frost Byte"*)        mode="frost-byte" ;;
                *"Retro Wave"*)        mode="retro-wave" ;;
                *"Neon Edge"*)         mode="neon-edge" ;;
                *"Pixel Grid"*)        mode="pixel-grid" ;;
                *"Zen Flow"*)          mode="zen-flow" ;;
                *"Star Deck"*)         mode="star-deck" ;;
                *"Nova Pulse"*)        mode="nova-pulse" ;;
                *"Crystal Bay"*)       mode="crystal-bay" ;;
                *"Deep Space"*)        mode="deep-space" ;;
                *"Quantum Flux"*)      mode="quantum-flux" ;;
                *"Cyber Matrix"*)      mode="cyber-matrix" ;;
                *"Command Deck Clean"*) mode="command-deck-clean" ;;
                *"Command Deck"*)      mode="command-deck" ;;
                *"Light Bridge"*)      mode="light-bridge" ;;
                *"Silicon Dawn"*)      mode="silicon-dawn" ;;
            esac

            if [ -n "$mode" ]; then
                "$HOME/.local/bin/apollo-os-visual-mode.sh" "$mode"
            fi
        fi
        ;;

    "Screenshot")
        shot_options="Region auswaehlen + bearbeiten
Region in Zwischenablage
Fullscreen + bearbeiten
Fullscreen in Zwischenablage"

        selected_shot=$(echo -e "$shot_options" | rofi -dmenu -p "> Screenshot" -i)

        case "$selected_shot" in
            *"Region auswaehlen + bearbeiten"*)
                "$HOME/.local/bin/apollo-os-screenshot.sh" smart edit &
                ;;
            *"Region in Zwischenablage"*)
                "$HOME/.local/bin/apollo-os-screenshot.sh" smart clipboard &
                ;;
            *"Fullscreen + bearbeiten"*)
                "$HOME/.local/bin/apollo-os-screenshot.sh" fullscreen edit &
                ;;
            *"Fullscreen in Zwischenablage"*)
                "$HOME/.local/bin/apollo-os-screenshot.sh" fullscreen clipboard &
                ;;
        esac
        ;;

    "Screenrecord")
        if pgrep -f "wf-recorder\|gpu-screen-recorder" >/dev/null 2>&1; then
            "$HOME/.local/bin/apollo-os-screenrecord.sh" --stop
        else
            rec_options="Bildschirm aufnehmen
Mit Desktop-Audio
Mit Mikrofon
Mit Desktop-Audio + Mikrofon"

            selected_rec=$(echo -e "$rec_options" | rofi -dmenu -p "> Screenrecord" -i)

            case "$selected_rec" in
                *"Mit Desktop-Audio + Mikrofon"*)
                    "$HOME/.local/bin/apollo-os-screenrecord.sh" --with-desktop-audio --with-microphone-audio &
                    ;;
                *"Mit Desktop-Audio"*)
                    "$HOME/.local/bin/apollo-os-screenrecord.sh" --with-desktop-audio &
                    ;;
                *"Mit Mikrofon"*)
                    "$HOME/.local/bin/apollo-os-screenrecord.sh" --with-microphone-audio &
                    ;;
                *"Bildschirm aufnehmen"*)
                    "$HOME/.local/bin/apollo-os-screenrecord.sh" &
                    ;;
            esac
        fi
        ;;

    "Color Picker")
        "$HOME/.local/bin/apollo-os-colorpicker.sh" &
        ;;

    "Clipboard History")
        if command -v cliphist &>/dev/null; then
            cliphist list | rofi -dmenu -p "> Clipboard" -i \
                -theme-str 'window {width: 800px;} listview {lines: 15;}' \
                | cliphist decode | wl-copy
        else
            notify-send "Apollo OS" "cliphist not installed"
        fi
        ;;

    "Quick Note")
        NOTES_DIR="$HOME/Notizen"
        mkdir -p "$NOTES_DIR"
        note=$(rofi -dmenu -p "> Notiz" -i \
            -theme-str 'window {width: 700px;}' \
            -mesg "Notiz eingeben (Enter zum Speichern)")
        if [ -n "$note" ]; then
            NOTES_FILE="$NOTES_DIR/Notizen.md"
            echo "- [$(date '+%Y-%m-%d %H:%M')] $note" >> "$NOTES_FILE"
            notify-send "Apollo OS" "Notiz gespeichert ✓" -t 1500
        fi
        ;;

    "Bluetooth")
        "$HOME/.local/bin/apollo-os-bluetooth.sh" &
        ;;

    "WiFi")
        "$HOME/.local/bin/apollo-os-wifi.sh" &
        ;;

    "Remote Connections")
        REMMINA_DIR="$HOME/.local/share/remmina"
        connections=""

        if [ -d "$REMMINA_DIR" ] && ls "$REMMINA_DIR"/*.remmina &>/dev/null; then
            while IFS= read -r file; do
                conn_name=$(grep -m1 '^name=' "$file" 2>/dev/null | cut -d'=' -f2-)
                conn_server=$(grep -m1 '^server=' "$file" 2>/dev/null | cut -d'=' -f2-)
                conn_protocol=$(grep -m1 '^protocol=' "$file" 2>/dev/null | cut -d'=' -f2-)
                conn_group=$(grep -m1 '^group=' "$file" 2>/dev/null | cut -d'=' -f2-)

                [ -z "$conn_name" ] && continue

                label="$conn_name [$conn_protocol] ($conn_server)"
                if [ -n "$conn_group" ]; then
                    label="$conn_group/$conn_name [$conn_protocol] ($conn_server)"
                fi

                if [ -n "$connections" ]; then
                    connections="$connections\n$label"
                else
                    connections="$label"
                fi
            done < <(find "$REMMINA_DIR" -name "*.remmina" -type f | sort)
        fi

        if [ -z "$connections" ]; then
            notify-send "Apollo OS" "Keine Remmina-Verbindungen gefunden"
        else
            selected_conn=$(echo -e "$connections" | rofi -dmenu -p "> Remote Connect" -i \
                -theme-str 'window {width: 850px;} listview {lines: 8; scrollbar: true;} element {padding: 8px 12px;}')

            if [ -n "$selected_conn" ]; then
                conn_name=$(echo "$selected_conn" | sed 's/ \[.*//')
                conn_name_clean="${conn_name##*/}"

                conn_file=""
                while IFS= read -r file; do
                    file_name=$(grep -m1 '^name=' "$file" 2>/dev/null | cut -d'=' -f2-)
                    if [ "$file_name" = "$conn_name_clean" ]; then
                        conn_file="$file"
                        break
                    fi
                done < <(find "$REMMINA_DIR" -name "*.remmina" -type f)

                if [ -n "$conn_file" ]; then
                    notify-send "Apollo OS" "Verbinde mit: $conn_name_clean" -t 2000
                    remmina -c "$conn_file" &
                else
                    notify-send "Apollo OS" "Verbindung nicht gefunden: $conn_name_clean"
                fi
            fi
        fi
        ;;

    "Security Status")
        # Gather status
        status_lines=""
        fw=$(systemctl is-active firewalld 2>/dev/null || echo "inactive")
        [ "$fw" = "active" ] && status_lines+="✅ Firewall\n" || status_lines+="❌ Firewall\n"
        f2b=$(systemctl is-active fail2ban 2>/dev/null || echo "inactive")
        [ "$f2b" = "active" ] && status_lines+="✅ fail2ban\n" || status_lines+="❌ fail2ban\n"
        clam=$(systemctl is-active clamav-freshclam 2>/dev/null || echo "inactive")
        [ "$clam" = "active" ] && status_lines+="✅ ClamAV\n" || status_lines+="❌ ClamAV\n"
        se=$(getenforce 2>/dev/null || echo "Disabled")
        status_lines+="🔒 SELinux: $se\n"
        bd=$(systemctl is-active bdsec 2>/dev/null || echo "inactive")
        [ "$bd" = "active" ] && status_lines+="✅ Bitdefender\n" || status_lines+="❌ Bitdefender\n"
        [ -f /etc/systemd/resolved.conf.d/99-apollo-dns-tls.conf ] && status_lines+="✅ DNS-over-TLS\n" || status_lines+="❌ DNS-over-TLS\n"
        [ -f /etc/NetworkManager/conf.d/99-apollo-mac-random.conf ] && status_lines+="✅ MAC Randomization\n" || status_lines+="❌ MAC Randomization\n"
        open_ports=$(ss -tlnp 2>/dev/null | awk 'NR>1 {print $4}' | sort -u | tr '\n' ', ' | sed 's/,$//')
        status_lines+="🌐 Ports: ${open_ports:-keine}"

        notify-send -t 10000 "Apollo OS - Security Status" "$(echo -e "$status_lines")"
        ;;

    "Power Profiles")
        if command -v powerprofilesctl &>/dev/null; then
            current=$(powerprofilesctl get 2>/dev/null || echo "balanced")

            options="Power Saver - Save battery, lower performance
Balanced - Standard mode (default)
Performance - Maximum performance"

            selected_option=$(echo -e "$options" | rofi -dmenu -p "> Power [$current]" -i)

            if [ -n "$selected_option" ]; then
                case "$selected_option" in
                    *"Power Saver"*)   profile="power-saver" ;;
                    *"Balanced"*)      profile="balanced" ;;
                    *"Performance"*)   profile="performance" ;;
                esac

                if [ -n "$profile" ]; then
                    if powerprofilesctl set "$profile" 2>/dev/null; then
                        notify-send "Apollo OS" "Power profile: $profile activated"
                        "$HOME/.local/bin/apollo-os-tts-notify.sh" "$profile" >/dev/null 2>&1 &
                    fi
                fi
            fi
        else
            notify-send "Apollo OS" "Power profiles not available"
        fi
        ;;

    "TTS Voice")
        "$HOME/.local/bin/apollo-os-voice-switcher.sh"
        ;;

    "TTS On/Off")
        tts_status=$("$HOME/.local/bin/apollo-os-tts-notify.sh" tts-status 2>/dev/null || echo "enabled")

        if [ "$tts_status" = "enabled" ]; then
            current="Aktiviert"
            options="Deaktivieren - Sprachausgabe ausschalten
Aktiviert lassen"
        else
            current="Deaktiviert"
            options="Aktivieren - Sprachausgabe einschalten
Deaktiviert lassen"
        fi

        selected_option=$(echo -e "$options" | rofi -dmenu -p "> TTS [$current]" -i)

        if [ -n "$selected_option" ]; then
            case "$selected_option" in
                *"Deaktivieren"*)
                    "$HOME/.local/bin/apollo-os-tts-notify.sh" tts-disable
                    notify-send "Apollo OS" "Sprachausgabe deaktiviert"
                    ;;
                *"Aktivieren"*)
                    "$HOME/.local/bin/apollo-os-tts-notify.sh" tts-enable
                    notify-send "Apollo OS" "Sprachausgabe aktiviert"
                    ;;
            esac
        fi
        ;;

    "System Health")
        cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{printf "%.0f%%", $2+$4}')
        mem_info=$(free -h | awk '/Mem:/ {printf "%s / %s (%s)", $3, $2, $7}')
        swap_info=$(free -h | awk '/Swap:/ {printf "%s / %s", $3, $2}')
        disk_root=$(df -h / | tail -1 | awk '{printf "%s / %s (%s)", $3, $2, $5}')
        disk_home=$(df -h "$HOME" | tail -1 | awk '{printf "%s / %s (%s)", $3, $2, $5}')
        uptime_info=$(uptime -p | sed 's/up //')
        load_avg=$(cat /proc/loadavg | awk '{print $1, $2, $3}')

        # Battery (if available)
        bat_info="N/A (Desktop)"
        bat_cap=$(cat /sys/class/power_supply/BAT*/capacity 2>/dev/null | head -1)
        bat_status=$(cat /sys/class/power_supply/BAT*/status 2>/dev/null | head -1)
        [ -n "$bat_cap" ] && bat_info="${bat_cap}% (${bat_status})"

        # CPU temperature
        temp="N/A"
        if [ -f /sys/class/thermal/thermal_zone0/temp ]; then
            raw_temp=$(cat /sys/class/thermal/thermal_zone0/temp)
            temp="$((raw_temp / 1000))°C"
        fi

        # Services
        svc_count=$(systemctl --user list-units --state=running --no-legend 2>/dev/null | wc -l)

        health_report="CPU: $cpu_usage | Temp: $temp
Memory: $mem_info
Swap: $swap_info
Disk /: $disk_root
Disk ~: $disk_home
Battery: $bat_info
Load: $load_avg
Uptime: $uptime_info
User Services: ${svc_count} running"

        echo "$health_report" | rofi -dmenu -p "> System Health" -i \
            -theme-str 'window {width: 650px;} listview {lines: 10;}'
        ;;

    "Display Scaling")
        scales="1.0 - No scaling (100%)
1.25 - Small scaling (125%)
1.5 - Medium scaling (150%)
2.0 - Large scaling (200%)"
        selected_scale=$(echo -e "$scales" | rofi -dmenu -p "> Display Scale")
        if [ -n "$selected_scale" ]; then
            scale_value=$(echo "$selected_scale" | awk '{print $1}')
            "$HOME/.local/bin/apollo-os-scale-setter.sh" "$scale_value"
        fi
        ;;

    "External Monitor Scaling")
        scales="1.0 - No scaling (100%)
1.25 - Small scaling (125%)
1.5 - Medium scaling (150%)
2.0 - Large scaling (200%)"
        selected_scale=$(echo -e "$scales" | rofi -dmenu -p "> External Scale")
        if [ -n "$selected_scale" ]; then
            scale_value=$(echo "$selected_scale" | awk '{print $1}')
            "$HOME/.local/bin/apollo-os-scale-setter.sh" "$scale_value" external
            notify-send "Apollo OS" "External monitor scaling set to ${scale_value}x\nReconnect monitor to apply"
        fi
        ;;

    "")
        ;;

    "Edit Configs")
        configs="Niri Config (Window Manager)
Waybar Config (Statusbar)
Mako Config (Notifications)
Rofi Config (Launcher)
Alacritty Config (Terminal)
GTK-3 Settings
GTK-4 Settings"
        selected_config=$(echo -e "$configs" | rofi -dmenu -p "> Edit Config")

        EDITOR="${VISUAL:-${EDITOR:-gnome-text-editor}}"

        case "$selected_config" in
            *"Niri Config"*)      $EDITOR "$HOME/.config/niri/config.kdl" & ;;
            *"Waybar Config"*)    $EDITOR "$HOME/.config/waybar/config-niri" & ;;
            *"Mako Config"*)      $EDITOR "$HOME/.config/mako/config" & ;;
            *"Rofi Config"*)      $EDITOR "$HOME/.config/rofi/config.rasi" & ;;
            *"Alacritty Config"*) $EDITOR "$HOME/.config/alacritty/alacritty.toml" & ;;
            *"GTK-3"*)            $EDITOR "$HOME/.config/gtk-3.0/settings.ini" & ;;
            *"GTK-4"*)            $EDITOR "$HOME/.config/gtk-4.0/settings.ini" & ;;
        esac
        ;;

    "Install Winboat (Windows VM)")
        if command -v winboat &>/dev/null; then
            notify-send "Apollo OS" "Winboat is already installed"
        else
            confirm=$(echo -e "No\nYes" | rofi -dmenu -p "> Install Winboat?")
            if [ "$confirm" = "Yes" ]; then
                notify-send "Apollo OS" "Installing Winboat... Please wait."
                alacritty -e bash -c '
                    echo "Installing Winboat Windows VM Manager..."
                    echo ""
                    sudo dnf install -y qemu-kvm libvirt virt-manager bridge-utils freerdp-libs || echo "Some dependencies may already be installed"
                    sudo systemctl enable --now libvirtd 2>/dev/null || true
                    sudo usermod -aG libvirt $USER 2>/dev/null || true
                    echo ""
                    WB_VERSION=$(timeout 10 curl -s https://api.github.com/repos/TibixDev/winboat/releases/latest | grep "\"tag_name\"" | cut -d"\"" -f4)
                    if [ -z "$WB_VERSION" ]; then
                        WB_VERSION="v0.9.0"
                        echo "Could not fetch latest version, using $WB_VERSION"
                    fi
                    echo "Downloading Winboat $WB_VERSION..."
                    WINBOAT_URL="https://github.com/TibixDev/winboat/releases/download/${WB_VERSION}/winboat-${WB_VERSION#v}-x86_64.rpm"
                    WINBOAT_RPM="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/winboat-${WB_VERSION#v}-x86_64.rpm"
                    wget -q --show-progress -O "$WINBOAT_RPM" "$WINBOAT_URL"
                    if [ -f "$WINBOAT_RPM" ] && [ $(stat -c%s "$WINBOAT_RPM") -gt 1000 ]; then
                        sudo dnf install -y "$WINBOAT_RPM"
                        rm -f "$WINBOAT_RPM"
                        command -v winboat &>/dev/null && echo "Winboat $WB_VERSION installed successfully!" || echo "Installation may have failed"
                    else
                        echo "Download failed"
                    fi
                    echo ""
                    read -p "Press Enter to close..."
                '
            fi
        fi
        ;;

    "Reload Infobar")
        WPID=$(pgrep -x waybar)
        if [ -n "$WPID" ]; then
            kill $WPID 2>/dev/null || true
        fi
        sleep 0.5
        if pgrep -x niri >/dev/null; then
            waybar -c "$HOME/.config/waybar/config-niri" &
        elif pgrep -x Hyprland >/dev/null; then
            waybar -c "$HOME/.config/waybar/config" &
        else
            waybar &
        fi
        notify-send "Apollo OS" "Infobar reloaded"
        ;;

    "Reload Notifications")
        MPID=$(pgrep -x mako)
        if [ -n "$MPID" ]; then
            kill $MPID 2>/dev/null || true
        fi
        sleep 0.2
        mako --config "$HOME/.config/mako/config" &
        notify-send "Apollo OS" "Notifications reloaded"
        ;;

    "Reload Apollo OS Orbit")
        confirm=$(echo -e "No\nYes" | rofi -dmenu -p "> Reload WM?")
        if [ "$confirm" = "Yes" ]; then
            if pgrep -x niri >/dev/null; then
                niri msg action quit
            elif pgrep -x Hyprland >/dev/null; then
                hyprctl reload
                notify-send "Apollo OS" "Hyprland config reloaded"
            fi
        fi
        ;;

    "Logout")
        confirm=$(echo -e "No\nYes" | rofi -dmenu -p "> Logout?")
        if [ "$confirm" = "Yes" ]; then
            if pgrep -x niri >/dev/null; then
                niri msg action quit
            elif pgrep -x Hyprland >/dev/null; then
                hyprctl dispatch exit
            fi
        fi
        ;;

    "Shutdown")
        confirm=$(echo -e "No\nYes" | rofi -dmenu -p "> Shutdown?")
        if [ "$confirm" = "Yes" ]; then
            "$HOME/.local/bin/apollo-os-tts-notify.sh" shutdown
            sleep 1
            systemctl poweroff
        fi
        ;;

    "Reboot")
        confirm=$(echo -e "No\nYes" | rofi -dmenu -p "> Reboot?")
        if [ "$confirm" = "Yes" ]; then
            "$HOME/.local/bin/apollo-os-tts-notify.sh" reboot
            sleep 1
            systemctl reboot
        fi
        ;;
esac
