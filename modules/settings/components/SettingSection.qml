pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import "../../../config"

ColumnLayout {
	id: root

	property string title: ""
	property bool expanded: false
	default property alias content: innerLayout.data

	Layout.fillWidth: true
	spacing: 10

	// Header row with title and expand/collapse indicator
	Item {
		Layout.fillWidth: true
		Layout.preferredHeight: headerRow.implicitHeight

		RowLayout {
			id: headerRow

			anchors.fill: parent
			spacing: 10

			Text {
				text: root.title
				color: Theme.accentColor
				font.pixelSize: Theme.fontSizeLarge
				font.bold: true
				Layout.fillWidth: true
			}
			Text {
				text: root.expanded ? "\u25BC" : "\u25B6"
				color: Theme.foregroundColor
				font.pixelSize: Theme.fontSizeNormal
			}
		}
		MouseArea {
			anchors.fill: parent

			onClicked: root.expanded = !root.expanded
		}
	}
	Rectangle {
		Layout.fillWidth: true
		height: 1
		color: Theme.surfaceColor
	}
	ColumnLayout {
		id: innerLayout

		Layout.fillWidth: true
		spacing: 15
		visible: root.expanded
	}
}
