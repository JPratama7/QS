pragma ComponentBehavior: Bound
import QtQuick
import Quickshell.Widgets
import "../config" as Config

Item {
    id: root
    objectName: "BarIcon"

    property string icon: ""
    property color color: Config.Theme.fg
    property int size: Config.Config.iconSize
    property string fontFamily: Config.Theme.fontFamily
    property string iconPath: ""

    implicitWidth: iconMetrics.width
    implicitHeight: iconMetrics.height

    Loader {
        id: iconLoader
        anchors.centerIn: parent
        sourceComponent: root.icon !== "" ? textIcon : (root.iconPath !== "" ? imageIcon : null)
    }

    Component {
        id: textIcon
        Text {
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
    }

    Component {
        id: imageIcon
        IconImage {
            source: root.iconPath
            implicitSize: Config.Config.iconSize
        }
    }

    TextMetrics {
        id: iconMetrics
        text: root.icon
        font.family: root.fontFamily
        font.pixelSize: root.size
    }
}
