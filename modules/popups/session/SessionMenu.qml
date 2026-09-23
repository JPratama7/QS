pragma ComponentBehavior: Bound

import QtQuick
import "../../../components"
import "../../../config"
import "../../../services/system"
import "../shared"

Item {
    id: root

    required property string screenName

    readonly property int menuWidth: 340

    implicitWidth: menuWidth
    implicitHeight: column.implicitHeight + Theme.paddingNormal * 2

    // Pending action waiting for confirmation
    readonly property string pendingAction: root._pendingAction
    readonly property bool isDestructive: root._isDestructive


    // Internal state for confirmation dialog
    property bool _confirmDialog: false
    property string _pendingAction: ""
    property string _pendingLabel: ""
    property bool _isDestructive: false

    // Glass card + glow layer behind (DESIGN_GUIDE.md §6)
    Rectangle {
        anchors.centerIn: parent
        width: parent.width - 6
        height: parent.height - 6
        radius: Theme.radiusGlassy
        color: Qt.alpha(Theme.accentColor, 0.05)
    }
    Rectangle {
        anchors.fill: parent
        color: Theme.glassSurface
        radius: Theme.radiusGlassy
        border.width: 1
        border.color: Theme.glassBorder
    }

    function openDialog(label: string, action: string, destructive: bool) {
        root._confirmDialog = true;
        root._pendingLabel = label;
        root._pendingAction = action;
        root._isDestructive = destructive;
    }

    function closeDialog() {
        root._confirmDialog = false;
        root._pendingAction = "";
        root._pendingLabel = "";
        root._isDestructive = false;
    }

    function executePendingAction() {
        if (root.pendingAction === "") {
            return;
        }
        const action = root.pendingAction;
        Qt.callLater(() => SessionActions.execute(action));
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

        // Icon button row — vertical icon+label tiles (DESIGN_GUIDE.md §6)
        Row {
            width: parent.width
            spacing: Theme.spacingSmall

            Repeater {
                model: [
                    {
                        action: "suspend",
                        label: "Suspend",
                        icon: "icons/outline/suspend.svg",
                        destructive: false
                    },
                    {
                        action: "reboot",
                        label: "Reboot",
                        icon: "icons/outline/reboot.svg",
                        destructive: true
                    },
                    {
                        action: "shutdown",
                        label: "Shut Down",
                        icon: "icons/outline/shutdown.svg",
                        destructive: true
                    },
                    {
                        action: "logout",
                        label: "Log Out",
                        icon: "icons/outline/logout.svg",
                        destructive: true
                    }
                ]

                delegate: Rectangle {
                    id: actionTile
                    required property var modelData

                    width: (column.width - Theme.spacingSmall * 3) / 4
                    height: actionColumn.implicitHeight + Theme.paddingNormal * 2
                    radius: Theme.radiusInner
                    // Destructive tiles tint dangerSoft; hover lifts the fill
                    color: actionArea.containsMouse
                        ? (actionTile.modelData.destructive ? Theme.dangerSoft : Theme.accentSoft)
                        : Qt.alpha(Theme.foregroundColor, 0.05)
                    border.width: actionArea.containsMouse && actionTile.modelData.destructive ? 1 : 0
                    border.color: Theme.dangerBorder

                    Behavior on color {
                        ColorAnimation { duration: Theme.hoverDuration }
                    }

                    Column {
                        id: actionColumn
                        anchors.centerIn: parent
                        spacing: Theme.spacingSmall

                        SvgIcon {
                            anchors.horizontalCenter: parent.horizontalCenter
                            source: actionTile.modelData.icon
                            color: actionTile.modelData.destructive ? Theme.errorColor : Theme.foregroundColor
                            iconSize: 19
                        }
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: actionTile.modelData.label
                            color: actionTile.modelData.destructive ? Theme.errorColor : Theme.mutedColor
                            font.pixelSize: Theme.fontSizeSmall - 1
                            font.family: Theme.fontFamily
                        }
                    }

                    MouseArea {
                        id: actionArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            root.openDialog(actionTile.modelData.label, actionTile.modelData.action, actionTile.modelData.destructive);
                        }
                    }
                }
            }
        }
    }

    // Inline confirmation — shown when a destructive action is pending
    ConfirmActionDialog {
        anchors.fill: parent
        visible: root._confirmDialog
        action: "Are you sure you want to " + root._pendingLabel

        onConfirmed: {
            root.executePendingAction();
            root.closeDialog();
        }

        onCancelled: {
            root.closeDialog();
        }
    }
}
