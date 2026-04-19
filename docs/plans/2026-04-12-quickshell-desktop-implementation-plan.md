# Quickshell Desktop Environment Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Implement the Quickshell desktop MVP from the PRD and design doc using very small, stable iterations that produce a usable bar first, then the popup stack, then the launcher.

**Architecture:** The shell is built from a small set of per-screen layer-shell surfaces plus one screen-targeted overlay launcher. UI modules consume normalized services and types; compositor-specific behavior stays behind adapter backends; popup and overlay coordination stays centralized.

**Tech Stack:** Quickshell, QML, QtQuick, Wayland layer-shell, compositor adapter services, system integration services, docs-first workflow.

---

## 1) Source Documents

Use these as the source of truth while executing this plan:

- `docs/Quickshell-Desktop-PRD.md`
- `docs/Quickshell-Desktop-DESIGN.md`
- `.qmlls.ini`

If the code diverges from these docs during execution, update the docs or stop and resolve the mismatch before continuing.

---

## 2) Planning Principles

This plan intentionally keeps tasks small.

- Each task should add **one behavior** or **one structural building block**.
- Avoid combining a **new surface** and a **new stateful service** in the same task unless the surface cannot render without it.
- Stop after each task at a state that is at least **loadable**, **inspectable in the IDE**, or **manually smoke-testable**.
- Prefer placeholder UI over incomplete business logic.
- Prefer stub services over prematurely “smart” services.
- If a task grows during implementation, split it before writing code.
- Do not pull deferred scope forward:
  - no dock,
  - no notification history panel,
  - no per-monitor bar layout variation,
  - no extra launcher providers beyond applications,
  - no control center.

### Task Size Target

Target each task to fit within one focused implementation pass.

Good tasks:

- create a single service contract,
- create one window shell,
- wire one widget to one service,
- connect one trigger path,
- validate one risky interaction.

Avoid tasks like:

- “implement the whole bar”,
- “implement all widgets”,
- “finish launcher system”,
- “handle all compositor cases”.

---

## 3) Verification Model

The repository does not yet expose a stable runtime workflow. Because of that, the first implementation iteration must establish one.

Use these verification levels throughout the plan:

- **Static verification**
  - local imports resolve in the IDE,
  - QML files load without obvious structural errors,
  - new modules can be referenced by path without unresolved local dependencies.

- **Smoke verification**
  - run the local shell launch workflow documented by Task `0.1`,
  - verify the new surface or behavior appears,
  - verify the shell remains usable after the change.

- **Interaction verification**
  - manually exercise the new widget, popup, or overlay behavior,
  - verify focus, dismissal, and screen targeting behave as expected.

- **Regression verification**
  - verify existing surfaces still load,
  - verify multi-monitor behavior still matches the design,
  - verify fullscreen behavior is not broken by new layer decisions.

---

## 4) Iteration Map

| Iteration | Outcome | Stop Point |
|---|---|---|
| `0` ✅ | Project bootstrap and local shell launch workflow | Minimal shell root loads without local-import confusion |
| `1` ✅ | Visible bar skeleton on every enabled monitor | Empty but stable top bar per screen |
| `2` ✅ | Stable bar surface stack | Exclusion and auto-hide trigger surfaces behave correctly |
| `3` ✅ | Daily-usable core bar | Workspace, active window, clock, and status widgets render cleanly with real data backends |
| `4` ✅ | Popup-enabled bar MVP | Tray, notification indicator, and session menu work through a shared popup stage |
| `5` | Launcher MVP | Overlay launcher opens, searches apps, and launches correctly |
| `6` | Hardening pass | Focus, multi-monitor, fullscreen, and fallback behavior are stable |

Each iteration should end at a stable checkpoint before the next one starts.

---

## 5) Execution Order

Follow this order strictly unless a concrete dependency forces a split:

1. bootstrap the shell root and dev workflow,
2. create screen/context plumbing,
3. render a minimal per-screen bar,
4. add exclusion and auto-hide surfaces,
5. add core data-backed widgets,
6. add popup staging,
7. add tray, notification presence, and session menu,
8. add launcher provider/service/view flow,
9. harden focus and cross-screen behavior,
10. only then improve styling and motion.

---

## 6) Detailed Task Breakdown

## Iteration 0: Bootstrap the Workspace ✅

### Task 0.1: Establish the local shell launch workflow ✅

**Files:**
- Create: `shell.qml`
- Create: `docs/DEV-WORKFLOW.md`
- Modify if needed: `.qmlls.ini`

**Depends on:** none

**Outcome:** There is a minimal Quickshell entrypoint and a documented local smoke-launch workflow for this repo.

**Subtasks:**
- Create a minimal `shell.qml` that can load successfully.
- Document the chosen local launch workflow in `docs/DEV-WORKFLOW.md`.
- Keep the workflow minimal and focused on local smoke testing.
- Update `.qmlls.ini` only if local import resolution requires it.

**Verification:**
- Static: `shell.qml` resolves in the IDE without broken local imports.
- Smoke: the documented workflow launches the shell root without crashing immediately.
- Regression: `.qmlls.ini` changes do not break existing QML import resolution.

**Do not add yet:** bar surfaces, services, widgets, or launcher logic.

---

### Task 0.2: Create configuration and theme foundations ✅

