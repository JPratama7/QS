# Quickshell Desktop

A lightweight, compositor-agnostic Wayland desktop shell built on [Quickshell](https://quickshell.org/).

## Features

- **Per-monitor system bar** with widgets:
  - Workspace indicator
  - Active window title
  - Clock/date
  - Network, volume, battery indicators
  - System tray
  - Session/power menu
- **Overlay application launcher** with:
  - Desktop entry search
  - Keyboard navigation
  - Fuzzy matching
- **Clipboard history popup** (cliphist) with:
  - Searchable clipboard entries
  - Keyboard navigation
  - One-key copy and close
- **Auto-hide support** with edge trigger zones
- **Multi-monitor** with hotplug handling (MVP)
- **Compositor-agnostic**

## Requirements

- Linux with Wayland compositor
- Quickshell (see [installation](https://quickshell.org/docs/master/install/))
- Qt 6.5+
- [cliphist](https://github.com/sentriz/cliphist) — clipboard history manager (required for the clipboard popup)
- [wl-clipboard](https://github.com/bugaevc/wl-clipboard) — Wayland clipboard utility (`wl-copy`, used by the clipboard popup)

## Installation

1. Install Quickshell:
   ```bash
   # Arch Linux (AUR)
   yay -S quickshell-git

   # NixOS
   nix profile install github:outfoxxed/quickshell
   ```

2. Clone this repository:
   ```bash
   git clone <repo-url> ~/.config/quickshell/my-shell
   ```

3. Run:
   ```bash
   quickshell -p ~/.config/quickshell/my-shell
   ```

## Configuration

Edit `config.json` in the shell directory:

```json
{
  "primaryScreen": "",
  "barHeight": 32,
  "barDisplayMode": "visible",
  "barEdge": "top",
  "excludedScreens": [],
  "triggerZoneHeight": 4,
  "launcherWidth": 560,
  "launcherMaxResults": 8,
  "popupEdgeMargin": 8,
  "toastPosition": "top-right",
  "toastMaxStack": 3,
  "toastDurationMs": 5000,
  "trayHiddenIds": [],
  "trayMenuMaxHeight": 400,
  "idleInhibitor": false,
  "bar": {
    "tooltip": { "enabled": true, "delayMs": 300 },
    "widgets": {
      "scale": 1.0,
      "workspaces": { "showText": true },
      "activeWindow": { "maxTextWidth": 200 }
    }
  },
  "barWidgetLayout": {
    "left": ["launcher", "workspaces", "activeWindow"],
    "center": ["clock"],
    "right": ["network", "volume", "battery", "idleInhibitor", "notifications", "tray", "session"]
  },
  "barWidgetLayoutPerScreen": {}
}
```

### Display Modes

| Mode | Behavior |
|------|----------|
| `visible` | Always visible, reserves screen space |
| `auto_hide` | Hidden by default, appears on edge hover |
| `hidden` | Never visible |
| `non_exclusive` | Visible but doesn't reserve space |

### Excluding Screens

Exclude screens by name pattern (regex):

```json
{
  "excludedScreens": ["^HDMI-", "Virtual-1"]
}
```

### Bar Widget Layout

Configure widgets per zone (left/center/right):

```json
{
  "barWidgetLayout": {
    "left": ["launcher", "workspaces", "activeWindow"],
    "center": ["clock"],
    "right": ["network", "volume", "battery", "idleInhibitor", "notifications", "tray", "session"]
  }
}
```

Available widgets: `launcher`, `workspaces`, `activeWindow`, `clock`, `network`, `volume`, `battery`, `idleInhibitor`, `notifications`, `tray`, `session`, `systemMonitor`, `taskbar`

Per-screen override:

```json
{
  "barWidgetLayoutPerScreen": {
    "DP-1": { "left": ["workspaces"], "center": [], "right": ["clock", "tray"] }
  }
}
```

### Idle Inhibition

Enable idle inhibition (prevents screen sleep):

```json
{
  "idleInhibitor": true
}
```

> **Note**: If `primaryScreen` is empty, it will automatically be set to the first available screen on startup.

### Notifications

Configure toast notifications:

```json
{
  "toastPosition": "top-right",
  "toastMaxStack": 3,
  "toastDurationMs": 5000
}
```

## Keybinds

### Hyprland

Add to `~/.config/hypr/hyprland.conf`:

```ini
bind = SUPER, R, exec, qs ipc call launcher toggleLauncher
bind = SUPER, V, exec, qs ipc call cliphist toggleCliphist
```

### Sway

Add to `~/.config/sway/config`:

```
bindsym $mod+r exec qs ipc call launcher toggleLauncher
bindsym $mod+v exec qs ipc call cliphist toggleCliphist
```

### Other Compositors

Use your compositor's keybind configuration to execute:

```bash
qs ipc call launcher toggleLauncher
qs ipc call cliphist toggleCliphist
```

## IPC Commands

Control the shell via IPC:

```bash
# Launcher
qs ipc call launcher toggleLauncher
qs ipc call launcher openLauncher DP-1   # open on specific screen
qs ipc call launcher closeLauncher
qs ipc call launcher isLauncherOpen

# Clipboard (cliphist)
qs ipc call cliphist toggleCliphist
qs ipc call cliphist openCliphist DP-1   # open on specific screen
qs ipc call cliphist closeCliphist
qs ipc call cliphist isCliphistOpen
```

## Architecture

See [ARCHITECTURE.md](./ARCHITECTURE.md) for detailed architecture documentation.

### Key Components

```
shell.qml              # Root composition
config/                # Configuration singletons
modules/               # UI modules (bar, launcher, popups)
services/              # Business logic services
  ui/                  # UI coordination
  compositor/          # Compositor abstraction
  launcher/            # Launcher logic
  system/              # System services
```

## Development

### Running for Development

```bash
# Kill any running instance
quickshell kill

# Run with live reload
quickshell -p /path/to/shell
```

### File Structure

See [AGENTS.md](./AGENTS.md) for development guidelines and conventions.

### Adding Widgets

1. Create widget in `modules/bar/widgets/`
2. Register in `modules/bar/qmldir`
3. Add to `BarLayout.qml` in appropriate zone (left/center/right)

### Adding Launcher Providers

1. Create provider in `services/launcher/providers/`
2. Implement `search(query)` and `activate(data)`
3. Self-register via `LauncherProviderRegistry.register()`

## Documentation

- [ARCHITECTURE.md](./ARCHITECTURE.md) - System architecture
- [AGENTS.md](./AGENTS.md) - Development guidelines
- [docs/IMPLEMENTATION-NOTES.md](./docs/IMPLEMENTATION-NOTES.md) - Implementation decisions
- [docs/Quickshell-Desktop-DESIGN-v2.md](./docs/Quickshell-Desktop-DESIGN-v2.md) - Design document

## License

[GPL 2](./LICENSE.md)


## Credits

- Built on [Quickshell](https://quickshell.org/)
- Inspired by reference shells in the Quickshell ecosystem
