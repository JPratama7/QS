pragma ComponentBehavior: Bound
import QtQuick
import "../config" as Config
import "../services" as Services
Item {
    id: root

    // Cache Policy Enum
    enum CachePolicy {
        NoCache,      // Load on demand, destroy on close
        LazyCache,    // Load on first open, keep cached
        EagerCache    // Load immediately, keep cached
    }

    // Layout Properties
    implicitWidth: contentRow.implicitWidth + (Config.Theme.widgetPadding * 2)
    implicitHeight: Config.Theme.componentSize

    // Popup caching policy - controls when popup is loaded and destroyed
    property int cachePolicy: BaseWidget.CachePolicy.NoCache

    // Widget State
    property bool expanded: false
    property bool active: false
    property string tooltipText: ""
    property Component popupComponent: null
    property bool showBackground: true
    property color containerColor: Config.Theme.widgetBg

    // Derived state
    readonly property bool hasPopup: popupComponent !== null


    // Bar Position (inherited from parent or config)
    property int barPosition: Config.Config.position

    // Signals
    signal clicked()
    signal rightClicked()
    signal middleClicked()
    signal scrollUp()
    signal scrollDown()
    signal popupOpened()
    signal popupClosed()

    // Internal
    property bool _popupOpen: popupLoader.item !== null && (popupLoader.item ? popupLoader.item.visible : false)
    property bool _pendingOpen: false  // Track if we're waiting to open popup after load

    // Background
    Rectangle {
        id: background
        anchors.fill: parent
        radius: Config.Theme.borderRadius
        visible: root.showBackground
        color: {
            if (root.active) return Config.Theme.widgetBgActive
            if (mouseArea.containsMouse) return Config.Theme.widgetBgHover
            return "transparent"
        }

        Behavior on color {
            ColorAnimation {
                duration: Config.Theme.animationNormal
                easing.type: Easing.OutCubic
            }
        }
    }

    // Content Container
    Row {
        id: contentRow
        anchors.centerIn: parent
        spacing: Config.Theme.widgetSpacing


    }

    // Mouse Area for interactions
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
        propagateComposedEvents: true

        onClicked: function(mouse) {
            if (mouse.button === Qt.LeftButton) {
                root.clicked()
                if (root.popupComponent !== null) root.togglePopup()
            } else if (mouse.button === Qt.RightButton) {
                root.rightClicked()
            } else if (mouse.button === Qt.MiddleButton) {
                root.middleClicked()
            }
        }

        onWheel: function(wheel) {
            if (wheel.angleDelta.y > 0) {
                root.scrollUp()
            } else {
                root.scrollDown()
            }
        }
    }

    // Tooltip handling via TooltipService
    HoverHandler {
        onHoveredChanged: {
            if (root.tooltipText !== "") {
                if (hovered) {
                    Services.TooltipService.showText(root, root.tooltipText, "auto", 500)
                } else {
                    Services.TooltipService.hide()
                }
            }
        }
    }

    // Popup Loader
    Loader {
        id: popupLoader
        active: root.cachePolicy === BaseWidget.CachePolicy.EagerCache
        asynchronous: true
        sourceComponent: root.popupComponent

        onLoaded: {
            if (root._pendingOpen && item) {
                item.open(root)
                root.popupOpened()
                root._pendingOpen = false
            }
        }
    }

    // Methods
    function openPopup(): void {
        if (!root.hasPopup) return

        root.loadPopup()
        if (popupLoader.item) {
            popupLoader.item.open(root)
            root.popupOpened()
        } else {
            // Popup is loading asynchronously, open when ready
            root._pendingOpen = true
        }
    }

    function loadPopup(): void {
        if (!root.hasPopup) return
        popupLoader.active = true
    }

    function destroyPopup(): void {
        popupLoader.active = false
    }

    function closePopup(): void {
        if (popupLoader.item?.visible) {
            popupLoader.item.close()
            root.popupClosed()
        }

        if (root.cachePolicy === BaseWidget.CachePolicy.NoCache) {
            root.destroyPopup()
        }
    }

    function togglePopup(): void {
        if (root._popupOpen) {
            root.closePopup()
        } else {
            root.openPopup()
        }
    }

    function refresh(): void {
        // Override in child widgets
    }

    function setActive(active: bool): void {
        root.active = active
    }
}
