pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import "../config" as Config

Singleton {
    id: root

    // Battery state
    property bool available: false
    property bool charging: false
    property int percentage: 0
    property int capacity: 100
    property string status: "Unknown"
    property string timeRemaining: ""

    // Multiple batteries
    property var batteries: [] // Array of battery objects

    // Update interval
    property int updateInterval: 5000

    Timer {
        id: updateTimer
        interval: root.updateInterval
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            batteryReader.running = true
        }
    }

    Process {
        id: batteryReader
        running: false
        command: ["sh", "-c", "ls /sys/class/power_supply/ | grep -E '^BAT' | while read bat; do echo \"$bat:$(cat /sys/class/power_supply/$bat/capacity 2>/dev/null || echo 0):$(cat /sys/class/power_supply/$bat/status 2>/dev/null || echo Unknown)\"; done || echo ''"]

        property var batteryList: []

        stdout: SplitParser {
            onRead: function(data) {
                const line = data.trim()
                if (line.includes(":")) {
                    const parts = line.split(":")
                    if (parts.length >= 3) {
                        batteryReader.batteryList.push({
                            name: parts[0],
                            percentage: parseInt(parts[1]) || 0,
                            status: parts[2].trim()
                        })
                    }
                }
            }
        }

        onExited: function(exitCode, exitStatus) {
            root.batteries = batteryReader.batteryList.slice()
            root.available = batteryReader.batteryList.length > 0

            if (batteryReader.batteryList.length > 0) {
                // Use first battery for main display
                const main = batteryReader.batteryList[0]
                root.percentage = main.percentage
                root.status = main.status
                root.charging = main.status === "Charging" || main.status === "Full"

                // Calculate average if multiple batteries
                if (batteryReader.batteryList.length > 1) {
                    const total = batteryReader.batteryList.reduce((sum, b) => sum + b.percentage, 0)
                    root.percentage = Math.round(total / batteryReader.batteryList.length)
                }
            }

            batteryReader.batteryList = []
        }
    }

    function getIcon(): string {
        if (!available) return "󰚯" // No battery
        if (charging) {
            if (percentage >= 90) return "󰂅" // Charging full
            if (percentage >= 70) return "󰂋" // Charging 80
            if (percentage >= 50) return "󰂊" // Charging 60
            if (percentage >= 30) return "󰂉" // Charging 40
            if (percentage >= 10) return "󰂈" // Charging 20
            return "󰂇" // Charging low
        }
        if (percentage >= 90) return "󰁹" // Full
        if (percentage >= 70) return "󰂀" // 80
        if (percentage >= 50) return "󰁾" // 60
        if (percentage >= 30) return "󰁼" // 40
        if (percentage >= 10) return "󰁺" // 20
        return "󰂃" // Critical
    }

    function getColor(): color {
        return Config.Theme.getBatteryColor(percentage, charging)
    }
}
