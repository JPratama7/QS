pragma ComponentBehavior: Bound
import "../../types/widgets/bar" as BarTypes
import "../../base" as Base
import "../../components" as Components
import "../../config" as Config
import "../../services" as Services
import QtQuick

Base.BaseWidget {
    id: root
    objectName: "SystemMonitor"

    required property BarTypes.Sizes sizes

    property bool showGraph: false
    property bool showTemp: true
    property bool showPercent: true

    tooltipText: "CPU: " + Services.SystemService.cpuUsage.toFixed(0) + "% | RAM: " + Services.SystemService.ramUsage.toFixed(0) + "% | Temp: " + Services.SystemService.formatTemp(Services.SystemService.cpuTemp)
    implicitWidth: monitorRow.implicitWidth + (Config.Theme.widgetPadding * 2)

    popupComponent: Component {
        Base.BasePopup {
            popupWidth: 320
            popupHeight: 300

            contentComponent: Column {
                spacing: Config.Theme.spacingLarge

                // Header
                Text {
                    text: "System Monitor"
                    font.family: Config.Theme.fontFamily
                    font.pixelSize: root.sizes.textLarge
                    font.bold: true
                    color: Config.Theme.fg
                }

                // CPU Section
                Column {
                    width: parent.width
                    spacing: Config.Theme.spacing

                    Row {
                        width: parent.width
                        Components.BarIcon {
                            icon: "󰻠"
                            color: Config.Theme.graphCpu
                            size: root.sizes.icon
                        }
                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: "CPU: " + Services.SystemService.cpuUsage.toFixed(1) + "%"
                            font.family: Config.Theme.fontFamily
                            font.pixelSize: root.sizes.text
                            color: Config.Theme.fg
                        }
                    }

                    Components.BarGraph {
                        width: parent.width
                        graphWidth: parent.width
                        graphHeight: 40
                        color: Config.Theme.graphCpu
                        values: Services.SystemService.cpuHistory
                    }
                }

                // RAM Section
                Column {
                    width: parent.width
                    spacing: Config.Theme.spacing

                    Row {
                        width: parent.width
                        Components.BarIcon {
                            icon: "󰍛"
                            color: Config.Theme.graphRam
                            size: root.sizes.icon
                        }
                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: "RAM: " + Services.SystemService.ramUsage.toFixed(1) + "% (" + Services.SystemService.formatBytes(Services.SystemService.ramUsed * 1024) + " / " + Services.SystemService.formatBytes(Services.SystemService.ramTotal * 1024) + ")"
                            font.family: Config.Theme.fontFamily
                            font.pixelSize: root.sizes.text
                            color: Config.Theme.fg
                        }
                    }

                    Components.BarGraph {
                        width: parent.width
                        graphWidth: parent.width
                        graphHeight: 40
                        color: Config.Theme.graphRam
                        values: Services.SystemService.ramHistory
                    }
                }

                // Temperature Section
                Row {
                    width: parent.width
                    Components.BarIcon {
                        icon: "󰔏"
                        color: Services.SystemService.cpuTemp > 70 ? Config.Theme.error : Config.Theme.graphTemp
                        size: root.sizes.icon
                    }
                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: "Temp: " + Services.SystemService.formatTemp(Services.SystemService.cpuTemp)
                        font.family: Config.Theme.fontFamily
                        font.pixelSize: root.sizes.text
                        color: Config.Theme.fg
                    }
                }
            }
        }
    }

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
                size: root.sizes.icon
            }

            Components.BarText {
                anchors.verticalCenter: parent.verticalCenter
                text: Services.SystemService.cpuUsage.toFixed(1) + "%"
                color: Config.Theme.warning
                fontSize: root.sizes.textSmall
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
                size: root.sizes.icon
            }

            Components.BarText {
                anchors.verticalCenter: parent.verticalCenter
                text: Services.SystemService.formatTemp(Services.SystemService.cpuTemp)
                color: Config.Theme.warning
                fontSize: root.sizes.textSmall
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
                size: root.sizes.icon
            }

            Components.BarText {
                anchors.verticalCenter: parent.verticalCenter
                text: (Services.SystemService.ramUsage / 100 * 16).toFixed(1) + "G"
                color: Config.Theme.warning
                fontSize: root.sizes.textSmall
                visible: root.showPercent
            }

        }

    }

}
