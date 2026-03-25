pragma ComponentBehavior: Bound

import "../../types/widgets/bar" as BarTypes
import "../../base" as Base
import "../../components" as Components
import "../../config" as Config
import "../../services" as Services
import QtQuick

Base.BaseWidget {
    id: root
    objectName: "Battery"

    required property BarTypes.Sizes sizes

    tooltipText: {
        if (!Services.BatteryService.available)
            return "No battery";

        return Services.BatteryService.percentage + "% - " + Services.BatteryService.status;
    }
    implicitWidth: batteryRow.implicitWidth + (Config.Theme.widgetPadding * 2)

    Row {
        id: batteryRow

        anchors.centerIn: parent
        spacing: Config.Theme.spacing

        Components.BarIcon {
            anchors.verticalCenter: parent.verticalCenter
            icon: Services.BatteryService.getIcon()
            color: Services.BatteryService.getColor()
            size: root.sizes.icon
        }

        Components.BarText {
            anchors.verticalCenter: parent.verticalCenter
            text: Services.BatteryService.percentage + "%"
            color: Config.Theme.fg
            fontSize: root.sizes.textSmall
            visible: Services.BatteryService.available
        }

    }

}
