# Apollo OS v0.5.0 - TTS Privacy Update
**Datum:** 2026-01-13 20:03 CET  
**Update:** Benutzernamen aus TTS entfernt  
**Status:** ✅ Abgeschlossen

---

## 🔒 Änderung

**Vorher:**
```
TTS: "Good morning, Manuel. Welcome to Apollo OS. All systems operational."
```

**Nachher:**
```
TTS: "Good morning. Welcome to Apollo OS. All systems operational."
```

---

## 📝 Grund

**Datenschutz:** Keine persönlichen Informationen via Sprachausgabe.

**Details:**
- Visual Notification zeigt weiterhin den Username
- TTS-Ausgabe ist anonym
- Gilt für alle TTS-Ansagen (nur Login betroffen)

---

## 📁 Geänderte Dateien

### 1. scripts/apollo-os-greeting.sh
```bash
# Vorher:
apollo-speak "$GREETING_EN, $USER_NAME. Welcome to Apollo OS..."

# Nachher:
apollo-speak "$TTS_GREETING. Welcome to Apollo OS. All systems operational."
```

### 2. README.md
- Privacy-Hinweis hinzugefügt
- TTS-Beispiel aktualisiert

### 3. docs/FAQ.md
- TTS-Beispiel aktualisiert
- Neue FAQ: "Werden Benutzernamen via TTS angesagt?"

### 4. TTS_SYSTEM_UPDATE.md
- Login Greeting Beispiele aktualisiert
- Privacy-Hinweis bei Login Greeting
- Test-Szenario aktualisiert

---

## ✅ Verifizierung

```bash
# Check: Keine Benutzernamen in TTS-Ausgaben
grep -r "USER_NAME" scripts/apollo-os-greeting.sh
# → Nur in notify-send (visual), nicht in apollo-speak ✅

# Check: Privacy-Hinweis in Dokumentation
grep -i "privacy\|benutzername.*tts" README.md docs/FAQ.md
# → Hinweise vorhanden ✅
```

---

## 🎯 Ergebnis

**Visual (mit Username):**
- "Good morning, Manuel!"
- "It's 08:30"

**TTS (anonym):**
- "Good morning. Welcome to Apollo OS. All systems operational."

**Alle anderen TTS-Events:** Bereits anonym (Battery, Network, Power)

---

**Durchgeführt von:** Apollo Agent  
**Copyright © 2026 by Manuel Kraibacher**
