pragma ComponentBehavior: Bound

import QtQuick
import "../../../config"
import "../../../components/bar"
import "../../../services/system"

BaseWidget {
    id: widget

    tooltipComponent: Component {
        Text {
            text: Idle.inhibited ? "Idle Inhibitor: Active" : "Idle Inhibitor: Inactive"
            font.pixelSize: Theme.fontSizeSmall
            color: Theme.foregroundColor
        }
    }

    implicitWidth: textItem.implicitWidth
    implicitHeight: textItem.implicitHeight

    Text {
        id: textItem
        text: "\u23F1" // Hourglass icon
        font.pixelSize: Theme.fontSizeNormal
        font.family: Theme.fontFamily
        color: Idle.inhibited ? Theme.accentColor : Theme.mutedColor
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: Idle.toggle()
    }
}
