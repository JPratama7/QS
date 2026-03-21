import "../types/services" as ServicesTypes
import "../types/widgets" as WidgetsTypes
import QtQuick
import Quickshell
import Quickshell.Io
pragma Singleton

// State storage for all services and widgets
Singleton {
    id: root

    property url statePath: ""
    property bool initialized: false

    FileView {
        id: stateFileView

        path: root.statePath
        watchChanges: true
        onFileChanged: reload()
        onAdapterUpdated: writeAdapter()

        JsonAdapter {
            property ServicesTypes.Services services
            property WidgetsTypes.Widgets widgets

            services: ServicesTypes.Services {
            }

            widgets: WidgetsTypes.Widgets {
            }

        }

    }

}
