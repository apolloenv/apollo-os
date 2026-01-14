# Boot Splash Konfiguration

Apollo OS bietet zwei verschiedene Boot-Splash Optionen:

## Option 1: ASCII Boot Splash (Standard)

**Script:** `scripts/apollo-os-boot-splash-installer.sh`

### Was macht es?
- ✅ Entfernt Plymouth komplett
- ✅ Zeigt ASCII-Logo beim Boot
- ✅ Verbose Boot (alle Boot-Nachrichten sichtbar)
- ✅ Schnellerer Boot-Prozess
- ✅ Minimal und techie

### Installation
```bash
cd ~/apollo-os-dev/v0.5.0
sudo ./scripts/apollo-os-boot-splash-installer.sh
```

### Vorteile
- Sieht "hacker-like" aus
- Zeigt alle Boot-Nachrichten
- Kein Plymouth-Overhead
- Einfach zu debuggen

### Nachteile
- Kein graphischer Splash
- Kann überwältigend wirken für normale User

---

## Option 2: Plymouth mit Apollo OS Watermark (NEU)

**Script:** `scripts/apollo-os-plymouth-installer.sh`

### Was macht es?
- ✅ Installiert/behält Plymouth
- ✅ Kopiert Apollo OS Watermark nach `/usr/share/plymouth/themes/spinner/`
- ✅ Setzt Fedora Spinner Theme als Standard
- ✅ Graphischer Boot-Splash mit Apollo Branding
- ✅ Optionally: Kann verbose bleiben oder quiet sein

### Installation
```bash
cd ~/apollo-os-dev/v0.5.0
sudo ./scripts/apollo-os-plymouth-installer.sh
```

### Was passiert?
1. **Plymouth Installation prüfen/installieren**
   - Installiert Plymouth falls nicht vorhanden
   - Installiert Spinner Theme

2. **Watermark kopieren**
   - Original wird gebackupt: `watermark.png.backup.YYYYMMDD`
   - Apollo OS Logo wird kopiert: `assets/spinner/APOLLO OS.png` → `/usr/share/plymouth/themes/spinner/watermark.png`
   - Berechtigungen: `root:root 644`

3. **Theme setzen**
   - `plymouth-set-default-theme spinner`

4. **initramfs rebuilden**
   - `dracut -f` (baut initramfs mit neuem Plymouth neu)

5. **GRUB updaten**
   - Fügt `splash` Parameter zu GRUB_CMDLINE_LINUX hinzu
   - Backup: `/etc/default/grub.backup.plymouth.YYYYMMDD`
   - Regeneriert GRUB config

### Vorteile
- Professioneller Look
- Apollo OS Branding
- User-freundlicher
- Standard für die meisten Linux-Distros

### Nachteile
- Etwas langsamerer Boot
- Plymouth-Overhead
- Boot-Nachrichten versteckt (außer bei Fehlern)

---

## Vergleich

| Feature | ASCII Splash | Plymouth Watermark |
|---------|--------------|-------------------|
| **Boot-Nachrichten** | Voll sichtbar | Versteckt (außer Fehler) |
| **Look** | Terminal/Hacker | Professionell |
| **Performance** | Schneller | Minimal langsamer |
| **Branding** | ASCII Logo | Graphisches Logo |
| **User-Freundlichkeit** | Techie | Mainstream |
| **Debugging** | Einfacher | Schwieriger |

---

## Wechseln zwischen den Modi

### Von ASCII zu Plymouth wechseln

```bash
cd ~/apollo-os-dev/v0.5.0
sudo ./scripts/apollo-os-plymouth-installer.sh
sudo reboot
```

Plymouth-Installer:
- Installiert Plymouth automatisch
- Kopiert Watermark
- Konfiguriert alles

### Von Plymouth zu ASCII wechseln

```bash
cd ~/apollo-os-dev/v0.5.0
sudo ./scripts/apollo-os-boot-splash-installer.sh
sudo reboot
```

