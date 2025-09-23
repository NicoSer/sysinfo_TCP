#!/usr/bin/env python3
# sc_kb.py - Keyboard listener for sysinfo project
#
# Copyright (c) 2025 NicoSer
#
# Licensed under the Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International License.
# You may use and share this script for personal, educational, or organizational purposes,
# but you may not modify it or use it commercially.
#
# Full license: https://creativecommons.org/licenses/by-nc-nd/4.0/
import os
import sys
import time
from evdev import InputDevice, categorize, ecodes, list_devices
import select

VINTAGE_COLORS = [
    (16, "Black"),
    (196, "Red"),
    (226, "Yellow"),
    (46, "Green"),
    (51, "Cyan"),
    (21, "Blue"),
    (201, "Magenta"),
    (15, "White"),
]

key_layout = """
[Esc] [F1] [F2] [F3] [F4] [F5] [F6] [F7] [F8] [F9] [F10] [F11] [F12]
[~] [1] [2] [3] [4] [5] [6] [7] [8] [9] [0] [-] [=] [Backspace]
[Tab] [Q] [W] [E] [R] [T] [Y] [U] [I] [O] [P] [[] []] [\\] [Enter]
[CapsLock] [A] [S] [D] [F] [G] [H] [J] [K] [L] [;] [']
[Shift] [Z] [X] [C] [V] [B] [N] [M] [,] [.] [/] [Shift] 
[Ctrl] [Win] [Alt] [Space] [AltGr] [Win] [Ctrl] [Up] [Down] [Left] [Right]
"""

def is_bright(color_index):
    return color_index in [15, 226, 46, 51, 201, 196, 202, 21]

def print_color_screen():
    cols, rows = os.get_terminal_size()
    for _ in range(2):
        for code, name in VINTAGE_COLORS:
            os.system("clear")
            # Fill screen with background color
            line = f"\033[48;5;{code}m{' ' * cols}\033[0m"
            for _ in range(rows - 1):
                print(line)

            # Text overlay on final line
            fg = 0 if is_bright(code) else 15
            text = f"Color: {name}"
            padding_left = (cols - len(text)) // 2
            padding_right = cols - len(text) - padding_left

            print(
                f"\033[48;5;{code}m"                        # BG color on whole line
                + ' ' * padding_left                         # left padding spaces with BG
                + f"\033[38;5;{fg}m{text}\033[48;5;{code}m"  # fg color text, then BG again
                + ' ' * padding_right                        # right padding spaces with BG
                + "\033[0m"                                  # reset at end
            )

            time.sleep(1.5)

