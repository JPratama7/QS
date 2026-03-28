pragma Singleton
import Quickshell
import Quickshell.Io

import QtQuick
import "../services" as Services
import "../types/services" as ServicesTypes
import "../types/widgets" as WidgetsTypes

Singleton {
    id: root

    // Expose storeFileView for external access
    property alias storeFileView: storeFileView

    // Bar Position Enum
    enum Position {
        Top,
        Bottom,
        Left,
        Right
    }

    // Shorthand reference to state path (may be undefined during init)
    readonly property var storeConfig: storeFileView.state.widgets?.bar?.config || null

    // Status flag (always true since state is loaded
    readonly property bool isLoaded: true

    // Bar Layout Configuration - Bind to state with fallback defaults
    property int position: root.storeConfig?.position ?? 0
    property int barSize: root.storeConfig?.barSize ?? 32
    property int barMargin: root.storeConfig?.barMargin ?? 0
    property int barRadius: root.storeConfig?.barRadius ?? 0

    // Widget Visibility Toggles - Bind to state with fallback defaults
    property bool showWorkspaces: root.storeConfig?.showWorkspaces ?? true
    property bool showWindowTitle: root.storeConfig?.showWindowTitle ?? true
    property bool showSystemMonitor: root.storeConfig?.showSystemMonitor ?? true
    property bool showNetwork: root.storeConfig?.showNetwork ?? true
    property bool showBluetooth: root.storeConfig?.showBluetooth ?? true
    property bool showBattery: root.storeConfig?.showBattery ?? true
    property bool showAudio: root.storeConfig?.showAudio ?? true
    property bool showBrightness: root.storeConfig?.showBrightness ?? true
    property bool showNightShift: root.storeConfig?.showNightShift ?? true
    property bool showCaffeine: root.storeConfig?.showCaffeine ?? true
    property bool showClock: root.storeConfig?.showClock ?? true

    // Widget Order - Bind to state with fallback default
    property var widgetOrder: root.storeConfig?.widgetOrder ?? ["workspaces", "windowTitle", "systemMonitor", "network", "bluetooth", "battery", "audio", "brightness", "nightShift", "caffeine", "clock"]

    // Animation Settings - Bind to state with fallback defaults
    property int animationDuration: root.storeConfig?.animationDuration ?? 150
    property int popupAnimationDuration: root.storeConfig?.popupAnimationDuration ?? 200

    // Popup Settings - Bind to state with fallback defaults
    property int popupWidth: root.storeConfig?.popupWidth ?? 320
    property int popupHeight: root.storeConfig?.popupHeight ?? 400
    property bool popupAutoClose: root.storeConfig?.popupAutoClose ?? true

    // Write-through: update state when properties change (only if storeConfig is ready)
    onPositionChanged: if (root.storeConfig) { root.storeConfig.position = position; storeFileView.saveState() }
    onBarSizeChanged: if (root.storeConfig) { root.storeConfig.barSize = barSize; storeFileView.saveState() }
    onBarMarginChanged: if (root.storeConfig) { root.storeConfig.barMargin = barMargin; storeFileView.saveState() }
    onBarRadiusChanged: if (root.storeConfig) { root.storeConfig.barRadius = barRadius; storeFileView.saveState() }
    onShowWorkspacesChanged: if (root.storeConfig) { root.storeConfig.showWorkspaces = showWorkspaces; storeFileView.saveState() }
    onShowWindowTitleChanged: if (root.storeConfig) { root.storeConfig.showWindowTitle = showWindowTitle; storeFileView.saveState() }
    onShowSystemMonitorChanged: if (root.storeConfig) { root.storeConfig.showSystemMonitor = showSystemMonitor; storeFileView.saveState() }
    onShowNetworkChanged: if (root.storeConfig) { root.storeConfig.showNetwork = showNetwork; storeFileView.saveState() }
    onShowBluetoothChanged: if (root.storeConfig) { root.storeConfig.showBluetooth = showBluetooth; storeFileView.saveState() }
    onShowBatteryChanged: if (root.storeConfig) { root.storeConfig.showBattery = showBattery; storeFileView.saveState() }
    onShowAudioChanged: if (root.storeConfig) { root.storeConfig.showAudio = showAudio; storeFileView.saveState() }
    onShowBrightnessChanged: if (root.storeConfig) { root.storeConfig.showBrightness = showBrightness; storeFileView.saveState() }
    onShowNightShiftChanged: if (root.storeConfig) { root.storeConfig.showNightShift = showNightShift; storeFileView.saveState() }
    onShowCaffeineChanged: if (root.storeConfig) { root.storeConfig.showCaffeine = showCaffeine; storeFileView.saveState() }
    onShowClockChanged: if (root.storeConfig) { root.storeConfig.showClock = showClock; storeFileView.saveState() }
    onWidgetOrderChanged: if (root.storeConfig) { root.storeConfig.widgetOrder = widgetOrder; storeFileView.saveState() }
    onAnimationDurationChanged: if (root.storeConfig) { root.storeConfig.animationDuration = animationDuration; storeFileView.saveState() }
    onPopupAnimationDurationChanged: if (root.storeConfig) { root.storeConfig.popupAnimationDuration = popupAnimationDuration; storeFileView.saveState() }
    onPopupWidthChanged: if (root.storeConfig) { root.storeConfig.popupWidth = popupWidth; storeFileView.saveState() }
    onPopupHeightChanged: if (root.storeConfig) { root.storeConfig.popupHeight = popupHeight; storeFileView.saveState() }
    onPopupAutoCloseChanged: if (root.storeConfig) { root.storeConfig.popupAutoClose = popupAutoClose; storeFileView.saveState() }

    // Layout Configuration - Bind to state with fallback defaults
    property var layoutLeft: root.storeConfig?.layoutLeft ?? ["workspaces", "windowTitle"]
    property var layoutCenter: root.storeConfig?.layoutCenter ?? []
    property var layoutRight: root.storeConfig?.layoutRight ?? ["systemMonitor", "network", "bluetooth", "battery", "audio", "brightness", "nightShift", "caffeine", "tray", "clock"]

    // Sizes Configuration - Bind to state with fallback defaults
    property int iconSize: root.storeConfig?.sizes?.icon ?? 14
    property int iconSizeLarge: root.storeConfig?.sizes?.iconLarge ?? 18
    property int iconSizeSmall: root.storeConfig?.sizes?.iconSmall ?? 12
    property int textSize: root.storeConfig?.sizes?.text ?? 11
    property int textSizeSmall: root.storeConfig?.sizes?.textSmall ?? 10
    property int textSizeLarge: root.storeConfig?.sizes?.textLarge ?? 13
    property int textSizeXLarge: root.storeConfig?.sizes?.textXLarge ?? 15
    property int textSizeXSmall: root.storeConfig?.sizes?.textXSmall ?? 8

    // Layout helper object for compatibility
    readonly property var layout: ({
        left: layoutLeft,
        center: layoutCenter,
        right: layoutRight
    })

    onLayoutLeftChanged: if (root.storeConfig) { root.storeConfig.layoutLeft = layoutLeft; storeFileView.saveState() }
    onLayoutCenterChanged: if (root.storeConfig) { root.storeConfig.layoutCenter = layoutCenter; storeFileView.saveState() }
    onLayoutRightChanged: if (root.storeConfig) { root.storeConfig.layoutRight = layoutRight; storeFileView.saveState() }
    onIconSizeChanged: if (root.storeConfig?.sizes) { root.storeConfig.sizes.icon = iconSize; storeFileView.saveState() }
    onIconSizeLargeChanged: if (root.storeConfig?.sizes) { root.storeConfig.sizes.iconLarge = iconSizeLarge; storeFileView.saveState() }
    onIconSizeSmallChanged: if (root.storeConfig?.sizes) { root.storeConfig.sizes.iconSmall = iconSizeSmall; storeFileView.saveState() }
    onTextSizeChanged: if (root.storeConfig?.sizes) { root.storeConfig.sizes.text = textSize; storeFileView.saveState() }
    onTextSizeSmallChanged: if (root.storeConfig?.sizes) { root.storeConfig.sizes.textSmall = textSizeSmall; storeFileView.saveState() }
    onTextSizeLargeChanged: if (root.storeConfig?.sizes) { root.storeConfig.sizes.textLarge = textSizeLarge; storeFileView.saveState() }
    onTextSizeXLargeChanged: if (root.storeConfig?.sizes) { root.storeConfig.sizes.textXLarge = textSizeXLarge; storeFileView.saveState() }
    onTextSizeXSmallChanged: if (root.storeConfig?.sizes) { root.storeConfig.sizes.textXSmall = textSizeXSmall; storeFileView.saveState() }

    // Helper Functions
    readonly property bool isHorizontal: position === Config.Position.Top || position === Config.Position.Bottom
    readonly property bool isVertical: position === Config.Position.Left || position === Config.Position.Right

    function getPositionName(): string {
        switch (position) {
            case Config.Position.Top: return "top"
            case Config.Position.Bottom: return "bottom"
            case Config.Position.Left: return "left"
            case Config.Position.Right: return "right"
        }
        return "top"
    }

    function getAnchors(): var {
        const anchors = {}
        switch (position) {
            case Config.Position.Top:
                anchors.top = true
                anchors.left = true
                anchors.right = true
                break
            case Config.Position.Bottom:
                anchors.bottom = true
                anchors.left = true
                anchors.right = true
                break
            case Config.Position.Left:
                anchors.left = true
                anchors.top = true
                anchors.bottom = true
                break
            case Config.Position.Right:
                anchors.right = true
                anchors.top = true
                anchors.bottom = true
                break
        }
        return anchors
    }

    // Widget config helper - fetch config for a specific widget, merging with default fallback values
    function getWidgetConfig(widgetName, defaultValues) {
        const configKey = widgetName + "Config"
        const widgetConfig = root.storeConfig?.[configKey]
        if (!widgetConfig) {
            return Object.assign({}, defaultValues)
        }
        const result = Object.assign({}, defaultValues)
        for (var key in widgetConfig) {
            result[key] = widgetConfig[key]
        }

        return result
    }

    JsonObject {
        id: payloadData
        property ServicesTypes.Services services
        property WidgetsTypes.Widgets widgets

        services: ServicesTypes.Services {
        }

        widgets: WidgetsTypes.Widgets {
        }
    }
    
    FileView {
        id: storeFileView
        path: Quickshell.env("XDG_CONFIG_HOME") + "/quickshell-bar/state.json"
        watchChanges: true
        blockLoading: true
        onFileChanged: reload()

        // State object accessible from outside
        property var state: ({
            services: { audio: { muted: false, volume: 50 }, brightness: { value: 80 } },
            widgets: { bar: { config: {}, caffeine: { active: false }, nightShift: { active: false, temperature: 4500, transitionDuration: 5 } } }
        })

        Component.onCompleted: {
            // Read and merge JSON manually
            const rawData = storeFileView.text()
            if (!rawData || rawData.length === 0) {
                console.log("No existing state, using defaults")
                saveState()
                return
            }

            try {
                const fileJson = JSON.parse(rawData)
                state = mergeObjects(state, fileJson)
                validateAgainstSchema()
                console.log("State loaded, merged, and validated")
                saveState()
            } catch (e) {
                console.log("Error parsing state:", e)
            }
        }

        function saveState() {
            storeFileView.setText(JSON.stringify(state, null, 4))
        }

        function mergeObjects(defaults, fileData) {
            const result = {}
            // Start with defaults
            for (let key in defaults) {
                if (typeof defaults[key] === 'object' && defaults[key] !== null) {
                    result[key] = JSON.parse(JSON.stringify(defaults[key]))
                } else {
                    result[key] = defaults[key]
                }
            }
            // Override with file data
            for (let key in fileData) {
                if (fileData.hasOwnProperty(key)) {
                    if (typeof fileData[key] === 'object' && fileData[key] !== null && !Array.isArray(fileData[key]) && typeof result[key] === 'object' && result[key] !== null && !Array.isArray(result[key])) {
                        result[key] = mergeObjects(result[key], fileData[key])
                    } else {
                        result[key] = fileData[key]
                    }
                }
            }
            return result
        }

        // Dynamic validation against payloadData schema
        function validateAgainstSchema() {
            const schema = payloadData
            const errors = []

            // Helper to get nested value by path array
            function getNestedValue(obj, path) {
                let current = obj
                for (let i = 0; i < path.length; i++) {
                    if (current === null || current === undefined) return undefined
                    current = current[path[i]]
                }
                return current
            }

            // Helper to set nested value by path array
            function setNestedValue(obj, path, value) {
                let current = obj
                for (let i = 0; i < path.length - 1; i++) {
                    if (!current[path[i]]) current[path[i]] = {}
                    current = current[path[i]]
                }
                current[path[path.length - 1]] = value
            }

            // Recursively validate schema properties
            function validateObject(schemaObj, stateObj, path) {
                if (!schemaObj || typeof schemaObj !== 'object') return

                // Get all property names from schema object, excluding QML internals
                const propNames = Object.keys(schemaObj).filter(k => 
                    !k.startsWith('_') && 
                    k !== 'objectName' &&
                    typeof schemaObj[k] !== 'function' // Exclude signal handlers
                )

                for (let propName of propNames) {
                    const schemaValue = schemaObj[propName]
                    const currentPath = [...path, propName]
                    const stateValue = getNestedValue(state, currentPath)

                    // Determine type from schema default value
                    const schemaType = typeof schemaValue

                    if (schemaValue && typeof schemaValue === 'object' && schemaValue.constructor.name === 'Object') {
                        // Nested object - recurse
                        if (stateValue === undefined || stateValue === null) {
                            // Create nested object if missing (silent)
                            setNestedValue(state, currentPath, {})
                        }
                        validateObject(schemaValue, stateValue, currentPath)
                    } else {
                        // Primitive type - validate
                        if (stateValue === undefined || stateValue === null) {
                            // Apply default from schema (silent)
                            setNestedValue(state, currentPath, schemaValue)
                        } else if (typeof stateValue !== schemaType) {
                            // Type mismatch - apply default and log error
                            setNestedValue(state, currentPath, schemaValue)
                            errors.push(`Type mismatch at ${currentPath.join('.')}, expected ${schemaType}, got ${typeof stateValue}`)
                        }
                    }
                }
            }

            // Validate services and widgets from payloadData
            if (schema.services) {
                validateObject(schema.services, state.services, ['services'])
            }
            if (schema.widgets) {
                validateObject(schema.widgets, state.widgets, ['widgets'])
            }

            if (errors.length > 0) {
                console.log("Validation applied fixes:", errors.join("; \n"))
            }
        }
    }
}
