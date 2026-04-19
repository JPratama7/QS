pragma ComponentBehavior: Bound

import QtQuick
import "../../../config"
import "../../../services/system"

Text {
    id: widget

    visible: Power.present
    text: Power.present ? Power.percent + "%" : "⏻ AC"
    color: {
        if (Power.charging) return "#3b82f6";
        if (Power.percent < 20) return "#ef4444";
        return Theme.foregroundColor;
    }
    font.pixelSize: Theme.fontSizeSmall
    font.family: Theme.fontFamily
}
