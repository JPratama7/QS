import "../../base" as Base
import "../../components" as Components
import "../../config" as Config
import "../../services" as Services
import QtQuick

Base.BaseWidget {
    id: root

    tooltipText: {
        if (!Services.AudioService.available)
            return "Audio: Not available";

        return (Services.AudioService.muted ? "Muted" : Services.AudioService.volume.toFixed(0) + "%");
    }
    hasPopup: true
    implicitWidth: audioRow.implicitWidth + (Config.Theme.widgetPadding * 2)
    onClicked: {
        Services.AudioService.toggleMute();
    }
    onScrollUp: {
        Services.AudioService.setVolume(Services.AudioService.volume + 5);
    }
    onScrollDown: {
        Services.AudioService.setVolume(Services.AudioService.volume - 5);
    }

    Row {
        id: audioRow

        anchors.centerIn: parent
        spacing: Config.Theme.spacing

        Components.BarIcon {
            anchors.verticalCenter: parent.verticalCenter
            icon: Services.AudioService.getIcon()
            color: Services.AudioService.getColor()
            size: Config.Theme.iconSize
        }

        Components.BarText {
            anchors.verticalCenter: parent.verticalCenter
            text: Services.AudioService.volume.toFixed(0) + "%"
            color: Config.Theme.fg
            fontSize: Config.Theme.fontSizeSmall
            visible: Services.AudioService.available && !Services.AudioService.muted
        }

    }

}
