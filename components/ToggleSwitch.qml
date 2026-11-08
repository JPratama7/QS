pragma ComponentBehavior: Bound

import QtQuick
import "../config"

// Compact on/off switch — mockup scale (30x16), accent fill when on.
Item {
    id: switchRoot

    property bool checked: false

    signal toggled()

    width: 30
    height: 16

    Rectangle {
        anchors.fill: parent
        radius: height / 2
        color: switchRoot.checked ? Theme.accentColor : Qt.alpha(Theme.foregroundColor, 0.2)

        Behavior on color {
            ColorAnimation { duration: Theme.hoverDuration }
        }

        Rectangle {
            width: 12
            height: 12
            radius: width / 2
            color: Theme.foregroundColor
            y: (parent.height - height) / 2
            x: switchRoot.checked ? parent.width - width - 2 : 2

            Behavior on x {
                NumberAnimation { duration: Theme.hoverDuration; easing.type: Easing.OutCubic }
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        onClicked: switchRoot.toggled()
    }
}
