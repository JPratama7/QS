pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Wayland
import "../../config"
import "../../services/ui"

PanelWindow {
	id: overlay

	required property string screenName

	// `shown` is the visual state the transition binds to. The window's `visible`
	// stays true during the close animation so the exit can render; `shown` flips
	// false to drive the exit, and the loader is torn down only after `closeFinished`.
	property bool shown: false
	property bool closing: false

	signal closeFinished

	function reset(): void {
		settingsView.reset();
	}

	// Play the exit transition, then emit `closeFinished` so the owner can drop the loader.
	function closeAnimated(): void {
		if (overlay.closing)
			return;
		overlay.closing = true;
		overlay.shown = false;
		closeTimer.restart();
	}

	// Cancel an in-progress close when settings is re-opened mid-transition.
	function abortClose(): void {
		closeTimer.stop();
		overlay.closing = false;
		overlay.shown = true;
	}

	visible: false
	color: overlay.shown ? Qt.alpha(Theme.backgroundColor, 0.85) : Qt.rgba(0, 0, 0, 0)
	Behavior on color {
		ColorAnimation {
			duration: 220
			easing.type: Easing.OutCubic
		}
	}

	WlrLayershell.layer: WlrLayer.Overlay
	WlrLayershell.keyboardFocus: overlay.visible ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
	WlrLayershell.namespace: "qs-settings-" + overlay.screenName
	WlrLayershell.exclusionMode: ExclusionMode.Ignore

	anchors {
		top: true
		left: true
		right: true
		bottom: true
	}

	onVisibleChanged: {
		// Window just became visible -> play the open animation.
		if (overlay.visible && !overlay.closing)
			overlay.shown = true;
	}

	Timer {
		id: closeTimer

		interval: 220
		repeat: false

		onTriggered: overlay.closeFinished()
	}

	// Click-outside-to-close
	MouseArea {
		anchors.fill: parent
		propagateComposedEvents: true

		onClicked: mouse => {
			const viewRect = mapFromItem(settingsView, 0, 0);
			const outside = (mouse.x < viewRect.x || mouse.x > viewRect.x + settingsView.width || mouse.y < viewRect.y || mouse.y > viewRect.y + settingsView.height);
			if (outside) {
				ShellUI.closeSettings();
				mouse.accepted = false; // Pass through to underlying window
			} else {
				mouse.accepted = true; // Consume clicks inside
			}
		}
	}

	// Centered view
	SettingsView {
		id: settingsView

		anchors.centerIn: parent
		width: 600
		height: Math.min(implicitHeight, parent.height - 100)

		// Open: opacity 0->1, scale 0.96->1.0. Close reverses via `shown`.
		opacity: overlay.shown ? 1 : 0
		scale: overlay.shown ? 1 : 0.96
		transformOrigin: Item.Center

		Behavior on opacity {
			NumberAnimation {
				duration: 220
				easing.type: Easing.OutCubic
			}
		}
		Behavior on scale {
			NumberAnimation {
				duration: 220
				easing.type: Easing.OutCubic
			}
		}
	}
}
