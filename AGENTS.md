# AGENTS.md

Guides for AI agents working on this Quickshell desktop shell project.

---

## Project Overview

This is a **Quickshell-based Wayland desktop shell** implementing:
- System bar with widgets (workspaces, clock, tray, etc.)
- Overlay application launcher
- System tray support
- Notification indicator
- Session/power menu
- IPC interface for compositor-agnostic keybinds

**Target**: Linux Wayland, compositor-agnostic with Hyprland backend support.

**Status**: MVP complete, stable for daily use.

---

## Architecture Principles

### 1. Explicit Typing

Always use explicit QML typing with `ShellScreen`:

```qml
// GOOD
property ShellScreen screen

// BAD - untyped
property var screen
```

### 2. Screen Context Pattern

Pass `ScreenContext` objects through the component tree, not raw `ShellScreen` values:

```qml
// types/ScreenContext.qml wraps ShellScreen with derived properties
property ScreenContext context
```

### 3. Service Layer

UI modules depend on services, services may depend on backends, backends depend on compositor APIs. **UI modules never import compositor-specific APIs directly.**

```
modules/  -->  services/  -->  services/compositor/backends/
```

### 4. Popup Lifecycle

Popup windows are owned by their source component. `PopupMenuWindow` is the shared popup stage for tray and session menus.

### 5. No Background Layer

No wallpaper management - external wallpaper app handles this.

### 6. No WlrLayer.Overlay for Bar

Bar uses `Top` layer, not `Overlay`. Only `LauncherOverlayWindow` uses `Overlay` layer.

---

## File Structure

```
shell.qml              # Root composition - keep minimal

config/                # Configuration singletons
  ShellConfig.qml      # User config loader
  Defaults.qml         # Default values
  Theme.qml            # Theme constants
  PersistentConfig.qml # Persistent storage

types/                 # Data types
  ScreenContext.qml    # Screen wrapper with derived properties
  LauncherResult.qml   # Normalized launcher result
  TrayMenuRequest.qml  # Tray menu request payload

modules/
  screens/             # Per-screen orchestration
    ScreenShells.qml
    ScreenShellDelegate.qml
  bar/                 # Bar UI
    BarContentWindow.qml
    BarView.qml
    BarLayout.qml
    BarTriggerZone.qml
    widgets/           # Bar widgets
  popups/              # Popup windows
  launcher/            # Overlay launcher
  ipc/                 # IPC handlers
    ShellIpc.qml       # Shell control IPC

components/
  containers/
    ShellWindow.qml    # Base window wrapper

services/
  ui/                  # UI coordination services
    ScreenRegistry.qml
    ShellUI.qml
    BarVisibility.qml
  compositor/          # Compositor abstraction
    Compositor.qml
    backends/          # Compositor-specific implementations
      Hyprland.qml
      Generic.qml
  launcher/            # Launcher logic
    Launcher.qml
    LauncherProviderRegistry.qml
    providers/         # Launcher providers
      ApplicationsProvider.qml
  system/              # System services (audio, network, etc.)
```

---

## Import Pattern

Use relative path imports (Quickshell VFS requirement):

```qml
import "../../config"
import "../../types"
import "../bar"
import "../../components/containers"
```

---

## Key Design Decisions

### ExclusionMode

- `BarContentWindow` uses `ExclusionMode.Auto` with dynamic `exclusiveZone`
- When visible and exclusive: `exclusiveZone = barHeight`
- When hidden (auto-hide): `exclusiveZone = 0`

### Multi-Instance Testing

Two `Top`-layer bars from different Quickshell instances overlap unpredictably. Always kill the live shell before testing:

```sh
quickshell kill
quickshell -p /home/xoid/projects/private/qs-rework
```

### ShellScreen API

Available properties: `name`, `model`, `serialNumber`, `x`, `y`, `width`, `height`, `physicalPixelDensity`, `logicalPixelDensity`, `devicePixelRatio`, `orientation`, `primaryOrientation`.

**NOT available**: `.geometry`, `.scale`, `.primary`.

---

## Verification Levels

1. **Static**: File opens in IDE without unresolved imports
2. **Smoke**: Shell launches without crashing
3. **Interaction**: Manual exercise of new widget/popup/overlay behavior
4. **Regression**: Previously working surfaces still load correctly

---

## Common Tasks

### Adding a Widget

1. Create in `modules/bar/widgets/`
2. Register in `modules/bar/qmldir`
3. Add to `BarLayout.qml` in correct zone (left/center/right)
4. If needs data: create or use existing service
5. Verify: static -> smoke -> interaction

### Adding a Service

1. Create in appropriate `services/` subdirectory
2. Register in `services/qmldir` as singleton
3. Import via relative path from consumers
4. Keep compositor-specific imports in backends only

### Adding a Compositor Backend

