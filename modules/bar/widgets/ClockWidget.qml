pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import "../../../components/bar"
import "../../../config"
import "../../../services/system"
import "../../../services/ui"
import "../../popups/calendar"

BaseWidget {
	id: widget

	required property string screenName
	required property PanelWindow barWindow

	implicitWidth: textItem.implicitWidth + Theme.paddingSmall * 2
	implicitHeight: textItem.implicitHeight + Theme.paddingSmall * 2

	tooltipComponent: Component {
		Text {
			text: "Clock"
			font.pixelSize: Theme.fontSizeSmall
			color: Theme.foregroundColor
		}
	}

	SystemClock {
		id: systemClock

		precision: SystemClock.Minutes
	}

	Rectangle {
		anchors.fill: parent
		radius: Theme.radiusSmall
		color: mouseArea.containsMouse ? Theme.hoverColor : "transparent"
	}

	Text {
		id: textItem

		anchors.centerIn: parent
		text: TimeZone.formatTime(systemClock.date, "hh:mm ddd", ShellConfig.timeZone)
		color: Theme.foregroundColor
		font.pixelSize: Theme.fontSizeNormal
		font.family: Theme.fontFamilyMono
		verticalAlignment: Text.AlignVCenter
	}

	MouseArea {
		id: mouseArea

		anchors.fill: parent
		hoverEnabled: true
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
