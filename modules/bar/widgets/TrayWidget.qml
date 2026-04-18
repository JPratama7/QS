pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Services.SystemTray
import "../../../config"
import "../../../services/system"

Item {
    id: widget

    required property string screenName
    required property PanelWindow barWindow

    implicitWidth: trayRow.implicitWidth
    implicitHeight: trayRow.implicitHeight

    visible: Tray.items.length > 0

    Row {
        id: trayRow
        anchors.fill: parent
        spacing: Theme.spacingSmall

        Repeater {
            model: Tray.items

            delegate: Item {
                id: trayItem

                required property SystemTrayItem modelData

                width: Theme.iconSizeSmall
                height: Theme.iconSizeSmall

                Image {
                    anchors.fill: parent
                    source: trayItem.modelData.icon
                    sourceSize.width: width
                    sourceSize.height: height
                    fillMode: Image.PreserveAspectFit
                    smooth: true
                }

                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.LeftButton | Qt.RightButton

                    onClicked: (mouse) => {
                        const item = trayItem.modelData;
                        if (mouse.button === Qt.RightButton || item.onlyMenu || item.hasMenu) {
                            if (item.hasMenu) {
                                const pos = trayItem.mapToItem(null, 0, trayItem.height);
                                item.display(widget.barWindow, pos.x, pos.y);
                            }
                        } else {
                            item.activate();
                        }
                    }
                }
            }
        }
    }
}
