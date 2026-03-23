pragma ComponentBehavior: Bound
import QtQuick
import "../config" as Config

Item {
    id: root

    property string text: ""
    property bool visible: false
    property int delay: 500
    property int timeout: 3000

    implicitWidth: tooltipText.implicitWidth + Config.Theme.padding * 2
    implicitHeight: tooltipText.implicitHeight + Config.Theme.padding

    visible: root.visible
    opacity: root.visible ? 1 : 0

    Behavior on opacity {
        NumberAnimation { duration: Config.Theme.animationFast }
    }

    Rectangle {
        anchors.fill: parent
        radius: Config.Theme.borderRadius
        color: Config.Theme.bgDark
        border.width: 1
        border.color: Config.Theme.fgMuted
    }

    Text {
        id: tooltipText
        anchors.centerIn: parent
        text: root.text
        font.family: Config.Theme.fontFamily
        font.pixelSize: Config.Theme.fontSizeSmall
        color: Config.Theme.fg
    }

    Timer {
        id: hideTimer
        interval: root.timeout
        running: root.visible
        onTriggered: root.visible = false
    }
}
