#!/usr/bin/env bash
# apollo-os-brightness-fix.sh
# Copyright 2025 by Manuel Kraibacher
# Hotfix für Helligkeitssteuerung auf bestehenden Apollo OS Installationen

set -euo pipefail

# Farben
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}══════════════════════════════════════════════════════${NC}"
echo -e "${CYAN}  Apollo OS - Brightness Control Hotfix${NC}"
echo -e "${CYAN}══════════════════════════════════════════════════════${NC}\n"

# Prüfe ob brightnessctl installiert ist
if ! command -v brightnessctl &>/dev/null; then
    echo -e "${YELLOW}brightnessctl nicht gefunden. Installiere...${NC}"
    sudo dnf install -y brightnessctl || {
        echo -e "${RED}Installation fehlgeschlagen!${NC}"
        exit 1
    }
    echo -e "${GREEN}✓ brightnessctl installiert${NC}"
else
    echo -e "${GREEN}✓ brightnessctl bereits installiert${NC}"
fi

# Prüfe aktuelle Gruppen
echo -e "\n${CYAN}Aktuelle Benutzergruppen:${NC}"
groups

# Füge User zur video Gruppe hinzu
if ! groups | grep -q video; then
    echo -e "\n${YELLOW}Füge Benutzer zur 'video' Gruppe hinzu...${NC}"
    sudo usermod -aG video "$USER"
    echo -e "${GREEN}✓ Benutzer zur 'video' Gruppe hinzugefügt${NC}"
else
    echo -e "${GREEN}✓ Benutzer bereits in 'video' Gruppe${NC}"
fi

# Füge User zur input Gruppe hinzu
if ! groups | grep -q input; then
    echo -e "\n${YELLOW}Füge Benutzer zur 'input' Gruppe hinzu...${NC}"
    sudo usermod -aG input "$USER"
    echo -e "${GREEN}✓ Benutzer zur 'input' Gruppe hinzugefügt${NC}"
else
    echo -e "${GREEN}✓ Benutzer bereits in 'input' Gruppe${NC}"
fi

# Erstelle udev Regel
echo -e "\n${CYAN}Erstelle udev Regeln...${NC}"
sudo bash -c 'cat > /etc/udev/rules.d/90-backlight.rules' << 'EOF'
# Allow users in video group to control backlight
ACTION=="add", SUBSYSTEM=="backlight", RUN+="/bin/chgrp video /sys/class/backlight/%k/brightness"
ACTION=="add", SUBSYSTEM=="backlight", RUN+="/bin/chmod g+w /sys/class/backlight/%k/brightness"
EOF

echo -e "${GREEN}✓ udev Regeln erstellt${NC}"

# Lade udev Regeln neu
echo -e "\n${CYAN}Lade udev Regeln neu...${NC}"
sudo udevadm control --reload-rules
sudo udevadm trigger --subsystem-match=backlight

echo -e "${GREEN}✓ udev Regeln neu geladen${NC}"

# Prüfe Backlight Geräte
echo -e "\n${CYAN}Verfügbare Backlight Geräte:${NC}"
if ls /sys/class/backlight/ 2>/dev/null | grep -q .; then
    ls -la /sys/class/backlight/
    
    echo -e "\n${CYAN}Teste Helligkeitssteuerung:${NC}"
    brightnessctl info || echo -e "${YELLOW}Warnung: brightnessctl konnte keine Geräte finden${NC}"
else
    echo -e "${YELLOW}Warnung: Keine Backlight Geräte gefunden${NC}"
    echo -e "${YELLOW}Dies ist normal für Desktop-PCs ohne Bildschirm-Hintergrundbeleuchtung${NC}"
fi

echo -e "\n${CYAN}══════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}Hotfix abgeschlossen!${NC}"
echo -e "${CYAN}══════════════════════════════════════════════════════${NC}\n"

echo -e "${YELLOW}WICHTIG:${NC}"
echo -e "Die Gruppenzugehörigkeit wird erst nach einem Ab- und Neuanmelden aktiv."
echo -e "Optionen:"
echo -e "  1. Ausloggen und wieder einloggen (empfohlen)"
echo -e "  2. Neustart des Systems"
echo -e ""
echo -e "Nach dem Neuanmelden sollten die Fn-Tasten für Helligkeit funktionieren:"
echo -e "  - Fn + F5/F6 (oder entsprechende Tasten auf deinem Laptop)"
echo -e "  - Die Waybar zeigt dann die aktuelle Helligkeit an"
echo ""

read -p "Möchtest du dich jetzt abmelden? (j/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[JjYy]$ ]]; then
    echo -e "${CYAN}Melde ab...${NC}"
    sleep 2
    # Versuche verschiedene Logout-Methoden
    if command -v loginctl &>/dev/null; then
        loginctl terminate-user "$USER"
    elif command -v gnome-session-quit &>/dev/null; then
        gnome-session-quit --logout --no-prompt
    else
        echo -e "${YELLOW}Konnte nicht automatisch abmelden. Bitte manuell abmelden.${NC}"
    fi
else
    echo -e "${CYAN}Bitte melde dich manuell ab, damit die Änderungen wirksam werden.${NC}"
fi
