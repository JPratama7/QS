pragma Singleton
import QtQuick
import Quickshell

Singleton {
	id: root

	// Cache: iconName -> resolved path (or "" for not-found)
	property var _cache: ({})
	readonly property int _maxCacheSize: 500

	function _invalidateCache(): void {
		root._cache = {};
	}
	function _addToCache(key, value) {
		root._cache[key] = value;
		if (Object.keys(root._cache).length > root._maxCacheSize) {
			root._invalidateCache();
		}
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

		if (iconName && Quickshell.iconPath) {
			const p = Quickshell.iconPath(iconName, fallback);
			if (p) {
				root._addToCache(cacheKey, p);
				return p;
			}
		}

		if (Quickshell.iconPath) {
			const p = Quickshell.iconPath(fallback, true);
			if (p) {
				root._addToCache(cacheKey, p);
				return p;
			}
		}

		root._addToCache(cacheKey, "");
		return "";
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
			root._addToCache(appIdKey, result);
			return result;
		}

		const entry = (DesktopEntries.heuristicLookup) ? DesktopEntries.heuristicLookup(appId) : DesktopEntries.byId(appId);
		const name = entry && entry.icon ? entry.icon : "";
		const result = iconFromName(name || fallback, fallback);
		root._addToCache(appIdKey, result);
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
