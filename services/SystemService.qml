pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import "../config" as Config

Singleton {
    id: root

    // CPU
    property real cpuUsage: 0
    property var cpuHistory: []
    property int cpuHistoryMax: 30

    // RAM
    property real ramUsage: 0
    property real ramTotal: 0
    property real ramUsed: 0
    property var ramHistory: []
    property int ramHistoryMax: 30

    // Temperature
    property real cpuTemp: 0
    property var tempHistory: []
    property int tempHistoryMax: 30

    // Update interval (ms)
    property int updateInterval: 2000

    // CPU stats tracking
    property var lastCpuStats: null

    // Timer for periodic updates
    Timer {
        id: updateTimer
        interval: root.updateInterval
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            cpuReader.running = true
            ramReader.running = true
            tempReader.running = true
        }
    }

    // CPU Process
    Process {
        id: cpuReader
        running: false
        command: ["cat", "/proc/stat"]

        stdout: SplitParser {
            onRead: function(data) {
                if (data.startsWith("cpu ")) {
                    const parts = data.split(/\s+/)
                    const user = parseInt(parts[1])
                    const nice = parseInt(parts[2])
                    const system = parseInt(parts[3])
                    const idle = parseInt(parts[4])
                    const iowait = parseInt(parts[5])
                    const irq = parseInt(parts[6])
                    const softirq = parseInt(parts[7])

                    const total = user + nice + system + idle + iowait + irq + softirq
                    const active = user + nice + system + irq + softirq

                    if (root.lastCpuStats !== null) {
                        const totalDiff = total - root.lastCpuStats.total
                        const activeDiff = active - root.lastCpuStats.active

                        if (totalDiff > 0) {
                            root.cpuUsage = (activeDiff / totalDiff) * 100
                            root.addHistory("cpuHistory", root.cpuUsage)
                        }
                    }

                    root.lastCpuStats = { total: total, active: active }
                }
            }
        }
    }

    // RAM Process
    Process {
        id: ramReader
        running: false
        command: ["cat", "/proc/meminfo"]
        onExited: function(exitStatus, exitSignal) {

        }

        stdout: SplitParser {
            property int memTotal: 0
            property int memAvailable: 0

            onRead: function(data) {
                if (data.startsWith("MemTotal:")) {
                    memTotal = parseInt(data.split(/\s+/)[1])
                } else if (data.startsWith("MemAvailable:")) {
                    memAvailable = parseInt(data.split(/\s+/)[1])
                }

                root.ramTotal = memTotal
                root.ramUsed = memTotal - memAvailable
                root.ramUsage = (root.ramUsed / memTotal) * 100
                root.addHistory("ramHistory", root.ramUsage)
            }
        }
    }

    // Temperature Process
    Process {
        id: tempReader
        running: false
        command: ["sh", "-c", "cat /sys/class/hwmon/hwmon0/temp1_input 2>/dev/null || cat /sys/class/thermal/thermal_zone0/temp 2>/dev/null || echo 0"]

        stdout: SplitParser {
            onRead: function(data) {
                const temp = parseInt(data.trim())
                if (temp > 0) {
                    root.cpuTemp = temp / 1000
                    root.addHistory("tempHistory", root.cpuTemp)
                }
            }
        }
    }

    function addHistory(historyName: string, value: real): void {
        const history = root[historyName]
        history.push(value)
        if (history.length > root[historyName + "Max"]) {
            history.shift()
        }
        root[historyName] = history.slice()
    }

    function formatBytes(bytes: int): string {
        const units = ["B", "KB", "MB", "GB", "TB"]
        let unitIndex = 0
        let value = bytes

        while (value >= 1024 && unitIndex < units.length - 1) {
            value /= 1024
            unitIndex++
        }

        return value.toFixed(1) + " " + units[unitIndex]
    }

    function formatTemp(temp: real): string {
        return temp.toFixed(0) + "°C"
    }
}
