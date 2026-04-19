pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Services.UPower

Singleton {
    id: root

    // Direct binding to UPower - updates automatically when device becomes available
    readonly property bool present: UPower.displayDevice?.isLaptopBattery ?? false
    readonly property int percent: present ? Math.round(UPower.displayDevice.percentage * 100) : 0
    readonly property bool charging: present ? UPower.displayDevice.state === UPowerDeviceState.Charging : false

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