ASCII-Boot-Splash-Installer:
- Entfernt Plymouth
- Installiert ASCII-Splash-Service
- Aktiviert verbose Boot

---

## Überprüfung

### Plymouth Status prüfen

```bash
# Ist Plymouth installiert?
rpm -q plymouth

# Welches Theme ist aktiv?
plymouth-set-default-theme

# Watermark vorhanden?
ls -lh /usr/share/plymouth/themes/spinner/watermark.png

# Plymouth während Boot testen (VORSICHT - startet Display Manager neu!)
sudo plymouthd --debug
sudo plymouth show-splash
sleep 3
sudo plymouth quit
```

### ASCII Splash Status prüfen

```bash
# Service Status
systemctl status apollo-boot-splash.service

# Logo vorhanden?
cat /usr/share/apollo-os/boot-logo.txt

# GRUB Konfiguration
grep GRUB_CMDLINE_LINUX /etc/default/grub
# Sollte KEINE "quiet" oder "splash" haben
```

---

## Fehlerbehebung

### Plymouth zeigt Watermark nicht

**Problem:** Plymouth läuft, aber zeigt Standard-Fedora Logo

**Lösung:**
```bash
# Prüfe ob Datei existiert
ls -la /usr/share/plymouth/themes/spinner/watermark.png

# Falls nicht, kopiere nochmal
cd ~/apollo-os-dev/v0.5.0
sudo cp "assets/spinner/APOLLO OS.png" \
    /usr/share/plymouth/themes/spinner/watermark.png

# Rebuild initramfs
sudo dracut -f

# Reboot
sudo reboot
```

### ASCII Splash funktioniert nicht

**Problem:** Normaler Boot ohne ASCII Logo

**Lösung:**
```bash
# Service Status prüfen
systemctl status apollo-boot-splash.service

# Service neu aktivieren
sudo systemctl enable apollo-boot-splash.service
sudo systemctl daemon-reload

# GRUB prüfen
grep "quiet\|splash" /etc/default/grub
# Falls vorhanden, entfernen und GRUB neu generieren

# Reboot
sudo reboot
```

### Schwarzer Bildschirm beim Boot

**Problem:** Plymouth hängt oder zeigt nichts

**Lösung:**
```bash
# Boot in Recovery Mode
# Im GRUB: 'e' drücken, 'splash' entfernen, boot mit Ctrl+X

# Dann Plymouth entfernen
sudo dnf remove plymouth
sudo dracut -f
sudo reboot
```

---

## Dateien & Pfade

### Plymouth
- **Watermark Source:** `assets/spinner/APOLLO OS.png`
- **Watermark Target:** `/usr/share/plymouth/themes/spinner/watermark.png`
- **Theme Directory:** `/usr/share/plymouth/themes/spinner/`
- **Config:** `/etc/default/grub` (splash parameter)
- **Installer:** `scripts/apollo-os-plymouth-installer.sh`

### ASCII Splash
- **Logo Source:** `assets/apollo-os-boot-logo.txt`
- **Logo Target:** `/usr/share/apollo-os/boot-logo.txt`
- **Service:** `/etc/systemd/system/apollo-boot-splash.service`
- **Config:** `/etc/default/grub` (NO quiet/splash)
- **Installer:** `scripts/apollo-os-boot-splash-installer.sh`

---

## Empfehlung

**Für Produktionsumgebung / normale User:**
→ **Plymouth mit Watermark** (`apollo-os-plymouth-installer.sh`)
- Professioneller
- User-freundlicher
- Standard-Verhalten

**Für Entwicklung / Tech-Enthusiasten:**
→ **ASCII Splash** (`apollo-os-boot-splash-installer.sh`)
- Debugging-freundlich
- Zeigt alle Meldungen
- Minimaler

---

**Apollo OS v0.5.1** - Copyright 2025 by Manuel Kraibacher
