pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import "../../../config"
import "../../../components/bar"
import "../../../services/system"
import "../../../services/ui"
import "../../popups/notifications"

BaseWidget {
    id: widget

    required property string screenName
    required property PanelWindow barWindow

    tooltipComponent: Component {
        Text {
            text: Notification.dndEnabled
                ? "Do Not Disturb is on — " + Notification.unreadCount + " pending"
                : widget.hasUnread
                    ? "Notifications: " + Notification.unreadCount
                    : "No notifications"
            font.pixelSize: Theme.fontSizeSmall
            color: Theme.foregroundColor
        }
    }

    readonly property bool hasUnread: Notification.unreadCount > 0
    readonly property bool isDnd: Notification.dndEnabled

    implicitWidth: label.implicitWidth
    implicitHeight: label.implicitHeight

    Text {
        id: label
        anchors.centerIn: parent
        text: widget.isDnd ? "\uD83D\uDD07" : (widget.hasUnread ? "\uD83D\uDD14 " + Notification.unreadCount : "\uD83D\uDD15")
        color: widget.isDnd ? Theme.accentColor : (widget.hasUnread ? Theme.foregroundColor : Theme.mutedColor)
        font.pixelSize: Theme.fontSizeSmall
        font.family: Theme.fontFamily
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: mouse => {
            if (mouse.button === Qt.RightButton) {
                Notification.toggleDnd();
                return;
            }
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