**Files:**
- Create: `config/ShellConfig.qml`
- Create: `config/Defaults.qml`
- Create: `config/Theme.qml`
- Modify: `shell.qml`

**Depends on:** `0.1`

**Outcome:** The shell root has one place for configuration defaults and one place for theme values.

**Subtasks:**
- Add a minimal config object with only MVP-safe defaults.
- Add a minimal theme object with only values needed to render a basic shell.
- Reference these from `shell.qml` without coupling feature modules to raw constants.

**Verification:**
- Static: config/theme files load cleanly.
- Smoke: the shell still launches through `docs/DEV-WORKFLOW.md`.
- Regression: no feature-specific settings are introduced prematurely.

**Do not add yet:** widget-level settings, per-monitor layout customization, or advanced theming.

---

### Task 0.3: Create the first normalized screen type ✅

**Files:**
- Create: `types/ScreenContext.qml`

**Depends on:** `0.2`

**Outcome:** There is a reusable normalized screen object for all screen-aware modules.

**Subtasks:**
- Define the MVP `ScreenContext` shape from the design doc.
- Keep it limited to screen metadata and bar-related normalized fields.
- Avoid putting behavior or service logic in the type.

**Implementation notes:**
- `ShellScreen` (`QuickshellScreenInfo`) exposes: `name`, `model`, `serialNumber`, `x`, `y`, `width`, `height`, `physicalPixelDensity`, `logicalPixelDensity`, `devicePixelRatio`, `orientation`, `primaryOrientation`. It has **no** `.geometry`, `.scale`, or `.primary` properties.
- `ScreenContext` therefore exposes: `screen` (raw `ShellScreen`), `name`, `isPrimary` (derived from `ShellConfig.primaryScreen` name comparison), `barEdge`, `barHeight`. Geometry and scale are not normalized here — surfaces read `screen.x/y/width/height` directly or rely on the compositor via `PanelWindow.screen`.

**Verification:**
- Static: the type can be imported and instantiated cleanly.
- Regression: the type is generic enough for both bar and launcher flows.

**Do not add yet:** workspace state, window state, launcher result type.

---

### Task 0.4: Create the shared shell window base ✅

**Files:**
- Create: `components/containers/ShellWindow.qml`

**Depends on:** `0.2`

**Outcome:** The project has one shared base container for shell surfaces.

**Subtasks:**
- Add the minimal common window wrapper needed by future top-level surfaces.
- Keep the base generic: sizing, namespace hooks, and common visual shell behavior only.
- Avoid embedding bar- or launcher-specific behavior here.

**Verification:**
- Static: `ShellWindow.qml` can be used by future window modules.
- Regression: the base does not hardcode one specific layer strategy.

**Do not add yet:** popup dismissal logic, launcher focus behavior, or auto-hide state.

---

## Iteration 1: Render the First Visible Bar ✅

### Task 1.1: Add screen registry service ✅

**Files:**
- Create: `services/ui/ScreenRegistry.qml`
- Modify: `shell.qml`

**Depends on:** `0.3`

**Outcome:** The shell can enumerate enabled screens and expose `ScreenContext` instances.

**Subtasks:**
- Wrap `Quickshell.screens` in a normalized service.
- Produce one `ScreenContext` per enabled screen.
- Expose simple lookup by screen name.

**Verification:**
- Static: screen registry service loads without circular imports.
- Smoke: launching the shell does not fail when one or more screens are present.
- Regression: no screen-specific surface logic exists yet.

---

### Task 1.2: Add per-screen orchestration modules ✅

**Files:**
- Create: `modules/screens/ScreenShells.qml`
- Create: `modules/screens/ScreenShellDelegate.qml`
- Modify: `shell.qml`

**Depends on:** `1.1`

**Outcome:** The shell root can create per-screen module instances from the registry.

**Subtasks:**
- Add a screen iteration layer that consumes `ScreenRegistry`.
- Delegate one screen at a time through `ScreenShellDelegate.qml`.
- Keep the delegate empty except for placeholders until the bar window exists.

**Verification:**
- Static: screen iteration resolves cleanly.
- Smoke: the shell still launches with no rendered bar yet.
- Regression: screen orchestration remains independent from feature logic.

---

### Task 1.3: Add the bar skeleton window ✅

**Files:**
- Create: `modules/bar/BarContentWindow.qml`
- Create: `modules/bar/BarView.qml`
- Modify: `modules/screens/ScreenShellDelegate.qml`

**Depends on:** `1.2`, `0.4`

**Outcome:** One visible top bar shell surface is rendered on each enabled screen.

**Subtasks:**
- Create a minimal `BarContentWindow` using the shared shell window base.
- Create a minimal `BarView` that renders simple placeholder content.
- Wire the screen delegate to instantiate one bar surface per screen.

**Verification:**
- Smoke: a visible bar appears on every enabled monitor.
- Interaction: the bar does not require keyboard focus to exist.
- Regression: no exclusion or auto-hide logic is present yet.

