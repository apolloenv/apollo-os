# Apollo OS v5.1.1 - Installation Fixes

## Probleme auf neuem Rechner identifiziert:

### 1. ✅ Kitty Terminal Config fehlt (Niri)
**Problem**: Kitty wurde nur für Hyprland konfiguriert, nicht für Niri
**Fix**: 
- Kitty Config zu `apollo-os-sys/config/kitty/kitty.conf` hinzugefügt
- Installer kopiert jetzt Kitty Config auch bei Niri-Installation
- JetBrains Mono Nerd Font, Beam Cursor, Fish Shell

### 2. ✅ Foot Terminal Config fehlt
**Problem**: Foot Terminal hatte keine Konfiguration
**Fix**:
- Foot Config zu `apollo-os-sys/config/foot/foot.ini` hinzugefügt  
- Installer kopiert jetzt Foot Config bei Niri-Installation
- JetBrains Mono Nerd Font, 25x25 Padding, Fish Shell

### 3. ✅ Screen-corners fehlt (abgerundete Ecken)
**Problem**: screen-corners.py Script und Service fehlten komplett
**Fix**:
- Script zu `apollo-os-sys/scripts/screen-corners/screen-corners.py` hinzugefügt
- Systemd Service `screen-corners.service` erstellt
- Installer installiert jetzt automatisch Screen-corners

### 4. ✅ SDDM Wallpaper
**Problem**: Standard-Wallpaper statt gewünschtes Black Dots
**Fix**:
- Basic-Black-Dots.jpg wird jetzt als SDDM Hintergrund gesetzt
- Installer konfiguriert SDDM Breeze Theme automatisch
- Wallpaper nach `/usr/share/wallpapers/apollo-os/sddm-background.jpg`

### 5. ⚠️ Visual Mode Wechsel (TODO - User muss testen)
**Status**: Alle Dateien vorhanden, Installer kopiert sie
**Zu prüfen**:
- Sind alle 16 Niri Configs installiert? (`~/.config/niri/config-*.kdl`)
- Sind alle Waybar Configs installiert? (`~/.config/waybar/config-niri-*`)
- Sind alle Waybar Styles installiert? (`~/.config/waybar/style-*.css`)
- Funktioniert `apollo-os-visual-mode.sh` Script?

### 6. ⚠️ Right Ctrl Push-to-Talk (TODO - User muss testen)
**Status**: Service läuft, Script vorhanden
**Zu prüfen**:
- Läuft `apollo-rightctrl-voice.service`?
- Ist User in `input` Gruppe? (`groups | grep input`)
- Existiert `~/.local/bin/voice-input`?
- Sind Sound-Dateien vorhanden? (`~/.local/share/apollo-os/sounds/voice-*.wav`)

## Installer Änderungen (apollo-os-install.sh):

1. **Zeile 1045+**: Kitty Config Deployment für Niri
2. **Zeile 1053+**: Foot Config Deployment für Niri  
3. **Zeile 1509+**: Screen-corners Installation in setup_systemd()
4. **Zeile 2129+**: SDDM Wallpaper Konfiguration

## Nächste Schritte:

1. User soll Installation erneut durchführen
2. Prüfen ob alle Probleme behoben sind
3. Falls Visual Mode / Right Ctrl noch nicht funktioniert:
   - Logs prüfen: `journalctl --user -u apollo-rightctrl-voice -f`
   - Manuell testen: `~/.local/bin/apollo-os-visual-mode.sh modern`
   - Permissions prüfen: `groups`, `ls -la ~/.local/bin/voice-*`

