import QtQuick
import "../config" as Config

Item {
    id: root

    property real value: 0.5
    property real minValue: 0
    property real maxValue: 1
    property color color: Config.Theme.accent
    property color backgroundColor: Config.Theme.bgDark
    property int barHeight: 4
    property int barWidth: 80
    property bool vertical: false
    property bool inverted: false

    signal valueChanged(real newValue)

    implicitWidth: vertical ? barHeight : barWidth
    implicitHeight: vertical ? barWidth : barHeight

    readonly property real normalizedValue: Math.max(0, Math.min(1, (value - minValue) / (maxValue - minValue)))

    // Background track
    Rectangle {
        id: track
        anchors.fill: parent
        radius: barHeight / 2
        color: root.backgroundColor
    }

    // Filled portion
    Rectangle {
        id: fill
        radius: barHeight / 2
        color: root.color

        states: [
            State {
                when: !root.vertical && !root.inverted
                AnchorChanges {
                    target: fill
                    anchors.left: track.left
                    anchors.top: track.top
                    anchors.bottom: track.bottom
                }
                PropertyChanges {
                    target: fill
                    width: track.width * root.normalizedValue
                }
            },
            State {
                when: !root.vertical && root.inverted
                AnchorChanges {
                    target: fill
                    anchors.right: track.right
                    anchors.top: track.top
                    anchors.bottom: track.bottom
                }
                PropertyChanges {
                    target: fill
                    width: track.width * root.normalizedValue
                }
            },
            State {
                when: root.vertical && !root.inverted
                AnchorChanges {
                    target: fill
                    anchors.left: track.left
                    anchors.right: track.right
                    anchors.bottom: track.bottom
                }
                PropertyChanges {
                    target: fill
                    height: track.height * root.normalizedValue
                }
            },
            State {
                when: root.vertical && root.inverted
                AnchorChanges {
                    target: fill
                    anchors.left: track.left
                    anchors.right: track.right
                    anchors.top: track.top
                }
                PropertyChanges {
                    target: fill
                    height: track.height * root.normalizedValue
                }
            }
        ]

        Behavior on width {
            NumberAnimation { duration: Config.Theme.animationNormal; easing.type: Easing.OutCubic }
        }
        Behavior on height {
            NumberAnimation { duration: Config.Theme.animationNormal; easing.type: Easing.OutCubic }
        }
        Behavior on color {
            ColorAnimation { duration: Config.Theme.animationNormal }
        }
    }

    // Handle
    Rectangle {
        id: handle
        width: root.barHeight + 4
        height: width
        radius: width / 2
        color: root.color
        border.width: 2
        border.color: Config.Theme.fgBright

        x: root.vertical ? (track.width - width) / 2 : track.width * root.normalizedValue - width / 2
        y: root.vertical ? track.height * (root.inverted ? root.normalizedValue : (1 - root.normalizedValue)) - height / 2 : (track.height - height) / 2

        Behavior on x {
            NumberAnimation { duration: Config.Theme.animationNormal; easing.type: Easing.OutCubic }
        }
        Behavior on y {
            NumberAnimation { duration: Config.Theme.animationNormal; easing.type: Easing.OutCubic }
        }
    }

    // Interaction
    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton

        function updateValue(mouseX, mouseY) {
            let newValue
            if (root.vertical) {
                const ratio = mouseY / track.height
                newValue = root.inverted ? ratio : (1 - ratio)
            } else {
                const ratio = mouseX / track.width
                newValue = root.inverted ? (1 - ratio) : ratio
            }
            root.value = root.minValue + newValue * (root.maxValue - root.minValue)
            root.valueChanged(root.value)
        }

        onPressed: function(mouse) {
            updateValue(mouse.x, mouse.y)
        }
        onPositionChanged: function(mouse) {
            if (pressed) {
                updateValue(mouse.x, mouse.y)
            }
        }
        onWheel: function(wheel) {
            const delta = wheel.angleDelta.y / 1200
            const step = (root.maxValue - root.minValue) / 20
            root.value = Math.max(root.minValue, Math.min(root.maxValue, root.value + delta * step))
            root.valueChanged(root.value)
        }
    }
}
