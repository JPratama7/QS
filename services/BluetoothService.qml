pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import "../config" as Config

Singleton {
    id: root

    // Bluetooth state
    property bool enabled: false
    property bool connected: false
    property var devices: [] // Array of connected devices
    property var adapters: [] // Array of available adapters

    // Update interval
    property int updateInterval: 5000

    Timer {
        id: updateTimer
        interval: root.updateInterval
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            bluetoothReader.running = true
        }
    }

    Process {
        id: bluetoothReader
        running: false
        command: ["sh", "-c", "bluetoothctl list 2>/dev/null && bluetoothctl devices Connected 2>/dev/null || echo ''"]

        property var adapterList: []
        property var deviceList: []

        stdout: SplitParser {
            onRead: function(data) {
                const line = data.trim()
                if (line.startsWith("Controller ")) {
                    // Controller XX:XX:XX:XX:XX:XX [name] (powered/ready/etc)
                    const parts = line.split(/\s+/)
                    if (parts.length >= 3) {
                        bluetoothReader.adapterList.push({
                            address: parts[1],
                            name: parts[2],
                            powered: line.includes("powered")
                        })
                    }
                } else if (line.startsWith("Device ")) {
                    // Device XX:XX:XX:XX:XX:XX DeviceName
                    const parts = line.split(/\s+/)
                    if (parts.length >= 3) {
                        bluetoothReader.deviceList.push({
                            address: parts[1],
                            name: parts.slice(2).join(" ")
                        })
                    }
                }
            }
        }

        onExited: function(exitCode, exitStatus) {
            root.adapters = bluetoothReader.adapterList.slice()
            root.devices = bluetoothReader.deviceList.slice()
            root.enabled = bluetoothReader.adapterList.length > 0
                && bluetoothReader.adapterList.some(a => a.powered)
            root.connected = bluetoothReader.deviceList.length > 0
            bluetoothReader.adapterList = []
            bluetoothReader.deviceList = []
        }
    }

    function getIcon(): string {
        if (!enabled) return "󰂲" // Bluetooth off
        if (connected) return "󰂱" // Bluetooth connected
        return "󰂯" // Bluetooth on
    }

    function toggleBluetooth(): void {
        bluetoothToggle.running = true
    }

    Process {
        id: bluetoothToggle
        running: false
        command: ["sh", "-c", "bluetoothctl power toggle"]
    }
}