**Implementation notes:**
- `BarContentWindow` uses `ExclusionMode.Auto` temporarily so the compositor reserves bar space without a dedicated exclusion surface. This is intentionally simpler than the final design — Task 2.1 will split this into a separate `BarExclusionZone` surface when auto-hide is needed.
- `ExclusionMode.Auto` derives `exclusiveZone` from `implicitHeight` automatically. `exclusiveZone` is a Wayland layer-shell protocol value telling the compositor how many pixels to reserve at the anchor edge for normal windows — it is independent from the surface's visual height (`implicitHeight`).
- Two `Top`-layer bars from different Quickshell instances cannot control their relative z-order via QML — the compositor decides. See `docs/DEV-WORKFLOW.md` for the recommended testing workflow alongside a live shell.

---

### Task 1.4: Add the fixed three-zone bar layout ✅

**Files:**
- Create: `modules/bar/BarLayout.qml`
- Modify: `modules/bar/BarView.qml`

**Depends on:** `1.3`

**Outcome:** The bar has a stable left / center / right layout with placeholders.

**Subtasks:**
- Create the three-zone layout container.
- Keep widget order fixed across monitors from the start.
- Use placeholders or empty slots where real widgets are not implemented yet.

**Verification:**
- Smoke: the bar layout renders consistently on each monitor.
- Regression: no per-monitor layout variation is introduced.

**Iteration 1 stop point:** empty but stable bar visible across screens.

---

## Iteration 2: Add the Bar Surface Stack ✅

### Task 2.1: Add the exclusion surface ✅

**Files:**
- Create: `modules/bar/BarExclusionZone.qml` (later removed)
- Modify: `modules/screens/ScreenShellDelegate.qml`

**Depends on:** `1.3`

**Outcome:** Screen space can be reserved independently from the visible bar surface.

**Subtasks:**
- Create a dedicated exclusion surface.
- Keep its behavior limited to anchoring and reserve-space policy.
- Mount it alongside the visible bar surface.
- Switch `BarContentWindow` from `ExclusionMode.Auto` back to `ExclusionMode.Ignore` once this surface is in place.

**Implementation note:** `BarExclusionZone` was initially created but later removed. With `ExclusionMode.Ignore` on `BarContentWindow`, the bar rendered at y=0 ignoring all exclusive zones, overlapping other layer-shell surfaces. With `ExclusionMode.Normal` + `exclusiveZone: 0`, it was pushed below ALL exclusive zones including its own. The split added complexity without MVP benefit. The final approach: `BarContentWindow` uses `ExclusionMode.Auto` with a dynamic `exclusiveZone` that equals `barHeight` when visible/exclusive and `0` when hidden/non-exclusive.

**Verification:**
- Smoke: the shell still renders one visible bar per screen.
- Interaction: the exclusion surface does not create visible artifacts.
- Regression: visible bar rendering is unaffected.

---

### Task 2.2: Add bar visibility state service ✅

**Files:**
- Create: `services/ui/BarVisibility.qml`
- Register: `services/ui/qmldir`

**Depends on:** `2.1`

**Outcome:** Auto-hide related state has one owner instead of living inside surfaces.

**Subtasks:**
- Add per-screen visibility state.
- Add only the minimum state needed for visible vs auto-hide behavior.
- Keep timers and policy simple.

**Implementation note:** Per-screen state keyed by screen name in a `states` JS object. `effectiveVisible()` returns `true` for `visible` mode, `hovered || popupOpen || forceVisible` for `auto_hide`. Hide timers use `Qt.createQmlObject` with `destroy()` cleanup to avoid leaks. `scheduleHide` fires after `hideDelayMs` (300ms), `cancelHide` stops and destroys the timer.

**Verification:**
- Static: the service can be referenced by bar surfaces without cyclic imports.
- Regression: default behavior keeps the bar visible until auto-hide is explicitly wired.

---

### Task 2.3: Add the trigger surface ✅

**Files:**
- Create: `modules/bar/BarTriggerZone.qml`
- Modify: `modules/screens/ScreenShellDelegate.qml`
- Modify: `services/ui/BarVisibility.qml`

**Depends on:** `2.2`

**Outcome:** Auto-hide reveal can be triggered by a thin screen-edge surface.

**Subtasks:**
- Add an invisible edge-aligned trigger window.
- Wire hover reporting to `BarVisibility`.
- Keep the trigger extremely lightweight.

**Verification:**
- Smoke: the trigger surface loads without visible artifacts.
- Interaction: hover state reaches `BarVisibility`.
- Regression: the visible bar still behaves normally when auto-hide is off.

---

### Task 2.4: Wire exclusion and auto-hide behavior together ✅

**Files:**
- Modify: `modules/bar/BarContentWindow.qml`
- Modify: `modules/bar/BarTriggerZone.qml`
- Modify: `services/ui/BarVisibility.qml`
- Modify: `types/ScreenContext.qml` (added `barDisplayMode`)

**Depends on:** `2.3`

**Outcome:** The bar surface stack behaves correctly in visible vs auto-hide modes.

**Subtasks:**
- Make the visible bar respond to `effectiveVisible` state.
- Make `BarContentWindow` manage `exclusiveZone` directly (dynamic: `barHeight` when visible/exclusive, `0` when hidden/non-exclusive).
- Keep auto-hide behavior minimal and predictable.

**Implementation note:** `BarContentWindow` uses `ExclusionMode.Auto` with explicit `exclusiveZone` binding. `visible` bound to `effectiveVisible`. `HoverHandler` reports hover, cancels hide timer, sets `forceVisible`. `BarTriggerZone` visible only when `auto_hide` + bar hidden. `ScreenContext` gained `barDisplayMode` property.

