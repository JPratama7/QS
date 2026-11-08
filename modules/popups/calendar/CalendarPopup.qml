pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import "../../../components"
import "../../../config"
import "../../../services/system"

Item {
	id: root

	readonly property int popupWidth: 300
	readonly property int cardPad: 16
	readonly property int railWidth: 18
	readonly property real cellSize: (popupWidth - cardPad * 2 - railWidth) / 7
	property int _todayYear: 0
	property int _todayMonth: 0
	property int _todayDate: 0
	property int _displayYear: 0
	property int _displayMonth: 0
	readonly property bool _drifted: _displayYear !== _todayYear || _displayMonth !== _todayMonth

	function daysInMonth(year: int, month: int): int {
		return new Date(year, month + 1, 0).getDate();
	}
	function firstDayOfMonth(year: int, month: int): int {
		return new Date(year, month, 1).getDay();
	}
	function weekRowCount(year: int, month: int): int {
		return Math.ceil((firstDayOfMonth(year, month) + daysInMonth(year, month)) / 7);
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
	// ISO-8601 week number — the Thursday of a week decides its week/year
	function isoWeek(d: var): int {
		const t = new Date(d.getFullYear(), d.getMonth(), d.getDate());
		const day = (t.getDay() + 6) % 7;
		t.setDate(t.getDate() - day + 3);
		const firstThu = new Date(t.getFullYear(), 0, 4);
		const fd = (firstThu.getDay() + 6) % 7;
		firstThu.setDate(firstThu.getDate() - fd + 3);
		return 1 + Math.round((t.getTime() - firstThu.getTime()) / 604800000);
	}
	function dayOfYear(d: var): int {
		return Math.round((d.getTime() - new Date(d.getFullYear(), 0, 1).getTime()) / 86400000) + 1;
	}
	function daysInYear(year: int): int {
		return ((year % 4 === 0 && year % 100 !== 0) || year % 400 === 0) ? 366 : 365;
	}

	implicitWidth: popupWidth
	implicitHeight: contentColumn.implicitHeight

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

		width: root.popupWidth
		spacing: 0

		anchors {
			top: parent.top
			left: parent.left
		}
		// Anchor header — today as a tear-off date; the clock is a status line
		Item {
			width: parent.width
			height: headLeft.implicitHeight + root.cardPad + 12

			Column {
				id: headLeft

				x: root.cardPad
				y: root.cardPad
				spacing: 6

				Text {
					text: root._todayDate
					color: Theme.foregroundColor
					font.pixelSize: 46
					font.weight: Font.Medium
					font.family: Theme.fontFamilyMono
					font.letterSpacing: -1.5
				}
				Text {
					text: root.weekdayName(new Date(root._todayYear, root._todayMonth, root._todayDate).getDay())
					color: Theme.mutedColor
					font.pixelSize: 9
					font.family: Theme.fontFamilyMono
					font.letterSpacing: 2.2
					font.capitalization: Font.AllUppercase
				}
			}
			Column {
				x: parent.width - width - root.cardPad
				y: root.cardPad + 7
				spacing: 5

				Text {
					text: TimeZone.formatTime(systemClock.date, "hh:mm", PersistentConfig.adapter.timeZone)
					color: Theme.foregroundColor
					font.pixelSize: 17
					font.weight: Font.Medium
					font.family: Theme.fontFamilyMono
					anchors.right: parent.right
				}
				Text {
					text: PersistentConfig.adapter.timeZone || "System"
					color: Qt.alpha(Theme.mutedColor, 0.72)
					font.pixelSize: 8
					font.family: Theme.fontFamilyMono
					font.letterSpacing: 1.3
					font.capitalization: Font.AllUppercase
					anchors.right: parent.right
				}
			}
		}
		Rectangle {
			width: parent.width
			height: 1
			color: Theme.glassBorder
		}
		// Viewport nav — month belongs to the grid, not to the header
		Item {
			width: parent.width
			height: 24 + 22

			Row {
				id: monthRow

				x: root.cardPad
				spacing: 4

				anchors.verticalCenter: parent.verticalCenter

				Text {
					text: root.monthName(root._displayMonth)
					color: Theme.foregroundColor
					font.pixelSize: 14
					font.weight: Font.DemiBold
					font.family: Theme.fontFamily
				}
				Text {
					text: root._displayYear
					color: Theme.mutedColor
					font.pixelSize: 14
					font.family: Theme.fontFamily
				}
			}
			// Return path — only exists while the viewport has drifted from today
			Rectangle {
				id: todayChip

				visible: root._drifted
				x: root.cardPad + monthRow.implicitWidth + 14
				width: chipText.implicitWidth + 16
				height: 18
				radius: 9
				color: Theme.accentSoft
				border.width: 1
				border.color: Theme.accentBorder

				anchors.verticalCenter: parent.verticalCenter

				Text {
					id: chipText

					anchors.centerIn: parent
					text: "Today"
					color: Theme.accentColor
					font.pixelSize: 8
					font.family: Theme.fontFamilyMono
					font.letterSpacing: 1.2
					font.capitalization: Font.AllUppercase
				}
				MouseArea {
					anchors.fill: parent
					cursorShape: Qt.PointingHandCursor

					onClicked: {
						root._displayYear = root._todayYear;
						root._displayMonth = root._todayMonth;
					}
				}
			}
			Item {
				id: navPrev

				width: 24
				height: 24
				x: parent.width - root.cardPad - 50

				anchors.verticalCenter: parent.verticalCenter

				Rectangle {
					anchors.fill: parent
					radius: width / 2
					color: Theme.accentSoft
					visible: prevArea.containsMouse
				}
				SvgIcon {
					anchors.centerIn: parent
					source: "icons/outline/chevron-left.svg"
					color: prevArea.containsMouse ? Theme.accentColor : Theme.mutedColor
					iconSize: 11
				}
				MouseArea {
					id: prevArea

					anchors.fill: parent
					hoverEnabled: true
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
			Item {
				id: navNext

				width: 24
				height: 24

				anchors {
					right: parent.right
					rightMargin: root.cardPad
					verticalCenter: parent.verticalCenter
				}
				Rectangle {
					anchors.fill: parent
					radius: width / 2
					color: Theme.accentSoft
					visible: nextArea.containsMouse
				}
				SvgIcon {
					anchors.centerIn: parent
					source: "icons/outline/chevron-right.svg"
					color: nextArea.containsMouse ? Theme.accentColor : Theme.mutedColor
					iconSize: 11
				}
				MouseArea {
					id: nextArea

					anchors.fill: parent
					hoverEnabled: true
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
		// Ledger grid — week-number rail on the left, band across the current week
		Item {
			width: parent.width
			height: gridCol.implicitHeight + 2

			Column {
				id: gridCol

				x: root.cardPad
				width: parent.width - root.cardPad * 2
				spacing: 0

				Row {
					height: 20
					spacing: 0

					Item {
						width: root.railWidth
						height: 20
					}
					Repeater {
						model: ["SU", "MO", "TU", "WE", "TH", "FR", "SA"]

						delegate: Text {
							required property string modelData
							required property int index

							width: root.cellSize
							height: 20
							horizontalAlignment: Text.AlignHCenter
							verticalAlignment: Text.AlignVCenter
							text: modelData
							color: (index === 0 || index === 6) ? Qt.alpha(Theme.mutedColor, 0.5) : Qt.alpha(Theme.mutedColor, 0.72)
							font.pixelSize: 8
							font.family: Theme.fontFamilyMono
							font.letterSpacing: 0.8
						}
					}
				}
				Repeater {
					model: root.weekRowCount(root._displayYear, root._displayMonth)

					delegate: Rectangle {
						id: weekRow

						required property int index
						readonly property var rowStart: new Date(root._displayYear, root._displayMonth, 1 - root.firstDayOfMonth(root._displayYear, root._displayMonth) + index * 7)
						readonly property var rowThursday: new Date(rowStart.getFullYear(), rowStart.getMonth(), rowStart.getDate() + 4)
						readonly property bool isCurrentWeek: {
							const end = new Date(rowStart.getFullYear(), rowStart.getMonth(), rowStart.getDate() + 7);
							const t = new Date(root._todayYear, root._todayMonth, root._todayDate);
							return !root._drifted && t >= rowStart && t < end;
						}

						width: gridCol.width
						height: root.cellSize
						radius: 7
						color: isCurrentWeek ? Theme.accentSoft : "transparent"

						Text {
							width: root.railWidth
							height: parent.height
							horizontalAlignment: Text.AlignHCenter
							verticalAlignment: Text.AlignVCenter
							text: root.isoWeek(weekRow.rowThursday)
							color: weekRow.isCurrentWeek ? Theme.accentColor : Qt.alpha(Theme.mutedColor, 0.72)
							font.pixelSize: 8
							font.family: Theme.fontFamilyMono
							font.weight: weekRow.isCurrentWeek ? Font.Medium : Font.Normal
						}
						Row {
							x: root.railWidth
							height: parent.height
							spacing: 0

							Repeater {
								model: 7

								delegate: Item {
									required property int index
									readonly property var cellDate: new Date(weekRow.rowStart.getFullYear(), weekRow.rowStart.getMonth(), weekRow.rowStart.getDate() + index)
									readonly property bool isWeekend: index === 0 || index === 6
									readonly property bool isOut: cellDate.getMonth() !== root._displayMonth
									readonly property bool isToday: cellDate.getFullYear() === root._todayYear && cellDate.getMonth() === root._todayMonth && cellDate.getDate() === root._todayDate

									width: root.cellSize
									height: root.cellSize

									Rectangle {
										visible: parent.isToday
										anchors.centerIn: parent
										width: parent.width - 2
										height: width
										radius: width / 2
										color: Theme.accentSoft
									}
									Rectangle {
										visible: parent.isToday
										anchors.centerIn: parent
										width: parent.width - 10
										height: width
										radius: width / 2
										color: Theme.accentColor
									}
									Rectangle {
										visible: cellArea.containsMouse && !parent.isToday
										anchors.centerIn: parent
										width: parent.width - 8
										height: width
										radius: width / 2
										color: weekRow.isCurrentWeek ? Qt.alpha(Theme.accentColor, 0.22) : Theme.hoverColor
									}
									Text {
										anchors.centerIn: parent
										text: parent.cellDate.getDate()
										font.pixelSize: 12
										font.family: Theme.fontFamily
										font.weight: parent.isToday ? Font.DemiBold : Font.Normal
										color: parent.isToday ? Theme.barBackgroundColor
											: parent.isOut ? (parent.isWeekend ? Qt.alpha(Theme.mutedColor, 0.45) : Qt.alpha(Theme.foregroundColor, 0.28))
											: parent.isWeekend ? Theme.mutedColor
											: Theme.foregroundColor
									}
									MouseArea {
										id: cellArea

										anchors.fill: parent
										hoverEnabled: true
									}
								}
							}
						}
					}
				}
			}
		}
		Rectangle {
			width: parent.width
			height: 1
			color: Theme.glassBorder
		}
		// Almanac footer — day-of-year and ISO week for the anchor date
		Item {
			width: parent.width
			height: footText.implicitHeight + 24

			Row {
				id: footText

				x: root.cardPad
				spacing: 5

				anchors.verticalCenter: parent.verticalCenter

				Text {
					text: "Day"
					color: Qt.alpha(Theme.mutedColor, 0.72)
					font.pixelSize: 8
					font.family: Theme.fontFamilyMono
					font.letterSpacing: 1.2
					font.capitalization: Font.AllUppercase
				}
				Text {
					text: root.dayOfYear(new Date(root._todayYear, root._todayMonth, root._todayDate)) + " / " + root.daysInYear(root._todayYear)
					color: Theme.mutedColor
					font.pixelSize: 8
					font.family: Theme.fontFamilyMono
					font.letterSpacing: 1.2
				}
			}
			Row {
				spacing: 5

				anchors {
					right: parent.right
					rightMargin: root.cardPad
					verticalCenter: parent.verticalCenter
				}
				Text {
					text: "Week"
					color: Qt.alpha(Theme.mutedColor, 0.72)
					font.pixelSize: 8
					font.family: Theme.fontFamilyMono
					font.letterSpacing: 1.2
					font.capitalization: Font.AllUppercase
				}
				Text {
					text: root.isoWeek(new Date(root._todayYear, root._todayMonth, root._todayDate))
					color: Theme.mutedColor
					font.pixelSize: 8
					font.family: Theme.fontFamilyMono
					font.letterSpacing: 1.2
				}
			}
		}
	}
}
