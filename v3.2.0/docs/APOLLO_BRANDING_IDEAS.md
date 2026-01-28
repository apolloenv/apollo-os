# Apollo OS - Branding & Identity Concepts

**Status:** Draft / Brainstorming (Expanded)
**Ziel:** Transformation von einer "Fedora Konfiguration" zu einer eigenständigen "OS Experience".
**Thema:** Modern Futurism, High-Tech, Clean AI.

---

## 1. Login Sessions (Window Manager Renaming)

Wir ersetzen die technischen Namen durch Begriffe, die das *Gefühl* der Nutzung beschreiben.

### Konzept A: Bewegung & Struktur (Der Favorit)
*Fokus auf die Art der Fensterverwaltung.*

| Original | Neuer Name | Desktop Entry Name | Beschreibung |
|:---|:---|:---|:---|
| **Niri** | **Apollo Orbit** | `Apollo Orbit (Fluid)` | Das endlose Scrollen fühlt sich an wie ein Orbit/Flow. |
| **Sway** | **Apollo Grid** | `Apollo Grid (Static)` | Das Tiling ist fest verankert, ein technisches Gitter. |

### Konzept B: Dimensionen (Futuristisch)
*Fokus auf die räumliche Wahrnehmung.*

| Original | Neuer Name | Desktop Entry Name | Beschreibung |
|:---|:---|:---|:---|
| **Niri** | **Apollo Horizon** | `Apollo Horizon (Infinite)` | Niri scrollt horizontal ins Unendliche – wie der Horizont. |
| **Sway** | **Apollo Sector** | `Apollo Sector (Fixed)` | Der Bildschirm wird in feste Sektoren unterteilt. |

---

## 2. Apollo Intelligence (AI Naming)

Die KI besteht aus zwei Teilen: Dem allwissenden, langsameren Teil (Cloud) und dem schnellen, privaten Teil (Lokal).

### Die Dachmarke
*   **Name:** **Apollo Core** oder **Apollo Mind**
*   **Interface:** **Neural Link** oder **Uplink**

### Namens-Paare für Cloud & Local AI

| Stil-Richtung | Cloud AI (Gemini) | Local AI (Ollama) | Beispiel-Interaktion |
|:---|:---|:---|:---|
| **Netzwerk** | **Nexus** | **Cortex** | "Nexus sucht Daten... Cortex verarbeitet lokal." |
| **Technisch** | **Mainframe** | **Subroutine** | "Mainframe Query gesendet. Subroutine aktiv." |
| **Abstrakt** | **Aether** | **Echo** | "Signal aus dem Aether empfangen. Echo bestätigt." |

---

## 3. System-Komponenten & Tools Renaming

Kleine Änderungen mit großer Wirkung für die Immersion.

| Tool | Original | Vorschlag: "Modern Tech" | Vorschlag: "Clean" |
|:---|:---|:---|:---|
| **Launcher** (Rofi) | Rofi | **Access Point** | **Search** |
| **Terminal** | Alacritty | **Console** | **Terminal** |
| **Diagnostics** | script | **Diagnostics** | **System Check** |
| **Daemon** | python | **Core Services** | **Background Ops** |
| **Theme Switch** | script | **Visual Mode** | **Ambiance** |
| **Boot Splash** | Plymouth | **Ignition** | **Startup** |
| **Lockscreen** | Swaylock | **Secure Mode** | **Lock** |
| **Notifications**| Mako | **Alerts** | **Notifications** |

---

## 4. Flavor Text & Wording (Micro-Copy)

Wie das System mit dem Benutzer spricht. (Neutral, Technisch, Präzise).

**Boot-Nachrichten (Ignition Sequence):**
*   `Initializing Apollo Core... [OK]`
*   `Loading Interface Modules... [OK]`
*   `Establishing Uplink to Nexus... [OK]`
*   `Cortex active. Local systems nominal.`
*   `Identity verified. Workspace ready.`

**Batterie-Warnung:**
*   *Standard:* "Battery Low (15%)"
*   *Apollo:* "⚠️ **Power Levels Critical**. Reserves at 15%. Connect power source."

**Update verfügbar:**
*   *Standard:* "Updates Available"
*   *Apollo:* "📦 **System Updates** ready for installation."

**Fehler / Offline:**
*   *Standard:* "No Internet Connection"
*   *Apollo:* "🚫 **Connection Lost**. Switching to local processing."

