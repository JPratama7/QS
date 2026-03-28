pragma ComponentBehavior: Bound

import "../../types/widgets/bar" as BarTypes
import "../../base" as Base
import "../../components" as Components
import "../../config" as Config
import "../../services" as Services
import QtQuick

Base.BaseWidget {
    id: root
    objectName: "Brightness"

    required property BarTypes.Sizes sizes

    tooltipText: {
        if (!Services.BrightnessService.available)
            return "Brightness: Not available";

        return Services.BrightnessService.brightness.toFixed(0) + "%";
    }
    Binding on implicitWidth { value: brightnessRow.implicitWidth + (Config.Theme.widgetPadding * 2) }
    onScrollUp: {
        Services.BrightnessService.setBrightness(Services.BrightnessService.brightness + 5);
    }
    onScrollDown: {
        Services.BrightnessService.setBrightness(Services.BrightnessService.brightness - 5);
    }

    Row {
        id: brightnessRow

        anchors.centerIn: parent
        spacing: Config.Theme.spacing

        Components.BarIcon {
            anchors.verticalCenter: parent.verticalCenter
            icon: Services.BrightnessService.getIcon()
            color: Services.BrightnessService.getColor()
            size: root.sizes.icon
        }

        Components.BarText {
            anchors.verticalCenter: parent.verticalCenter
            text: Services.BrightnessService.brightness.toFixed(0) + "%"
            color: Config.Theme.fg
            fontSize: root.sizes.textSmall
            visible: Services.BrightnessService.available
        }

    }

}
