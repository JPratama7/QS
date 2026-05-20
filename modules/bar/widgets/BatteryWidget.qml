pragma ComponentBehavior: Bound

import QtQuick
import "../../../components/bar"
import "../../../config"
import "../../../services/system"

BaseWidget {
	id: widget

	readonly property color _textColor: {
		if (Power.charging)
			return "#3b82f6";
		if (Power.percent < 20)
			return "#ef4444";
		return Theme.foregroundColor;
	}

	function formatTime(seconds: int): string {
		const hours = Math.floor(seconds / 3600);
		const mins = Math.floor((seconds % 3600) / 60);
		if (hours > 0)
			return hours + "h " + mins + "m";
		return mins + "m";
	}

	visible: Power.present
	implicitWidth: row.implicitWidth
	implicitHeight: row.implicitHeight

	tooltipComponent: Component {
		Column {
			spacing: 4

			Text {
				text: !Power.present ? "On AC Power" : (Power.charging ? "Charging: " + Power.percent + "%" : "Battery: " + Power.percent + "%")
				font.pixelSize: Theme.fontSizeSmall
				color: Theme.foregroundColor
			}
			Text {
				visible: Power.present && Power.health > 0
				text: "Health: " + Power.health + "%"
				font.pixelSize: Theme.fontSizeSmall
				color: Theme.foregroundColor
			}
			Text {
				visible: Power.present && Power.charging && Power.timeToFull > 0
				text: "Time to full: " + widget.formatTime(Power.timeToFull)
				font.pixelSize: Theme.fontSizeSmall
				color: Theme.foregroundColor
			}
			Text {
				visible: Power.present && !Power.charging && Power.timeToEmpty > 0
				text: "Time remaining: " + widget.formatTime(Power.timeToEmpty)
				font.pixelSize: Theme.fontSizeSmall
				color: Theme.foregroundColor
			}
			Text {
				visible: Power.present && Power.changeRate > 0
				text: (Power.charging ? "Charge rate: " : "Discharge rate: ") + Power.changeRate.toFixed(1) + " W"
				font.pixelSize: Theme.fontSizeSmall
				color: Theme.foregroundColor
			}
		}
	}

	Row {
		id: row

		spacing: 3

		Text {
			id: iconItem

			// 🔌 when charging, 🔋 when on battery
			text: Power.charging ? "🔌" : "🔋"
			font.pixelSize: Theme.fontSizeSmall
			font.family: Theme.fontFamily
			color: widget._textColor
			height: textItem.height
			verticalAlignment: Text.AlignVCenter
		}
		Text {
			id: textItem

			text: Power.percent + "%"
			color: widget._textColor
			font.pixelSize: Theme.fontSizeSmall
			font.family: Theme.fontFamily
			verticalAlignment: Text.AlignVCenter
		}
	}
}
