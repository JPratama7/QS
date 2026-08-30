pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import ".."
import "../../../components"
import "../../../config"

ColumnLayout {
	id: root

	property string text: ""
	property string currentValue: ""
	property var options: ([])
	property bool _expanded: false

	signal valueChanged(string newValue)

	Layout.fillWidth: true
	spacing: 4

	// Trigger row — label left, value button right (same 2-section structure)
	SettingRow {
		Layout.fillWidth: true
		text: root.text

		// Trigger button: value + rotating chevron
		Rectangle {
			id: trigger

			Layout.alignment: Qt.AlignRight
			Layout.preferredWidth: 140
			Layout.preferredHeight: 28
			radius: Theme.radiusSmall
			color: triggerMouse.containsMouse ? Theme.hoverColor : Theme.surfaceColor
			border.color: root._expanded ? Theme.accentColor : (triggerMouse.containsMouse ? Qt.alpha(Theme.foregroundColor, 0.25) : Theme.borderColor)
			border.width: 1

			Behavior on color {
				ColorAnimation {
					duration: Theme.hoverDuration
					easing.type: Easing.OutQuad
				}
			}
			Behavior on border.color {
				ColorAnimation {
					duration: Theme.hoverDuration
					easing.type: Easing.OutQuad
				}
			}

			RowLayout {
				anchors.fill: parent
				anchors.leftMargin: 10
				anchors.rightMargin: 8
				spacing: 6

				Text {
					Layout.fillWidth: true
					text: root.currentValue
					color: Theme.foregroundColor
					font.pixelSize: Theme.fontSizeNormal
					font.family: Theme.fontFamilyMono
					elide: Text.ElideRight
					verticalAlignment: Text.AlignVCenter
				}
				SvgIcon {
					source: "icons/outline/chevron-down.svg"
					color: root._expanded ? Theme.accentColor : Theme.mutedColor
					iconSize: Theme.fontSizeNormal
					rotation: root._expanded ? 180 : 0

					Behavior on rotation {
						NumberAnimation {
							duration: 150
							easing.type: Easing.OutQuad
						}
					}
				}
			}
			MouseArea {
				id: triggerMouse

				anchors.fill: parent
				hoverEnabled: true
				cursorShape: Qt.PointingHandCursor

				onClicked: {
					root._expanded = !root._expanded;
					if (root._expanded) {
						searchField.text = "";
						filteredModel.model = root.options;
						searchField.forceActiveFocus();
					}
				}
			}
		}
	}

	// Expandable dropdown panel (inline — Wayland overlays make popups painful)
	Rectangle {
		Layout.fillWidth: true
		Layout.preferredHeight: root._expanded ? 200 : 0
		clip: true
		color: Theme.backgroundColor
		radius: Theme.radiusNormal
		border.color: root._expanded ? Qt.alpha(Theme.accentColor, 0.4) : Theme.borderColor
		border.width: 1
		visible: root._expanded

		Behavior on Layout.preferredHeight {
			NumberAnimation {
				duration: 150
				easing.type: Easing.OutQuad
			}
		}
		Behavior on border.color {
			ColorAnimation {
				duration: Theme.hoverDuration
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
				color: Theme.surfaceColor
				border.color: searchField.activeFocus ? Theme.accentColor : Theme.borderColor
				border.width: 1

				Behavior on border.color {
					ColorAnimation {
						duration: Theme.hoverDuration
						easing.type: Easing.OutQuad
					}
				}

				TextInput {
					id: searchField

					anchors.fill: parent
					anchors.leftMargin: 8
					anchors.rightMargin: 8
					verticalAlignment: Text.AlignVCenter
					color: Theme.foregroundColor
					font.pixelSize: Theme.fontSizeNormal
					font.family: Theme.fontFamilyMono
					selectionColor: Qt.alpha(Theme.accentColor, 0.3)
					selectByMouse: true

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
						font.family: Theme.fontFamilyMono
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
					id: optionRow

					required property string modelData

					width: filteredModel.width
					height: 26
					radius: Theme.radiusSmall
					color: rowMouse.containsMouse ? Theme.hoverAccentColor : (root.currentValue === optionRow.modelData ? Qt.alpha(Theme.accentColor, 0.08) : "transparent")

					Behavior on color {
						ColorAnimation {
							duration: Theme.hoverDuration
							easing.type: Easing.OutQuad
						}
					}

					RowLayout {
						anchors.fill: parent
						anchors.leftMargin: 10
						anchors.rightMargin: 8
						spacing: 6

						Text {
							Layout.fillWidth: true
							text: optionRow.modelData
							color: root.currentValue === optionRow.modelData ? Theme.accentColor : Theme.foregroundColor
							font.pixelSize: Theme.fontSizeNormal
							font.bold: root.currentValue === optionRow.modelData
							elide: Text.ElideRight
							verticalAlignment: Text.AlignVCenter
						}
						// Checkmark on the selected option
						SvgIcon {
							source: "icons/outline/check.svg"
							color: Theme.accentColor
							iconSize: Theme.fontSizeSmall
							visible: root.currentValue === optionRow.modelData
						}
					}
					MouseArea {
						id: rowMouse

						anchors.fill: parent
						hoverEnabled: true
						cursorShape: Qt.PointingHandCursor

						onClicked: {
							root.valueChanged(optionRow.modelData);
							root._expanded = false;
						}
					}
				}
			}
		}
	}
}
