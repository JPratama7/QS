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
        const barAtBottom = toastWindow.context.barEdge === "bottom";

        switch (position) {
            case "top-left":
            case "top-center":
            case "top-right":
                // Add barHeight only when the bar occupies the top edge
                return (barAtBottom ? 0 : toastWindow.context.barHeight) + edgeMargin;
            case "bottom-left":
            case "bottom-center":
            case "bottom-right":
                // Subtract barHeight as well when the bar occupies the bottom edge
                return -(toastColumn.implicitHeight + edgeMargin + (barAtBottom ? toastWindow.context.barHeight : 0));
            default:
                return (barAtBottom ? 0 : toastWindow.context.barHeight) + edgeMargin; // default to top
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
}