pragma ComponentBehavior: Bound
import "../../base" as Base
import "../../components" as Components
import "../../config" as Config
import "../../services" as Services
import QtQuick

Base.BaseWidget {
    id: root

    tooltipText: {
        if (!Services.AudioService.available)
            return "Audio: Not available";

        return (Services.AudioService.muted ? "Muted" : Services.AudioService.volume.toFixed(0) + "%");
    }
    implicitWidth: audioRow.implicitWidth + (Config.Theme.widgetPadding * 2)

    popupComponent: Component {
        Base.BasePopup {
            popupWidth: 280
            popupHeight: 200

            contentComponent: Column {
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
    }

    onClicked: {
        Services.AudioService.toggleMute();
    }
    onScrollUp: {
        Services.AudioService.setVolume(Services.AudioService.volume + 5);
    }
    onScrollDown: {
        Services.AudioService.setVolume(Services.AudioService.volume - 5);
    }

    Row {
        id: audioRow

        anchors.centerIn: parent
        spacing: Config.Theme.spacing

        Components.BarIcon {
            anchors.verticalCenter: parent.verticalCenter
            icon: Services.AudioService.getIcon()
            color: Services.AudioService.getColor()
            size: Config.Theme.iconSize
        }

        Components.BarText {
            anchors.verticalCenter: parent.verticalCenter
            text: Services.AudioService.volume.toFixed(0) + "%"
            color: Config.Theme.fg
            fontSize: Config.Theme.fontSizeSmall
            visible: Services.AudioService.available && !Services.AudioService.muted
        }

    }

}
