pragma Singleton
import Quickshell
import QtQuick
import "../services" as Services

Singleton {
    id: root

    // Bar Position Enum
    enum Position {
        Top,
        Bottom,
        Left,
        Right
    }

    // Shorthand reference to StateStore path (may be undefined during init)
    readonly property var storeConfig: Services.StateStore.widgets?.bar?.config || null

    // Bar Layout Configuration - Bind to StateStore with fallback defaults
    property int position: root.storeConfig?.position ?? 0
    property int barSize: root.storeConfig?.barSize ?? 32
    property int barMargin: root.storeConfig?.barMargin ?? 0
    property int barRadius: root.storeConfig?.barRadius ?? 0

    // Widget Visibility Toggles - Bind to StateStore with fallback defaults
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

    // Widget Order - Bind to StateStore with fallback default
    property var widgetOrder: root.storeConfig?.widgetOrder ?? ["workspaces", "windowTitle", "systemMonitor", "network", "bluetooth", "battery", "audio", "brightness", "nightShift", "caffeine", "clock"]

    // Animation Settings - Bind to StateStore with fallback defaults
    property int animationDuration: root.storeConfig?.animationDuration ?? 150
    property int popupAnimationDuration: root.storeConfig?.popupAnimationDuration ?? 200

    // Popup Settings - Bind to StateStore with fallback defaults
    property int popupWidth: root.storeConfig?.popupWidth ?? 320
    property int popupHeight: root.storeConfig?.popupHeight ?? 400
    property bool popupAutoClose: root.storeConfig?.popupAutoClose ?? true

    // Write-through: update StateStore when properties change (only if storeConfig is ready)
    onPositionChanged: if (root.storeConfig) root.storeConfig.position = position
    onBarSizeChanged: if (root.storeConfig) root.storeConfig.barSize = barSize
    onBarMarginChanged: if (root.storeConfig) root.storeConfig.barMargin = barMargin
    onBarRadiusChanged: if (root.storeConfig) root.storeConfig.barRadius = barRadius
    onShowWorkspacesChanged: if (root.storeConfig) root.storeConfig.showWorkspaces = showWorkspaces
    onShowWindowTitleChanged: if (root.storeConfig) root.storeConfig.showWindowTitle = showWindowTitle
    onShowSystemMonitorChanged: if (root.storeConfig) root.storeConfig.showSystemMonitor = showSystemMonitor
    onShowNetworkChanged: if (root.storeConfig) root.storeConfig.showNetwork = showNetwork
    onShowBluetoothChanged: if (root.storeConfig) root.storeConfig.showBluetooth = showBluetooth
    onShowBatteryChanged: if (root.storeConfig) root.storeConfig.showBattery = showBattery
    onShowAudioChanged: if (root.storeConfig) root.storeConfig.showAudio = showAudio
    onShowBrightnessChanged: if (root.storeConfig) root.storeConfig.showBrightness = showBrightness
    onShowNightShiftChanged: if (root.storeConfig) root.storeConfig.showNightShift = showNightShift
    onShowCaffeineChanged: if (root.storeConfig) root.storeConfig.showCaffeine = showCaffeine
    onShowClockChanged: if (root.storeConfig) root.storeConfig.showClock = showClock
    onWidgetOrderChanged: if (root.storeConfig) root.storeConfig.widgetOrder = widgetOrder
    onAnimationDurationChanged: if (root.storeConfig) root.storeConfig.animationDuration = animationDuration
    onPopupAnimationDurationChanged: if (root.storeConfig) root.storeConfig.popupAnimationDuration = popupAnimationDuration
    onPopupWidthChanged: if (root.storeConfig) root.storeConfig.popupWidth = popupWidth
    onPopupHeightChanged: if (root.storeConfig) root.storeConfig.popupHeight = popupHeight
    onPopupAutoCloseChanged: if (root.storeConfig) root.storeConfig.popupAutoClose = popupAutoClose

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
}
