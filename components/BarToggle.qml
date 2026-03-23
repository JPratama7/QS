pragma ComponentBehavior: Bound
import QtQuick
import "../config" as Config

Item {
    id: root
    objectName: "BarToggle"

    property bool checked: false
    property color checkedColor: Config.Theme.accent
    property color uncheckedColor: Config.Theme.bgDark
    property color handleColor: Config.Theme.fgBright
    property int toggleWidth: 36
    property int toggleHeight: 18

    signal toggled(bool checked)

    implicitWidth: toggleWidth
    implicitHeight: toggleHeight

    // Background track
    Rectangle {
        id: track
        anchors.fill: parent
        radius: toggleHeight / 2
        color: root.checked ? root.checkedColor : root.uncheckedColor

        Behavior on color {
            ColorAnimation { duration: Config.Theme.animationNormal }
        }
    }

    // Handle
    Rectangle {
        id: handle
        width: toggleHeight - 4
        height: width
        radius: width / 2
        color: root.handleColor
        anchors.verticalCenter: parent.verticalCenter

        x: root.checked ? (toggleWidth - width - 2) : 2

        Behavior on x {
            NumberAnimation { duration: Config.Theme.animationNormal; easing.type: Easing.OutCubic }
        }
    }

    // Interaction
    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        onClicked: {
            root.checked = !root.checked
            root.toggled(root.checked)
        }
    }
}
