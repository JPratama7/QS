pragma ComponentBehavior: Bound

import QtQuick
import "../../components"
import "../../services/ui"
import "../../types"
import "../bar"
import "../cliphist"
import "../emoji"
import "../launcher"
import "../popups/notifications"
import "../popups/session"
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
	OverlayHost {
		kind: "launcher"
		screenName: delegate.context.name
		sourceComponent: launcherWindow
		resetOnOpen: true
	}
	OverlayHost {
		kind: "session"
		screenName: delegate.context.name
		sourceComponent: sessionWindow
	}
	OverlayHost {
		kind: "cliphist"
		screenName: delegate.context.name
		sourceComponent: cliphistWindow
		resetOnOpen: true
		animateClose: true
	}
	OverlayHost {
		kind: "emoji"
		screenName: delegate.context.name
		sourceComponent: emojiWindow
		resetOnOpen: true
	}
	OverlayHost {
		kind: "settings"
		screenName: delegate.context.name
		sourceComponent: settingsWindow
		resetOnOpen: true
		animateClose: true
	}

	Component {
		id: launcherWindow

		LauncherOverlayWindow {
			screenName: delegate.context.name
		}
	}
	Component {
		id: sessionWindow

		SessionOverlayWindow {
			screenName: delegate.context.name
		}
	}
	Component {
		id: cliphistWindow

		CliphistOverlayWindow {
			screenName: delegate.context.name
		}
	}
	Component {
		id: emojiWindow

		EmojiOverlayWindow {
			screenName: delegate.context.name
		}
	}
	Component {
		id: settingsWindow

		SettingsOverlayWindow {
			screenName: delegate.context.name
		}
	}
}
