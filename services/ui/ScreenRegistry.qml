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

    function isExcluded(screenName: string): bool {
        const patterns = ShellConfig.excludedScreens;
        for (let i = 0; i < patterns.length; i++) {
            if (screenName.match(patterns[i]))
                return true;
        }
        return false;
    }

    function screenByName(screenName: string): var {
        for (let i = 0; i < enabledScreens.length; i++) {
            if (enabledScreens[i].name === screenName)
                return enabledScreens[i];
        }
        return null;
    }

    function createContext(screen: ShellScreen): ScreenContext {
        const context = registry.screenContextComponent.createObject(null, { "screen": screen }) as ScreenContext;
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
