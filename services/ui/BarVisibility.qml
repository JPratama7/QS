pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import "../../config"
import "../../services/compositor"
import "../../types"

Singleton {
	id: service

	property int hideDelayMs: 300

	// Screen states - ScreenState instances keyed by screen name
	property var screenStates: ({})
	readonly property bool anyVisible: {
		const states = service.screenStates;
		for (const screenName in states) {
			const state = states[screenName];
			if (state && state.effectiveVisible) {
				return true;
			}
		}
		return false;
	}

	// Hide timers keyed by screen name
	readonly property var _hideTimers: ({})

	function destroyTimer(screenName: string): void {
		const timer = _hideTimers[screenName];
		if (!timer) {
			return;
		}
		timer.stop();
		timer.destroy();
		delete _hideTimers[screenName];
	}
	function initScreenStates(): void {
		const states = {};
		for (const screen of Quickshell.screens) {
			states[screen.name] = screenStateComponent.createObject(service, {
				displayMode: ShellConfig.barDisplayMode
			});
		}
		screenStates = states;
	}

	// Convenience getter for consumers
	function effectiveVisible(screenName: string): bool {
		const state = screenStates[screenName];
		return state ? state.effectiveVisible : true;
	}
	function hoverEnter(screenName: string): void {
		const state = screenStates[screenName];
		if (!state) {
			return;
		}
		state.hovered = true;
	}
	function hoverLeave(screenName: string): void {
		const state = screenStates[screenName];
		if (!state) {
			return;
		}
		state.hovered = false;
		scheduleHide(screenName);
	}
	function popupOpen(screenName: string): void {
		const state = screenStates[screenName];
		if (!state) {
			return;
		}
		state.popupOpen = true;
	}
	function popupClose(screenName: string): void {
		const state = screenStates[screenName];
		if (!state) {
			return;
		}
		state.popupOpen = false;
		scheduleHide(screenName);
	}
	function setForceVisible(screenName: string, value: bool): void {
		const state = screenStates[screenName];
		if (!state) {
			return;
		}
		state.forceVisible = value;
	}
	function setFullscreen(screenName: string, value: bool): void {
		const state = screenStates[screenName];
		if (!state) {
			return;
		}
		state.fullscreen = value;
	}
	function scheduleHide(screenName: string): void {
		destroyTimer(screenName);

		const timer = hideTimerComponent.createObject(service, {
			screenName: screenName
		});
		_hideTimers[screenName] = timer;
		timer.start();
	}
	function cancelHide(screenName: string): void {
		destroyTimer(screenName);
	}

	Component.onCompleted: {
		initScreenStates();
	}

	// ScreenState component for type-safe instantiation
	Component {
		id: screenStateComponent

		ScreenState {
		}
	}

	// Timer component - type-safe, no string interpolation
	Component {
		id: hideTimerComponent

		Timer {
			property string screenName

			interval: service.hideDelayMs
			repeat: false

			onTriggered: {
				const state = service.screenStates[screenName];
				if (state && !state.hovered && !state.popupOpen) {
					state.forceVisible = false;
				}
				service.destroyTimer(screenName);
			}
		}
	}
	Connections {
		function onScreensChanged(): void {
			const currentNames = new Set(Quickshell.screens.map(s => s.name));
			for (const name in service.screenStates) {
				if (!currentNames.has(name)) {
					service.screenStates[name].destroy();
					service.destroyTimer(name);
				}
			}
			const states = {};
			for (const screen of Quickshell.screens) {
				states[screen.name] = service.screenStates[screen.name] || screenStateComponent.createObject(service, {
					displayMode: ShellConfig.barDisplayMode
				});
			}
			service.screenStates = states;
		}

		target: Quickshell
	}
	Connections {
		function onActiveToplevelChanged(): void {
			for (const screen of Quickshell.screens) {
				const state = service.screenStates[screen.name];
				if (state) {
					state.fullscreen = Compositor.screenHasFullscreen(screen.name);
				}
			}
		}

		target: Compositor
	}
	Connections {
		function onBarDisplayModeChanged(): void {
			for (const screenName in service.screenStates) {
				service.screenStates[screenName].displayMode = ShellConfig.barDisplayMode;
			}
		}

		target: ShellConfig
	}
}
