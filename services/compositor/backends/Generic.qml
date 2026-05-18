pragma ComponentBehavior: Bound

import QtQuick
import "../../../types/compositor"

CompositorBackend {
	id: backend

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

	backendId: "generic"
	available: true
	focusedScreen: ""
}
