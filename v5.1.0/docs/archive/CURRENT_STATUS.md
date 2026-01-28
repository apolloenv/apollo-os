# Apollo OS v0.4.1 - Aktueller Status & Offene Probleme

**Stand:** 2026-01-13 01:11 Uhr  
**System:** Remote-Test auf 192.168.0.111 (Fedora 43)  
**GitHub:** apolloenv/apollo-os (Commit: 05f6bc1)

---

## ✅ ERFOLGREICH GEFIXT

### 1. Boot-Probleme
- ✅ **Plymouth deaktiviert** (verursachte Kernel-Freeze bei frame buffer device)
  - Services maskiert: plymouth-start, plymouth-quit, plymouth-quit-wait
  - GRUB: `rhgb` Parameter entfernt
- ✅ **Greeter User erstellt** (war nicht vorhanden, Greetd crashed)
  - User: greeter (uid=1001, Gruppe: video, Shell: /sbin/nologin)
- ✅ **Greetd funktioniert** (Login Manager läuft stabil)
- ⚠️ **Cryptsetup Timeout reduziert** (x-systemd.device-timeout=5)
  - Aber: Boot bleibt trotzdem kurz bei frame buffer hängen
  - **Workaround:** Enter drücken → Passwort-Eingabe erscheint
  - **Problem:** Sollte direkt zur Passwort-Eingabe springen ohne Enter

