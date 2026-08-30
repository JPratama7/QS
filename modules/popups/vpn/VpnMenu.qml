pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Dialogs
import "../../../config"
import "../../../services/system"
import "."

Item {
    id: root

    required property string screenName

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
        Vpn.menuOpen = true;
        opacity = 1;
        entranceSlide.y = 0;
    }

    Component.onDestruction: {
        Vpn.menuOpen = false;
    }

    Connections {
        target: stack
        function onCurrentItemChanged() {
            if (stack.depth === 1 && stack.currentItem) {
                Qt.callLater(() => {
                    if (stack.currentItem && stack.depth === 1)
                        root.frozenHeight = stack.currentItem.implicitHeight;
                });
            }
        }
    }

    // sudo -n cache miss on disconnect/disconnectAll/delete → collect password.
    // The action payload is forwarded verbatim to Vpn.supplyPassword() on submit.
    Connections {
        target: Vpn
        function onElevationRequired(action: var) {
            const verb = action.type === "delete" ? "delete" : "disconnect";
            stack.push(Qt.resolvedUrl("VpnPasswordPage.qml"), {
                title: "Enter the sudo password to " + verb,
                name: action.name,
                mode: "disconnect",
                action: action,
                stackView: stack,
                screenName: root.screenName,
                width: root.menuWidth
            });
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
        VpnMainPage {
            screenName: root.screenName
            stackView: stack
            width: root.menuWidth
            onImportRequested: importDialog.open()
        }
    }

    // Owned by the root so it survives page transitions (plan §5.4).
    FileDialog {
        id: importDialog
        fileMode: FileDialog.OpenFiles
        nameFilters: ["OpenVPN configuration files (*.ovpn)"]
        acceptLabel: "Import"
        onAccepted: Vpn.importConfigs(importDialog.selectedFiles)
    }
}
