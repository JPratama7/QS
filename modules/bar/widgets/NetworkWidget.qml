pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import "../../../components/bar"
import "../../../config"
import "../../../services/system"
import "../../../services/ui"
import "../../popups/controlcenter"

BaseWidget {
	id: widget

	required property string screenName
	required property PanelWindow barWindow

	tooltipComponent: Component {
		Text {
			text: Network.connected ? "WiFi: " + Network.ssid : "WiFi: Off"
			font.pixelSize: Theme.fontSizeSmall
			color: Theme.foregroundColor
		}
	}

	implicitWidth: text.implicitWidth + Theme.paddingSmall * 2
	implicitHeight: text.implicitHeight + Theme.paddingSmall * 2

	Rectangle {
		anchors.fill: parent
		radius: Theme.radiusSmall
		color: mouseArea.containsMouse ? Theme.hoverColor : "transparent"
	}

	Text {
		id: text

		anchors.centerIn: parent
		text: Network.connected ? Network.ssid : "Off"
		color: Network.connected ? Theme.foregroundColor : Theme.mutedColor
		font.pixelSize: Theme.fontSizeSmall
		font.family: Theme.fontFamily
	}

	MouseArea {
		id: mouseArea

		anchors.fill: parent
		hoverEnabled: true
		cursorShape: Qt.PointingHandCursor

		onClicked: {
			const pos = widget.mapToItem(null, 0, 0);
			const ccWidth = 360;
			// Right-zone widget: right-align the card and clamp inside the bar window
			const anchorX = Math.max(0, Math.min(pos.x, widget.barWindow.width - ccWidth - Theme.paddingNormal));
			ShellUI.openPopup(widget.screenName, "controlcenter", controlCenterComponent, anchorX);
		}
	}

	Component {
		id: controlCenterComponent

		ControlCenter {
			screenName: widget.screenName
		}
	}
}
