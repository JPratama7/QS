pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Services.UPower

Singleton {
    id: root

    property var displayDevice: null

    // Internal state properties
    property bool _present: false
    property int _percent: 0
    property bool _charging: false

    readonly property bool present: _present
    readonly property int percent: _percent
    readonly property bool charging: _charging

    Component.onCompleted: {
        root.resolveDevice();
    }

    Connections {
        target: root.displayDevice
        function onReadyChanged() {
            root.resolveDevice();
        }
        function onIsPresentChanged() {
            root.updatePowerState();
        }
        function onPercentageChanged() {
            root.updatePowerState();
        }
        function onStateChanged() {
            root.updatePowerState();
        }
    }

    // Resolve the display device from UPower
    function resolveDevice(): void {
        const dev = UPower.displayDevice;
        if (dev && dev.isLaptopBattery) {
            root.displayDevice = dev;
        } else {
            root.displayDevice = null;
        }
        root.updatePowerState();
    }

    // Update present/percent/charging from the resolved device
    function updatePowerState(): void {
        if (!root.displayDevice || !root.displayDevice.isPresent) {
            root._present = false;
            root._percent = 0;
            root._charging = false;
            return;
        }

        root._present = true;
        root._percent = Math.round(root.displayDevice.percentage * 100);
        root._charging = root.displayDevice.state === UPowerDeviceState.Charging;
    }

    function shutdown(): void {
        // Stub - requires logind D-Bus call
    }

    function reboot(): void {
        // Stub - requires logind D-Bus call
    }

    function suspend(): void {
        // Stub - requires logind D-Bus call
    }

    function logout(): void {
        // Stub - requires compositor/hyprctl call
    }
}
