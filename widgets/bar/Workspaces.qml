pragma ComponentBehavior: Bound

import QtQuick
import Quickshell.Hyprland
import "../../config" as Config
import "../../base" as Base
import "../../components" as Components

Base.BaseWidget {
    id: root

    // Fetch values from Config or fallback to defaults
    property var widgetConfig: Config.Config.getWidgetConfig("workspaces", {
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

        // Cache static content as a texture for smoother rendering
        layer.enabled: true
        layer.smooth: true

        // Smooth layout changes when items appear/disappear
        move: Transition {
            NumberAnimation {
                properties: "x,y"
                duration: 150
                easing.type: Easing.OutCubic
            }
        }

        Repeater {
            model: Hyprland.workspaces

            Item {
                id: workspaceItem
                required property var modelData

                // Only show workspaces 1-10
                readonly property bool shouldShow: modelData.id >= 1 && modelData.id <= root.workspaceCount

                // Cache computed values
                readonly property color cachedColor: root.getWorkspaceColor(modelData)
                readonly property string cachedIcon: root.getWorkspaceIcon(modelData)
                readonly property bool isFocused: modelData === Hyprland.focusedWorkspace

                implicitWidth: shouldShow && workspaceLoader.item ? (workspaceLoader.item as Item).implicitWidth : 0
                implicitHeight: shouldShow && workspaceLoader.item ? (workspaceLoader.item as Item).implicitHeight : Config.Theme.componentSize

                // Lazily Load Component
                Loader {
                    id: workspaceLoader
                    anchors.centerIn: parent
                    active: workspaceItem.shouldShow

                    asynchronous: true

                    // Pass cached values as properties
                    property int wsId: workspaceItem.modelData.id
                    property color wsColor: workspaceItem.cachedColor
                    property string wsIcon: workspaceItem.cachedIcon
                    property bool wsFocused: workspaceItem.isFocused

                    sourceComponent: Component {
                        Item {
                            id: workspaceContent
                            property int wsId: workspaceLoader.wsId
                            property color wsColor: workspaceLoader.wsColor
                            property string wsIcon: workspaceLoader.wsIcon
                            property bool wsFocused: workspaceLoader.wsFocused

                            implicitWidth: workspaceBtn.implicitWidth
                            implicitHeight: Config.Theme.componentSize

                            opacity: 1

                            Behavior on opacity {
                                NumberAnimation {
                                    duration: 100
                                    easing.type: Easing.OutCubic
                                }
                            }

                            Components.BarButton {
                                id: workspaceBtn
                                anchors.centerIn: parent

                                text: workspaceContent.wsId.toString()
                                icon: workspaceContent.wsIcon
                                iconColor: workspaceContent.wsColor
                                showBackground: false

                                onClicked: {
                                    Hyprland.dispatch("workspace " + workspaceContent.wsId)
                                }
                            }

                            // Active indicator
                            Rectangle {
                                anchors.bottom: parent.bottom
                                anchors.horizontalCenter: parent.horizontalCenter
                                width: workspaceBtn.width - 4
                                height: 2
                                radius: 1
                                color: workspaceContent.wsColor
                                visible: workspaceContent.wsFocused
                            }
                        }
                    }
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
