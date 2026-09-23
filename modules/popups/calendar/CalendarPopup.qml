pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import "../../../components"
import "../../../config"
import "../../../services/system"

Item {
	id: root

	readonly property int popupWidth: 280
	readonly property int cellSize: 36
	property int _todayYear: 0
	property int _todayMonth: 0
	property int _todayDate: 0
	property int _displayYear: 0
	property int _displayMonth: 0

	function daysInMonth(year: int, month: int): int {
		return new Date(year, month + 1, 0).getDate();
	}
	function firstDayOfMonth(year: int, month: int): int {
		return new Date(year, month, 1).getDay();
	}
	function monthName(month: int): string {
		// Note: the QML JS engine on this platform has no Intl (ReferenceError),
		// so month names are hardcoded rather than derived from Intl.DateTimeFormat.
		const names = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
		return names[month];
	}
	function weekdayName(day: int): string {
		const names = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"];
		return names[day];
	}

	implicitWidth: popupWidth
	implicitHeight: contentColumn.implicitHeight + Theme.paddingNormal * 2

	SystemClock {
		id: systemClock

		precision: SystemClock.Minutes
	}

	Component.onCompleted: {
		const today = TimeZone.getToday(PersistentConfig.adapter.timeZone);
		root._todayYear = today.year;
		root._todayMonth = today.month;
		root._todayDate = today.day;
		root._displayYear = root._todayYear;
		root._displayMonth = root._todayMonth;
	}

	// Glass card + glow layer behind (DESIGN_GUIDE.md §5)
	Rectangle {
		anchors.centerIn: parent
		width: parent.width - 6
		height: parent.height - 6
		radius: Theme.radiusGlassy
		color: Qt.alpha(Theme.accentColor, 0.05)
	}
	Rectangle {
		anchors.fill: parent
		color: Theme.glassSurface
		radius: Theme.radiusGlassy
		border.width: 1
		border.color: Theme.glassBorder
	}
	Column {
		id: contentColumn

		spacing: Theme.spacingSmall

		anchors {
			top: parent.top
			left: parent.left
			right: parent.right
			margins: Theme.paddingNormal
		}
		// Big clock moment — large hh:mm, date line below (end4-style header)
		Column {
			width: parent.width
			spacing: 2

			Text {
				text: TimeZone.formatTime(systemClock.date, "hh:mm", PersistentConfig.adapter.timeZone)
				color: Theme.foregroundColor
				font.pixelSize: 26
				font.weight: Font.Medium
				font.family: Theme.fontFamilyMono
			}
			Text {
				text: root.weekdayName(new Date(root._todayYear, root._todayMonth, root._todayDate).getDay())
					+ ", " + root.monthName(root._todayMonth) + " " + root._todayDate
				color: Theme.mutedColor
				font.pixelSize: Theme.fontSizeNormal
				font.family: Theme.fontFamily
			}
		}
		Item {
			id: headerRow

			width: parent.width
			height: navPrev.implicitHeight + Theme.paddingSmall * 2

			SvgIcon {
				id: navPrev

				source: "icons/outline/chevron-left.svg"
				color: Theme.accentColor
				iconSize: Theme.fontSizeLarge

				anchors {
					left: parent.left
					verticalCenter: parent.verticalCenter
				}
				MouseArea {
					anchors.fill: parent
					cursorShape: Qt.PointingHandCursor

					onClicked: {
						root._displayMonth--;
						if (root._displayMonth < 0) {
							root._displayMonth = 11;
							root._displayYear--;
						}
					}
				}
			}
			Column {
				anchors.centerIn: parent
				spacing: 2

				Text {
					text: root.monthName(root._displayMonth) + " " + root._displayYear
					color: Theme.foregroundColor
					font.pixelSize: Theme.fontSizeNormal
					font.family: Theme.fontFamily
					anchors.horizontalCenter: parent.horizontalCenter
				}
				Text {
					text: PersistentConfig.adapter.timeZone || "System"
					color: Theme.mutedColor
					font.pixelSize: Theme.fontSizeSmall
					font.family: Theme.fontFamily
					anchors.horizontalCenter: parent.horizontalCenter
				}
			}
			SvgIcon {
				id: navNext

				source: "icons/outline/chevron-right.svg"
				color: Theme.accentColor
				iconSize: Theme.fontSizeLarge

				anchors {
					right: parent.right
					verticalCenter: parent.verticalCenter
				}
				MouseArea {
					anchors.fill: parent
					cursorShape: Qt.PointingHandCursor

					onClicked: {
						root._displayMonth++;
						if (root._displayMonth > 11) {
							root._displayMonth = 0;
							root._displayYear++;
						}
					}
				}
			}
		}
		Row {
			id: dayNamesRow

			width: parent.width
			spacing: 0

			Repeater {
				model: ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]

				delegate: Item {
					required property string modelData

					width: root.cellSize
					height: root.cellSize * 0.6

					Text {
						anchors.centerIn: parent
						text: modelData
						color: Theme.mutedColor
						font.pixelSize: Theme.fontSizeSmall
						font.family: Theme.fontFamily
					}
				}
			}
		}
		Grid {
			id: dayGrid

			width: parent.width
			columns: 7
			spacing: 0

			Repeater {
				model: 42

				delegate: Rectangle {
					required property int index
					readonly property int firstDay: root.firstDayOfMonth(root._displayYear, root._displayMonth)
					readonly property int daysInMonth: root.daysInMonth(root._displayYear, root._displayMonth)
					readonly property int dayNumber: {
						const day = index - firstDay + 1;
						return (day > 0 && day <= daysInMonth) ? day : 0;
					}
					readonly property bool isToday: dayNumber > 0 && root._displayYear === root._todayYear && root._displayMonth === root._todayMonth && dayNumber === root._todayDate

					width: root.cellSize
					height: root.cellSize
					// Today = accent circle (mockup); other days transparent
					color: isToday ? Theme.accentColor : "transparent"
					radius: width / 2

					Text {
						anchors.centerIn: parent
						visible: parent.dayNumber > 0
						text: parent.dayNumber
						color: parent.isToday ? Theme.barBackgroundColor : Theme.foregroundColor
						font.pixelSize: Theme.fontSizeSmall
						font.family: Theme.fontFamily
						font.weight: parent.isToday ? Font.Medium : Font.Normal
					}
				}
			}
		}
	}
}
