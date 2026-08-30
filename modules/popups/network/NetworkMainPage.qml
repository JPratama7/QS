pragma ComponentBehavior: Bound

import QtQuick
import "../../../services/system"
import "."

NetworkMenuPage {
    id: page

    // NM-down state: show an error row instead of a dead list.
    NetworkMenuRow {
        iconSource: "icons/outline/wifi-off.svg"
        label: "NetworkManager is not running"
        enabled: false
        visible: !Network.nmAvailable
    }

    NetworkMenuRow {
        iconSource: Network.wifiEnabled ? "icons/outline/wifi.svg" : "icons/outline/wifi-off.svg"
        label: Network.wifiEnabled ? "Disable Wi-Fi" : "Enable Wi-Fi"
        visible: Network.nmAvailable
        onClicked: Network.toggleWifi()
    }

    NetworkMenuRow {
        iconSource: "icons/outline/wifi.svg"
        label: "Manage Wi-Fi"
        showChevron: true
        visible: Network.nmAvailable
        onClicked: page.stackView.push(Qt.resolvedUrl("NetworkWifiPage.qml"), {
            screenName: page.screenName,
            stackView: page.stackView,
            width: page.width
        })
    }

    NetworkMenuRow {
        iconSource: "icons/outline/plug.svg"
        label: "Manage Ethernet"
        showChevron: true
        visible: Network.nmAvailable
        onClicked: page.stackView.push(Qt.resolvedUrl("NetworkEthernetPage.qml"), {
            screenName: page.screenName,
            stackView: page.stackView,
            width: page.width
        })
    }
}
