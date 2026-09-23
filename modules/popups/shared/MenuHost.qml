pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import Quickshell.Widgets
import "../../../config"

// Shared host for the popup menus: entrance animation (opacity + slide),
// frozen-height handling for the StackView, and the push/pop page transitions.
// Each menu supplies menuWidth, the initial page, and its own Connections/lifecycle.
Item {
    id: root

    // Width of the menu and its pages
    property int menuWidth: 220
    // Root page component shown on open
    required property Component initialPage
    // The menu's StackView — pages receive this to push subpages
    readonly property alias stackView: stack
    // Optional lifecycle hooks (Vpn sets menuOpen around the host lifetime)
    property var onEnter: null
    property var onExit: null

    // Frozen height of the root page, so the host doesn't collapse mid-transition
    property int frozenHeight: 0

    implicitWidth: menuWidth
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
        if (root.onEnter)
            root.onEnter();
    }
    Component.onDestruction: {
        if (root.onExit)
            root.onExit();
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
        color: Theme.glassSurface
        radius: Theme.radiusGlassy
        border.width: 1
        border.color: Theme.glassBorder
    }

    ClippingRectangle {
        id: stackClip
        anchors.fill: parent
        radius: Theme.radiusGlassy
        color: "transparent"

        StackView {
            id: stack
            anchors.fill: parent
            clip: true

        initialItem: root.initialPage

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
    }
}
