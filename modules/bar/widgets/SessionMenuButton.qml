pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import "../../../components/bar"
import "../../../components"
import "../../../config"
import "../../../services/ui"

BaseWidget {
	id: widget

	required property string screenName
	required property PanelWindow barWindow

	implicitWidth: label.implicitWidth + Theme.paddingSmall * 2
	implicitHeight: label.implicitHeight + Theme.paddingSmall * 2

	tooltipComponent: Component {
		Text {
			text: "Session"
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
		source: "icons/outline/power.svg"
		color: Theme.foregroundColor
		iconSize: ShellConfig.barIconSize
	}

	MouseArea {
		id: mouseArea

		anchors.fill: parent
		hoverEnabled: true
		cursorShape: Qt.PointingHandCursor

		onClicked: {
			ShellUI.openSession(widget.screenName);
		}
	}
}
