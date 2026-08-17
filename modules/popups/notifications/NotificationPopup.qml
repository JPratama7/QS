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
	readonly property int popupWidth: 280
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
	Rectangle {
		anchors.fill: parent
		color: Theme.surfaceColor
		radius: Theme.radiusNormal
		border.width: 1
		border.color: Qt.alpha(Theme.foregroundColor, 0.1)
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

		// Header
		Text {
			width: parent.width
			text: "Notifications"
			color: Theme.foregroundColor
			font.pixelSize: Theme.fontSizeNormal
			font.family: Theme.fontFamily
			font.weight: Font.Medium
		}

		// DnD toggle
		Button {
			id: dndButton

			width: parent.width
			height: dndText.implicitHeight + Theme.paddingSmall * 2

			Rectangle {
				anchors.fill: parent
				radius: Theme.radiusSmall
				color: dndArea.containsMouse ? Qt.alpha(Theme.accentColor, 0.15) : "transparent"
			}
			Text {
				id: dndText

				anchors.centerIn: parent
				text: Notification.dndEnabled ? "Do Not Disturb: ON" : "Do Not Disturb: OFF"
				color: Notification.dndEnabled ? Theme.accentColor : Theme.mutedColor
				font.pixelSize: Theme.fontSizeSmall
				font.family: Theme.fontFamily
			}
			MouseArea {
				id: dndArea

				anchors.fill: parent
				hoverEnabled: true

				onClicked: Notification.toggleDnd()
			}
		}

		// Clear all button (only show if there are notifications)
		Button {
			id: clearAllButton

			width: parent.width
			height: clearAllText.implicitHeight + Theme.paddingSmall * 2
			visible: Notification.trackedList.length > 0

			Rectangle {
				anchors.fill: parent
				radius: Theme.radiusSmall
				color: clearAllArea.containsMouse ? Qt.alpha(Theme.errorColor, 0.15) : "transparent"
			}
			Text {
				id: clearAllText

				anchors.centerIn: parent
				text: "Clear All"
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

		// Notifications list — ListView for delegate reuse (virtualization)
		ListView {
			id: notificationList

			width: parent.width
			height: Math.min(contentHeight, Math.max(0, root.maxPopupHeight - dndButton.height - clearAllButton.height - 30 - Theme.paddingNormal * 4))
			visible: Notification.trackedList.length > 0
			clip: true
			spacing: Theme.spacingSmall
			reuseItems: true
			cacheBuffer: 100
			model: Notification.trackedList

			delegate: Item {
				id: notificationItem

				required property QuickshellNotifications.Notification modelData
				readonly property int itemPadding: Theme.paddingSmall
				readonly property int iconSize: Theme.iconSizeSmall * 1.5
				readonly property bool bodyExpanded: root._isExpanded(modelData.id)

				width: ListView.view.width
				implicitHeight: contentColumn.implicitHeight + itemPadding * 2

				Rectangle {
					anchors.fill: parent
					radius: Theme.radiusSmall
					color: itemArea.containsMouse ? Qt.alpha(Theme.foregroundColor, 0.05) : "transparent"
					border.width: notificationItem.modelData.urgency === QuickshellNotifications.NotificationUrgency.Critical ? 1 : 0
					border.color: Qt.alpha(Theme.errorColor, 0.3)
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
								return Qt.alpha(Theme.errorColor, 0.2);
							if (notificationItem.modelData.urgency === QuickshellNotifications.NotificationUrgency.Low)
								return Qt.alpha(Theme.mutedColor, 0.15);
							return Qt.alpha(Theme.accentColor, 0.2);
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
