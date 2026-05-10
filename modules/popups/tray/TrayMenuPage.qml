pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import Quickshell
import "../../../config"
import "../../../services/ui"
import "."

Item {
	id: page

	required property string screenName
	required property var menuHandle
	required property StackView stackView
	readonly property bool isSubmenu: page.stackView.depth > 1
	readonly property int maxMenuHeight: ShellConfig.trayMenuMaxHeight
	readonly property int headerHeight: isSubmenu ? backButton.height + Theme.spacingSmall : 0
	readonly property int contentHeight: pageColumn.implicitHeight + Theme.paddingNormal * 2
	readonly property int totalHeight: headerHeight + contentHeight

	implicitWidth: width
	implicitHeight: Math.min(totalHeight, headerHeight + maxMenuHeight)

	QsMenuOpener {
		id: opener

		menu: page.menuHandle
	}

	// Back button — only shown for submenu pages
	Rectangle {
		id: backButton

		visible: page.isSubmenu
		height: visible ? backRow.implicitHeight + Theme.paddingSmall * 2 : 0
		radius: Theme.radiusSmall
		color: backArea.containsMouse ? Qt.alpha(Theme.accentColor, 0.15) : "transparent"

		anchors {
			top: parent.top
			left: parent.left
			right: parent.right
			topMargin: Theme.paddingNormal
			leftMargin: Theme.paddingNormal
			rightMargin: Theme.paddingNormal
		}
		Row {
			id: backRow

			spacing: Theme.spacingSmall

			anchors {
				verticalCenter: parent.verticalCenter
				left: parent.left
				leftMargin: Theme.paddingSmall
			}
			Text {
				text: "‹"
				color: Theme.accentColor
				font.pixelSize: Theme.fontSizeSmall
				font.family: Theme.fontFamily
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

			onClicked: page.stackView.pop()
		}
	}
	ScrollView {
		contentHeight: pageColumn.implicitHeight + Theme.paddingNormal
		clip: true
		ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
		ScrollBar.vertical.policy: ScrollBar.AsNeeded

		anchors {
			top: page.isSubmenu ? backButton.bottom : parent.top
			left: parent.left
			right: parent.right
			bottom: parent.bottom
			topMargin: page.isSubmenu ? Theme.spacingSmall : Theme.paddingNormal
		}
		Column {
			id: pageColumn

			spacing: 2

			anchors {
				left: parent.left
				right: parent.right
				leftMargin: Theme.paddingNormal
				rightMargin: Theme.paddingNormal
			}
			Repeater {
				model: opener.children

				delegate: TrayMenuItem {
					required property var modelData

					entry: modelData
					width: page.width - Theme.paddingNormal * 2

					onTriggered: entry => {
						ShellUI.closePopup(page.screenName);
						Qt.callLater(() => entry.triggered());
					}
					onSubmenuRequested: entry => {
						page.stackView.push(Qt.resolvedUrl("TrayMenuPage.qml"), {
							menuHandle: entry,
							stackView: page.stackView,
							screenName: page.screenName,
							width: page.width
						});
					}
				}
			}
		}
	}
}
