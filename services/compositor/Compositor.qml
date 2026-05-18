pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import "../../types/compositor"

Singleton {
	id: service

	readonly property string compositorType: {
		if (Hyprland.eventSocketPath)
			return "Hyprland";
		return "Generic";
	}
	property CompositorBackend _backend: null
	readonly property CompositorBackend backend: _backend
	readonly property string backendName: _backend ? _backend.backendId : "none"
	readonly property string focusedScreen: _backend ? _backend.focusedScreen : ""
	readonly property var toplevels: _backend ? _backend.toplevels : []
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
	function setToplevelSortMode(mode: int): void {
		if (backend)
			backend.sortMode = mode;
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
