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

    // Track known screens for removal detection
    property var _knownScreenNames: ([])

    // Emitted when a widget requests a popup — carries the component to render and anchor X
    signal popupRequested(screenName: string, popupId: string, component: var, anchorX: int)

    // Emitted when a popup should close
    signal popupClosed(screenName: string)

    // Emitted when launcher opens/closes on a screen
    signal launcherOpened(screenName: string)
    signal launcherClosed()

    readonly property string launcherScreen: _launcherScreen

    // Detect screen removal and clean up state
    Connections {
        target: Quickshell

        function onScreensChanged(): void {
            const currentNames = Quickshell.screens.map(s => s.name);
            const removed = root._knownScreenNames.filter(name => !currentNames.includes(name));

            // Close popup/launcher on removed screens
            for (const name of removed) {
                if (root._openScreens[name]) {
                    root.closePopup(name);
                }
                if (root._launcherScreen === name) {
                    root.closeLauncher();
                }
            }

            root._knownScreenNames = currentNames;
        }
    }

    Component.onCompleted: {
        root._knownScreenNames = Quickshell.screens.map(s => s.name);
    }

    // Open a named popup on a screen with the component to render and optional anchor X position
    function openPopup(screenName: string, popupId: string, component: var, anchorX: int): void {
        // Close launcher if open on any screen
        if (root._launcherScreen !== "") {
            root.closeLauncher();
        }
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

    // Launcher open/close
    function openLauncher(screenName: string): void {
        // Close all popups first
        root.closeAllPopups();
        root._launcherScreen = screenName;
        root.launcherOpened(screenName);
    }

    function closeLauncher(): void {
        root._launcherScreen = "";
        root.launcherClosed();
    }

    function isLauncherOpen(): bool {
        return root._launcherScreen !== "";
    }
}
