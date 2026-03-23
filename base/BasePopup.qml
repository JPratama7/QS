pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import "../config" as Config

PopupWindow {
    id: root

    // Content
    required property Component contentComponent
    property Component backgroundComponent: Component {
            Rectangle {
                radius: 30
                color: Config.Theme.popupBg
                border.width: 1
                border.color: Config.Theme.popupBorder
            }
    }

    // Popup Properties
    property var anchorWidget: null
    property int barPosition: Config.Config.position
    property int popupWidth: Config.Config.popupWidth
    property int popupHeight: Config.Config.popupHeight
    property bool autoClose: Config.Config.popupAutoClose

    // Animation
    property int animationDuration: Config.Config.popupAnimationDuration

    // Size
    implicitWidth: popupWidth
    implicitHeight: popupHeight

    // Window Properties
    color: "transparent"
    visible: false

    property int contentPadding: Config.Theme.padding


    // Background with shadow
    Item {
        id: container
        anchors.fill: parent
        
        // Animation properties on container Item
        property real popupOpacity: 1
        property real popupScale: 1
        
        Behavior on popupOpacity {
            NumberAnimation {
                duration: root.animationDuration
                easing.type: Easing.OutCubic
            }
        }
        
        Behavior on popupScale {
            NumberAnimation {
                duration: root.animationDuration
                easing.type: Easing.OutCubic
            }
        }
        
        // Apply transforms
        transform: [
            Scale {
                origin.x: root.popupWidth / 2
                origin.y: root.popupHeight / 2
                xScale: container.popupScale
                yScale: container.popupScale
            }
        ]
        opacity: container.popupOpacity
        visible: root.visible

        // Background (optional, customizable)
        Loader {
            id: backgroundLoader
            anchors.fill: parent
            z: 0
            active: root.backgroundComponent !== null
            sourceComponent: root.backgroundComponent
        }

        // Content
        Loader {
            id: contentLoader
            anchors.fill: parent
            anchors.margins: 0
            z: 1
            sourceComponent: root.contentComponent
        }

        // Close on outside click
        MouseArea {
            anchors.fill: parent
            z: 100
            propagateComposedEvents: true
            onReleased: function(mouse) {
                if (root.autoClose && !mouse.accepted) {
                    root.close()
                }
            }
        }
    }

    // Methods
    function open(widget: var): void {
        anchorWidget = widget
        root.visible = true
        container.popupOpacity = 1
        container.popupScale = 1
    }

    function close(): void {
        container.popupOpacity = 0
        container.popupScale = 0.9
        closeTimer.start()
    }

    Timer {
        id: closeTimer
        interval: root.animationDuration
        onTriggered: {
            root.visible = false
        }
    }

    // PopupWindow anchor configuration
    anchor {
        item: anchorWidget ?? null
        rect.x: anchorWidget ? (anchorWidget.width / 2) - (popupWidth / 2) : 0
        rect.y: {
            if (!anchorWidget) return 0
            const barHeight = Config.Config.barSize
            switch (barPosition) {
                case Config.Config.Position.Top:
                    return barHeight + Config.Theme.spacing
                case Config.Config.Position.Bottom:
                    return -popupHeight - Config.Theme.spacing
                case Config.Config.Position.Left:
                    return (anchorWidget.height / 2) - (popupHeight / 2)
                case Config.Config.Position.Right:
                    return (anchorWidget.height / 2) - (popupHeight / 2)
                default:
                    return barHeight + Config.Theme.spacing
            }
        }
        edges: {
            switch (barPosition) {
                case Config.Config.Position.Left:
                    return Qt.LeftEdge
                case Config.Config.Position.Right:
                    return Qt.RightEdge
                case Config.Config.Position.Bottom:
                    return Qt.BottomEdge
                default:
                    return Qt.TopEdge
            }
        }
    }
}
