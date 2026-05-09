# Bar Memory Static Analysis (No Runtime Profiling)

Date: 2026-05-04

## Goal

Identify which bar-related modules are most likely to consume memory using a static code inspection only, while avoiding recommendations that increase steady-state CPU usage.

## Scope

Reviewed:

- Bar composition and per-screen instantiation
- Bar widgets and their delegates/loaders
- Popup modules used by bar widgets
- Service singletons imported by bar widgets/popups
- Current `config.json` bar layout

Not reviewed:

- Runtime heap snapshots
- GPU memory use
- Allocator-level behavior

## Architecture Notes (Static)

- Bar is instantiated per enabled screen via `ScreenShells -> ScreenShellDelegate -> BarContentWindow -> BarView -> BarLayout`.
- `BarLayout` creates widget instances through per-zone `Repeater + Loader`.
- Several heavy paths are list-driven (`Notification`, taskbar windows, tray items), so memory scales with list length.

## Ranked Memory Risk (Highest to Lower)

### 1) `services/system/Notification.qml` (Highest)

Reason:

- `trackedList` stores notification objects and grows until explicit dismiss.
- No static cap on retained notification history.
- Toast queue is capped, but persistent history is not.

Static indicators:

- `trackedList.push(notification)` on each new notification.
- `unreadCount` bound directly to `trackedList.length`.

Likely impact:

- Long uptime with many notifications causes gradual memory growth.

### 2) `modules/popups/NotificationPopup.qml` — Mitigated

Reason (original):

- Used `Column + Repeater` over full notification history.
- Delegate is deep (background, icon container, icon resolver, summary/body text, expand control, dismiss controls, hover areas).

Mitigation:

- Replaced `Column + Repeater` with `ListView` for delegate reuse (virtualization).
- Only visible delegates are instantiated; off-screen items are recycled.
- Expanded body state stored externally keyed by `notification.id` — survives delegate reuse.
- Stale expanded entries pruned when notifications are dismissed.

Likely impact (remaining):

- Peak memory now bounded by visible delegate count, not total notification count.

### 3) `modules/bar/widgets/Applications.qml` (Taskbar)

Reason:

- `Repeater` over `ToplevelManager.toplevels`.
- Each top-level window creates a widget delegate with icon, background, mouse handler, and connection.

Likely impact:

- Linear memory growth with number of open windows.

### 4) `modules/bar/BarLayout.qml` (Baseline per-screen overhead)

Reason:

- For each configured widget slot, creates wrapper `Item + Loader + HoverHandler`.
- Cost multiplies by widgets x zones x screens.

Likely impact:

- Predictable baseline overhead that increases in multi-monitor setups and richer layouts.

### 5) `modules/bar/widgets/TrayWidget.qml` (Medium)

Reason:

- `Repeater` over tray items with per-item image delegate and mouse area.
- Usually smaller list than notifications/taskbar, but still linear.

Likely impact:

- Moderate growth with tray icon count.

## Current Config Amplifiers

In current `config.json`, bar layout includes:

- `taskbar` in center
- `systemMonitor` in right section

This increases always-live bar object count and binding surface.

## CPU-Safe / CPU-Neutral Optimization Opportunities

### A) Cap retained notification history — IMPLEMENTED

- Config key: `notificationMaxHistory` (default 100, 0 = unlimited).
- Trim oldest entries when limit is exceeded; dismissed notifications signal `dismiss()` to sender app.
- Also removes overflowed entries from toast queue to avoid dangling references.
- Expected memory gain: high.
- CPU effect: negligible.

### B) Virtualize notification list rendering — IMPLEMENTED

- Replaced `Column + Repeater` in notification popup with `ListView` delegate reuse.
- Only visible delegates are instantiated; off-screen items are recycled.
- Expanded body state stored externally keyed by `notification.id` — survives delegate reuse.
- Stale expanded entries pruned on dismiss.
- Expected memory gain: high when history is large.
- CPU effect: neutral to positive during scrolling.

### C) Bound taskbar delegate count — DEFERRED

- Add `maxTaskbarItems` and optional overflow indicator.
- Expected memory gain: medium to high on window-heavy sessions.
- CPU effect: neutral.

### D) Reduce always-instantiated widget surface

- Lazily instantiate rarely used widgets with `Loader.active` policies instead of always creating all configured widgets.
- Expected memory gain: medium.
- CPU effect: neutral in steady state.

## Suggested Priority Order

1. ~~Notification retention cap (`trackedList` bound).~~ **DONE** — `notificationMaxHistory` config added.
2. ~~Notification popup virtualization (`ListView`).~~ **DONE** — `NotificationPopup` now uses `ListView` with delegate reuse.
3. Taskbar max visible items.
4. Optional lazy-instantiation pass in `BarLayout`.

## Validation Plan (When Runtime Checks Are Allowed)

1. Baseline RSS after shell start with current config.
2. Inject 200+ notifications, compare memory before/after cap.
3. Open notification popup with large history, compare old/new popup implementation.
4. Open many windows, compare taskbar memory with and without cap.
5. Confirm no measurable CPU regression in idle and normal interaction.
