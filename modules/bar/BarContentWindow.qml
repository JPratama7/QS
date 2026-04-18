pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Wayland
import "../../components/containers"
import "../../types"
import "../../config"
import "../../services/ui"

ShellWindow {
    id: barWindow

    required property ScreenContext context

    name: "bar-content"
    screen: context.screen

    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.exclusionMode: ExclusionMode.Auto
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    anchors {
        top: true
        left: true
        right: true
    }

    implicitHeight: context.barHeight

    // Reserve compositor space only when the bar should be visible and exclusive
    exclusiveZone: BarVisibility.effectiveVisible(context.name)
                   && context.barDisplayMode !== "non_exclusive"
                   ? context.barHeight : 0

    color: Theme.backgroundColor

    visible: BarVisibility.effectiveVisible(context.name)

    HoverHandler {
        id: barHover
        onHoveredChanged: {
            BarVisibility.setHovered(barWindow.context.name, hovered);
            if (hovered) {
                BarVisibility.cancelHide(barWindow.context.name);
                BarVisibility.setForceVisible(barWindow.context.name, true);
            }
        }
    }

    BarView {
        id: barView
        anchors.fill: parent
        context: barWindow.context
    }
}
