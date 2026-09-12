pragma Singleton

import QtQuick

QtObject {
	id: config

	// Resolved active palette object (falls back to deepMocha if name is invalid)
	readonly property var activePalette: Defaults.palettes[PersistentConfig.adapter.themePalette] || Defaults.palettes["deepMocha"]

	// Clock format — whitelisted presets only, so TimeZone.formatTime can rely on them
	readonly property string timeFormat: {
		const fmt = PersistentConfig.adapter.timeFormat;
		const presets = ["hh:mm", "hh:mm ddd", "hh:mm:ss", "hh:mm AP", "MMM d, hh:mm"];
		return presets.indexOf(fmt) >= 0 ? fmt : "hh:mm ddd";
	}

	// Bar widget scale configuration
	readonly property real barWidgetScale: (PersistentConfig.adapter.bar || {}).widgets?.scale || 1.0
	readonly property int barIconSize: (PersistentConfig.adapter.bar || {}).widgets?.iconSize || Defaults.bar.widgets.iconSize

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
