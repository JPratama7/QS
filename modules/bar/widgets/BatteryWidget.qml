import QtQuick
import "../../../config"
import "../../../services/system"

Text {
    id: widget

    visible: Power.present
    text: Power.present ? (Power.charging ? "charging" : Power.percent + "%") : ""
    color: Theme.mutedColor
    font.pixelSize: Theme.fontSizeSmall
    font.family: Theme.fontFamily
}
