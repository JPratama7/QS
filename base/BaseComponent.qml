pragma ComponentBehavior: Bound
import QtQuick
import "../config" as Config

Item {
    id: root

    // Size Properties
    property int size: Config.Theme.componentSize
    implicitWidth: size
    implicitHeight: size

    // Color Properties
    property color foreground: Config.Theme.fg
    property color background: Config.Theme.bgBright
    property color backgroundHover: Config.Theme.widgetBgHover
    property color backgroundActive: Config.Theme.widgetBgActive

    // State Properties
    property bool hovered: hoverHandler.hovered ?? false
    property bool pressed: pressHandler.pressed ?? false
    property bool disabled: false
    property bool active: false

    // Animation Properties
    property int animationDuration: Config.Theme.animationNormal

    // Behavior Properties (can be overridden)
    property bool animateBackground: true
    property bool animateScale: true
    property real scaleOnHover: 1.0
    property real scaleOnPress: 0.95
    property bool showBackground: true

    // Internal
    readonly property color currentBackground: {
        if (disabled) return background
        if (active) return backgroundActive
        if (hovered) return backgroundHover
        return background
    }
    
    readonly property real _opacityDisable:  Config.Theme.opacityDisabled 

    // Background Rectangle
    Rectangle {
        id: backgroundRect
        anchors.fill: parent
        radius: Config.Theme.borderRadius
        color: root.currentBackground
        visible: root.showBackground

        Behavior on color {
            enabled: root.animateBackground
            ColorAnimation {
                duration: root.animationDuration
                easing.type: Easing.OutCubic
            }
        }
    }

    // Content Container (for children to anchor to)
    Item {
        id: content
        anchors.fill: parent
        anchors.margins: Config.Theme.padding / 2
    }

    // Hover Handler
    HoverHandler {
        id: hoverHandler
        enabled: !root.disabled
    }

    // Tap Handler
    TapHandler {
        id: pressHandler
        enabled: !root.disabled
    }

    // Scale Animation
    Behavior on scale {
        enabled: root.animateScale
        NumberAnimation {
            duration: root.animationDuration
            easing.type: Easing.OutCubic
        }
    }

    // Scale binding (animated via Behavior on scale)
    Binding on scale {
        when: !root.disabled
        value: root.pressed ? root.scaleOnPress : (root.hovered ? root.scaleOnHover : 1.0)
        restoreMode: Binding.RestoreBinding
    }

    // Opacity binding for disabled state
    Binding on opacity {
        when: root.disabled
        value: root._opacityDisable
        restoreMode: Binding.RestoreBinding
    }

    // Helper Methods
    function animateTo(target: var, property: string, value: var): void {
        const anim = target.createAnimation(property, value, animationDuration)
        if (anim) anim.start()
    }

    function setForeground(color: color): void {
        root.foreground = color
    }

    function setBackground(color: color): void {
        root.background = color
    }

    function setDisabled(disabled: bool): void {
        root.disabled = disabled
    }

    function setActive(active: bool): void {
        root.active = active
    }
}
