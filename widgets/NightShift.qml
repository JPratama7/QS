import QtQuick
import Quickshell.Io
import "../config" as Config
import "../base" as Base
import "../components" as Components
import "../services" as Services

Base.BaseWidget {
    id: root

    // Shorthand reference to StateStore path (may be undefined during init)
    readonly property var config: Services.StateStore.widgets?.bar?.nightShift || null

    // Bind to config for clean internal access with fallback defaults
    property bool nightModeActive: root.config?.active ?? false
    property int temperature: root.config?.temperature ?? 4500
    property int transitionDuration: root.config?.transitionDuration ?? 5

    containerColor: root.nightModeActive ? Config.Theme.warning : Config.Theme.widgetBg

    Component.onCompleted: {
        if (root.nightModeActive) {
            nightModeOn.running = true
        } else {
            nightModeOff.running = true
        }
    }

    tooltipText: root.nightModeActive ? "Night Mode: On (" + root.temperature + "K)" : "Night Mode: Off"

    implicitWidth: nightIcon.implicitWidth + (Config.Theme.widgetPadding * 2)

    Components.BarIcon {
        id: nightIcon
        anchors.centerIn: parent
        icon: root.nightModeActive ? "󰖕" : "󰖔"
        color: root.nightModeActive ? Config.Theme.bgDark : Config.Theme.fg
        size: Config.Theme.iconSize
    }

    onClicked: {
        root.toggleNightMode()
    }

    function toggleNightMode(): void {
        root.nightModeActive = !root.nightModeActive
        if (root.nightModeActive) {
            nightModeOn.running = true
        } else {
            nightModeOff.running = true
        }
    }

    // Write-through using shorthand (only if config is ready)
    onNightModeActiveChanged: if (root.config) root.config.active = root.nightModeActive
    onTemperatureChanged: if (root.config) root.config.temperature = root.temperature
    onTransitionDurationChanged: if (root.config) root.config.transitionDuration = root.transitionDuration

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
