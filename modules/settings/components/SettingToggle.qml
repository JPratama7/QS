pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import "../../../config"

RowLayout {
	id: root

	property string text: ""
	property bool checked: false

	signal toggled

	Layout.fillWidth: true
	spacing: 15

	Text {
		text: root.text
		color: Theme.foregroundColor
		font.pixelSize: Theme.fontSizeNormal
		Layout.fillWidth: true
	}
	Rectangle {
		Layout.preferredWidth: PersistentConfig.adapterView.settings?.components?.toggle?.width || 40
		Layout.preferredHeight: PersistentConfig.adapterView.settings?.components?.toggle?.height || 20
		radius: 10
		color: root.checked ? Theme.accentColor : Theme.surfaceColor
		border.color: Theme.surfaceColor
		border.width: 1

		Rectangle {
			width: 16
			height: 16
			radius: 8
			color: Theme.foregroundColor
			x: root.checked ? parent.width - width - 2 : 2
			y: 2

			Behavior on x {
				NumberAnimation {
					duration: 150
					easing.type: Easing.OutQuad
				}
			}
		}
		MouseArea {
			anchors.fill: parent

			onClicked: root.toggled()
		}
	}
}
