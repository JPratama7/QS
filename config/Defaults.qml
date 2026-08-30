pragma Singleton
import QtQml
import QtQuick

QtObject {
	id: defaults

	// Primary screen name (empty string = first screen is treated as primary)
	readonly property string primaryScreen: ""
	// Theme palette — one of: "deepMocha", "mochaMauve", "macchiatoTeal", "frappePeach"
	readonly property string themePalette: "deepMocha"
	// Palette definitions — each mixes base depth and accent hue from Catppuccin flavors
	readonly property var palettes: ({
		"deepMocha": {
			"background": "#11111b",
			"barBackground": "#181825",
			"foreground": "#cdd6f4",
			"muted": "#6c7086",
			"surface": "#313244",
			"accent": "#89b4fa",
			"error": "#f38ba8"
		},
		"mochaMauve": {
			"background": "#1e1e2e",
			"barBackground": "#181825",
			"foreground": "#cdd6f4",
			"muted": "#6c7086",
			"surface": "#313244",
			"accent": "#cba6f7",
			"error": "#f38ba8"
		},
		"macchiatoTeal": {
			"background": "#24273a",
			"barBackground": "#1e2030",
			"foreground": "#cad3f5",
			"muted": "#6e738d",
			"surface": "#363a4f",
			"accent": "#8bd5ca",
			"error": "#ed8796"
		},
		"frappePeach": {
			"background": "#303446",
			"barBackground": "#292c3c",
			"foreground": "#c6d0f5",
			"muted": "#737994",
			"surface": "#414559",
			"accent": "#fab387",
			"error": "#e78284"
		}
	})
	// Time zone for clock display (empty string = system default)
	readonly property string timeZone: ""
	// Bar defaults
	readonly property int barHeight: 32
	readonly property string barEdge: "top"
	readonly property string barDisplayMode: "visible"
	readonly property var bar: {
		"tooltip": {
			"enabled": true,
			"delayMs": 300
		},
		"widgets": {
			"scale": 1,
			"iconSize": 16,
			"workspaces": {
				"showText": true
			},
			"activeWindow": {
				"maxTextWidth": 200
			},
			"systemMonitor": {
				"ramFormat": "percent"
			},
			"battery": {
				"displayMode": "both"
			}
		}
	}
	// Auto-hide trigger defaults
	readonly property int triggerZoneHeight: 4
	// Launcher defaults
	readonly property int launcherWidth: 560
	readonly property int launcherMaxResults: 8
	// Vertical margin kept between the launcher and the screen edges
	readonly property int launcherVerticalMargin: 100
	// Max height of the results list before it scrolls
	readonly property int launcherResultsHeight: 400
	// Popup defaults
	readonly property int popupEdgeMargin: 8
	// Notification defaults
	readonly property bool dndEnabled: false
	// Toast notification defaults
	readonly property string toastPosition: "top-right"
	readonly property int toastMaxStack: 3
	readonly property int toastDurationMs: 5000
	// Notification history cap — 0 means unlimited
	readonly property int notificationMaxHistory: 100
	// Tray defaults
	readonly property var trayHiddenIds: ([])
	readonly property int trayMenuMaxHeight: 400
	// Settings panel component dimensions
	readonly property var settings: {
		"components": {
			"numberButton": {
				"width": 30,
				"height": 30
			},
			"numberDisplay": {
				"width": 60,
				"height": 30
			},
			"select": {
				"width": 100,
				"height": 30
			},
			"toggle": {
				"width": 40,
				"height": 20
			}
		}
	}
	// Bar widget layout defaults
	readonly property var barWidgetLayout: {
		"left": ["launcher", "workspaces", "activeWindow"],
		"center": ["clock"],
		"right": ["network", "vpn", "volume", "battery", "idleInhibitor", "notifications", "tray", "settings", "session"]
	}
	readonly property var barWidgetLayoutPerScreen: ({})
}
