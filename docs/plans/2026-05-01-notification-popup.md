# Notification Popup Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Add a click-to-open notification popup (full list) and a stacking auto-dismiss toast system for new notifications on the primary screen only.

**Architecture:** The notification popup reuses the existing `PopupMenuWindow` / `ShellUI.openPopup()` mechanism — identical to `SessionMenu`. Toasts are a separate `PopupWindow` anchored to the bar window in `ScreenShellDelegate`, active only on the primary screen. The **toast queue lives in `Notification` service** — `ScreenShellDelegate` only instantiates and shows the `NotificationToastWindow`, which reads directly from the service. Toast position and max stack size are user-configurable flat properties in `Defaults` / `PersistentConfig`.

**Tech Stack:** QML, Quickshell, `Quickshell.Services.Notifications`

---

## Key Files Reference

| File | Role |
|---|---|
| `config/Defaults.qml` | Default values for all config |
| `config/PersistentConfig.qml` | JSON-backed config store (`JsonAdapter`) |
| `config/ShellConfig.qml` | Singleton that exposes adapter values |
| `config/Theme.qml` | Design tokens (colors, spacing, radii, fonts) |
| `services/system/Notification.qml` | Notification singleton — owns `trackedNotifications`, `toastQueue`, `dismiss()`, `dismissAll()` |
| `services/ui/ShellUI.qml` | Global UI coordination — `openPopup()`, popup signals |
| `modules/popups/PopupMenuWindow.qml` | Shared per-screen popup stage anchored to bar |
| `modules/popups/SessionMenu.qml` | **Style reference** for popup content components |
| `modules/popups/qmldir` | Module registration for popups |
| `modules/bar/widgets/SessionMenuButton.qml` | **Pattern reference** for clickable bar widgets that open popups |
| `modules/bar/widgets/NotificationIndicatorWidget.qml` | Widget to modify — add click-to-open |
| `modules/bar/BarLayout.qml` | Widget instantiation — pass `screenName`/`barWindow` to notifications widget |
| `modules/screens/ScreenShellDelegate.qml` | Per-screen orchestrator — instantiate toast window here |
| `types/ScreenContext.qml` | Has `isPrimary` and `barHeight` properties |

---

## Design Decisions

### Toast position
- Config key: `toastPosition: string`
- Valid values: `"top-left"`, `"top-center"`, `"top-right"`, `"bottom-left"`, `"bottom-center"`, `"bottom-right"`
- Default: `"top-right"`
- Stored as flat top-level property in `Defaults` / `PersistentConfig` (not nested under `bar`)

### Toast stacking
- Config key: `toastMaxStack: int`, default `3`
- Queue eviction: when at max, the **oldest** toast is dropped to make room
- Each toast entry carries a `createdAt: Date.now()` timestamp; a single sweep `Timer` in `Notification` expires them
- **Toast queue lives in `Notification` service** as `property var toastQueue: []`
- `ScreenShellDelegate` only instantiates `NotificationToastWindow` — it does not manage the queue

### Toast anchor
- `PopupWindow` anchored to `barWindow` (`PanelWindow`)
- `anchor.rect.x` computed from `toastPosition` horizontal zone + `ShellConfig.popupEdgeMargin`
- `anchor.rect.y` computed from `toastPosition` vertical zone:
  - Top positions: `context.barHeight + edgeMargin` (appears below bar)
  - Bottom positions: `-(toastColumn.implicitHeight + edgeMargin)` (appears above bar sitting at screen bottom)
- `grabFocus: false` — toasts never steal keyboard focus

### Notification popup
- Rendered inside the existing `PopupMenuWindow` via `ShellUI.openPopup()`
- `NotificationIndicatorWidget` gets `screenName` + `barWindow` (same pattern as `SessionMenuButton`)
- Fixed width 280px, dynamic height

---

## Task 1: Add config properties

**Files:**
- Modify: `config/Defaults.qml`
- Modify: `config/PersistentConfig.qml`
- Modify: `config/ShellConfig.qml`

### Step 1: Add defaults

In `config/Defaults.qml`, add after the `popupEdgeMargin` line:

```qml
// Toast notification defaults
readonly property string toastPosition: "top-right"
readonly property int toastMaxStack: 3
readonly property int toastDurationMs: 5000
```

### Step 2: Register in JsonAdapter

In `config/PersistentConfig.qml`, add inside the `JsonAdapter` block after `popupEdgeMargin`:

```qml
property string toastPosition: Defaults.toastPosition
property int toastMaxStack: Defaults.toastMaxStack
property int toastDurationMs: Defaults.toastDurationMs
```

### Step 3: Expose via ShellConfig

In `config/ShellConfig.qml`, add after the `popupEdgeMargin` line:

```qml
// Toast configuration
readonly property string toastPosition: PersistentConfig.adapter.toastPosition
readonly property int toastMaxStack: PersistentConfig.adapter.toastMaxStack
readonly property int toastDurationMs: PersistentConfig.adapter.toastDurationMs
```



---

## Task 2: Extend `Notification` service with toast queue

**Files:**
- Modify: `services/system/Notification.qml`

The service gains a `toastQueue` (list of `{ notification, createdAt }`), a sweep timer for auto-expiry, `addToast()` / `removeToast()`, and the `newNotificationReceived` signal.

### Step 1: Add toast queue state and signal

After the existing `property list<Notification> trackedList: []` line, add:

```qml
// Toast queue — each entry: { notification: Notification, createdAt: int }
property var toastQueue: []

signal newNotificationReceived(notification: Notification)
```

### Step 2: Populate queue and emit signal on new notification

Replace the existing `onNotification` handler with:

```qml
onNotification: (notification) => {
    notification.tracked = true;
    root.trackedList.push(notification);
    root.trackedListChanged();
    root.newNotificationReceived(notification);
    root.addToast(notification);
}
```

### Step 3: Add `addToast` and `removeToast` functions

Add after the existing `dismiss()` function:

```qml
function addToast(notification: Notification): void {
    const maxStack = ShellConfig.toastMaxStack;
    let queue = root.toastQueue.slice();
    if (queue.length >= maxStack) {
        queue.shift();
    }
    queue.push({ notification: notification, createdAt: Date.now() });
    root.toastQueue = queue;
}

function removeToast(index: int): void {
    let queue = root.toastQueue.slice();
    queue.splice(index, 1);
    root.toastQueue = queue;
}
```

### Step 4: Add sweep timer for auto-expiry

Add inside the `Singleton` body (alongside `NotificationServer`):

```qml
Timer {
    id: toastSweepTimer
    interval: 500
    repeat: true
    running: root.toastQueue.length > 0

    onTriggered: {
        const now = Date.now();
        const duration = ShellConfig.toastDurationMs;
        const before = root.toastQueue.length;
        root.toastQueue = root.toastQueue.filter(item => (now - item.createdAt) < duration);
        // filter() assigns a new array so toastQueueChanged fires automatically
    }
}
```

### Step 5: Add ShellConfig import

`Notification.qml` needs to read `ShellConfig.toastMaxStack` and `ShellConfig.toastDurationMs`. Add to the import block:

```qml
import "../../config"
```



---

## Task 3: Create `NotificationToast.qml` — single toast card

**Files:**
- Create: `modules/popups/NotificationToast.qml`

Visual card only — no `PopupWindow`. Used as a delegate inside `NotificationToastWindow`.