**Theme Switch:**
*   *Zu Dark:* "Visuals adapted. Dark mode active."
*   *Zu Light:* "Brightness increased. Light mode active."

---

## 5. Audio-Feedback (Sound Design)

Geräusche machen das System "greifbar".

### Einsatzorte für Sounds (SFX)

| Event | Sound-Charakter | Wo einbauen? | Technisch möglich? |
|:---|:---|:---|:---|
| **Login / Startup** | **"Initialize"** (Subtiles Hochfahren) | `apollo-os-wrapper-*.sh` | ✅ Ja |
| **Shutdown** | **"Terminate"** (Sanftes Ausblenden) | `apollo-os-wrapper-*.sh` | ✅ Ja |
| **Theme Switch** | **"Click"** (Hochwertiger Schalter) | `apollo-os-theme-switcher.sh` | ✅ Ja |
| **Lock Screen** | **"Secure"** (Mechanisches Verriegeln) | `swayidle` | ✅ Ja |
| **Unlock** | **"Access"** (Bestätigungston) | `swayidle` | ✅ Ja |
| **AI Request** | **"Processing"** (Digitales Rattern) | `apollo-os-daemon.py` | ✅ Ja |
| **AI Response** | **"Result"** (Positives Pingen) | `apollo-os-daemon.py` | ✅ Ja |

---

## 7. Voice Interface (TTS Scripts)

**Persona:** "Apollo Core"
**Stil:** Modern, Technisch, Hilfsbereit, Ruhig.
**Tone:** Kein "Commander", kein "Sir". Einfach, direkt und smart.

**Dateiformat:** `.wav`
**Speicherort:** `/home/apollo/.local/share/apollo-os/sounds/voice/`

### Phrasen (Deutsch & Englisch)

| Event | Dateiname | Text (English) | Text (Deutsch) |
|:---|:---|:---|:---|
| **System Boot** | `voice_system_online.wav` | "Apollo Core initialized. All systems operational." | "Apollo Core initialisiert. Alle Systeme bereit." |
| **Login Success** | `voice_welcome.wav` | "Identity confirmed. Welcome back." | "Identität bestätigt. Willkommen zurück." |
| **Session Orbit** | `voice_session_orbit.wav` | "Orbit Interface loaded." | "Orbit Interface geladen." |
| **Session Grid** | `voice_session_grid.wav` | "Grid Interface loaded." | "Grid Interface geladen." |
| **Lock Screen** | `voice_lock.wav` | "System secured. Standing by." | "System gesichert. Standby Modus." |
| **Unlock** | `voice_unlock.wav` | "Access granted. Resuming session." | "Zugriff gewährt. Sitzung wird fortgesetzt." |
| **Wake Up** | `voice_wakeup.wav` | "Power levels restored. Online." | "Energielevel wiederhergestellt. Online." |
| **Shutdown** | `voice_shutdown.wav` | "Shutting down services. Until next time." | "Dienste werden beendet. Bis zum nächsten Mal." |
| **Battery Low** | `voice_battery_low.wav` | "Energy critical. Please connect power source." | "Energie kritisch. Bitte Stromquelle anschließen." |
| **Notification** | `voice_transmission.wav` | "New data received." | "Neue Daten empfangen." |
| **Theme: Dark** | `voice_theme_dark.wav` | "Visuals dimmed. Night mode active." | "Visuelle Systeme gedimmt. Nachtmodus aktiv." |
| **Theme: Light** | `voice_theme_light.wav` | "Brightness adjusted. Day mode active." | "Helligkeit angepasst. Tagmodus aktiv." |
| **AI Error** | `voice_uplink_lost.wav` | "Connection lost. Local processing only." | "Verbindung unterbrochen. Nur lokale Verarbeitung." |
| **AI Ready** | `voice_uplink_ready.wav` | "Nexus Uplink established." | "Nexus Verbindung hergestellt." |

---

## 8. Integration in Code

Funktion zum Abspielen (Sprachwahl via Config):

```bash
# In apollo-os/config.env:
# APOLLO_VOICE_LANG="de" # oder "en"

play_voice() {
    local file="$1"
    local lang="${APOLLO_VOICE_LANG:-en}" # Default English
    local path="$HOME/.local/share/apollo-os/sounds/voice/$lang/$file"
    
    if [ -f "$path" ]; then
        paplay "$path" &
    fi
}
```

