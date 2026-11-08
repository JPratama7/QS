pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import "../../../components/bar"
import "../../../components"
import "../../../config"
import "../../../services/system"
import "../../../services/ui"
import "../../popups/controlcenter"

BaseWidget {
	id: widget

	required property string screenName
	required property PanelWindow barWindow

	readonly property string _displayMode: ShellConfig.batteryDisplayMode()
	readonly property color _textColor: {
		if (Power.charging)
			return Theme.accentColor;
		if (Power.percent < 20)
			return Theme.errorColor;
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

		spacing: Theme.spacingSmall
		anchors.verticalCenter: parent.verticalCenter

		Text {
			id: textItem

			visible: widget._displayMode === "text" || widget._displayMode === "both"
			text: Power.percent + "%"
			color: widget._textColor
			font.pixelSize: Theme.fontSizeSmall
			font.family: Theme.fontFamilyMono
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
			iconSize: ShellConfig.barIconSize
			anchors.verticalCenter: parent.verticalCenter
		}
	}

	// Click opens the control center — battery lives in the quick-settings card
	MouseArea {
		anchors.fill: parent
		hoverEnabled: true
		cursorShape: Qt.PointingHandCursor

		onClicked: {
			const pos = widget.mapToItem(null, 0, 0);
			const ccWidth = 360;
			const anchorX = Math.max(0, Math.min(pos.x, widget.barWindow.width - ccWidth - Theme.paddingNormal));
			ShellUI.openPopup(widget.screenName, "controlcenter", controlCenterComponent, anchorX);
		}
	}

	Component {
		id: controlCenterComponent

		ControlCenter {
			screenName: widget.screenName
		}
	}
}
