pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import "../../../services/ui"
import "../../../types"

PopupWindow {
	id: popupWindow

	required property ScreenContext context

	// The source bar window this popup is anchored to — set by ScreenShellDelegate
	required property PanelWindow barWindow

	// Horizontal anchor — set via popupRequested signal metadata
	property int anchorX: 0
	property Component activeComponent: null

	// Track if close was triggered internally to prevent recursive close
	property bool _internalClose: false

	anchor.window: popupWindow.barWindow
	anchor.rect.y: popupWindow.context.barEdge === "bottom" ? -popupWindow.implicitHeight : popupWindow.context.barHeight
	anchor.rect.x: popupWindow.anchorX

	// qmllint disable missing-property
	implicitWidth: popupContent.item ? popupContent.item.implicitWidth : 0
	implicitHeight: popupContent.item ? popupContent.item.implicitHeight : 0
	// qmllint enable missing-property

	// Dismiss on click outside
	grabFocus: true
	visible: popupWindow.activeComponent !== null
	color: "transparent"

	Component.onCompleted: console.log("PMW: completed context=" + popupWindow.context.name + " barWindow=" + !!popupWindow.barWindow)
	onActiveComponentChanged: {
		if (activeComponent)
			popupContent.sourceComponent = activeComponent;
		else
			Qt.callLater(() => {
				if (popupWindow.activeComponent === null)
					popupContent.sourceComponent = null;
			});
	}
	// Detect external dismissal (click outside, Escape, focus loss)
	// When visible becomes false while activeComponent is set, notify ShellUI
	// ShellUI will emit popupClosed signal, triggering our onPopupClosed handler
	onVisibleChanged: {
		console.log("PMW: visible -> " + visible + " active=" + (activeComponent !== null))
		if (!visible && activeComponent !== null && !_internalClose) {
			ShellUI.closePopup(context.name);
		}
		if (!visible) {
			_internalClose = false;
		}
	}

	// Managed manually — unbind from activeComponent to defer content destruction
	// Window must hide first before Loader destroys content (avoids Wayland "Invalid size")
	Loader {
		id: popupContent

		anchors.fill: parent
		sourceComponent: null
	}
	Connections {
		function onPopupRequested(screenName: string, popupId: string, component: var, anchorX: int) {
			console.log("PMW: request screen=" + screenName + " id=" + popupId + " match=" + (screenName === popupWindow.context.name))
			if (screenName !== popupWindow.context.name)
				return;
			popupWindow.anchorX = anchorX;
			popupWindow.activeComponent = component;
			BarVisibility.popupOpen(screenName);
		}
		function onPopupClosed(screenName: string) {
			if (screenName !== popupWindow.context.name)
				return;
			popupWindow._internalClose = true;
			popupWindow.activeComponent = null;
			BarVisibility.popupClose(screenName);
		}

		target: ShellUI
	}
}
