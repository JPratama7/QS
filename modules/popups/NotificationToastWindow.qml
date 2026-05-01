pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import "../../config"
import "../../services/system"
import "../../types"

PopupWindow {
    id: toastWindow

    required property ScreenContext context

    // The source bar window this popup is anchored to — set by ScreenShellDelegate
    required property PanelWindow barWindow

    anchor.window: toastWindow.barWindow
    grabFocus: false // toasts never steal keyboard focus

    readonly property int toastWidth: 280
    readonly property int toastSpacing: Theme.spacingNormal
    readonly property int edgeMargin: ShellConfig.popupEdgeMargin

    // Compute anchor position based on toastPosition config
    function computeAnchorX(): int {
        const position = ShellConfig.toastPosition;
        const screenWidth = toastWindow.context.screen.width;
        
        switch (position) {
            case "top-left":
            case "bottom-left":
                return edgeMargin;
            case "top-center":
            case "bottom-center":
                return Math.floor((screenWidth - toastWidth) / 2);
            case "top-right":
            case "bottom-right":
                return screenWidth - toastWidth - edgeMargin;
            default:
                return screenWidth - toastWidth - edgeMargin; // default to right
        }
    }

    function computeAnchorY(): int {
        const position = ShellConfig.toastPosition;
        
        switch (position) {
            case "top-left":
            case "top-center":
            case "top-right":
                return toastWindow.context.barHeight + edgeMargin;
            case "bottom-left":
            case "bottom-center":
            case "bottom-right":
                return -(toastColumn.implicitHeight + edgeMargin);
            default:
                return toastWindow.context.barHeight + edgeMargin; // default to top
        }
    }

    anchor.rect.x: computeAnchorX()
    anchor.rect.y: computeAnchorY()

    implicitWidth: toastWidth
    implicitHeight: toastColumn.implicitHeight

    color: "transparent"

    visible: (Notification.toastQueue || []).length > 0

    Column {
        id: toastColumn
        width: parent.width
        spacing: toastWindow.toastSpacing

        Repeater {
            model: Notification.toastQueue || []

            delegate: NotificationToast {
                required property var modelData

                width: toastColumn.width
                notification: modelData.notification

                onDismissed: {
                    // Remove this toast from the queue by notification object
                    Notification.removeToast(modelData.notification);
                }
            }
        }
    }

    // Update anchor position when config changes
    Connections {
        target: ShellConfig

        function onToastPositionChanged() {
            // Force re-evaluation of anchor position
            toastWindow.anchor.rect.x = Qt.binding(() => toastWindow.computeAnchorX());
            toastWindow.anchor.rect.y = Qt.binding(() => toastWindow.computeAnchorY());
        }
    }
}