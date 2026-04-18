pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Services.SystemTray

Singleton {
    id: root

    // Exposes the live list of system tray items, re-evaluated when the item list changes
    readonly property var items: {
        const all = SystemTray.items.values;
        return all ? all.filter(item => item != null) : [];
    }
}
