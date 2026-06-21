pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell.DBusMenu
import "../../../components"
import "../../../config"

Item {
	id: root

	required property DBusMenuItem entry
	readonly property bool isSeparator: root.entry?.isSeparator ?? false

	signal triggered(entry: DBusMenuItem)
	signal submenuRequested(entry: DBusMenuItem)

	implicitWidth: row.implicitWidth + Theme.paddingNormal * 2
	implicitHeight: isSeparator ? 9 : row.implicitHeight + Theme.paddingSmall * 2

	// Separator
	Rectangle {
		visible: root.isSeparator
		height: 1
		color: Theme.mutedColor
		opacity: 0.4

		anchors {
			left: parent.left
			right: parent.right
			verticalCenter: parent.verticalCenter
			leftMargin: Theme.paddingNormal
			rightMargin: Theme.paddingNormal
		}
	}

	// Normal item
	Rectangle {
		id: bg

		visible: !root.isSeparator
		anchors.fill: parent
		radius: Theme.radiusSmall
		color: Theme.accentColor
		opacity: hoverArea.containsMouse && root.entry?.enabled ? 0.15 : 0

		Behavior on opacity {
			NumberAnimation {
				duration: 100
			}
		}
	}
	RowLayout {
		id: row

		visible: !root.isSeparator
		spacing: Theme.spacingSmall

		anchors {
			left: parent.left
			right: parent.right
			verticalCenter: parent.verticalCenter
			leftMargin: Theme.paddingNormal
			rightMargin: Theme.paddingNormal
		}
		Image {
			visible: source !== ""
			source: root.entry?.icon ?? ""
			sourceSize.width: Theme.iconSizeSmall
			sourceSize.height: Theme.iconSizeSmall
			Layout.preferredWidth: Theme.iconSizeSmall
			Layout.preferredHeight: Theme.iconSizeSmall
		}
		Text {
			text: root.entry?.text ?? ""
			color: root.entry?.enabled ? Theme.foregroundColor : Theme.mutedColor
			font.pixelSize: Theme.fontSizeSmall
			font.family: Theme.fontFamily
			Layout.fillWidth: true
			elide: Text.ElideRight
		}
		SvgIcon {
			visible: root.entry?.hasChildren ?? false
			source: "icons/outline/chevron-right.svg"
			color: Theme.mutedColor
			iconSize: Theme.fontSizeSmall
		}
	}
	MouseArea {
		id: hoverArea

		anchors.fill: parent
		hoverEnabled: true
		enabled: !root.isSeparator && (root.entry?.enabled ?? false)

		onClicked: {
			if (!root.entry)
				return;
			if (root.entry.hasChildren)
				root.submenuRequested(root.entry);
			else
				root.triggered(root.entry);
		}
	}
}
