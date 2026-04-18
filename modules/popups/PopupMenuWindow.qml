pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import "../../types"
import "../../services/ui"

PopupWindow {
    id: popupWindow

    required property ScreenContext context

    // The source bar window this popup is anchored to — set by ScreenShellDelegate
    required property PanelWindow barWindow

    anchor.window: popupWindow.barWindow
    anchor.rect.y: popupWindow.context.barHeight

    // Horizontal anchor — set via popupRequested signal metadata
    property int anchorX: 0
    anchor.rect.x: popupWindow.anchorX

    // qmllint disable missing-property
    implicitWidth: popupContent.item ? popupContent.item.implicitWidth : 0
    implicitHeight: popupContent.item ? popupContent.item.implicitHeight : 0
    // qmllint enable missing-property

    // Dismiss on click outside
    grabFocus: true

    property var activeComponent: null

    visible: popupWindow.activeComponent !== null

    color: "transparent"

    Loader {
        id: popupContent
        anchors.fill: parent
        sourceComponent: popupWindow.activeComponent
    }

    Connections {
        target: ShellUI

        function onPopupRequested(screenName: string, popupId: string, component: var, anchorX: int) {
            if (screenName !== popupWindow.context.name)
                return;
            popupWindow.anchorX = anchorX;
            popupWindow.activeComponent = component;
            BarVisibility.setPopupOpen(screenName, true);
        }

        function onPopupClosed(screenName: string) {
            if (screenName !== popupWindow.context.name)
                return;
            popupWindow.activeComponent = null;
            BarVisibility.setPopupOpen(screenName, false);
        }
    }

    onVisibleChanged: {
        if (!visible) {
            popupWindow.activeComponent = null;
            ShellUI.closePopup(popupWindow.context.name);
        }
    }
}
