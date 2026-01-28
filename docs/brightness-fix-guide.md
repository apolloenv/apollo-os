# Helligkeitssteuerung - Fehlerbehebung

## Problem

Die Helligkeitssteuerung über die Funktionstasten (Fn + Brightness Keys) funktioniert nicht, obwohl:
- `brightnessctl` installiert ist
- Die Niri-Konfiguration korrekt eingerichtet ist
- Das Waybar Backlight-Modul konfiguriert ist

## Ursache

Der Benutzer benötigt Mitgliedschaft in der `video` Gruppe, um Zugriff auf die Backlight-Geräte unter `/sys/class/backlight/` zu haben. Dies wurde in der ursprünglichen Installation nicht konfiguriert.

## Lösung

### Für bestehende Installationen (Hotfix)

Führe das Hotfix-Script aus:

```bash
cd /path/to/apollo-os-dev/v0.5.0
./scripts/apollo-os-brightness-fix.sh
```

Das Script führt folgende Schritte aus:

1. **Installiert brightnessctl** (falls nicht vorhanden)
2. **Fügt Benutzer zu Gruppen hinzu**:
   - `video` - für Backlight-Zugriff
   - `input` - für Input-Geräte
3. **Erstellt udev-Regeln** (`/etc/udev/rules.d/90-backlight.rules`):
   ```
   ACTION=="add", SUBSYSTEM=="backlight", RUN+="/bin/chgrp video /sys/class/backlight/%k/brightness"
   ACTION=="add", SUBSYSTEM=="backlight", RUN+="/bin/chmod g+w /sys/class/backlight/%k/brightness"
   ```
4. **Lädt udev-Regeln neu**

**WICHTIG**: Nach dem Hotfix **musst du dich abmelden und wieder anmelden** (oder Neustart), damit die Gruppenzugehörigkeit aktiv wird.

### Für Neuinstallationen

Die Installation wurde aktualisiert und enthält jetzt die Funktion `configure_user_permissions()`, die automatisch:
- Benutzer zur `video` und `input` Gruppe hinzufügt
- udev-Regeln erstellt
- Berechtigungen konfiguriert

Bei einer Neuinstallation ist nach dem ersten Neustart alles korrekt konfiguriert.

## Testen

Nach dem Abmelden und Neuanmelden teste:

1. **Überprüfe Gruppenzugehörigkeit**:
   ```bash
   groups
   # Sollte 'video' und 'input' enthalten
   ```

2. **Teste brightnessctl**:
   ```bash
   brightnessctl info
   # Sollte Backlight-Gerät anzeigen
   
   brightnessctl set 50%
   # Sollte Helligkeit auf 50% setzen
   ```

3. **Teste Funktionstasten**:
   - Drücke Fn + Brightness Up/Down
   - Die Waybar sollte die Änderung anzeigen

## Konfiguration

### Niri Keybindings

In `/home/$USER/.config/niri/config.kdl`:
```kdl
XF86MonBrightnessUp allow-when-locked=true { spawn "brightnessctl" "set" "10%+"; }
XF86MonBrightnessDown allow-when-locked=true { spawn "brightnessctl" "set" "10%-"; }
```

### Waybar Modul

In `/home/$USER/.config/waybar/config`:
```json
"backlight": {
    "format": "{icon}   {percent}%",
    "format-icons": ["󰃞", "󰃟", "󰃠"]
}
```

## Fehlerbehebung

### Keine Backlight-Geräte gefunden

```bash
ls /sys/class/backlight/
```

Wenn leer: Du nutzt wahrscheinlich einen Desktop-PC ohne Laptop-Display. Helligkeitssteuerung ist nur für Laptops relevant.

### Berechtigungen falsch

```bash
ls -la /sys/class/backlight/*/brightness
```

Sollte Gruppenzugriff für `video` zeigen.

### brightnessctl findet keine Geräte

```bash
brightnessctl list
```

Wenn keine Geräte gefunden werden, könnte dein System:
- Einen Desktop-Monitor nutzen (keine Backlight-Steuerung möglich)
- Einen externen Monitor nutzen (nutze Monitor-Tasten stattdessen)
- Ein nicht unterstütztes Backlight-System haben (selten)

## Manuelle Lösung

Falls das Hotfix-Script nicht funktioniert:

```bash
# 1. Installiere brightnessctl
sudo dnf install -y brightnessctl

# 2. Füge Benutzer zu Gruppen hinzu
sudo usermod -aG video $USER
sudo usermod -aG input $USER

# 3. Erstelle udev-Regel
sudo tee /etc/udev/rules.d/90-backlight.rules << 'EOF'
ACTION=="add", SUBSYSTEM=="backlight", RUN+="/bin/chgrp video /sys/class/backlight/%k/brightness"
ACTION=="add", SUBSYSTEM=="backlight", RUN+="/bin/chmod g+w /sys/class/backlight/%k/brightness"
EOF

# 4. Lade udev neu
sudo udevadm control --reload-rules
sudo udevadm trigger --subsystem-match=backlight

# 5. Melde dich ab und wieder an
```

## Status

✅ **Behoben** - Ab v0.5.1
- Hotfix-Script erstellt
- Installation aktualisiert
- Dokumentation hinzugefügt

## Verwandte Dateien

- `/home/$USER/.config/niri/config.kdl` - Tastenbelegung
- `/home/$USER/.config/waybar/config` - Waybar Backlight-Modul
- `/etc/udev/rules.d/90-backlight.rules` - udev-Berechtigungen
- `scripts/apollo-os-brightness-fix.sh` - Hotfix-Script
- `apollo-os-install.sh` - Aktualisiertes Installations-Script
