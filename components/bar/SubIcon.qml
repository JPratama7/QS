pragma ComponentBehavior: Bound

import QtQuick
import ".."
import "../../config"

// Small square icon slot used inside grouped bar widgets (e.g. the control
// center anchor). Renders either an SvgIcon or an image (tray), optionally
// with a count badge. The owner wires tooltips via `tooltipComponent` and
// hover signal; clicks forward the mouse event.
Item {
    id: subIcon

    property string iconSource: ""
    property string iconImageSource: ""
    property color iconColor: Theme.foregroundColor
    property int badgeCount: 0
    property Component tooltipComponent: null
    property int acceptedButtons: Qt.LeftButton

    signal hoverChanged(hovered: bool)
    signal clicked(mouse: var)

    readonly property int _iconSize: 16

    width: 22
    height: 22

    Rectangle {
        anchors.fill: parent
        radius: Theme.radiusSmall
        color: hoverArea.containsMouse ? Theme.hoverColor : "transparent"
    }

    SvgIcon {
        visible: subIcon.iconSource !== ""
        anchors.centerIn: parent
        source: subIcon.iconSource
        color: subIcon.iconColor
        iconSize: subIcon._iconSize
    }

    Image {
        visible: subIcon.iconImageSource !== ""
        anchors.centerIn: parent
        width: subIcon._iconSize
        height: subIcon._iconSize
        source: subIcon.iconImageSource
        sourceSize.width: subIcon._iconSize
        sourceSize.height: subIcon._iconSize
        fillMode: Image.PreserveAspectFit
        smooth: true
    }

    // Badge — unread count on the bell
    Rectangle {
        visible: subIcon.badgeCount > 0
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.topMargin: -2
        anchors.rightMargin: -2
        width: badgeText.implicitWidth + 4
        height: 10
        radius: height / 2
        color: Theme.errorColor

        Text {
            id: badgeText

            anchors.centerIn: parent
            text: subIcon.badgeCount > 99 ? "99+" : subIcon.badgeCount
            color: Theme.barBackgroundColor
            font.pixelSize: 7
            font.family: Theme.fontFamilyMono
        }
    }

    MouseArea {
        id: hoverArea

        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: subIcon.acceptedButtons
        cursorShape: Qt.PointingHandCursor

        // `hoveredChanged` is the notify signal for the `containsMouse`
        // property; QML has no `hovered` name in scope (that's only the C++
        // read accessor), so read the property explicitly.
        onHoveredChanged: subIcon.hoverChanged(hoverArea.containsMouse)
        onClicked: mouse => subIcon.clicked(mouse)
    }
}
