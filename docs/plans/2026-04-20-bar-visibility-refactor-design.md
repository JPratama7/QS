# BarVisibility Service Refactor Design

**Date:** 2026-04-20
**Status:** Draft

## Problem

Current `BarVisibility.qml` has several issues:

1. **Dynamic timer creation** - `Qt.createQmlObject` with string interpolation is error-prone and untyped
2. **Mutable state object** - Plain JS objects require manual `statesChanged()` signaling
3. **Redundant timer management** - Overlapping cleanup logic across multiple functions
4. **Debug log in production** - `console.log` left in `setPopupOpen`
5. **No type safety** - Screen state is untyped plain object

## Solution

### 1. Typed ScreenState Component

Create `types/ScreenState.qml` as a pure state container:

```qml
// types/ScreenState.qml
pragma ComponentBehavior: Bound

import QtQuick

QtObject {
    id: state

    property bool hovered: false
    property bool popupOpen: false
    property bool forceVisible: false
    property bool fullscreen: false
    property string displayMode: "visible"

    // Reactive property - no manual signaling needed
    readonly property bool effectiveVisible: {
        if (fullscreen && !popupOpen) return false;
        if (displayMode === "visible") return true;
        if (displayMode === "auto_hide") return hovered || popupOpen || forceVisible;
        if (displayMode === "hidden") return false;
        return false;
    }
}
```

**Benefits:**
- Type-safe state
- `effectiveVisible` is reactive via QML property bindings
- No manual `statesChanged()` calls needed

### 2. Component-Based Timer Creation

Replace string-based `Qt.createQmlObject` with `Component.createObject`:

```qml
Component {
    id: hideTimerComponent
    Timer {
        property string screenName
        interval: service.hideDelayMs
        repeat: false
        onTriggered: {
            if (service.screenStates[screenName]) {
                service.screenStates[screenName].forceVisible = false;
            }
            service._destroyTimer(screenName);
        }
    }
}
```

**Benefits:**
- Type-safe timer definition
- No string interpolation for code
- Cleaner lifecycle management

### 3. Screen State Initialization

```qml
property var screenStates: ({})

Component {
    id: screenStateComponent
    ScreenState {}
}

function _initScreenStates(): void {
    const states = {};
    for (const screen of Quickshell.screens) {
        states[screen.name] = screenStateComponent.createObject(service, {
            displayMode: ShellConfig.barDisplayMode
        });
    }
    screenStates = states;
}

Component.onCompleted: {
    _initScreenStates();
}
```

### 4. Config Change Handling

```qml
Connections {
    target: ShellConfig

    function onBarDisplayModeChanged(): void {
        for (const screenName in screenStates) {
            screenStates[screenName].displayMode = ShellConfig.barDisplayMode;
        }
    }
}
```

### 5. Simplified Setter Functions

Setters become direct property assignments (no manual signaling):

```qml
function setHovered(screenName: string, value: bool): void {
    if (screenStates[screenName]) {
        screenStates[screenName].hovered = value;
    }
    if (!value && screenStates[screenName]?.effectiveVisible) {
        scheduleHide(screenName);
    }
}

function setPopupOpen(screenName: string, value: bool): void {
    if (screenStates[screenName]) {
        screenStates[screenName].popupOpen = value;
    }
    if (!value && screenStates[screenName]?.effectiveVisible) {
        scheduleHide(screenName);
    }
}

function setForceVisible(screenName: string, value: bool): void {
    if (screenStates[screenName]) {
        screenStates[screenName].forceVisible = value;
    }
}

function setFullscreen(screenName: string, value: bool): void {
    if (screenStates[screenName]) {
        screenStates[screenName].fullscreen = value;
    }
}
```

### 6. Timer Management

```qml
readonly property var _hideTimers: ({})

function _destroyTimer(screenName: string): void {
    if (_hideTimers[screenName]) {
        _hideTimers[screenName].destroy();
        delete _hideTimers[screenName];
    }
}

function scheduleHide(screenName: string): void {
    _destroyTimer(screenName);

    const timer = hideTimerComponent.createObject(service, {
        screenName: screenName
    });
    _hideTimers[screenName] = timer;
    timer.start();
}

function cancelHide(screenName: string): void {
    _destroyTimer(screenName);
}
```

## Files Changed

| File | Action |
|------|--------|
| `types/ScreenState.qml` | Create |
| `services/ui/BarVisibility.qml` | Refactor |
| `types/qmldir` | Add ScreenState entry |

## Consumer Changes

Consumers (`BarContentWindow`, `BarTriggerZone`, `PopupMenuWindow`) need minimal changes:

- Replace `BarVisibility.effectiveVisible(screenName)` with `BarVisibility.screenStates[screenName].effectiveVisible`
- Or keep wrapper function for convenience

## Verification

1. **Static**: File opens in IDE without unresolved imports
2. **Smoke**: Shell launches without crashing
3. **Interaction**: 
   - Auto-hide bar shows on trigger zone hover, hides after delay
   - Popup keeps bar visible, hides after close + delay
   - Fullscreen app hides bar (unless popup open)
4. **Regression**: Previously working surfaces still load correctly
