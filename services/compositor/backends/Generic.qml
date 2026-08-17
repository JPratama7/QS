pragma ComponentBehavior: Bound

import QtQuick
import Quickshell.Wayland
import "../../../types/compositor"

CompositorBackend {
	id: backend

	property bool _dirty: true

	function _markDirty(): void {
		_dirty = true;
		debounce.restart();
	}
	function _rebuild(): void {
		const mode = backend.sortMode;
		const items = ToplevelManager.toplevels.values.slice();

		if (mode === CompositorBackend.ToplevelSort.None) {
			// No sorting
		} else if (mode === CompositorBackend.ToplevelSort.WorkspaceId) {
			// Generic backend doesn't have workspace info, fall back to name sort
			items.sort(function (a, b) {
				return (a.title || "").localeCompare(b.title || "");
			});
		} else if (mode === CompositorBackend.ToplevelSort.Name) {
			items.sort(function (a, b) {
				return (a.title || "").localeCompare(b.title || "");
			});
		}
		backend.toplevels = items;
		_dirty = false;
	}
	function activeWorkspaceIdForScreen(screenName: string): int {
		return 0;
	}
	function workspacesForScreen(screenName: string): var {
		return [];
	}
	function activeWindowForScreen(screenName: string): var {
		return null;
	}
	function screenHasFullscreen(screenName: string): bool {
		return false;
	}
	function switchWorkspace(screenName: string, workspaceId: int): void {
		console.warn("GenericBackend: switchWorkspace not supported");
	}

	backendId: "generic"
	available: true
	focusedScreen: ""

	Component.onCompleted: {
		backend._rebuild();
	}

	Connections {
		function onSortModeChanged(): void {
			backend._markDirty();
		}

		target: backend
	}
	Connections {
		function onValuesChanged(): void {
			backend._markDirty();
		}

		target: ToplevelManager.toplevels
	}
	Timer {
		id: debounce

		interval: 50
		repeat: false

		onTriggered: {
			if (backend._dirty)
				backend._rebuild();
		}
	}
}
