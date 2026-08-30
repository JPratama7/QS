pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import "../../../services/ui"

// Owns the network menu root component for the IPC handler.
//
// IpcHandler cannot hold object-typed properties across IPC, so the Component
// literal lives here (UI layer — services must not import modules) and is
// registered into PopupRegistry. Instantiated in shell.qml.
QtObject {
    id: root

    property Component menuComponent: Component {
        NetworkMenu {
            screenName: PopupRegistry.activeScreen
        }
    }

    Component.onCompleted: PopupRegistry.register("network", root.menuComponent)
}
