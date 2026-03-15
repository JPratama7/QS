import QtQuick
import Quickshell
import Quickshell.Wayland
import "../config" as Config

PopupWindow {
    id: root

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

    // Background with shadow
    Rectangle {
        id: background
        anchors.fill: parent
        radius: Config.Theme.borderRadiusLarge
        color: Config.Theme.popupBg
        border.width: 1
        border.color: Config.Theme.popupBorder

        // Shadow effect
        layer.enabled: true
        layer.effect: Item {
            Rectangle {
                anchors.fill: parent
                anchors.margins: -Config.Theme.shadowRadius
                radius: background.radius + Config.Theme.shadowRadius
                color: Config.Theme.shadowColor
                opacity: Config.Theme.shadowOpacity
                z: -1
            }
        }

        // Content container
        Item {
            id: content
            anchors.fill: parent
            anchors.margins: Config.Theme.paddingLarge
        }
    }

    // Close on outside click
    MouseArea {
        anchors.fill: parent
        z: -1
        onPressed: function(mouse) {
            if (autoClose) {
                root.close()
            }
        }
    }

    // Animation on open/close
    Behavior on opacity {
        NumberAnimation {
            duration: animationDuration
            easing.type: Easing.OutCubic
        }
    }

    Behavior on scale {
        NumberAnimation {
            duration: animationDuration
            easing.type: Easing.OutCubic
        }
    }

    // Methods
    function open(widget: var): void {
        anchorWidget = widget
        reposition()
        visible = true
        opacity = 1
        scale = 1
    }

    function close(): void {
        opacity = 0
        scale = 0.9
        visible = false
    }

    function reposition(): void {
        if (anchorWidget === null) return

        const widgetPos = anchorWidget.mapToItem(null, 0, 0)
        const barHeight = Config.Config.barSize

        switch (barPosition) {
            case Config.Config.Position.Top:
                x = widgetPos.x + (anchorWidget.width / 2) - (popupWidth / 2)
                y = barHeight + Config.Theme.spacing
                break
            case Config.Config.Position.Bottom:
                x = widgetPos.x + (anchorWidget.width / 2) - (popupWidth / 2)
                y = -popupHeight - Config.Theme.spacing
                break
            case Config.Config.Position.Left:
                x = barHeight + Config.Theme.spacing
                y = widgetPos.y + (anchorWidget.height / 2) - (popupHeight / 2)
                break
            case Config.Config.Position.Right:
                x = -popupWidth - Config.Theme.spacing
                y = widgetPos.y + (anchorWidget.height / 2) - (popupHeight / 2)
                break
        }

        // Clamp to screen bounds
        const screen = anchorWidget.Window.window?.screen
        if (screen) {
            x = Math.max(0, Math.min(x, screen.width - popupWidth))
            y = Math.max(0, Math.min(y, screen.height - popupHeight))
        }
    }
}
