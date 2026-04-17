pragma Singleton

import QtQuick

QtObject {
    id: service

    readonly property bool connected: false
    readonly property string ssid: ""
    readonly property int signalStrength: 0

    function toggleWifi(): void {
        // Stub
    }
}
