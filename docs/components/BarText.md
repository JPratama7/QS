# BarText

Auto-sizing text label with elide support.

## Overview

`BarText` provides a text display that automatically sizes itself based on content metrics. Supports text truncation with ellipsis and color animations.

## File Location

`components/BarText.qml`

## Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `text` | `string` | `""` | Text content |
| `color` | `color` | `Config.Theme.fg` | Text color |
| `fontSize` | `int` | `Config.Theme.fontSizeNormal` | Font pixel size |
| `fontFamily` | `string` | `Config.Theme.fontFamily` | Font family |
| `bold` | `bool` | `false` | Bold font weight |
| `maxWidth` | `int` | `-1` | Maximum width (-1 = no limit) |

## Usage

### Simple label
```qml
Components.BarText {
    text: "Hello World"
}
```

### Status label with color
```qml
Components.BarText {
    text: connectionStatus
    color: isConnected ? Config.Theme.success : Config.Theme.error
    bold: true
}
```

### Time display
```qml
Components.BarText {
    text: Qt.formatTime(new Date(), "hh:mm")
    fontSize: Config.Theme.fontSizeLarge
    fontFamily: "monospace"
}
```

### Truncated text
```qml
Components.BarText {
    text: longWindowTitle
    maxWidth: 200  // Text will elide with ... if longer
}
```

## Sizing

Uses `TextMetrics` for accurate implicit sizing:
- `implicitWidth`: Measured text width
- `implicitHeight`: Measured text height

The internal `Text` element fills the component and uses `Text.ElideRight` when `maxWidth` is set.

## Animation

Color changes animate with `ColorAnimation` using `Config.Theme.animationNormal` duration.
