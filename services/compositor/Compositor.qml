pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland

Singleton {
	id: service

	readonly property string compositorType: {
		if (Hyprland.eventSocketPath)
			return "Hyprland";
		return "Generic";
	}
	property var _backend: null
	readonly property var backend: _backend
	readonly property string backendName: _backend ? _backend.name : "none"
	readonly property string focusedScreen: _backend ? _backend.focusedScreen : ""
	property string toplevelSortMode: "workspaceId" // "none", "activeFirst", "workspaceId"

	readonly property var toplevels: {
		if (toplevelSortMode === "none") {
			return ToplevelManager.toplevels;
		}

		const items = ToplevelManager.toplevels.values.slice();

		if (toplevelSortMode === "activeFirst") {
			items.sort(function (a, b) {
				if (a.activated !== b.activated) {
					return a.activated ? -1 : 1;
				}
				return (a.title || "").localeCompare(b.title || "");
			});
		} else if (toplevelSortMode === "workspaceId") {
			const wsMap = new Map();
			if (compositorType === "Hyprland") {
				for (const ht of Hyprland.toplevels.values) {
					wsMap.set(ht.title, ht);
				}
			}
			items.sort(function (a, b) {
				const wsA = wsMap.get(a.title);
				const wsB = wsMap.get(b.title);
				if (wsA && wsB && wsA.workspace && wsB.workspace) {
					return wsA.workspace.id - wsB.workspace.id;
				}
				return (a.title || "").localeCompare(b.title || "");
			});

			wsMap.clear();
		}

		return items;
	}
	readonly property Toplevel topLevel: ToplevelManager.activeToplevel

	signal activeToplevelChanged(data: Toplevel)

	function activeWorkspaceIdForScreen(screenName: string): int {
		return backend ? backend.activeWorkspaceIdForScreen(screenName) : 0;
	}
	function workspacesForScreen(screenName: string): var {
		return backend ? backend.workspacesForScreen(screenName) : [];
	}
	function activeWindowForScreen(screenName: string): var {
		return backend ? backend.activeWindowForScreen(screenName) : null;
	}
	function screenHasFullscreen(screenName: string): bool {
		return backend ? backend.screenHasFullscreen(screenName) : false;
	}
	function switchWorkspace(screenName: string, workspaceId: int): void {
		if (backend)
			backend.switchWorkspace(screenName, workspaceId);
	}

	Component.onCompleted: {
		const backendComp = Qt.createComponent(`backends/${compositorType}.qml`);
		if (backendComp.status === Component.Ready) {
			service._backend = backendComp.createObject(service);
		} else {
			// Fallback to generic if the specific backend fails to load
			const genericComp = Qt.createComponent("backends/Generic.qml");
			if (genericComp.status === Component.Ready) {
				service._backend = genericComp.createObject(service);
			}
		}
	}
	onTopLevelChanged: {
		service.activeToplevelChanged(service.topLevel);
	}
}
