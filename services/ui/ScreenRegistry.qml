pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import "../../config"
import "../../types"

Singleton {
	id: registry

	readonly property list<ShellScreen> enabledScreens: {
		const excluded = ShellConfig.excludedScreens;
		if (excluded.length === 0)
			return Quickshell.screens;
		return Quickshell.screens.filter(s => !isExcluded(s.name));
	}
	property var enabledScreensMap: ({})
	property var screenContexts: ({})
	property Component screenContextComponent: Component {
		ScreenContext {
		}
	}

	signal screenChanged

	function rebuildScreensMap(): void {
		const map = {};
		for (const screen of registry.enabledScreens) {
			map[screen.name] = screen;
		}
		enabledScreensMap = map;
	}
	function restoreFromPersistence(): void {
		if (PersistentConfig.adapterView.primaryScreen === "" && registry.enabledScreens.length > 0) {
			const firstScreen = registry.enabledScreens[0];
			PersistentConfig.adapterView.primaryScreen = firstScreen.name;
		}
	}
	function isExcluded(screenName: string): bool {
		const patterns = ShellConfig.excludedScreens;
		for (const pattern of patterns) {
			if (screenName.match(pattern))
				return true;
		}
		return false;
	}
	function screenByName(screenName: string): var {
		return enabledScreensMap[screenName] || null;
	}
	function createContext(screen: ShellScreen): ScreenContext {
		if (registry.screenContexts[screen.name]) {
			return registry.screenContexts[screen.name];
		}
		const context = registry.screenContextComponent.createObject(registry, {
			"screen": screen
		}) as ScreenContext;
		if (!context) {
			console.error("Failed to create screen context for screen:", screen.name);
			return null;
		}
		registry.screenContexts[screen.name] = context;
		return context;
	}
	function cleanupScreenContexts(): void {
		const currentNames = new Set(registry.enabledScreens.map(s => s.name));
		const newContexts = {};
		for (const name in registry.screenContexts) {
			if (currentNames.has(name)) {
				newContexts[name] = registry.screenContexts[name];
			} else {
				registry.screenContexts[name].destroy();
			}
		}
		registry.screenContexts = newContexts;
	}

	Component.onCompleted: {
		rebuildScreensMap();
	}

	Connections {
		function onLoaded(): void {
			registry.restoreFromPersistence();
		}

		target: PersistentConfig
	}
	Connections {
		function onScreensChanged(): void {
			registry.rebuildScreensMap();
			registry.cleanupScreenContexts();
			registry.screenChanged();
		}

		target: Quickshell
	}
}
