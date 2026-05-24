pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import "../../../config"

RowLayout {
	id: root

	property string text: ""
	property int currentValue: 0
	property int minValue: 0
	property int maxValue: 1000
	property int step: 1

	signal valueChanged(int newValue)

	Layout.fillWidth: true
	spacing: 15

	Text {
		text: root.text
		color: Theme.foregroundColor
		font.pixelSize: Theme.fontSizeNormal
		Layout.fillWidth: true
	}
	RowLayout {
		spacing: 5

		Rectangle {
			width: 30
			height: 30
			radius: Theme.radiusSmall
			color: Theme.surfaceColor
			border.color: Theme.surfaceColor
			border.width: 1

			Text {
				anchors.centerIn: parent
				text: "-"
				color: Theme.foregroundColor
				font.pixelSize: Theme.fontSizeLarge
				font.bold: true
			}
			MouseArea {
				anchors.fill: parent

				onClicked: {
					if (root.currentValue - root.step >= root.minValue) {
						root.valueChanged(root.currentValue - root.step);
					}
				}
			}
		}
		Rectangle {
			width: 60
			height: 30
			radius: Theme.radiusSmall
			color: Theme.backgroundColor
			border.color: Theme.surfaceColor
			border.width: 1

			Text {
				anchors.centerIn: parent
				text: root.currentValue.toString()
				color: Theme.foregroundColor
				font.pixelSize: Theme.fontSizeNormal
			}
		}
		Rectangle {
			width: 30
			height: 30
			radius: Theme.radiusSmall
			color: Theme.surfaceColor
			border.color: Theme.surfaceColor
			border.width: 1

			Text {
				anchors.centerIn: parent
				text: "+"
				color: Theme.foregroundColor
				font.pixelSize: Theme.fontSizeLarge
				font.bold: true
			}
			MouseArea {
				anchors.fill: parent

				onClicked: {
					if (root.currentValue + root.step <= root.maxValue) {
						root.valueChanged(root.currentValue + root.step);
					}
				}
			}
		}
	}
}
