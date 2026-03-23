pragma ComponentBehavior: Bound
import QtQuick
import "../config" as Config

Rectangle {
    id: root

    property string icon: ""
    property bool hovering: false

    signal clicked()

    implicitWidth: 28
    implicitHeight: 28
    radius: Config.Theme.borderRadius
    color: root.hovering ? Config.Theme.widgetBgHover : Config.Theme.widgetBg
    border.width: 1
    border.color: Config.Theme.widgetBorder

    Behavior on color {
        ColorAnimation {
            duration: Config.Theme.animationFast
        }
    }

    Text {
        anchors.centerIn: parent
        text: root.icon
        font.family: Config.Theme.fontFamily
        font.pixelSize: Config.Theme.fontSizeNormal
        color: root.hovering ? Config.Theme.accent : Config.Theme.fg
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onEntered: root.hovering = true
        onExited: root.hovering = false
        onClicked: root.clicked()
    }
}