```qml
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell.Services.Notifications
import "../../config"

Item {
    id: toast

    required property Notification notification
    signal dismissed()

    readonly property int cardPadding: Theme.paddingNormal

    implicitWidth: parent.width
    implicitHeight: cardContent.implicitHeight + cardPadding * 2

    Rectangle {
        anchors.fill: parent
        color: Theme.surfaceColor
        radius: Theme.radiusNormal
        border.width: 1
        border.color: Qt.alpha(Theme.foregroundColor, 0.1)
    }

    Column {
        id: cardContent
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            margins: toast.cardPadding
        }
        spacing: Theme.spacingSmall

        // Header row: summary + dismiss button
        Item {
            width: parent.width
            implicitHeight: summaryText.implicitHeight

            Text {
                id: summaryText
                anchors {
                    left: parent.left
                    right: dismissButton.left
                    rightMargin: Theme.spacingSmall
                    verticalCenter: parent.verticalCenter
                }
                text: toast.notification.summary
                color: Theme.foregroundColor
                font.pixelSize: Theme.fontSizeSmall
                font.bold: true
                font.family: Theme.fontFamily
                elide: Text.ElideRight
            }

            Text {
                id: dismissButton
                anchors {
                    right: parent.right
                    verticalCenter: parent.verticalCenter
                }
                text: "✕"
                color: Theme.mutedColor
                font.pixelSize: Theme.fontSizeSmall
                font.family: Theme.fontFamily

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: toast.dismissed()
                }
            }
        }

        // Body — max 2 lines
        Text {
            width: parent.width
            visible: toast.notification.body !== ""
            text: toast.notification.body
            color: Theme.mutedColor
            font.pixelSize: Theme.fontSizeSmall
            font.family: Theme.fontFamily
            wrapMode: Text.WordWrap
            maximumLineCount: 2
            elide: Text.ElideRight
        }
    }
}
```

### Step 1: Create the file as above

### Step 2: Register in qmldir

In `modules/popups/qmldir`, add:

```
NotificationToast NotificationToast.qml
```



---

## Task 4: Create `NotificationToastWindow.qml` — stacking popup window

**Files:**
- Create: `modules/popups/NotificationToastWindow.qml`

`PopupWindow` that reads `Notification.toastQueue` directly — no queue management here.

```qml
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import "../../config"
import "../../services/system"
import "../../types"

PopupWindow {
    id: toastWindow

    required property ScreenContext context
    required property PanelWindow barWindow

    readonly property int toastWidth: 280
    readonly property int edgeMargin: ShellConfig.popupEdgeMargin

    readonly property string toastPos: ShellConfig.toastPosition
    readonly property string hZone: {
        if (toastPos.endsWith("left")) return "left";
        if (toastPos.endsWith("right")) return "right";
        return "center";
    }
    readonly property string vZone: toastPos.startsWith("top") ? "top" : "bottom"

    anchor.window: toastWindow.barWindow

    anchor.rect.x: {
        if (hZone === "left") return edgeMargin;
        if (hZone === "right") return context.screen.width - toastWidth - edgeMargin;
        return (context.screen.width - toastWidth) / 2;
    }

    anchor.rect.y: {
        if (vZone === "top") return context.barHeight + edgeMargin;
        return -(toastColumn.implicitHeight + edgeMargin);
    }

    implicitWidth: toastWidth
    implicitHeight: toastColumn.implicitHeight

    visible: Notification.toastQueue.length > 0
    grabFocus: false
    color: "transparent"

    Column {
        id: toastColumn
        width: toastWidth
        spacing: Theme.spacingSmall

        Repeater {
            model: Notification.toastQueue

            delegate: NotificationToast {
                required property var modelData
                required property int index

                notification: modelData.notification
                width: toastWidth

                onDismissed: Notification.removeToast(index)
            }
        }
    }
}
```

### Step 1: Create the file as above

### Step 2: Register in qmldir

In `modules/popups/qmldir`, add:

```
NotificationToastWindow NotificationToastWindow.qml
```



---

## Task 5: Wire toast window into `ScreenShellDelegate`

**Files:**
- Modify: `modules/screens/ScreenShellDelegate.qml`

The delegate only instantiates `NotificationToastWindow` on the primary screen. No queue management — the window reads `Notification.toastQueue` directly.

### Step 1: Add the toast window

Add after the `PopupMenuWindow` block:

```qml
Loader {
    active: delegate.context.isPrimary
    sourceComponent: NotificationToastWindow {
        context: delegate.context
        barWindow: barWindow
    }
}
```

### Step 2: Verify imports

`../popups` is already imported in `ScreenShellDelegate.qml`. No new imports needed.



---

## Task 6: Create `NotificationPopup.qml` — full notification list

**Files:**
- Create: `modules/popups/NotificationPopup.qml`

Popup content rendered inside `PopupMenuWindow`. Style mirrors `SessionMenu.qml`.

