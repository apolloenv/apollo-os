# Apollo OS v0.5.1 - Brightness Hotfix Anleitung

## Für bestehende Apollo OS Benutzer

Falls deine Helligkeitssteuerung (Fn-Tasten) nicht funktioniert, führe bitte diesen Hotfix aus:

### Schnelle Lösung (3 Schritte)

1. **Terminal öffnen** (Super+Enter oder Super+Shift+Space → Terminal)

2. **Hotfix ausführen:**
   ```bash
   cd ~/apollo-os-dev/v0.5.0
   ./scripts/apollo-os-brightness-fix.sh
   ```

3. **Abmelden wenn gefragt** (oder manuell abmelden)

4. **Wieder anmelden**

Das war's! Die Fn-Tasten für Helligkeit sollten jetzt funktionieren.

---

## Was macht der Hotfix?

- ✅ Installiert `brightnessctl` (falls nötig)
- ✅ Fügt dich zur `video` Gruppe hinzu
- ✅ Fügt dich zur `input` Gruppe hinzu  
- ✅ Erstellt udev-Regeln für Backlight-Zugriff
- ✅ Lädt udev-Regeln neu

**Warum Abmelden?** Die Gruppenzugehörigkeit wird erst nach erneutem Anmelden aktiv.

---

## Testen

Nach dem Neuanmelden:

```bash
# Zeige verfügbare Backlight-Geräte
brightnessctl list

# Teste Helligkeitsänderung
brightnessctl set 50%
```

Dann probiere die Fn-Tasten (meist Fn+F5/F6).

---

## Desktop-PC ohne Laptop-Display?

Falls du einen Desktop-PC nutzt oder nur externe Monitore angeschlossen hast:
- **Das ist normal** - Desktop-PCs haben keine Backlight-Steuerung
- Nutze die Tasten am Monitor direkt
- Der Hotfix schadet nicht, aber bringt auch keinen Nutzen

---

## Probleme?

Siehe: [docs/BRIGHTNESS_FIX.md](../docs/BRIGHTNESS_FIX.md)

Oder manuell:
```bash
# Prüfe Gruppen
groups
# Sollte 'video' enthalten

# Prüfe Backlight
ls /sys/class/backlight/
# Sollte mindestens ein Gerät zeigen (bei Laptops)
```

---

**Apollo OS v0.5.1** - Copyright 2025 by Manuel Kraibacher
