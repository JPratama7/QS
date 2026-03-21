# BasePopup

Popup window component with automatic positioning and animations.

## Overview

`BasePopup` extends `PopupWindow` from Quickshell to provide a styled, shadowed popup that automatically positions relative to an anchor widget. It supports all four bar positions (top, bottom, left, right) and includes open/close animations.

## File Location

`base/BasePopup.qml`

## Properties

### Positioning

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `anchorWidget` | `var` | `null` | Widget to anchor the popup to |
| `barPosition` | `int` | `Config.Config.position` | Position of the bar (Top/Bottom/Left/Right) |
| `popupWidth` | `int` | `Config.Config.popupWidth` | Popup width |
| `popupHeight` | `int` | `Config.Config.popupHeight` | Popup height |

### Behavior

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `autoClose` | `bool` | `Config.Config.popupAutoClose` | Close when clicking outside |
| `animationDuration` | `int` | `Config.Config.popupAnimationDuration` | Open/close animation duration |

### Window

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `color` | `color` | `"transparent"` | Window background (transparent, shadow drawn manually) |
| `visible` | `bool` | `false` | Window visibility |
| `implicitWidth` | `int` | `popupWidth` | Window width |
| `implicitHeight` | `int` | `popupHeight` | Window height |

## Methods

```qml
function open(widget: var): void      // Open popup anchored to widget
function close(): void                 // Close popup with animation
function reposition(): void            // Recalculate position based on anchor
```

## Usage

```qml
import "../base" as Base

Base.BasePopup {
    id: myPopup
    popupWidth: 300
    popupHeight: 200
    autoClose: true
    
    // Content goes inside content container
    Rectangle {
        parent: content
        anchors.fill: parent
        color: "#333333"
        
        Text {
            anchors.centerIn: parent
            text: "Popup Content"
            color: "#ffffff"
        }
    }
}
```

## Content Container

Child elements should anchor to the `content` item with appropriate margins:

```qml
Base.BasePopup {
    Item {
        parent: content
        anchors.fill: parent
        
        // Your popup content here
    }
}
```

## Positioning Logic

The popup positions itself relative to the bar:

| Bar Position | X Position | Y Position |
|--------------|-----------|------------|
| Top | Centered on widget | Below bar |
| Bottom | Centered on widget | Above bar |
| Left | Right of bar | Centered on widget |
| Right | Left of bar | Centered on widget |

Screen bounds clamping ensures the popup stays visible within the screen.

## Styling

| Element | Property | Source |
|-----------|----------|--------|
| Background | `color` | `Config.Theme.popupBg` |
| Border | `width` / `color` | `1` / `Config.Theme.popupBorder` |
| Border Radius | `radius` | `Config.Theme.borderRadiusLarge` |
| Shadow | `color` / `radius` | `Config.Theme.shadowColor` / `Config.Theme.shadowRadius` |
| Shadow Opacity | `opacity` | `Config.Theme.shadowOpacity` |
| Content Padding | `margins` | `Config.Theme.paddingLarge` |

## Animations

| Property | Animation | Duration |
|----------|-----------|----------|
| `opacity` | NumberAnimation | `animationDuration` |
| `scale` | NumberAnimation | `animationDuration` |

On open: `opacity → 1`, `scale → 1`
On close: `opacity → 0`, `scale → 0.9`

## Auto-Close Behavior

When `autoClose` is enabled, clicking outside the popup (on the transparent window area) triggers `close()`. The `MouseArea` capturing these clicks is at `z: -1` so it doesn't interfere with content interactions.
