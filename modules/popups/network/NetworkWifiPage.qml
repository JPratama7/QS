pragma ComponentBehavior: Bound

import QtQuick
import Quickshell.Networking
import "../../../config"
import "../../../services/system"
import "."

NetworkMenuPage {
    id: page

    // Scanner lives only while the wifi page is on screen.
    Component.onCompleted: Network.startScan()
    Component.onDestruction: Network.stopScan()

    NetworkMenuRow {
        iconSource: "icons/outline/refresh.svg"
        label: Network.scanning ? "Scanning\u2026" : "Rescan"
        enabled: !Network.scanning
        onClicked: Network.startScan()
    }

    // Loading state — scanning with no results yet.
    Text {
        width: parent.width
        horizontalAlignment: Text.AlignHCenter
        text: "Scanning\u2026"
        color: Theme.mutedColor
        font.pixelSize: Theme.fontSizeSmall
        font.family: Theme.fontFamily
        topPadding: Theme.paddingSmall
        bottomPadding: Theme.paddingSmall
        visible: Network.scanning && (!Network.networks || Network.networks.count === 0)
    }

    // Empty state — scan finished with no results.
    Text {
        width: parent.width
        horizontalAlignment: Text.AlignHCenter
        text: "No networks found"
        color: Theme.mutedColor
        font.pixelSize: Theme.fontSizeSmall
        font.family: Theme.fontFamily
        topPadding: Theme.paddingSmall
        bottomPadding: Theme.paddingSmall
        visible: !Network.scanning && (!Network.networks || Network.networks.count === 0)
    }

    Repeater {
        model: Network.networks
        delegate: NetworkMenuRow {
            required property var modelData

            iconSource: {
                const level = Math.max(0, Math.min(3, Math.floor(modelData.signalStrength * 4)))
                return level === 3 ? "icons/outline/wifi.svg" : "icons/outline/wifi-" + level + ".svg"
            }
            label: modelData.name
            trailingIcon: modelData.connected
                ? "icons/outline/check.svg"
                : (modelData.security !== WifiSecurityType.Open ? "icons/outline/lock.svg" : "")
            trailingColor: modelData.connected ? Theme.accentColor : Theme.mutedColor
            onClicked: page.stackView.push(Qt.resolvedUrl("NetworkActionPage.qml"), {
                network: modelData,
                screenName: page.screenName,
                stackView: page.stackView,
                width: page.width
            })
        }
    }
}
