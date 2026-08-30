pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Wayland
import "../../config"
import "../../services/launcher"

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
	LauncherView {
		id: launcherView
		anchors.centerIn: parent
		width: Defaults.launcherWidth
		height: Math.min(implicitHeight, parent.height - Defaults.launcherVerticalMargin)
	}
}
