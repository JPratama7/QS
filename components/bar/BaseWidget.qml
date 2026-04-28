pragma ComponentBehavior: Bound

import QtQuick

Item {
    id: widget

    property Component tooltipComponent
    property real widgetScale: 1.0

    transform: Scale {
        origin.x: widget.width / 2
        origin.y: widget.height / 2
        xScale: widget.widgetScale
        yScale: widget.widgetScale
    }
}
