# BarIcon

Simple icon display component with automatic sizing.

## Overview

`BarIcon` displays a single icon character from an icon font with proper metrics-based sizing. It automatically calculates its size based on the text metrics of the icon.

## File Location

`components/BarIcon.qml`

## Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `icon` | `string` | `""` | Icon character to display |
| `color` | `color` | `Config.Theme.fg` | Icon color |
| `size` | `int` | `Config.Theme.iconSize` | Font pixel size |
| `fontFamily` | `string` | `Config.Theme.fontFamily` | Font family for the icon |

## Usage

### Basic icon
```qml
Components.BarIcon {
    icon: "\uf026"  // Mute icon
}
```

### Styled icon
```qml
Components.BarIcon {
    icon: "\uf028"
    color: Config.Theme.accent
    size: 24
}
```

### Dynamic icon
```qml
Components.BarIcon {
    icon: audioService.isMuted ? "\uf026" : "\uf028"
    color: audioService.isMuted ? Config.Theme.error : Config.Theme.fg
}
```

## Sizing

The component uses `TextMetrics` to calculate proper implicit size:
- `implicitWidth`: Measured text width
- `implicitHeight`: Measured text height

This ensures the icon takes exactly the space it needs without clipping or excess padding.

## Animation

Color changes animate with `ColorAnimation` using `Config.Theme.animationNormal` duration.
