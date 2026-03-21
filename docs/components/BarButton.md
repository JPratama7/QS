# BarButton

Interactive button component with icon and/or text.

## Overview

`BarButton` extends `BaseComponent` to provide a ready-to-use button with support for icons (using icon fonts), text labels, or both. It handles hover, press states, and click signals automatically.

## File Location

`components/BarButton.qml`

## Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `icon` | `string` | `""` | Icon character (from icon font) |
| `text` | `string` | `""` | Button text label |
| `iconColor` | `color` | `foreground` | Icon color |
| `iconSize` | `int` | `Config.Theme.iconSize` | Icon font size |
| `showBackground` | `bool` | `true` | Show background rectangle |

## Signals

| Signal | Description |
|--------|-------------|
| `clicked()` | Emitted when button is clicked |

## Usage

### Icon-only button
```qml
Components.BarButton {
    icon: "\uf011"  // Power icon
    onClicked: togglePower()
}
```

### Text-only button
```qml
Components.BarButton {
    text: "Settings"
    onClicked: openSettings()
}
```

### Icon + Text button
```qml
Components.BarButton {
    icon: "\uf013"  // Gear icon
    text: "Settings"
    iconColor: Config.Theme.accent
    onClicked: openSettings()
}
```

### Custom styled button
```qml
Components.BarButton {
    icon: "\uf028"  // Volume icon
    size: 48
    foreground: "#ffffff"
    background: "#333333"
    backgroundHover: "#444444"
    scaleOnHover: 1.05
    onClicked: toggleMute()
}
```

## Styling

The button auto-sizes based on content:
- `implicitWidth`: icon/text width + `widgetPadding * 2`
- `implicitHeight`: `Config.Theme.componentSize`

Icon and text are vertically centered with `Config.Theme.spacing` between them.

## Interaction

- `hoverEnabled`: true (cursor changes to pointing hand)
- `pressed` state: updates on press/release
- `hovered` state: updates on enter/exit

Both icon and text have `ColorAnimation` on color changes with `animationDuration`.
