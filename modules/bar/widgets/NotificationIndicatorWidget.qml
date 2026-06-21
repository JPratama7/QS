pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import "../../../components/bar"
import "../../../components"
import "../../../config"
import "../../../services/system"
import "../../../services/ui"
import "../../popups/notifications"

BaseWidget {
	id: widget

	required property string screenName
	required property PanelWindow barWindow
	readonly property bool hasUnread: Notification.unreadCount > 0
	readonly property bool isDnd: Notification.dndEnabled

	implicitWidth: labelRow.implicitWidth
	implicitHeight: labelRow.implicitHeight

	tooltipComponent: Component {
		Text {
			text: Notification.dndEnabled ? "Do Not Disturb is on — " + Notification.unreadCount + " pending" : widget.hasUnread ? "Notifications: " + Notification.unreadCount : "No notifications"
			font.pixelSize: Theme.fontSizeSmall
			color: Theme.foregroundColor
		}
	}

	Row {
		id: labelRow

		anchors.centerIn: parent
		spacing: 2

		SvgIcon {
			source: widget.isDnd ? "icons/outline/bell-off.svg" : (widget.hasUnread ? "icons/outline/bell-ringing.svg" : "icons/outline/bell.svg")
			color: widget.isDnd ? Theme.accentColor : (widget.hasUnread ? Theme.foregroundColor : Theme.mutedColor)
			iconSize: Theme.fontSizeSmall
		}
		Text {
			visible: widget.hasUnread
			text: Notification.unreadCount
			color: widget.isDnd ? Theme.accentColor : Theme.foregroundColor
			font.pixelSize: Theme.fontSizeSmall
			font.family: Theme.fontFamily
		}
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
