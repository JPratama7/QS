pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Wayland
import "../../config"
import "../../services/launcher"
import "../search"

PanelWindow {
	id: overlay

	required property string screenName

	function reset(): void {
		launcherView.reset();
	}

	anchors {
		top: true
		left: true
		right: true
		bottom: true
	}

	color: Qt.alpha(Theme.backgroundColor, 0.85)

	visible: false

	WlrLayershell.layer: WlrLayer.Overlay
	WlrLayershell.keyboardFocus: overlay.visible ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
	WlrLayershell.namespace: "qs-launcher-" + overlay.screenName
	WlrLayershell.exclusionMode: ExclusionMode.Ignore

	// Scrim: close on click outside the launcher view, consume clicks inside
	// so padding around the search field doesn't dismiss the launcher.
	MouseArea {
		anchors.fill: parent
		onClicked: (mouse) => {
			const viewRect = mapFromItem(launcherView, 0, 0);
			const outside = (mouse.x < viewRect.x || mouse.x > viewRect.x + launcherView.width ||
					mouse.y < viewRect.y || mouse.y > viewRect.y + launcherView.height);
			if (outside)
				Launcher.close();
			mouse.accepted = true;
		}
	}

	// Centered launcher view
	SearchView {
		id: launcherView
		anchors.centerIn: parent
		width: Defaults.launcherWidth
		height: Math.min(implicitHeight, parent.height - Defaults.launcherVerticalMargin)
		searchService: Launcher
		resultDelegate: launcherResultDelegate
		placeholderText: "Search applications..."
		resultsHeight: Defaults.launcherResultsHeight
		emptyQueryHint: "Start typing to search"
		reserveEmptySpace: true
	}

	Component {
		id: launcherResultDelegate

		Rectangle {
			id: resultRow

			required property var modelData
			required property int index

			width: parent.width
			height: rowContent.implicitHeight + Theme.paddingSmall * 2
			radius: Theme.radiusSmall
			color: "transparent"

			Row {
				id: rowContent

				spacing: Theme.spacingSmall

				anchors {
					verticalCenter: parent.verticalCenter
					left: parent.left
					leftMargin: Theme.paddingSmall
				}
				Image {
					width: Theme.iconSizeSmall
					height: Theme.iconSizeSmall
					fillMode: Image.PreserveAspectFit
					sourceSize.width: Theme.iconSizeSmall
					sourceSize.height: Theme.iconSizeSmall
					source: AppIcons.iconFromName(resultRow.modelData.icon)
				}
				Column {
					anchors.verticalCenter: parent.verticalCenter
					spacing: 2

					Text {
						text: resultRow.modelData.title
						color: Theme.foregroundColor
						font.pixelSize: Theme.fontSizeSmall
						font.family: Theme.fontFamily
					}
					Text {
						text: resultRow.modelData.subtitle
						color: Theme.mutedColor
						font.pixelSize: Theme.fontSizeSmall - 1
						font.family: Theme.fontFamily
						visible: text !== ""
					}
				}
			}
			MouseArea {
				anchors.fill: parent
				hoverEnabled: true

				onEntered: Launcher.selectedIndex = resultRow.index
				onClicked: Launcher.activateSelected()
			}
		}
	}
}
