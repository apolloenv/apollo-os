#!/usr/bin/env python3
import os, sys, json, subprocess, queue, time
from datetime import datetime
from vosk import Model, KaldiRecognizer
import sounddevice as sd

WAKE_WORD = "apollo"
MODEL_PATH = os.path.expanduser("~/.local/share/vosk-models/vosk-model-small-de-0.15")
SAMPLE_RATE = 16000
COMMAND_TIMEOUT = 5

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

def play_sound(sound_file):
    """Play audio feedback sound"""
    sound_path = os.path.expanduser(f"~/.local/share/apollo-os/sounds/{sound_file}")
    if os.path.exists(sound_path):
        subprocess.Popen(["pw-play", sound_path], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

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
        subprocess.Popen([os.path.expanduser("~/.local/bin/apollo-speak.sh"), time_text])
        
    elif "tag" in command_text or "datum" in command_text:
        log("→ Executing: Tell date")
        now = datetime.now()
        weekday = get_german_weekday(now.weekday())
        day = now.day
        month = get_german_month(now.month)
        year = now.year
        date_text = f"Heute ist {weekday} der {day}. {month} {year}"
        subprocess.Popen([os.path.expanduser("~/.local/bin/apollo-speak.sh"), date_text])
    
    elif "terminal" in command_text and "öffnen" in command_text:
        log("→ Executing: Open Terminal (Alacritty)")
        subprocess.Popen([os.path.expanduser("~/.local/bin/apollo-speak.sh"), "Terminal wird geöffnet"])
        subprocess.Popen(["alacritty"])
    
    elif ("browser" in command_text or "web" in command_text) and "start" in command_text:
        log("→ Executing: Open Browser (Microsoft Edge)")
        subprocess.Popen([os.path.expanduser("~/.local/bin/apollo-speak.sh"), "Web Browser wird gestartet"])
        subprocess.Popen(["microsoft-edge-stable", "--new-window"])
    
    elif "sperren" in command_text or "sperre" in command_text:
        log("→ Executing: Lock screen")
        subprocess.Popen([os.path.expanduser("~/.local/bin/apollo-speak.sh"), "System wird gesperrt"])
        time.sleep(1)
        # Try multiple methods to lock
        # Method 1: swaylock with proper environment
        wayland_display = os.environ.get('WAYLAND_DISPLAY', 'wayland-1')
        env = os.environ.copy()
        env['WAYLAND_DISPLAY'] = wayland_display
        subprocess.Popen(["swaylock", "-i", "/usr/share/backgrounds/apollo-login.jpg"], env=env)
        
    elif "ausschalten" in command_text or "herunterfahren" in command_text or "beenden" in command_text:
        log("→ Executing: Suspend/Sleep")
        subprocess.Popen([os.path.expanduser("~/.local/bin/apollo-speak.sh"), "System wird in den Ruhemodus versetzt"])
        time.sleep(2)
        subprocess.run(["systemctl", "suspend"])
        
    elif "neustart" in command_text or "neu starten" in command_text:
        log("→ Executing: Reboot")
        subprocess.Popen([os.path.expanduser("~/.local/bin/apollo-speak.sh"), "System wird neu gestartet"])
        time.sleep(2)
        subprocess.run(["systemctl", "reboot"])
        
    else:
        log("→ No specific command found, acknowledging")
        subprocess.Popen([os.path.expanduser("~/.local/bin/apollo-speak.sh"), "Ich bin hier und bereit"])

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
