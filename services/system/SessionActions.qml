pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import "../compositor"
import "."

Singleton {
    id: root

    // Available action IDs
    readonly property var actions: ["suspend", "logout", "reboot", "shutdown"]

    function execute(action: string): void {
        switch (action) {
            case "shutdown": Power.shutdown(); break;
            case "reboot":   Power.reboot();   break;
            case "suspend":  Power.suspend();  break;
            case "logout":   Compositor.logout(); break;
        }
    }
}
