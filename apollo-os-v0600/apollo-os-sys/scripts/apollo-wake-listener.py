#!/usr/bin/env python3
import os, sys, json, subprocess, queue, time, shlex
from datetime import datetime
from vosk import Model, KaldiRecognizer
import sounddevice as sd

WAKE_WORD = "apollo"
MODEL_PATH = os.path.expanduser("~/.local/share/vosk-models/vosk-model-small-de-0.15")
SAMPLE_RATE = 16000
COMMAND_TIMEOUT = 5

# Whitelist: Erlaubte Befehle für Sicherheit
ALLOWED_COMMANDS = {
    "alacritty": ["/usr/bin/alacritty"],
    "microsoft-edge": ["/usr/bin/microsoft-edge-stable", "--new-window"],
    "hyprlock": ["/usr/bin/hyprlock"],
    "systemctl": ["/usr/bin/systemctl"],  # nur mit validate_command()
    "pw-play": ["/usr/bin/pw-play"],
    "apollo-speak": [os.path.expanduser("~/.local/bin/apollo-speak.sh")]
}

def log(msg):
    sys.stderr.write(msg + "\n")
    sys.stderr.flush()

log(f"Apollo Wake Word Listener (Vosk)")
log(f"Loading model from: {MODEL_PATH}")

try:
    model = Model(MODEL_PATH)
    recognizer = KaldiRecognizer(model, SAMPLE_RATE)
    recognizer.SetWords(True)
    log("✓ Vosk model loaded")
except Exception as e:
    log(f"Failed to load model: {e}")
    sys.exit(1)

q = queue.Queue()

def audio_callback(indata, frames, time_info, status):
    if status:
        log(f"Audio status: {status}")
    q.put(bytes(indata))

def get_german_weekday(weekday):
    days = ["Montag", "Dienstag", "Mittwoch", "Donnerstag", "Freitag", "Samstag", "Sonntag"]
    return days[weekday]

def get_german_month(month):
    months = ["Jänner", "Februar", "März", "April", "Mai", "Juni", 
              "Juli", "August", "September", "Oktober", "November", "Dezember"]
    return months[month - 1]

def validate_command(cmd_name, args=None):
    """
    Validiert Befehle gegen Whitelist
    Returns: (valid, full_command_list) oder (False, None)
    """
    if cmd_name not in ALLOWED_COMMANDS:
        log(f"SECURITY: Command '{cmd_name}' not in whitelist")
        return False, None

    cmd = ALLOWED_COMMANDS[cmd_name].copy()

    # Spezielle Validierung für systemctl
    if cmd_name == "systemctl" and args:
        allowed_systemctl = ["suspend", "reboot"]
        if args[0] not in allowed_systemctl:
            log(f"SECURITY: systemctl action '{args[0]}' not allowed")
            return False, None
        cmd.extend(args)
    elif args:
        cmd.extend(args)

    return True, cmd

def safe_execute(cmd_name, args=None, wait=False):
    """
    Führt Befehl sicher aus (Whitelist-Check)
    """
    valid, cmd = validate_command(cmd_name, args)
    if not valid:
        log(f"SECURITY: Blocked execution of '{cmd_name}'")
        return False

    try:
        if wait:
            subprocess.run(cmd, check=True, timeout=10)
        else:
            subprocess.Popen(cmd, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        return True
    except subprocess.TimeoutExpired:
        log(f"ERROR: Command '{cmd_name}' timed out")
        return False
    except Exception as e:
        log(f"ERROR: Failed to execute '{cmd_name}': {e}")
        return False

def play_sound(sound_file):
    """Play audio feedback sound"""
    # Sanitize filename - nur alphanumerisch, -, _ und .
    safe_filename = "".join(c for c in sound_file if c.isalnum() or c in ".-_")
    if safe_filename != sound_file:
        log(f"SECURITY: Invalid sound filename '{sound_file}'")
        return

    sound_path = os.path.expanduser(f"~/.local/share/apollo-os/sounds/{safe_filename}")
    if os.path.exists(sound_path):
        safe_execute("pw-play", [sound_path])

def execute_command(command_text):
    """Execute voice commands"""
    log(f"Processing command: '{command_text}'")

    if "spät" in command_text or "uhrzeit" in command_text:
        log("→ Executing: Tell time")
        now = datetime.now()
        hour = now.hour
        minute = now.minute
        if minute == 0:
            time_text = f"Es ist {hour} Uhr"
        else:
            time_text = f"Es ist {hour} Uhr {minute}"
        safe_execute("apollo-speak", [time_text])

    elif "tag" in command_text or "datum" in command_text:
        log("→ Executing: Tell date")
        now = datetime.now()
        weekday = get_german_weekday(now.weekday())
        day = now.day
        month = get_german_month(now.month)
        date_text = f"Heute ist {weekday} der {day}. {month}"
        safe_execute("apollo-speak", [date_text])

    elif "terminal" in command_text and "öffnen" in command_text:
        log("→ Executing: Open Terminal (Alacritty)")
        safe_execute("apollo-speak", ["Terminal startet."])
        safe_execute("alacritty")

    elif ("browser" in command_text or "web" in command_text) and "start" in command_text:
        log("→ Executing: Open Browser (Microsoft Edge)")
        safe_execute("apollo-speak", ["Browser startet."])
        safe_execute("microsoft-edge")

    elif "sperren" in command_text or "sperre" in command_text:
        log("→ Executing: Lock screen")
        safe_execute("apollo-speak", ["Sperre System."])
        time.sleep(1)
        safe_execute("hyprlock")

    elif "ausschalten" in command_text or "herunterfahren" in command_text or "beenden" in command_text:
        log("→ Executing: Suspend/Sleep")
        safe_execute("apollo-speak", ["Ruhemodus."])
        time.sleep(2)
        safe_execute("systemctl", ["suspend"], wait=True)

    elif "neustart" in command_text or "neu starten" in command_text:
        log("→ Executing: Reboot")
        safe_execute("apollo-speak", ["Neustart."])
        time.sleep(2)
        safe_execute("systemctl", ["reboot"], wait=True)

    else:
        log("→ No specific command found, acknowledging")
        safe_execute("apollo-speak", ["Bereit."])

log("Starting audio stream...")
try:
    with sd.RawInputStream(samplerate=SAMPLE_RATE, blocksize=8000, dtype='int16',
                           channels=1, callback=audio_callback):
        log(f"✓ Listening for '{WAKE_WORD}'...")
        
        wake_word_detected = False
        wake_word_time = 0
        
        while True:
            data = q.get()
            if recognizer.AcceptWaveform(data):
                result = json.loads(recognizer.Result())
                text = result.get("text", "").lower()
                
                if text:
                    log(f"Recognized: '{text}'")
                    
                    if WAKE_WORD in text:
                        log(f"*** WAKE WORD DETECTED ***")
                        # Play Star Trek sound - Apollo is listening
                        play_sound("voice-start.wav")
                        wake_word_detected = True
                        wake_word_time = time.time()
                        
                        if len(text.split()) > 1:
                            execute_command(text)
                            # Play end sound after command execution
                            play_sound("voice-end.wav")
                            wake_word_detected = False
                    
                    elif wake_word_detected:
                        if time.time() - wake_word_time <= COMMAND_TIMEOUT:
                            execute_command(text)
                            # Play end sound after command execution
                            play_sound("voice-end.wav")
                        else:
                            log("Command timeout - ignoring")
                        wake_word_detected = False
                        
except KeyboardInterrupt:
    log("Stopped by user")
except Exception as e:
    log(f"Error: {e}")
    sys.exit(1)
