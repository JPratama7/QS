pragma ComponentBehavior: Bound

import QtQuick
import "../../../config"
import "../../../services/system"

Item {
    id: widget

    property Component tooltipComponent: Component {
        Text {
            text: widget.hasUnread ? "Notifications: " + Notification.unreadCount : "No notifications"
            font.pixelSize: Theme.fontSizeSmall
            color: Theme.foregroundColor
        }
    }

    readonly property bool hasUnread: Notification.unreadCount > 0

    implicitWidth: label.implicitWidth
    implicitHeight: label.implicitHeight

    Text {
        id: label
        anchors.centerIn: parent
        text: widget.hasUnread ? "\uD83D\uDD14 " + Notification.unreadCount : "\uD83D\uDD15"
        color: widget.hasUnread ? Theme.foregroundColor : Theme.mutedColor
        font.pixelSize: Theme.fontSizeSmall
        font.family: Theme.fontFamily
    }
}
