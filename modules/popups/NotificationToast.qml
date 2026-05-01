pragma ComponentBehavior: Bound

import QtQuick
import Quickshell.Services.Notifications
import "../../config"

Item {
    id: toast

    required property Notification notification
    signal dismissed()

    readonly property int cardPadding: Theme.paddingNormal

    implicitWidth: parent.width
    implicitHeight: cardContent.implicitHeight + cardPadding * 2

    Rectangle {
        anchors.fill: parent
        color: Theme.surfaceColor
        radius: Theme.radiusNormal
        border.width: 1
        border.color: Qt.alpha(Theme.foregroundColor, 0.1)
    }

    Row {
        id: cardContent
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            margins: cardPadding
        }
        spacing: Theme.spacingNormal

        Rectangle {
            id: iconContainer
            width: Theme.iconSizeSmall * 2
            height: width
            radius: Theme.radiusSmall
            color: Qt.alpha(Theme.accentColor, 0.2)
            anchors.verticalCenter: parent.verticalCenter

            Text {
                anchors.centerIn: parent
                text: "🔔"
                font.pixelSize: Theme.iconSizeSmall
                color: Theme.accentColor
            }
        }

        Column {
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width - iconContainer.width - parent.spacing - dismissButton.width

            Text {
                id: titleText
                width: parent.width
                text: toast.notification.summary || "Notification"
                color: Theme.foregroundColor
                font.pixelSize: Theme.fontSizeNormal
                font.family: Theme.fontFamily
                font.weight: Font.Medium
                elide: Text.ElideRight
            }

            Text {
                id: bodyText
                width: parent.width
                text: toast.notification.body || ""
                color: Theme.mutedColor
                font.pixelSize: Theme.fontSizeSmall
                font.family: Theme.fontFamily
                elide: Text.ElideRight
                maximumLineCount: 2
                wrapMode: Text.WordWrap
                visible: text.length > 0
            }
        }

        MouseArea {
            id: dismissButton
            width: Theme.iconSizeSmall + Theme.paddingSmall
            height: width
            anchors.verticalCenter: parent.verticalCenter
            hoverEnabled: true

            Rectangle {
                anchors.fill: parent
                radius: Theme.radiusSmall
                color: dismissButton.containsMouse ? Qt.alpha(Theme.errorColor, 0.2) : "transparent"
            }

            Text {
                anchors.centerIn: parent
                text: "✕"
                color: dismissButton.containsMouse ? Theme.errorColor : Theme.mutedColor
                font.pixelSize: Theme.fontSizeSmall
                font.family: Theme.fontFamily
            }

            onClicked: toast.dismissed()
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            // Activate the notification (open app, etc.)
            toast.notification.activate();
            toast.dismissed();
        }
    }
}