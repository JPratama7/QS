pragma ComponentBehavior: Bound

import QtQuick
import "../../config"

Rectangle {
    id: dialog

    property string action: ""

    signal confirmed()
    signal cancelled()

    readonly property string actionLabel: {
        switch (dialog.action) {
            case "logout":   return "Log Out";
            case "reboot":   return "Reboot";
            case "shutdown": return "Shut Down";
            default:         return dialog.action;
        }
    }

    color: Theme.surfaceColor
    radius: Theme.radiusNormal

    Column {
        anchors.centerIn: parent
        spacing: Theme.spacingNormal
        width: parent.width - Theme.paddingNormal * 2

        Text {
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
            text: dialog.actionLabel + "?"
            color: Theme.errorColor
            font.pixelSize: Theme.fontSizeNormal
            font.family: Theme.fontFamily
        }

        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: Theme.spacingSmall

            Rectangle {
                width: 72
                height: confirmLabel.implicitHeight + Theme.paddingSmall * 2
                radius: Theme.radiusSmall
                color: confirmArea.containsMouse ? Theme.errorColor : Qt.alpha(Theme.errorColor, 0.3)

                Text {
                    id: confirmLabel
                    anchors.centerIn: parent
                    text: "Confirm"
                    color: confirmArea.containsMouse ? Theme.surfaceColor : Theme.foregroundColor
                    font.pixelSize: Theme.fontSizeSmall
                    font.family: Theme.fontFamily
                }

                MouseArea {
                    id: confirmArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: dialog.confirmed()
                }
            }

            Rectangle {
                width: 72
                height: cancelLabel.implicitHeight + Theme.paddingSmall * 2
                radius: Theme.radiusSmall
                color: cancelArea.containsMouse ? Qt.alpha(Theme.mutedColor, 0.3) : "transparent"

                Text {
                    id: cancelLabel
                    anchors.centerIn: parent
                    text: "Cancel"
                    color: Theme.mutedColor
                    font.pixelSize: Theme.fontSizeSmall
                    font.family: Theme.fontFamily
                }

                MouseArea {
                    id: cancelArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: dialog.cancelled()
                }
            }
        }
    }
}
