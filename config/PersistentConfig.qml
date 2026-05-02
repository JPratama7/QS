import QtQuick
import Quickshell
import Quickshell.Io
pragma Singleton

FileView {
    id: configFile

    property alias adapterView: adapter
    // Guard: only write after the initial load has completed (or failed),
    // so that default-value assignments during construction don't overwrite
    // an existing config.json before it is read.
    property bool readyToWrite: false

    path: Quickshell.shellDir + "/config.json"
    watchChanges: true
    onFileChanged: reload()
    Component.onCompleted: {
        reload();
    }
    onLoaded: {
        readyToWrite = true;
    }
    onAdapterUpdated: {
        if (readyToWrite)
            writeAdapter();

    }
    onLoadFailed: {
        // File doesn't exist yet — write defaults to create it
        readyToWrite = true;
        writeAdapter();
    }

    JsonAdapter {
        id: adapter

        property string primaryScreen: Defaults.primaryScreen
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
        property var excludedScreens: []
        property var trayHiddenIds: Defaults.trayHiddenIds
        property int trayMenuMaxHeight: Defaults.trayMenuMaxHeight
        property var barWidgetLayout: Defaults.barWidgetLayout
        property var barWidgetLayoutPerScreen: Defaults.barWidgetLayoutPerScreen
        property var barWidgetScalePerScreen: ({
        })
        property bool idleInhibitor: false
    }

}
