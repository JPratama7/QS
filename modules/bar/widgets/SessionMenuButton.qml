pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import "../../../components/bar"
import "../../../components"
import "../../../config"
import "../../../services/ui"
import "../../popups/session"

BaseWidget {
	id: widget

	required property string screenName
	required property PanelWindow barWindow

	implicitWidth: label.implicitWidth
	implicitHeight: label.implicitHeight

	tooltipComponent: Component {
		Text {
			text: "Session"
			font.pixelSize: Theme.fontSizeSmall
			color: Theme.foregroundColor
		}
	}

	SvgIcon {
		id: label

		anchors.centerIn: parent
		source: "icons/outline/power.svg"
		color: Theme.foregroundColor
		iconSize: Theme.fontSizeNormal
	}
	MouseArea {
		anchors.fill: parent
		cursorShape: Qt.PointingHandCursor

		onClicked: {
			const pos = widget.mapToItem(null, 0, 0);
			ShellUI.openPopup(widget.screenName, "session", sessionMenuComponent, pos.x);
		}
	}
	Component {
		id: sessionMenuComponent

		SessionMenu {
			screenName: widget.screenName
		}
	}
}