def vintage_tv_bars():
    cols, rows = os.get_terminal_size()
    os.system('clear')
    colors = [c[0] for c in VINTAGE_COLORS]
    bar_width = max(cols // len(colors), 1)
    for _ in range(rows):
        for c in colors:
            print(f"\033[48;5;{c}m{' ' * bar_width}\033[0m", end='')
        print()
    time.sleep(1.5)

def map_keycode_to_name(kc):
    return {
        'KEY_ESC': 'Esc', 'KEY_F1': 'F1', 'KEY_F2': 'F2', 'KEY_F3': 'F3', 'KEY_F4': 'F4',
        'KEY_F5': 'F5', 'KEY_F6': 'F6', 'KEY_F7': 'F7', 'KEY_F8': 'F8', 'KEY_F9': 'F9',
        'KEY_F10': 'F10', 'KEY_F11': 'F11', 'KEY_F12': 'F12',
        'KEY_1': '1', 'KEY_2': '2', 'KEY_3': '3', 'KEY_4': '4', 'KEY_5': '5',
        'KEY_6': '6', 'KEY_7': '7', 'KEY_8': '8', 'KEY_9': '9', 'KEY_0': '0',
        'KEY_MINUS': '-', 'KEY_EQUAL': '=', 'KEY_BACKSPACE': 'Backspace', 'KEY_TAB': 'Tab',
        'KEY_Q': 'Q', 'KEY_W': 'W', 'KEY_E': 'E', 'KEY_R': 'R', 'KEY_T': 'T',
        'KEY_Y': 'Y', 'KEY_U': 'U', 'KEY_I': 'I', 'KEY_O': 'O', 'KEY_P': 'P',
        'KEY_LEFTBRACE': '[', 'KEY_RIGHTBRACE': ']', 'KEY_BACKSLASH': '\\', 'KEY_ENTER': 'Enter',
        'KEY_CAPSLOCK': 'CapsLock', 'KEY_A': 'A', 'KEY_S': 'S', 'KEY_D': 'D',
        'KEY_F': 'F', 'KEY_G': 'G', 'KEY_H': 'H', 'KEY_J': 'J', 'KEY_K': 'K', 'KEY_L': 'L',
        'KEY_SEMICOLON': ';', 'KEY_APOSTROPHE': "'", 'KEY_Z': 'Z', 'KEY_X': 'X',
        'KEY_C': 'C', 'KEY_V': 'V', 'KEY_B': 'B', 'KEY_N': 'N', 'KEY_M': 'M',
        'KEY_COMMA': ',', 'KEY_DOT': '.', 'KEY_SLASH': '/', 'KEY_LEFTSHIFT': 'Shift',
        'KEY_RIGHTSHIFT': 'Shift', 'KEY_LEFTCTRL': 'Ctrl', 'KEY_RIGHTCTRL': 'Ctrl',
        'KEY_LEFTALT': 'Alt', 'KEY_RIGHTALT': 'AltGr', 'KEY_SPACE': 'Space',
        'KEY_LEFTMETA': 'Win', 'KEY_RIGHTMETA': 'Win',
        'KEY_UP': 'Up', 'KEY_DOWN': 'Down', 'KEY_LEFT': 'Left', 'KEY_RIGHT': 'Right',
        'KEY_DELETE': 'Del', 'KEY_END': 'End'
    }.get(kc, None)

def draw_keyboard(key_counts, extra_keys):
    os.system('clear')
    print("Keyboard Test (Press ESC 5x to exit)\n")
    for row in key_layout.strip().split('\n'):
        for key in row.strip().split():
            key_clean = key.strip('[]')
            count = key_counts.get(key_clean, 0)
            if count == 0:
                color = 16
                fg = 15
            elif count == 1:
                color = 196
                fg = 15
            elif count == 2:
                color = 33
                fg = 15
            else:
                color = 46
                fg = 0
            print(f"\033[48;5;{color}m\033[38;5;{fg}m {key_clean:^7} \033[0m", end=' ')
        print()
    if extra_keys:
        print("\nExtra Keys Pressed:")
        for k in sorted(extra_keys):
            print(f"[{k}]", end=' ')
        print("\n")

# --- Utility: Check if a keyboard device is present ---
def has_keyboard():
    devices = [InputDevice(path) for path in list_devices()]
    for dev in devices:
        caps = dev.capabilities()
        if dev.name and 'keyboard' in dev.name.lower():
            return True
        # Fallback: check for EV_KEY and basic letter keys
        if ecodes.EV_KEY in caps:
            keys = caps[ecodes.EV_KEY]
            if ecodes.KEY_A in keys and ecodes.KEY_Z in keys:
                return True
    return False

# --- Main keyboard testing function ---
def keyboard_test():
    if not has_keyboard():
        print("No keyboard detected.")
        return

    devices = [InputDevice(path) for path in list_devices()]
    keyboard = None
    for dev in devices:
        if 'keyboard' in dev.name.lower():
            keyboard = dev
            break

    if keyboard is None:
        print("No keyboard found.")
        return

    try:
        keyboard.grab()
    except:
        print("Warning: Could not grab keyboard.")

    key_counts = {}
    extra_keys = set()
    esc_count = 0
    draw_keyboard(key_counts, extra_keys)

    try:
        while True:
            r, _, _ = select.select([keyboard.fd], [], [], 0.1)
            if keyboard.fd in r:
                for event in keyboard.read():
                    if event.type == ecodes.EV_KEY and event.value == 1:
                        key_event = categorize(event)
                        kc = key_event.keycode
                        if isinstance(kc, list):
                            kc = kc[0]
                        keyname = map_keycode_to_name(kc)
                        if keyname:
                            key_counts[keyname] = key_counts.get(keyname, 0) + 1
                        elif kc not in ('KEY_MENU', 'KEY_GRAVE'):
                            extra_keys.add(kc)
                        if keyname == 'Esc':
                            esc_count += 1
                            if esc_count >= 5:
                                keyboard.ungrab()
                                return
                        else:
                            esc_count = 0
                        draw_keyboard(key_counts, extra_keys)
    except KeyboardInterrupt:
        try:
            keyboard.ungrab()
        except:
            pass

# --- Main runner ---
def main():
    try:
        print_color_screen()
        vintage_tv_bars()
        keyboard_test()
    except Exception as e:
        print(f"Error: {e}")
    finally:
        print("\033[0m")
        os.system("clear")

if __name__ == '__main__':
    main()

#   _   _ _               _           
#  | \ | (_) ___ ___   __| | _____  __
#  |  \| | |/ __/ _ \ / _` |/ _ \ \/ /
#  | |\  | | (_| (_) | (_| |  __/>  < 
#  |_| \_|_|\___\___/ \__,_|\___/_/\_\
#                                     
