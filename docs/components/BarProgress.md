# BarProgress

Horizontal progress bar with optional value display.

## Overview

`BarProgress` displays a progress value as a filled horizontal bar. Supports custom ranges, colors, and optional text showing the current value.

## File Location

`components/BarProgress.qml`

## Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `value` | `real` | `0.5` | Current value |
| `minValue` | `real` | `0` | Minimum value |
| `maxValue` | `real` | `1` | Maximum value |
| `color` | `color` | `Config.Theme.accent` | Fill color |
| `backgroundColor` | `color` | `Config.Theme.bgDark` | Track background color |
| `radius` | `int` | `Config.Theme.borderRadius` | Corner radius |
| `thickness` | `int` | `4` | Bar thickness |
| `showValue` | `bool` | `false` | Show value text below bar |

## Computed Properties

| Property | Description |
|----------|-------------|
| `normalizedValue` | Value normalized to 0-1 range: `(value - min) / (max - min)` |

## Usage

### Basic progress bar
```qml
Components.BarProgress {
    value: 0.75
}
```

### Battery percentage
```qml
Components.BarProgress {
    value: battery.percent
    minValue: 0
    maxValue: 100
    color: battery.percent < 20 ? Config.Theme.error : Config.Theme.accent
    showValue: true
}
```

### Volume indicator
```qml
Components.BarProgress {
    value: audio.volume
    thickness: 6
    color: audio.isMuted ? Config.Theme.fgMuted : Config.Theme.accent
}
```

### Custom styled
```qml
Components.BarProgress {
    value: downloadProgress
    thickness: 8
    radius: 4
    color: "#4CAF50"
    backgroundColor: "#1a1a1a"
    showValue: true
}
```

## Layout

- Width defaults to `100` (override as needed)
- Height = `thickness` + (optional value text height + spacing)
- Fill width animates smoothly with `NumberAnimation`

## Animation

- `width`: Smooth animation on value change using `Config.Theme.animationNormal`
- `color`: Color transitions animate when changed
