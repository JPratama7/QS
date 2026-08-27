pragma Singleton
import QtQuick
import Quickshell

Singleton {
	id: root

	// Cache: iconName -> resolved path (or "" for not-found)
	property var _cache: ({})
	readonly property int _maxCacheSize: 500

	// Evict the oldest-inserted entries. Cache keys are non-numeric strings, so
	// Object.keys() order is insertion order. Partial eviction beats a full wipe:
	// desktop-entry changes rarely affect most already-resolved icon paths.
	function _evictOldest(count: int): void {
		const keys = Object.keys(root._cache);
		const removeCount = Math.min(count, keys.length);
		for (let i = 0; i < removeCount; i++) {
			delete root._cache[keys[i]];
		}
	}
	function _addToCache(key, value) {
		root._cache[key] = value;
		if (Object.keys(root._cache).length > root._maxCacheSize) {
			root._evictOldest(Math.floor(root._maxCacheSize / 2));
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

	// New/removed apps: drop the oldest half, keep the rest resolvable
	Connections {
		function onApplicationsChanged() {
			root._evictOldest(Math.floor(Object.keys(root._cache).length / 2));
		}

		target: DesktopEntries
	}
}