**Verification:**
- Interaction: auto-hide reveal works predictably.
- Regression: when auto-hide is off, exclusion still behaves correctly.
- Regression: the bar does not flicker or churn surfaces during show/hide transitions.

**Iteration 2 stop point:** stable bar stack with visible bar and trigger layers; exclusion handled by `BarContentWindow` directly.

---

## Iteration 3: Add the Core Bar Data Path

### Task 3.1: Add the compositor service contract and generic backend ✅

**Files:**
- Create: `services/compositor/Compositor.qml`
- Create: `services/compositor/backends/Generic.qml`
- Modify: `shell.qml`

**Depends on:** `1.1`

**Outcome:** UI code can depend on a normalized compositor interface even before a full backend exists.

**Subtasks:**
- Define the normalized contract from the design doc.
- Add a generic fallback backend with safe no-data behavior.
- Expose the service without leaking compositor-specific imports to widgets.

**Verification:**
- Static: widgets can import `Compositor` without backend-specific imports.
- Smoke: the shell still runs even if the generic backend returns limited data.

---

### Task 3.2: Add the Hyprland backend adapter ✅

**Files:**
- Create: `services/compositor/backends/Hyprland.qml`
- Modify: `services/compositor/Compositor.qml`

**Depends on:** `3.1`

**Outcome:** The compositor service can provide real workspace and active-window data on Hyprland.

**Subtasks:**
- Implement the smallest adapter needed for MVP widgets.
- Keep Hyprland-specific imports and logic isolated here.
- Defer advanced compositor-specific features until hardening.

**Verification:**
- Smoke: the service exposes workspace and active-window data on the target compositor.
- Regression: generic fallback remains available when Hyprland-specific data is unavailable.

---

### Task 3.3: Add workspace and active-window widgets ✅

**Files:**
- Create: `types/WorkspaceState.qml`
- Create: `types/WindowState.qml`
- Create: `modules/bar/widgets/WorkspacesWidget.qml`
- Create: `modules/bar/widgets/ActiveWindowWidget.qml`
- Modify: `modules/bar/BarLayout.qml`

**Depends on:** `3.2`

**Outcome:** The bar shows workspace state and active window text.

**Subtasks:**
- Define minimal normalized types for workspace and window data if needed.
- Create the workspace widget.
- Create the active window widget.
- Mount both into the left zone of the bar.

**Verification:**
- Interaction: workspace state updates when switching workspaces.
- Interaction: active window text updates when focus changes.
- Regression: widgets degrade gracefully if backend data is partial.

---

### Task 3.4: Add the clock widget ✅

**Files:**
- Create: `modules/bar/widgets/ClockWidget.qml`
- Modify: `modules/bar/BarLayout.qml`

**Depends on:** `1.4`

**Outcome:** The center zone shows the clock/date widget.

**Subtasks:**
- Create the smallest useful clock/date widget.
- Mount it in the center zone.
- Keep formatting simple and stable.

**Verification:**
- Smoke: clock is visible and updates over time.
- Regression: the center slot remains layout-stable.

---

### Task 3.5: Add volume service and widget ✅

**Files:**
- Create: `services/system/Audio.qml`
- Create: `modules/bar/widgets/VolumeWidget.qml`
- Modify: `modules/bar/BarLayout.qml`

**Depends on:** `1.4`

**Outcome:** The right zone shows audio status.

**Subtasks:**
- Create a minimal audio service.
- Create the volume widget against that service.
- Mount it in the right zone.

**Verification:**
- Smoke: the widget renders even if full audio metadata is not available.
- Regression: widget does not require keyboard focus.

---

### Task 3.6: Add network service and widget ✅

**Files:**
- Create: `services/system/Network.qml`
- Create: `modules/bar/widgets/NetworkWidget.qml`
- Modify: `modules/bar/BarLayout.qml`

**Depends on:** `1.4`

**Outcome:** The right zone shows network status.

**Subtasks:**
- Create a minimal network service.
- Create the network widget.
- Mount it in the right zone.

**Implementation note:** `Network.qml` uses `Quickshell.Networking` singleton, following the same pattern as `Audio.qml`: `Singleton` type, `pragma ComponentBehavior: Bound`, private `_connected`/`_ssid` state with readonly public aliases, `resolveDevice()`/`updateNetworkState()` functions, `Connections` on `Networking.devices.values` and `root.device` for reactivity. Resolves the best connected device (prefers wifi over ethernet). For wifi devices, scans `networks` for the connected network name (SSID). For ethernet, falls back to device `name`. `toggleWifi()` toggles `Networking.wifiEnabled`. `NetworkWidget` wrapped in `Item` with `MouseArea` for click-to-toggle-wifi.

**Verification:**
- Smoke: the widget renders with stable fallback behavior.
- Regression: missing data does not break the layout.

---

### Task 3.7: Add power service and battery widget ✅

**Files:**
- Create: `services/system/Power.qml`
- Create: `modules/bar/widgets/BatteryWidget.qml`
- Modify: `modules/bar/BarLayout.qml`

**Depends on:** `1.4`

**Outcome:** The right zone shows battery state when battery hardware is available.

