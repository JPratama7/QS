pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import ".."
import "../../../config"

SettingRow {
	id: root

	property bool checked: false

	signal toggled

	// Row accepts keyboard focus so Space/Enter can flip the toggle.
	focus: true

	Keys.onSpacePressed: event => {
		root.toggled();
		event.accepted = true;
	}
	Keys.onReturnPressed: event => {
		root.toggled();
		event.accepted = true;
	}

	// Modern switch track
	Rectangle {
		id: track

		Layout.alignment: Qt.AlignRight
		Layout.preferredWidth: 44
		Layout.preferredHeight: 24
		radius: 12
		// Off: neutral surface. On: accent fill. Hover and focus lift the border.
		color: root.checked ? Theme.accentColor : Theme.surfaceColor
		border.color: root.activeFocus ? Theme.accentColor : (trackMouse.containsMouse ? Qt.alpha(Theme.foregroundColor, 0.25) : Theme.borderColor)
		border.width: 1

		Behavior on color {
			ColorAnimation {
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

		// Thumb
		Rectangle {
			id: thumb

			width: 16
			height: 16
			radius: 8
			// Off: muted knob. On: bright knob against the accent fill.
			color: root.checked ? Theme.foregroundColor : Theme.mutedColor
			y: (parent.height - height) / 2
			x: root.checked ? parent.width - width - 4 : 4
			scale: trackMouse.pressed ? 0.85 : 1.0

			Behavior on color {
				ColorAnimation {
					duration: 150
					easing.type: Easing.OutQuad
				}
			}
			Behavior on x {
				NumberAnimation {
					duration: 150
					easing.type: Easing.OutQuad
				}
			}
			Behavior on scale {
				NumberAnimation {
					duration: 90
					easing.type: Easing.OutQuad
				}
			}
		}

		MouseArea {
			id: trackMouse

			anchors.fill: parent
			hoverEnabled: true
			cursorShape: Qt.PointingHandCursor

			onClicked: {
				root.forceActiveFocus();
				root.toggled();
			}
		}
	}
}
