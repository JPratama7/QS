# Quickshell Desktop Architecture

> **Status**: MVP Complete
> **Last Updated**: 2026-04-20

This document provides a comprehensive overview of the Quickshell desktop shell architecture.

---

## Overview

A lightweight, compositor-agnostic Wayland desktop shell built on Quickshell, featuring:

- Per-monitor system bar with widgets
- Overlay application launcher
- System tray support
- Session/power management
- Auto-hide behavior

---

## Design Principles

1. **Compositor-Agnostic First** - Compositor-specific logic isolated to backend adapters
2. **Explicit Typing** - Use `ShellScreen` and `ScreenContext` types, not `var`
3. **Service Layer Pattern** - UI modules depend on services, services depend on backends
4. **Signal-Driven State** - Reactive updates via QML signals, not polling
5. **Surface Lifecycle Clarity** - Each window type has explicit ownership and focus policy

---

## Surface Topology

| Surface | Count | Layer | Keyboard Focus | Exclusion | Purpose |
|---------|-------|-------|----------------|-----------|---------|
| `BarContentWindow` | per screen | `Top` | `None` | `Auto` | Visible bar UI + space reservation |
| `BarTriggerZone` | per screen (auto-hide) | `Top` | `None` | `Ignore` | Edge strip for auto-hide reveal |
| `PopupMenuWindow` | per screen | `Top` | `OnDemand` | `Ignore` | Tray/session menus |
| `LauncherOverlayWindow` | one screen | `Overlay` | `Exclusive` | `Ignore` | Full-screen launcher overlay |

### Exclusion Behavior

- **Visible + exclusive**: `exclusiveZone = barHeight` (apps pushed below)
- **Hidden (auto-hide)**: `exclusiveZone = 0` (apps can overlap)
- **Fullscreen app**: Bar hidden, `exclusiveZone = 0`

---

## Directory Structure

```
shell.qml                    # Root composition (minimal)

config/                      # Configuration singletons
  ShellConfig.qml            # User config loader
  Defaults.qml               # Default values
  Theme.qml                  # Theme constants
  PersistentConfig.qml       # Disk persistence

types/                       # Data types
  ScreenContext.qml          # Screen wrapper with derived properties
  LauncherResult.qml         # Normalized launcher result
  TrayMenuRequest.qml        # Tray menu request payload

modules/                     # UI modules
  screens/                   # Per-screen orchestration
    ScreenShells.qml         # Variants model
    ScreenShellDelegate.qml   # Per-screen delegate
  bar/                       # Bar UI
    BarContentWindow.qml     # Bar window
    BarView.qml              # Bar content
    BarLayout.qml            # Widget layout
    BarTriggerZone.qml       # Auto-hide trigger
    widgets/                 # Bar widgets
  popups/                    # Popup windows
    PopupMenuWindow.qml      # Popup stage
    SessionMenu.qml          # Session/power menu
    ConfirmActionDialog.qml  # Confirmation overlay
  launcher/                  # Overlay launcher
    LauncherOverlayWindow.qml
    LauncherView.qml
    LauncherResultsList.qml
    LauncherSearchField.qml
  ipc/                       # IPC handlers
    ShellIpc.qml             # Shell control IPC

components/                  # Reusable components
  containers/
    ShellWindow.qml          # Base window wrapper

services/                    # Business logic services
  ui/                        # UI coordination
    ScreenRegistry.qml       # Screen enumeration
    ShellUI.qml              # Popup/launcher coordination
    BarVisibility.qml        # Bar visibility state
  compositor/                # Compositor abstraction
    Compositor.qml           # Normalized interface
    backends/
      Hyprland.qml           # Hyprland implementation
      Generic.qml            # Fallback implementation
  launcher/                  # Launcher logic
    Launcher.qml             # Launcher state
    LauncherProviderRegistry.qml
    providers/
      ApplicationsProvider.qml
  system/                    # System services
    AppIcons.qml             # Icon resolution
    Audio.qml                # Volume control
    Network.qml              # Network state
    SessionActions.qml       # Power actions
```

---

## Service Architecture

### UI Services

#### ScreenRegistry
- Enumerates enabled screens (excludes configured patterns)
- Creates `ScreenContext` instances
- Provides `screenByName()` lookup

#### ShellUI
- Coordinates popup and launcher lifecycle
- Enforces mutual exclusion (popup OR launcher, not both)
- Tracks open popup screens
- Handles screen removal cleanup

#### BarVisibility
- Per-screen visibility state (display mode, hover, popup, fullscreen)
- Auto-hide timer management
- Fullscreen detection via `Compositor.activeToplevelChanged`
- `effectiveVisible()` computes final visibility

### Compositor Service

#### Compositor
- Detects compositor type (Hyprland/Generic)
- Loads appropriate backend dynamically
- Normalized API:
  - `focusedScreenName()`
  - `workspacesForScreen(screenName)`
  - `activeWindowForScreen(screenName)`
  - `screenHasFullscreen(screenName)`
  - `switchWorkspace(screenName, id)`

