pragma ComponentBehavior: Bound

import QtQuick
import "../../../config"
import "../../../components/bar"
import "../../../services/system"

BaseWidget {
    id: widget

    property Component widgetTooltip: Component {
        Text {
            text: "CPU: " + Math.round(SystemMonitor.cpuUsage * 100) + "%\n"
                + "RAM: " + (SystemMonitor.useGB
                    ? SystemMonitor.ramUsedGB + "/" + SystemMonitor.ramTotalGB + " GB"
                    : SystemMonitor.ramUsedMB + "/" + SystemMonitor.ramTotalMB + " MB") + "\n"
                + "Temp: " + SystemMonitor.temperature + "°C"
            font.pixelSize: Theme.fontSizeSmall
            color: Theme.foregroundColor
        }
    }

    tooltipComponent: widgetTooltip

    implicitWidth: row.implicitWidth
    implicitHeight: row.implicitHeight

    Row {
        id: row
        spacing: Theme.spacingNormal

        // CPU
        Text {
            text: "CPU " + Math.round(SystemMonitor.cpuUsage * 100) + "%"
            color: SystemMonitor.cpuUsage > 0.8 ? "#ef4444" : Theme.foregroundColor
            font.pixelSize: Theme.fontSizeSmall
            font.family: Theme.fontFamily
        }

        // RAM
        Text {
            text: "RAM " + Math.round(SystemMonitor.ramUsage * 100) + "%"
            color: SystemMonitor.ramUsage > 0.9 ? "#ef4444" : Theme.foregroundColor
            font.pixelSize: Theme.fontSizeSmall
            font.family: Theme.fontFamily
        }

        // Temperature
        Text {
            visible: SystemMonitor.temperature > 0
            text: SystemMonitor.temperature + "°C"
            color: SystemMonitor.temperature > 80 ? "#ef4444" : Theme.foregroundColor
            font.pixelSize: Theme.fontSizeSmall
            font.family: Theme.fontFamily
        }
    }
}
