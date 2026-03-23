pragma ComponentBehavior: Bound
import QtQuick
import "../config" as Config
import "../base" as Base
import "../components" as Components
import "../services" as Services

Base.BasePopup {
    id: root

    popupWidth: 280
    popupHeight: 200

    Column {
        anchors.fill: parent
        spacing: Config.Theme.spacingLarge

        // Header
        Text {
            text: "Audio"
            font.family: Config.Theme.fontFamily
            font.pixelSize: Config.Theme.fontSizeLarge
            font.bold: true
            color: Config.Theme.fg
        }

        // Volume control
        Column {
            width: parent.width
            spacing: Config.Theme.spacing

            Row {
                width: parent.width
                Components.BarIcon {
                    icon: Services.AudioService.getIcon()
                    color: Services.AudioService.getColor()
                    size: Config.Theme.iconSizeLarge
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: Services.AudioService.muted ? "Muted" : Services.AudioService.volume.toFixed(0) + "%"
                    font.family: Config.Theme.fontFamily
                    font.pixelSize: Config.Theme.fontSizeNormal
                    color: Config.Theme.fg
                }
            }

            Components.BarSlider {
                width: parent.width
                barWidth: parent.width
                value: Services.AudioService.volume
                maxValue: 100
                onValueChanged: function(newValue) {
                    Services.AudioService.setVolume(newValue)
                }
            }
        }

        // Mute toggle
        Components.BarToggle {
            checked: Services.AudioService.muted
            onToggled: function(checked) {
                Services.AudioService.toggleMute()
            }
        }
    }
}
