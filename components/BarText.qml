pragma ComponentBehavior: Bound
import QtQuick
import "../config" as Config

Item {
    id: root
    objectName: "BarText"

    property string text: ""
    property color color: Config.Theme.fg
    property int fontSize: Config.Config.textSize
    property string fontFamily: Config.Theme.fontFamily
    property bool bold: false
    property int maxWidth: -1

    implicitWidth: textMetrics.width
    implicitHeight: textMetrics.height

    Text {
        id: label
        anchors.fill: parent
        text: root.text
        font.family: root.fontFamily
        font.pixelSize: root.fontSize
        font.bold: root.bold
        color: root.color
        elide: Text.ElideRight
        maximumLineCount: 1

        Behavior on color {
            ColorAnimation {
                duration: Config.Theme.animationNormal
            }
        }
    }

    TextMetrics {
        id: textMetrics
        text: root.text
        font.family: root.fontFamily
        font.pixelSize: root.fontSize
        font.bold: root.bold
    }
}
