import QtQuick
import "../../../config"
import "../../../services/system"

Text {
    id: widget

    text: Network.connected ? Network.ssid : "Off"
    color: Network.connected ? Theme.foregroundColor : Theme.mutedColor
    font.pixelSize: Theme.fontSizeSmall
    font.family: Theme.fontFamily
}
