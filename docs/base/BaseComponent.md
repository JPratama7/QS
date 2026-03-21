# BaseComponent

Foundation for all interactive components in the Quickshell bar.

## Overview

`BaseComponent` provides a reusable base for interactive UI elements with consistent theming, hover states, press animations, and background transitions. It handles mouse interactions and visual feedback automatically.

## File Location

`base/BaseComponent.qml`

## Properties

### Size

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `size` | `int` | `Config.Theme.componentSize` | Base dimension (width and height) |
| `implicitWidth` | `int` | `size` | Component width |
| `implicitHeight` | `int` | `size` | Component height |

### Colors

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `foreground` | `color` | `Config.Theme.fg` | Primary text/icon color |
| `background` | `color` | `Config.Theme.bgBright` | Default background color |
| `backgroundHover` | `color` | `Config.Theme.widgetBgHover` | Background when hovered |
| `backgroundActive` | `color` | `Config.Theme.widgetBgActive` | Background when active |
| `currentBackground` | `color` (readonly) | - | Computed background based on state |

### State

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `hovered` | `bool` | `false` | True when mouse is over the component |
| `pressed` | `bool` | `false` | True when component is being pressed |
| `disabled` | `bool` | `false` | Disables interactions when true |
| `active` | `bool` | `false` | Active/toggled state |

### Animation

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `animationDuration` | `int` | `Config.Theme.animationNormal` | Duration for all animations |
| `animateBackground` | `bool` | `true` | Enable background color transitions |
| `animateScale` | `bool` | `true` | Enable scale animations |
| `scaleOnHover` | `real` | `1.0` | Scale factor when hovered (1.0 = no change) |
| `scaleOnPress` | `real` | `0.95` | Scale factor when pressed |
| `showBackground` | `bool` | `true` | Toggle background visibility |

## Methods

```qml
function animateTo(target: var, property: string, value: var): void
function setForeground(color: color): void
function setBackground(color: color): void
function setDisabled(disabled: bool): void
function setActive(active: bool): void
```

## Usage

```qml
import "../base" as Base

Base.BaseComponent {
    id: myButton
    size: 40
    
    // Custom colors
    foreground: "#ffffff"
    background: "#333333"
    backgroundHover: "#444444"
    
    // Animation tuning
    scaleOnHover: 1.05
    scaleOnPress: 0.92
    animationDuration: 150
    
    // Add content as children
    Rectangle {
        anchors.centerIn: parent
        width: 20
        height: 20
        color: parent.foreground
    }
}
```

## Content Container

Child elements should anchor to the `content` item:

```qml
Base.BaseComponent {
    Text {
        parent: content  // Important!
        anchors.centerIn: parent
        text: "Click me"
        color: root.foreground
    }
}
```

## States

| State | Condition | Effect |
|-------|-----------|--------|
| `hovered` | `hovered && !pressed && !disabled` | Applies `scaleOnHover` |
| `pressed` | `pressed && !disabled` | Applies `scaleOnPress` |
| `disabled` | `disabled` | Applies `Config.Theme.opacityDisabled` |

## Signals

None exposed directly. Handle interactions via `HoverHandler` and `TapHandler` children, or use signals in derived components.
