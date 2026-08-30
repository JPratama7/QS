pragma ComponentBehavior: Bound

import QtQuick
import "../../../components/bar"
import "../../../components"
import "../../../config"
import "../../../services/system"

BaseWidget {
	id: widget

	implicitWidth: textItem.implicitWidth + Theme.paddingSmall * 2
	implicitHeight: textItem.implicitHeight + Theme.paddingSmall * 2

	tooltipComponent: Component {
		Text {
			text: Idle.inhibited ? "Idle Inhibitor: Active" : "Idle Inhibitor: Inactive"
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
		id: textItem

		anchors.centerIn: parent
		source: "icons/outline/hourglass.svg"
		iconSize: ShellConfig.barIconSize
		color: Idle.inhibited ? Theme.accentColor : Theme.mutedColor
	}

	MouseArea {
		id: mouseArea

		anchors.fill: parent
		hoverEnabled: true
		cursorShape: Qt.PointingHandCursor

		onClicked: Idle.toggle()
	}
}
