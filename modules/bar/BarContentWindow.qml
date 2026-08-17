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
	readonly property bool _barActive: BarVisibility.effectiveVisible(context.name)

	name: "bar-content"
	screen: context.screen
	aboveWindows: true
	WlrLayershell.layer: WlrLayer.Top
	WlrLayershell.exclusionMode: ExclusionMode.Auto
	WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
	implicitHeight: context.barHeight
	exclusiveZone: barWindow._barActive && context.barDisplayMode !== "non_exclusive" ? context.barHeight : 0
	color: Theme.backgroundColor
	visible: context.barDisplayMode !== "hidden" && BarVisibility.effectiveVisible(context.name) || context.barDisplayMode === "auto_hide"
	anchors.top: context.barEdge === "top"
	anchors.bottom: context.barEdge === "bottom"
	anchors.left: true
	anchors.right: true

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
		shown: barWindow._barActive
	}
}
