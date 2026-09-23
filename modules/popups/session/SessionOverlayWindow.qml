pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Wayland
import "../../../config"
import "../../../services/ui"

PanelWindow {
	id: overlay

	required property string screenName

	anchors {
		top: true
		left: true
		right: true
		bottom: true
	}

	color: Qt.alpha(Theme.backgroundColor, ShellConfig.overlayOpacity)

	visible: false

	WlrLayershell.layer: WlrLayer.Overlay
	WlrLayershell.keyboardFocus: overlay.visible ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
	WlrLayershell.namespace: "qs-session-" + overlay.screenName
	WlrLayershell.exclusionMode: ExclusionMode.Ignore

	// Scrim: close on click outside the card, consume clicks inside
	MouseArea {
		anchors.fill: parent
		onClicked: ShellUI.closeSession()
	}

	Item {
		id: sessionView

		anchors.centerIn: parent
		width: sessionMenu.implicitWidth
		height: sessionMenu.implicitHeight + hintRow.height + Theme.spacingNormal
		focus: true

		Keys.onEscapePressed: ShellUI.closeSession()

		SessionMenu {
			id: sessionMenu

			anchors.centerIn: parent
			width: implicitWidth
			height: implicitHeight

			screenName: overlay.screenName
		}

		// Hint line below the card, launcher-style
		Row {
			id: hintRow

			anchors {
				top: sessionMenu.bottom
				topMargin: Theme.spacingNormal
				horizontalCenter: parent.horizontalCenter
			}
			spacing: Theme.spacingLarge

			Text {
				text: "esc close"
				color: Qt.alpha(Theme.mutedColor, 0.7)
				font.pixelSize: Theme.fontSizeSmall - 2
				font.family: Theme.fontFamilyMono
			}
		}
	}
}
