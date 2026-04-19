pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Networking

Singleton {
    id: root

    property var device: null

    // Internal state properties
    property bool _connected: false
    property string _ssid: ""

    readonly property bool connected: _connected
    readonly property string ssid: _ssid
    readonly property bool wifiEnabled: Networking.wifiEnabled
    readonly property bool wifiHardwareEnabled: Networking.wifiHardwareEnabled

    Component.onCompleted: {
        root.resolveDevice();
    }

    Connections {
        target: Networking.devices
        function onValuesChanged() {
            root.resolveDevice();
        }
    }

    Connections {
        target: root.device
        function onConnectedChanged() {
            root.updateNetworkState();
        }
    }

    // Resolve the best available connected device: prefer wifi, fallback to any connected
    function resolveDevice(): void {
        const devs = Networking.devices;
        if (!devs) {
            return;
        }

        let wifiDevice = null;
        let anyDevice = null;

        for (const dev of devs.values) {
            if (dev.connected) {
                if (!anyDevice)
                    anyDevice = dev;
                if (dev.type === DeviceType.Wifi && !wifiDevice) {
                    wifiDevice = dev;
                }
            }
        }

        root.device = wifiDevice || anyDevice;
        root.updateNetworkState();
    }

    // Update connected/ssid from the resolved device
    function updateNetworkState(): void {
        if (!root.device || !root.device.connected) {
            root._connected = false;
            root._ssid = "";
            return;
        }

        root._connected = true;

        if (root.device.type === DeviceType.Wifi) {
            const networks = root.device.networks;
            for (let i = 0; i < networks.count; i++) {
                const net = networks.get(i);
                if (net.connected) {
                    root._ssid = net.name;
                    return;
                }
            }
        }

        root._ssid = root.device.name || "";
    }

    function toggleWifi(): void {
        Networking.wifiEnabled = !Networking.wifiEnabled;
    }
}