**Subtasks:**
- Create a minimal power service.
- Create the battery widget with graceful absence handling.
- Mount it in the right zone.

**Implementation note:** `Power.qml` uses `Quickshell.Services.UPower` singleton, following the same pattern as `Audio.qml`: `Singleton` type, `pragma ComponentBehavior: Bound`, private `_present`/`_percent`/`_charging` state with readonly public aliases, `resolveDevice()`/`updatePowerState()` functions, `Connections` on `UPower` and `root.displayDevice` for reactivity. Resolves `UPower.displayDevice` only if `isLaptopBattery`. Action functions (shutdown/reboot/suspend/logout) remain stubs pending logind D-Bus integration. `BatteryWidget` unchanged — existing contract (`present`, `charging`, `percent`) preserved. All three system services (`Audio`, `Network`, `Power`) now share the same structural pattern.

**Verification:**
- Interaction: battery state appears when hardware exists.
- Regression: the widget hides or collapses cleanly on systems without battery hardware.

**Iteration 3 stop point:** core bar is useful for daily orientation even before tray/session/launcher work is done.

---

## Iteration 4: Add Popup-Driven Bar Features

### Task 4.1: Add the shell UI coordination service ✅

**Files:**
- Create: `services/ui/ShellUI.qml`
- Modify: `shell.qml`

**Depends on:** `1.1`

**Outcome:** Popup and overlay open/close behavior has one central owner.

**Subtasks:**
- Add popup registration APIs.
- Add one-open-popup state.
- Add launcher-open state placeholders for the next iteration.

**Verification:**
- Static: UI modules can depend on `ShellUI` without circular imports.
- Regression: the service remains thin until popup windows are added.

---

### Task 4.2: Add the shared popup stage ✅

**Files:**
- Create: `modules/popups/PopupMenuWindow.qml`
- Modify: `modules/screens/ScreenShellDelegate.qml`
- Modify: `services/ui/ShellUI.qml`

**Depends on:** `4.1`

**Outcome:** Each screen has one popup window that can host small popup content.

**Subtasks:**
- Create one popup stage per screen.
- Register popup windows with `ShellUI`.
- Add click-outside dismissal.

**Verification:**
- Smoke: popup windows load per screen without visual artifacts when idle.
- Interaction: click-outside dismissal works for placeholder content.
- Regression: popup stage does not steal focus unnecessarily when idle.

---

### Task 4.3: Add tray service and tray widget ✅

**Files:**
- Create: `services/system/Tray.qml`
- Create: `modules/bar/widgets/TrayWidget.qml`
- Modify: `modules/bar/BarLayout.qml`

**Depends on:** `4.2`

**Outcome:** The bar can render tray items and route menu-open requests toward the popup stage.

**Subtasks:**
- Add a normalized tray service.
- Create the tray widget.
- Keep initial behavior to item rendering plus menu-open dispatch only.

**Verification:**
- Smoke: tray area renders and remains interactable.
- Regression: absence of tray items does not break bar layout.

---

### Task 4.4: Add tray menu content ✅


**Files:**
- Create: `modules/popups/TrayMenu.qml`
- Create: `modules/popups/TrayMenuItem.qml`
- Create: `modules/popups/TrayMenuPage.qml`
- Create: `types/TrayMenuRequest.qml`
- Modify: `modules/popups/PopupMenuWindow.qml`
- Modify: `services/system/Tray.qml`
- Modify: `services/ui/ShellUI.qml`
- Modify: `modules/bar/widgets/TrayWidget.qml`
- Modify: `config/Defaults.qml`, `config/PersistentConfig.qml`, `config/ShellConfig.qml`

**Depends on:** `4.3`

**Outcome:** Tray item menus render through the shared popup stage.

**Implementation note:** `ShellUI.openPopup` now uses a signal-driven approach (`popupRequested`/`popupClosed`) carrying the `Component` to render and `anchorX` position — `PopupMenuWindow` is fully generic with no hardcoded content switches. Submenu navigation uses `StackView` in `TrayMenu`; each level is a `TrayMenuPage` with scrolling capped at `ShellConfig.trayMenuMaxHeight`. The popup window height is frozen at the root page's height so submenus don't resize the popup. `TrayMenuRequest` type in `types/` wraps the active tray item + anchor coordinates. Tray items can be hidden via `ShellConfig.trayHiddenIds`.

**Verification:**
- Interaction: clicking a tray item opens its menu.
- Interaction: clicking outside closes the menu.
- Interaction: submenu items push new pages with back navigation.
- Interaction: long menus scroll within a capped height.
- Regression: opening tray menus does not leave popup state stuck.

---

### Task 4.5: Add notification presence service and widget ✅

**Files:**
- Create: `services/system/Notification.qml`
- Create: `modules/bar/widgets/NotificationIndicatorWidget.qml`
- Modify: `modules/bar/BarLayout.qml`

**Depends on:** `1.4`

**Outcome:** The bar shows notification presence without a full notification center.

**Subtasks:**
- Add a minimal notification presence store.
- Create the indicator widget.
- Mount it in the right zone.

**Verification:**
- Smoke: the widget renders with empty-state fallback.
- Interaction: unread presence becomes visible when notification data is available.
- Regression: no notification history panel is added.

---

### Task 4.6: Add session action service and button ✅

