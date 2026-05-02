pragma ComponentBehavior: Bound

import QtQuick
import "../../../types"

QtObject {
    id: backend

    readonly property string name: "generic"
    readonly property bool available: true

    readonly property string focusedScreen: ""

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
        console.log("GenericBackend: switchWorkspace not supported");
    }
}
