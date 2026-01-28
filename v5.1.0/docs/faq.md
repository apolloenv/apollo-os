# Apollo OS v0.5.0 - FAQ

**Copyright © 2026 by Manuel Kraibacher**

Häufig gestellte Fragen und Antworten zu Apollo OS.

---

## 🚀 Installation & Setup

### Was ist Apollo OS?
Apollo OS ist ein **Custom Layer** für Fedora 43 Workstation, das das Standard-Gnome durch Niri Window Manager ersetzt. Es bietet ein modernes, scrollbares Tiling-Layout mit GTK Dark Theme und TTS-Integration.

### Kann ich Apollo OS auf anderen Distributionen installieren?
**Nein.** Apollo OS ist speziell für **Fedora 43** entwickelt. Andere Versionen oder Distributionen werden nicht unterstützt.

### Muss ich Fedora neu installieren?
**Empfohlen, aber nicht zwingend.** Apollo OS funktioniert am besten auf einer frischen Fedora 43 Workstation Installation. Bei bestehenden Systemen können Konfigurationskonflikte auftreten.

### Wie lange dauert die Installation?
**15-30 Minuten**, abhängig von:
- Internetgeschwindigkeit (~500 MB Downloads)
- Systemupdates (kann bei älteren Systemen länger dauern)

### Kann ich Apollo OS und Gnome parallel nutzen?
**Nein.** Apollo OS entfernt die Gnome Session vom GDM Login-Screen. Niri ist die einzige verfügbare Session. Gnome kann manuell wiederhergestellt werden (siehe Deinstallation).

---

## 🪟 Niri Window Manager

### Was ist Niri?
Niri ist ein **scrollbarer Tiling Window Manager** für Wayland. Im Gegensatz zu traditionellen Tiling-WMs (i3, Sway) mit festen Layouts, erlaubt Niri horizontales Scrollen durch Workspaces und Fenster.

### Wie unterscheidet sich Niri von Sway/i3?
| Feature | Niri | Sway/i3 |
|---------|------|---------|
| Layout | Scrollbar | Fixed Grid |
| Navigation | Horizontal Scroll | Tab-basiert |
| Komplexität | Einfach | Mittel-Hoch |
| Lernkurve | Flach | Steiler |

### Kann ich zwischen Niri und Sway wechseln?
**Nein.** Apollo OS v0.5.0 installiert **nur Niri**. Sway wurde in v0.4.1 entfernt.

### Wie öffne ich Anwendungen?
- `Super + Space` = Rofi Launcher
- `Super + Return` = Terminal
- `Super + E` = Dateimanager

### Wie schließe ich Fenster?
- `Super + Q` = Fenster schließen
- `Super + Shift + Q` = Fenster sofort beenden (force kill)

---

## 🎨 Design & Themes

### Kann ich zwischen Dark und Light Theme wechseln?
**Ja**, mit `Super + Shift + T` oder:
```bash
~/.local/bin/apollo-os-theme-switcher.sh
```

### Wo finde ich Wallpapers?
**Standard-Wallpapers:** `~/System/Wallpaper/`

**Eigene hinzufügen:**
```bash
cp /path/to/wallpaper.jpg ~/System/Wallpaper/
```

**Wechseln:** `Super + Ctrl + Space`

### Wie ändere ich die Waybar-Farben?
Editiere:
```bash
nano ~/.config/waybar/style.css
```

Nach Änderungen Waybar neu laden:
```bash
killall waybar && waybar &
```

### Kann ich Rofi anpassen?
**Ja.** Editiere:
```bash
nano ~/.config/rofi/config.rasi
```

---

## 🔋 Power Management

### Wie wechsle ich das Power Profile?
**Klick auf das Batterie-Symbol in Waybar** (oben rechts).

**Profile:**
- 🔋 **Power Saver** - Energiesparmodus
- ⚖️ **Balanced** - Ausbalanciert (Standard)
- ⚡ **Performance** - Leistungsmodus

**Manuell über Terminal:**
```bash
powerprofilesctl set power-saver
powerprofilesctl set balanced
powerprofilesctl set performance
```

**Aktuelles Profil anzeigen:**
```bash
powerprofilesctl get
```

### Was macht der Power Saver Modus?
- CPU-Takt wird reduziert
- Display-Helligkeit automatisch angepasst
- Hintergrund-Prozesse eingeschränkt
- Maximale Akkulaufzeit

