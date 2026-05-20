pragma Singleton
import QtQuick
import Quickshell

Singleton {
	id: root

	// Cache: iconName -> resolved path (or "" for not-found)
	property var _cache: ({})

	function _invalidateCache(): void {
		root._cache = {};
	}
	function iconFromName(iconName, fallbackName) {
		const fallback = fallbackName || "application-x-executable";

		// Absolute path - use directly instead of passing through icon theme resolver
		if (iconName && iconName.startsWith("/"))
			return "file://" + iconName;

		// Check cache first
		const cacheKey = iconName + "|" + fallback;
		if (cacheKey in root._cache)
			return root._cache[cacheKey];

		let resolved = "";
		if (iconName && Quickshell.iconPath) {
			const p = Quickshell.iconPath(iconName, fallback);
			if (p && p !== "") {
				resolved = p;
			}
		}
		if (!resolved && Quickshell.iconPath) {
			resolved = Quickshell.iconPath(fallback, true) || "";
		}

		root._cache[cacheKey] = resolved;
		return resolved;
	}

	// Resolve icon path for a DesktopEntries appId - safe on missing entries
	function iconForAppId(appId, fallbackName) {
		const fallback = fallbackName || "application-x-executable";
		if (!appId)
			return iconFromName(fallback, fallback);

		// Check appId cache
		const appIdKey = "appId:" + appId + "|" + fallback;
		if (appIdKey in root._cache)
			return root._cache[appIdKey];

		if (typeof DesktopEntries === 'undefined' || !DesktopEntries.byId) {
			const result = iconFromName(fallback, fallback);
			root._cache[appIdKey] = result;
			return result;
		}

		const entry = (DesktopEntries.heuristicLookup) ? DesktopEntries.heuristicLookup(appId) : DesktopEntries.byId(appId);
		const name = entry && entry.icon ? entry.icon : "";
		const result = iconFromName(name || fallback, fallback);
		root._cache[appIdKey] = result;
		return result;
	}

	// Invalidate when desktop entries change (new/removed apps, icon updates)
	Connections {
		function onApplicationsChanged() {
			root._invalidateCache();
		}

		target: DesktopEntries
	}
}
