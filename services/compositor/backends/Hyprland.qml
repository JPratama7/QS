pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Hyprland

Singleton {
    id: backend

    readonly property string name: "hyprland"

    function focusedScreenName(): string {
        const focused = Hyprland.focusedMonitor;
        return focused ? focused.name : "";
    }

    function workspacesForScreen(screenName: string): var {
        const workspaces = Hyprland.workspaces?.values;
        if (!workspaces) return [];

        return workspaces.map(ws => ({
            "id": ws.id,
            "name": ws.name,
            "monitor": ws.monitor,
            "windows": ws.windows
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
        Hyprland.dispatch("workspace", String(workspaceId));
    }
}
