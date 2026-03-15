import QtQuick
import Quickshell.Io
import "../config" as Config
import "../base" as Base
import "../components" as Components

Base.BaseWidget {
    id: root

    property bool nightModeActive: false
    property int temperature: 4500
    property int transitionDuration: 5
    containerColor: nightModeActive ? Config.Theme.warning : Config.Theme.widgetBg

    Component.onCompleted: {
        if (nightModeActive) {
            nightModeOn.running = true
        } else {
            nightModeOff.running = true
        }
    }

    tooltipText: nightModeActive ? "Night Mode: On (" + temperature + "K)" : "Night Mode: Off"

    implicitWidth: nightIcon.implicitWidth + (Config.Theme.widgetPadding * 2)

    Components.BarIcon {
        id: nightIcon
        anchors.centerIn: parent
        icon: nightModeActive ? "󰖕" : "󰖔"
        color: nightModeActive ? Config.Theme.bgDark : Config.Theme.fg
        size: Config.Theme.iconSize
    }

    onClicked: {
        toggleNightMode()
    }

    function toggleNightMode(): void {
        nightModeActive = !nightModeActive
        if (nightModeActive) {
            nightModeOn.running = true
        } else {
            nightModeOff.running = true
        }
    }

    Process {
        id: nightModeOn
        running: false
        command: ["sh", "-c", "gammastep -O " + root.temperature + " -b 1.0 2>/dev/null &"]
    }

    Process {
        id: nightModeOff
        running: false
        command: ["sh", "-c", "pkill gammastep 2>/dev/null || true"]
    }
}
