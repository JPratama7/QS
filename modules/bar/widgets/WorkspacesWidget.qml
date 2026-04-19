pragma ComponentBehavior: Bound

import QtQuick
import "../../../services/compositor"
import "../../../config"

Item {
    id: widget

    required property string screenName

    readonly property var workspaces: Compositor.workspacesForScreen(screenName)
    readonly property int activeWorkspaceId: {
        const list = workspaces;
        for (let i = 0; i < list.length; i++) {
            if (list[i].monitor === screenName) return list[i].id;
        }
        return 0;
    }

    // Hide if compositor doesn't support workspaces
    visible: workspaces.length > 0

    implicitWidth: visible ? row.implicitWidth : 0
    implicitHeight: visible ? row.implicitHeight : 0

    Row {
        id: row
        spacing: Theme.spacingSmall

        Repeater {
            model: 10
            delegate: Rectangle {
                required property int index
                width: 20
                height: 20
                radius: Theme.radiusSmall
                color: index + 1 === widget.activeWorkspaceId ? Theme.accentColor : Theme.surfaceColor

                Text {
                    anchors.centerIn: parent
                    text: index + 1
                    font.pixelSize: Theme.fontSizeSmall
                    color: index + 1 === widget.activeWorkspaceId ? Theme.backgroundColor : Theme.foregroundColor
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: Compositor.switchWorkspace(widget.screenName, index + 1)
                }
            }
        }
    }
}
