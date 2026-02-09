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
cd ~/apollo-os-dev/apollo-os-v0600
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

## Option 2: Apollo OS Watermark für Plymouth

**Info:** Das Apollo OS Watermark wird automatisch während der Installation nach `/usr/share/plymouth/themes/spinner/watermark.png` kopiert, falls das Plymouth Spinner Theme vorhanden ist.

### Automatische Installation
Das Watermark wird im Hauptinstaller (`apollo-os-install.sh`) automatisch installiert:
- ✅ Prüft ob Plymouth Spinner Theme vorhanden ist
- ✅ Kopiert `assets/spinner/watermark.png` nach `/usr/share/plymouth/themes/spinner/`
- ✅ Setzt korrekte Berechtigungen (`root:root 644`)
- ✅ Erstellt Backup falls bereits vorhanden

### Manuelle Installation (Hotfix)

**Script:** `scripts/apollo-os-watermark-installer.sh`

Falls das Watermark nicht während der Installation kopiert wurde (z.B. Plymouth wurde nachträglich installiert):

```bash
cd ~/apollo-os-dev/apollo-os-v0600
./scripts/apollo-os-watermark-installer.sh
```

### Was macht es?
- Kopiert nur das Watermark-File
- Ändert KEINE Plymouth-Konfiguration
- Ändert KEINE Bootloader-Einstellungen
- Erstellt Backup falls Watermark bereits existiert

### Hinweis
Das Watermark wird nur kopiert, wenn Plymouth installiert ist und das Spinner-Theme verwendet wird. Es ändert nichts an deiner aktuellen Boot-Konfiguration.

---

## Vergleich

| Feature | ASCII Splash | Standard (mit Watermark) |
|---------|--------------|--------------------------|
| **Boot-Nachrichten** | Voll sichtbar | Je nach Plymouth-Config |
| **Look** | Terminal/Hacker | Abhängig von Plymouth |
| **Performance** | Schneller | Abhängig von Plymouth |
| **Branding** | ASCII Logo | Watermark wenn Plymouth aktiv |
| **User-Freundlichkeit** | Techie | Standard |
| **Debugging** | Einfacher | Schwieriger |

---

## Wechseln zwischen den Modi

### Von Standard zu ASCII wechseln

```bash
cd ~/apollo-os-dev/apollo-os-v0600
sudo ./scripts/apollo-os-boot-splash-installer.sh
sudo reboot
```

ASCII-Boot-Splash-Installer:
- Entfernt Plymouth
- Installiert ASCII-Splash-Service
- Aktiviert verbose Boot

### Watermark nachträglich installieren

Falls Plymouth später installiert wurde:

```bash
cd ~/apollo-os-dev/apollo-os-v0600
./scripts/apollo-os-watermark-installer.sh
```

---

## Überprüfung

### Watermark prüfen

```bash
# Ist Watermark vorhanden?
ls -lh /usr/share/plymouth/themes/spinner/watermark.png

# Plymouth Status (falls installiert)
rpm -q plymouth

# Welches Theme ist aktiv? (falls Plymouth aktiv)
plymouth-set-default-theme
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

### Watermark nachträglich installieren

**Problem:** Plymouth wurde nach Apollo OS installiert

**Lösung:**
```bash
cd ~/apollo-os-dev/apollo-os-v0600
./scripts/apollo-os-watermark-installer.sh
```

Das Script:
- Prüft ob Watermark-Source vorhanden ist
- Prüft ob Plymouth Spinner Theme existiert
- Kopiert Watermark mit korrekten Berechtigungen
- Erstellt Backup falls bereits vorhanden

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

---

## Dateien & Pfade

### Watermark
- **Source:** `assets/spinner/watermark.png`
- **Target:** `/usr/share/plymouth/themes/spinner/watermark.png`
- **Installer:** `scripts/apollo-os-watermark-installer.sh`
- **Installation:** Automatisch während Hauptinstallation wenn Plymouth vorhanden

### ASCII Splash
- **Logo Source:** `assets/apollo-os-boot-logo.txt`
- **Logo Target:** `/usr/share/apollo-os/boot-logo.txt`
- **Service:** `/etc/systemd/system/apollo-boot-splash.service`
- **Config:** `/etc/default/grub` (NO quiet/splash)
- **Installer:** `scripts/apollo-os-boot-splash-installer.sh`

---

## Empfehlung

**Für Standard-Installation:**
→ **Standard (Plymouth mit Watermark)** wenn Plymouth vorhanden
- Watermark wird automatisch installiert
- Keine zusätzliche Konfiguration nötig
- Standard-Plymouth-Verhalten bleibt erhalten

**Für Entwicklung / Tech-Enthusiasten:**
→ **ASCII Splash** (`apollo-os-boot-splash-installer.sh`)
- Debugging-freundlich
- Zeigt alle Meldungen
- Minimaler
- Entfernt Plymouth komplett

---

**Apollo OS v0.5.2** - Copyright 2025 by Manuel Kraibacher
