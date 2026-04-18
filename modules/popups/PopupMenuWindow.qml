pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import "../../types"
import "../../services/ui"
import "../../services/system"

PopupWindow {
    id: popupWindow

    required property ScreenContext context

    // The source bar window this popup is anchored to — set by ScreenShellDelegate
    required property PanelWindow barWindow

    anchor.window: popupWindow.barWindow
    anchor.rect.y: popupWindow.context.barHeight

    anchor.rect.x: Tray.activeRequest ? Tray.activeRequest.anchorX : 0

    // qmllint disable missing-property
    implicitWidth: popupContent.item ? popupContent.item.implicitWidth : 0
    implicitHeight: popupContent.item ? popupContent.item.implicitHeight : 0
    // qmllint enable missing-property

    // Dismiss on click outside
    grabFocus: true

    property string activePopupId: ""

    visible: popupWindow.activePopupId !== ""

    color: "transparent"

    Loader {
        id: popupContent
        anchors.fill: parent

        readonly property string activeId: popupWindow.activePopupId

        sourceComponent: {
            if (activeId === "tray") return trayMenuComponent;
            return null;
        }
    }

    Component {
        id: trayMenuComponent
        TrayMenu {
            menuHandle: Tray.activeRequest ? Tray.activeRequest.item.menu : null
        }
    }

    Connections {
        target: ShellUI
        function onActivePopupChanged(screenName: string) {
            if (screenName !== popupWindow.context.name)
                return;
            popupWindow.activePopupId = ShellUI.activePopup(screenName);
            BarVisibility.setPopupOpen(screenName, popupWindow.activePopupId !== "");
        }
    }

    onVisibleChanged: {
        if (!visible) {
            popupWindow.activePopupId = "";
            ShellUI.closePopup(popupWindow.context.name);
        }
    }
}
