# Known Issues - Apollo OS v0.4.1

**Last Updated:** 2026-01-13 01:13 Uhr  
**Status:** Post-Testing on Fedora 43 (Remote: 192.168.0.111)

**📄 Siehe CURRENT_STATUS.md für detaillierte Problembeschreibungen und alle Lösungsansätze.**

---

## 🔴 CRITICAL - AKTIV

### GTK Dark Theme funktioniert nicht in Niri
- ❌ Niri PRO/MOD: Gnome-Apps im hellen Theme
- ✅ Sway PRO/MOD: Dark Theme funktioniert
- Problem: gsettings hat keinen Effekt trotz korrekter Konfiguration
- Status: **LÖSUNGSANSÄTZE GESUCHT**

---

## 🟡 MEDIUM - AKTIV  

### Boot-Pause bei frame buffer device
- Symptom: Boot stoppt kurz, Enter → Cryptsetup Passwort
- Workaround: Enter drücken
- Ursache: Plymouth deaktiviert, aber Cryptsetup wartet trotzdem

---

## 🟢 MINOR

- Waybar Zombie-Prozess (funktioniert trotzdem)
- spawn-at-startup nicht im Journal (Services starten trotzdem)

---

## ✅ GELÖST in v0.4.1

- ✅ Boot Freeze bei Plymouth (maskiert)
- ✅ Greetd crashed (greeter user erstellt)
- ✅ Waybar fehlt (Autostart + Nerd Font)
- ✅ Sway Config Error (omarchy-menu entfernt)
- ✅ Wrapper nicht gefunden (nach /usr/local/bin/)
- ✅ Waybar Icons fehlen (Nerd Font installiert)
- ✅ Boot-Splash blockiert (entfernt)
- ✅ API Keys Validation (optional gemacht)
- ✅ Sensitive Daten in Docs (durch Platzhalter ersetzt)

---

**Details:** CURRENT_STATUS.md  
**GitHub:** apolloenv/apollo-os (Commit: 05f6bc1)
