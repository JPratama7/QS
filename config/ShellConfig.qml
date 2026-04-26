pragma Singleton

import QtQuick

QtObject {
    id: config

    // Bar configuration
    readonly property int barHeight: PersistentConfig.adapter.barHeight
    readonly property string barEdge: PersistentConfig.adapter.barEdge
    readonly property string barDisplayMode: PersistentConfig.adapter.barDisplayMode

    // Auto-hide trigger configuration
    readonly property int triggerZoneHeight: PersistentConfig.adapter.triggerZoneHeight

    // Launcher configuration
    readonly property int launcherWidth: PersistentConfig.adapter.launcherWidth
    readonly property int launcherMaxResults: PersistentConfig.adapter.launcherMaxResults

    // Popup configuration
    readonly property int popupEdgeMargin: PersistentConfig.adapter.popupEdgeMargin

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

    function normalizedBarWidgetLayout(layout: var): var {
        const source = layout || {}
        const seen = ({})

        function uniqueZone(zone: string): var {
            const zoneWidgets = source[zone] || []
            const result = []

            for (const widgetId of zoneWidgets) {
                if (typeof widgetId !== "string" || widgetId === "")
                    continue
                if (seen[widgetId])
                    continue
                seen[widgetId] = true
                result.push(widgetId)
            }

            return result
        }

        return {
            "left": uniqueZone("left"),
            "center": uniqueZone("center"),
            "right": uniqueZone("right")
        }
    }

    function barWidgetLayoutForScreen(screenName: string): var {
        const perScreen = PersistentConfig.adapter.barWidgetLayoutPerScreen
        const layout = (perScreen && perScreen[screenName])
            ? perScreen[screenName]
            : PersistentConfig.adapter.barWidgetLayout
        return config.normalizedBarWidgetLayout(layout)
    }
}
