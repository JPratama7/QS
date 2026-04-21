pragma ComponentBehavior: Bound

import QtQuick
import "../../../services/compositor"
import "../../../config"

Item {
    id: widget

    required property string screenName

    readonly property var workspaces: Compositor.workspacesForScreen(screenName)
    readonly property int activeWorkspaceId: Compositor.activeWorkspaceIdForScreen(screenName)

    // Hide if compositor doesn't support workspaces
    visible: workspaces.length > 0

    implicitWidth: visible ? row.implicitWidth : 0
    implicitHeight: visible ? row.implicitHeight : 0

    Row {
        id: row
        spacing: Theme.spacingSmall

        Repeater {
            model: widget.workspaces
            delegate: Rectangle {
                id: delegated
                required property var modelData
                width: 20
                height: 20
                radius: Theme.radiusSmall
                color: modelData.id === widget.activeWorkspaceId ? Theme.accentColor : Theme.surfaceColor

                Text {
                    anchors.centerIn: parent
                    text: delegated.modelData.id
                    font.pixelSize: Theme.fontSizeSmall
                    color: delegated.modelData.id === widget.activeWorkspaceId ? Theme.backgroundColor : Theme.foregroundColor
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: Compositor.switchWorkspace(widget.screenName, delegated.modelData.id)
                }
            }
        }
    }
}
