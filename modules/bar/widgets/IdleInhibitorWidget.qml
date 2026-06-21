pragma ComponentBehavior: Bound

import QtQuick
import "../../../components/bar"
import "../../../components"
import "../../../config"
import "../../../services/system"

BaseWidget {
	id: widget

	implicitWidth: textItem.implicitWidth
	implicitHeight: textItem.implicitHeight

	tooltipComponent: Component {
		Text {
			text: Idle.inhibited ? "Idle Inhibitor: Active" : "Idle Inhibitor: Inactive"
			font.pixelSize: Theme.fontSizeSmall
			color: Theme.foregroundColor
		}
	}

	SvgIcon {
		id: textItem

		source: "icons/outline/hourglass.svg"
		iconSize: Theme.fontSizeNormal
		color: Idle.inhibited ? Theme.accentColor : Theme.mutedColor
	}
	MouseArea {
		anchors.fill: parent
		cursorShape: Qt.PointingHandCursor

		onClicked: Idle.toggle()
	}
}
