pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import "../../config" as Config
import "../../services" as Services

Item {
    id: root

    required property SystemTrayItem modelData
    property bool showTooltip: true

    implicitWidth: Config.Theme.iconSize
    implicitHeight: Config.Theme.iconSize

    IconImage {
        id: iconImage

        anchors.centerIn: parent
        anchors.fill: parent
        anchors.margins: 2  // Add small margins for better visual balance
        asynchronous: true

        source: {
            const icon = root.modelData?.icon;
            if (!icon)
                return "";

            // Process icon path (handle ?path= format)
            const iconStr = icon.toString();
            if (iconStr.includes("?path=")) {
                const chunks = iconStr.split("?path=");
                const name = chunks[0];
                const path = chunks[1];
                const fileName = name.substring(name.lastIndexOf("/") + 1);
                return `file://${path}/${fileName}`;
            }
            return iconStr;
        }

        // Fade in when loaded
        opacity: status === Image.Ready ? 1 : 0

        Behavior on opacity {
            NumberAnimation {
                duration: Config.Theme.animationFast
            }
        }
    }

    MouseArea {
        id: mouseArea

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton

        onEntered: {
            if (root.showTooltip && root.modelData) {
                const title = root.modelData.tooltipTitle || root.modelData.id || "Tray Item";
                Services.TooltipService.show(root, title, "auto");
            }
        }

        onExited: {
            Services.TooltipService.hide();
        }

        onClicked: mouse => {
            if (!root.modelData)
                return;

            Services.TooltipService.hide();

            console.log("Onclick Tray Item")

            if (mouse.button === Qt.LeftButton) {
                if (!root.modelData.onlyMenu) {
                    root.modelData.activate();
                }
            } else if (mouse.button === Qt.MiddleButton) {
                root.modelData.secondaryActivate();
            } else if (mouse.button === Qt.RightButton) {
                // Signal for parent to handle menu
                root.menuRequested(mouse);
            }
        }

        onWheel: wheel => {
            if (wheel.angleDelta.y > 0) {
                root.modelData?.scroll(Qt.Vertical, 1);
            } else if (wheel.angleDelta.y < 0) {
                root.modelData?.scroll(Qt.Vertical, -1);
            }
        }
    }

    // Signal emitted when right-click menu is requested
    signal menuRequested(mouse: var)
}
