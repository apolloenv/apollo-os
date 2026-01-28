#!/bin/bash

#####################################################################
# Apollo OS - Quick Action Menu
# Copyright © 2025 by Manuel Kraibacher
#
# Description: Rofi-based quick action menu
# Keybinding: Super+Shift+Space
#####################################################################

set -e

# Ensure XDG_RUNTIME_DIR for TTS/audio
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"

# Load config for theme detection
CONFIG_FILE="$HOME/.config/apollo-os/config.env"
if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
fi

# Define actions (v1.0.4) - Nerd Font icons, no leading spaces
actions=(
    " Next Wallpaper"
    " Visual Mode"
    " Display Scaling"
    " External Monitor Scaling"
    " Power Profiles"
    " TTS Voice"
    " Edit Configs"
    " Keyboard Shortcuts"
    " APOLLO OS Update"
    " Install Winboat (Windows VM)"
    " Reload Infobar"
    " Reload Notifications"
    " Reload Apollo OS Orbit"
    " Lock Screen"
    " Logout"
    " Reboot"
    " Shutdown"
)

# Show menu with improved styling
selected=$(printf '%s\n' "${actions[@]}" | rofi -dmenu -p "> Quick Menu" -i \
    -theme-str 'window {width: 750px;} listview {lines: 6; scrollbar: true;} element {padding: 8px 12px;}')

# Execute selected action
case "$selected" in
    " Lock Screen")
        # Use swaylock with black background
        if command -v swaylock &>/dev/null; then
            swaylock -f -c 000000
        else
            notify-send "Apollo OS" "swaylock not installed"
        fi
        ;;

    " APOLLO OS Update")
        # TTS before terminal opens
        "$HOME/.local/bin/apollo-os-tts-notify.sh" update-start >/dev/null 2>&1
        alacritty -e bash -c "$HOME/.local/bin/apollo-os-update.sh; $HOME/.local/bin/apollo-os-tts-notify.sh update-complete >/dev/null 2>&1"
        ;;

    " Keyboard Shortcuts")
        "$HOME/.local/bin/apollo-os-shortcuts.sh"
        ;;

    " Next Wallpaper")
        "$HOME/.local/bin/apollo-os-wallpaper-cycle.sh"
        ;;

    " Visual Mode")
        # Get current mode
        current_mode=$("$HOME/.local/bin/apollo-os-visual-mode.sh" status 2>/dev/null || echo "classic")

        # All available visual modes
        modes="🎯 Classic - Traditional clean style
🚀 Developer - Code-focused layout
🖥️ Enterprise - Terminal-style optimized
🔵 Tech Blue - Modern professional blue design
🔲 i3 - Tiling WM style with colored blocks
📺 i3-retro - Retro Linux 70s/80s colors
⚡ i3-contrast - High contrast i3 with animations
◼️ Minimal - Clean vertical sidebar
🎨 Modern - Contemporary design
✨ Nova - Futuristic bottom bar
🪐 Orbit - Cosmic futuristic theme
💼 Professional - Business-oriented layout
🖥️ SGI - IRIX Indigo Magic workstation"

        selected_mode=$(echo -e "$modes" | rofi -dmenu -p "> Visual [$current_mode]" -i)

        if [ -n "$selected_mode" ]; then
            # Extract mode name from selection
            case "$selected_mode" in
                *"Classic"*)
                    mode="classic"
                    ;;
                *"Developer"*)
                    mode="developer"
                    ;;
                *"Enterprise"*)
                    mode="enterprise"
                    ;;
                *"Tech Blue"*)
                    mode="tech-blue"
                    ;;
                *"i3-retro"*)
                    mode="i3-retro"
                    ;;
                *"i3-contrast"*)
                    mode="i3-contrast"
                    ;;
                *"i3"*)
                    mode="i3"
                    ;;
                *"Minimal"*)
                    mode="minimal"
                    ;;
                *"Nova"*)
                    mode="nova"
                    ;;
                *"Modern"*)
                    mode="modern"
                    ;;
                *"Orbit"*)
                    mode="orbit"
                    ;;
                *"Professional"*)
                    mode="professional"
                    ;;
                *"SGI"*)
                    mode="sgi"
                    ;;
            esac

            if [ -n "$mode" ]; then
                "$HOME/.local/bin/apollo-os-visual-mode.sh" "$mode"
            fi
        fi
        ;;

    " Power Profiles")
        # Get available profiles with clearer descriptions
        if command -v powerprofilesctl &>/dev/null; then
            current=$(powerprofilesctl get 2>/dev/null || echo "balanced")
            
            # Create menu with descriptions
            options="🔋 Power Saver - Save battery, lower performance
⚖️  Balanced - Standard mode (default)
⚡ Performance - Maximum performance"
            
            selected_option=$(echo -e "$options" | rofi -dmenu -p "> Power [$current]" -i)
            
            if [ -n "$selected_option" ]; then
                case "$selected_option" in
                    *"Power Saver"*)
                        profile="power-saver"
                        ;;
                    *"Balanced"*)
                        profile="balanced"
                        ;;
                    *"Performance"*)
                        profile="performance"
                        ;;
                esac
                
                if [ -n "$profile" ]; then
                    if powerprofilesctl set "$profile" 2>/dev/null; then
                        notify-send "Apollo OS" "Power profile: $profile activated"
                        # TTS feedback
                        "$HOME/.local/bin/apollo-os-tts-notify.sh" "$profile" >/dev/null 2>&1 &
                    fi
                fi
            fi
        else
            notify-send "Apollo OS" "Power profiles not available"
        fi
        ;;

    " TTS Voice")
        "$HOME/.local/bin/apollo-os-voice-switcher.sh"
        ;;

    " Display Scaling")
        # Display scaling options for internal display
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

    " External Monitor Scaling")
        # External monitor scaling
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
        # Empty selection - do nothing
        ;;

    " Edit Configs")
        # Config editor submenu
        configs="🪐 Niri Config (Window Manager)
