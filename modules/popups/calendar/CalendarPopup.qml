pragma ComponentBehavior: Bound

import QtQuick
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
		const names = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
		return names[month];
	}

	implicitWidth: popupWidth
	implicitHeight: contentColumn.implicitHeight + Theme.paddingNormal * 2

	Component.onCompleted: {
		const today = TimeZone.getToday(ShellConfig.timeZone);
		root._todayYear = today.year;
		root._todayMonth = today.month;
		root._todayDate = today.day;
		root._displayYear = root._todayYear;
		root._displayMonth = root._todayMonth;
	}

	Rectangle {
		anchors.fill: parent
		color: Theme.surfaceColor
		radius: Theme.radiusNormal
		border.width: 1
		border.color: Qt.alpha(Theme.foregroundColor, 0.1)
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
		Item {
			id: headerRow

			width: parent.width
			height: navPrev.implicitHeight + Theme.paddingSmall * 2

			Text {
				id: navPrev

				text: "<"
				color: Theme.accentColor
				font.pixelSize: Theme.fontSizeLarge
				font.family: Theme.fontFamily

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
					text: ShellConfig.timeZone || "System"
					color: Theme.mutedColor
					font.pixelSize: Theme.fontSizeSmall
					font.family: Theme.fontFamily
					anchors.horizontalCenter: parent.horizontalCenter
				}
			}
			Text {
				id: navNext

				text: ">"
				color: Theme.accentColor
				font.pixelSize: Theme.fontSizeLarge
				font.family: Theme.fontFamily

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
					color: isToday ? Qt.alpha(Theme.accentColor, 0.2) : "transparent"
					radius: Theme.radiusSmall

					Text {
						anchors.centerIn: parent
						visible: parent.dayNumber > 0
						text: parent.dayNumber
						color: parent.isToday ? Theme.accentColor : Theme.foregroundColor
						font.pixelSize: Theme.fontSizeSmall
						font.family: Theme.fontFamily
					}
				}
			}
		}
	}
}
