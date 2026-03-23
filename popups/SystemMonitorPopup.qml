pragma ComponentBehavior: Bound
import QtQuick
import "../config" as Config
import "../base" as Base
import "../components" as Components
import "../services" as Services

Base.BasePopup {
    id: root

    popupWidth: 320
    popupHeight: 300

    Column {
        anchors.fill: parent
        spacing: Config.Theme.spacingLarge

        // Header
        Text {
            text: "System Monitor"
            font.family: Config.Theme.fontFamily
            font.pixelSize: Config.Theme.fontSizeLarge
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
                    size: Config.Theme.iconSize
                }
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "CPU: " + Services.SystemService.cpuUsage.toFixed(1) + "%"
                    font.family: Config.Theme.fontFamily
                    font.pixelSize: Config.Theme.fontSizeNormal
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
                    size: Config.Theme.iconSize
                }
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "RAM: " + Services.SystemService.ramUsage.toFixed(1) + "% (" + Services.SystemService.formatBytes(Services.SystemService.ramUsed * 1024) + " / " + Services.SystemService.formatBytes(Services.SystemService.ramTotal * 1024) + ")"
                    font.family: Config.Theme.fontFamily
                    font.pixelSize: Config.Theme.fontSizeNormal
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
                size: Config.Theme.iconSize
            }
            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: "Temp: " + Services.SystemService.formatTemp(Services.SystemService.cpuTemp)
                font.family: Config.Theme.fontFamily
                font.pixelSize: Config.Theme.fontSizeNormal
                color: Config.Theme.fg
            }
        }
    }
}
