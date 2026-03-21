# BaseWidget

Base class for all bar widgets with popup support and mouse interactions.

## Overview

`BaseWidget` provides a standardized container for widgets displayed in the Quickshell bar. It includes hover states, background styling, mouse event handling (click, right-click, middle-click, scroll), tooltip support, and integrated popup management.

## File Location

`base/BaseWidget.qml`

## Properties

### Layout

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `implicitWidth` | `int` | `contentRow.width + padding*2` | Auto-sized based on content |
| `implicitHeight` | `int` | `Config.Theme.componentSize` | Fixed height matching bar |

### State

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `expanded` | `bool` | `false` | Widget expanded state |
| `hasPopup` | `bool` | `false` | Enable popup functionality |
| `active` | `bool` | `false` | Active/toggled visual state |
| `showBackground` | `bool` | `true` | Toggle background visibility |
| `_popupOpen` | `bool` (readonly) | - | True when popup is visible |

### Popup

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `popupComponent` | `var` | `null` | Component to instantiate as popup |
| `popupInstance` | `var` | `null` | Live popup instance (managed internally) |

### Styling

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `containerColor` | `color` | `Config.Theme.widgetBg` | Background color override |
| `tooltipText` | `string` | `""` | Tooltip text on hover |
| `barPosition` | `int` | `Config.Config.position` | Bar position (inherited from parent or config) |

## Signals

```qml
signal clicked()         // Left click
signal rightClicked()    // Right click
signal middleClicked()   // Middle click
signal scrollUp()        // Scroll wheel up
signal scrollDown()      // Scroll wheel down
signal popupOpened()     // Popup was opened
signal popupClosed()      // Popup was closed
```

## Methods

```qml
function openPopup(): void      // Open the popup if hasPopup is true
function closePopup(): void     // Close the popup
function togglePopup(): void    // Toggle popup open/closed
function refresh(): void        // Override in child widgets to refresh data
function setActive(active: bool): void  // Set active state
```

## Usage

```qml
import "../base" as Base

Base.BaseWidget {
    id: myWidget
    hasPopup: true
    tooltipText: "My Widget"
    
    // Set popup component
    popupComponent: MyPopupComponent
    
    // Widget content
    Row {
        anchors.centerIn: parent
        spacing: 8
        
        Rectangle {
            width: 16
            height: 16
            color: "#00ff00"
        }
        
        Text {
            text: "Status"
            color: "#ffffff"
        }
    }
    
    onClicked: {
        console.log("Widget clicked")
    }
    
    onScrollUp: {
        volumeUp()
    }
}
```

## Content Container

Add child elements directly; the `contentRow` is internal. The widget auto-sizes based on content:

```qml
Base.BaseWidget {
    // Content is placed in implicit content area
    Text {
        anchors.centerIn: parent
        text: "Widget"
    }
}
```

## Mouse Handling

| Button | Signal | Action |
|--------|--------|--------|
| Left | `clicked()` | Opens popup if `hasPopup` is true |
| Right | `rightClicked()` | Custom handling |
| Middle | `middleClicked()` | Custom handling |
| Scroll Up | `scrollUp()` | Custom handling |
| Scroll Down | `scrollDown()` | Custom handling |

## Popup Management

Set `hasPopup: true` and assign a component:

```qml
Base.BaseWidget {
    hasPopup: true
    popupComponent: Component {
        Base.BasePopup {
            // Popup content
        }
    }
}
```

The widget handles:
- Lazy instantiation (only created when first opened)
- `openPopup()` / `closePopup()` / `togglePopup()` methods
- Signal emission (`popupOpened`, `popupClosed`)

## Tooltips

Tooltips use `TooltipService` from services:

```qml
Base.BaseWidget {
    tooltipText: "Volume: 75%"
    // Tooltip shows on hover with 500ms delay
}
```

## Background States

| State | Condition | Background |
|-------|-----------|------------|
| Active | `active === true` | `Config.Theme.widgetBgActive` |
| Hover | `mouseArea.containsMouse` | `Config.Theme.widgetBgHover` |
| Default | - | `transparent` |

Color transitions use `ColorAnimation` with `Config.Theme.animationNormal` duration.

## Extending BaseWidget

Override `refresh()` to update widget data:

```qml
Base.BaseWidget {
    function refresh() {
        // Update displayed data
        statusText.text = getCurrentStatus()
    }
}
```
