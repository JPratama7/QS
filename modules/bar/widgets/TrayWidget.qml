pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Services.SystemTray
import "../../../config"
import "../../../components/bar"
import "../../../services/system"
import "../../../services/ui"
import "../../popups/tray"

BaseWidget {
    id: widget

    required property string screenName
    required property PanelWindow barWindow

    tooltipComponent: Component {
        Text {
            text: "System Tray"
            font.pixelSize: Theme.fontSizeSmall
            color: Theme.foregroundColor
        }
    }

    implicitWidth: trayRow.implicitWidth
    implicitHeight: trayRow.implicitHeight

    visible: Tray.items.length > 0

    Row {
        id: trayRow
        anchors.fill: parent
        spacing: Theme.spacingNormal

        Repeater {
            model: Tray.items

            delegate: Item {
                id: trayItem

                required property SystemTrayItem modelData

                width: ShellConfig.barIconSize
                height: ShellConfig.barIconSize

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
                                const pos = trayItem.mapToItem(null, 0, 0);
                                Tray.setActiveRequest(item, pos.x, pos.y);
                                ShellUI.openPopup(widget.screenName, "tray", trayMenuComponent, pos.x);
                            }
                        } else {
                            item.activate();
                        }
                    }
                }
            }
        }
    }

    Component {
        id: trayMenuComponent
        TrayMenu {
            screenName: widget.screenName
            menuHandle: Tray.activeRequest ? Tray.activeRequest.item.menu : null
        }
    }
}
