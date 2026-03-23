pragma ComponentBehavior: Bound
import QtQuick
import "../config" as Config

Item {
    id: root
    objectName: "BarIcon"

    property string icon: ""
    property color color: Config.Theme.fg
    property int size: Config.Theme.iconSize
    property string fontFamily: Config.Theme.fontFamily

    implicitWidth: iconMetrics.width
    implicitHeight: iconMetrics.height

    Text {
        id: iconLabel
        anchors.centerIn: parent
        text: root.icon
        font.family: root.fontFamily
        font.pixelSize: root.size
        color: root.color

        Behavior on color {
            ColorAnimation {
                duration: Config.Theme.animationNormal
            }
        }
    }

    TextMetrics {
        id: iconMetrics
        text: root.icon
        font.family: root.fontFamily
        font.pixelSize: root.size
    }
}
