pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import "../../../config"

RowLayout {
	id: root

	property string text: ""
	property string currentValue: ""
	property var options: [] // Array of string options

	signal valueChanged(string newValue)

	Layout.fillWidth: true
	spacing: 15

	Text {
		text: root.text
		color: Theme.foregroundColor
		font.pixelSize: Theme.fontSizeNormal
		Layout.fillWidth: true
	}
	Rectangle {
		Layout.preferredWidth: PersistentConfig.adapterView.settings?.components?.select?.width || 100
		Layout.preferredHeight: PersistentConfig.adapterView.settings?.components?.select?.height || 30
		radius: Theme.radiusSmall
		color: Theme.surfaceColor
		border.color: Theme.surfaceColor
		border.width: 1

		Text {
			anchors.centerIn: parent
			text: root.currentValue
			color: Theme.foregroundColor
			font.pixelSize: Theme.fontSizeNormal
		}
		MouseArea {
			anchors.fill: parent

			onClicked: {
				const currentIndex = root.options.indexOf(root.currentValue);
				const nextIndex = (currentIndex + 1) % root.options.length;
				root.valueChanged(root.options[nextIndex]);
			}
		}
	}
}
