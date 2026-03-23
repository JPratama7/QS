pragma ComponentBehavior: Bound
import QtQuick
import "../config" as Config
import "../services" as Services
import "BasePopup.qml"
Item {
    id: root

    // Layout Properties
    implicitWidth: contentRow.implicitWidth + (Config.Theme.widgetPadding * 2)
    implicitHeight: Config.Theme.componentSize

    // Widget State
    property bool expanded: false
    property bool hasPopup: false
    property bool active: false
    property string tooltipText: ""
    property BasePopup popupComponent: null
    property bool showBackground: true
    property color containerColor: Config.Theme.widgetBg

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
    property bool _popupOpen: popupLoader.item !== null && popupLoader.item.visible

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

        onClicked: function(mouse) {
            if (mouse.button === Qt.LeftButton) {
                root.clicked()
                if (root.hasPopup) root.togglePopup()
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
        active: false
        asynchronous: true
        sourceComponent: root.popupComponent
    }

    // Methods
    function openPopup(): void {
        if (!root.hasPopup || root.popupComponent === null) return

        popupLoader.active = true
        if (popupLoader.item) {
            popupLoader.item.open(root)
            root.popupOpened()
        }
    }

    function closePopup(): void {
        if (popupLoader.item !== null && popupLoader.item.visible) {
            popupLoader.item.close()
            popupLoader.active = false
            root.popupClosed()
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
