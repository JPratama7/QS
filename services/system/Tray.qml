pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Services.SystemTray
import "../../types"
import "../../config"

Singleton {
    id: root

    // The active tray menu request — item + anchor position
    property TrayMenuRequest activeRequest: null

    function setActiveRequest(item: SystemTrayItem, anchorX: int, anchorY: int): void {
        root.activeRequest = requestFactory.createObject(root, {
            item: item,
            anchorX: anchorX,
            anchorY: anchorY
        });
    }

    Component {
        id: requestFactory
        TrayMenuRequest {}
    }

    // Exposes the live list of system tray items, filtered by hidden IDs config
    readonly property list<SystemTrayItem> items: {
        const all = SystemTray.items.values;
        if (!all) return [];
        const hidden = ShellConfig.trayHiddenIds;
        return all.filter(item => item != null && !hidden.includes(item.id));
    }
}
