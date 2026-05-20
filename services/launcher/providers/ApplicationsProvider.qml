pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import "../../../types/launcher"
import "../../launcher"

// Launcher provider for installed desktop-entry applications.
LauncherProvider {
	id: provider

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
				results.push({
					title: app.name,
					subtitle: app.genericName || app.comment || "",
					icon: app.icon || "",
					providerId: provider.providerId,
					data: app.id
				});
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

	providerId: "applications"

	Component.onCompleted: {
		LauncherProviderRegistry.register(provider);
	}
}
