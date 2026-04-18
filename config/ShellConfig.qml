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
}
