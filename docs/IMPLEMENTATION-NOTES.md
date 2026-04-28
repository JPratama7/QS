# Implementation Notes

> **Status**: Iterations 0-5 complete, Iteration 6 in progress
> **Last Updated**: 2026-04-19

This document records architecture decisions made during implementation that deviate from or extend the original design.

---

## Architecture Deviations

### 1. IPC Module for Compositor-Agnostic Keybinds

**Design**: Global shortcuts were planned as compositor-specific (e.g., Hyprland `GlobalShortcut`).

**Implementation**: Created `modules/ipc/ShellIpc.qml` using `IpcHandler` for compositor-agnostic keybinds.

**Rationale**: 
- `IpcHandler` works on any compositor Quickshell supports
- Users bind keys via their compositor's config: `bind = SUPER, R, exec, qs ipc call shell toggleLauncher`
- No compositor-specific imports in `shell.qml`

**Files**:
- `modules/ipc/ShellIpc.qml` - IPC handler singleton
- `modules/ipc/qmldir` - module registration
- `modules/ipc/README.md` - usage documentation

---

### 2. Launcher Lazy Loading via Loader

**Design**: `LauncherOverlayWindow` was to be instantiated per-screen with visibility binding.

**Implementation**: Wrapped in `Loader` in `ScreenShellDelegate.qml` for lazy instantiation.

**Rationale**:
- Launcher is heavy (DesktopEntries parsing, result list)
- Only instantiated when actually opened
- `Loader.active = true` on `ShellUI.launcherOpened` signal

**Files**:
- `modules/screens/ScreenShellDelegate.qml` - Loader wrapper

---

### 3. Launcher Provider Self-Registration

**Design**: Providers were to be registered externally.

**Implementation**: Providers self-register in `Component.onCompleted` via `LauncherProviderRegistry.register()`.

**Rationale**:
- Simpler initialization flow
- Providers are singletons that manage their own lifecycle
- Registry just maintains a list and dispatches search/activate

**Files**:
- `services/launcher/providers/ApplicationsProvider.qml`
- `services/launcher/LauncherProviderRegistry.qml`

---

### 4. File Naming Convention

**Design**: Service files used `*Service.qml` suffix (e.g., `ShellUIService.qml`).

**Implementation**: Dropped `Service` suffix for brevity (e.g., `ShellUI.qml`).

**Rationale**:
- QML type names already indicate purpose
- Reduces verbosity in imports and references
- Consistent with singleton pattern

---

### 5. Fullscreen Detection via Active Toplevel Signal

**Design**: Periodic polling for fullscreen state.

**Implementation**: Event-driven via `Compositor.activeToplevelChanged` signal.

**Rationale**:
- No unnecessary CPU cycles
- Immediate response to fullscreen transitions
- `BarVisibility` updates state on signal

**Files**:
- `services/ui/BarVisibility.qml` - Connections to Compositor

---

### 6. Mutual Exclusion for Popup and Launcher

**Design**: Not explicitly specified.

**Implementation**: `ShellUI.openPopup()` closes launcher, `ShellUI.openLauncher()` closes all popups.

**Rationale**:
- Prevents focus conflicts
- Only one modal surface active at a time
- Clean state transitions

**Files**:
- `services/ui/ShellUI.qml`

---

### 7. Screen Removal State Cleanup

**Design**: Not explicitly specified.

**Implementation**: `ShellUI` tracks known screens and cleans up popup/launcher state on screen removal.

**Rationale**:
- Prevents orphaned state when monitors disconnect
- `Quickshell.onScreensChanged` triggers cleanup
- Launcher/popup targeting removed screen closes gracefully

**Files**:
- `services/ui/ShellUI.qml` - screen tracking and cleanup

---

## Follow-Up Items (Post-MVP)

### High Priority

1. **Session Actions Implementation** - `SessionActions.execute()` currently logs stubs. Need:
   - `lock`: integrate with loginctl/swaylock
   - `suspend`: systemd loginctl
   - `logout`: hyprctl dispatch exit (or compositor-specific)
   - `reboot/shutdown`: systemd logind

2. **Notification Service** - `Notification.qml` exists but not wired to bar indicator. Need:
   - D-Bus notification listener
   - Notification count state
   - Notification indicator widget update

3. **Tray Menu Positioning** - Tray menus anchor to bar correctly, but need:
   - Scroll support for long menus
   - Nested submenu support

### Medium Priority

4. **Launcher Provider Ecosystem** - Currently only `ApplicationsProvider`. Future:
   - Recent files provider
   - Calculator/provider for math expressions
   - Web search provider

5. **Workspace Widget Dynamic Model** - Currently shows 10 static buttons. Should:
   - Query actual workspace count from compositor
   - Support workspace renames

6. **Audio Service Hardening** - `Audio.qml` uses PipeWire. Need:
   - PulseAudio fallback
   - Device selection

### Low Priority

7. **Network Service** - `Network.qml` exists but not wired. Need:
   - NetworkManager D-Bus integration
   - Connection state display

8. **Battery Service** - `Battery.qml` exists but not wired. Need:
   - UPower D-Bus integration
   - Battery level display

9. **Auto-Hide Animation** - Currently instant hide/show. Could add:
   - Slide animation via transform
   - Fade animation for launcher

---

## Known Lint False Positives

The following qmllint warnings are false positives in this environment:

- `PanelWindow is not creatable` - PanelWindow is a Quickshell type
- `GlobalShortcut is not resolved` - Hyprland-specific type
- `Member "start" not found on type "QObject"` - Dynamic Timer creation in BarVisibility

These can be safely ignored.
