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

	implicitWidth: label.implicitWidth
	implicitHeight: label.implicitHeight

	tooltipComponent: Component {
		Text {
			text: Vpn.connected ? Vpn.connectedNames.join(", ") : "VPN: Off"
			font.pixelSize: Theme.fontSizeSmall
			color: Theme.foregroundColor
		}
	}

	SvgIcon {
		id: label

		anchors.centerIn: parent
		source: "icons/outline/world.svg"
		color: Vpn.connected ? Theme.accentColor : Theme.mutedColor
		iconSize: ShellConfig.barIconSize
	}
	MouseArea {
		anchors.fill: parent
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
