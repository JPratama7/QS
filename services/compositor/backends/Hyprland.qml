pragma ComponentBehavior: Bound

import QtQuick
import QtQml
import Quickshell.Hyprland
import "../../../types"

QtObject {
    id: backend

    readonly property string name: "hyprland"

    readonly property string focusedScreen: Hyprland.focusedMonitor?.name ?? ""

    function activeWorkspaceIdForScreen(screenName: string): int {
        const monitor = Hyprland.monitors.values.find(m => m.name === screenName);
        return monitor ? monitor.activeWorkspace?.id ?? 0 : 0;
    }

    function workspacesForScreen(screenName: string): var {
        const workspaces = Hyprland.workspaces?.values;
        if (!workspaces) return [];

        const monitor = Hyprland.monitors.values.find(monitor => monitor.name === screenName);
        return workspaces.filter(ws => ws.monitor === monitor).map(ws => ({
            "id": ws.id,
            "name": ws.name,
            "monitor": ws.monitor,
            "windows": ws.windows,
        }));
    }

    function activeWindowForScreen(screenName: string): var {
        const active = Hyprland.activeToplevel;
        if (!active) return null;

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
        if (!workspaces) return false;

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
        Hyprland.dispatch("workspace " + String(workspaceId));
    }
}
