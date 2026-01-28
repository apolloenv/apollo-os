#!/usr/bin/env python3
"""
Apollo OS - Right Control Key Voice Input Trigger
Push-to-Talk: Hold Right Ctrl to record, release to transcribe
"""

import evdev
import subprocess
import sys
import os
import time

# Voice input script
VOICE_SCRIPT = os.path.expanduser("~/.local/bin/voice-input")
PID_FILE = os.path.expanduser(f"{os.environ.get('XDG_RUNTIME_DIR', '/tmp')}/voice-input.pid")

recording = False

def find_keyboards():
    """Find all keyboard devices"""
    devices = []
    for path in evdev.list_devices():
        device = evdev.InputDevice(path)
        caps = device.capabilities()
        # Check if device has KEY_RIGHTCTRL (105)
        if evdev.ecodes.EV_KEY in caps and evdev.ecodes.KEY_RIGHTCTRL in caps[evdev.ecodes.EV_KEY]:
            devices.append(device)
    return devices

def is_recording():
    """Check if voice input is currently recording"""
    return os.path.exists(PID_FILE)

def main():
    global recording
    
    devices = find_keyboards()
    if not devices:
        print("No keyboard with Right Ctrl found", file=sys.stderr)
        return 1
    
    print(f"Listening on {len(devices)} keyboard(s) - Push-to-Talk mode")
    for dev in devices:
        print(f"  - {dev.name}")
    
    # Monitor all keyboards
    try:
        while True:
            # Check all devices for events
            for device in devices:
                try:
                    # Non-blocking read
                    for event in device.read():
                        if event.type == evdev.ecodes.EV_KEY and event.code == evdev.ecodes.KEY_RIGHTCTRL:
                            if event.value == 1:  # Key press - START recording
                                if not is_recording():
                                    print("Right Ctrl pressed - START recording", flush=True)
                                    subprocess.Popen([VOICE_SCRIPT])
                                    recording = True
                            elif event.value == 0:  # Key release - STOP recording
                                if is_recording():
                                    print("Right Ctrl released - STOP recording", flush=True)
                                    subprocess.Popen([VOICE_SCRIPT])
                                    recording = False
                except BlockingIOError:
                    pass
            time.sleep(0.01)
    except KeyboardInterrupt:
        pass
    
    return 0

if __name__ == "__main__":
    sys.exit(main())
