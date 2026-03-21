import QtQuick
import Quickshell.Io

JsonObject {
    property int position: 0
    property int barSize: 32
    property int barMargin: 0
    property int barRadius: 0
    property var widgetOrder: ["workspaces", "windowTitle", "systemMonitor", "network", "bluetooth", "battery", "audio", "brightness", "nightShift", "caffeine", "clock"]
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
    property int animationDuration: 150
    property int popupAnimationDuration: 200
    property int popupWidth: 320
    property int popupHeight: 400
    property bool popupAutoClose: true
}
