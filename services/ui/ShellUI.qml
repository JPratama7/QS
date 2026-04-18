pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell

Singleton {
    id: root

    // Tracks which screens have an open popup — used only by closeAllPopups()
    property var _openScreens: ({})

    // Launcher open state (screen name of the screen showing the launcher, or "")
    property string _launcherScreen: ""

    // Emitted when a widget requests a popup — carries the component to render and anchor X
    signal popupRequested(screenName: string, popupId: string, component: var, anchorX: int)

    // Emitted when a popup should close
    signal popupClosed(screenName: string)

    readonly property string launcherScreen: _launcherScreen

    // Open a named popup on a screen with the component to render and optional anchor X position
    function openPopup(screenName: string, popupId: string, component: var, anchorX: int): void {
        root._openScreens[screenName] = true;
        root.popupRequested(screenName, popupId, component, anchorX);
    }

    // Close the active popup on a screen
    function closePopup(screenName: string): void {
        if (!root._openScreens[screenName])
            return;
        delete root._openScreens[screenName];
        root.popupClosed(screenName);
    }

    // Close all open popups across all screens
    function closeAllPopups(): void {
        const keys = Object.keys(root._openScreens);
        if (keys.length === 0)
            return;
        for (const key of keys) {
            delete root._openScreens[key];
            root.popupClosed(key);
        }
    }

    // Launcher open/close — placeholder for Task 5.4
    function openLauncher(screenName: string): void {
        root._launcherScreen = screenName;
    }

    function closeLauncher(): void {
        root._launcherScreen = "";
    }

    function isLauncherOpen(): bool {
        return root._launcherScreen !== "";
    }
}