**Files:**
- Create: `services/system/SessionActions.qml`
- Create: `modules/bar/widgets/SessionMenuButton.qml`
- Modify: `modules/bar/BarLayout.qml`

**Depends on:** `4.2`

**Outcome:** The bar exposes a session menu trigger without yet implementing final popup content.

**Subtasks:**
- Create a minimal session actions service.
- Add the session menu button.
- Route button activation through `ShellUI`.

**Verification:**
- Smoke: the button renders and is clickable.
- Regression: no destructive action executes yet without confirmation UI.

---

### Task 4.7: Add session menu and confirmation dialog ✅

**Files:**
- Create: `modules/popups/SessionMenu.qml`
- Create: `modules/popups/ConfirmActionDialog.qml`
- Modify: `modules/popups/PopupMenuWindow.qml`
- Modify: `services/system/SessionActions.qml`
- Modify: `services/ui/ShellUI.qml`

**Depends on:** `4.6`

**Outcome:** The session menu works through the popup stage and destructive actions require confirmation.

**Subtasks:**
- Add popup content for session actions.
- Add a confirmation dialog flow.
- Keep `lock` lightweight and require confirmation for logout/reboot/shutdown.

**Implementation note:** `SessionMenu` renders 5 actions inline (Lock, Suspend, Log Out, Reboot, Shut Down). Non-destructive actions execute immediately via `SessionActions.execute()`; destructive ones set `pendingAction` to show an inline `ConfirmActionDialog`. `PopupMenuWindow` and `ShellUI` required no changes — the generic signal-driven architecture handles session popup the same way as tray. `SessionActions` dispatches to `Power.*` stubs; `lock` is a separate stub pending loginctl/swaylock integration.

**Verification:**
- Interaction: session menu opens from the bar.
- Interaction: destructive actions require confirmation.
- Regression: popup and confirmation state closes cleanly after cancel or action.

**Iteration 4 stop point:** bar MVP is functionally complete before launcher work begins.

---

## Iteration 5: Add the Launcher MVP

### Task 5.1: Add the normalized launcher result type and provider registry ✅

**Files:**
- Create: `types/LauncherResult.qml`
- Create: `services/launcher/LauncherProviderRegistry.qml`

**Depends on:** `0.3`

**Outcome:** Launcher results have a normalized shape and providers have a clean registry contract.

**Subtasks:**
- Define the launcher result type.
- Add a provider registry that supports one provider now and more later.
- Keep the registry independent from UI code.

**Implementation note:** `LauncherResult` is a `QtObject` with `title`, `subtitle`, `icon`, `providerId`, `data` properties. `LauncherProviderRegistry` is a singleton with `register(provider)`, `search(query)`, `activate(result)` methods. Providers self-register on `Component.onCompleted`.

**Verification:**
- Static: launcher UI can depend on normalized result data without provider-specific conditionals.
- Regression: provider architecture remains MVP-small.

---

### Task 5.2: Add the applications provider ✅

**Files:**
- Create: `services/launcher/providers/ApplicationsProvider.qml`
- Modify: `services/launcher/LauncherProviderRegistry.qml`

**Depends on:** `5.1`

**Outcome:** The launcher can search installed desktop-entry applications.

**Subtasks:**
- Add desktop-entry loading.
- Implement name/comment/executable matching.
- Return normalized launcher results.

**Implementation note:** Uses `DesktopEntries.applications` API. Searches by `name`, `genericName`, `comment`, `keywords`. Results sorted by prefix match first, then title length, then locale. `activate()` calls `DesktopEntries.byId(id).execute()`. Provider instantiated directly in `LauncherProviderRegistry`.

**Verification:**
- Interaction: app search returns useful results.
- Regression: empty query and no-results cases behave safely.

---

### Task 5.3: Add launcher state service ✅

**Files:**
- Create: `services/launcher/Launcher.qml`
- Modify: `services/launcher/LauncherProviderRegistry.qml`

**Depends on:** `5.2`

**Outcome:** Query state, result state, selection state, and launch behavior have one owner.

**Subtasks:**
- Add query state.
- Add result resolution through the provider registry.
- Add selection index and activate behavior.
- Keep launch-close behavior centralized.

**Implementation note:** `Launcher` singleton owns `query`, `results`, `selectedIndex`. `onQueryChanged` triggers `_refresh()` which calls `LauncherProviderRegistry.search()`. `selectNext()`/`selectPrev()` for navigation, `activateSelected()` dispatches to provider. `open(screenName)`/`close()` delegate to `ShellUI`.

**Verification:**
- Static: launcher UI can bind to one service instead of embedding search logic.
- Interaction: selecting a result triggers the correct provider action.

---

### Task 5.4: Add the launcher overlay window shell ✅

**Files:**
- Create: `modules/launcher/LauncherOverlayWindow.qml`
- Modify: `shell.qml`
- Modify: `services/ui/ShellUI.qml`

**Depends on:** `4.1`, `5.3`

**Outcome:** The shell can open one overlay launcher surface on the target screen.

**Subtasks:**
- Create the overlay window.
- Wire open/close state through `ShellUI`.
- Keep focus behavior explicit and limited to overlay-open state.

