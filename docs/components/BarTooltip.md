# BarTooltip

Simple inline tooltip component.

## Overview

`BarTooltip` provides a basic tooltip display with a bordered background, auto-sizing, and optional auto-hide timeout. This is a simpler alternative to the full `Tooltip` component for basic use cases.

## File Location

`components/BarTooltip.qml`

## Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `text` | `string` | `""` | Tooltip text content |
| `visible` | `bool` | `false` | Show/hide the tooltip |
| `delay` | `int` | `500` | Delay before showing (ms) |
| `timeout` | `int` | `3000` | Auto-hide timeout (ms) |

## Usage

### Hover tooltip
```qml
Item {
    HoverHandler {
        onHoveredChanged: tooltip.visible = hovered
    }

    Components.BarTooltip {
        id: tooltip
        text: "Click to toggle"
    }
}
```

### Delayed show with custom timeout
```qml
Components.BarTooltip {
    text: "This will show for 5 seconds"
    delay: 200
    timeout: 5000
}
```

## Styling

| Element | Property | Source |
|---------|----------|--------|
| Background | `color` | `Config.Theme.bgDark` |
| Border | `width` / `color` | `1` / `Config.Theme.fgMuted` |
| Border radius | `radius` | `Config.Theme.borderRadius` |
| Text color | `color` | `Config.Theme.fg` |
| Font size | `pixelSize` | `Config.Theme.fontSizeSmall` |

## Sizing

Auto-sized based on text content:
- `implicitWidth`: `tooltipText.implicitWidth + padding * 2`
- `implicitHeight`: `tooltipText.implicitHeight + padding`

## Auto-hide

When `visible` is true and `timeout > 0`, an internal `Timer` automatically hides the tooltip after the timeout duration.

## Animation

Opacity fades in/out with `NumberAnimation` using `Config.Theme.animationFast` duration.

## Comparison

| Feature | `BarTooltip` | `Tooltip` |
|---------|-------------|-----------|
| Positioning | Manual | Automatic (screen-aware) |
| Content | Simple text | Text or grid layout |
| Animation | Simple fade | Scale + fade with easing |
| Delay/Timeout | Built-in | Configurable |
| Screen clamping | No | Yes |
| Multi-screen | No | Yes |

Use `BarTooltip` for simple inline tooltips. Use `Tooltip` for complex positioning and rich content.