```qml
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell.Services.Notifications
import "../../config"
import "../../services/system"

Item {
    id: root

    required property string screenName

    readonly property int popupWidth: 280
    readonly property bool hasNotifications: Notification.unreadCount > 0

    implicitWidth: popupWidth
    implicitHeight: hasNotifications
        ? header.implicitHeight + divider.height + notifList.implicitHeight + Theme.paddingNormal * 3 + Theme.paddingSmall * 2
        : header.implicitHeight + emptyState.implicitHeight + Theme.paddingNormal * 3

    Rectangle {
        anchors.fill: parent
        color: Theme.surfaceColor
        radius: Theme.radiusNormal
        border.width: 1
        border.color: Qt.alpha(Theme.foregroundColor, 0.1)
    }

    // Header row
    Item {
        id: header
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            margins: Theme.paddingNormal
        }
        implicitHeight: headerLabel.implicitHeight + Theme.paddingSmall * 2

        Text {
            id: headerLabel
            anchors {
                left: parent.left
                verticalCenter: parent.verticalCenter
            }
            text: "Notifications"
            color: Theme.foregroundColor
            font.pixelSize: Theme.fontSizeNormal
            font.bold: true
            font.family: Theme.fontFamily
        }

        Rectangle {
            anchors {
                right: parent.right
                verticalCenter: parent.verticalCenter
            }
            visible: root.hasNotifications
            width: dismissAllLabel.implicitWidth + Theme.paddingSmall * 2
            height: dismissAllLabel.implicitHeight + Theme.paddingSmall * 2
            radius: Theme.radiusSmall
            color: dismissAllArea.containsMouse
                ? Qt.alpha(Theme.errorColor, 0.15)
                : "transparent"

            Text {
                id: dismissAllLabel
                anchors.centerIn: parent
                text: "Dismiss All"
                color: Theme.errorColor
                font.pixelSize: Theme.fontSizeSmall
                font.family: Theme.fontFamily
            }

            MouseArea {
                id: dismissAllArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: Notification.dismissAll()
            }
        }
    }

    Rectangle {
        id: divider
        anchors {
            top: header.bottom
            left: parent.left
            right: parent.right
            leftMargin: Theme.paddingNormal
            rightMargin: Theme.paddingNormal
        }
        height: 1
        color: Qt.alpha(Theme.foregroundColor, 0.1)
        visible: root.hasNotifications
    }

    Column {
        id: notifList
        anchors {
            top: divider.bottom
            topMargin: Theme.paddingSmall
            left: parent.left
            right: parent.right
            leftMargin: Theme.paddingNormal
            rightMargin: Theme.paddingNormal
        }
        visible: root.hasNotifications
        spacing: Theme.spacingSmall

        Repeater {
            model: Notification.trackedNotifications

            delegate: Rectangle {
                id: notifRow
                required property Notification modelData

                width: notifList.width
                implicitHeight: notifRowContent.implicitHeight + Theme.paddingSmall * 2
                radius: Theme.radiusSmall
                color: Theme.backgroundColor

                Column {
                    id: notifRowContent
                    anchors {
                        top: parent.top
                        left: parent.left
                        right: rowDismiss.left
                        margins: Theme.paddingSmall
                        rightMargin: Theme.spacingSmall
                    }
                    spacing: 2

                    Text {
                        width: parent.width
                        text: notifRow.modelData.summary
                        color: Theme.foregroundColor
                        font.pixelSize: Theme.fontSizeSmall
                        font.bold: true
                        font.family: Theme.fontFamily
                        elide: Text.ElideRight
                    }

                    Text {
                        width: parent.width
                        visible: notifRow.modelData.body !== ""
                        text: notifRow.modelData.body
                        color: Theme.mutedColor
                        font.pixelSize: Theme.fontSizeSmall
                        font.family: Theme.fontFamily
                        wrapMode: Text.WordWrap
                        maximumLineCount: 3
                        elide: Text.ElideRight
                    }
                }

                Text {
                    id: rowDismiss
                    anchors {
                        right: parent.right
                        top: parent.top
                        margins: Theme.paddingSmall
                    }
                    text: "✕"
                    color: Theme.mutedColor
                    font.pixelSize: Theme.fontSizeSmall
                    font.family: Theme.fontFamily

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Notification.dismiss(notifRow.modelData)
                    }
                }
            }
        }
    }

    // Empty state
    Item {
        id: emptyState
        anchors {
            top: header.bottom
            topMargin: Theme.paddingNormal
            left: parent.left
            right: parent.right
        }
        visible: !root.hasNotifications
        implicitHeight: emptyLabel.implicitHeight + Theme.paddingNormal * 2

        Text {
            id: emptyLabel
            anchors.centerIn: parent
            text: "No notifications"
            color: Theme.mutedColor
            font.pixelSize: Theme.fontSizeSmall
            font.family: Theme.fontFamily
        }
    }
}
```