### Performance Mode - wann verwenden?
Für rechenintensive Aufgaben:
- Video-Rendering
- Kompilieren von Code
- Gaming
- VM/Container-Workloads

**Achtung:** Höherer Stromverbrauch!

---

## 🔆 Brightness Control (Bildschirmhelligkeit)

### Funktionstasten funktionieren nicht - Was tun?

**Symptom:** Fn + Brightness Tasten ändern nichts, Waybar zeigt keine Helligkeit an.

**Lösung:** Führe das Hotfix-Script aus:
```bash
cd /path/to/apollo-os
./scripts/apollo-os-brightness-fix.sh
```

Das Script:
1. Installiert `brightnessctl` (falls nötig)
2. Fügt dich zur `video` Gruppe hinzu
3. Erstellt udev-Regeln für Backlight-Zugriff
4. Bietet automatisches Abmelden an

**Wichtig:** Nach dem Script **musst du dich abmelden und wieder anmelden**!

### Welche Tasten steuern die Helligkeit?

Standard auf den meisten Laptops:
- **Heller:** Fn + F5 oder Fn + →
- **Dunkler:** Fn + F6 oder Fn + ←

Die genauen Tasten variieren je nach Laptop-Hersteller.

### Manuelle Helligkeitssteuerung

Über Terminal:
```bash
# Helligkeit anzeigen
brightnessctl info

# Helligkeit auf 50% setzen
brightnessctl set 50%

# Helligkeit um 10% erhöhen
brightnessctl set 10%+

# Helligkeit um 10% reduzieren
brightnessctl set 10%-
```

### "Keine Backlight-Geräte gefunden"

Dies ist normal für:
- Desktop-PCs (keine integrierte Display-Beleuchtung)
- Externe Monitore (nutze Monitor-Tasten)

Nur Laptops mit integrierten Displays haben Backlight-Steuerung.

### Waybar zeigt keine Helligkeit

Prüfe ob Backlight-Geräte vorhanden sind:
```bash
ls /sys/class/backlight/
```

Wenn leer: Dein System hat keine Backlight-Hardware (siehe oben).

**Weitere Details:** Siehe [docs/BRIGHTNESS_FIX.md](BRIGHTNESS_FIX.md)

---

### Wie funktioniert das TTS-System?
Apollo OS verwendet **Piper TTS** mit der LUNA Voice (British English). Fallback ist espeak-ng.

### Wie teste ich TTS?
```bash
apollo-speak "Hello World"
apollo-speak boot  # Predefined message
```

### TTS funktioniert nicht - was tun?
**1. Prüfe Piper Installation:**
```bash
ls -la ~/.local/share/apollo-os/piper/piper/piper
```

**2. Prüfe Voice Model:**
```bash
ls -la ~/.local/share/apollo-os/voices/luna.onnx
```

**3. Test mit Fallback:**
```bash
espeak-ng -v en-gb "Test"
```

**4. Neuinstallation:**
```bash
rm -rf ~/.local/share/apollo-os/piper
rm -rf ~/.local/share/apollo-os/voices
./scripts/apollo-os-audio-installer.sh  # Manuell ausführen
```

### Kann ich die Voice ändern?
**Ja.** Andere Piper-Voices von: https://rhasspy.github.io/piper-samples/

1. Voice Model herunterladen (.onnx + .json)
2. Nach `~/.local/share/apollo-os/voices/` kopieren
3. `apollo-speak.sh` editieren (Zeile 19: VOICE_MODEL anpassen)

### Warum sind alle TTS-Ansagen auf Englisch?
**Für beste Sprachqualität.** LUNA Voice ist für britisches Englisch optimiert. Deutsche Ausgaben würden unnatürlich klingen. Notifications sind weiterhin in Deutsch/Englisch gemischt.

### Wird TTS auch ohne Niri gestartet?
**Nein.** Das TTS-System startet erst **nach** Niri, Mako und dem Audio-System. Das verhindert:
- Audio-Gerät nicht bereit Fehler
- Fehlende Wayland-Display Probleme
- Race Conditions beim Start

**Start-Reihenfolge:**
1. Niri startet
2. Audio-System (PulseAudio/Pipewire) wird bereit
3. Mako (Notifications) startet
4. 2 Sekunden Wartezeit
5. TTS-Greeting wird ausgegeben
6. Event Monitor startet (für System-Ereignisse)

---

## 📱 Telegram Integration

### Brauche ich Telegram?
**Nein.** Telegram ist **optional** und nur für Benachrichtigungen (z.B. "System gestartet").

