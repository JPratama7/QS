pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import "../../../components"
import "../../../config"

// Shared back-navigation header for menu subpages.
// When showWhenSubmenu is set it hides on root pages (height collapses to 0)
// so page layout can anchor below it unconditionally.
Item {
	id: root

	// Only show the header on submenu pages (stackView.depth > 1)
	property bool showWhenSubmenu: false
	// The StackView to pop when the header is clicked
	property StackView stackView: null

	readonly property bool isSubmenu: root.stackView ? root.stackView.depth > 1 : false
	// Height contribution including the spacing the pages apply below the header
	readonly property real headerHeight: root.visible ? root.height + Theme.spacingSmall : 0

	visible: !root.showWhenSubmenu || root.isSubmenu
	height: visible ? backRow.implicitHeight + Theme.paddingSmall * 2 : 0

	anchors {
		top: parent.top
		left: parent.left
		right: parent.right
		topMargin: Theme.paddingNormal
		leftMargin: Theme.paddingNormal
		rightMargin: Theme.paddingNormal
	}

	Rectangle {
		id: backButton

		anchors.fill: parent
		radius: Theme.radiusSmall
		color: backArea.containsMouse ? Qt.alpha(Theme.accentColor, 0.15) : "transparent"

		Row {
			id: backRow

			spacing: Theme.spacingSmall

			anchors {
				verticalCenter: parent.verticalCenter
				left: parent.left
				leftMargin: Theme.paddingSmall
			}
			SvgIcon {
				source: "icons/outline/chevron-left.svg"
				color: Theme.accentColor
				iconSize: Theme.fontSizeSmall
				anchors.verticalCenter: parent.verticalCenter
			}
			Text {
				text: "Back"
				color: Theme.accentColor
				font.pixelSize: Theme.fontSizeSmall
				font.family: Theme.fontFamily
				anchors.verticalCenter: parent.verticalCenter
			}
		}
		MouseArea {
			id: backArea

			anchors.fill: parent
			hoverEnabled: true

			onClicked: {
				if (root.stackView)
					root.stackView.pop();
			}
		}
	}
}
