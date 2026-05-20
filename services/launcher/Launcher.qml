pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import "../ui"
import "."

Singleton {
	id: root

	// Query state
	property string query: ""

	// Result state — updated whenever query changes
	property var results: []

	// Selection index — -1 means nothing selected
	property int selectedIndex: -1
	readonly property bool hasResults: root.results.length > 0
	readonly property var selectedResult: {
		if (root.selectedIndex >= 0 && root.selectedIndex < root.results.length)
			return root.results[root.selectedIndex];
		return null;
	}

	// Update results from all providers; reset selection
	function _refresh(): void {
		root.results = LauncherProviderRegistry.search(root.query);
		root.selectedIndex = root.results.length > 0 ? 0 : -1;
	}

	// Move selection up/down, clamped to valid range
	function selectNext(): void {
		if (root.results.length === 0)
			return;
		root.selectedIndex = Math.min(root.selectedIndex + 1, root.results.length - 1);
	}
	function selectPrev(): void {
		if (root.results.length === 0)
			return;
		root.selectedIndex = Math.max(root.selectedIndex - 1, 0);
	}

	// Launch the currently selected result, then close
	function activateSelected(): void {
		if (root.selectedResult === null)
			return;
		LauncherProviderRegistry.activate(root.selectedResult);
		root.close();
	}

	// Open launcher on a given screen — clears previous state
	function open(screenName: string): void {
		root.query = "";
		root.selectedIndex = -1;
		ShellUI.openLauncher(screenName);
	}

	// Close launcher — clear state
	function close(): void {
		root.query = "";
		root.selectedIndex = -1;
		ShellUI.closeLauncher();
	}

	onQueryChanged: {
		root._refresh();
	}
}
