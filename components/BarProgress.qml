pragma ComponentBehavior: Bound
import QtQuick
import "../config" as Config

Item {
    id: root

    property real value: 0.5
    property real minValue: 0
    property real maxValue: 1
    property color color: Config.Theme.accent
    property color backgroundColor: Config.Theme.bgDark
    property int radius: Config.Theme.borderRadius
    property int thickness: 4
    property bool showValue: false

    implicitWidth: 100
    implicitHeight: thickness + (showValue ? Config.Theme.fontSizeNormal + Config.Theme.spacing : 0)

    readonly property real normalizedValue: Math.max(0, Math.min(1, (value - minValue) / (maxValue - minValue)))

    // Background track
    Rectangle {
        id: track
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        height: root.thickness
        radius: root.radius
        color: root.backgroundColor
    }

    // Filled portion
    Rectangle {
        id: fill
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width * root.normalizedValue
        height: root.thickness
        radius: root.radius
        color: root.color

        Behavior on width {
            NumberAnimation {
                duration: Config.Theme.animationNormal
                easing.type: Easing.OutCubic
            }
        }

        Behavior on color {
            ColorAnimation {
                duration: Config.Theme.animationNormal
            }
        }
    }

    // Optional value text
    Text {
        anchors.left: parent.left
        anchors.top: track.bottom
        anchors.topMargin: Config.Theme.spacing
        text: Math.round(root.value) + (root.maxValue === 100 ? "%" : "")
        font.family: Config.Theme.fontFamily
        font.pixelSize: Config.Theme.fontSizeSmall
        color: Config.Theme.fgDark
        visible: root.showValue
    }
}
