pragma ComponentBehavior: Bound

import QtQuick
import "../../../config"
import "../../../services/system"

Item {
    id: widget

    implicitWidth: text.implicitWidth
    implicitHeight: text.implicitHeight

    Text {
        id: text
        text: Network.connected ? Network.ssid : "Off"
        color: Network.connected ? Theme.foregroundColor : Theme.mutedColor
        font.pixelSize: Theme.fontSizeSmall
        font.family: Theme.fontFamily
    }

    MouseArea {
        anchors.fill: parent
        onClicked: Network.toggleWifi()
    }
}
