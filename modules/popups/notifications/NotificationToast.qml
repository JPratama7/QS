pragma ComponentBehavior: Bound

import QtQuick
import Quickshell.Services.Notifications as QuickshellNotification
import Quickshell.Widgets
import "../../../components"
import "../../../config"
import "../../../services/system"

Item {
	id: toast

	required property QuickshellNotification.Notification notification
	readonly property int cardPadding: Theme.paddingNormal
	readonly property int iconSize: Theme.iconSizeSmall * 2
	property bool bodyExpanded: false

	// Single resolved icon string used by both IconImage and fallback Text
	readonly property string resolvedIcon: toast.notification.image || (toast.notification.appIcon && AppIcons.iconFromName(toast.notification.appIcon)) || (toast.notification.desktopEntry && AppIcons.iconForAppId(toast.notification.desktopEntry)) || ""

	signal dismissed

	implicitWidth: parent.width
	implicitHeight: cardContent.implicitHeight + cardPadding * 2

	Rectangle {
		id: card

		anchors.fill: parent
		color: Theme.surfaceColor
		radius: Theme.radiusNormal
		border.width: 1
		border.color: toast.notification.urgency === QuickshellNotification.NotificationUrgency.Critical ? Qt.alpha(Theme.errorColor, 0.3) : Qt.alpha(Theme.foregroundColor, 0.1)
	}
	Row {
		id: cardContent

		spacing: Theme.spacingNormal

		anchors {
			top: parent.top
			left: parent.left
			right: parent.right
			margins: toast.cardPadding
		}
		Rectangle {
			id: iconContainer

			width: toast.iconSize
			height: toast.iconSize
			radius: Theme.radiusSmall
			anchors.verticalCenter: parent.verticalCenter
			color: {
				if (toast.notification.urgency === QuickshellNotification.NotificationUrgency.Critical)
					return Qt.alpha(Theme.errorColor, 0.2);
				if (toast.notification.urgency === QuickshellNotification.NotificationUrgency.Low)
					return Qt.alpha(Theme.mutedColor, 0.15);
				return Qt.alpha(Theme.accentColor, 0.2);
			}

			// Resolved icon (image > appIcon > desktopEntry)
			Image {
				anchors.fill: parent
				anchors.margins: Theme.paddingSmall
				fillMode: Image.PreserveAspectFit
				sourceSize.width: toast.iconSize
				sourceSize.height: toast.iconSize
				source: toast.resolvedIcon
				visible: toast.resolvedIcon !== ""
			}

			// Fallback bell icon
			SvgIcon {
				anchors.centerIn: parent
				source: "icons/outline/bell.svg"
				iconSize: Theme.iconSizeSmall
				color: {
					if (toast.notification.urgency === QuickshellNotification.NotificationUrgency.Critical)
						return Theme.errorColor;
					if (toast.notification.urgency === QuickshellNotification.NotificationUrgency.Low)
						return Theme.mutedColor;
					return Theme.accentColor;
				}
				visible: toast.resolvedIcon === ""
			}
		}
		Column {
			id: textColumn

			anchors.verticalCenter: parent.verticalCenter
			width: parent.width - iconContainer.width - parent.spacing - dismissButton.width - parent.spacing

			Text {
				id: titleText

				width: parent.width
				text: toast.notification.summary || "Notification"
				color: Theme.foregroundColor
				font.pixelSize: Theme.fontSizeNormal
				font.family: Theme.fontFamily
				font.weight: Font.Medium
				elide: Text.ElideRight
			}
			Text {
				id: bodyText

				width: parent.width
				text: toast.notification.body || ""
				textFormat: Text.StyledText
				color: Theme.mutedColor
				font.pixelSize: Theme.fontSizeSmall
				font.family: Theme.fontFamily
				elide: Text.ElideRight
				maximumLineCount: toast.bodyExpanded ? undefined : 2
				wrapMode: Text.WordWrap
				visible: text.length > 0
			}
			Item {
				id: expandIndicator

				visible: bodyText.visible && (bodyText.truncated || toast.bodyExpanded)
				implicitWidth: rowContent.implicitWidth
				implicitHeight: rowContent.implicitHeight

				Row {
					id: rowContent

					spacing: 4

					SvgIcon {
						source: toast.bodyExpanded ? "icons/outline/chevron-up.svg" : "icons/outline/chevron-down.svg"
						color: Theme.accentColor
						iconSize: Theme.fontSizeSmall - 1
						anchors.verticalCenter: parent.verticalCenter
					}
					Text {
						text: toast.bodyExpanded ? "show less" : "show more"
						color: Theme.accentColor
						font.pixelSize: Theme.fontSizeSmall - 1
						font.family: Theme.fontFamily
						anchors.verticalCenter: parent.verticalCenter
					}
				}
				MouseArea {
					anchors.fill: parent
					cursorShape: Qt.PointingHandCursor

					onClicked: toast.bodyExpanded = !toast.bodyExpanded
				}
			}
		}
		MouseArea {
			id: dismissButton

			width: Theme.iconSizeSmall + Theme.paddingSmall
			height: width
			anchors.verticalCenter: parent.verticalCenter
			hoverEnabled: true

			onClicked: toast.dismissed()

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
		z: -1
		anchors.fill: parent

		onClicked: toast.dismissed()
	}
}
