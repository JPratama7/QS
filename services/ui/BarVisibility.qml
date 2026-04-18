pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import "../../config"

Singleton {
    id: service

    property int hideDelayMs: 300

    // Per-screen visibility state, keyed by screen name
    readonly property var states: {
        const result = {};
        const screens = Quickshell.screens;
        for (let i = 0; i < screens.length; i++) {
            const name = screens[i].name;
            result[name] = {
                "displayMode": ShellConfig.barDisplayMode,
                "hovered": false,
                "popupOpen": false,
                "forceVisible": false
            };
        }
        return result;
    }

    function displayMode(screenName: string): string {
        if (states[screenName]) return states[screenName].displayMode;
        return ShellConfig.barDisplayMode;
    }

    function setHovered(screenName: string, value: bool): void {
        if (states[screenName]) states[screenName].hovered = value;
        service.statesChanged();
        if (!value && service.effectiveVisible(screenName)) {
            service.scheduleHide(screenName);
        }
    }

    function setPopupOpen(screenName: string, value: bool): void {
        if (states[screenName]) states[screenName].popupOpen = value;
        service.statesChanged();
        if (!value && service.effectiveVisible(screenName)) {
            service.scheduleHide(screenName);
        }
    }

    function setForceVisible(screenName: string, value: bool): void {
        if (states[screenName]) states[screenName].forceVisible = value;
        service.statesChanged();
    }

    function effectiveVisible(screenName: string): bool {
        const state = states[screenName];
        if (!state) return true;

        if (state.displayMode === "visible") return true;
        if (state.displayMode === "auto_hide") {
            return state.hovered || state.popupOpen || state.forceVisible;
        }
        if (state.displayMode === "hidden") return false;
        return false; // Safe default for unrecognized modes
    }

    // Per-screen hide timers
    readonly property var _hideTimers: ({})

    function scheduleHide(screenName: string): void {
        // Cancel and destroy existing timer if any
        if (_hideTimers[screenName]) {
            _hideTimers[screenName].stop();
            _hideTimers[screenName].destroy();
            delete _hideTimers[screenName];
        }

        const timer = Qt.createQmlObject(
            "import QtQuick; Timer { interval: " + service.hideDelayMs + "; repeat: false; onTriggered: { service.setForceVisible('" + screenName + "', false); service._cleanTimer('" + screenName + "'); } }",
            service,
            "hideTimer-" + screenName
        );
        _hideTimers[screenName] = timer;
        timer.start();
    }

    function _cleanTimer(screenName: string): void {
        if (_hideTimers[screenName]) {
            _hideTimers[screenName].destroy();
            delete _hideTimers[screenName];
        }
    }

    function cancelHide(screenName: string): void {
        if (_hideTimers[screenName]) {
            _hideTimers[screenName].stop();
            _hideTimers[screenName].destroy();
            delete _hideTimers[screenName];
        }
    }
}
