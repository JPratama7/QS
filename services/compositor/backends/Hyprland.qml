pragma ComponentBehavior: Bound
import QtQml

import QtQuick
import Quickshell.Hyprland
import Quickshell.Wayland
import "../../../types/compositor"

CompositorBackend {
	id: backend

	property bool _dirty: true

	// Per-screen workspaces cache: rebuilt once per change batch, not once per
	// widget binding evaluation. Array identity is kept while the workspace id
	// set is unchanged, so Repeaters don't churn delegates on window-only churn.
	property var _workspacesCache: ({})
	property bool _workspacesDirty: true

	function _markDirty(): void {
		backend._workspacesDirty = true;
		if (_dirty && debounce.running)
			return;
		_dirty = true;
		debounce.restart();
	}
	function _rebuild(): void {
		const mode = backend.sortMode;
		const items = ToplevelManager.toplevels.values.slice();

		if (mode === CompositorBackend.ToplevelSort.None) {
			backend.toplevels = items;
		} else if (mode === CompositorBackend.ToplevelSort.WorkspaceId) {
			const wsMap = new Map();
			for (const ht of Hyprland.toplevels.values) {
				wsMap.set(ht.title, ht);
			}
			items.sort(function (a, b) {
				const wsA = wsMap.get(a.title);
				const wsB = wsMap.get(b.title);
				if (wsA && wsB && wsA.workspace && wsB.workspace) {
					return wsA.workspace.id - wsB.workspace.id;
				}
				return (a.title || "").localeCompare(b.title || "");
			});
			backend.toplevels = items;
		} else if (mode === CompositorBackend.ToplevelSort.Name) {
			items.sort(function (a, b) {
				return (a.title || "").localeCompare(b.title || "");
			});
			backend.toplevels = items;
		}
		_dirty = false;
	}
	function activeWorkspaceIdForScreen(screenName: string): int {
		const monitor = Hyprland.monitors.values.find(m => m.name === screenName);
		return monitor ? monitor.activeWorkspace?.id ?? 0 : 0;
	}
	function _sameWorkspaceIds(a: var, b: var): bool {
		if (!a || !b || a.length !== b.length)
			return false;
		for (let i = 0; i < a.length; i++) {
			if (a[i] !== b[i])
				return false;
		}
		return true;
	}
	function _rebuildWorkspaces(): void {
		const workspaces = Hyprland.workspaces?.values;
		const monitors = Hyprland.monitors?.values;
		const cache = {};
		if (workspaces && monitors) {
			for (const monitor of monitors) {
				const list = workspaces.filter(ws => ws.monitor === monitor).map(ws => ({
							"id": ws.id,
							"name": ws.name,
							"monitor": ws.monitor,
							"windows": ws.windows
						}));
				const previous = backend._workspacesCache[monitor.name];
				// Keep the previous array when only windows/name changed — the
				// widgets render id + active state, so a stable identity avoids
				// Repeater teardown/recreate churn.
				if (_sameWorkspaceIds(previous, list))
					cache[monitor.name] = previous;
				else
					cache[monitor.name] = list;
			}
		}
		backend._workspacesCache = cache;
		backend._workspacesDirty = false;
	}
	function workspacesForScreen(screenName: string): var {
		if (backend._workspacesDirty)
			backend._rebuildWorkspaces();
		return backend._workspacesCache[screenName] || [];
	}
	function activeWindowForScreen(screenName: string): var {
		const active = Hyprland.activeToplevel;
		if (!active)
			return null;

		const monitor = active.monitor;
		if (monitor && monitor.name === screenName) {
			return {
				"title": active.title,
				"class": active.workspace?.name ?? "",
				"monitor": active.monitor,
				"pid": 0
			};
		}
		return null;
	}
	function screenHasFullscreen(screenName: string): bool {
		const workspaces = Hyprland.workspaces?.values;
		if (!workspaces)
			return false;

		for (let i = 0; i < workspaces.length; i++) {
			const ws = workspaces[i];
			const wsMonitor = ws.monitor;
			if (wsMonitor && wsMonitor.name === screenName && ws.fullscreen) {
				return true;
			}
		}
		return false;
	}
	function switchWorkspace(screenName: string, workspaceId: int): void {
		Hyprland.dispatch("focusmonitor " + screenName);
		Hyprland.dispatch("workspace " + String(workspaceId));
	}

	backendId: "hyprland"
	focusedScreen: Hyprland.focusedMonitor?.name ?? ""

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
	Connections {
		function onRefreshToplevels(): void {
			backend._markDirty();
		}

		target: Hyprland
	}
	Connections {
		function onValuesChanged(): void {
			backend._markDirty();
		}

		target: Hyprland.workspaces
	}
	Connections {
		function onValuesChanged(): void {
			backend._markDirty();
		}

		target: Hyprland.monitors
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
