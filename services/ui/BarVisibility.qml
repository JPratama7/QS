pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import "../../config"
import "../../services/compositor"
import "../../types"

Singleton {
    id: service

    property int hideDelayMs: 300

    // Screen states - ScreenState instances keyed by screen name
    property var screenStates: ({})

    // Hide timers keyed by screen name
    readonly property var _hideTimers: ({})

    // ScreenState component for type-safe instantiation
    Component {
        id: screenStateComponent
        ScreenState {}
    }

    // Timer component - type-safe, no string interpolation
    Component {
        id: hideTimerComponent
        Timer {
            property string screenName
            interval: service.hideDelayMs
            repeat: false
            onTriggered: {
                const state = service.screenStates[screenName];
                if (state && !state.hovered && !state.popupOpen) {
                    state.forceVisible = false;
                }
                service.destroyTimer(screenName);
            }
        }
    }

    function destroyTimer(screenName: string): void {
        const timer = _hideTimers[screenName];
        if (!timer) {
            return;
        }
        timer.stop();
        timer.destroy();
        delete _hideTimers[screenName];
    }

    function initScreenStates(): void {
        const states = {};
        for (const screen of Quickshell.screens) {
            states[screen.name] = screenStateComponent.createObject(service, {
                displayMode: ShellConfig.barDisplayMode
            });
        }
        screenStates = states;
    }

    Component.onCompleted: {
        initScreenStates();
    }

    // Convenience getter for consumers
    function effectiveVisible(screenName: string): bool {
        const state = screenStates[screenName];
        return state ? state.effectiveVisible : true;
    }

    function hoverEnter(screenName: string): void {
        const state = screenStates[screenName];
        if (!state) {
            return;
        }
        state.hovered = true;
    }

    function hoverLeave(screenName: string): void {
        const state = screenStates[screenName];
        if (!state) {
            return;
        }
        state.hovered = false;
        scheduleHide(screenName);
    }

    function popupOpen(screenName: string): void {
        const state = screenStates[screenName];
        if (!state) {
            return;
        }
        state.popupOpen = true;
    }

    function popupClose(screenName: string): void {
        const state = screenStates[screenName];
        if (!state) {
            return;
        }
        state.popupOpen = false;
        scheduleHide(screenName);
    }

    function setForceVisible(screenName: string, value: bool): void {
        const state = screenStates[screenName];
        if (!state) {
            return;
        }
        state.forceVisible = value;
    }

    function setFullscreen(screenName: string, value: bool): void {
        const state = screenStates[screenName];
        if (!state) {
            return;
        }
        state.fullscreen = value;
    }

    function scheduleHide(screenName: string): void {
        destroyTimer(screenName);

        const timer = hideTimerComponent.createObject(service, {
            screenName: screenName
        });
        _hideTimers[screenName] = timer;
        timer.start();
    }

    function cancelHide(screenName: string): void {
        destroyTimer(screenName);
    }

    Connections {
        target: Compositor

        function onActiveToplevelChanged(): void {
            for (const screen of Quickshell.screens) {
                const state = service.screenStates[screen.name];
                if (state) {
                    state.fullscreen = Compositor.screenHasFullscreen(screen.name);
                }
            }
        }
    }

    Connections {
        target: ShellConfig

        function onBarDisplayModeChanged(): void {
            for (const screenName in service.screenStates) {
                service.screenStates[screenName].displayMode = ShellConfig.barDisplayMode;
            }
        }
    }
}
