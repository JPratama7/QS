pragma Singleton

import QtQuick

QtObject {
	id: config

	// Bar configuration
	readonly property int barHeight: PersistentConfig.adapter.barHeight
	readonly property string barEdge: PersistentConfig.adapter.barEdge
	readonly property string barDisplayMode: PersistentConfig.adapter.barDisplayMode
	readonly property var bar: PersistentConfig.adapter.bar

	// Time zone for clock display ("local" = system default)
	readonly property string timeZone: PersistentConfig.adapter.timeZone

	// Auto-hide trigger configuration
	readonly property int triggerZoneHeight: PersistentConfig.adapter.triggerZoneHeight

	// Launcher configuration
	readonly property int launcherWidth: PersistentConfig.adapter.launcherWidth
	readonly property int launcherMaxResults: PersistentConfig.adapter.launcherMaxResults

	// Popup configuration
	readonly property int popupEdgeMargin: PersistentConfig.adapter.popupEdgeMargin

	// Toast configuration
	readonly property string toastPosition: PersistentConfig.adapter.toastPosition
	readonly property int toastMaxStack: PersistentConfig.adapter.toastMaxStack
	readonly property int toastDurationMs: PersistentConfig.adapter.toastDurationMs

	// Notification history cap — 0 means unlimited
	readonly property int notificationMaxHistory: PersistentConfig.adapter.notificationMaxHistory

	// DnD configuration
	readonly property bool dndEnabled: PersistentConfig.adapter.dndEnabled

	// Primary screen name — used by ScreenContext.isPrimary
	readonly property string primaryScreen: PersistentConfig.adapter.primaryScreen

	// Screen exclusion list (regex patterns)
	readonly property var excludedScreens: PersistentConfig.adapter.excludedScreens

	// Tray configuration
	readonly property var trayHiddenIds: PersistentConfig.adapter.trayHiddenIds
	readonly property int trayMenuMaxHeight: PersistentConfig.adapter.trayMenuMaxHeight

	// Bar widget layout configuration
	readonly property var barWidgetLayout: PersistentConfig.adapter.barWidgetLayout
	readonly property var barWidgetLayoutPerScreen: PersistentConfig.adapter.barWidgetLayoutPerScreen

	// Bar widget scale configuration
	readonly property real barWidgetScale: (PersistentConfig.adapter.bar || {}).widgets?.scale || 1.0
	readonly property var barWidgetScalePerScreen: PersistentConfig.adapter.barWidgetScalePerScreen

	function widgetScaleForScreen(screenName: string): real {
		const perScreen = PersistentConfig.adapter.barWidgetScalePerScreen;
		const scale = perScreen && perScreen[screenName];
		if (typeof scale === "number" && isFinite(scale) && scale > 0) {
			return scale;
		}
		return config.barWidgetScale;
	}
	function barWidgetsConfig(): var {
		const barConfig = PersistentConfig.adapter.bar || {};
		return barConfig.widgets || {};
	}
	function systemMonitorRamFormat(): string {
		const widgetsConfig = config.barWidgetsConfig();
		const fmt = widgetsConfig.systemMonitor?.ramFormat;
		return (fmt === "used" || fmt === "used/total") ? fmt : "percent";
	}
	function batteryDisplayMode(): string {
		const widgetsConfig = config.barWidgetsConfig();
		const mode = widgetsConfig.battery?.displayMode;
		return (mode === "text" || mode === "icon" || mode === "both") ? mode : "both";
	}
	function normalizedBarWidgetLayout(layout: var): var {
		const source = layout || {};
		const seen = ({});

		function uniqueZone(zone: string): var {
			const zoneWidgets = source[zone] || [];
			const result = [];

			for (const widgetId of zoneWidgets) {
				if (typeof widgetId !== "string" || widgetId === "")
					continue;
				if (seen[widgetId])
					continue;
				seen[widgetId] = true;
				result.push(widgetId);
			}

			return result;
		}

		return {
			"left": uniqueZone("left"),
			"center": uniqueZone("center"),
			"right": uniqueZone("right")
		};
	}
	function barWidgetLayoutForScreen(screenName: string): var {
		const perScreen = PersistentConfig.adapter.barWidgetLayoutPerScreen;
		const layout = (perScreen && perScreen[screenName]) ? perScreen[screenName] : PersistentConfig.adapter.barWidgetLayout;
		return config.normalizedBarWidgetLayout(layout);
	}
}
