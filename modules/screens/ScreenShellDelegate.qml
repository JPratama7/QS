pragma ComponentBehavior: Bound

import QtQuick
import "../../services/ui"
import "../../types"
import "../bar"
import "../cliphist"
import "../launcher"
import "../popups/notifications"
import "../popups/shared"

Item {
	id: delegate

	required property ScreenContext context

	BarContentWindow {
		id: barWindow

		context: delegate.context
	}
	Loader {
		id: triggerZoneLoader

		active: delegate.context.barDisplayMode === "auto_hide"
		asynchronous: true

		sourceComponent: BarTriggerZone {
			context: delegate.context
		}
	}
	PopupMenuWindow {
		context: delegate.context
		barWindow: barWindow
	}
	Loader {
		id: toastWindowLoader

		active: delegate.context.isPrimary
		asynchronous: true

		sourceComponent: NotificationToastWindow {
			context: delegate.context
			barWindow: barWindow
		}
	}
	Loader {
		id: launcherLoader

		active: false
		asynchronous: true

		sourceComponent: LauncherOverlayWindow {
			screenName: delegate.context.name
		}

		onLoaded: {
			item.visible = true;
			item.reset();
		}

		Connections {
			function onLauncherOpened(screenName: string): void {
				if (screenName === delegate.context.name) {
					launcherLoader.active = true;
				}
			}
			function onLauncherClosed(): void {
				if (launcherLoader.active) {
					launcherLoader.active = false;
				}
			}

			target: ShellUI
		}
	}
	Loader {
		id: cliphistLoader

		active: false
		asynchronous: true

		sourceComponent: CliphistOverlayWindow {
			screenName: delegate.context.name
		}

		onLoaded: {
			item.visible = true;
			item.reset();
		}

		Connections {
			function onCliphistOpened(screenName: string): void {
				if (screenName === delegate.context.name) {
					cliphistLoader.active = true;
				}
			}
			function onCliphistClosed(): void {
				if (cliphistLoader.active) {
					cliphistLoader.active = false;
				}
			}

			target: ShellUI
		}
	}
}
