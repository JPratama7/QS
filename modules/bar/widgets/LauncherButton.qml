pragma ComponentBehavior: Bound

import QtQuick
import "../../../components/bar"
import "../../../components"
import "../../../config"
import "../../../services/launcher"

BaseWidget {
	id: widget

	required property string screenName

	implicitWidth: label.implicitWidth + Theme.paddingSmall * 2
	implicitHeight: label.implicitHeight + Theme.paddingSmall * 2

	tooltipComponent: Component {
		Text {
			text: "Launcher"
			font.pixelSize: Theme.fontSizeSmall
			color: Theme.foregroundColor
		}
	}

	Rectangle {
		anchors.fill: parent
		radius: Theme.radiusSmall
		color: mouseArea.containsMouse ? Qt.alpha(Theme.foregroundColor, 0.1) : "transparent"
	}
	SvgIcon {
		id: label

		anchors.centerIn: parent
		source: "icons/outline/menu-2.svg"
		color: Theme.foregroundColor
		iconSize: ShellConfig.barIconSize
	}
	MouseArea {
		id: mouseArea

		anchors.fill: parent
		hoverEnabled: true
		cursorShape: Qt.PointingHandCursor

		onClicked: Launcher.open(widget.screenName)
	}
}
