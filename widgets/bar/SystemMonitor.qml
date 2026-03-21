import "../../base" as Base
import "../../components" as Components
import "../../config" as Config
import "../../services" as Services
import QtQuick

Base.BaseWidget {
    id: root

    property bool showGraph: false
    property bool showTemp: true
    property bool showPercent: true

    tooltipText: "CPU: " + Services.SystemService.cpuUsage.toFixed(0) + "% | RAM: " + Services.SystemService.ramUsage.toFixed(0) + "% | Temp: " + Services.SystemService.formatTemp(Services.SystemService.cpuTemp)
    hasPopup: true
    implicitWidth: monitorRow.implicitWidth + (Config.Theme.widgetPadding * 2)

    Row {
        id: monitorRow

        anchors.centerIn: parent
        spacing: Config.Theme.spacingLarge

        // CPU
        Row {
            spacing: Config.Theme.spacing
            anchors.verticalCenter: parent.verticalCenter

            Components.BarIcon {
                anchors.verticalCenter: parent.verticalCenter
                icon: "󰓅" // CPU icon
                color: Config.Theme.warning
                size: Config.Theme.iconSize
            }

            Components.BarText {
                anchors.verticalCenter: parent.verticalCenter
                text: Services.SystemService.cpuUsage.toFixed(1) + "%"
                color: Config.Theme.warning
                fontSize: Config.Theme.fontSizeSmall
                visible: root.showPercent
            }

        }

        // Temperature
        Row {
            spacing: Config.Theme.spacing
            anchors.verticalCenter: parent.verticalCenter
            visible: root.showTemp && Services.SystemService.cpuTemp > 0

            Components.BarIcon {
                anchors.verticalCenter: parent.verticalCenter
                icon: "󰔏" // Temp icon
                color: Config.Theme.warning
                size: Config.Theme.iconSize
            }

            Components.BarText {
                anchors.verticalCenter: parent.verticalCenter
                text: Services.SystemService.formatTemp(Services.SystemService.cpuTemp)
                color: Config.Theme.warning
                fontSize: Config.Theme.fontSizeSmall
            }

        }

        // RAM
        Row {
            spacing: Config.Theme.spacing
            anchors.verticalCenter: parent.verticalCenter

            Components.BarIcon {
                anchors.verticalCenter: parent.verticalCenter
                icon: "󰍛" // RAM icon
                color: Config.Theme.warning
                size: Config.Theme.iconSize
            }

            Components.BarText {
                anchors.verticalCenter: parent.verticalCenter
                text: (Services.SystemService.ramUsage / 100 * 16).toFixed(1) + "G"
                color: Config.Theme.warning
                fontSize: Config.Theme.fontSizeSmall
                visible: root.showPercent
            }

        }

    }

}
