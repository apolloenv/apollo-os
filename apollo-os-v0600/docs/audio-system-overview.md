# Apollo OS - Audio & Voice System (TTS)

**Status:** Final Concept
**Engine:** Piper TTS (Offline Neural Text-to-Speech)
**Default Voice:** LUNA (`en_GB-jenny_dioco-medium`)
**Integration:** System-wide via Bash Scripts & Daemon

---

## 1. Architektur & Komponenten

Das Audiosystem besteht aus drei Schichten:
1.  **Sound FX (SFX):** Synthetische Töne für Feedback (Chimes, Beeps).
2.  **Voice Engine (TTS):** Piper binary für dynamische Sprachsynthese.
3.  **Controller:** Skripte, die Events abfangen und Audio-Feedback triggern.

### Speicherorte
*   **Piper Binary:** `/usr/local/bin/piper` (oder `~/.local/bin/piper`)
*   **Voice Models:** `~/.local/share/apollo-os/voices/`
*   **SFX Assets:** `~/.local/share/apollo-os/sounds/` (`chime.wav`, `silence.wav`)
*   **Cache:** `/tmp/apollo-tts-cache/` (für generierte Sätze)

---

## 2. Standard-Stimme: LUNA

Wir nutzen **LUNA** als primäre Systemstimme für Apollo OS.
*   **Modell:** `en_GB-jenny_dioco-medium.onnx`
*   **Charakter:** Ruhig, britisch, professionell, freundlich.
*   **Einstellungen:** `Length Scale: 1.2` (etwas langsamer für mehr Natürlichkeit).

---

## 3. Der "Announcement Flow"

Jede System-Durchsage folgt einem festen Muster, um Aufmerksamkeit zu erregen, ohne zu nerven.

**Ablauf:**
1.  **Chime:** Ein sanfter 2-Ton "Ding-Dong" (880Hz -> 660Hz).
2.  **Pause:** 0.5 Sekunden Stille.
3.  **Voice:** Der gesprochene Text (TTS).

**Bash-Implementierung (Konzept):**
```bash
play_announcement() {
    local text="$1"
    local chime="$HOME/.local/share/apollo-os/sounds/chime.wav"
    
    # 1. TTS generieren (falls nicht im Cache)
    local hash=$(echo -n "$text" | md5sum | cut -d' ' -f1)
    local wav="/tmp/apollo-tts-cache/$hash.wav"
    
    if [ ! -f "$wav" ]; then
        echo "$text" | piper --model ... --length_scale 1.2 --output_file "$wav"
    fi
    
    # 2. Abspielen (Chime -> Wait -> Voice)
    paplay "$chime"
    sleep 0.5
    paplay "$wav"
}
```

---

## 4. System-Events & Trigger

Hier ist die Liste aller Events, die eine Sprachausgabe auslösen sollen.

### A. Session Management

| Event | Trigger | Text (LUNA) |
|:---|:---|:---|
| **System Boot** | Systemd Unit (`multi-user.target`) | "Apollo Core systems online. Waiting for authentication." |
| **Login** | WM Startup Script | "Identity verified. Welcome back. Workspace initialized." |
| **Logout** | WM Exit Script | "Ending session. User settings saved." |
| **Shutdown** | Systemd Unit (`poweroff.target`) | "Shutting down Apollo services. Goodnight." |
| **Lock Screen** | `swayidle` (before-sleep) | "System locked. Security protocols active." |
| **Unlock** | `swayidle` (after-resume) | "Access granted. Resuming session." |

### B. Hardware & Power

| Event | Trigger | Text (LUNA) |
|:---|:---|:---|
| **AC Connected** | Udev Rule / Daemon | "Power source connected. Charging initiated." |
| **AC Disconnected** | Udev Rule / Daemon | "Power source disconnected. Running on battery reserves." |
| **Battery < 20%** | Daemon Loop | "Warning: Energy levels at 20 percent." |
| **Battery < 10%** | Daemon Loop | "Critical Alert: Energy reserves critical. Connect power immediately." |
| **Brightness Up** | SwayOSD / Script | "Brightness increased." (Optional, evtl. nur SFX) |
| **Brightness Down** | SwayOSD / Script | "Brightness decreased." (Optional, evtl. nur SFX) |

### C. Connectivity

| Event | Trigger | Text (LUNA) |
|:---|:---|:---|
| **WiFi Connected** | NetworkManager Dispatcher | "Nexus Uplink established. Connection secure." |
| **WiFi Lost** | NetworkManager Dispatcher | "Connection lost. Scanning for networks." |
| **Bluetooth Connected** | Udev / Blueman | "Peripheral device connected." |
| **Bluetooth Lost** | Udev / Blueman | "Device disconnected." |

---

## 5. Installation & Setup

### Voraussetzungen
```bash
sudo dnf install piper-tts sox ffmpeg libespeak-ng1
```

### Assets vorbereiten
Das `install.sh` Skript muss:
1.  Die Ordnerstruktur anlegen.
2.  Das LUNA-Modell (`.onnx` + `.json`) herunterladen.
3.  Den Chime-Sound generieren (via `ffmpeg`).
4.  Das `apollo-speak` Helper-Skript nach `/usr/local/bin/` kopieren.

---

## 6. Zukünftige Erweiterungen

*   **LLM-Integration:** Der Daemon könnte dynamische Antworten von Gemini/Ollama direkt an Piper senden ("Lies mir die News vor").
*   **Silent Mode:** Ein "Do Not Disturb" Schalter, der TTS deaktiviert und nur visuelle Notifications zulässt.
*   **Persona Switch:** Einfaches Wechseln zu KAI oder ATLAS via Config-Datei.
