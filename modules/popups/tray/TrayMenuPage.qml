pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import Quickshell
import "../../../config"
import "../../../services/ui"
import "../shared"
import "."

Item {
	id: page

	required property string screenName
	required property var menuHandle
	required property StackView stackView
	readonly property int maxMenuHeight: PersistentConfig.adapter.trayMenuMaxHeight
	readonly property int headerHeight: backHeader.headerHeight
	readonly property int contentHeight: pageColumn.implicitHeight + Theme.paddingNormal * 2
	readonly property int totalHeight: headerHeight + contentHeight

	implicitWidth: width
	implicitHeight: Math.min(totalHeight, headerHeight + maxMenuHeight)

	QsMenuOpener {
		id: opener

		menu: page.menuHandle
	}

	BackHeader {
		id: backHeader

		stackView: page.stackView
		showWhenSubmenu: true
	}
	ScrollView {
		contentHeight: pageColumn.implicitHeight + Theme.paddingNormal
		clip: true
		ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
		ScrollBar.vertical.policy: ScrollBar.AsNeeded

		anchors {
			top: backHeader.bottom
			left: parent.left
			right: parent.right
			bottom: parent.bottom
			topMargin: backHeader.visible ? Theme.spacingSmall : Theme.paddingNormal
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