### Wie richte ich Telegram ein?
1. Bot erstellen via @BotFather
2. User ID ermitteln via @userinfobot
3. Config editieren:
```bash
nano ~/.config/apollo-os/config.env
```
4. Service neu starten:
```bash
systemctl --user restart apollo-os-notification-handler.service
```

---

## 🔧 Troubleshooting

### Niri startet nicht
**Logs anzeigen:**
```bash
journalctl --user -u niri -b
```

**Zurück zu Gnome:**
```bash
sudo dnf install @gnome-desktop
sudo rm /usr/share/wayland-sessions/niri.desktop
# Neu einloggen → Gnome verfügbar
```

### Waybar fehlt
**Manuell starten:**
```bash
waybar -c ~/.config/waybar/config -s ~/.config/waybar/style.css &
```

**Autostart prüfen:**
```bash
cat ~/.config/niri/apollo-autostart.sh
```

### Rofi öffnet nicht
**Manueller Test:**
```bash
rofi -show drun
```

**Paket prüfen:**
```bash
dnf list installed rofi
```

**Neuinstallation:**
```bash
sudo dnf reinstall rofi
```

### Keine Sounds/TTS
**PulseAudio läuft?**
```bash
systemctl --user status pulseaudio
```

**Audio-Test:**
```bash
paplay /usr/share/sounds/freedesktop/stereo/bell.oga
```

### Keyboard Layout funktioniert nicht
Editiere Niri Config:
```bash
nano ~/.config/niri/config.kdl
```

Ändere Zeile 16:
```kdl
layout "de"  # Oder "us", "gb", etc.
```

Reload:
```bash
niri msg action reload-config
```

---

## 🔄 Updates & Wartung

### Wie update ich Apollo OS?
```bash
cd ~/apollo-os
git pull
# WICHTIG: Backup von Configs erstellen!
cp -r ~/.config/niri ~/.config/niri.backup
./apollo-os-install.sh
```

### Wie update ich Fedora?
```bash
sudo dnf upgrade --refresh
sudo reboot  # Nach Kernel-Updates
```

### Wie update ich nur Niri?
```bash
sudo dnf upgrade niri
```

---

## 🗑️ Deinstallation

### Wie entferne ich Apollo OS?
**Vollständige Anleitung:** Siehe `docs/INSTALLATION.md` → Deinstallation

**Kurzversion:**
```bash
sudo rm /usr/share/wayland-sessions/niri.desktop
sudo dnf install @gnome-desktop
rm -rf ~/.config/niri ~/.config/apollo-os
systemctl --user disable apollo-os-notification-handler.service
```

---

## 📚 Weitere Ressourcen

- **Keybindings:** `docs/KEYBINDINGS.md`
- **Installation:** `docs/INSTALLATION.md`
- **Niri Docs:** https://github.com/YaLTeR/niri
- **GitHub Issues:** https://github.com/apolloenv/apollo-os/issues

---

## 📧 Support

**E-Mail:** aiq@kraibacher.com  
**GitHub:** https://github.com/apolloenv/apollo-os

---

**Made with ❤️ in Austria | Copyright © 2026 Manuel Kraibacher**

### Warum sind alle TTS-Ansagen auf Englisch?
**Für beste Sprachqualität.** LUNA Voice ist für britisches Englisch optimiert. Deutsche Ausgaben würden unnatürlich klingen. Notifications sind weiterhin in Deutsch/Englisch gemischt.

### Wird TTS auch ohne Niri gestartet?
**Nein.** Das TTS-System startet erst **nach** Niri, Mako und dem Audio-System. Das verhindert:
- Audio-Gerät nicht bereit Fehler
- Fehlende Wayland-Display Probleme
- Race Conditions beim Start

**Start-Reihenfolge:**
1. Niri startet
2. Audio-System (PulseAudio/Pipewire) wird bereit
3. Mako (Notifications) startet
4. 2 Sekunden Wartezeit
5. TTS-Greeting wird ausgegeben
6. Event Monitor startet (für System-Ereignisse)

---

### Werden Benutzernamen via TTS angesagt?
**Nein.** Aus Datenschutzgründen werden **keine Benutzernamen** via TTS ausgegeben. Die visuelle Notification zeigt den Namen, aber die Sprachausgabe ist anonym.

**Beispiel:**
- Visual: "Good morning, Manuel!"
- TTS: "Good morning. Welcome to Apollo OS. All systems operational."

