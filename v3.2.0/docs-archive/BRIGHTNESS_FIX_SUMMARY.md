# Apollo OS v0.5.1 - Brightness Fix Summary

**Datum:** 2026-01-14  
**Problem:** Helligkeitssteuerung funktionierte nicht  
**Status:** ✅ BEHOBEN

---

## Problem-Analyse

### Symptome
- Funktionstasten (Fn + Brightness) änderten die Helligkeit nicht
- Waybar Backlight-Modul zeigte zwar Prozent an, aber Änderungen wirkten sich nicht aus
- `brightnessctl` war installiert, hatte aber keine Berechtigungen

### Root Cause
1. **Fehlende Gruppenzugehörigkeit**: Benutzer war nicht in der `video` Gruppe
2. **Fehlende udev-Regeln**: Keine automatischen Berechtigungen für `/sys/class/backlight/*/brightness`
3. **Installation unvollständig**: Diese Konfiguration fehlte in `apollo-os-install.sh`

---

## Implementierte Lösung

### 1. Aktualisierung der Installation (`apollo-os-install.sh`)

**Neue Funktion:** `configure_user_permissions()` (Zeilen 285-323)

```bash
configure_user_permissions() {
    # Fügt Benutzer zu video und input Gruppen hinzu
    sudo usermod -aG video "$USER"
    sudo usermod -aG input "$USER"
    
    # Erstellt udev-Regeln für Backlight-Zugriff
    sudo bash -c 'cat > /etc/udev/rules.d/90-backlight.rules' << 'EOF'
ACTION=="add", SUBSYSTEM=="backlight", RUN+="/bin/chgrp video /sys/class/backlight/%k/brightness"
ACTION=="add", SUBSYSTEM=="backlight", RUN+="/bin/chmod g+w /sys/class/backlight/%k/brightness"
EOF
    
    # Lädt udev-Regeln neu
    sudo udevadm control --reload-rules
    sudo udevadm trigger --subsystem-match=backlight
}
```

**Integration in main():** Aufgerufen nach `install_packages()`, vor `verify_critical_packages()`

---

### 2. Hotfix-Script für bestehende Installationen

**Datei:** `scripts/apollo-os-brightness-fix.sh`

**Features:**
- ✅ Prüft und installiert `brightnessctl` falls nötig
- ✅ Fügt Benutzer zu `video` und `input` Gruppen hinzu
- ✅ Erstellt udev-Regeln (`/etc/udev/rules.d/90-backlight.rules`)
- ✅ Lädt udev-Regeln neu
- ✅ Zeigt verfügbare Backlight-Geräte
- ✅ Testet `brightnessctl`
- ✅ Bietet automatisches Abmelden an
- ✅ Interaktiv und benutzerfreundlich

**Ausführung:**
```bash
cd ~/apollo-os-dev/v0.5.0
./scripts/apollo-os-brightness-fix.sh
```

---

### 3. Dokumentation

**Neue Dateien:**

1. **`docs/BRIGHTNESS_FIX.md`** (4.3 KB)
   - Vollständige technische Dokumentation
   - Problem-Beschreibung und Ursachen
   - Schritt-für-Schritt Lösungen
   - Manuelle Fehlerbehebung
   - Testen und Verifizierung

2. **`HOTFIX_BRIGHTNESS.md`** (1.7 KB)
   - Schnelle Anleitung für Endbenutzer
   - 3-Schritte Lösung
   - Erklärung für Desktop-PC Nutzer

**Aktualisierte Dateien:**

1. **`docs/FAQ.md`**
   - Neuer Abschnitt: "🔆 Brightness Control"
   - Häufige Probleme und Lösungen
   - Tastenkombinationen
   - Manuelle Steuerung über Terminal

2. **`README.md`**
   - Version auf v0.5.1 aktualisiert
   - Neues Feature: 🔆 Brightness Control
   - Hinweis auf v0.5.1 Änderungen mit Link zu Dokumentation

3. **`AENDERUNGSPROTOKOLL.md`**
   - Neuer Eintrag für v0.5.1
   - Detaillierte Beschreibung der Fehlerbehebung
   - Geänderte Dateien aufgelistet

---

## Technische Details

### udev-Regeln
```bash
# /etc/udev/rules.d/90-backlight.rules
ACTION=="add", SUBSYSTEM=="backlight", RUN+="/bin/chgrp video /sys/class/backlight/%k/brightness"
ACTION=="add", SUBSYSTEM=="backlight", RUN+="/bin/chmod g+w /sys/class/backlight/%k/brightness"
```

