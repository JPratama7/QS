pragma ComponentBehavior: Bound

import QtQuick
import "../../../config"
import "../../../services/launcher"

Item {
    id: widget

    required property string screenName

    implicitWidth: label.implicitWidth
    implicitHeight: label.implicitHeight

    Text {
        id: label
        anchors.centerIn: parent
        text: "\u2630"
        color: Theme.foregroundColor
        font.pixelSize: Theme.fontSizeNormal
        font.family: Theme.fontFamily
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: Launcher.open(widget.screenName)
    }
}
