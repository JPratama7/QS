pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import "../../../config"
import "../../../components/bar"
import "../../../services/system"
import "../../../services/ui"
import "../../popups"

BaseWidget {
    id: widget

    required property string screenName
    required property PanelWindow barWindow

    tooltipComponent: Component {
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

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            const pos = widget.mapToItem(null, 0, 0);
            ShellUI.openPopup(widget.screenName, "notifications", notificationPopupComponent, pos.x);
        }
    }

    Component {
        id: notificationPopupComponent
        NotificationPopup {
            screenName: widget.screenName
        }
    }
}
