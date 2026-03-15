import QtQuick
import Quickshell
import Quickshell.Io
import "../config" as Config
import "../base" as Base
import "../components" as Components

Base.BaseWidget {
    id: root

    property bool caffeineActive: false

    tooltipText: caffeineActive ? "Caffeine: On (Sleep prevented)" : "Caffeine: Off"

    implicitWidth: caffeineIcon.implicitWidth + (Config.Theme.widgetPadding * 2)

    Components.BarIcon {
        id: caffeineIcon
        anchors.centerIn: parent
        icon: caffeineActive ? "󰅪" : "󰅩"
        color: caffeineActive ? Config.Theme.bgDark : Config.Theme.fg
        size: Config.Theme.iconSize
    }

    onClicked: {
        toggleCaffeine()
    }

    function toggleCaffeine(): void {
        caffeineActive = !caffeineActive
        if (caffeineActive) {
            caffeineOn.running = true
        } else {
            caffeineOff.running = true
        }
    }

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
