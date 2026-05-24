pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Wayland
import "../../components/containers"
import "../../config"
import "../../services/ui"
import "../../types"

ShellWindow {
	id: triggerZone

	required property ScreenContext context

	name: "bar-trigger"
	screen: context.screen
	WlrLayershell.layer: WlrLayer.Top
	WlrLayershell.exclusionMode: ExclusionMode.Ignore
	WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
	anchors.top: context.barEdge === "top"
	anchors.bottom: context.barEdge === "bottom"
	anchors.left: true
	anchors.right: true
	implicitHeight: ShellConfig.triggerZoneHeight
	color: "transparent"

	// Only active when auto-hide is enabled and bar is hidden
	visible: context.barDisplayMode === "auto_hide" && !BarVisibility.effectiveVisible(context.name)

	HoverHandler {
		id: hoverHandler

		onHoveredChanged: {
			if (hovered) {
				BarVisibility.hoverEnter(triggerZone.context.name);
				BarVisibility.cancelHide(triggerZone.context.name);
				BarVisibility.setForceVisible(triggerZone.context.name, true);
			}
		}
	}
}
