pragma ComponentBehavior: Bound

import QtQuick

// Base type for compositor backends.
// Backends must:
//   - Set backendId to a unique string identifier
//   - Set available to indicate if the backend is functional
//   - Implement all screen/workspace/window query functions
QtObject {
	id: backend

	enum ToplevelSort {
		None = 0,
		WorkspaceId = 1,
		Name = 2
	}

	default property list<QtObject> data

	// Unique identifier for this backend type
	property string backendId: ""

	// Whether this backend is functional
	property bool available: true

	// Sorted toplevel list
	property var toplevels: ([])

	// Sort strategy for toplevels
	property int sortMode: CompositorBackend.ToplevelSort.WorkspaceId

	// Name of the currently focused screen
	property string focusedScreen: ""

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
		// Subclasses override this
	}
}
