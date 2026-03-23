pragma ComponentBehavior: Bound
import QtQuick
import "../config" as Config
import "../base" as Base
import "../components" as Components
import "../services" as Services

Base.BasePopup {
    id: root

    popupWidth: 320
    popupHeight: 350

    Column {
        anchors.fill: parent
        spacing: Config.Theme.spacingLarge

        // Header
        Text {
            text: "Network"
            font.family: Config.Theme.fontFamily
            font.pixelSize: Config.Theme.fontSizeLarge
            font.bold: true
            color: Config.Theme.fg
        }

        // Network adapters list
        Column {
            width: parent.width
            spacing: Config.Theme.spacing

            Repeater {
                model: Services.NetworkService.adapters

                Rectangle {
                    width: parent.width
                    height: 50
                    radius: Config.Theme.borderRadius
                    color: Config.Theme.bgBright

                    Row {
                        anchors.fill: parent
                        anchors.margins: Config.Theme.padding
                        spacing: Config.Theme.spacing

                        Components.BarIcon {
                            icon: modelData.isWifi ? Services.NetworkService.getSignalIcon(Services.NetworkService.signalStrength) : Services.NetworkService.getEthernetIcon()
                            color: Config.Theme.cyan
                            size: Config.Theme.iconSizeLarge
                        }

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            Text {
                                text: modelData.connection || modelData.device
                                font.family: Config.Theme.fontFamily
                                font.pixelSize: Config.Theme.fontSizeNormal
                                color: Config.Theme.fg
                            }
                            Text {
                                text: modelData.type.toUpperCase()
                                font.family: Config.Theme.fontFamily
                                font.pixelSize: Config.Theme.fontSizeSmall
                                color: Config.Theme.fgDark
                            }
                        }
                    }
                }
            }
        }

        // Disconnected state
        Text {
            visible: !Services.NetworkService.connected
            text: "No active connections"
            font.family: Config.Theme.fontFamily
            font.pixelSize: Config.Theme.fontSizeNormal
            color: Config.Theme.fgMuted
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }
}
