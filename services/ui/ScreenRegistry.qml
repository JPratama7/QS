pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import "../../config"
import "../../types"

Singleton {
    id: registry

    readonly property list<ShellScreen> enabledScreens: {
        const excluded = ShellConfig.excludedScreens;
        if (excluded.length === 0)
            return Quickshell.screens;
        return Quickshell.screens.filter(s => !isExcluded(s.name));
    }

    signal screenChanged()

    property var enabledScreensMap: ({})

    function rebuildScreensMap(): void {
        const map = {};
        for (const screen of registry.enabledScreens) {
            map[screen.name] = screen;
        }
        enabledScreensMap = map;
    }

    Component.onCompleted: {
        rebuildScreensMap()

        if (PersistentConfig.adapterView.primaryScreen === "" && registry.enabledScreens.length > 0) {
            const firstScreen = registry.enabledScreens[0];
            PersistentConfig.adapterView.primaryScreen = firstScreen.name;
        }

    }

    Connections {
        target: Quickshell
        function onScreensChanged(): void {
            registry.rebuildScreensMap();
            registry.screenChanged();
        }
    }

    function isExcluded(screenName: string): bool {
        const patterns = ShellConfig.excludedScreens;
        for (const pattern of patterns) {
            if (screenName.match(pattern))
                return true;
        }
        return false;
    }

    function screenByName(screenName: string): var {
        return enabledScreensMap[screenName] || null;
    }

    function createContext(screen: ShellScreen): ScreenContext {
        const context = registry.screenContextComponent.createObject(null, {
            "screen": screen
        }) as ScreenContext;
        if (!context) {
            console.error("Failed to create screen context for screen:", screen.name);
            return null;
        }
        return context;
    }

    property Component screenContextComponent: Component {
        ScreenContext {}
    }
}
