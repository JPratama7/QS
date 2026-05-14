pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Wayland
import "../../components/containers"
import "../../config"
import "../../services/ui"
import "../../types"

ShellWindow {
	id: barWindow

	required property ScreenContext context

	name: "bar-content"
	screen: context.screen
	aboveWindows: true
	WlrLayershell.layer: WlrLayer.Top
	WlrLayershell.exclusionMode: ExclusionMode.Auto
	WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
	implicitHeight: context.barHeight

	// Reserve compositor space only when the bar should be visible and exclusive
	exclusiveZone: BarVisibility.effectiveVisible(context.name) && context.barDisplayMode !== "non_exclusive" ? context.barHeight : 0
	color: Theme.backgroundColor
	visible: BarVisibility.effectiveVisible(context.name)

	anchors {
		top: true
		left: true
		right: true
	}
	HoverHandler {
		id: barHover

		onHoveredChanged: {
			if (hovered) {
				BarVisibility.hoverEnter(barWindow.context.name);
				BarVisibility.cancelHide(barWindow.context.name);
				BarVisibility.setForceVisible(barWindow.context.name, true);
			} else {
				BarVisibility.hoverLeave(barWindow.context.name);
			}
		}
	}
	BarView {
		id: barView

		anchors.fill: parent
		context: barWindow.context
		barWindow: barWindow
	}
}
