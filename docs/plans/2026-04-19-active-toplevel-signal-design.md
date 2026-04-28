# Active Toplevel Changed Signal Design (2026-04-19)

## Purpose
Expose a QML signal that notifies the rest of Quickshell when the active window (toplevel) changes. This enables UI components such as the bar, pop‑ups, or custom widgets to react instantly to window focus changes.

## Public API (Compositor.qml)
```qml
signal activeToplevelChanged(data: var)
```
- **data** – an object containing at least:
  - `title`: window title
  - `class`: workspace/class name (may be empty)
  - `monitor`: the `ShellScreen` object representing the monitor
  - `pid`: placeholder for process id (currently `0`)

The signal is forwarded from the active compositor backend via a `Connections` block.

## Backend Contract
All compositor backends must declare the same signal:
```qml
signal activeToplevelChanged(data: var)
```
- **Hyprland backend** – listens to `Hyprland`'s `onActiveToplevelChanged` event and emits the signal with the raw `Hyprland.activeToplevel` object.
- **Generic backend** – declares the signal but never emits it (no‑op), providing a consistent API for future backends.

## Implementation Details
1. **Hyprland.qml**
   - Added `signal activeToplevelChanged(data: var)`.
   - Connected to `Hyprland` via a `Connections` block and re‑emitted the event:
   ```qml
   Connections {
       target: Hyprland
       function onActiveToplevelChanged() {
           activeToplevelChanged(Hyprland.activeToplevel);
       }
   }
   ```
2. **Generic.qml**
   - Declared the same signal at the top of the object.
3. **Compositor.qml**
   - Updated the `Connections` block to listen for `activeToplevelChanged` from the backend, log the payload, and re‑emit the top‑level signal.

## Testing Strategy
- **Unit test (QML TestCase)** that loads `Compositor.qml` with a mock backend emitting `activeToplevelChanged` and asserts the top‑level signal is received with the expected payload.
- **Manual integration test** on a Hyprland session: switch windows and verify the console log from `Compositor.qml` appears.

## Future Work
- Extend the payload with `pid` and other metadata when the compositor provides it.
- Add similar handling for other backends (e.g., Niri, River) by implementing the same signal contract.

---
*Design authored on 2026‑04‑19 as part of the Quickshell desktop implementation plan.*
