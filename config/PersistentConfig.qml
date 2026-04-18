pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

FileView {
    id: configFile

    path: Quickshell.shellDir + "/config.json"
    watchChanges: true

    onFileChanged: reload()

    JsonAdapter {
        id: adapter

        property string primaryScreen: Defaults.primaryScreen
        property int barHeight: Defaults.barHeight
        property string barEdge: Defaults.barEdge
        property string barDisplayMode: Defaults.barDisplayMode
        property int triggerZoneHeight: Defaults.triggerZoneHeight
        property int launcherWidth: Defaults.launcherWidth
        property int launcherMaxResults: Defaults.launcherMaxResults
        property int popupEdgeMargin: Defaults.popupEdgeMargin
        property var excludedScreens: []
        property var trayHiddenIds: Defaults.trayHiddenIds
        property int trayMenuMaxHeight: Defaults.trayMenuMaxHeight
    }

    onAdapterUpdated: writeAdapter()

    onLoadFailed: writeAdapter()

    Component.onCompleted: reload()
}
