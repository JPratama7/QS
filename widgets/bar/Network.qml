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
