pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import "../../config"
import "."

Item {
    id: root

    required property var menuHandle

    readonly property int menuWidth: 220

    implicitWidth: menuWidth
    implicitHeight: stack.currentItem ? stack.currentItem.implicitHeight : 0

    Rectangle {
        anchors.fill: parent
        color: Theme.surfaceColor
        radius: Theme.radiusNormal
    }

    StackView {
        id: stack
        anchors.fill: parent
        clip: true

        initialItem: menuPage

        pushEnter: Transition {
            NumberAnimation { property: "x"; from: root.menuWidth; to: 0; duration: 180; easing.type: Easing.OutCubic }
        }
        pushExit: Transition {
            NumberAnimation { property: "x"; from: 0; to: -root.menuWidth / 3; duration: 180; easing.type: Easing.OutCubic }
        }
        popEnter: Transition {
            NumberAnimation { property: "x"; from: -root.menuWidth / 3; to: 0; duration: 180; easing.type: Easing.OutCubic }
        }
        popExit: Transition {
            NumberAnimation { property: "x"; from: 0; to: root.menuWidth; duration: 180; easing.type: Easing.OutCubic }
        }
    }

    Component {
        id: menuPage
        TrayMenuPage {
            menuHandle: root.menuHandle
            stackView: stack
            width: root.menuWidth
        }
    }
}
