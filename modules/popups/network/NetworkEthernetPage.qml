pragma ComponentBehavior: Bound

import QtQuick
import "../../../config"
import "../../../services/system"
import "."

NetworkMenuPage {
    id: page

    Repeater {
        model: Network.wiredDevices
        delegate: NetworkMenuRow {
            required property var modelData

            iconSource: modelData.connected ? "icons/outline/plug-connected.svg" : "icons/outline/plug.svg"
            label: modelData.name
            trailingIcon: modelData.connected ? "icons/outline/check.svg" : ""
            trailingColor: Theme.accentColor
            enabled: !Network.busy
            onClicked: {
                if (modelData.connected)
                    Network.disconnectDevice(modelData)
                else
                    Network.connectEthernet(modelData)
            }
        }
    }

    // Empty state — no wired devices present.
    Text {
        width: parent.width
        horizontalAlignment: Text.AlignHCenter
        text: "No Ethernet devices"
        color: Theme.mutedColor
        font.pixelSize: Theme.fontSizeSmall
        font.family: Theme.fontFamily
        topPadding: Theme.paddingSmall
        bottomPadding: Theme.paddingSmall
        visible: !Network.wiredDevices || Network.wiredDevices.length === 0
    }
}
