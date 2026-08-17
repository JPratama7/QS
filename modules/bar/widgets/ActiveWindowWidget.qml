pragma ComponentBehavior: Bound

import QtQuick

import Quickshell.Widgets
import "../../../components/bar"
import "../../../config"
import "../../../services/compositor"
import "../../../services/system"

BaseWidget {
	id: widget

	required property string screenName
	property var activeWindow: null
	readonly property string windowTitle: activeWindow ? activeWindow.title : ""
	property int maxTextWidth: 200

	function applyActiveWindowConfig(): void {
		const widgetsConfig = ShellConfig.barWidgetsConfig();
		const activeWindowConfig = widgetsConfig.activeWindow || {};
		const configuredMaxTextWidth = activeWindowConfig.maxTextWidth;

		maxTextWidth = (typeof configuredMaxTextWidth === "number" && configuredMaxTextWidth > 0) ? configuredMaxTextWidth : Defaults.bar.widgets.activeWindow.maxTextWidth;
	}

	implicitWidth: row.implicitWidth
	implicitHeight: row.implicitHeight

	tooltipComponent: Component {
		Text {
			text: widget.windowTitle || "No active window"
			font.pixelSize: Theme.fontSizeSmall
			color: Theme.foregroundColor
		}
	}

	Component.onCompleted: applyActiveWindowConfig()

	Connections {
		function onActiveToplevelChanged(data: var) {
			widget.activeWindow = data;
		}

		target: Compositor
	}
	Connections {
		function onBarChanged(): void {
			widget.applyActiveWindowConfig();
		}

		target: ShellConfig
	}
	Row {
		id: row

		spacing: Theme.spacingSmall
		visible: widget.activeWindow !== null

		Image {
			width: ShellConfig.barIconSize
			height: ShellConfig.barIconSize
			fillMode: Image.PreserveAspectFit
			sourceSize.width: ShellConfig.barIconSize
			sourceSize.height: ShellConfig.barIconSize
			source: AppIcons.iconForAppId(widget.activeWindow?.appId ?? "")
		}
		Text {
			id: text

			text: widget.windowTitle || "No active window"
			font.pixelSize: Theme.fontSizeSmall
			color: Theme.foregroundColor
			elide: Text.ElideRight
			width: widget.maxTextWidth
		}
	}
}
