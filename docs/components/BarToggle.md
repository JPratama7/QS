# BarToggle

Animated toggle switch component.

## Overview

`BarToggle` provides an on/off switch with a sliding circular handle and animated color transitions. Commonly used for boolean settings like mute, notifications, or power states.

## File Location

`components/BarToggle.qml`

## Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `checked` | `bool` | `false` | Current toggle state |
| `checkedColor` | `color` | `Config.Theme.accent` | Track color when checked |
| `uncheckedColor` | `color` | `Config.Theme.bgDark` | Track color when unchecked |
| `handleColor` | `color` | `Config.Theme.fgBright` | Handle circle color |
| `toggleWidth` | `int` | `36` | Total switch width |
| `toggleHeight` | `int` | `18` | Track height (handle diameter - 4) |

## Signals

| Signal | Description |
|--------|-------------|
| `toggled(bool checked)` | Emitted when toggle state changes |

## Usage

### Basic toggle
```qml
Components.BarToggle {
    checked: notificationsEnabled
    onToggled: (c) => notificationsEnabled = c
}
```

### Mute toggle with custom colors
```qml
Components.BarToggle {
    checked: !audio.muted
    checkedColor: Config.Theme.accent
    uncheckedColor: Config.Theme.error
    onToggled: (c) => audio.setMuted(!c)
}
```

### Large toggle
```qml
Components.BarToggle {
    toggleWidth: 48
    toggleHeight: 24
    checked: darkMode
    onToggled: (c) => theme.setDarkMode(c)
}
```

## Interaction

- Click anywhere on the toggle to switch state
- Cursor changes to `PointingHandCursor` on hover
- `checked` property toggles on click

## Animation

| Element | Animation |
|---------|-----------|
| Track `color` | `ColorAnimation` on state change |
| Handle `x` position | `NumberAnimation` with `OutCubic` easing |

Handle slides from `2` to `toggleWidth - width - 2` pixels.

## Geometry

- Handle size: `toggleHeight - 4` (perfect circle)
- Handle positions: 2px padding on each side when at extremes
- Track radius: `toggleHeight / 2` (pill shape)
