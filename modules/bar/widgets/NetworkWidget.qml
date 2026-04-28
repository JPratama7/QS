pragma ComponentBehavior: Bound

import QtQuick
import "../../../config"
import "../../../components/bar"
import "../../../services/system"

BaseWidget {
    id: widget

    tooltipComponent: Component {
        Text {
            text: Network.connected ? "WiFi: " + Network.ssid : "WiFi: Off"
            font.pixelSize: Theme.fontSizeSmall
            color: Theme.foregroundColor
        }
    }

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
