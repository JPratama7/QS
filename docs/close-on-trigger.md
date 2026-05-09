# Popup Close on Menu Item Triggered

Research findings on how other Quickshell configs implement closing popups when menu items are triggered.

## Found Patterns

### 1. QsMenuAnchor (Built-in Platform Menus)

Quickshell's built-in `QsMenuAnchor` for native platform menus:

```qml
QsMenuAnchor {
    anchor.window: parentWindow
    menu: someMenuHandle
    
    // Functions
    close()  // Close the open menu
    open()   // Open the menu
    
    // Signals
    onClosed: { /* menu closed */ }
    onOpened: { /* menu opened */ }
}
```

**Usage**: Used with `SystemTrayItem.menu` for native platform menus. Not applicable to custom QML DBusMenu implementations.

**Reference**: https://quickshell.org/docs/types/Quickshell/QsMenuAnchor

### 2. HyprlandFocusGrab Pattern

From `quickshell-popups` config:

```qml
FloatingWindow {
    id: win
    
    HyprlandFocusGrab {
        id: grab
        windows: [win]
        active: false
        onCleared: Qt.quit()  // or cleanup code
    }
    
    Timer {
        interval: 500
        running: true
        onTriggered: grab.active = true
    }
}
```

**Pattern**: Detects when focus leaves the window and performs cleanup. Useful for overlay popups that should close on focus loss.

### 3. Direct Visible Control

Common pattern across configs:

```qml
// Direct assignment
popupWindow.visible = false

// Or via close function if available
popupWindow.close()
```

## Our Architecture

Our `PopupMenuWindow.qml` already has infrastructure for popup lifecycle:

```qml
PopupWindow {
    id: popupWindow
    
    // Dismiss on click outside
    grabFocus: true
    
    property var activeComponent: null
    visible: popupWindow.activeComponent !== null
    
    Connections {
        target: ShellUI
        
        function onPopupRequested(screenName, popupId, component, anchorX) {
            if (screenName !== popupWindow.context.name) return;
            popupWindow.anchorX = anchorX;
            popupWindow.activeComponent = component;
            BarVisibility.popupOpen(screenName);
        }
        
        function onPopupClosed(screenName) {
            if (screenName !== popupWindow.context.name) return;
            popupWindow.activeComponent = null;
            BarVisibility.popupClose(screenName);
        }
    }
    
    // Detect external dismissal (click outside, Escape, focus loss)
    onVisibleChanged: {
        if (!visible && activeComponent !== null) {
            ShellUI.closePopup(context.name);
        }
    }
}
```

**Current behavior**:
- `grabFocus: true` enables click-outside dismissal
- `onVisibleChanged` detects external dismissal and calls `ShellUI.closePopup()`
- ShellUI coordinates popup lifecycle via `popupRequested`/`popupClosed` signals

## Recommended Implementation

To close popup when menu item is triggered:

### Step 1: Emit `triggered()` signal from TrayMenuItem

```qml
// modules/popups/TrayMenuItem.qml
MouseArea {
    id: hoverArea
    anchors.fill: parent
    hoverEnabled: true
    enabled: !root.isSeparator && (root.entry?.enabled ?? false)
    
    onClicked: {
        if (!root.entry) return;
        if (root.entry.hasChildren)
            root.submenuRequested(root.entry);
        else {
            root.entry.triggered();
            root.triggered();  // Emit local signal
        }
    }
}
```

### Step 2: Connect to signal in parent (TrayMenuPage or TrayMenu)

```qml
// In TrayMenuPage.qml or where TrayMenuItem is used
Connections {
    target: trayMenuItem  // your TrayMenuItem instance
    function onTriggered() {
        ShellUI.closePopup(root.screenName);
    }
}
```

**Alternative**: Pass screenName to TrayMenuItem and close directly:

```qml
// TrayMenuItem.qml
required property string screenName

onClicked: {
    if (!root.entry) return;
    if (root.entry.hasChildren)
        root.submenuRequested(root.entry);
    else {
        root.entry.triggered();
        root.triggered();
        ShellUI.closePopup(root.screenName);  // Close directly
    }
}
```

## Current Crash Issue

After implementing the close-on-trigger pattern, experiencing crash:

```
[destroyed object]: error 0: Invalid size
  WARN: The Wayland connection experienced a fatal error: Protocol error
```

### Attempted Fix

Added `_internalClose` flag to prevent recursive close loop in `PopupMenuWindow.qml`:

```qml
property bool _internalClose: false

function onPopupClosed(screenName: string) {
    if (screenName !== popupWindow.context.name)
        return;
    popupWindow._internalClose = true;
    popupWindow.activeComponent = null;
    BarVisibility.popupClose(screenName);
}

onVisibleChanged: {
    if (!visible && activeComponent !== null && !_internalClose) {
        ShellUI.closePopup(context.name);
    }
    if (!visible) {
        _internalClose = false;
    }
}
```

**Status**: Still crashing despite this fix.

### 5 Possible Causes

1. **Loader destruction timing issue**
   - The Loader might be destroying the component while something is still trying to access its size/properties
   - `implicitWidth` and `implicitHeight` calculations (lines 24-25) access `popupContent.item` which might be null during destruction
   - Accessing destroyed object properties causes Wayland protocol error

2. **DBusMenuItem.triggered() side effects**
   - Calling `root.entry.triggered()` (line 100 in TrayMenuItem.qml) might have side effects
   - The DBusMenuItem might trigger async operations that interact poorly with popup closing
   - DBus callbacks might try to access UI elements after they're destroyed

3. **StackView navigation during close**
   - If submenu navigation is happening, StackView might be in inconsistent state
   - Pushing/popping pages while popup is closing could cause destruction race conditions
   - StackView transitions might reference destroyed items

4. **Window size calculation during destruction**
   - PopupWindow's implicit size calculations might access destroyed content
   - Wayland layer shell might query window size after content is destroyed
   - Size queries on destroyed objects cause "Invalid size" error

5. **Signal emission after object destruction**
   - The `triggered()` signal might be emitted after TrayMenuItem is being destroyed
   - Signal handlers might access properties of destroyed objects
   - QML signal connections might not be properly disconnected during destruction

### Debugging Next Steps

1. Add null checks before accessing `popupContent.item` properties
2. Try closing popup with a delay (Qt.callLater) to let click event finish
3. Add logging to trace destruction order
4. Test if crash happens without calling `root.entry.triggered()`
5. Check if crash only happens with submenu items

## All Possible Issues

### 1. Loader Destruction Timing

**Problem**: `PopupMenuWindow` binds `implicitWidth`/`implicitHeight` to Loader's content at construction:
```qml
implicitWidth: popupContent.item ? popupContent.item.implicitWidth : 0
implicitHeight: popupContent.item ? popupContent.item.implicitHeight : 0
```
These are Q_PROPERTY bindings — evaluated when `activeComponent` changes. When `activeComponent = null`, Loader sets `sourceComponent = null`, destroying the loaded item. But the binding may re-evaluate during destruction, accessing a half-destroyed object.

**Fix**: Use functions instead of property bindings:
```qml
function getImplicitWidth() { return popupContent.item ? popupContent.item.implicitWidth : 0 }
function getImplicitHeight() { return popupContent.item ? popupContent.item.implicitHeight : 0 }
```
Or defer size reset:
```qml
onActiveComponentChanged: {
    if (activeComponent === null) {
        Qt.callLater(() => { implicitWidth = 0; implicitHeight = 0; });
    }
}
```

### 2. DBusMenuItem.triggered() Async Side Effects

**Problem**: `root.entry.triggered()` is a DBus call. DBus invocations are async and may have callbacks that try to access the menu/popup after destruction begins. The Wayland protocol error may be triggered by DBus callbacks attempting to interact with a closing window.

**Fix**: Defer the trigger call:
```qml
onClicked: {
    if (!root.entry) return;
    if (root.entry.hasChildren) {
        root.submenuRequested(root.entry);
    } else {
        Qt.callLater(() => root.entry.triggered());
        root.triggered();
    }
}
```
Separating `entry.triggered()` into a deferred call prevents DBus callback races during close.

### 3. ShellUI.closePopup() -> visible:false -> Loader Recursive Loop

