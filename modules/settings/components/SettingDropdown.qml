pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import "../../../config"

ColumnLayout {
	id: root

	property string text: ""
	property string currentValue: ""
	property var options: []
	property bool _expanded: false

	signal valueChanged(string newValue)

	Layout.fillWidth: true
	spacing: 4

	// Label row + clickable value display
	RowLayout {
		Layout.fillWidth: true
		spacing: 15

		Text {
			text: root.text
			color: Theme.foregroundColor
			font.pixelSize: Theme.fontSizeNormal
			Layout.fillWidth: true
		}
		Rectangle {
			Layout.preferredWidth: PersistentConfig.adapterView.settings?.components?.select?.width || 140
			Layout.preferredHeight: PersistentConfig.adapterView.settings?.components?.select?.height || 30
			radius: Theme.radiusSmall
			color: Theme.surfaceColor
			border.color: root._expanded ? Theme.accentColor : Theme.surfaceColor
			border.width: 1

			Text {
				anchors.centerIn: parent
				text: root.currentValue
				color: Theme.foregroundColor
				font.pixelSize: Theme.fontSizeNormal
				elide: Text.ElideRight
				width: parent.width - 10
				horizontalAlignment: Text.AlignHCenter
			}
			MouseArea {
				anchors.fill: parent
				cursorShape: Qt.PointingHandCursor

				onClicked: {
					root._expanded = !root._expanded;
					if (root._expanded) {
						searchField.text = "";
						filteredModel.model = root.options;
					}
				}
			}
		}
	}

	// Expandable dropdown panel (inline, no Popup)
	Rectangle {
		Layout.fillWidth: true
		Layout.preferredHeight: root._expanded ? 200 : 0
		clip: true
		color: Theme.surfaceColor
		radius: Theme.radiusNormal
		border.color: Qt.alpha(Theme.foregroundColor, 0.1)
		border.width: 1
		visible: root._expanded

		// Animate expand/collapse
		Behavior on Layout.preferredHeight {
			NumberAnimation {
				duration: 120
				easing.type: Easing.OutQuad
			}
		}

		ColumnLayout {
			anchors.fill: parent
			anchors.margins: 8
			spacing: 6

			// Search field
			Rectangle {
				Layout.fillWidth: true
				Layout.preferredHeight: 28
				radius: Theme.radiusSmall
				color: Theme.backgroundColor
				border.color: Theme.surfaceColor
				border.width: 1

				TextInput {
					id: searchField

					anchors.fill: parent
					anchors.margins: 6
					verticalAlignment: Text.AlignVCenter
					color: Theme.foregroundColor
					font.pixelSize: Theme.fontSizeNormal
					selectionColor: Qt.alpha(Theme.accentColor, 0.3)

					onTextChanged: {
						const q = text.toLowerCase().trim();
						if (q === "") {
							filteredModel.model = root.options;
						} else {
							filteredModel.model = root.options.filter(o => o.toLowerCase().includes(q));
						}
					}
					Keys.onEscapePressed: {
						root._expanded = false;
					}

					Text {
						anchors.fill: parent
						verticalAlignment: Text.AlignVCenter
						text: "Search..."
						color: Theme.mutedColor
						font.pixelSize: Theme.fontSizeNormal
						visible: !searchField.text && !searchField.activeFocus
					}
				}
			}

			// Scrollable list of options
			ListView {
				id: filteredModel

				Layout.fillWidth: true
				Layout.fillHeight: true
				clip: true
				model: root.options
				spacing: 1

				delegate: Rectangle {
					required property string modelData

					width: filteredModel.width
					height: 26
					radius: Theme.radiusSmall
					color: mouseArea.containsMouse ? Qt.alpha(Theme.accentColor, 0.15) : "transparent"

					Component.onCompleted: {
						console.log("modelData:", modelData);
					}

					Text {
						anchors.left: parent.left
						anchors.verticalCenter: parent.verticalCenter
						anchors.leftMargin: 8
						text: parent.modelData
						color: root.currentValue === parent.modelData ? Theme.accentColor : Theme.foregroundColor
						font.pixelSize: Theme.fontSizeNormal
						font.bold: root.currentValue === parent.modelData
						elide: Text.ElideRight
						width: parent.width - 16
					}
					MouseArea {
						id: mouseArea

						anchors.fill: parent
						hoverEnabled: true
						cursorShape: Qt.PointingHandCursor

						onClicked: {
							root.valueChanged(parent.modelData);
							root._expanded = false;
						}
					}
				}
			}
		}
	}
}
