pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import "."

Singleton {
    id: root

    // Emitted when a session action is confirmed and ready to execute
    signal actionRequested(action: string)

    // Available action IDs
    readonly property var actions: ["lock", "suspend", "logout", "reboot", "shutdown"]

    function execute(action: string): void {
        root.actionRequested(action);
        switch (action) {
            case "shutdown": Power.shutdown(); break;
            case "reboot":   Power.reboot();   break;
            case "suspend":  Power.suspend();  break;
            case "logout":   Power.logout();   break;
            case "lock":     root._lock();     break;
        }
    }

    function _lock(): void {
        // Stub — requires loginctl/swaylock call
    }
}
