# Notification Toast ↔ Notification.qml Integration Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Wire the existing toast UI to real notification data from `Notification.qml` — real app icons, proper dismiss/expire semantics, and `NotificationServer` capability advertisement.

**Architecture:** The plumbing already exists (`Notification.toastQueue` feeds `NotificationToastWindow` → `NotificationToast`). What's missing is: (1) `NotificationServer` not advertising image/actions support so apps don't send them, (2) toast dismiss not calling `notification.expire()`, (3) sweep-timer expiry not calling `notification.expire()`, and (4) the icon slot in `NotificationToast` is a hardcoded emoji instead of the real `appIcon` / `image`.

**Tech Stack:** QML, Quickshell (`Quickshell.Services.Notifications`, `Quickshell.Widgets.IconImage`)

---

## Context for Implementor

### File Map

| File | Role |
|---|---|
| `services/system/Notification.qml` | Singleton service — receives D-Bus notifications, manages `toastQueue` and `trackedList` |
| `modules/popups/NotificationToast.qml` | Single toast card UI — receives one `Notification` object |
| `modules/popups/NotificationToastWindow.qml` | `PopupWindow` that renders the toast stack via `Repeater` over `Notification.toastQueue` |
| `modules/screens/ScreenShellDelegate.qml` | Mounts `NotificationToastWindow` per-screen (primary only) |

### Key Data Flow

```
D-Bus notification arrives
  → NotificationServer fires onNotification
    → Notification.qml: push to trackedList, call addToast()
      → toastQueue gets { notification: Notification, createdAt: int }
        → NotificationToastWindow Repeater renders NotificationToast per item
          → NotificationToast shows summary + body + icon
```

### What's Currently Broken / Incomplete

1. **`NotificationServer` capabilities**: only `bodySupported: true` is set. Apps use this to decide whether to send images and actions. `imageSupported` and `actionsSupported` need to be `true`.

2. **Icon is a hardcoded emoji**: `NotificationToast.qml` shows `🔔` unconditionally. It should use `notification.appIcon` (a string name) via `Quickshell.Widgets.IconImage`, and fall back to `notification.image` (a QML `Image` source), then fall back to `🔔` if both are empty.

3. **Toast dismiss doesn't expire the notification**: Clicking ✕ or the card calls `toast.dismissed()` → `Notification.removeToast(index)` which only splices the `toastQueue` array. It does **not** call `notification.expire()`, so the sending app never learns the notification was dismissed. Fix: `removeToast` should accept the notification object and call `notification.expire()`.

4. **Sweep timer expiry doesn't expire notifications**: The `toastSweepTimer` in `Notification.qml` filters out expired entries from `toastQueue` but never calls `notification.expire()` on them. Timed-out toasts should call `notification.expire()` so apps know they timed out.

### Quickshell API Reference

**`Notification` properties used here:**
- `notification.appIcon: string` — icon name (from XDG icon theme) or path; empty string if none
- `notification.image` — a QML `Image`-compatible source (may be a path or raw image data); available when `imageSupported: true` on the server
- `notification.summary: string` — title text
- `notification.body: string` — body text
- `notification.expire(): void` — signal to the sending app that the notification timed out
- `notification.dismiss(): void` — signal to the sending app that the user dismissed it

**`IconImage`** (`import Quickshell.Widgets`): renders XDG icon by name. Use `source: notification.appIcon`.

**`NotificationServer` capability flags** (all `bool`, default `false` except `bodySupported`):
- `imageSupported` — advertise image support so apps send `notification.image`
- `actionsSupported` — advertise action button support

---

## Task 1: Advertise `imageSupported` and `actionsSupported` on NotificationServer

**Files:**
- Modify: `services/system/Notification.qml` (lines 27–39, the `NotificationServer` block)

**Step 1: Edit the NotificationServer block**

Current:
```qml
NotificationServer {
    id: server
    keepOnReload: true
    bodySupported: true

    onNotification: (notification) => { ... }
}
```

