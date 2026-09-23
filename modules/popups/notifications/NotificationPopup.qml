pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import Quickshell.Services.Notifications as QuickshellNotifications
import Quickshell.Widgets
import "../../../components"
import "../../../config"
import "../../../services/system"

Item {
	id: root

	required property string screenName
	readonly property int popupWidth: 300
	readonly property int maxPopupHeight: 400

	// Expanded state keyed by notification.id — survives delegate reuse
	property var _expandedMap: ({})

	function _isExpanded(notificationId: int): bool {
		return _expandedMap[notificationId] === true;
	}
	function _setExpanded(notificationId: int, expanded: bool): void {
		const map = Object.assign({}, _expandedMap);
		if (expanded)
			map[notificationId] = true;
		else
			delete map[notificationId];
		_expandedMap = map;
	}

	// Prune stale entries when notifications are dismissed
	function _pruneExpandedMap(): void {
		const activeIds = new Set(Notification.trackedList.map(n => n.id));
		const map = Object.assign({}, _expandedMap);
		let changed = false;
		for (const key of Object.keys(map)) {
			if (!activeIds.has(parseInt(key))) {
				delete map[key];
				changed = true;
			}
		}
		if (changed)
			_expandedMap = map;
	}

	implicitWidth: popupWidth
	implicitHeight: Math.min(column.implicitHeight + Theme.paddingNormal * 2, maxPopupHeight)

	Connections {
		function onTrackedListChanged() {
			root._pruneExpandedMap();
		}

		target: Notification
	}
	// Glass card + glow layer behind (DESIGN_GUIDE.md §4)
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
		id: column

		spacing: Theme.spacingSmall

		anchors {
			top: parent.top
			left: parent.left
			right: parent.right
			margins: Theme.paddingNormal
		}

		// Header — title + Clear all text button
		Row {
			id: headerRow

			width: parent.width
			spacing: Theme.spacingNormal

			Text {
				width: parent.width - clearAllButton.width - parent.spacing
				text: "Notifications"
				color: Theme.foregroundColor
				font.pixelSize: Theme.fontSizeNormal
				font.family: Theme.fontFamily
				font.weight: Font.Medium
				elide: Text.ElideRight
			}
			Item {
				id: clearAllButton

				width: clearAllText.implicitWidth + Theme.paddingSmall * 2
				height: clearAllText.implicitHeight + Theme.paddingSmall
				visible: Notification.trackedList.length > 0

				Text {
					id: clearAllText

					anchors.centerIn: parent
					text: "Clear all"
					color: clearAllArea.containsMouse ? Theme.errorColor : Theme.mutedColor
					font.pixelSize: Theme.fontSizeSmall
					font.family: Theme.fontFamily
				}
				MouseArea {
					id: clearAllArea

					anchors.fill: parent
					hoverEnabled: true

					onClicked: Notification.dismissAll()
				}
			}
		}

		// DnD switch pinned under the header
		Row {
			id: dndRow

			width: parent.width
			spacing: Theme.spacingSmall

			Text {
				id: dndLabel

				text: "Do Not Disturb"
				color: Notification.dndEnabled ? Theme.foregroundColor : Theme.mutedColor
				font.pixelSize: Theme.fontSizeSmall
				font.family: Theme.fontFamily
				anchors.verticalCenter: parent.verticalCenter
			}
			Item {
				width: parent.width - dndLabel.width - dndSwitch.width - parent.spacing
				height: 1
			}
			ToggleSwitch {
				id: dndSwitch

				checked: Notification.dndEnabled
				anchors.verticalCenter: parent.verticalCenter

				onToggled: Notification.toggleDnd()
			}
		}

		// Notifications list — stacked cards, ListView for delegate reuse
		ListView {
			id: notificationList

			width: parent.width
			height: Math.min(contentHeight, Math.max(0, root.maxPopupHeight - dndRow.height - headerRow.height - 48))
			visible: Notification.trackedList.length > 0
			clip: true
			spacing: Theme.spacingSmall
			model: Notification.trackedList

			delegate: Rectangle {
				id: notificationItem

				required property QuickshellNotifications.Notification modelData
				readonly property int itemPadding: Theme.paddingSmall
				readonly property int iconSize: Theme.iconSizeSmall * 1.5
				readonly property bool bodyExpanded: root._isExpanded(modelData.id)
				readonly property bool isCritical: modelData.urgency === QuickshellNotifications.NotificationUrgency.Critical

				width: ListView.view.width
				height: contentColumn.implicitHeight + itemPadding * 2
				radius: Theme.radiusInner
				// Critical: dangerSoft fill + dangerBorder ring; normal: hover accentSoft
				color: isCritical ? Theme.dangerSoft : (itemArea.containsMouse ? Theme.accentSoft : Qt.alpha(Theme.foregroundColor, 0.03))
				border.width: isCritical ? 1 : 0
				border.color: Theme.dangerBorder

				Behavior on color {
					ColorAnimation { duration: Theme.hoverDuration }
				}

				Row {
					id: contentColumn

					spacing: Theme.spacingSmall

					anchors {
						top: parent.top
						left: parent.left
						right: parent.right
						margins: notificationItem.itemPadding
					}
					Rectangle {
						id: iconContainer

						width: notificationItem.iconSize
						height: width
						radius: Theme.radiusSmall
						anchors.verticalCenter: parent.verticalCenter
						color: {
							if (notificationItem.modelData.urgency === QuickshellNotifications.NotificationUrgency.Critical)
								return Theme.dangerSoft;
							if (notificationItem.modelData.urgency === QuickshellNotifications.NotificationUrgency.Low)
								return Qt.alpha(Theme.mutedColor, 0.15);
							return Theme.accentSoft;
						}

						// Resolved icon (image > appIcon > desktopEntry)
						Image {
							anchors.fill: parent
							anchors.margins: Theme.paddingSmall
							fillMode: Image.PreserveAspectFit
							sourceSize.width: notificationItem.iconSize
							sourceSize.height: notificationItem.iconSize
							source: notificationItem.modelData.image || (notificationItem.modelData.appIcon && AppIcons.iconFromName(notificationItem.modelData.appIcon)) || (notificationItem.modelData.desktopEntry && AppIcons.iconForAppId(notificationItem.modelData.desktopEntry)) || ""
							visible: source !== ""
						}

						// Fallback bell icon
						SvgIcon {
							anchors.centerIn: parent
							source: "icons/outline/bell.svg"
							iconSize: Theme.iconSizeSmall
							color: {
								if (notificationItem.modelData.urgency === QuickshellNotifications.NotificationUrgency.Critical)
									return Theme.errorColor;
								if (notificationItem.modelData.urgency === QuickshellNotifications.NotificationUrgency.Low)
									return Theme.mutedColor;
								return Theme.accentColor;
							}
							visible: !notificationItem.modelData.image && !notificationItem.modelData.appIcon && !notificationItem.modelData.desktopEntry
						}
					}
					Column {
						anchors.verticalCenter: parent.verticalCenter
						width: parent.width - iconContainer.width - parent.spacing - dismissButton.width

						Text {
							id: titleText

							width: parent.width
							text: notificationItem.modelData.summary || "Notification"
							color: Theme.foregroundColor
							font.pixelSize: Theme.fontSizeSmall
							font.family: Theme.fontFamily
							font.weight: Font.Medium
							elide: Text.ElideRight
						}
						Text {
							id: bodyText

							width: parent.width
							text: notificationItem.modelData.body || ""
							textFormat: Text.StyledText
							color: Theme.mutedColor
							font.pixelSize: Theme.fontSizeSmall
							font.family: Theme.fontFamily
							elide: Text.ElideRight
							maximumLineCount: notificationItem.bodyExpanded ? undefined : 3
							wrapMode: Text.WordWrap
							visible: text.length > 0
						}
						MouseArea {
							visible: bodyText.visible && (bodyText.truncated || notificationItem.bodyExpanded)
							width: row.implicitWidth
							height: row.implicitHeight
							cursorShape: Qt.PointingHandCursor

							onClicked: root._setExpanded(notificationItem.modelData.id, !notificationItem.bodyExpanded)

							Row {
								id: row
								spacing: 4

								SvgIcon {
									source: notificationItem.bodyExpanded ? "icons/outline/chevron-up.svg" : "icons/outline/chevron-down.svg"
									color: Theme.accentColor
									iconSize: Theme.fontSizeSmall - 1
									anchors.verticalCenter: parent.verticalCenter
								}
								Text {
									text: notificationItem.bodyExpanded ? "show less" : "show more"
									color: Theme.accentColor
									font.pixelSize: Theme.fontSizeSmall - 1
									font.family: Theme.fontFamily
									anchors.verticalCenter: parent.verticalCenter
								}
							}
						}
					}
					MouseArea {
						id: dismissButton

						z: 1 // Need to above MouseArea for itemArea
						width: Theme.iconSizeSmall + Theme.paddingSmall
						height: width
						anchors.verticalCenter: parent.verticalCenter
						hoverEnabled: true

						onClicked: {
							Notification.dismiss(notificationItem.modelData);
						}

						Rectangle {
							anchors.fill: parent
							radius: Theme.radiusSmall
							color: dismissButton.containsMouse ? Qt.alpha(Theme.errorColor, 0.2) : "transparent"
						}
						SvgIcon {
							anchors.centerIn: parent
							source: "icons/outline/x.svg"
							color: dismissButton.containsMouse ? Theme.errorColor : Theme.mutedColor
							iconSize: Theme.fontSizeSmall
						}
					}
				}
				MouseArea {
					id: itemArea

					z: -1 // Need to be below dismiss button to not block clicks
					anchors.fill: parent
					hoverEnabled: true

					onClicked: {
						Notification.dismiss(notificationItem.modelData);
					}
				}
			}
		}

		// Empty state
		Text {
			width: parent.width
			text: "No notifications"
			color: Theme.mutedColor
			font.pixelSize: Theme.fontSizeSmall
			font.family: Theme.fontFamily
			horizontalAlignment: Text.AlignHCenter
			visible: Notification.trackedList.length === 0
			topPadding: Theme.paddingNormal
		}
	}
}
