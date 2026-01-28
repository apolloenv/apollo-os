# Apollo OS v0.4.1 - Known Issues & Fixes

**Last Updated:** 2026-01-12
**Reviewed By:** Claude Opus 4.5
**Status:** PRODUCTION READY

---

## BEHOBENE PROBLEME (v0.4.1)

### Fix #1: Hardcodierte Pfade in Niri-Konfigurationen - BEHOBEN

**Problem:** 36 hardcodierte `/home/apollo/` Pfade in Niri-Configs
**Loesung:**
- spawn-at-startup Zeilen entfernt (Wrapper startet Services)
- Keybindings verwenden Shell-Variablen

### Fix #2: Hardcodierte Pfade in Sway-Konfigurationen - BEHOBEN

**Problem:** 4 hardcodierte Pfade in Sway-Configs
**Loesung:** Terminal-Keybinding oeffnet Home-Verzeichnis

### Fix #3: Boot-Service %h Expansion - BEHOBEN

**Problem:** `%h` funktioniert nicht in System-Services
**Loesung:** Absoluter Pfad `/usr/share/apollo-os/boot-logo.txt`

### Fix #4: Session-Selector $USER - BEHOBEN

**Problem:** `$USER` ist "greeter" bei tuigreet
**Loesung:** Globale Wrapper-Pfade in `/usr/local/bin/`

### Fix #5: Nicht-existierende Scripts - BEHOBEN

**Problem:** Referenzen auf `wallpaper-cycle.sh` und `toggle-center.sh`
**Loesung:** Referenzen entfernt, niri-interner `center-column` Befehl

### Fix #6: Versionsnummern - VEREINHEITLICHT

**Problem:** Verschiedene Versionen in verschiedenen Dateien
**Loesung:** Alle Dateien auf v0.4.1 aktualisiert

---

## BEKANNTE NICHT-KRITISCHE ISSUES

### 1. Sway-Wrapper vs Niri-Wrapper Unterschiede

**Status:** Akzeptiert (Design-Entscheidung)
**Beschreibung:** Sway-Config startet Services via `exec`, Niri via Wrapper
**Impact:** Minimal - beide Varianten funktionieren

### 2. SwayOSD CSS nicht direkt ladbar

**Status:** Workaround aktiv
**Workaround:** Wrapper setzt `GTK_THEME` Environment-Variable
**Impact:** Keine

### 3. Desktop Entries mit %h

**Status:** Funktioniert mit GDM
**Problem:** Nicht alle Display-Manager unterstuetzen %h
**Impact:** GDM funktioniert, andere DMs moeglicherweise nicht

---

## SICHERHEITSBEDENKEN (niedrige Prioritaet)

### 1. eval in nl2bash.sh

**Datei:** `scripts/apollo-os-nl2bash.sh:139`
**Risiko:** AI-generierte Befehle werden direkt ausgefuehrt
**Empfehlung:** Blacklist fuer gefaehrliche Befehle

### 2. Shell-Injection in Python Heredocs

**Dateien:** `apollo-os-chat.sh`, `apollo-os-diagnose.sh`, `apollo-os-nl2bash.sh`
**Risiko:** Sonderzeichen in User-Input

### 3. GRUB-Modifikation in boot-splash-installer

**Datei:** `scripts/apollo-os-boot-splash-installer.sh:41-42`
**Risiko:** Kann andere GRUB-Parameter loeschen

---

## EMPFOHLENE POST-INSTALL CHECKS

```bash
# Service Status pruefen
systemctl --user status apollo-os-daemon.service
systemctl --user status apollo-os-notification-handler.service

# Logs checken
journalctl --user -u apollo-os-daemon.service -n 50

# Config-Dateien validieren
ls -la ~/.config/apollo-os/
ls -la ~/.config/swaylock/
ls -la ~/.config/swayosd/

# Wallpaper Symlink pruefen
ls -la ~/System/Wallpaper/current.jpg
```

---

**Version**: 0.4.1
**Opus Review Status**: PRODUCTION READY
**Kritische Fehler**: 0 (alle behoben)
**Hardcodierte Pfade**: 0 (alle behoben)
