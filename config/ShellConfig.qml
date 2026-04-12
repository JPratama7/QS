pragma Singleton

import QtQuick
import QtQml

QtObject {
    id: config

    // Bar configuration
    readonly property int barHeight: Defaults.barHeight
    readonly property string barEdge: Defaults.barEdge
    readonly property string barDisplayMode: Defaults.barDisplayMode

    // Auto-hide trigger configuration
    readonly property int triggerZoneHeight: Defaults.triggerZoneHeight

    // Launcher configuration
    readonly property int launcherWidth: Defaults.launcherWidth
    readonly property int launcherMaxResults: Defaults.launcherMaxResults

    // Popup configuration
    readonly property int popupEdgeMargin: Defaults.popupEdgeMargin

    // Primary screen name — used by ScreenContext.isPrimary
    readonly property string primaryScreen: Defaults.primaryScreen

    // Screen exclusion list (regex patterns)
    readonly property var excludedScreens: []
}