### 2. Niri/Sway Konfiguration
- ✅ **Waybar startet** und zeigt korrekt an
- ✅ **JetBrainsMono Nerd Font installiert** (Icons in Waybar funktionieren)
- ✅ **Wrapper Scripts in /usr/local/bin/** (Greetd hat Zugriff)
- ✅ **Desktop Entries korrigiert**
  - Absolute Pfade: `/usr/local/bin/apollo-os-wrapper-*.sh`
  - Namen: Apollo Orbit (Fluid/Minimal), Apollo Grid (Fluid/Minimal)
- ✅ **Sway Config bereinigt** (omarchy-menu Referenzen entfernt)
- ✅ **Autostart-Script existiert** (~/.config/niri/apollo-autostart.sh)
- ✅ **Autostart in Niri Configs integriert** (spawn-at-startup)

### 3. Services & Komponenten
- ✅ Waybar läuft mit korrekten Configs
- ✅ Mako notification daemon
- ✅ Wallpaper (swaybg)
- ✅ Network Manager Applet
- ✅ Bluetooth Applet

---

## ❌ OFFENE PROBLEME

### **HAUPTPROBLEM: GTK Dark Theme funktioniert nicht in Niri**

**Symptom:**
- Gnome-Anwendungen (Nautilus, etc.) werden in **hellem Theme** angezeigt
- In **Sway funktioniert Dark Theme** ✅
- In **Niri (PRO und MOD) funktioniert es NICHT** ❌

**Was bereits versucht wurde:**

1. **Autostart-Script mit gsettings**
   ```bash
   gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark'
   gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
   ```
   - Script ist vorhanden: `~/.config/niri/apollo-autostart.sh`
   - Script ist ausführbar (chmod +x)
   - Script ist in Niri Config: `spawn-at-startup "/home/apollo/.config/niri/apollo-autostart.sh"`
   - **Problem:** gsettings wird nicht korrekt ausgeführt oder hat keinen Effekt

2. **DBUS Session Bus explizit gesetzt**
   ```bash
   export DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$(id -u)/bus
   ```
   - Hinzugefügt im Autostart-Script
   - **Problem:** Hat keinen Effekt

3. **Direktes Setzen via SSH**
   ```bash
   gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark'
   ```
   - Wird ohne Fehler ausgeführt
   - **Problem:** Hat trotzdem keinen visuellen Effekt

4. **Environment Variables aus Wrapper**
   ```bash
   export APOLLO_THEME="dark"
   ```
   - Wrapper setzt Variablen
   - **Problem:** Niri's spawn-at-startup sieht diese nicht

**Warum funktioniert es in Sway?**
- Sway hat vermutlich ein anderes Exec-Modell
- Möglicherweise wird gsettings dort früher/anders ausgeführt
- Oder Sway leitet die Environment richtig weiter

**Technische Details:**
```bash
# Prozesse beim Start:
apollo  2194  niri --config /home/apollo/.config/niri/apollo-os-config-pro.kdl
apollo  2250  [waybar] <defunct>  # Zombie-Prozess!
apollo  2341  waybar -c /home/apollo/.config/waybar/apollo-os-config-niri-pro

# Autostart-Script läuft NICHT im Journal:
journalctl --user -b | grep apollo-autostart
# → Kein Output

# GSetting aktuell:
gsettings get org.gnome.desktop.interface gtk-theme
# → Vermutlich 'Adwaita' statt 'Adwaita-dark'
```

---

## 🔧 MÖGLICHE LÖSUNGSANSÄTZE

### Ansatz 1: GTK Theme über Environment Variable
```bash
export GTK_THEME=Adwaita:dark
```
- In Wrapper setzen BEVOR Niri startet
- Oder in Niri Config: `environment { GTK_THEME "Adwaita:dark" }`

### Ansatz 2: XDG Desktop Portal
```bash
dbus-send --session --dest=org.freedesktop.portal.Desktop \
  /org/freedesktop/portal/desktop \
  org.freedesktop.portal.Settings.Read \
  string:org.freedesktop.appearance string:color-scheme
```
- Portal korrekt konfigurieren
- xdg-desktop-portal-gtk installieren

### Ansatz 3: Autostart über systemd user service
```ini
[Unit]
Description=Apollo OS GTK Theme Setter
After=graphical-session.target

[Service]
Type=oneshot
ExecStart=/home/apollo/.config/niri/set-gtk-theme.sh
Environment=DISPLAY=:0

[Install]
WantedBy=graphical-session.target
```
- systemd --user service statt spawn-at-startup
- Hat Zugriff auf DBUS Session

### Ansatz 4: Niri Config direkt
Prüfen ob Niri eigene Theme-Settings hat:
```kdl
// Irgendwo in config.kdl
prefer-dark-theme true
```

### Ansatz 5: .gtkrc-2.0 und settings.ini
Statische Konfiguration:
```ini
# ~/.config/gtk-3.0/settings.ini
[Settings]
gtk-application-prefer-dark-theme=1
gtk-theme-name=Adwaita-dark
```

---

## 📁 WICHTIGE DATEIEN

### Installer
- `/home/apollo/AIQSAN01/apollo/apollo-os-dev/v0.4.1/apollo-os-install.sh`
  - Alle Fixes integriert
  - Zeile 262-304: Font Installation (inkl. Nerd Font)
  - Zeile 683-707: Greeter User + Plymouth Deaktivierung
  - Zeile 429-442: Niri Config Deployment + Autostart Integration

### Remote System (192.168.0.111)
- `/home/apollo/.config/niri/apollo-autostart.sh` - Autostart Script
- `/home/apollo/.config/niri/apollo-os-config-pro.kdl` - Niri Config (PRO)
- `/home/apollo/.config/niri/apollo-os-config-mod.kdl` - Niri Config (MOD)
- `/usr/local/bin/apollo-os-wrapper-niri.sh` - Niri Wrapper
- `/usr/local/bin/apollo-os-wrapper-sway.sh` - Sway Wrapper
- `/etc/crypttab` - Cryptsetup Config (Timeout: 5s)
- `/etc/default/grub` - GRUB Config (rhgb entfernt)

### Configs
```bash
# Niri Autostart (Zeile 132 in beiden Configs):
spawn-at-startup "/home/apollo/.config/niri/apollo-autostart.sh"

# Environment Variables (sollten vom Wrapper kommen):
APOLLO_PROFILE=pro
APOLLO_THEME=dark
APOLLO_WM=niri
```

---

## 🐛 BEKANNTE BUGS

1. **Waybar Zombie-Prozess**
   - Beim Start entsteht ein Zombie-Prozess von Waybar
   - Waybar startet danach nochmal und funktioniert
   - Ursache unklar

2. **Boot-Pause bei frame buffer device**
   - Trotz Timeout-Reduktion bleibt Boot kurz hängen
   - Enter überspringt es → Cryptsetup Prompt erscheint
   - Sollte direkt zum Prompt springen

3. **spawn-at-startup läuft nicht zuverlässig**
   - Autostart-Script erscheint nicht im Journal
   - Waybar startet trotzdem (vermutlich doppelt)
   - Unklar ob Script überhaupt ausgeführt wird

---

## 📊 TEST-MATRIX

| Feature | Niri PRO | Niri MOD | Sway PRO | Sway MOD |
|---------|----------|----------|----------|----------|
| Waybar | ✅ | ✅ | ✅ | ✅ |
| Mako | ✅ | ✅ | ✅ | ✅ |
| Wallpaper | ✅ | ✅ | ✅ | ✅ |
| Nerd Font Icons | ✅ | ✅ | ✅ | ✅ |
| GTK Dark Theme | ❌ | ❌ | ✅ | ✅ |
| Boot ohne Freeze | ✅ | ✅ | ✅ | ✅ |

---

## 💡 EMPFEHLUNG FÜR NÄCHSTES LLM

**Fokus:** GTK Dark Theme in Niri zum Laufen bringen

**Debugging-Schritte:**
1. Prüfe ob `gsettings` in Niri-Session überhaupt funktioniert
2. Checke `echo $DBUS_SESSION_BUS_ADDRESS` in laufender Niri-Session
3. Teste manuell: `gsettings get/set org.gnome.desktop.interface gtk-theme`
4. Prüfe ob `~/.config/gtk-3.0/settings.ini` existiert und wirkt
5. Checke `xdg-desktop-portal` Logs: `journalctl --user -u xdg-desktop-portal`
6. Vergleiche Environment von Sway vs Niri: `printenv | sort`

**Alternative Ansätze:**
- Systemd user service statt spawn-at-startup
- GTK_THEME Environment Variable
- Statische GTK Config Files
- Niri's eigene Theme-Settings (falls vorhanden)

**System-Zugang:**
- SSH: `ssh apollo@192.168.0.111` (Passwort: 008490)
- GitHub: apolloenv/apollo-os (Commit: 05f6bc1)
- Lokaler Dev: `/home/apollo/AIQSAN01/apollo/apollo-os-dev/v0.4.1/`

---

## 📝 SESSION NOTES

**Was funktioniert:**
- Greetd Login ✅
- Session-Auswahl ✅
- Niri/Sway starten ✅
- Waybar mit Icons ✅
- Alle Keybindings ✅
- Wallpaper ✅
- Notifications ✅

**Was nicht funktioniert:**
- GTK Dark Theme in Niri ❌
- Boot direkt zur Cryptsetup-Eingabe ❌

**Kritikalität:**
- Boot-Issue: **MINOR** (Workaround: Enter drücken)
- GTK Theme: **MAJOR** (Benutzer-Experience stark beeinträchtigt)

---

**Viel Erfolg!** 🚀
