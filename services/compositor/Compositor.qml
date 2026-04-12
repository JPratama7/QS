pragma Singleton

import QtQuick
import Quickshell.Hyprland

QtObject {
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
