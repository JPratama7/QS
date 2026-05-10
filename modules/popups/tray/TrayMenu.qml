pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import "../../../config"
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

    opacity: 0
    Behavior on opacity {
        NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
    }

    transform: Translate {
        id: entranceSlide
        y: 20
        Behavior on y {
            NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
        }
    }

    Behavior on implicitHeight {
        NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
    }

    Component.onCompleted: {
        opacity = 1;
        entranceSlide.y = 0;
    }

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
            ParallelAnimation {
                NumberAnimation { property: "x"; from: root.menuWidth; to: 0; duration: 200; easing.type: Easing.OutCubic }
                NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 200; easing.type: Easing.OutCubic }
            }
        }
        pushExit: Transition {
            ParallelAnimation {
                NumberAnimation { property: "x"; from: 0; to: -root.menuWidth; duration: 200; easing.type: Easing.OutCubic }
                NumberAnimation { property: "opacity"; from: 1; to: 0; duration: 200; easing.type: Easing.OutCubic }
            }
        }
        popEnter: Transition {
            ParallelAnimation {
                NumberAnimation { property: "x"; from: -root.menuWidth; to: 0; duration: 200; easing.type: Easing.OutCubic }
                NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 200; easing.type: Easing.OutCubic }
            }
        }
        popExit: Transition {
            ParallelAnimation {
                NumberAnimation { property: "x"; from: 0; to: root.menuWidth; duration: 200; easing.type: Easing.OutCubic }
                NumberAnimation { property: "opacity"; from: 1; to: 0; duration: 200; easing.type: Easing.OutCubic }
            }
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
