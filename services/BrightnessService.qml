pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import "../config" as Config

Singleton {
    id: root

    // Brightness state
    property bool available: false
    property real brightness: 0
    property real maxBrightness: 100
    property string device: ""

    // Update interval
    property int updateInterval: 2000

    Timer {
        id: updateTimer
        interval: root.updateInterval
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            brightnessReader.running = true
        }
    }

    Process {
        id: brightnessReader
        running: false
        command: ["sh", "-c", "ls /sys/class/backlight/ | head -1"]

        stdout: SplitParser {
            onRead: function(data) {
                const dev = data.trim()
                if (dev) {
                    root.device = dev
                    brightnessValueReader.running = true
                }
            }
        }
    }

    Process {
        id: brightnessValueReader
        running: false
        command: ["sh", "-c", "cat /sys/class/backlight/" + root.device + "/brightness && cat /sys/class/backlight/" + root.device + "/max_brightness"]

        property int current: 0
        property int max: 0

        stdout: SplitParser {
            onRead: function(data) {
                const val = parseInt(data.trim())
                if (isNaN(val))
                    return

                if (brightnessValueReader.current === 0) {
                    brightnessValueReader.current = val
                } else {
                    brightnessValueReader.max = val
                }
            }
        }

        onExited: function(exitCode, exitStatus) {
            if (brightnessValueReader.max > 0) {
                root.brightness = (brightnessValueReader.current / brightnessValueReader.max) * 100
                root.maxBrightness = 100
                root.available = true
            } else {
                root.available = false
            }

            brightnessValueReader.current = 0
            brightnessValueReader.max = 0
        }
    }

    function setBrightness(value: real): void {
        const bright = Math.max(0, Math.min(100, value))
        brightnessSetter.command = ["sh", "-c", "echo " + Math.round((bright / 100) * 100) + " | tee /sys/class/backlight/" + root.device + "/brightness"]
        brightnessSetter.running = true
    }

    Process {
        id: brightnessSetter
        running: false
        command: ["sh", "-c", "echo 50 | tee /sys/class/backlight/*/brightness"]
    }

    function getIcon(): string {
        if (brightness < 30) return "󰃞" // Dim
        if (brightness < 70) return "󰃟" // Medium
        return "󰃠" // Bright
    }

    function getColor(): color {
        return Config.Theme.getBrightnessColor(brightness)
    }
}
