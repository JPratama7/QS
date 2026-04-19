pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland

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
        return backend.focusedScreenName();
    }

    function workspacesForScreen(screenName: string): var {
        return backend.workspacesForScreen(screenName);
    }

    function activeWindowForScreen(screenName: string): var {
        return backend.activeWindowForScreen(screenName);
    }

    function screenHasFullscreen(screenName: string): bool {
        return backend.screenHasFullscreen(screenName);
    }

    function switchWorkspace(screenName: string, workspaceId: int): void {
        backend.switchWorkspace(screenName, workspaceId);
    }
}
