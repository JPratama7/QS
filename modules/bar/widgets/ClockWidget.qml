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

	implicitWidth: textItem.implicitWidth
	implicitHeight: textItem.implicitHeight

	tooltipComponent: Component {
		Text {
			text: "Clock"
			font.pixelSize: Theme.fontSizeSmall
			color: Theme.foregroundColor
		}
	}

	SystemClock {
		id: systemClock

		precision: SystemClock.Seconds
	}
	Text {
		id: textItem

		text: {
			return Qt.formatDateTime(systemClock.date, "hh:mm ddd");
		}
		color: Theme.foregroundColor
		font.pixelSize: Theme.fontSizeNormal
		font.family: Theme.fontFamily
		verticalAlignment: Text.AlignVCenter
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
