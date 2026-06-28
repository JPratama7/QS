pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

FileView {
	id: configFile

	property alias adapterView: adapter
	// Guard: only write after the initial load has completed (or failed),
	// so that default-value assignments during construction don't overwrite
	// an existing config.json before it is read.
	property bool readyToWrite: false

	// Returns an object with all default configuration values
	function getDefaultsObject(): var {
		// Helper to deep copy plain objects (for nested config like bar, barWidgetLayout)
		function deepCopy(v: var): var {
			if (typeof v !== "object" || v === null)
				return v;
			if (Array.isArray(v))
				return v.map(deepCopy);
			const copy = {};
			for (const key in v) {
				if (v.hasOwnProperty(key))
					copy[key] = deepCopy(v[key]);
			}
			return copy;
		}
		return {
			primaryScreen: Defaults.primaryScreen,
			timeZone: Defaults.timeZone,
			barHeight: Defaults.barHeight,
			barEdge: Defaults.barEdge,
			barDisplayMode: Defaults.barDisplayMode,
			bar: deepCopy(Defaults.bar),
			triggerZoneHeight: Defaults.triggerZoneHeight,
			launcherWidth: Defaults.launcherWidth,
			launcherMaxResults: Defaults.launcherMaxResults,
			popupEdgeMargin: Defaults.popupEdgeMargin,
			toastPosition: Defaults.toastPosition,
			toastMaxStack: Defaults.toastMaxStack,
			toastDurationMs: Defaults.toastDurationMs,
			notificationMaxHistory: Defaults.notificationMaxHistory,
			excludedScreens: [],
			trayHiddenIds: deepCopy(Defaults.trayHiddenIds),
			trayMenuMaxHeight: Defaults.trayMenuMaxHeight,
			barWidgetLayout: deepCopy(Defaults.barWidgetLayout),
			barWidgetLayoutPerScreen: deepCopy(Defaults.barWidgetLayoutPerScreen),
			barWidgetScalePerScreen: {},
			idleInhibitor: false,
			dndEnabled: Defaults.dndEnabled,
			settings: deepCopy(Defaults.settings)
		};
	}

	// Deep merge helper: merges source into target recursively
	function deepMerge(target: var, source: var): void {
		if (typeof source !== "object" || source === null || Array.isArray(source)) {
			return;
		}
		for (const key in source) {
			if (!source.hasOwnProperty(key))
				continue;
			const sourceVal = source[key];
			const targetVal = target[key];
			if (typeof sourceVal === "object" && sourceVal !== null && !Array.isArray(sourceVal) && typeof targetVal === "object" && targetVal !== null && !Array.isArray(targetVal)) {
				// Both are plain objects - recurse
				deepMerge(targetVal, sourceVal);
			} else if (sourceVal !== undefined) {
				// Source value takes precedence (including arrays, nulls, primitives)
				target[key] = sourceVal;
			}
		}
	}

	// Merge disk values on top of defaults (deep merge for nested objects)
	function mergeWithDefaults(diskValues: var): var {
		const merged = getDefaultsObject();
		deepMerge(merged, diskValues);
		return merged;
	}

	// Apply merged values to the adapter properties
	function applyMergedValues(merged: var): void {
		adapterView.primaryScreen = merged.primaryScreen;
		adapterView.timeZone = merged.timeZone;
		adapterView.barHeight = merged.barHeight;
		adapterView.barEdge = merged.barEdge;
		adapterView.barDisplayMode = merged.barDisplayMode;
		adapterView.bar = merged.bar;
		adapterView.triggerZoneHeight = merged.triggerZoneHeight;
		adapterView.launcherWidth = merged.launcherWidth;
		adapterView.launcherMaxResults = merged.launcherMaxResults;
		adapterView.popupEdgeMargin = merged.popupEdgeMargin;
		adapterView.toastPosition = merged.toastPosition;
		adapterView.toastMaxStack = merged.toastMaxStack;
		adapterView.toastDurationMs = merged.toastDurationMs;
		adapterView.notificationMaxHistory = merged.notificationMaxHistory;
		adapterView.excludedScreens = merged.excludedScreens;
		adapterView.trayHiddenIds = merged.trayHiddenIds;
		adapterView.trayMenuMaxHeight = merged.trayMenuMaxHeight;
		adapterView.barWidgetLayout = merged.barWidgetLayout;
		adapterView.barWidgetLayoutPerScreen = merged.barWidgetLayoutPerScreen;
		adapterView.barWidgetScalePerScreen = merged.barWidgetScalePerScreen;
		adapterView.idleInhibitor = merged.idleInhibitor;
		adapterView.dndEnabled = merged.dndEnabled;
		adapterView.settings = merged.settings;
	}

	path: Quickshell.shellDir + "/config.json"
	watchChanges: true

	onFileChanged: reload()
	Component.onCompleted: {
		reload();
	}
	onLoaded: {
		// Parse, merge, and apply before enabling writes
		// to avoid onAdapterUpdated from firing writeAdapter() mid-apply
		try {
			const rawText = configFile.text() || "{}";
			const diskValues = JSON.parse(rawText);
			const merged = mergeWithDefaults(diskValues);
			applyMergedValues(merged);
			writeAdapter();
			readyToWrite = true;
		} catch (e) {
			console.error("PersistentConfig: failed to parse or apply config:", e);
			// Don't enable writes — state is inconsistent
		}
	}
	onAdapterUpdated: {
		if (readyToWrite)
			writeAdapter();
	}
	onLoadFailed: error => {
		readyToWrite = true;
		if (error === FileViewError.FileNotFound) {
			// File doesn't exist yet — write defaults to create it
			writeAdapter();
		} else {
			console.error("PersistentConfig: failed to load config file:", FileViewError.toString(error), path);
		}
	}

	JsonAdapter {
		id: adapter

		property string primaryScreen: Defaults.primaryScreen
		property string timeZone: Defaults.timeZone
		property int barHeight: Defaults.barHeight
		property string barEdge: Defaults.barEdge
		property string barDisplayMode: Defaults.barDisplayMode
		property var bar: Defaults.bar
		property int triggerZoneHeight: Defaults.triggerZoneHeight
		property int launcherWidth: Defaults.launcherWidth
		property int launcherMaxResults: Defaults.launcherMaxResults
		property int popupEdgeMargin: Defaults.popupEdgeMargin
		property string toastPosition: Defaults.toastPosition
		property int toastMaxStack: Defaults.toastMaxStack
		property int toastDurationMs: Defaults.toastDurationMs
		property int notificationMaxHistory: Defaults.notificationMaxHistory
		property var excludedScreens: ([])
		property var trayHiddenIds: Defaults.trayHiddenIds
		property int trayMenuMaxHeight: Defaults.trayMenuMaxHeight
		property var barWidgetLayout: Defaults.barWidgetLayout
		property var barWidgetLayoutPerScreen: Defaults.barWidgetLayoutPerScreen
		property var barWidgetScalePerScreen: ({})
		property bool idleInhibitor: false
		property bool dndEnabled: Defaults.dndEnabled
		property var settings: Defaults.settings
	}
}
