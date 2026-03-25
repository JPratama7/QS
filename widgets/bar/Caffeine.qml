pragma ComponentBehavior: Bound
import QtQuick
import Quickshell.Io


import "../../types/widgets/bar" as BarTypes
import "../../config" as Config
import "../../base" as Base
import "../../components" as Components
import "../../services" as Services

Base.BaseWidget {
    id: root
    objectName: "Caffeine"

    required property BarTypes.Sizes sizes

    // Shorthand reference to StateStore path (may be undefined during init)
    readonly property var config: Services.StateStore.widgets?.bar?.caffeine || null

    // Bind to config for clean internal access with fallback default
    property bool caffeineActive: root.config?.active ?? false

    containerColor: root.caffeineActive ? Config.Theme.warning : Config.Theme.widgetBg

    Component.onCompleted: {
        // Restore the inhibitor state on startup based on the saved setting
        if (root.caffeineActive) {
            caffeineOn.running = true
        } else {
            caffeineOff.running = true
        }
    }

    tooltipText: root.caffeineActive ? "Caffeine: On (Sleep prevented)" : "Caffeine: Off"

    implicitWidth: caffeineIcon.implicitWidth + (Config.Theme.widgetPadding * 2)

    Components.BarIcon {
        id: caffeineIcon
        anchors.centerIn: parent
        icon: root.caffeineActive ? "󰅪" : "󰅩"
        color: root.caffeineActive ? Config.Theme.bgDark : Config.Theme.fg
        size: root.sizes.icon
    }

    onClicked: {
        root.toggleCaffeine()
    }

    function toggleCaffeine(): void {
        root.caffeineActive = !root.caffeineActive
        if (root.caffeineActive) {
            caffeineOn.running = true
        } else {
            caffeineOff.running = true
        }
    }

    // Write-through using shorthand (only if config is ready)
    onCaffeineActiveChanged: if (root.config) root.config.active = root.caffeineActive

    Process {
        id: caffeineOn
        running: false
        command: ["sh", "-c", "systemd-inhibit --what=sleep --who=quickshell --why=\"Caffeine mode active\" sleep infinity &"]
    }

    Process {
        id: caffeineOff
        running: false
        command: ["sh", "-c", "pkill -f \"systemd-inhibit.*Caffeine\" 2>/dev/null || true"]
    }
}