📊 Waybar Config (Statusbar)
🔔 Mako Config (Notifications)
🚀 Rofi Config (Launcher)
💻 Alacritty Config (Terminal)
🎨 GTK-3 Settings
🎨 GTK-4 Settings"
        selected_config=$(echo -e "$configs" | rofi -dmenu -p "> Edit Config")

        EDITOR="${VISUAL:-${EDITOR:-gnome-text-editor}}"

        case "$selected_config" in
            *"Niri Config"*)
                $EDITOR "$HOME/.config/niri/config.kdl" &
                ;;
            *"Waybar Config"*)
                $EDITOR "$HOME/.config/waybar/config-niri" &
                ;;
            *"Mako Config"*)
                $EDITOR "$HOME/.config/mako/config" &
                ;;
            *"Rofi Config"*)
                $EDITOR "$HOME/.config/rofi/config.rasi" &
                ;;
            *"Alacritty Config"*)
                $EDITOR "$HOME/.config/alacritty/alacritty.toml" &
                ;;
            *"GTK-3"*)
                $EDITOR "$HOME/.config/gtk-3.0/settings.ini" &
                ;;
            *"GTK-4"*)
                $EDITOR "$HOME/.config/gtk-4.0/settings.ini" &
                ;;
        esac
        ;;

    " Install Winboat (Windows VM)")
        # Check if already installed
        if command -v winboat &>/dev/null; then
            notify-send "Apollo OS" "Winboat is already installed"
            winboat --version 2>/dev/null | head -1 | xargs -I{} notify-send "Winboat" "Version: {}"
        else
            confirm=$(echo -e "No\nYes" | rofi -dmenu -p "> Install Winboat?")
            if [ "$confirm" = "Yes" ]; then
                notify-send "Apollo OS" "Installing Winboat... Please wait."
                alacritty -e bash -c '
                    echo "Installing Winboat Windows VM Manager..."
                    echo ""

                    # Install dependencies
                    echo "Installing dependencies..."
                    sudo dnf install -y qemu-kvm libvirt virt-manager bridge-utils freerdp || echo "Some dependencies may already be installed"

                    # Enable libvirtd
                    sudo systemctl enable --now libvirtd 2>/dev/null || true
                    sudo usermod -aG libvirt $USER 2>/dev/null || true

                    # Download Winboat
                    echo ""
                    echo "Downloading Winboat v0.9.0..."
                    WINBOAT_URL="https://github.com/TibixDev/winboat/releases/download/v0.9.0/winboat-0.9.0-x86_64.rpm"
                    WINBOAT_RPM="/tmp/winboat-0.9.0-x86_64.rpm"

                    wget -q --show-progress -O "$WINBOAT_RPM" "$WINBOAT_URL"

                    if [ -f "$WINBOAT_RPM" ] && [ $(stat -c%s "$WINBOAT_RPM") -gt 1000 ]; then
                        echo ""
                        echo "Installing Winboat..."
                        sudo dnf install -y "$WINBOAT_RPM"
                        rm -f "$WINBOAT_RPM"

                        if command -v winboat &>/dev/null; then
                            echo ""
                            echo "✓ Winboat installed successfully!"
                            echo "  Run: winboat"
                        else
                            echo ""
                            echo "✗ Installation may have failed"
                        fi
                    else
                        echo ""
                        echo "✗ Download failed"
                    fi

                    echo ""
                    read -p "Press Enter to close..."
                '
            fi
        fi
        ;;

    " Reload Infobar")
        WPID=$(pgrep -x waybar)
        if [ -n "$WPID" ]; then
            kill $WPID 2>/dev/null || true
        fi
        sleep 0.5
        waybar -c "$HOME/.config/waybar/config-niri" &
        notify-send "Apollo OS" "Infobar reloaded"
        ;;

    " Reload Notifications")
        MPID=$(pgrep -x mako)
        if [ -n "$MPID" ]; then
            kill $MPID 2>/dev/null || true
        fi
        sleep 0.2
        mako --config "$HOME/.config/mako/config" &
        notify-send "Apollo OS" "Notifications reloaded"
        ;;

    " Reload Apollo OS Orbit")
        # Confirm
        confirm=$(echo -e "No\nYes" | rofi -dmenu -p "> Reload WM?")
        if [ "$confirm" = "Yes" ]; then
            if pgrep -x niri >/dev/null; then
                niri msg action quit
                # Note: This will exit to login manager, user needs to re-login
            fi
        fi
        ;;

    " Logout")
        # Confirm
        confirm=$(echo -e "No\nYes" | rofi -dmenu -p "> Logout?")
        if [ "$confirm" = "Yes" ]; then
            if pgrep -x niri >/dev/null; then
                niri msg action quit
            fi
        fi
        ;;

    " Shutdown")
        # Confirm
        confirm=$(echo -e "No\nYes" | rofi -dmenu -p "> Shutdown?")
        if [ "$confirm" = "Yes" ]; then
            # TTS announcement before shutdown
            "$HOME/.local/bin/apollo-os-tts-notify.sh" shutdown
            sleep 1
            systemctl poweroff
        fi
        ;;

    " Reboot")
        # Confirm
        confirm=$(echo -e "No\nYes" | rofi -dmenu -p "> Reboot?")
        if [ "$confirm" = "Yes" ]; then
            # TTS announcement before reboot
            "$HOME/.local/bin/apollo-os-tts-notify.sh" reboot
            sleep 1
            systemctl reboot
        fi
        ;;
esac
