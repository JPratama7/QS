# WidgetColumn

Pill-shaped container for widget layouts.

## Overview

`WidgetColumn` provides a rounded rectangle container (pill shape) that automatically sizes to its content. Used internally by the bar to group widget delegates with consistent styling.

## File Location

`components/WidgetColumn.qml`

## Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `content` | `alias` | - | Default property for child items |
| `bgColor` | `color` | `Config.Theme.widgetBg` | Background color |
| `horizontalPadding` | `int` | `Config.Theme.widgetPadding` | Left/right padding |
| `verticalPadding` | `int` | `0` | Top/bottom padding |

## Usage

### Basic container
```qml
Components.WidgetColumn {
    Text { text: "Status" }
    Text { text: "Active" }
}
```

### With custom background
```qml
Components.WidgetColumn {
    bgColor: Config.Theme.widgetBgActive
    horizontalPadding: 12
    
    Row {
        spacing: 8
        BarIcon { icon: "\uf00c" }
        BarText { text: "Connected" }
    }
}
```

### As widget wrapper
```qml
Components.WidgetColumn {
    bgColor: loader.item ? loader.item.containerColor : Config.Theme.widgetBg
    
    Loader {
        source: widgetSource
    }
}
```

## Geometry

- `radius`: `height / 2` - Creates a perfect pill shape regardless of height
- `implicitWidth`: `container.implicitWidth + horizontalPadding * 2`
- `implicitHeight`: `container.implicitHeight + verticalPadding * 2`

The internal `Column` centers its content and has `spacing: 0`.

## Styling

The pill shape is achieved with dynamic border radius:
```qml
radius: height / 2
```

This ensures the container always appears as a rounded pill, whether containing a single icon or a tall stack of items.

## Notes

- Content is placed in a `Column`, not a `Row`
- For horizontal layouts, wrap children in a `Row` inside the `WidgetColumn`
- Background color can be bound to widget state via `loader.item.containerColor`
