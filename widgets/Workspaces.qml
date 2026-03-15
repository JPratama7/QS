import QtQuick
import Quickshell
import Quickshell.Hyprland
import "../config" as Config
import "../base" as Base
import "../components" as Components

Base.BaseWidget {
    id: root

    // Fetch values from JSON config or fallback to defaults
    property var widgetConfig: Config.JsonConfig.getWidgetConfig("workspaces", {
        "workspaceCount": 10,
        "showIcons": false,
        "showNames": false
    })

    property int workspaceCount: widgetConfig.workspaceCount
    property bool showIcons: widgetConfig.showIcons
    property bool showNames: widgetConfig.showNames

    tooltipText: "Workspaces"
    implicitWidth: workspaceRow.implicitWidth + (Config.Theme.widgetPadding * 2)

    // Workspace row
    Row {
        id: workspaceRow
        anchors.centerIn: parent
        spacing: Config.Theme.spacing

        Repeater {
            model: Hyprland.workspaces

            Item {
                id: workspaceItem
                required property var modelData
                property var workspace: modelData

                implicitWidth: workspaceBtn.implicitWidth
                implicitHeight: Config.Theme.componentSize

                // Only show workspaces 1-10 (filter out named workspaces with negative IDs)
                visible: workspace.id >= 1 && workspace.id <= root.workspaceCount

                Components.BarButton {
                    id: workspaceBtn
                    anchors.centerIn: parent

                    text: workspace.id.toString()
                    icon: getWorkspaceIcon(workspace)
                    iconColor: getWorkspaceColor(workspace)
                    showBackground: false

                    onClicked: {
                        Hyprland.dispatch("workspace " + workspace.id)
                    }
                }

                // Active indicator
                Rectangle {
                    anchors.bottom: parent.bottom
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: workspaceBtn.width - 4
                    height: 2
                    radius: 1
                    color: getWorkspaceColor(workspace)
                    visible: workspace === Hyprland.focusedWorkspace
                }
            }
        }
    }

    function getWorkspaceColor(workspace: var): color {
        if (workspace === Hyprland.focusedWorkspace) {
            return Config.Theme.accent
        }
        if (workspace.active) {
            return Config.Theme.accentBright
        }
        return Config.Theme.fgMuted
    }

    function getWorkspaceIcon(workspace: var): string {
        // Return icon based on workspace content or empty
        if (!root.showIcons) return ""

        // Check for windows in workspace
        const windows = workspace.toplevels
        if (windows && windows.length > 0) {
            return "󰖯" // Window icon
        }
        return ""
    }
}
