pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import "../config" as Config

Singleton {
    id: root

    // Audio state
    property bool available: false
    property bool muted: false
    property real volume: 0
    property var sinks: [] // Array of audio sinks
    property var sources: [] // Array of audio sources
    property string defaultSink: ""

    // Update interval
    property int updateInterval: 2000

    Timer {
        id: updateTimer
        interval: root.updateInterval
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            audioReader.running = true
        }
    }

    Process {
        id: audioReader
        running: false
        command: ["sh", "-c", "pactl get-sink-volume @DEFAULT_SINK@ 2>/dev/null && pactl get-sink-mute @DEFAULT_SINK@ 2>/dev/null || echo ''"]

        property string volumeLine: ""
        property string muteLine: ""

        stdout: SplitParser {
            onRead: function(data) {
                const line = data.trim()
                if (line.startsWith("Volume:")) {
                    audioReader.volumeLine = line
                } else if (line === "Mute: yes" || line === "Mute: no") {
                    audioReader.muteLine = line
                }
            }
        }

        onExited: function(exitCode, exitStatus) {
            // Parse volume
            const volMatch = audioReader.volumeLine.match(/(\d+)%/)
            if (volMatch) {
                root.volume = parseInt(volMatch[1])
                root.available = true
            } else {
                root.available = false
            }

            // Parse mute
            root.muted = audioReader.muteLine === "Mute: yes"

            audioReader.volumeLine = ""
            audioReader.muteLine = ""
        }
    }

    function setVolume(value: real): void {
        const vol = Math.max(0, Math.min(100, value))
        volumeSetter.command = ["sh", "-c", "pactl set-sink-volume @DEFAULT_SINK@ " + Math.round(vol) + "%"]
        volumeSetter.running = true
    }

    Process {
        id: volumeSetter
        running: false
        command: ["sh", "-c", "pactl set-sink-volume @DEFAULT_SINK@ " + Math.round(root.volume) + "%"]
    }

    function toggleMute(): void {
        muteToggler.running = true
    }

    Process {
        id: muteToggler
        running: false
        command: ["sh", "-c", "pactl set-sink-mute @DEFAULT_SINK@ toggle"]
    }

    function getIcon(): string {
        if (muted || volume === 0) return "󰝟" // Muted
        if (volume < 30) return "󰕿" // Low
        if (volume < 70) return "󰖀" // Medium
        return "󰕾" // High
    }

    function getColor(): color {
        return Config.Theme.getVolumeColor(volume, muted)
    }
}
