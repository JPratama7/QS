import QtQuick
import "../config" as Config
import "../base" as Base
import "../components" as Components
import "../services" as Services

Base.BaseWidget {
    id: root

    tooltipText: {
        if (!Services.BluetoothService.enabled) return "Bluetooth: Off"
        if (Services.BluetoothService.connected) {
            const names = Services.BluetoothService.devices.map(d => d.name).join(", ")
            return "Connected: " + names
        }
        return "Bluetooth: On (No devices)"
    }

    hasPopup: true
    implicitWidth: bluetoothRow.implicitWidth + (Config.Theme.widgetPadding * 2)

    Row {
        id: bluetoothRow
        anchors.centerIn: parent
        spacing: Config.Theme.spacing

        Components.BarIcon {
            anchors.verticalCenter: parent.verticalCenter
            icon: Services.BluetoothService.getIcon()
            color: {
                if (!Services.BluetoothService.enabled) return Config.Theme.fgMuted
                if (Services.BluetoothService.connected) return Config.Theme.info
                return Config.Theme.fg
            }
            size: Config.Theme.iconSize
        }

        Components.BarText {
            anchors.verticalCenter: parent.verticalCenter
            text: Services.BluetoothService.devices.length.toString()
            color: Config.Theme.fg
            fontSize: Config.Theme.fontSizeSmall
            visible: Services.BluetoothService.connected
        }
    }

    onClicked: {
        Services.BluetoothService.toggleBluetooth()
    }
}
