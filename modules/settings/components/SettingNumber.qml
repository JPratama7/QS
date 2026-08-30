pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import ".."
import "../../../config"

SettingRow {
	id: root

	property int currentValue: 0
	property int minValue: 0
	property int maxValue: 1000
	property int step: 1

	signal valueChanged(int newValue)

	// Slider + value chip sit side by side in the right section
	RowLayout {
		Layout.alignment: Qt.AlignRight
		spacing: Theme.spacingNormal

		// Slider is the honest control for a bounded numeric range.
		Slider {
			id: slider

			Layout.preferredWidth: 150
			Layout.preferredHeight: 28
			from: root.minValue
			to: root.maxValue
			stepSize: root.step
			// `value` is set imperatively (a binding would fight the drag).
			Component.onCompleted: value = root.currentValue
			onMoved: root.valueChanged(Math.round(value))

			// Re-sync from external config writes (e.g. defaults reset).
			Connections {
				target: root

				function onCurrentValueChanged(): void {
					slider.value = root.currentValue;
				}
			}

			background: Rectangle {
				x: slider.leftPadding
				y: slider.topPadding + slider.availableHeight / 2 - height / 2
				width: slider.availableWidth
				height: 4
				radius: 2
				color: Theme.surfaceColor

				// Filled portion up to the handle center.
				// Handle travel is inset by its own width so it stays inside the
				// track at both extremes; fill must track the handle center, not
				// the raw visualPosition * track width.
				Rectangle {
					width: slider.visualPosition * (slider.availableWidth - 14) + 7
					height: parent.height
					radius: 2
					color: Theme.accentColor

					Behavior on width {
						NumberAnimation {
							duration: 60
							easing.type: Easing.OutQuad
						}
					}
				}
			}

			handle: Rectangle {
				x: slider.leftPadding + slider.visualPosition * (slider.availableWidth - width)
				y: slider.topPadding + slider.availableHeight / 2 - height / 2
				width: 14
				height: 14
				radius: 7
				color: slider.pressed ? Theme.accentColor : Theme.foregroundColor
				border.color: Theme.accentColor
				border.width: 2
				scale: slider.pressed ? 1.15 : (slider.hovered ? 1.08 : 1.0)

				Behavior on scale {
					NumberAnimation {
						duration: 90
						easing.type: Easing.OutQuad
					}
				}
				Behavior on color {
					ColorAnimation {
						duration: 90
						easing.type: Easing.OutQuad
					}
				}
			}
		}

		// Mono value chip — numbers read as data on a control surface.
		Rectangle {
			Layout.preferredWidth: 52
			Layout.preferredHeight: 28
			radius: Theme.radiusSmall
			color: Theme.backgroundColor
			border.color: Theme.borderColor
			border.width: 1

			Text {
				anchors.centerIn: parent
				text: root.currentValue.toString()
				color: Theme.foregroundColor
				font.pixelSize: Theme.fontSizeNormal
				font.family: Theme.fontFamilyMono
			}
		}
	}
}
