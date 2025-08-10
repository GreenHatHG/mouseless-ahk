# AHK Windows Utils: Keyboard-driven Controls for Windows

This is an [AutoHotkey v2](https://www.autohotkey.com/) script that provides keyboard-centric controls for mouse movement, window management, and more on Windows.

## Features

### Core Functions

| Hotkey              | Action                       |
| ------------------- | ---------------------------- |
| `Alt + O`           | Left Mouse Click             |
| `Alt + A`           | Right Mouse Click            |
| `Alt + Shift + Q`   | Close Active Window          |
| `Alt + Win + J/K`   | Scroll Down/Up (hold for continuous) |
| `Alt + C`           | Move mouse to center of the active window |
| `Alt + T`           | Move mouse to center of the screen |

### Mouse Movement

| Hotkey              | Action                                   |
| ------------------- | ---------------------------------------- |
| `Ctrl + Alt + h/j/k/l` | Move mouse left/down/up/right (accelerates on hold) |
| `Alt + gg` (double-tap) | Move mouse to the top-center of the active window |
| `Alt + G` (`Alt+Shift+g`) | Move mouse to the bottom-center of the active window |
| `Alt + 0`           | Move mouse to the middle-left of the active window |
| `Alt + $` (`Alt+Shift+4`) | Move mouse to the middle-right of the active window |

### Window Move Mode

1.  Press `Alt + M` to enter **Move Mode**.
2.  Use the `Arrow Keys` to move the active window.
3.  Press `Enter` or `Escape` to confirm and exit Move Mode.

### Window Resize Mode

1.  Press `Alt + R` to enter **Resize Mode**.
2.  Use the `Arrow Keys` to resize the active window.
3.  Press `Enter` or `Escape` to confirm and exit Resize Mode.

## Installation

1.  **Install AutoHotkey v2:** Download and install the latest version from the [official AutoHotkey website](https://www.autohotkey.com/).
2.  **Download the script:** Save the `windows.ahk` file to your computer.
3.  **Run the script:** Double-click `windows.ahk` to run it. The script will automatically request administrator privileges, which are required for some window management functions.

## Configuration

You can customize the script's behavior by editing the global variables at the top of the `windows.ahk` file:

-   `MoveStep`: The number of pixels to move a window in Move Mode.
-   `ResizeStep`: The number of pixels to resize a window in Resize Mode.
-   `MouseMoveStep`: The initial speed (in pixels) for mouse movement.
-   `MouseAcceleration`: The acceleration multiplier for mouse movement when a key is held down.
-   `MouseMaxSpeed`: The maximum speed (in pixels) for mouse movement.
-   `LongPressThreshold`: The time in seconds to register a key press as a long press (not currently used in hotkeys but available for customization).
