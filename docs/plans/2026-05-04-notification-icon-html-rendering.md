# Plan: Enhanced Icon & HTML Markup for NotificationToast

**Date**: 2026-05-04
**Status**: planned
**Scope**: `NotificationToast.qml`, `NotificationPopup.qml`, `Notification.qml` (service)

---

## Current State

Both `NotificationToast.qml` and `NotificationPopup.qml` use a hardcoded `🔔` emoji for icons and
render body text as plain `Text` with no markup support. The `NotificationServer` already advertises
`bodyMarkupSupported: true` and `imageSupported: true`, but neither is consumed in the UI.

---

## Available Notification Properties (from qmltypes)

| Property | Type | Notes |
|---|---|---|
| `appIcon` | `string` | XDG icon name or absolute path |
| `image` | `string` | Image path/URI from notification |
| `desktopEntry` | `string` | Desktop entry ID for icon resolution |
| `body` | `string` | May contain HTML markup |
| `urgency` | `enum` | `Low`, `Normal`, `Critical` |
| `actions` | `list<NotificationAction>` | Each has `identifier`, `text`, `invoke()` |

---

## Phase 1: Icon Rendering

**Goal**: Replace hardcoded `🔔` with the notification's actual app icon.

**Icon resolution priority**:

1. `notification.image` — if non-empty, use as `Image` source (file path or data URI)
2. `notification.appIcon` — resolve via `AppIcons.iconFromName()` → `IconImage`
3. `notification.desktopEntry` — resolve via `AppIcons.iconForAppId()` → `IconImage`
4. Fallback — current `🔔` emoji

**Implementation** — a `Loader` that picks the right component based on available data:

```qml
Loader {
    id: iconLoader
    width: iconSize
    height: iconSize
    anchors.verticalCenter: parent.verticalCenter
    sourceComponent: {
        if (notification.image) return imageIconComp;
        if (notification.appIcon) return namedIconComp;
        if (notification.desktopEntry) return desktopIconComp;
        return fallbackIconComp;
    }

    Component {
        id: imageIconComp
        Image {
            width: iconSize; height: iconSize
            source: notification.image
            fillMode: Image.PreserveAspectFit
        }
    }
    Component {
        id: namedIconComp
        IconImage {
            width: iconSize; height: iconSize
            source: AppIcons.iconFromName(notification.appIcon)
        }
    }
    Component {
        id: desktopIconComp
        IconImage {
            width: iconSize; height: iconSize
            source: AppIcons.iconForAppId(notification.desktopEntry)
        }
    }
    Component {
        id: fallbackIconComp
        Text {
            anchors.centerIn: parent
            text: "🔔"
            font.pixelSize: Theme.iconSizeSmall
            color: Theme.accentColor
        }
    }
}
```

**Files to modify**:
- `modules/popups/NotificationToast.qml` — replace icon container block (lines 36-50)
- `modules/popups/NotificationPopup.qml` — same pattern for popup list items (lines 123-137)

**New imports needed**:
- `Quickshell.Widgets` (for `IconImage`)
- `../../services/system` (for `AppIcons`)

---

## Phase 2: HTML Markup Body Rendering + Expand/Collapse

**Goal**: Render `notification.body` with HTML markup, limit to a few lines by default,
allow expanding to full content.

**Approach**:

### 2a: Markup Rendering

Set `textFormat: Text.StyledText` on body `Text` elements.

Qt's `Text.StyledText` supports a safe subset of HTML 4:
`<b>`, `<i>`, `<u>`, `<s>`, `<a href>`, `<br>`, `<font>`, `<span style>`, `<img>` (local only), etc.
It does **not** load remote images or execute scripts — making it safe for notification bodies.

**Security note**: Since `bodyMarkupSupported: true` is already set on the server, notification
senders already expect markup rendering. `Text.StyledText` is the right choice (vs `Text.RichText`
which is heavier and can load external resources).

### 2b: Expand/Collapse

Body text is collapsed by default (`maximumLineCount: 2`) with an "expand" affordance when the
text is truncated. Clicking the body toggles between collapsed and expanded states.

**Collapsed state**:
- `maximumLineCount: 2`, `elide: Text.ElideRight`
- When `truncated === true`, show a small "show more" indicator (e.g. `▼` or "..." in muted color)
  below or inline at the end of the text

**Expanded state**:
- Remove `maximumLineCount` restriction
- Show full body with word wrap
- Indicator changes to "show less" (e.g. `▲`)
- Toast `implicitHeight` grows to accommodate expanded content

**Implementation sketch**:

