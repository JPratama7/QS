pragma ComponentBehavior: Bound

import QtQuick
import "../../services/ui"
import "../../types"
import "../bar"
import "../cliphist"
import "../emoji"
import "../launcher"
import "../popups/notifications"
import "../popups/shared"
import "../settings"

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
			onCloseFinished: cliphistLoader.active = false
		}

		onLoaded: {
			item.visible = true;
			item.reset();
		}

		Connections {
			function onCliphistOpened(screenName: string): void {
				if (screenName === delegate.context.name) {
					if (cliphistLoader.item && cliphistLoader.item.closing) {
						// Re-opened mid-close: cancel the exit animation and settle back.
						cliphistLoader.item.abortClose();
					} else {
						cliphistLoader.active = true;
					}
				}
			}
			function onCliphistClosed(): void {
				if (cliphistLoader.item)
					cliphistLoader.item.closeAnimated();
			}

			target: ShellUI
		}
	}

	Loader {
		id: emojiLoader

		active: false
		asynchronous: true

		sourceComponent: EmojiOverlayWindow {
			screenName: delegate.context.name
		}

		onLoaded: {
			item.visible = true;
			item.reset();
		}

		Connections {
			function onEmojiOpened(screenName: string): void {
				if (screenName === delegate.context.name) {
					emojiLoader.active = true;
				}
			}
			function onEmojiClosed(): void {
				if (emojiLoader.active) {
					emojiLoader.active = false;
				}
			}

			target: ShellUI
		}
	}

	Loader {
		id: settingsLoader

		active: false
		asynchronous: true

		sourceComponent: SettingsOverlayWindow {
			screenName: delegate.context.name
			onCloseFinished: settingsLoader.active = false
		}

		onLoaded: {
			item.visible = true;
			item.reset();
		}

		Connections {
			function onSettingsOpened(screenName: string): void {
				if (screenName === delegate.context.name) {
					if (settingsLoader.item && settingsLoader.item.closing) {
						// Re-opened mid-close: cancel the exit animation and settle back.
						settingsLoader.item.abortClose();
					} else {
						settingsLoader.active = true;
					}
				}
			}
			function onSettingsClosed(): void {
				if (settingsLoader.item)
					settingsLoader.item.closeAnimated();
			}

			target: ShellUI
		}
	}
}
