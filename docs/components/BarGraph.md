# BarGraph

Live data graph with area fill.

## Overview

`BarGraph` renders a scrolling line graph with area fill using HTML5 Canvas. It's designed for real-time data visualization like CPU usage, network traffic, or memory consumption.

## File Location

`components/BarGraph.qml`

## Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `values` | `array` | `[]` | Array of numeric values to graph |
| `maxPoints` | `int` | `30` | Maximum number of points to display |
| `color` | `color` | `Config.Theme.accent` | Line color |
| `fillColor` | `color` | `color` at 30% opacity | Area fill color |
| `graphHeight` | `int` | `20` | Graph height |
| `graphWidth` | `int` | `60` | Graph width |

## Methods

```qml
function addValue(value)    // Add a new value to the graph, removes oldest if over maxPoints
function clearValues()      // Clear all values and redraw
```

## Usage

### CPU usage graph
```qml
Components.BarGraph {
    id: cpuGraph
    graphWidth: 80
    graphHeight: 30
    color: "#ff6b6b"
}

// In service or timer:
cpuGraph.addValue(cpuService.usagePercent)
```

### Network traffic graph
```qml
Components.BarGraph {
    id: netGraph
    maxPoints: 50
    color: Config.Theme.accent
    fillColor: Qt.rgba(Config.Theme.accent.r, Config.Theme.accent.g, Config.Theme.accent.b, 0.2)
}
```

## Rendering

The graph is drawn on an HTML5 Canvas:

1. **Fill area**: Closed path from bottom-left through all points to bottom-right
2. **Line**: Stroke path connecting all data points

Values are normalized against the maximum value in the dataset (minimum 1 to avoid division by zero).

## Performance

- Uses `Canvas` with `requestPaint()` only when data changes
- Data array is truncated to `maxPoints` automatically
- No animations - immediate redraw on value change