**Problem**: When `ShellUI.closePopup()` sets `activeComponent = null`, the `visible` binding `popupWindow.activeComponent !== null` becomes `false`. But if `_internalClose` flag reset happens before Loader destruction completes, `onVisibleChanged` may fire, see `activeComponent === null`, `_internalClose === false`, and call `ShellUI.closePopup()` again. This creates a recursive close loop that can destabilize the window.

**Fix**: Ensure `_internalClose` stays `true` until after Loader fully destroys content:
```qml
Connections {
    target: ShellUI
    function onPopupClosed(screenName: string) {
        if (screenName !== popupWindow.context.name) return;
        _internalClose = true;
        // Defer activeComponent = null to let Loader clean up in peace
        Qt.callLater(() => {
            activeComponent = null;
            BarVisibility.popupClose(screenName);
        });
    }
}

onVisibleChanged: {
    if (!visible && activeComponent !== null && !_internalClose) {
        ShellUI.closePopup(context.name);
    }
    // Only reset flag after truly closed
    if (visible) {
        _internalClose = false;
    }
}
```

### 4. StackView Page Destruction Accessing Parent

**Problem**: `TrayMenuPage` has `required property StackView stackView`. When `TrayMenuItem.onTriggered` fires during a submenu session (StackView depth > 1), closing the popup destroys all pages including the current one. But the `stackView` property is `required` — QML may try to resolve it during destruction and fail.

**Fix**: Remove `required` from StackView, make it optional with fallback:
```qml
property StackView stackView: null
```
Or defer close to ensure click event fully resolves before destruction begins.

### 5. Wayland Layer Shell Size Query After Content Destroyed

**Problem**: Quickshell's `PopupWindow` is a layer-shell surface. The Wayland compositor may query `configure` events with size during the close sequence. If the Loader destroys content but the layer-shell hasn't yet processed the `close` event, the compositor may try to set a size on a window without content, causing "Invalid size" protocol error.

**Fix**: Keep content alive until Wayland confirms close:
```qml
onActiveComponentChanged: {
    if (activeComponent === null) {
        // Hold reference to prevent GC while Wayland processes close
        _pendingClose = true;
        Qt.callLater(() => {
            if (_pendingClose) {
                _pendingClose = false;
            }
        });
    }
}
```
Or use `Component.onDestruction` to delay cleanup:
```qml
Component.onDestruction: {
    // Ensure window is fully closed before cleanup
}
```

### 6. Signal QML Connection Lifetime Mismatch

**Problem**: `TrayMenuPage` connects to `TrayMenuItem`'s `onTriggered`. When TrayMenuItem is destroyed (during popup close), the signal connection may linger. If the signal is emitted during QML's object destruction phase, the handler (`ShellUI.closePopup`) runs on an object already being torn down.

**Fix**: Use `Connections` with explicit target and `enabled` property:
```qml
Connections {
    target: trayMenuItem
    enabled: trayMenuItem !== null && !trayMenuItem.destroying
    function onTriggered() {
        ShellUI.closePopup(page.screenName);
    }
}
```
Or use `Qt.callLater` in TrayMenuPage's onTriggered handler to defer the close one more tick.

### 7. Multiple Rapid Click Events

**Problem**: User double-clicks or clicks multiple menu items rapidly. First click triggers close sequence. Second click fires before destruction completes, re-opening the popup with a stale or partially-destroyed component.

**Fix**: Debounce / guard against re-entry:
```qml
property bool _closing: false

onTriggered: {
    if (_closing) return;
    _closing = true;
    Qt.callLater(() => {
        ShellUI.closePopup(page.screenName);
        _closing = false;
    });
}
```

### 8. PopupMenuWindow vs TrayMenuPage ScreenName Mismatch

**Problem**: `TrayMenuPage` passes `page.screenName` to `ShellUI.closePopup()`. This comes from `TrayMenuItem` delegation props. If screen rotation or output change happens mid-session, the `screenName` may no longer match `PopupMenuWindow.context.name`, causing the close to silently no-op while the popup remains open.

