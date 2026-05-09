pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import "../../config"
import "."

Item {
    id: root

    required property string screenName
    required property var menuHandle
    onMenuHandleChanged: root.frozenHeight = 0

    readonly property int menuWidth: 220

    implicitWidth: menuWidth
    property int frozenHeight: 0
    implicitHeight: (stack.depth >= 1 && stack.currentItem) ? stack.currentItem.implicitHeight : Math.max(frozenHeight, 0)

    Connections {
        target: stack
        function onCurrentItemChanged() {
            if (stack.depth === 1 && stack.currentItem) {
                // Use callLater to ensure implicitHeight is computed after page content is loaded
                Qt.callLater(() => {
                    if (stack.currentItem && stack.depth === 1)
                        root.frozenHeight = stack.currentItem.implicitHeight;
                });
            }
        }
    }

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
            screenName: root.screenName
            width: root.menuWidth
        }
    }
}
