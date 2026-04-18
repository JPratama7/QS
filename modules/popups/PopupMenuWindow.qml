pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Wayland
import "../../types"
import "../../services/ui"

PopupWindow {
    id: popupWindow

    required property ScreenContext context

    // The source bar window this popup is anchored to — set by ScreenShellDelegate
    required property PanelWindow barWindow

    anchor.window: popupWindow.barWindow
    anchor.rect.y: popupWindow.context.barHeight

    // Horizontally centered on the bar by default; content may override via contentX
    anchor.rect.x: 0
    anchor.rect.width: popupWindow.barWindow.width

    implicitWidth: popupContent.implicitWidth
    implicitHeight: popupContent.implicitHeight

    // Dismiss on click outside
    grabFocus: true

    visible: ShellUI.isPopupOpen(popupWindow.context.name)

    color: "transparent"

    // Placeholder content container — Tasks 4.4 and 4.7 will swap real content in here
    Item {
        id: popupContent
        anchors.fill: parent

        implicitWidth: 200
        implicitHeight: 1
    }

    Connections {
        target: ShellUI
        function onActivePopupChanged(screenName: string) {
            if (screenName !== popupWindow.context.name)
                return;
            const open = ShellUI.isPopupOpen(screenName);
            BarVisibility.setPopupOpen(screenName, open);
        }
    }

    onVisibleChanged: {
        if (!visible)
            ShellUI.closePopup(popupWindow.context.name);
    }
}
