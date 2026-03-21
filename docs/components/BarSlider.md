# BarSlider

Interactive slider for value selection with vertical/horizontal orientations.

## Overview

`BarSlider` provides a draggable slider with a fill bar and circular handle. Supports both horizontal and vertical orientations, normal and inverted directions, mouse drag, and scroll wheel interactions.

## File Location

`components/BarSlider.qml`

## Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `value` | `real` | `0.5` | Current value |
| `minValue` | `real` | `0` | Minimum value |
| `maxValue` | `real` | `1` | Maximum value |
| `color` | `color` | `Config.Theme.accent` | Fill and handle color |
| `backgroundColor` | `color` | `Config.Theme.bgDark` | Track background color |
| `barHeight` | `int` | `4` | Track thickness (handle diameter + 4) |
| `barWidth` | `int` | `80` | Track length (when horizontal) |
| `vertical` | `bool` | `false` | Vertical orientation |
| `inverted` | `bool` | `false` | Invert fill direction |

## Signals

| Signal | Description |
|--------|-------------|
| `valueChanged(real newValue)` | Emitted when value changes via interaction |

## Usage

### Volume slider
```qml
Components.BarSlider {
    value: audioService.volume
    onValueChanged: (v) => audioService.setVolume(v)
}
```

### Vertical brightness slider
```qml
Components.BarSlider {
    vertical: true
    barWidth: 100
    value: brightness.level
    onValueChanged: (v) => brightness.setLevel(v)
}
```

### Inverted slider (fill from right)
```qml
Components.BarSlider {
    inverted: true
    color: Config.Theme.warning
}
```

### Custom sized
```qml
Components.BarSlider {
    barWidth: 120
    barHeight: 6
    color: "#2196F3"
}
```

## Orientation Modes

The fill rectangle uses states to handle 4 combinations:

| Vertical | Inverted | Fill Direction |
|----------|----------|----------------|
| false | false | Left to right |
| false | true | Right to left |
| true | false | Bottom to top |
| true | true | Top to bottom |

## Interaction

- **Click/Drag**: Sets value based on mouse position
- **Scroll wheel**: Adjusts value by 1/20th of range per wheel tick

## Animation

- `width`/`height`: Fill animates smoothly
- `x`/`y`: Handle follows with animation
- `color`: Transitions animate on change

All use `Config.Theme.animationNormal` duration with `OutCubic` easing.
