pragma ComponentBehavior: Bound

import "../../types/widgets/bar" as BarTypes
import QtQuick
import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import "../../base" as Base
import "../../config" as Config
import "../../services" as Services

Base.BasePopup {
    id: root

    required property BarTypes.Sizes sizes
    property var drawerItems: []
    signal itemMenuRequested(item: var, anchor: Item)

    popupWidth: columnWidth + (Config.Theme.padding * 2)
    popupHeight: columnHeight + (Config.Theme.padding * 2)

    readonly property int cellSize: root.sizes.icon + Config.Theme.padding
    readonly property int itemsPerRow: 1
    readonly property int rows: drawerItems.length
    readonly property int columnWidth: cellSize
    readonly property int columnHeight: rows * cellSize + (rows - 1) * Config.Theme.spacing

    // Auto-close when empty
    onDrawerItemsChanged: {
        if (visible && drawerItems.length === 0) {
            close();
        }
    }

    backgroundComponent: Rectangle {
        color: Config.Theme.popupBg
        radius: 10
        border.color: Config.Theme.accent
    }

    contentComponent: Column {
        id: column
        spacing: Config.Theme.spacing
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: Config.Theme.spacing

        Repeater {
            model: root.drawerItems

            Item {
                id: gridItem
                required property var modelData
                width: root.cellSize
                height: root.cellSize
                anchors.horizontalCenter: parent.horizontalCenter

                IconImage {
                    id: iconImage
                    anchors.centerIn: parent
                    width: root.sizes.icon
                    height: root.sizes.icon
                    asynchronous: true

                    source: {
                        const icon = gridItem.modelData?.icon;
                        if (!icon) return "";
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

                    opacity: status === Image.Ready ? 1 : 0
                    Behavior on opacity {
                        NumberAnimation { duration: Config.Theme.animationFast }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton

                    onEntered: {
                        const title = gridItem.modelData?.tooltipTitle || gridItem.modelData?.id || "Tray Item";
                        Services.TooltipService.show(gridItem, title, "auto");
                    }

                    onExited: {
                        Services.TooltipService.hide();
                    }

                    onClicked: mouse => {
                        if (!gridItem.modelData) return;
                        Services.TooltipService.hide();

                        if (mouse.button === Qt.LeftButton) {
                            if (!gridItem.modelData.onlyMenu) {
                                gridItem.modelData.activate();
                            }
                            root.close();
                        } else if (mouse.button === Qt.MiddleButton) {
                            gridItem.modelData.secondaryActivate();
                            root.close();
                        } else if (mouse.button === Qt.RightButton) {
                            if (gridItem.modelData.hasMenu && gridItem.modelData.menu) {
                                root.itemMenuRequested(gridItem.modelData, iconImage);
                            }
                        }
                    }

                    onWheel: wheel => {
                        if (wheel.angleDelta.y > 0) {
                            gridItem.modelData?.scroll(Qt.Vertical, 1);
                        } else if (wheel.angleDelta.y < 0) {
                            gridItem.modelData?.scroll(Qt.Vertical, -1);
                        }
                    }
                }
            }
        }
    }
}
