pragma ComponentBehavior: Bound

import QtQuick
import "../../config"
import "../../services/launcher"

Item {
	id: view

	implicitWidth: column.implicitWidth
	implicitHeight: column.implicitHeight + Theme.paddingNormal * 2

	focus: true

	Keys.onUpPressed: Launcher.selectPrev()
	Keys.onDownPressed: Launcher.selectNext()
	Keys.onReturnPressed: Launcher.activateSelected()
	Keys.onEscapePressed: Launcher.close()

	function reset(): void {
		searchField.clear();
		searchField.focusInput();
	}

	Rectangle {
		z: -1
		anchors.fill: parent
		color: Theme.surfaceColor
		radius: Theme.radiusNormal
		border.width: 1
		border.color: Qt.alpha(Theme.foregroundColor, 0.1)
	}

	Column {
		id: column

		anchors {
			top: parent.top
			left: parent.left
			right: parent.right
			margins: Theme.paddingNormal
		}
		spacing: Theme.spacingNormal

		LauncherSearchField {
			id: searchField
			width: parent.width
		}

		LauncherResultsList {
			width: parent.width
			height: Math.min(implicitHeight, Defaults.launcherResultsHeight)
		}
	}
}
