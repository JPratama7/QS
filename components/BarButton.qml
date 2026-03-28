pragma ComponentBehavior: Bound
import QtQuick
import "../config" as Config
import "../base" as Base

Base.BaseComponent {
    id: root
    objectName: "BarButton"

    property string icon: ""
    property string text: ""
    property color iconColor: foreground
    property int iconSize: Config.Theme.iconSize

    signal clicked()

    // Bind to base class size property
    size: Config.Theme.componentSize
    Binding on implicitWidth { value: iconText.implicitWidth + (Config.Theme.widgetPadding * 2) }

    // Icon and Text
    Row {
        id: iconText
        anchors.centerIn: parent
        spacing: Config.Theme.spacing

        Text {
            id: iconLabel
            anchors.verticalCenter: parent.verticalCenter
            text: root.icon
            font.family: Config.Theme.fontFamily
            font.pixelSize: root.iconSize
            color: root.iconColor
            visible: root.icon !== ""

            Behavior on color {
                ColorAnimation {
                    duration: root.animationDuration
                }
            }
        }

        Text {
            id: textLabel
            anchors.verticalCenter: parent.verticalCenter
            text: root.text
            font.family: Config.Theme.fontFamily
            font.pixelSize: Config.Theme.fontSizeNormal
            color: root.foreground
            visible: root.text !== ""

            Behavior on color {
                ColorAnimation {
                    duration: root.animationDuration
                }
            }
        }
    }

    // Click handler
    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        onEntered: root.hovered = true
        onExited: root.hovered = false
        onPressed: root.pressed = true
        onReleased: root.pressed = false
        onClicked: root.clicked()
    }
}