---

## 9. ElevenLabs Copy-Paste Scripts (Text Only)

Hier sind die reinen Textblöcke mit jeweils 3 Varianten (Standard, Kurz, Detailliert) für mehr Abwechslung.

### 🇬🇧 ENGLISH (Copy Block)

**voice_system_online**
Apollo Core initialized. All systems operational.
Startup sequence complete. Systems online.
Core services active. Ready for input.

**voice_welcome**
Identity confirmed. Welcome back.
Access granted. Workspace ready.
User authenticated. Loading preferences.

**voice_session_orbit**
Orbit Interface loaded.
Fluid navigation active.
Orbit mode engaged.

**voice_session_grid**
Grid Interface loaded.
Tiling structure active.
Grid mode engaged.

**voice_lock**
System secured. Standing by.
Interface locked.
Security protocols active. System locked.

**voice_unlock**
Access granted. Resuming session.
Unlocked.
Identity verified. Restoring interface.

**voice_wakeup**
Power levels restored. Online.
System awake.
Resuming from suspension.

**voice_shutdown**
Shutting down services. Until next time.
System offline. Goodbye.
Terminating all processes. Powering down.

**voice_battery_low**
Energy critical. Please connect power source.
Warning. Power levels below threshold.
Battery low. Charging recommended.

**voice_transmission**
New data received.
Incoming alert.
You have a new notification.

**voice_theme_dark**
Visuals dimmed. Night mode active.
Dark mode engaged.
Adjusting brightness. Night vision active.

**voice_theme_light**
Brightness adjusted. Day mode active.
Light mode engaged.
Visuals adapted. Day cycle active.

**voice_uplink_lost**
Connection lost. Local processing only.
Uplink severed. Using Cortex fallback.
Network unreachable. Offline mode.

**voice_uplink_ready**
Nexus Uplink established.
Connection restored.
Online services available.

### 🇩🇪 GERMAN (Copy Block)

**voice_system_online**
Apollo Core initialisiert. Alle Systeme bereit.
Systemstart abgeschlossen. Dienste online.
Core Services aktiv. Bereit für Eingabe.

**voice_welcome**
Identität bestätigt. Willkommen zurück.
Zugriff gewährt. Arbeitsumgebung bereit.
Benutzer authentifiziert. Lade Einstellungen.

**voice_session_orbit**
Orbit Interface geladen.
Fluide Navigation aktiv.
Orbit Modus gestartet.

**voice_session_grid**
Grid Interface geladen.
Raster Struktur aktiv.
Grid Modus gestartet.

**voice_lock**
System gesichert. Standby Modus.
Interface gesperrt.
Sicherheitsprotokolle aktiv. System gesperrt.

**voice_unlock**
Zugriff gewährt. Sitzung wird fortgesetzt.
Entsperrt.
Identität verifiziert. Stelle Interface wieder her.

**voice_wakeup**
Energielevel wiederhergestellt. Online.
System wach.
Nehme Betrieb wieder auf.

**voice_shutdown**
Dienste werden beendet. Bis zum nächsten Mal.
System offline. Auf Wiedersehen.
Beende alle Prozesse. Fahre herunter.

**voice_battery_low**
Energie kritisch. Bitte Stromquelle anschließen.
Warnung. Energielevel unter Grenzwert.
Akku leer. Aufladen empfohlen.

**voice_transmission**
Neue Daten empfangen.
Eingehender Alarm.
Du hast eine neue Benachrichtigung.

**voice_theme_dark**
Visuelle Systeme gedimmt. Nachtmodus aktiv.
Dunkelmodus aktiviert.
Passe Helligkeit an. Nachtsicht aktiv.

**voice_theme_light**
Helligkeit angepasst. Tagmodus aktiv.
Heller Modus aktiviert.
Visuelle Systeme adaptiert. Tagzyklus aktiv.

**voice_uplink_lost**
Verbindung unterbrochen. Nur lokale Verarbeitung.
Uplink getrennt. Nutze Cortex Fallback.
Netzwerk nicht erreichbar. Offline Modus.

**voice_uplink_ready**
Nexus Verbindung hergestellt.
Verbindung wiederhergestellt.
Online Dienste verfügbar.