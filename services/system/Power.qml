pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.UPower

Singleton {
    id: root

    // Direct binding to UPower - updates automatically when device becomes available
    readonly property var primaryDevice: UPower.devices.values.find(d => d.powerSupply === true) ?? null
    readonly property bool displayReady: root.primaryDevice ? root.primaryDevice.ready : false
    readonly property bool present: root.displayReady ? root.primaryDevice.isLaptopBattery === true : false
    readonly property int percent: {
        if (!present)
            return 0;
        return Math.round(root.primaryDevice.percentage * 100);
    }
    readonly property bool charging: {
        if (!present)
            return false;
        return root.primaryDevice.state === UPowerDeviceState.Charging;
    }
    readonly property int health: {
        if (!present || !root.primaryDevice.healthSupported)
            return 0;
        return root.primaryDevice.healthPercentage;
    }
    readonly property int timeToFull: {
        if (!present)
            return 0;
        return root.primaryDevice.timeToFull;
    }
    readonly property int timeToEmpty: {
        if (!present)
            return 0;
        return root.primaryDevice.timeToEmpty;
    }
    readonly property real changeRate: {
        if (!present)
            return 0;
        return Math.abs(root.primaryDevice.changeRate);
    }

    Process {
        id: powerProcess
    }

    function shutdown(): void {
        powerProcess.command = ["systemctl", "poweroff"];
        powerProcess.startDetached();
    }

    function reboot(): void {
        powerProcess.command = ["systemctl", "reboot"];
        powerProcess.startDetached();
    }

    function suspend(): void {
        powerProcess.command = ["systemctl", "suspend"];
        powerProcess.startDetached();
    }

    function logout(): void {
        // Stub - requires compositor/hyprctl call
    }
}