Change to:
```qml
NotificationServer {
    id: server
    keepOnReload: true
    bodySupported: true
    imageSupported: true
    actionsSupported: true

    onNotification: (notification) => { ... }
}
```

**Step 2: Verify static**

Open the file in an editor and confirm no import errors. The new properties are standard `NotificationServer` flags — no new imports needed.

**Step 3: Commit**

```bash
git add services/system/Notification.qml
git commit -m "feat(notifications): advertise image and actions support on NotificationServer"
```

---

## Task 2: Fix toast dismiss — call `notification.expire()` when toast is removed

Currently `removeToast(index)` only splices the array. The notification object itself is never told it was dismissed/expired.

**Files:**
- Modify: `services/system/Notification.qml` — change `removeToast` signature and logic
- Modify: `modules/popups/NotificationToastWindow.qml` — update the `onDismissed` call site

### Step 1: Update `removeToast` in `Notification.qml`

Change the signature from `removeToast(index: int)` to accept a notification object. Since the queue stores `{ notification, createdAt }` plain JS objects, we match by notification identity:

```qml
function removeToast(notification: Notification): void {
    if (!root.toastQueue) return;
    const idx = root.toastQueue.findIndex(item => item.notification === notification);
    if (idx === -1) return;
    let queue = root.toastQueue.slice();
    queue.splice(idx, 1);
    root.toastQueue = queue;
    notification.expire();
}
```

> **Why `expire()` not `dismiss()`?** The user clicking ✕ on a toast means "acknowledged / timed out from view", which maps to `expire()`. The notification stays in `trackedList` so it can still be seen in the notification popup. `dismiss()` would remove it from `trackedList` too (see `Notification.dismiss()`). If you want the ✕ button to also remove from history, use `Notification.dismiss(notification)` instead of just `expire()` — but the current design keeps toasts separate from history dismissal.

### Step 2: Update `NotificationToastWindow.qml` — fix the `onDismissed` handler

The delegate currently passes `index` (array index). Change to pass `modelData.notification`:

```qml
delegate: NotificationToast {
    required property var modelData

    width: toastColumn.width
    notification: modelData.notification

    onDismissed: {
        Notification.removeToast(modelData.notification);
    }
}
```

### Step 3: Verify

Check that both files have no type errors. The `Notification` type is already imported in both files.

### Step 4: Commit

```bash
git add services/system/Notification.qml modules/popups/NotificationToastWindow.qml
git commit -m "fix(notifications): call notification.expire() when toast is dismissed"
```

---

## Task 3: Fix sweep timer — call `notification.expire()` on timed-out toasts

The `toastSweepTimer` currently uses `filter()` to drop old entries but never notifies the apps.

**Files:**
- Modify: `services/system/Notification.qml` — update `toastSweepTimer.onTriggered`

### Step 1: Update the sweep timer handler

Current:
```qml
onTriggered: {
    if (!root.toastQueue) return;
    const now = Date.now();
    const duration = ShellConfig.toastDurationMs;
    const before = root.toastQueue.length;
    root.toastQueue = root.toastQueue.filter(item => (now - item.createdAt) < duration);
    // filter() assigns a new array so toastQueueChanged fires automatically
}
```

Change to:
```qml
onTriggered: {
    if (!root.toastQueue) return;
    const now = Date.now();
    const duration = ShellConfig.toastDurationMs;
    const expired = root.toastQueue.filter(item => (now - item.createdAt) >= duration);
    root.toastQueue = root.toastQueue.filter(item => (now - item.createdAt) < duration);
    for (const item of expired) {
        item.notification.expire();
    }
}
```

### Step 2: Verify

Confirm the logic: `expired` captures items being removed; then the queue is updated; then each expired notification is told it timed out. Order matters — update the queue first so the UI responds, then fire the signals.

### Step 3: Commit

```bash
git add services/system/Notification.qml
git commit -m "fix(notifications): call notification.expire() when toast times out via sweep timer"
```

