# Static Analysis: Memory Allocation

Report generated from review of 58 QML files across `services/`, `modules/`, `config/`, and `components/`.

## Critical Issues

### 1. TrayMenuRequest objects accumulate indefinitely

**Location:** `services/system/Tray.qml:25-35`

**Status:** Fixed

**Problem:** Each call creates a new `TrayMenuRequest` with `root` as parent and overwrites `activeRequest`. The old object is still parented to the `Tray` singleton, so it **never gets destroyed**. Repeated tray menu opens leak memory.

**Fix:** Explicitly destroy the old request before creating a new one.

```qml
function setActiveRequest(item: SystemTrayItem, anchorX: int, anchorY: int): void {
    if (root.activeRequest) {
        root.activeRequest.destroy();
        root.activeRequest = null;
    }
    root.activeRequest = requestFactory.createObject(root, {
        item: item,
        anchorX: anchorX,
        anchorY: anchorY
    });
}
```

---

### 2. LauncherResult objects leak on every search

**Location:** `services/launcher/providers/ApplicationsProvider.qml:31-38`

**Status:** Fixed

```qml
const result = resultFactory.createObject(null, {
    title: app.name,
    subtitle: app.genericName || app.comment || "",
    icon: app.icon || "",
    providerId: provider.providerId,
    data: app.id
});
results.push(result);
```

**Problem:** Results created with `null` parent have no QML object tree ownership. When `Launcher.qml` overwrites `results` on the next query, the old JS array is dropped, but the orphaned QML objects are **not reliably garbage-collected** and leak memory.

**Fix:** Use `provider` as the parent so results have proper lifecycle management within the QML object tree:

```qml
const result = resultFactory.createObject(provider, {
    title: app.name,
    subtitle: app.genericName || app.comment || "",
    icon: app.icon || "",
    providerId: provider.providerId,
    data: app.id
});
```

---

### 3. ScreenContext orphans on screen removal

**Location:** `services/ui/ScreenRegistry.qml:70-78`

**Status:** Fixed

```qml
function createContext(screen: ShellScreen): ScreenContext {
    const context = registry.screenContextComponent.createObject(null, {
        "screen": screen
    }) as ScreenContext;
```

**Problem:** `createObject(null, ...)` gives **no parent**. When the `Variants` delegate in `ScreenShells.qml` is destroyed (screen unplugged), the `context` property goes out of scope, but with no parent the object relies solely on JS GC — which may delay or skip collection for QML objects.

**Fix:** Maintain a `screenContexts` map in `ScreenRegistry`, parent each context to the registry singleton, reuse existing contexts, and explicitly destroy orphaned ones on `Quickshell.screensChanged`:

```qml
property var screenContexts: ({})

function createContext(screen: ShellScreen): ScreenContext {
    if (registry.screenContexts[screen.name]) {
        return registry.screenContexts[screen.name];
    }
    const context = registry.screenContextComponent.createObject(registry, {
        "screen": screen
    }) as ScreenContext;
    registry.screenContexts[screen.name] = context;
    return context;
}

function cleanupScreenContexts(): void {
    const currentNames = new Set(registry.enabledScreens.map(s => s.name));
    const newContexts = {};
    for (const name in registry.screenContexts) {
        if (currentNames.has(name)) {
            newContexts[name] = registry.screenContexts[name];
        } else {
            registry.screenContexts[name].destroy();
        }
    }
    registry.screenContexts = newContexts;
}
```

---

## Medium Issues

### 4. ScreenState objects never rebuilt on screen changes

**Location:** `services/ui/BarVisibility.qml:54-66`

**Status:** Fixed

**Problem:** `initScreenStates()` runs **once** on startup. There is no `Connections` on `Quickshell.screensChanged`. If a screen is removed, its `ScreenState` and any associated `_hideTimers` are **never cleaned up**. If a screen is added later, it gets no state at all (functional bug + leak).

**Fix:** Add a `Connections` block on `Quickshell.screensChanged` that destroys orphaned states/timers and reuses existing ones for still-connected screens.

```qml
Connections {
    target: Quickshell
    function onScreensChanged(): void {
        const currentNames = new Set(Quickshell.screens.map(s => s.name));
        for (const name in service.screenStates) {
            if (!currentNames.has(name)) {
                service.screenStates[name].destroy();
                service.destroyTimer(name);
            }
        }
        const states = {};
        for (const screen of Quickshell.screens) {
            states[screen.name] = service.screenStates[screen.name]
                || screenStateComponent.createObject(service, {
                       displayMode: ShellConfig.barDisplayMode
                   });
        }
        service.screenStates = states;
    }
}
```

---

### 5. Backend Component may leak on fallback path

**Location:** `services/compositor/Compositor.qml:19-29`

```qml
const backendComp = Qt.createComponent(`backends/${compositorType}.qml`);
if (backendComp.status === Component.Ready) {
    service._backend = backendComp.createObject(service);
} else {
    const genericComp = Qt.createComponent("backends/Generic.qml");
    if (genericComp.status === Component.Ready) {
        service._backend = genericComp.createObject(service);
    }
}
```

**Problem:** If `backendComp` fails to load, the `Component` object from `Qt.createComponent()` may leak if not explicitly destroyed. Also, `_backend` is overwritten without destroying any previous value if this code were re-executed.

**Fix:**

```qml
Component.onCompleted: {
    if (service._backend) return;
    let comp = Qt.createComponent(`backends/${compositorType}.qml`);
    if (comp.status !== Component.Ready) {
        console.warn("Backend load failed, falling back to Generic");
        comp.destroy();
        comp = Qt.createComponent("backends/Generic.qml");
    }
    if (comp.status === Component.Ready) {
        service._backend = comp.createObject(service);
    } else {
        console.error("Failed to load any compositor backend");
        comp.destroy();
    }
}
```

---

## Low / Notes

- **`NotificationPopup._expandedMap`** (`modules/popups/notifications/NotificationPopup.qml:19-31`): Prunes correctly on `trackedListChanged`, but relies on that signal firing reliably. The manual emit in `Notification.qml:109` looks correct.

- **Tooltip PopupWindow** (`services/ui/Tooltip.qml:65`): A permanent `PopupWindow` instance exists for the app lifetime. Not a leak, but ~150 lines of UI tree stay resident even when tooltips are idle.

- **IconImage caches** (`NotificationToast.qml`, `NotificationPopup.qml`, `LauncherResultsList.qml`): Dynamic `source` bindings to `AppIcons.iconFromName()` may cause Qt to retain texture cache entries for previously loaded icons. Usually benign.

---

## Summary Table

| Severity | File                                                      | Issue                                            | Fix Complexity |
| -------- | --------------------------------------------------------- | ------------------------------------------------ | -------------- |
| Critical | `services/system/Tray.qml:16`                             | Old `TrayMenuRequest` not destroyed              | 1-line         |
| Critical | `services/launcher/providers/ApplicationsProvider.qml:31` | `LauncherResult` objects parented permanently    | **Fixed**      |
| Critical | `services/ui/ScreenRegistry.qml:71`                       | `ScreenContext` created with `null` parent       | **Fixed**      |
| Medium   | `services/ui/BarVisibility.qml:54`                        | `ScreenState` never rebuilt on screen changes    | Medium         |
| Medium   | `services/compositor/Compositor.qml:19`                   | `Qt.createComponent` without cleanup on fallback | ~3 lines       |
