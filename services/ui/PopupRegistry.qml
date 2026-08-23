pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell

// Registry of popup root components for the IPC handlers.
//
// IpcHandler exports every declared property over IPC, and Quickshell only
// allows void/string/int/bool/real/color across that boundary — holding a
// Component there errors at registration ("Type QQmlComponent* cannot be used
// across IPC"). A service singleton has no such restriction. UI modules
// register their popup roots here at startup; handlers look them up by id.
//
// activeScreen must be set BEFORE ShellUI.openPopup() — the Loader inside
// PopupMenuWindow instantiates the component synchronously, and popup roots
// bind screenName to this property.
Singleton {
    id: root

    // Screen the next popup opens on. Read by popup component bindings at
    // instantiation time, so it must be set before openPopup().
    property string activeScreen: ""

    property var _components: ({})

    function register(id: string, component: Component): void {
        root._components[id] = component;
    }

    function get(id: string): Component {
        return root._components[id];
    }
}
