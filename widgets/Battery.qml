import QtQuick
import "../config" as Config
import "../base" as Base
import "../components" as Components
import "../services" as Services

Base.BaseWidget {
    id: root

    tooltipText: {
        if (!Services.BatteryService.available) return "No battery"
        return Services.BatteryService.percentage + "% - " + Services.BatteryService.status
    }

    hasPopup: true
    implicitWidth: batteryRow.implicitWidth + (Config.Theme.widgetPadding * 2)

    Row {
        id: batteryRow
        anchors.centerIn: parent
        spacing: Config.Theme.spacing

        Components.BarIcon {
            anchors.verticalCenter: parent.verticalCenter
            icon: Services.BatteryService.getIcon()
            color: Services.BatteryService.getColor()
            size: Config.Theme.iconSize
        }

        Components.BarText {
            anchors.verticalCenter: parent.verticalCenter
            text: Services.BatteryService.percentage + "%"
            color: Config.Theme.fg
            fontSize: Config.Theme.fontSizeSmall
            visible: Services.BatteryService.available
        }
    }
}
