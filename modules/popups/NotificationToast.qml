pragma ComponentBehavior: Bound

import QtQuick
import Quickshell.Services.Notifications as QuickshellNotification
import Quickshell.Widgets
import "../../config"
import "../../services/system"

Item {
    id: toast

    required property QuickshellNotification.Notification notification
    signal dismissed()

    readonly property int cardPadding: Theme.paddingNormal
    readonly property int iconSize: Theme.iconSizeSmall * 2

    property bool bodyExpanded: false

    // Single resolved icon string used by both IconImage and fallback Text
    readonly property string resolvedIcon: toast.notification.image
        || (toast.notification.appIcon && AppIcons.iconFromName(toast.notification.appIcon))
        || (toast.notification.desktopEntry && AppIcons.iconForAppId(toast.notification.desktopEntry))
        || ""

    implicitWidth: parent.width
    implicitHeight: cardContent.implicitHeight + cardPadding * 2

    Rectangle {
        id: card
        anchors.fill: parent
        color: Theme.surfaceColor
        radius: Theme.radiusNormal
        border.width: 1
        border.color: toast.notification.urgency === QuickshellNotification.NotificationUrgency.Critical
            ? Qt.alpha(Theme.errorColor, 0.3)
            : Qt.alpha(Theme.foregroundColor, 0.1)
    }

    Row {
        id: cardContent
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            margins: toast.cardPadding
        }
        spacing: Theme.spacingNormal

        Rectangle {
            id: iconContainer
            width: toast.iconSize
            height: toast.iconSize
            radius: Theme.radiusSmall
            anchors.verticalCenter: parent.verticalCenter

            color: {
                if (toast.notification.urgency === QuickshellNotification.NotificationUrgency.Critical)
                    return Qt.alpha(Theme.errorColor, 0.2);
                if (toast.notification.urgency === QuickshellNotification.NotificationUrgency.Low)
                    return Qt.alpha(Theme.mutedColor, 0.15);
                return Qt.alpha(Theme.accentColor, 0.2);
            }

            // Resolved icon (image > appIcon > desktopEntry)
            IconImage {
                anchors.fill: parent
                anchors.margins: Theme.paddingSmall
                source: toast.resolvedIcon
                visible: toast.resolvedIcon !== ""
            }

            // Fallback bell emoji
            Text {
                anchors.centerIn: parent
                text: "🔔"
                font.pixelSize: Theme.iconSizeSmall
                visible: toast.resolvedIcon === ""
                color: {
                    if (toast.notification.urgency === QuickshellNotification.NotificationUrgency.Critical)
                        return Theme.errorColor;
                    if (toast.notification.urgency === QuickshellNotification.NotificationUrgency.Low)
                        return Theme.mutedColor;
                    return Theme.accentColor;
                }
            }
        }

        Column {
            id: textColumn
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width - iconContainer.width - parent.spacing - dismissButton.width - parent.spacing

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
                textFormat: Text.StyledText
                color: Theme.mutedColor
                font.pixelSize: Theme.fontSizeSmall
                font.family: Theme.fontFamily
                elide: Text.ElideRight
                maximumLineCount: toast.bodyExpanded ? undefined : 2
                wrapMode: Text.WordWrap
                visible: text.length > 0
            }

            Text {
                id: expandIndicator
                visible: bodyText.visible && (bodyText.truncated || toast.bodyExpanded)
                text: toast.bodyExpanded ? "▲ show less" : "▼ show more"
                color: Theme.accentColor
                font.pixelSize: Theme.fontSizeSmall - 1
                font.family: Theme.fontFamily

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: toast.bodyExpanded = !toast.bodyExpanded
                }
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
        z: -1
        anchors.fill: parent
        onClicked: toast.dismissed()
    }
}