**Implementation note:** `LauncherOverlayWindow` is a `PanelWindow` with `WlrLayer.Overlay`, `WlrKeyboardFocus.Exclusive` when visible. Instantiated per-screen in `ScreenShellDelegate`. `ShellUI` has `launcherOpened`/`launcherClosed` signals. Click-outside-to-close via `MouseArea`.

**Verification:**
- Smoke: the launcher overlay can open on one screen.
- Interaction: the overlay closes cleanly when requested.
- Regression: only one launcher overlay is active at a time.

---

### Task 5.5: Add the launcher view components ✅

**Files:**
- Create: `modules/launcher/LauncherView.qml`
- Create: `modules/launcher/LauncherSearchField.qml`
- Create: `modules/launcher/LauncherResultsList.qml`
- Modify: `modules/launcher/LauncherOverlayWindow.qml`

**Depends on:** `5.4`

**Outcome:** The overlay displays the search field and results list.

**Subtasks:**
- Create the launcher view shell.
- Add the search field.
- Add the results list.
- Bind the view to `Launcher`.

**Implementation note:** `LauncherView` is a centered `Item` with `focus: true` and `Keys` handlers. Contains `LauncherSearchField` (TextInput bound to `Launcher.query`) and `LauncherResultsList` (ListView with delegate showing title/subtitle, hover selection, click to activate). `reset()` clears and focuses input.

**Verification:**
- Smoke: the launcher shows a centered panel with query and results.
- Interaction: the default selected result is visually clear.
- Regression: the overlay still closes cleanly when idle.

---

### Task 5.6: Add keyboard navigation and activation ✅

**Files:**
- Modify: `modules/launcher/LauncherView.qml`
- Modify: `modules/launcher/LauncherSearchField.qml`
- Modify: `modules/launcher/LauncherResultsList.qml`
- Modify: `services/launcher/Launcher.qml`

**Depends on:** `5.5`

**Outcome:** The launcher supports typing, selection movement, `Enter`, and `Escape`.

**Subtasks:**
- Wire query updates.
- Wire selection movement.
- Wire `Enter` to launch.
- Wire `Escape` to close.

**Implementation note:** `LauncherView` has `Keys.onUpPressed`/`onDownPressed` calling `Launcher.selectPrev()`/`selectNext()`, `Keys.onReturnPressed` calling `Launcher.activateSelected()`, `Keys.onEscapePressed` calling `Launcher.close()`. Typing handled by `TextInput.onTextChanged → Launcher.query`.

**Verification:**
- Interaction: typing filters results.
- Interaction: arrow keys move selection.
- Interaction: `Enter` launches the selected app.
- Interaction: `Escape` closes the launcher.

---

### Task 5.7: Wire launcher triggers ✅

**Files:**
- Create: `modules/bar/widgets/LauncherButton.qml`
- Create: `modules/ipc/ShellIpc.qml`
- Create: `modules/ipc/qmldir`
- Create: `modules/ipc/README.md`
- Modify: `modules/bar/BarLayout.qml`
- Modify: `shell.qml`

**Depends on:** `5.6`

**Outcome:** The launcher opens from both the bar and the chosen shortcut mechanism.

**Subtasks:**
- Wire the bar launcher button first.
- Wire the shortcut path through the runtime-compatible mechanism selected during implementation.
- Keep both trigger paths routed through `ShellUI`.

**Implementation note:** `LauncherButton` (hamburger icon ☰) in bar left zone calls `Launcher.open(screenName)`. IPC module uses `IpcHandler` with target `shell` for compositor-agnostic keybinds: `qs ipc call shell toggleLauncher`. Falls back to first enabled screen if `primaryScreen` is empty. Hyprland keybind: `bind = SUPER, R, exec, qs ipc call shell toggleLauncher`.

**Verification:**
- Interaction: launcher opens from the bar.
- Interaction: launcher opens from the configured shortcut path.
- Regression: launcher opens on the intended screen in a multi-monitor setup.

**Iteration 5 stop point:** full launcher MVP is operational end-to-end. ✅

---

## Iteration 6: Hardening and Stability

### Task 6.1: Harden popup and overlay focus behavior

**Files:**
- Modify: `modules/popups/PopupMenuWindow.qml`
- Modify: `modules/launcher/LauncherOverlayWindow.qml`
- Modify: `services/ui/ShellUI.qml`

**Depends on:** `4.7`, `5.7`

**Outcome:** Popup and launcher focus behavior is explicit and less fragile.

**Subtasks:**
- Audit focus policy on idle vs open states.
- Remove accidental focus stealing.
- Ensure popup and launcher close paths do not wedge state.

**Verification:**
- Interaction: repeated popup open/close cycles do not wedge input.
- Interaction: repeated launcher open/close cycles do not wedge focus.

---

### Task 6.2: Harden fullscreen and exclusion behavior

**Files:**
- Modify: `modules/bar/BarContentWindow.qml`
- Modify: `services/compositor/Compositor.qml`
- Modify: `services/compositor/backends/Hyprland.qml`

**Depends on:** `2.4`, `3.2`

**Outcome:** Fullscreen handling and exclusion behavior remain safe.

**Subtasks:**
- Audit fullscreen detection through normalized compositor state.
- Ensure the bar does not break fullscreen application behavior.
- Re-check exclusion policy in visible vs auto-hide states.

**Verification:**
- Interaction: fullscreen applications are not broken by the bar.
- Regression: exclusion still behaves correctly after fullscreen transitions.

