# Tooltip

Advanced tooltip window with automatic positioning and animations.

## Overview

`Tooltip` is a `PopupWindow`-based component providing intelligent, screen-aware tooltip positioning. It supports both text and grid content modes, automatic direction selection, multi-screen awareness, and rich show/hide animations.

## File Location

`components/Tooltip.qml`

## Properties

### Content

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `text` | `string` | `""` | Text content (for text mode) |
| `rows` | `array` | `null` | Grid data: `[['col1', 'col2'], ['row2col1', 'row2col2']]` |
| `isGridMode` | `bool` (readonly) | - | True when rows is set |
| `columnCount` | `int` (readonly) | - | Number of columns in grid mode |

### Positioning

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `direction` | `string` | `"auto"` | Preferred direction: "auto", "left", "right", "top", "bottom" |
| `margin` | `int` | `Config.Theme.spacing` | Distance from target element |
| `padding` | `int` | `Config.Theme.padding` | Internal padding |
| `gridPaddingVertical` | `int` | `Config.Theme.spacing` | Extra vertical padding for grids |
| `maxWidth` | `int` | `340` | Maximum tooltip width |

### Timing

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `delay` | `int` | `0` | Delay before showing (ms) |
| `hideDelay` | `int` | `0` | Delay before hiding (ms) |

### Animation

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `animationDuration` | `int` | `Config.Theme.animationFast` | Show/hide animation duration |
| `animationScale` | `real` | `0.85` | Initial scale for show animation |

### Font

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `fontFamily` | `string` | `Config.Theme.fontFamily` | Font family |
| `fontSize` | `int` | `Config.Theme.fontSizeSmall` | Font size |

### Internal

| Property | Type | Description |
|----------|------|-------------|
| `targetItem` | `var` | Item the tooltip is anchored to |
| `anchorX` / `anchorY` | `real` | Anchor position relative to target |
| `isPositioned` | `bool` | Position has been calculated |
| `animatingOut` | `bool` | Currently hiding |
| `screenWidth` / `screenHeight` | `int` | Current screen dimensions |
| `screenX` / `screenY` | `int` | Current screen offset |

## Methods

```qml
function show(target, content, direction, delay, customFont)     // Show tooltip
function hide()                                                    // Hide with animation
function hideImmediately()                                           // Hide without animation
function updateContent(newContent)                                 // Update while showing
function repositionTooltip()                                       // Recalculate position
function reset()                                                     // Reset all state
```

## Usage

### Simple text tooltip
```qml
Components.Tooltip {
    id: tooltip
}

// Show on hover:
tooltip.show(myButton, "Click to save", "auto", 500)
```

### Grid tooltip (key-value pairs)
```qml
tooltip.show(statusIcon, [
    ["CPU", cpuUsage + "%"],
    ["Memory", memUsage + "%"],
    ["Uptime", uptimeString]
], "bottom", 0)
```

### With custom delay and direction
```qml
tooltip.show(widget, "Loading...", "right", 1000)
```

### Manual hide
```qml
tooltip.hide()           // Animates out
tooltip.hideImmediately() // Instant hide
```

## Auto-positioning Logic

When `direction` is `"auto"`:

1. Calculate available space in all 4 directions
2. Try positions in order: bottom → top → right → left
3. Use first position that fits completely
4. If none fit, use position with most available space
5. Adjust position to keep tooltip on screen

## Animation

### Show Animation
- Opacity: 0 → 1
- Scale: `animationScale` → 1
- Easing: `OutCubic` / `OutBack` with overshoot

### Hide Animation
- Opacity: 1 → 0
- Scale: 1 → `animationScale`
- Duration: 75% of show duration
- Easing: `InCubic`

## Screen Awareness

- Detects which screen contains the target item
- Clamps tooltip to screen bounds
- Handles multi-monitor setups with different geometries

## Grid Mode

Calculates optimal column widths based on content:
- Measures each cell's text
- Uses maximum width per column
- Adds spacing between columns
- Maintains uniform row height

## Styling

| Element | Property | Value |
|---------|----------|-------|
| Background | `color` | `Config.Theme.bgDark` |
| Border | `color` / `width` | `Config.Theme.fgMuted` / `1` |
| Border radius | `radius` | `min(borderRadius, min(width,height)/3)` |
| Text color | `color` | `Config.Theme.fg` |
