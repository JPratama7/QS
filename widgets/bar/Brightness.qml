pragma ComponentBehavior: Bound
import "../../base" as Base
import "../../components" as Components
import "../../config" as Config
import "../../services" as Services
import QtQuick

Base.BaseWidget {
    id: root

    tooltipText: {
        if (!Services.BrightnessService.available)
            return "Brightness: Not available";

        return Services.BrightnessService.brightness.toFixed(0) + "%";
    }
    hasPopup: false
    implicitWidth: brightnessRow.implicitWidth + (Config.Theme.widgetPadding * 2)
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
            size: Config.Theme.iconSize
        }

        Components.BarText {
            anchors.verticalCenter: parent.verticalCenter
            text: Services.BrightnessService.brightness.toFixed(0) + "%"
            color: Config.Theme.fg
            fontSize: Config.Theme.fontSizeSmall
            visible: Services.BrightnessService.available
        }

    }

}