**Funktion:**
- Setzt Gruppe auf `video` für alle Backlight-Geräte
- Erlaubt Schreibzugriff für Gruppenmitglieder
- Wird automatisch beim Gerät-Hinzufügen angewendet

### Niri Tastenbelegung
```kdl
# ~/.config/niri/config.kdl
XF86MonBrightnessUp allow-when-locked=true { 
    spawn "brightnessctl" "set" "10%+"; 
}
XF86MonBrightnessDown allow-when-locked=true { 
    spawn "brightnessctl" "set" "10%-"; 
}
```

### Waybar Modul
```json
"backlight": {
    "format": "{icon}   {percent}%",
    "format-icons": ["󰃞", "󰃟", "󰃠"]
}
```

---

## Verifizierung

### Nach Installation/Hotfix

1. **Gruppenzugehörigkeit prüfen:**
   ```bash
   groups
   # Muss 'video' enthalten
   ```

2. **Backlight-Geräte prüfen:**
   ```bash
   ls /sys/class/backlight/
   # Sollte Gerät(e) zeigen (bei Laptops)
   ```

3. **brightnessctl testen:**
   ```bash
   brightnessctl info
   brightnessctl set 50%
   ```

4. **Fn-Tasten testen:**
   - Fn + Brightness Up/Down drücken
   - Waybar sollte Änderung anzeigen

---

## Wichtige Hinweise

### Für Benutzer

⚠️ **Abmelden erforderlich**: Nach Installation oder Hotfix **muss** der Benutzer sich abmelden und wieder anmelden, damit die Gruppenzugehörigkeit aktiv wird. Ein einfacher Neustart des Window Managers reicht nicht!

⚠️ **Nur für Laptops**: Desktop-PCs ohne integrierte Laptop-Displays haben keine Backlight-Steuerung. Dies ist normal und kein Fehler.

### Für Entwickler

✅ **Neuinstallationen**: Ab v0.5.1 wird `configure_user_permissions()` automatisch während der Installation aufgerufen.

✅ **Bestehende Installationen**: Benutzer können das Hotfix-Script ausführen oder die Installation erneut durchlaufen lassen.

---

## Git Commit

**Commit:** `fc0f2d0`  
**Branch:** `main`  
**GitHub:** https://github.com/apolloenv/apollo-os

**Commit Message:**
```
v0.5.1: Fix brightness control

🐛 Fixed brightness control not working

Problem:
- Fn keys for brightness didn't work
- User lacked permissions for backlight devices

Solution:
- Added configure_user_permissions() to installer
- Adds user to 'video' and 'input' groups
- Creates udev rules for backlight access
- Hotfix script for existing installations

Changes:
- apollo-os-install.sh: New configure_user_permissions()
- scripts/apollo-os-brightness-fix.sh: NEW - Hotfix script
- docs/BRIGHTNESS_FIX.md: NEW - Complete documentation
- docs/FAQ.md: Added brightness troubleshooting section
- HOTFIX_BRIGHTNESS.md: NEW - Quick guide for users
- README.md: Updated to v0.5.1
- AENDERUNGSPROTOKOLL.md: Added v0.5.1 changelog

Note: After installation/hotfix, users must log out and back in
for group changes to take effect.
```

**Push:** Erfolgreich zu GitHub gepusht

---

## Geänderte Dateien

```
modified:   AENDERUNGSPROTOKOLL.md
new file:   HOTFIX_BRIGHTNESS.md
modified:   README.md
modified:   apollo-os-install.sh
new file:   docs/BRIGHTNESS_FIX.md
modified:   docs/FAQ.md
new file:   scripts/apollo-os-brightness-fix.sh
```

**Statistik:**
- 7 Dateien geändert
- 508 Zeilen hinzugefügt
- 2 Zeilen entfernt
- 3 neue Dateien erstellt

---

## Zusammenfassung

✅ **Problem identifiziert**: Fehlende Benutzerberechtigungen für Backlight-Steuerung

✅ **Lösung implementiert**: 
- Installation aktualisiert mit automatischer Berechtigungskonfiguration
- Hotfix-Script für bestehende Installationen
- Umfassende Dokumentation

✅ **Getestet**: Funktioniert auf Laptops mit Backlight-Hardware

✅ **Dokumentiert**: README, FAQ, Changelog und dedizierte Docs aktualisiert

✅ **Deployed**: v0.5.1 auf GitHub verfügbar

---

**Status:** ✅ Production Ready  
**Version:** v0.5.1  
**Datum:** 2026-01-14  
**Entwickler:** Apollo Agent  
**Copyright:** 2025 by Manuel Kraibacher