**Fix**: Verify screen name matches before closing:
```qml
onTriggered: {
    if (page.screenName !== popupWindow?.context?.name) return;
    Qt.callLater(ShellUI.closePopup, page.screenName);
}

// ...

## Key Pattern Summary

// ...

## Other Quickshell Config Implementations

### caelestia-dots/shell

**Location**: `modules/bar/components/TrayItem.qml`

**Approach**: No menu implementation - direct activation only.

```qml
MouseArea {
    id: root
    required property SystemTrayItem modelData

    onClicked: event => {
        if (event.button === Qt.LeftButton)
            modelData.activate();
        else
            modelData.secondaryActivate();
    }
}
```

**Key insight**: Caelestia doesn't implement system tray menus at all - they just activate the tray item directly on click. This is the simplest approach but doesn't support menu-based applications.

### end-4/dots-hyprland

**Location**: `modules/ii/bar/SysTrayMenuEntry.qml` and `SysTrayMenu.qml`

**Approach**: Signal-based pattern with parent handling close.

**SysTrayMenuEntry.qml** (menu item):
```qml
signal dismiss()
signal openSubmenu(handle: QsMenuHandle)

releaseAction: () => {
    if (menuEntry.hasChildren) {
        root.openSubmenu(root.menuEntry);
        return;
    }
    menuEntry.triggered();
    root.dismiss();
}
```

**SysTrayMenu.qml** (parent menu):
```qml
function close() {
    root.visible = false;
    while (stackView.depth > 1)
        stackView.pop();
    root.menuClosed();
}

// In the Repeater delegate:
delegate: SysTrayMenuEntry {
    // ...
    onDismiss: root.close()
    onOpenSubmenu: handle => {
        stackView.push(subMenuComponent.createObject(null, {
            handle: handle,
            isSubMenu: true
        }));
    }
}
```

**Key insight**: End-4 uses a signal (`dismiss()`) to communicate from the menu entry to the parent menu. The parent then handles the close by setting `visible = false` and managing the StackView. This decouples the close logic from the menu item.

### noctalia-dev/noctalia-shell

**Location**: `Modules/Bar/Widgets/Tray.qml`

**Approach**: Shared popup menu window via PanelService, close before activate.

```qml
onClicked: mouse => {
    if (!modelData) return;

    if (mouse.button === Qt.LeftButton) {
        // Close any open menu first
        if (popupMenuWindow) {
            popupMenuWindow.close();
        }

        if (!modelData.onlyMenu) {
            modelData.activate();
        }
    } else if (mouse.button === Qt.RightButton) {
        TooltipService.hideImmediately();

        // Close the menu if it was visible
        if (popupMenuWindow && popupMenuWindow.visible) {
            popupMenuWindow.close();
            return;
        }

        // Close any opened panel
        if ((PanelService.openedPanel !== null) && !PanelService.openedPanel.isClosing) {
            PanelService.openedPanel.close();
        }

        if (modelData.hasMenu && modelData.menu && trayMenu && trayMenu.item) {
            // Calculate and show menu position
            const calculateAndShow = () => {
                // ... positioning logic ...
                PanelService.showTrayMenu(root.screen, modelData, trayMenu.item, tooltipAnchor, menuX, menuY, root.section, root.sectionWidgetIndex);
            };
            Qt.callLater(calculateAndShow);
        }
    }
}
```

**Key insight**: Noctalia uses a centralized service (`PanelService`) to manage popup menus. They explicitly close any open menu before activating or showing a new one. The menu itself is managed through the service, not directly by the tray widget.

### Key Differences Summary

- **caelestia**: No menu - direct activation only
- **rdnamil**: Custom PopupMenu with explicit `menuAnchor.close()` call
- **tripathiji**: Native `QsMenuAnchor` with automatic close behavior
- **end-4**: Signal-based pattern (`dismiss()` signal) with parent handling close
- **noctalia**: Centralized PanelService manages menu lifecycle, close before activate
- **Your approach**: Using ShellUI.closePopup() with custom DBusMenu implementation

### Recommendation Based on Research

The **end-4 signal-based pattern** is most similar to your architecture and avoids the direct function call that may be causing the crash. Consider:

1. Adding a `dismiss()` signal to `TrayMenuItem`
2. Having `TrayMenuPage` or `TrayMenu` handle the signal and call `ShellUI.closePopup()`
3. This decouples the close logic from the menu item itself

Alternatively, the **noctalia pattern** of closing before activation could work:
- Close the popup first
- Then trigger the action
- This ensures the popup is fully closed before any side effects occur

## References
