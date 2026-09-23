pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import "../../../services/ui"

// Owns the control center root component for IPC handlers.
//
// IpcHandler cannot hold object-typed properties across IPC, so the Component
// literal lives here (UI layer — services must not import modules) and is
// registered into PopupRegistry. Instantiated in shell.qml via PopupHosts.
QtObject {
    id: root

    property Component menuComponent: Component {
        ControlCenter {
            screenName: PopupRegistry.activeScreen
        }
    }

    Component.onCompleted: PopupRegistry.register("controlcenter", root.menuComponent)
}
