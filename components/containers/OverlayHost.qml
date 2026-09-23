pragma ComponentBehavior: Bound

import QtQuick
import "../../services/ui"

// Reusable fullscreen-overlay host. Loads a window when ShellUI opens the
// matching kind on this screen, unloads on close. Handles both instant close
// (launcher, emoji, session) and animated close (cliphist, settings) styles.
Item {
	id: root

	required property string kind
	required property string screenName
	required property Component sourceComponent

	// Call item.reset() on load (search field, scroll position, etc.)
	property bool resetOnOpen: false

	// Use closeAnimated() and wait for closeFinished instead of unloading instantly
	property bool animateClose: false

	Loader {
		id: overlayLoader

		active: false
		asynchronous: true
		sourceComponent: root.sourceComponent

		onLoaded: {
			item.visible = true;
			if (root.resetOnOpen && item.reset)
				item.reset();
			// Animated close completion — window reports back, then unload
			if (root.animateClose)
				item.closeFinished.connect(() => overlayLoader.active = false);
		}
	}

	Connections {
		function onOverlayOpened(openedKind: string, openedScreen: string): void {
			if (openedKind !== root.kind || openedScreen !== root.screenName)
				return;
			if (overlayLoader.item && overlayLoader.item.closing) {
				// Re-opened mid-close: cancel the exit animation and settle back.
				overlayLoader.item.abortClose();
			} else {
				overlayLoader.active = true;
			}
		}
		function onOverlayClosed(closedKind: string): void {
			if (closedKind !== root.kind)
				return;
			if (overlayLoader.item && overlayLoader.item.closing)
				return;
			if (root.animateClose && overlayLoader.item)
				overlayLoader.item.closeAnimated();
			else
				overlayLoader.active = false;
		}

		target: ShellUI
	}
}
