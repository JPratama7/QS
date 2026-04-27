pragma Singleton

import QtQuick
import QtQml

QtObject {
    id: defaults

    // Primary screen name (empty string = first screen is treated as primary)
    readonly property string primaryScreen: ""

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
            "workspaces": {
                "showText": true
            },
            "activeWindow": {
                "maxTextWidth": 200
            }
        }
    }

    // Auto-hide trigger defaults
    readonly property int triggerZoneHeight: 4

    // Launcher defaults
    readonly property int launcherWidth: 560
    readonly property int launcherMaxResults: 8

    // Popup defaults
    readonly property int popupEdgeMargin: 8

    // Tray defaults
    readonly property var trayHiddenIds: []
    readonly property int trayMenuMaxHeight: 400

    // Bar widget layout defaults
    readonly property var barWidgetLayout: {
        "left": ["launcher", "workspaces", "activeWindow"],
        "center": ["clock"],
        "right": ["network", "volume", "battery", "idleInhibitor", "notifications", "tray", "session"]
    }
    readonly property var barWidgetLayoutPerScreen: ({})
}
