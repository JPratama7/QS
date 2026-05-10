pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import "../../../components/bar"
import "../../../config"
import "../../../services/ui"
import "../../popups/calendar"

BaseWidget {
	id: widget

	required property string screenName
	required property PanelWindow barWindow
	property int _seconds: 0

	function formatTime(): string {
		const date = new Date();
		const h = date.getHours();
		const m = date.getMinutes();
		return (h < 10 ? "0" + h : h) + ":" + (m < 10 ? "0" + m : m);
	}
	function formatDate(): string {
		const date = new Date();
		const days = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
		return days[date.getDay()] + " " + date.getDate();
	}

	implicitWidth: textItem.implicitWidth
	implicitHeight: textItem.implicitHeight

	tooltipComponent: Component {
		Text {
			text: "Clock"
			font.pixelSize: Theme.fontSizeSmall
			color: Theme.foregroundColor
		}
	}

	Text {
		id: textItem

		text: {
			widget._seconds; // dependency
			const date = new Date();
			const h = date.getHours();
			const m = date.getMinutes();
			const timeStr = (h < 10 ? "0" + h : h) + ":" + (m < 10 ? "0" + m : m);
			const days = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
			const dateStr = days[date.getDay()] + " " + date.getDate();
			return timeStr + " " + dateStr;
		}
		color: Theme.foregroundColor
		font.pixelSize: Theme.fontSizeNormal
		font.family: Theme.fontFamily
		verticalAlignment: Text.AlignVCenter
	}
	Timer {
		interval: 1000
		repeat: true
		running: true

		onTriggered: {
			widget._seconds++;
		}
	}
	MouseArea {
		anchors.fill: parent
		cursorShape: Qt.PointingHandCursor

		onClicked: {
			const pos = widget.mapToItem(null, 0, 0);
			const popupWidth = 280;
			const anchorX = pos.x + widget.width / 2 - popupWidth / 2;
			ShellUI.openPopup(widget.screenName, "calendar", calendarComponent, Math.max(0, anchorX));
		}
	}
	Component {
		id: calendarComponent

		CalendarPopup {
		}
	}
}
