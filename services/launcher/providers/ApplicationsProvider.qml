pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import "../../../types"
import ".."

// Launcher provider for installed desktop-entry applications.
// Registers itself with LauncherProviderRegistry on creation.
QtObject {
	id: provider

	readonly property string providerId: "applications"

	// Factory for creating LauncherResult instances
	property Component resultFactory: Component {
		LauncherResult {
		}
	}

	// Search by name, genericName, comment, and keywords (case-insensitive)
	function search(query: string): var {
		const apps = DesktopEntries.applications.values;
		if (!apps)
			return [];

		const q = query.trim().toLowerCase();
		if (q === "")
			return [];

		const results = [];
		for (const app of apps) {
			if (!app || app.noDisplay)
				continue;
			if (provider._matches(app, q)) {
				const result = resultFactory.createObject(provider, {
					title: app.name,
					subtitle: app.genericName || app.comment || "",
					icon: app.icon || "",
					providerId: provider.providerId,
					data: app.id
				});
				results.push(result);
			}
		}

		// Sort: name-prefix matches first, then others
		results.sort((a, b) => {
			const aPrefix = a.title.toLowerCase().startsWith(q);
			const bPrefix = b.title.toLowerCase().startsWith(q);
			if (aPrefix && !bPrefix)
				return -1;
			if (!aPrefix && bPrefix)
				return 1;

			// Secondary sort by title length (shorter first)
			if (a.title.length !== b.title.length) {
				return a.title.length - b.title.length;
			}
			return a.title.localeCompare(b.title);
		});

		return results;
	}
	function activate(data: var): void {
		const app = DesktopEntries.byId(data);
		if (app)
			app.execute();
	}
	function _matches(app: QtObject, q: string): bool {
		if (app.name && app.name.toLowerCase().includes(q))
			return true;
		if (app.genericName && app.genericName.toLowerCase().includes(q))
			return true;
		if (app.comment && app.comment.toLowerCase().includes(q))
			return true;
		if (app.keywords) {
			for (const kw of app.keywords) {
				if (kw && kw.toLowerCase().includes(q))
					return true;
			}
		}
		return false;
	}

	Component.onCompleted: {
		LauncherProviderRegistry.register(provider);
	}
}
