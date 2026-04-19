pragma ComponentBehavior: Bound

import QtQuick
import "../../config"
import "../../services/system"
import "../../services/ui"

Item {
    id: root

    readonly property int menuWidth: 180

    implicitWidth: menuWidth
    implicitHeight: column.implicitHeight + Theme.paddingNormal * 2

    // Pending action waiting for confirmation
    property string pendingAction: ""

    Rectangle {
        anchors.fill: parent
        color: Theme.surfaceColor
        radius: Theme.radiusNormal
        border.width: 1
        border.color: Qt.alpha(Theme.foregroundColor, 0.1)
    }

    Column {
        id: column
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            margins: Theme.paddingNormal
        }
        spacing: Theme.spacingSmall

        Repeater {
            model: [
                { action: "lock",     label: "\uD83D\uDD12  Lock",     destructive: false },
                { action: "suspend",  label: "\uD83D\uDCA4  Suspend",  destructive: false },
                { action: "logout",   label: "\u{1F6AA}  Log Out",    destructive: true  },
                { action: "reboot",   label: "\uD83D\uDD04  Reboot",   destructive: true  },
                { action: "shutdown", label: "\u23FB  Shut Down", destructive: true  }
            ]

            delegate: Rectangle {
                id: actionRow
                required property var modelData
                width: column.width
                height: actionLabel.implicitHeight + Theme.paddingSmall * 2
                radius: Theme.radiusSmall
                color: actionArea.containsMouse
                    ? Qt.alpha(actionRow.modelData.destructive ? Theme.errorColor : Theme.accentColor, 0.15)
                    : "transparent"

                Text {
                    id: actionLabel
                    anchors {
                        verticalCenter: parent.verticalCenter
                        left: parent.left
                        leftMargin: Theme.paddingSmall
                    }
                    text: actionRow.modelData.label
                    color: actionRow.modelData.destructive ? Theme.errorColor : Theme.foregroundColor
                    font.pixelSize: Theme.fontSizeSmall
                    font.family: Theme.fontFamily
                }

                MouseArea {
                    id: actionArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        if (actionRow.modelData.destructive) {
                            root.pendingAction = actionRow.modelData.action;
                        } else {
                            SessionActions.execute(actionRow.modelData.action);
                            ShellUI.closeAllPopups();
                        }
                    }
                }
            }
        }
    }

    // Inline confirmation — shown when a destructive action is pending
    ConfirmActionDialog {
        anchors.fill: parent
        visible: root.pendingAction !== ""
        action: root.pendingAction

        onConfirmed: {
            SessionActions.execute(root.pendingAction);
            root.pendingAction = "";
            ShellUI.closeAllPopups();
        }

        onCancelled: {
            root.pendingAction = "";
        }
    }
}