---

### Task 6.3: Harden multi-monitor and hotplug behavior

**Files:**
- Modify: `services/ui/ScreenRegistry.qml`
- Modify: `modules/screens/ScreenShells.qml`
- Modify: `services/ui/ShellUI.qml`
- Modify: `modules/launcher/LauncherOverlayWindow.qml`

**Depends on:** `5.7`

**Outcome:** Screen add/remove events do not leave orphaned windows or bad state.

**Subtasks:**
- Close popup or launcher state targeting removed screens.
- Rebuild per-screen surfaces safely.
- Verify screen-local popup ownership remains correct.

**Verification:**
- Interaction: popup windows remain screen-local after monitor changes.
- Interaction: launcher does not target a removed screen.
- Regression: bar layout remains identical across monitors.

---

### Task 6.4: Harden generic backend fallback behavior

**Files:**
- Modify: `services/compositor/Compositor.qml`
- Modify: `services/compositor/backends/Generic.qml`
- Modify as needed: compositor-dependent widgets

**Depends on:** `3.2`, `3.3`

**Outcome:** The shell remains stable when advanced compositor data is missing.

**Subtasks:**
- Audit each compositor-dependent widget for fallback behavior.
- Remove assumptions that all workspace/window metadata is always available.
- Keep the bar usable even with reduced backend data.

**Verification:**
- Regression: widgets degrade gracefully without crashing.
- Regression: backend-specific code remains isolated to backend files.

---

### Task 6.5: Add the first styling pass

**Files:**
- Modify: `config/Theme.qml`
- Modify: `modules/bar/BarView.qml`
- Modify: `modules/launcher/LauncherView.qml`
- Modify as needed: widget files

**Depends on:** `5.7`

**Outcome:** The MVP looks cohesive without changing architecture or interaction rules.

**Subtasks:**
- Improve spacing and density.
- Add minimal motion only where it does not risk focus or surface stability.
- Keep styling changes separate from behavior changes.

**Verification:**
- Smoke: styling changes do not change open/close behavior.
- Regression: layout and interaction remain stable.

---

### Task 6.6: Document implementation decisions and follow-up backlog

**Files:**
- Create: `docs/IMPLEMENTATION-NOTES.md`
- Modify: `docs/Quickshell-Desktop-DESIGN-v2.md`

**Depends on:** `6.5`

**Outcome:** The code and docs remain aligned after the MVP implementation pass.

**Subtasks:**
- Record any architecture deviations that proved necessary.
- Record unresolved follow-up items for post-MVP work.
- Keep deferred scope explicitly deferred.

**Implementation note:** Created `IMPLEMENTATION-NOTES.md` documenting: IPC module deviation, launcher lazy loading, provider self-registration, file naming convention, event-driven fullscreen detection, mutual exclusion for popup/launcher, screen removal cleanup. Follow-up items: session actions, notification service, tray menu improvements, launcher providers, workspace widget, audio hardening, network/battery services, auto-hide animations.

**Verification:**
- Regression: docs still match the implemented architecture.
- Regression: deferred roadmap remains clear.

**Iteration 6 stop point:** MVP candidate is stable enough for repeated daily use and further iteration.

---

## 7) Suggested Commit Boundaries

Use small commits. A reasonable default is:

- one commit per task, or
- one commit for two tightly related tasks when the first task is only structural scaffolding.

Good commit examples:

- `chore: bootstrap quickshell root and dev workflow`
- `feat: add per-screen bar skeleton`
- `feat: add bar exclusion and trigger surfaces`
- `feat: add compositor service and hyprland adapter`
- `feat: add tray popup stage`
- `feat: add overlay launcher MVP`
- `fix: harden popup and launcher focus behavior`

---

## 8) Execution Guardrails

While implementing, always prefer these choices:

- **Prefer placeholder output over speculative full logic**
- **Prefer one screen-safe surface over a complex multipurpose surface**
- **Prefer central service ownership over widget-owned global state**
- **Prefer fallback behavior over hard failure when system data is missing**
- **Prefer one provider in the launcher over premature provider expansion**
- **Prefer docs updates over silent architecture drift**

If any task starts to require:

- multiple new popup types,
- multiple new providers,
- per-monitor layout customization,
- or compositor-specific branches inside UI widgets,

stop and split the work or redesign the task.

---

## 9) Done Criteria for the MVP

The MVP is done when all of the following are true:

- one top bar renders on every enabled monitor,
- bar layout is identical across monitors,
- workspace and active window widgets work on the target compositor,
- clock and system status widgets render safely,
- tray menus open through the shared popup stage,
- notification presence is visible in the bar,
- session menu opens and destructive actions require confirmation,
- the launcher opens from both the bar and shortcut path,
- application search returns desktop-entry results,
- keyboard navigation and launch behavior work,
- fullscreen behavior is not broken,
- and hotplug / repeated open-close cycles do not leave stale shell state.

---

## 10) Recommended Execution Style

Execute this plan in order.

Do **not** parallelize tasks that change shared shell state or window lifecycle rules.

Reasonable places to pause and review:

- after Iteration `1`
- after Iteration `2`
- after Iteration `4`
- after Iteration `5`

If an iteration is unstable, do not continue to the next one until the unstable behavior is understood and fixed.
