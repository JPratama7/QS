pragma ComponentBehavior: Bound

import QtQuick

QtObject {
    id: backend

    readonly property string name: "generic"
    readonly property bool available: true

    function focusedScreenName(): string {
        return "";
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
        console.log("GenericBackend: switchWorkspace not supported");
    }
}
