pragma ComponentBehavior: Bound

import QtQuick
import "../../../components/bar"
import "../../../config"
import "../../../services/system"

BaseWidget {
	id: widget

	readonly property string _ramFormat: ShellConfig.systemMonitorRamFormat()
	readonly property string _ramAbsolute: SystemMonitor.useGB ? SystemMonitor.ramUsedGB.toFixed(1) + "/" + SystemMonitor.ramTotalGB.toFixed(1) + " GB" : SystemMonitor.ramUsedMB + "/" + SystemMonitor.ramTotalMB + " MB"
	readonly property string _ramUsed: SystemMonitor.useGB ? SystemMonitor.ramUsedGB.toFixed(1) + " GB" : SystemMonitor.ramUsedMB + " MB"
	readonly property string _ramText: {
		if (_ramFormat === "used/total")
			return _ramAbsolute;
		if (_ramFormat === "used")
			return _ramUsed;
		return Math.round(SystemMonitor.ramUsage * 100) + "%";
	}
	property Component widgetTooltip: Component {
		Text {
			text: "CPU: " + Math.round(SystemMonitor.cpuUsage * 100) + "%\n" + "RAM: " + widget._ramAbsolute + " (" + Math.round(SystemMonitor.ramUsage * 100) + "%)\n" + "Temp: " + SystemMonitor.temperature + "°C"
			font.pixelSize: Theme.fontSizeSmall
			color: Theme.foregroundColor
		}
	}

	tooltipComponent: widgetTooltip
	implicitWidth: row.implicitWidth
	implicitHeight: row.implicitHeight

	Row {
		id: row

		spacing: Theme.spacingNormal

		// CPU
		Text {
			text: "CPU " + Math.round(SystemMonitor.cpuUsage * 100) + "%"
			color: SystemMonitor.cpuUsage > 0.8 ? Theme.errorColor : Theme.foregroundColor
			font.pixelSize: Theme.fontSizeSmall
			font.family: Theme.fontFamilyMono
		}

		// RAM
		Text {
			text: "RAM " + widget._ramText
			color: SystemMonitor.ramUsage > 0.9 ? Theme.errorColor : Theme.foregroundColor
			font.pixelSize: Theme.fontSizeSmall
			font.family: Theme.fontFamilyMono
		}

		// Temperature
		Text {
			visible: SystemMonitor.temperature > 0
			text: SystemMonitor.temperature + "°C"
			color: SystemMonitor.temperature > 80 ? Theme.errorColor : Theme.foregroundColor
			font.pixelSize: Theme.fontSizeSmall
			font.family: Theme.fontFamilyMono
		}
	}
}
