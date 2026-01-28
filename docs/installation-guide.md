# Apollo OS v0.5.0 - Installation Guide

**Copyright © 2026 by Manuel Kraibacher**

---

## 📋 Systemvoraussetzungen

- **Betriebssystem:** Fedora 43 Workstation (frische Installation empfohlen)
- **Hardware:** x86_64 Architektur
- **RAM:** Mindestens 4 GB (8 GB empfohlen)
- **Festplatte:** Mindestens 20 GB freier Speicher
- **Internet:** Stabile Verbindung für Package-Downloads (~500 MB)

---

## 🚀 Installation

### 1. Repository klonen

```bash
cd ~
git clone https://github.com/apolloenv/apollo-os.git
cd apollo-os
```

**Alternative:** ZIP-Download von GitHub

```bash
wget https://github.com/apolloenv/apollo-os/archive/refs/heads/main.zip
unzip main.zip
cd apollo-os-main
```

---

### 2. Installer ausführen

```bash
chmod +x apollo-os-install.sh
./apollo-os-install.sh
```

**Installationszeit:** ca. 15-30 Minuten (abhängig von Internetgeschwindigkeit)

---

### 3. Konfiguration während Installation

Der Installer fragt folgende Informationen ab:

#### Telegram Bot (Optional)
- **Bot Token:** Von @BotFather auf Telegram
- **User ID:** Deine Telegram User ID

**Überspringen:** Einfach Enter drücken, kann später konfiguriert werden.

---

### 4. Was wird installiert?

#### Window Manager & Wayland
- Niri (Scrollable Tiling Window Manager)
- Waybar (Status-Bar)
- Rofi (Application Launcher)
- Mako (Notification Daemon)

#### System Tools
- grim, slurp (Screenshots)
- swaylock, swayidle (Lock & Idle Management)
- swaybg (Wallpaper)
- wl-clipboard (Clipboard Manager)
- NetworkManager, Blueman
- brightnessctl, playerctl
- **power-profiles-daemon** (Power Profile Management)

#### Audio & TTS
- Piper TTS (LUNA Voice - British English)
- espeak-ng (Fallback)
- PulseAudio/ALSA Utilities

#### Terminal Emulators
- Alacritty (Standard)
- Kitty (Alternative)

#### Fonts
- JetBrainsMono Nerd Font (mit Icons)
- Noto Emoji
- FontAwesome
- Fira Code

---

### 5. Nach der Installation

#### Session auswählen
1. **Logout** von aktueller Session
2. Am GDM Login-Screen erscheint nur **"Apollo OS"**
3. Passwort eingeben → Niri startet automatisch

#### Erste Schritte
- **Super + Space:** Rofi Launcher öffnen
- **Super + Shift + Space:** Quick Menu
- **Super + Return:** Terminal öffnen
- **Super + Shift + ?:** Keybindings anzeigen
- **Klick auf Batterie:** Power Profile wechseln

---

## ⚙️ Post-Installation Konfiguration

### Telegram Integration

Editiere die Config-Datei:
```bash
nano ~/.config/apollo-os/config.env
```

Füge hinzu:
```bash
TELEGRAM_BOT_TOKEN="YOUR_BOT_TOKEN"
TELEGRAM_USER_ID="YOUR_USER_ID"
```

Starte den Notification Handler neu:
```bash
systemctl --user restart apollo-os-notification-handler.service
```

---

### Boot Splash (Optional)

Installiere das Apollo OS Boot Theme:
```bash
sudo ~/.local/bin/apollo-os-boot-splash-installer.sh
```

**WICHTIG:** Erstellt Plymouth Theme mit Apollo OS Wasserzeichen.

---

### Wallpapers hinzufügen

Eigene Wallpapers nach `~/System/Wallpaper/` kopieren:
```bash
cp /path/to/your/wallpaper.jpg ~/System/Wallpaper/
```

Wallpaper-Cycling aktivieren:
```bash
Super + Ctrl + Space  # Nächstes Wallpaper
```

---

## 🔧 Troubleshooting

### Problem: Niri startet nicht

**Lösung 1:** Prüfe Logs
```bash
journalctl --user -u niri -b
```

**Lösung 2:** Zurück zu Gnome
```bash
# Am GDM Login-Screen:
# Klicke auf ⚙️ → "GNOME" auswählen
```

---

### Problem: Waybar wird nicht angezeigt

**Lösung:** Starte Waybar manuell
```bash
waybar -c ~/.config/waybar/config -s ~/.config/waybar/style.css &
```

Prüfe Config:
```bash
cat ~/.config/waybar/config
```

---

### Problem: TTS (apollo-speak) funktioniert nicht

**Prüfe Installation:**
```bash
ls -la ~/.local/share/apollo-os/piper/piper/piper
ls -la ~/.local/share/apollo-os/voices/luna.onnx
```

**Test mit espeak-ng (Fallback):**
```bash
espeak-ng -v en-gb "Test message"
```

---

### Problem: Rofi öffnet nicht

**Test manuell:**
```bash
rofi -show drun
```

**Prüfe Theme:**
```bash
ls -la ~/.config/rofi/config.rasi
```

---

## 🔄 Updates

### Apollo OS Update
```bash
cd ~/apollo-os
git pull
./apollo-os-install.sh  # Überschreibt Configs - Backup erstellen!
```

### System Updates
```bash
sudo dnf upgrade --refresh
```

**WICHTIG:** Nach Kernel-Updates neustarten!

---

## 🗑️ Deinstallation

### Apollo OS entfernen (Fedora Gnome wiederherstellen)

```bash
# 1. Niri Session entfernen
sudo rm /usr/share/wayland-sessions/niri.desktop

# 2. Gnome wiederherstellen
sudo dnf install @gnome-desktop

# 3. Configs löschen (optional)
rm -rf ~/.config/niri ~/.config/waybar ~/.config/mako ~/.config/rofi
rm -rf ~/.config/apollo-os
rm -rf ~/.local/share/apollo-os

# 4. Scripts entfernen
rm ~/.local/bin/apollo-*
sudo rm /usr/local/bin/apollo-os-wrapper-niri.sh

# 5. Systemd Services deaktivieren
systemctl --user disable apollo-os-notification-handler.service
```

---

## 📞 Support

- **GitHub Issues:** https://github.com/apolloenv/apollo-os/issues
- **E-Mail:** aiq@kraibacher.com
- **Dokumentation:** `~/apollo-os/docs/`

---

**Made with ❤️ in Austria | Powered by Niri 🪟**