### Step 1: Create the file as above

### Step 2: Register in qmldir

In `modules/popups/qmldir`, add:

```
NotificationPopup NotificationPopup.qml
```



---

## Task 7: Update `NotificationIndicatorWidget` — add click-to-open popup

**Files:**
- Modify: `modules/bar/widgets/NotificationIndicatorWidget.qml`

Pattern: `SessionMenuButton.qml`.

### Step 1: Add imports

Add to the import block:

```qml
import Quickshell
import "../../../services/ui"
import "../../popups"
```

### Step 2: Add required properties

Add after `id: widget`:

```qml
required property string screenName
required property PanelWindow barWindow
```

### Step 3: Add MouseArea and popup component

Add after the `Text` block:

```qml
MouseArea {
    anchors.fill: parent
    cursorShape: Qt.PointingHandCursor
    onClicked: {
        const pos = widget.mapToItem(null, 0, 0);
        ShellUI.openPopup(widget.screenName, "notifications", notificationPopupComponent, pos.x);
    }
}

Component {
    id: notificationPopupComponent
    NotificationPopup {
        screenName: widget.screenName
    }
}
```



---

## Task 8: Pass `screenName` and `barWindow` from `BarLayout` to the notifications widget

**Files:**
- Modify: `modules/bar/BarLayout.qml`

### Step 1: Update `notificationsComp`

Find:

```qml
Component {
    id: notificationsComp
    NotificationIndicatorWidget {
        widgetScale: barLayout.widgetScale
    }
}
```

Replace with:

```qml
Component {
    id: notificationsComp
    NotificationIndicatorWidget {
        screenName: barLayout.screenName
        barWindow: barLayout.barWindow
        widgetScale: barLayout.widgetScale
    }
}
```



---

## Task 9: Final smoke test

### Step 1: Kill any running shell instance

```bash
quickshell kill
```

### Step 2: Launch with the dev project

```bash
quickshell -p /home/xoid/projects/private/qs-dev
```

### Step 3: Verification checklist

- [ ] Shell launches without crash
- [ ] Notification indicator visible in bar
- [ ] Clicking indicator opens popup with "No notifications" empty state
- [ ] Clicking outside popup closes it
- [ ] Send a test notification: `notify-send "Test" "This is a test body"`
- [ ] Toast appears at `top-right` corner, auto-dismisses after 5 seconds
- [ ] Clicking `✕` on toast dismisses it immediately
- [ ] Clicking indicator after notification arrives shows it in the full popup
- [ ] Clicking `✕` in popup dismisses individual notification
- [ ] Clicking "Dismiss All" clears all notifications
- [ ] Sending 4 rapid notifications: only 3 toasts shown (oldest evicted)
- [ ] After all toasts expire, toast window is hidden

### Step 4: Config override test

Temporarily set in `config.json`:
```json
{ "toastPosition": "bottom-left", "toastMaxStack": 1 }
```
Verify toast appears at bottom-left and only one is shown at a time.

---

## Summary of all changed/created files

| Action | File |
|---|---|
| Modify | `config/Defaults.qml` |
| Modify | `config/PersistentConfig.qml` |
| Modify | `config/ShellConfig.qml` |
| Modify | `services/system/Notification.qml` |
| Create | `modules/popups/NotificationToast.qml` |
| Create | `modules/popups/NotificationToastWindow.qml` |
| Create | `modules/popups/NotificationPopup.qml` |
| Modify | `modules/popups/qmldir` |
| Modify | `modules/screens/ScreenShellDelegate.qml` |
| Modify | `modules/bar/widgets/NotificationIndicatorWidget.qml` |
| Modify | `modules/bar/BarLayout.qml` |
