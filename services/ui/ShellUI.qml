pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell

Singleton {
	id: root

	// Tracks which screens have an open popup — read by openPopup/closePopup/isPopupOpen/onScreensChanged
	property var _openScreens: ({})

	// Launcher open state (screen name of the screen showing the launcher, or "")
	property string _launcherScreen: ""

	// Cliphist open state (screen name of the screen showing cliphist, or "")
	property string _cliphistScreen: ""

	// Settings open state
	property string _settingsScreen: ""

	// Emoji picker open state
	property string _emojiScreen: ""

	// Session overlay open state
	property string _sessionScreen: ""

	// Track known screens for removal detection
	property var _knownScreenNames: ([])

	// Emitted when a widget requests a popup — carries the component to render and anchor X
	signal popupRequested(screenName: string, popupId: string, component: var, anchorX: int)

	// Emitted when a popup should close
	signal popupClosed(screenName: string)

	// Emitted when a fullscreen overlay opens/closes on a screen
	signal overlayOpened(kind: string, screenName: string)
	signal overlayClosed(kind: string)

	// Open a named popup on a screen with the component to render and optional anchor X position
	function openPopup(screenName: string, popupId: string, component: var, anchorX: int): void {
		// Close launcher and cliphist if open on any screen
		if (root._launcherScreen !== "") {
			root.closeLauncher();
		}
		if (root._cliphistScreen !== "") {
			root.closeCliphist();
		}
		if (root._settingsScreen !== "") {
			root.closeSettings();
		}
		if (root._emojiScreen !== "") {
			root.closeEmoji();
		}
		if (root._sessionScreen !== "") {
			root.closeSession();
		}
		root._openScreens[screenName] = popupId;
		root.popupRequested(screenName, popupId, component, anchorX);
	}

	// Close the active popup on a screen
	function closePopup(screenName: string): void {
		if (!root._openScreens[screenName])
			return;
		delete root._openScreens[screenName];
		root.popupClosed(screenName);
	}

	// Check whether a specific popup is open on a screen
	function isPopupOpen(screenName: string, popupId: string): bool {
		return root._openScreens[screenName] === popupId;
	}

	// Shared opener for the four overlays. Overlays are mutually exclusive:
	// opening one closes the other three, plus this kind if it was open on
	// another screen. Preserves the original close-guard asymmetry —
	// launcher/cliphist close unconditionally, settings/emoji only when open.
	function _openOverlay(kind: string, screenName: string): void {
		if (root["_" + kind + "Screen"] === screenName) {
			return;
		}
		if (kind !== "launcher" && root._launcherScreen !== "") {
			root.closeLauncher();
		}
		if (kind !== "cliphist" && root._cliphistScreen !== "") {
			root.closeCliphist();
		}
		if (kind !== "settings" && root._settingsScreen !== "") {
			root.closeSettings();
		}
		if (kind !== "emoji" && root._emojiScreen !== "") {
			root.closeEmoji();
		}
		if (kind !== "session" && root._sessionScreen !== "") {
			root.closeSession();
		}
		const closeSelf = kind === "launcher" ? root.closeLauncher
			: kind === "cliphist" ? root.closeCliphist
			: kind === "settings" ? root.closeSettings
			: kind === "emoji" ? root.closeEmoji
			: root.closeSession;
		if (root["_" + kind + "Screen"] !== "") {
			closeSelf();
		}
		root["_" + kind + "Screen"] = screenName;
		root.overlayOpened(kind, screenName);
	}

	// Launcher open/close
	function openLauncher(screenName: string): void {
		root._openOverlay("launcher", screenName);
	}
	function closeLauncher(): void {
		root._launcherScreen = "";
		root.overlayClosed("launcher");
	}
	function isLauncherOpen(): bool {
		return root._launcherScreen !== "";
	}

	// Cliphist open/close
	function openCliphist(screenName: string): void {
		root._openOverlay("cliphist", screenName);
	}
	function closeCliphist(): void {
		root._cliphistScreen = "";
		root.overlayClosed("cliphist");
	}
	function isCliphistOpen(): bool {
		return root._cliphistScreen !== "";
	}

	// Settings open/close
	function openSettings(screenName: string): void {
		root._openOverlay("settings", screenName);
	}
	function closeSettings(): void {
		if (root._settingsScreen !== "") {
			root._settingsScreen = "";
			root.overlayClosed("settings");
		}
	}
	function isSettingsOpen(): bool {
		return root._settingsScreen !== "";
	}

	// Emoji picker open/close
	function openEmoji(screenName: string): void {
		root._openOverlay("emoji", screenName);
	}
	function closeEmoji(): void {
		if (root._emojiScreen !== "") {
			root._emojiScreen = "";
			root.overlayClosed("emoji");
		}
	}
	function isEmojiOpen(): bool {
		return root._emojiScreen !== "";
	}

	// Session overlay open/close
	function openSession(screenName: string): void {
		root._openOverlay("session", screenName);
	}
	function closeSession(): void {
		if (root._sessionScreen !== "") {
			root._sessionScreen = "";
			root.overlayClosed("session");
		}
	}
	function isSessionOpen(): bool {
		return root._sessionScreen !== "";
	}

	onOverlayClosed: gcTimer.restart()
	Component.onCompleted: {
		root._knownScreenNames = Quickshell.screens.map(s => s.name);
	}

	// Detect screen removal and clean up state
	Connections {
		function onScreensChanged(): void {
			const currentNames = Quickshell.screens.map(s => s.name);
			const removed = root._knownScreenNames.filter(name => !currentNames.includes(name));

			// Close popup/launcher on removed screens
			for (const name of removed) {
				if (root._openScreens[name]) {
					root.closePopup(name);
				}
				if (root._launcherScreen === name) {
					root.closeLauncher();
				}
				if (root._cliphistScreen === name) {
					root.closeCliphist();
				}
				if (root._settingsScreen === name) {
					root.closeSettings();
				}
				if (root._emojiScreen === name) {
					root.closeEmoji();
				}
				if (root._sessionScreen === name) {
					root.closeSession();
				}
			}

			root._knownScreenNames = currentNames;
		}

		target: Quickshell
	}
	Timer {
		id: gcTimer

		interval: 300
		repeat: false

		onTriggered: gc()
	}
}
