pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import "../config" as Config

Singleton {
    id: root

    // Network state
    property bool connected: false
    property string interfaceName: ""
    property string ip4Address: ""
    property string ip6Address: ""

    // WiFi specific
    property bool isWifi: false
    property string ssid: ""
    property int signalStrength: 0
    property bool isSecure: false

    // Ethernet specific
    property bool isEthernet: false
    property int linkSpeed: 0

    // Multiple adapters
    property var adapters: [] // Array of adapter objects

    // Update interval
    property int updateInterval: 5000

    Timer {
        id: updateTimer
        interval: root.updateInterval
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            networkReader.running = true
        }
    }

    Process {
        id: networkReader
        running: false
        command: ["sh", "-c", "nmcli -t -f DEVICE,TYPE,STATE,CONNECTION device status 2>/dev/null || echo ''"]

        property var adapterList: []

        stdout: SplitParser {
            onRead: function(data) {
                const parts = data.trim().split(":")
                if (parts.length >= 4) {
                    const device = parts[0]
                    const type = parts[1]
                    const state = parts[2]
                    const connection = parts[3]

                    if (state === "connected" || state === "activated") {
                        networkReader.adapterList.push({
                            device: device,
                            type: type,
                            state: state,
                            connection: connection,
                            isWifi: type === "wifi",
                            isEthernet: type === "ethernet"
                        })
                    }
                }
            }
        }

        onExited: function(exitCode, exitStatus) {
            root.adapters = networkReader.adapterList.slice()
            root.connected = networkReader.adapterList.length > 0

            // Get primary adapter info
            if (networkReader.adapterList.length > 0) {
                const primary = networkReader.adapterList[0]
                root.interfaceName = primary.device
                root.isWifi = primary.isWifi
                root.isEthernet = primary.isEthernet

                if (primary.isWifi) {
                    wifiInfoReader.running = true
                } else {
                    root.ssid = primary.connection
                }
            }
            networkReader.adapterList = []
        }
    }

    Process {
        id: wifiInfoReader
        running: false
        command: ["sh", "-c", "nmcli -t -f ACTIVE,SSID,SIGNAL,SECURITY dev wifi list 2>/dev/null | grep '^yes' || echo ''"]

        stdout: SplitParser {
            onRead: function(data) {
                const parts = data.trim().split(":")
                if (parts.length >= 4 && parts[0] === "yes") {
                    root.ssid = parts[1]
                    root.signalStrength = parseInt(parts[2]) || 0
                    root.isSecure = parts[3] !== ""
                }
            }
        }
    }

    function getSignalIcon(strength: int): string {
        if (strength >= 80) return "󰤨" // Excellent
        if (strength >= 60) return "󰤥" // Good
        if (strength >= 40) return "󰤢" // Fair
        if (strength >= 20) return "󰤟" // Weak
        return "󰤫" // None
    }

    function getEthernetIcon(): string {
        return "󰈀"
    }

    function getDisconnectedIcon(): string {
        return "󰤮"
    }
}
