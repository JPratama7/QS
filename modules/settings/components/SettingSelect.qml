pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import ".."
import "../../../components"
import "../../../config"

SettingRow {
	id: root

	property string currentValue: ""
	property var options: ([]) // Array of string options

	signal valueChanged(string newValue)

	// Row accepts keyboard focus so Left/Right can step through values.
	focus: true

	Keys.onLeftPressed: event => {
		root._step(-1);
		event.accepted = true;
	}
	Keys.onRightPressed: event => {
		root._step(1);
		event.accepted = true;
	}
	Keys.onSpacePressed: event => {
		root._step(1);
		event.accepted = true;
	}

	function _step(direction: int): void {
		if (root.options.length === 0)
			return;
		const currentIndex = root.options.indexOf(root.currentValue);
		const baseIndex = currentIndex < 0 ? 0 : currentIndex;
		// Wrap so both chevrons always work for short enums.
		const nextIndex = (baseIndex + direction + root.options.length) % root.options.length;
		root.valueChanged(root.options[nextIndex]);
	}

	// Stepper pill: [‹] [ value ] [›] — the shape tells you it cycles.
	RowLayout {
		Layout.alignment: Qt.AlignRight
		spacing: 0

		// Previous chevron
		Rectangle {
			id: prevBtn

			Layout.preferredWidth: 28
			Layout.preferredHeight: 28
			radius: Theme.radiusSmall
			color: prevMouse.containsMouse ? Theme.hoverColor : Theme.surfaceColor
			border.color: root.activeFocus ? Qt.alpha(Theme.accentColor, 0.5) : Theme.borderColor
			border.width: 1

			Behavior on color {
				ColorAnimation {
					duration: Theme.hoverDuration
					easing.type: Easing.OutQuad
				}
			}

			SvgIcon {
				anchors.centerIn: parent
				source: "icons/outline/chevron-left.svg"
				color: prevMouse.containsMouse ? Theme.accentColor : Theme.foregroundColor
				iconSize: Theme.fontSizeNormal
			}
			MouseArea {
				id: prevMouse

				anchors.fill: parent
				hoverEnabled: true
				cursorShape: Qt.PointingHandCursor

				onClicked: {
					root.forceActiveFocus();
					root._step(-1);
				}
			}
		}

		// Value display
		Rectangle {
			Layout.preferredWidth: 96
			Layout.preferredHeight: 28
			color: Theme.backgroundColor
			border.color: root.activeFocus ? Qt.alpha(Theme.accentColor, 0.5) : Theme.borderColor
			border.width: 1

			Text {
				anchors.centerIn: parent
				text: root.currentValue
				color: Theme.foregroundColor
				font.pixelSize: Theme.fontSizeNormal
				font.family: Theme.fontFamilyMono
				elide: Text.ElideRight
				width: parent.width - 12
				horizontalAlignment: Text.AlignHCenter
			}
		}

		// Next chevron
		Rectangle {
			id: nextBtn

			Layout.preferredWidth: 28
			Layout.preferredHeight: 28
			radius: Theme.radiusSmall
			color: nextMouse.containsMouse ? Theme.hoverColor : Theme.surfaceColor
			border.color: root.activeFocus ? Qt.alpha(Theme.accentColor, 0.5) : Theme.borderColor
			border.width: 1

			Behavior on color {
				ColorAnimation {
					duration: Theme.hoverDuration
					easing.type: Easing.OutQuad
				}
			}

			SvgIcon {
				anchors.centerIn: parent
				source: "icons/outline/chevron-right.svg"
				color: nextMouse.containsMouse ? Theme.accentColor : Theme.foregroundColor
				iconSize: Theme.fontSizeNormal
			}
			MouseArea {
				id: nextMouse

				anchors.fill: parent
				hoverEnabled: true
				cursorShape: Qt.PointingHandCursor

				onClicked: {
					root.forceActiveFocus();
					root._step(1);
				}
			}
		}
	}
}
