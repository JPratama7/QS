pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell

Singleton {
	id: root

	// Tracks which screens have an open popup — used only by closeAllPopups()
	property var _openScreens: ({})

	// Launcher open state (screen name of the screen showing the launcher, or "")
	property string _launcherScreen: ""

	// Cliphist open state (screen name of the screen showing cliphist, or "")
	property string _cliphistScreen: ""

	// Settings open state
	property string _settingsScreen: ""

	// Emoji picker open state
	property string _emojiScreen: ""

	// Track known screens for removal detection
	property var _knownScreenNames: ([])
	readonly property string launcherScreen: _launcherScreen
	readonly property string cliphistScreen: _cliphistScreen
	readonly property string settingsScreen: _settingsScreen
	readonly property string emojiScreen: _emojiScreen

	// Emitted when a widget requests a popup — carries the component to render and anchor X
	signal popupRequested(screenName: string, popupId: string, component: var, anchorX: int)

	// Emitted when a popup should close
	signal popupClosed(screenName: string)

	// Emitted when launcher opens/closes on a screen
	signal launcherOpened(screenName: string)
	signal launcherClosed

	// Emitted when cliphist opens/closes on a screen
	signal cliphistOpened(screenName: string)
	signal cliphistClosed

	// Emitted when settings opens/closes on a screen
	signal settingsOpened(screenName: string)
	signal settingsClosed

	// Emitted when emoji picker opens/closes on a screen
	signal emojiOpened(screenName: string)
	signal emojiClosed

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

	// Close all open popups across all screens
	function closeAllPopups(): void {
		const keys = Object.keys(root._openScreens);
		if (keys.length === 0)
			return;
		for (const key of keys) {
			delete root._openScreens[key];
			root.popupClosed(key);
		}
	}

	// Launcher open/close
	function openLauncher(screenName: string): void {
		if (root._launcherScreen === screenName) {
			return;
		}
		if (root._settingsScreen !== "") {
			root.closeSettings();
		}
		if (root._launcherScreen !== "") {
			root.closeLauncher();
		}
		if (root._cliphistScreen !== "") {
			root.closeCliphist();
		}
		if (root._emojiScreen !== "") {
			root.closeEmoji();
		}

		root._launcherScreen = screenName;
		root.launcherOpened(screenName);
	}
	function closeLauncher(): void {
		root._launcherScreen = "";
		root.launcherClosed();
	}
	function isLauncherOpen(): bool {
		return root._launcherScreen !== "";
	}

	// Cliphist open/close
	function openCliphist(screenName: string): void {
		if (root._cliphistScreen === screenName) {
			return;
		}
		if (root._settingsScreen !== "") {
			root.closeSettings();
		}
		if (root._cliphistScreen !== "") {
			root.closeCliphist();
		}
		if (root._launcherScreen !== "") {
			root.closeLauncher();
		}
		if (root._emojiScreen !== "") {
			root.closeEmoji();
		}

		root._cliphistScreen = screenName;
		root.cliphistOpened(screenName);
	}
	function closeCliphist(): void {
		root._cliphistScreen = "";
		root.cliphistClosed();
	}
	function isCliphistOpen(): bool {
		return root._cliphistScreen !== "";
	}

	// Settings open/close
	function openSettings(screenName: string): void {
		if (root._settingsScreen === screenName) {
			return;
		}
		if (root._settingsScreen !== "") {
			root.closeSettings();
		}
		if (root._launcherScreen !== "") {
			root.closeLauncher();
		}
		if (root._cliphistScreen !== "") {
			root.closeCliphist();
		}
		if (root._emojiScreen !== "") {
			root.closeEmoji();
		}

		root._settingsScreen = screenName;
		root.settingsOpened(screenName);
	}
	function closeSettings(): void {
		if (root._settingsScreen !== "") {
			root._settingsScreen = "";
			root.settingsClosed();
		}
	}
	function isSettingsOpen(): bool {
		return root._settingsScreen !== "";
	}

	// Emoji picker open/close
	function openEmoji(screenName: string): void {
		if (root._emojiScreen === screenName) {
			return;
		}
		if (root._settingsScreen !== "") {
			root.closeSettings();
		}
		if (root._emojiScreen !== "") {
			root.closeEmoji();
		}
		if (root._launcherScreen !== "") {
			root.closeLauncher();
		}
		if (root._cliphistScreen !== "") {
			root.closeCliphist();
		}

		root._emojiScreen = screenName;
		root.emojiOpened(screenName);
	}
	function closeEmoji(): void {
		if (root._emojiScreen !== "") {
			root._emojiScreen = "";
			root.emojiClosed();
		}
	}
	function isEmojiOpen(): bool {
		return root._emojiScreen !== "";
	}

	onLauncherClosed: gcTimer.restart()
	onCliphistClosed: gcTimer.restart()
	onSettingsClosed: gcTimer.restart()
	onEmojiClosed: gcTimer.restart()
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
