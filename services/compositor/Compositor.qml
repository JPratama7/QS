pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import "../../types"

Singleton {
    id: service

    readonly property string compositorType: {
        if (Hyprland.eventSocketPath) return "Hyprland";
        return "Generic";
    }

    property var _backend: null

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

    readonly property var backend: _backend
    readonly property string backendName: _backend ? _backend.name : "none"

    readonly property Toplevel topLevel: ToplevelManager.activeToplevel

    onTopLevelChanged: {
        service.activeToplevelChanged(service.topLevel);
    }

    signal activeToplevelChanged(data: Toplevel)

    function focusedScreenName(): string {
        return backend ? backend.focusedScreenName() : "";
    }

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
        if (backend) backend.switchWorkspace(screenName, workspaceId);
    }
}
