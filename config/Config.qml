pragma Singleton
import Quickshell
import QtQuick

Singleton {
    id: root

    // Bar Position Enum
    enum Position {
        Top,
        Bottom,
        Left,
        Right
    }

    // Bar Layout Configuration
    property int position: Config.Position.Top
    property int barSize: 32
    property int barMargin: 0
    property int barRadius: 0

    // Widget Visibility Toggles
    property bool showWorkspaces: true
    property bool showWindowTitle: true
    property bool showSystemMonitor: true
    property bool showNetwork: true
    property bool showBluetooth: true
    property bool showBattery: true
    property bool showAudio: true
    property bool showBrightness: true
    property bool showNightShift: true
    property bool showCaffeine: true
    property bool showClock: true

    // Widget Order (array of widget names)
    property var widgetOrder: [
        "workspaces",
        "windowTitle",
        "systemMonitor",
        "network",
        "bluetooth",
        "battery",
        "audio",
        "brightness",
        "nightShift",
        "caffeine",
        "clock"
    ]

    // Animation Settings
    property int animationDuration: 150
    property int popupAnimationDuration: 200

    // Popup Settings
    property int popupWidth: 320
    property int popupHeight: 400
    property bool popupAutoClose: true

    // Helper Functions
    readonly property bool isHorizontal: position === Config.Position.Top || position === Config.Position.Bottom
    readonly property bool isVertical: position === Config.Position.Left || position === Config.Position.Right

    function getPositionName(): string {
        switch (position) {
            case Config.Position.Top: return "top"
            case Config.Position.Bottom: return "bottom"
            case Config.Position.Left: return "left"
            case Config.Position.Right: return "right"
        }
        return "top"
    }

    function getAnchors(): var {
        const anchors = {}
        switch (position) {
            case Config.Position.Top:
                anchors.top = true
                anchors.left = true
                anchors.right = true
                break
            case Config.Position.Bottom:
                anchors.bottom = true
                anchors.left = true
                anchors.right = true
                break
            case Config.Position.Left:
                anchors.left = true
                anchors.top = true
                anchors.bottom = true
                break
            case Config.Position.Right:
                anchors.right = true
                anchors.top = true
                anchors.bottom = true
                break
        }
        return anchors
    }
}