```qml
// In the body Column, replace the simple bodyText with:

property bool bodyExpanded: false

Text {
    id: bodyText
    width: parent.width
    text: notification.body || ""
    textFormat: Text.StyledText
    color: Theme.mutedColor
    font.pixelSize: Theme.fontSizeSmall
    font.family: Theme.fontFamily
    wrapMode: Text.WordWrap
    maximumLineCount: bodyExpanded ? undefined : 2
    elide: Text.ElideRight
    visible: text.length > 0
}

Text {
    id: expandIndicator
    visible: bodyText.truncated || bodyExpanded
    text: bodyExpanded ? "▲ show less" : "▼ show more"
    color: Theme.accentColor
    font.pixelSize: Theme.fontSizeSmall - 1
    font.family: Theme.fontFamily
    anchors.right: parent.right

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: bodyExpanded = !bodyExpanded
    }
}
```

**Interaction note**: The expand click must NOT trigger the toast's dismiss `MouseArea`.
Use `z` ordering or event propagation control — the indicator's `MouseArea` sits above
the dismiss area so clicks on the expand toggle are consumed locally.

`bodyHyperlinksSupported` and `bodyImagesSupported` are already `true` on the `NotificationServer`
— no service changes needed.

**Files to modify**:
- `modules/popups/NotificationToast.qml` — add `textFormat: Text.StyledText`, expand/collapse logic
- `modules/popups/NotificationPopup.qml` — same on body `Text` (can use larger line limit, e.g. 3, still expandable)

---

## Phase 3: Urgency-based Visual Styling

**Goal**: Visually differentiate notifications by urgency level.

**Approach**: Map urgency to accent colors on the icon container and card border:

| Urgency | Icon container bg | Border accent |
|---|---|---|
| `Low` | `Qt.alpha(Theme.mutedColor, 0.15)` | none |
| `Normal` | `Qt.alpha(Theme.accentColor, 0.2)` (current) | none |
| `Critical` | `Qt.alpha(Theme.errorColor, 0.2)` | `1px Theme.errorColor` |

**Implementation** — property bindings on the icon container `Rectangle` and card `Rectangle`:

```qml
// Icon container
color: {
    if (notification.urgency === NotificationUrgency.Critical)
        return Qt.alpha(Theme.errorColor, 0.2);
    if (notification.urgency === NotificationUrgency.Low)
        return Qt.alpha(Theme.mutedColor, 0.15);
    return Qt.alpha(Theme.accentColor, 0.2); // Normal
}

// Card border (add/change on outer Rectangle)
border.color: notification.urgency === NotificationUrgency.Critical
    ? Qt.alpha(Theme.errorColor, 0.3)
    : Qt.alpha(Theme.foregroundColor, 0.1)
```

**Files to modify**:
- `modules/popups/NotificationToast.qml` — urgency-driven colors on icon container and card
- `modules/popups/NotificationPopup.qml` — same

---

## Phase 4: Action Buttons (stretch / optional)

**Goal**: Render notification action buttons (e.g., "Mark as read", "Reply").

**Approach**: Add a `Flow` of small action buttons below the body text. Each calls `action.invoke()`
on click.

This increases toast height and complexity — defer unless explicitly wanted.

---

## Summary of Changes

| Phase | Scope | Complexity |
|---|---|---|
| 1. Icon rendering | Toast + Popup | Medium — Loader pattern, 3 icon sources |
| 2. HTML markup + expand/collapse | Toast + Popup | Medium — markup rendering + toggle state + indicator |
| 3. Urgency styling | Toast + Popup | Low — color mapping |
| 4. Action buttons | Toast + Popup | Medium — new UI elements, height changes |

Phases 1-3 are tightly coupled (all touch the same icon container / body text area), so they
should be implemented together in a single pass on each file. Phase 4 is independent and can
be done later.

---

## Verification

1. **Static**: Files open in IDE without unresolved imports (`IconImage`, `AppIcons`)
2. **Smoke**: Shell launches without crashing, notifications render
3. **Interaction**: Send test notifications with varying icon sources, markup, and body length:
   ```sh
   notify-send -i firefox "Test Title" "<b>Bold</b> and <i>italic</i> body"
   notify-send -u critical "Critical Alert" "Something urgent"
   notify-send -u low "Low Priority" "Nothing important"
   # Long body to test expand/collapse
   notify-send "Long Notification" "Line one.\nLine two.\nLine three.\nLine four.\nLine five."
   ```
4. **Regression**: Toast dismiss, popup scroll, empty state still work; clicking expand does not dismiss

---

## References

- Quickshell Notification API: `/usr/lib/qt6/qml/Quickshell/Services/Notifications/quickshell-service-notifications.qmltypes`
- AppIcons service: `services/system/AppIcons.qml`
- IconImage: `Quickshell.Widgets` — `https://quickshell.org/docs/master/types/widgets/iconimage`
- Qt Text.StyledText: `https://doc.qt.io/qt-6/qml-qtquick-text.html#textFormat-prop`
- Qt HTML Subset: `https://doc.qt.io/qt-6/richtext-html-subset.html`