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
	// Clock format — preset whitelisted in ShellConfig.timeFormat
	readonly property string timeFormat: "hh:mm ddd"
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
				"showText": false
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
	readonly property int launcherWidth: 640
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
	// Transparency — percent opacities for the glass surfaces (bar, popups, overlay scrims)
	readonly property var transparency: {
		"bar": 85,
		"popup": 85,
		"overlay": 85
	}
	// Control center feature flags — stub toggles hidden until real backends exist
	readonly property var controlCenter: {
		"showBluetoothStub": false,
		"showNightLightStub": false
	}
	// Tray defaults
	readonly property var trayHiddenIds: ([])
	readonly property int trayMenuMaxHeight: 400
	// Bar widget layout defaults
	readonly property var barWidgetLayout: {
		"left": ["launcher", "workspaces", "activeWindow"],
		"center": ["clock"],
		"right": ["vpn", "idleInhibitor", "controlcenter", "settings", "session"]
	}
	readonly property var barWidgetLayoutPerScreen: ({})
}
