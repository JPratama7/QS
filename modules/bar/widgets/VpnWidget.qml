pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import "../../../components/bar"
import "../../../components"
import "../../../config"
import "../../../services/ui"
import "../../../services/system"
import "../../popups/vpn"

BaseWidget {
	id: widget

	required property string screenName
	required property PanelWindow barWindow

	implicitWidth: label.implicitWidth + Theme.paddingSmall * 2
	implicitHeight: label.implicitHeight + Theme.paddingSmall * 2

	tooltipComponent: Component {
		Text {
			text: Vpn.connected ? Vpn.connectedNames.join(", ") : "VPN: Off"
			font.pixelSize: Theme.fontSizeSmall
			color: Theme.foregroundColor
		}
	}

	Rectangle {
		anchors.fill: parent
		radius: Theme.radiusSmall
		color: mouseArea.containsMouse ? Theme.hoverColor : "transparent"
	}

	SvgIcon {
		id: label

		anchors.centerIn: parent
		source: "icons/outline/world.svg"
		color: Vpn.connected ? Theme.accentColor : Theme.mutedColor
		iconSize: ShellConfig.barIconSize
	}

	MouseArea {
		id: mouseArea

		anchors.fill: parent
		hoverEnabled: true
		cursorShape: Qt.PointingHandCursor

		onClicked: {
			const pos = widget.mapToItem(null, 0, 0);
			ShellUI.openPopup(widget.screenName, "vpn", vpnMenuComponent, pos.x);
		}
	}

	Component {
		id: vpnMenuComponent

		VpnMenu {
			screenName: widget.screenName
		}
	}
}
