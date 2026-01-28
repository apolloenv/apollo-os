# Apollo OS v5.1.2 - Visual Themes & GTK Fixes

## Probleme behoben:

### 1. ✅ GTK_THEME fehlt in allen Visual Mode Configs
**Problem**: Einige Visual Modes zeigten altes Adwaita Design  
**Ursache**: GTK_THEME und ADW_DEBUG_COLOR_SCHEME fehlten in environment{}  
**Fix**: 
- Alle 16 Visual Mode Configs updated (visual-modes/configs/*.kdl)
- Alle 7 Base Configs updated (base-config/niri/*.kdl)
- GTK_THEME "adw-gtk3-dark" hinzugefügt
- ADW_DEBUG_COLOR_SCHEME "prefer-dark" hinzugefügt

**Ergebnis**: Alle Visual Modes verwenden jetzt konsistent das neue Adwaita Design

### 2. ✅ Doppelte spawn-at-startup Einträge entfernt
**Problem**: Potenzielle doppelte Prozess-Starts  
**Ursache**: waybar, mako, monitor-scripts waren in config.kdl UND apollo-autostart.sh  
**Fix**:
- waybar spawn aus allen Visual Mode Configs entfernt
- mako spawn aus allen Visual Mode Configs entfernt
- power-monitor, network-monitor, sleep-monitor spawns entfernt
- welcome-tts spawn entfernt

**Verbleibende spawns** (korrekt):
- xwayland-satellite
- swaybg (Wallpaper)
- nm-applet
- blueman-applet  
- polkit-gnome-authentication-agent
- swayidle
- notify-send (System ready)

**Ergebnis**: apollo-autostart.sh startet waybar/mako mit Duplicate-Checks

### 3. ⚠️ Doppelte App-Starts aus Rofi
**Status**: Ursache noch unklar
**Vermutung**: Möglicherweise ein Rofi oder GTK-Portal Problem
**Zu testen**: 
- Welche Apps öffnen sich doppelt?
- Passiert es bei ALLEN Apps oder nur bestimmten?
- Logs prüfen: `journalctl --user -f` während App-Start

## Geänderte Dateien:

**Visual Modes (16 Configs):**
- apollo-os-orbit/visual-modes/configs/config-classic.kdl
- apollo-os-orbit/visual-modes/configs/config-developer.kdl
- apollo-os-orbit/visual-modes/configs/config-enterprise.kdl
- apollo-os-orbit/visual-modes/configs/config-i3.kdl
- apollo-os-orbit/visual-modes/configs/config-i3-retro.kdl
- apollo-os-orbit/visual-modes/configs/config-i3-contrast.kdl
- apollo-os-orbit/visual-modes/configs/config-macos.kdl
- apollo-os-orbit/visual-modes/configs/config-minimal.kdl
- apollo-os-orbit/visual-modes/configs/config-modern.kdl
- apollo-os-orbit/visual-modes/configs/config-nova.kdl
- apollo-os-orbit/visual-modes/configs/config-orbit.kdl
- apollo-os-orbit/visual-modes/configs/config-professional.kdl
- apollo-os-orbit/visual-modes/configs/config-professional-next.kdl
- apollo-os-orbit/visual-modes/configs/config-professional-plus.kdl
- apollo-os-orbit/visual-modes/configs/config-sgi.kdl
- apollo-os-orbit/visual-modes/configs/config-tech-blue.kdl

**Base Configs (7 Configs):**
- apollo-os-orbit/base-config/niri/config.kdl
- apollo-os-orbit/base-config/niri/config-classic.kdl
- apollo-os-orbit/base-config/niri/config-developer.kdl
- apollo-os-orbit/base-config/niri/config-modern.kdl
- apollo-os-orbit/base-config/niri/config-orbit.kdl
- apollo-os-orbit/base-config/niri/config-professional.kdl
- apollo-os-orbit/base-config/niri/config-tech-blue.kdl

## Nächste Schritte:

1. Installation auf Remote-Rechner durchführen
2. Alle Visual Modes testen - sollten jetzt konsistentes Adwaita Design haben
3. App-Start aus Rofi testen - welche Apps öffnen sich doppelt?
4. Falls Problem bestehen bleibt: Detaillierte Info welche Apps betroffen sind