#### Backend Pattern
```qml
QtObject {
    readonly property string name: "hyprland" | "generic"
    
    function focusedScreenName(): string
    function workspacesForScreen(screenName: string): var
    function activeWindowForScreen(screenName: string): var
    function screenHasFullscreen(screenName: string): bool
    function switchWorkspace(screenName: string, id: int): void
}
```

### Launcher Service

#### Launcher
- Manages query, results, selection state
- `open(screenName)` / `close()` / `toggle()`
- `activateSelected()` executes result action
- Emits signals for UI binding

#### LauncherProviderRegistry
- Provider registration (self-registration pattern)
- Dispatches `search(query)` to all providers
- Aggregates and deduplicates results

#### Provider Pattern
```qml
QtObject {
    id: provider
    property string name: "applications"
    property int priority: 100  // lower = higher priority
    
    function search(query: string): var  // returns LauncherResult[]
    function activate(data: var): void
    
    Component.onCompleted: LauncherProviderRegistry.register(provider)
}
```

---

## Data Flow

### Popup Flow
```
Widget.onClick
  -> ShellUI.openPopup(screenName, popupId, component, anchorX)
    -> closeLauncher() if open
    -> popupRequested signal
      -> PopupMenuWindow.onPopupRequested
        -> Loader loads component
        -> visible = true
        -> grabFocus = true
```

### Launcher Flow
```
IPC call / LauncherButton.onClick
  -> Launcher.open(screenName)
    -> ShellUI.openLauncher(screenName)
      -> closeAllPopups()
      -> launcherOpened signal
        -> ScreenShellDelegate.Loader.active = true
          -> LauncherOverlayWindow instantiated
            -> WlrKeyboardFocus = Exclusive
```

### Fullscreen Flow
```
Window focus change
  -> Compositor.activeToplevelChanged
    -> BarVisibility.onActiveToplevelChanged
      -> screenHasFullscreen() for each screen
        -> setFullscreen() if changed
          -> effectiveVisible() returns false
            -> BarContentWindow.visible = false
              -> exclusiveZone = 0
```

---

## IPC Interface

Compositor-agnostic control via `qs ipc call shell <function>`:

| Function | Args | Description |
|----------|------|-------------|
| `toggleLauncher` | - | Toggle launcher on primary/first screen |
| `openLauncher` | `screen?` | Open launcher on specified screen |
| `closeLauncher` | - | Close launcher |
| `isLauncherOpen` | - | Returns boolean |

### Keybind Integration (Hyprland)
```ini
bind = SUPER, R, exec, qs ipc call shell toggleLauncher
```

---

## Configuration

### config.json
```json
{
  "primaryScreen": "",
  "barHeight": 32,
  "barDisplayMode": "visible",
  "barEdge": "top",
  "excludedScreens": []
}
```

### Display Modes
- `visible` - Always visible, reserves space
- `auto_hide` - Hidden by default, appears on hover/edge trigger
- `hidden` - Never visible
- `non_exclusive` - Visible but doesn't reserve space

---

## Key Implementation Decisions

See `docs/IMPLEMENTATION-NOTES.md` for detailed deviations from original design:

1. **IPC Module** - Compositor-agnostic keybinds via `IpcHandler`
2. **Launcher Lazy Loading** - Wrapped in `Loader` for performance
3. **Provider Self-Registration** - Providers register on init
4. **Event-Driven Fullscreen** - Signal-based, not polling
5. **Mutual Exclusion** - Popup and launcher cannot coexist
6. **Screen Removal Cleanup** - State cleaned on monitor disconnect

---

## Import Pattern

Relative path imports (Quickshell VFS requirement):

```qml
import "../../config"
import "../../types"
import "../../services/ui"
import "../../services/compositor"
```

---

## Extension Points

### Adding a Widget
1. Create in `modules/bar/widgets/`
2. Register in `modules/bar/qmldir`
3. Add to `BarLayout.qml` in appropriate zone

### Adding a Service
1. Create in appropriate `services/` subdirectory
2. Register in `services/qmldir` as singleton
3. Import via relative path from consumers

### Adding a Launcher Provider
1. Create in `services/launcher/providers/`
2. Implement `search()` and `activate()`
3. Self-register in `Component.onCompleted`

### Adding a Compositor Backend
1. Create in `services/compositor/backends/`
2. Implement normalized interface
3. Never import from `modules/` or `components/`

---

## References

- Design Doc: `docs/Quickshell-Desktop-DESIGN-v2.md`
- Implementation Notes: `docs/IMPLEMENTATION-NOTES.md`
- PRD: `docs/Quickshell-Desktop-PRD.md`
- Dev Workflow: `docs/DEV-WORKFLOW.md`
- Quickshell Docs: https://quickshell.org/docs/master/
