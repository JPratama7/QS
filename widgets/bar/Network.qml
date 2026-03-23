pragma ComponentBehavior: Bound
import "../../base" as Base
import "../../components" as Components
import "../../config" as Config
import "../../services" as Services
import QtQuick

Base.BaseWidget {
    id: root

    tooltipText: {
        if (!Services.NetworkService.connected)
            return "Disconnected";

        if (Services.NetworkService.isWifi)
            return Services.NetworkService.ssid + " (" + Services.NetworkService.signalStrength + "%)";

        return Services.NetworkService.interfaceName;
    }
    hasPopup: true
    implicitWidth: networkRow.implicitWidth + (Config.Theme.widgetPadding * 2)

    popupComponent: Component {
        Base.BasePopup {
            popupWidth: 320
            popupHeight: 350

            contentComponent: Column {
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
    }

    Row {
        id: networkRow

        anchors.centerIn: parent
        spacing: Config.Theme.spacing

        Components.BarIcon {
            id: networkIcon

            anchors.verticalCenter: parent.verticalCenter
            icon: {
                if (!Services.NetworkService.connected)
                    return Services.NetworkService.getDisconnectedIcon();

                if (Services.NetworkService.isWifi)
                    return Services.NetworkService.getSignalIcon(Services.NetworkService.signalStrength);

                return Services.NetworkService.getEthernetIcon();
            }
            color: Services.NetworkService.connected ? Config.Theme.cyan : Config.Theme.fgMuted
            size: Config.Theme.iconSize
        }

        Components.BarText {
            anchors.verticalCenter: parent.verticalCenter
            text: Services.NetworkService.ssid || Services.NetworkService.interfaceName
            color: Config.Theme.fg
            fontSize: Config.Theme.fontSizeSmall
            visible: Services.NetworkService.connected && text !== ""
        }

    }

}
