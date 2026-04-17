pragma Singleton

import QtQuick

QtObject {
    id: service

    readonly property bool present: false
    readonly property int percent: 0
    readonly property bool charging: false

    function shutdown(): void {
        // Stub
    }

    function reboot(): void {
        // Stub
    }

    function suspend(): void {
        // Stub
    }

    function logout(): void {
        // Stub
    }
}
