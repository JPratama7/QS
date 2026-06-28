pragma ComponentBehavior: Bound

import QtQuick
import "../../../components/bar"
import "../../../components"
import "../../../config"
import "../../../services/system"

BaseWidget {
	id: widget

	readonly property string _displayMode: {
		const widgets = (ShellConfig.bar || {}).widgets || {};
		const mode = widgets.battery ? widgets.battery.displayMode : undefined;
		return (mode === "text" || mode === "icon" || mode === "both") ? mode : "both";
	}
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

		spacing: 5
		anchors.verticalCenter: parent.verticalCenter

		Text {
			id: textItem

			visible: widget._displayMode === "text" || widget._displayMode === "both"
			text: Power.percent + "%"
			color: widget._textColor
			font.pixelSize: Theme.fontSizeSmall
			font.family: Theme.fontFamily
			anchors.verticalCenter: parent.verticalCenter
		}
		SvgIcon {
			id: iconItem

			visible: widget._displayMode === "icon" || widget._displayMode === "both"
			source: {
				if (Power.charging)
					return "icons/battery-charge-minimalistic-svgrepo-com.svg";
				if (Power.percent < 20)
					return "icons/battery-low-minimalistic-svgrepo-com.svg";
				if (Power.percent < 60)
					return "icons/battery-half-minimalistic-svgrepo-com.svg";
				return "icons/battery-full-minimalistic-svgrepo-com.svg";
			}
			color: widget._textColor
			iconSize: Theme.iconSizeSmall
			anchors.verticalCenter: parent.verticalCenter
		}
	}
}
