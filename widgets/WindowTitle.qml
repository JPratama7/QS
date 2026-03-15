import QtQuick
import Quickshell
import Quickshell.Hyprland
import "../config" as Config
import "../base" as Base
import "../components" as Components

Base.BaseWidget {
    id: root

    property int maxWidth: 200
    property bool showAppName: true

    tooltipText: activeWindow ? activeWindow.title : "No active window"
    implicitWidth: Math.min(titleText.implicitWidth + (Config.Theme.widgetPadding * 2), maxWidth)

    readonly property var activeWindow: Hyprland.focusedWorkspace?.lastFocusedWindow

    Components.BarText {
        id: titleText
        anchors.centerIn: parent

        text: {
            if (!activeWindow) return ""
            const title = activeWindow.title || ""
            // Truncate if too long
            if (title.length > 30) {
                return title.substring(0, 27) + "..."
            }
            return title
        }
        color: Config.Theme.fg
        fontSize: Config.Theme.fontSizeNormal
        maxWidth: root.maxWidth - (Config.Theme.widgetPadding * 2)
    }
}