1. Create in `services/compositor/backends/`
2. Implement normalized interface (see `Compositor` contract)
3. Never import from `modules/` or `components/`

### Adding a Launcher Provider

1. Create in `services/launcher/providers/`
2. Implement `search(query: string): var` returning `LauncherResult[]`
3. Implement `activate(data: var): void`
4. Self-register in `Component.onCompleted`: `LauncherProviderRegistry.register(provider)`
5. Set `priority` property (lower = higher priority in results)

---

## Code Style

- **Clarity over brevity** - understandable code over clever tricks
- **Descriptive names** - self-explanatory variable/function names
- **Small functions** - one responsibility per function
- **Comments for "why"** - explain complex logic rationale, not what

### QML Conventions

- Property declarations at top of component
- Signal handlers below properties
- Child components last
- Use `id:` for internal references, `property alias` for external API

---

## Quickshell Reference

### Core Components

#### ShellRoot
Optional root configuration element for specifying settings inline:
```qml
ShellRoot {
    settings.watchFiles: true  // auto-reload on file changes (default: true)
}
```

#### PanelWindow
Decorationless window attached to screen edges:
```qml
PanelWindow {
    anchors { left: true; top: true; right: true }
    exclusiveZone: 32           // space reserved for shell layer
    exclusionMode: ExclusionMode.Auto
    focusable: false            // keyboard focus (default: false)
    aboveWindows: true          // render above standard windows
}
```

#### PopupWindow
Popup positioned relative to a parent window:
```qml
PopupWindow {
    anchor.window: parentWindow
    anchor.rect.x: parentWindow.width / 2 - width / 2
    anchor.rect.y: parentWindow.height
    grabFocus: true             // dismiss on click outside
    visible: false
}
```

### ExclusionMode Variants

- **Ignore**: Ignore exclusion zones of other shell layers. Cannot set exclusive zone.
- **Auto**: Decide exclusion zone based on window dimensions and anchors (3 anchors connected).
- **Normal**: Respect exclusion zones of others and optionally set one.

### WlrLayershell (Wayland)

Attached to PanelWindow for layer control:
```qml
PanelWindow {
    Component.onCompleted: {
        if (this.WlrLayershell != null) {
            this.WlrLayershell.layer = WlrLayer.Top;  // Bottom, Top, Overlay
            this.WlrLayershell.keyboardFocus = WlrKeyboardFocus.None;  // None, OnDemand, Exclusive
        }
    }
}
```

### ShellScreen Properties

Read-only monitor information:
- `name` - Display name (e.g., "DP-1", "HDMI-1")
- `model` - Model name from OS
- `serialNumber` - Monitor serial
- `x`, `y` - Position coordinates
- `width`, `height` - Dimensions
- `devicePixelRatio` - Physical to logical pixel ratio
- `physicalPixelDensity`, `logicalPixelDensity` - Pixels per mm
- `orientation`, `primaryOrientation` - Screen orientation

### Configuration Persistence

#### FileView + JsonAdapter (disk-persistent)
```qml
FileView {
    path: Quickshell.shellDir + "/config.json"
    watchChanges: true
    onFileChanged: reload()
    onAdapterUpdated: writeAdapter()

    JsonAdapter {
        property string primaryScreen: ""
        property int barHeight: 32
    }
}
```

#### PersistentProperties (reload-persistent, not disk-persistent)
```qml
PersistentProperties {
    id: persist
    reloadableId: "uniqueId"    // required for state tracking
    property bool popupOpen: false
}
```

### Quickshell Singleton

Directory paths:
- `Quickshell.shellDir` - Shell root directory
- `Quickshell.dataDir` - Persistent data
- `Quickshell.stateDir` - Application state
- `Quickshell.cacheDir` - Cached files

Path helpers:
- `Quickshell.shellPath(path)` - Resolve relative to shellDir
- `Quickshell.dataPath(path)` - Resolve relative to dataDir

### LazyLoader

Async loading for heavy components:
```qml
LazyLoader {
    id: popupLoader
    loading: true               // start background loading
    PopupWindow { ... }
}
```

### Official Documentation

- **Docs**: https://quickshell.org/docs/master/
- **Types Reference**: https://quickshell.org/docs/master/types/
- **Examples**: https://quickshell.org/docs/master/examples/

---

## References

- Architecture: `ARCHITECTURE.md`
- README: `README.md`
- Design Doc: `docs/Quickshell-Desktop-DESIGN-v2.md`
- Implementation Notes: `docs/IMPLEMENTATION-NOTES.md`
- PRD: `docs/Quickshell-Desktop-PRD.md`
- Dev Workflow: `docs/DEV-WORKFLOW.md`
- Implementation Plan: `docs/plans/2026-04-12-quickshell-desktop-implementation-plan.md`
