pragma ComponentBehavior: Bound

import QtQuick
import "../../../config"
import "../../../services/system"

Text {
    id: widget

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
