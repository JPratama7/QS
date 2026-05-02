pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.UPower

Singleton {
    id: root

    // Direct binding to UPower - updates automatically when device becomes available
    readonly property bool displayReady: UPower.displayDevice.ready
    readonly property bool present: UPower.displayDevice.isLaptopBattery ?? false
    readonly property int percent: {
        if (!present)
            return 0;
        return Math.round(UPower.displayDevice.percentage * 100);
    }
    readonly property bool charging: {
        if (!present)
            return false;
        return UPower.displayDevice.state === UPowerDeviceState.Charging;
    }
    readonly property int health: {
        if (!present || !UPower.displayDevice.healthSupported)
            return 0;
        return Math.round(UPower.displayDevice.healthPercentage * 100);
    }
    readonly property int timeToFull: {
        if (!present)
            return 0;
        return UPower.displayDevice.timeToFull;
    }
    readonly property int timeToEmpty: {
        if (!present)
            return 0;
        return UPower.displayDevice.timeToEmpty;
    }
    readonly property real chargeRate: {
        if (!present || !charging)
            return 0;
        return Math.abs(UPower.displayDevice.changeRate);
    }
    readonly property real dischargeRate: {
        if (!present || charging)
            return 0;
        return Math.abs(UPower.displayDevice.changeRate);
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