---

## Task 4: Show real app icon in `NotificationToast`

Replace the hardcoded `🔔` emoji icon with real notification icon using `IconImage` for XDG icon names, with fallback chain: `appIcon` (XDG name) → `image` (raw image) → `🔔` emoji.

**Files:**
- Modify: `modules/popups/NotificationToast.qml`

### Step 1: Add the Quickshell.Widgets import

At the top of `NotificationToast.qml`, after the existing imports, add:

```qml
import Quickshell.Widgets
```

### Step 2: Replace the hardcoded icon block

Current icon block (lines 36–49):
```qml
Rectangle {
    id: iconContainer
    width: Theme.iconSizeSmall * 2
    height: width
    radius: Theme.radiusSmall
    color: Qt.alpha(Theme.accentColor, 0.2)
    anchors.verticalCenter: parent.verticalCenter

    Text {
        anchors.centerIn: parent
        text: "🔔"
        font.pixelSize: Theme.iconSizeSmall
        color: Theme.accentColor
    }
}
```

Replace with:
```qml
Rectangle {
    id: iconContainer
    width: Theme.iconSizeSmall * 2
    height: width
    radius: Theme.radiusSmall
    color: Qt.alpha(Theme.accentColor, 0.2)
    anchors.verticalCenter: parent.verticalCenter

    // XDG icon name (e.g. "firefox", "spotify") — shown when appIcon is non-empty
    IconImage {
        anchors.fill: parent
        anchors.margins: 4
        source: toast.notification.appIcon
        visible: toast.notification.appIcon !== ""
    }

    // Raw image (e.g. album art, app-provided pixmap) — shown when appIcon is empty but image exists
    Image {
        anchors.fill: parent
        anchors.margins: 4
        source: toast.notification.image || ""
        visible: toast.notification.appIcon === "" && (toast.notification.image || "") !== ""
        fillMode: Image.PreserveAspectFit
    }

    // Fallback emoji when no icon at all
    Text {
        anchors.centerIn: parent
        text: "🔔"
        font.pixelSize: Theme.iconSizeSmall
        color: Theme.accentColor
        visible: toast.notification.appIcon === "" && (toast.notification.image || "") === ""
    }
}
```

> **Note on `notification.image`**: Quickshell exposes `image` as a QML `Image` source-compatible value (may be a url or a `QImage`-backed source). Assign it directly to `Image.source`. If it's `null` or `undefined`, guard with `|| ""` to avoid binding errors.

### Step 3: Verify static

Confirm `Quickshell.Widgets` is a valid import (it is — `IconImage` is documented at https://quickshell.org/docs/master/types/Quickshell.Widgets/IconImage/). Confirm `IconImage` accepts a `source` string property (it does — it's an `Image`-like type).

### Step 4: Commit

```bash
git add modules/popups/NotificationToast.qml
git commit -m "feat(notifications): show real app icon in toast with XDG icon, image, and emoji fallback"
```

---

## Verification Checklist

After all 4 tasks, do a smoke test:

1. **Launch the shell**: `quickshell -p /home/xoid/projects/private/qs-dev`
2. **Send a test notification**:
   ```bash
   notify-send -i firefox "Test title" "Test body from Firefox"
   ```
3. **Verify**: Toast appears, shows the Firefox icon (not `🔔`), disappears after `toastDurationMs` ms
4. **Dismiss test**: Send another notification, click ✕ — toast disappears immediately
5. **No regressions**: Notification popup (NotificationIndicatorWidget → NotificationPopup) still works; `trackedList` still grows as expected

---

## Execution Options

**Plan complete and saved to `docs/plans/2026-05-01-notification-toast-integration.md`.**

**Two execution options:**

**1. Subagent-Driven (this session)** — I dispatch a fresh subagent per task, review between tasks, fast iteration

**2. Parallel Session (separate)** — Open a new session with `executing-plans`, batch execution with checkpoints

Which approach?
