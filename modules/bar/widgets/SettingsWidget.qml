pragma ComponentBehavior: Bound

import QtQuick
import "../../../components/bar"
import "../../../config"
import "../../../services/ui"

BaseWidget {
	id: widget

	required property string screenName

	implicitWidth: label.implicitWidth + Theme.paddingSmall * 2
	implicitHeight: label.implicitHeight + Theme.paddingSmall * 2

	tooltipComponent: Component {
		Text {
			text: "Settings"
			font.pixelSize: Theme.fontSizeSmall
			color: Theme.foregroundColor
		}
	}

	Component.onCompleted: {
		console.log("Settings is loaded");
	}

	Rectangle {
		anchors.fill: parent
		radius: Theme.radiusSmall
		color: mouseArea.containsMouse ? Qt.alpha(Theme.foregroundColor, 0.1) : "transparent"
	}
	Text {
		id: label

		anchors.centerIn: parent
		text: "\u2699"
		color: Theme.foregroundColor
		font.pixelSize: Theme.fontSizeNormal
		font.family: Theme.fontFamily
	}
	MouseArea {
		id: mouseArea

		anchors.fill: parent
		hoverEnabled: true
		cursorShape: Qt.PointingHandCursor

		onClicked: ShellUI.openSettings(widget.screenName)
	}
}
