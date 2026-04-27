pragma ComponentBehavior: Bound

import QtQuick
import "../../../config"
import "../../../services/system"

Text {
    id: widget

    property Component tooltipComponent: Component {
        Text {
            text: Idle.inhibited ? "Idle Inhibitor: Active" : "Idle Inhibitor: Inactive"
            font.pixelSize: Theme.fontSizeSmall
            color: Theme.foregroundColor
        }
    }

    text: "\u23F1" // Hourglass icon
    font.pixelSize: Theme.fontSizeNormal
    font.family: Theme.fontFamily

    color: Idle.inhibited ? Theme.accentColor : Theme.mutedColor

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: Idle.toggle()
    }
}
