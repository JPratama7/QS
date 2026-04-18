pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell

Singleton {
    id: root

    // Per-screen active popup id, empty string means none open
    readonly property var _activePopup: ({})

    // Launcher open state (screen name of the screen showing the launcher, or "")
    property string _launcherScreen: ""

    signal activePopupChanged(screenName: string)

    readonly property string launcherScreen: _launcherScreen

    // Returns true if any popup is open on the given screen
    function isPopupOpen(screenName: string): bool {
        return !!root._activePopup[screenName];
    }

    // Returns the active popup id for a screen (empty string if none)
    function activePopup(screenName: string): string {
        return root._activePopup[screenName] ?? "";
    }

    // Open a named popup on a screen, closing any existing one first
    function openPopup(screenName: string, popupId: string): void {
        if (root._activePopup[screenName] === popupId)
            return;
        root._activePopup[screenName] = popupId;
        root.activePopupChanged(screenName);
    }

    // Close the active popup on a screen
    function closePopup(screenName: string): void {
        if (!root._activePopup[screenName])
            return;
        delete root._activePopup[screenName];
        root.activePopupChanged(screenName);
    }

    // Close all open popups across all screens
    function closeAllPopups(): void {
        const keys = Object.keys(root._activePopup);
        if (keys.length === 0)
            return;
        for (const key of keys) {
            delete root._activePopup[key];
            root.activePopupChanged(key);
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
