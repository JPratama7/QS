pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../config"
import "../../services/ui"

Rectangle {
	id: root

	function reset(): void {
		// Nothing to reset yet
	}

	color: Theme.backgroundColor
	radius: Theme.radiusLarge
	border.color: Theme.surfaceColor
	border.width: 1
	implicitHeight: Math.min(contentLayout.implicitHeight + 40, parent ? parent.height - 100 : 800)

	MouseArea {
		anchors.fill: parent

		onClicked: mouse => mouse.accepted = true
	}
	Item {
		anchors.fill: parent
		focus: true

		Keys.onEscapePressed: ShellUI.closeSettings()
	}
	ScrollView {
		contentWidth: availableWidth
		clip: true
		ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
		ScrollBar.vertical.policy: ScrollBar.AsNeeded

		anchors {
			fill: parent
			margins: 20
		}
		ColumnLayout {
			id: contentLayout

			width: parent.width
			spacing: 30

			Text {
				text: "Settings"
				color: Theme.foregroundColor
				font.pixelSize: Theme.fontSizeLarge
				font.bold: true
				Layout.alignment: Qt.AlignHCenter
			}
			SettingSection {
				title: "General"

				SettingToggle {
					text: "Do Not Disturb"
					checked: PersistentConfig.adapter.dndEnabled

					onToggled: {
						PersistentConfig.adapter.dndEnabled = !PersistentConfig.adapter.dndEnabled;
					}
				}
			}
			SettingSection {
				title: "Bar"

				SettingSelect {
					text: "Bar Edge"
					currentValue: PersistentConfig.adapter.barEdge
					options: ["top", "bottom"]

					onValueChanged: val => {
						PersistentConfig.adapter.barEdge = val;
					}
				}
				SettingSelect {
					text: "Bar Display Mode"
					currentValue: PersistentConfig.adapter.barDisplayMode
					options: ["visible", "auto_hide"]

					onValueChanged: val => {
						PersistentConfig.adapter.barDisplayMode = val;
					}
				}
				SettingNumber {
					text: "Bar Height"
					currentValue: PersistentConfig.adapter.barHeight
					minValue: 20
					maxValue: 80
					step: 2

					onValueChanged: val => {
						PersistentConfig.adapter.barHeight = val;
					}
				}
			}
			SettingSection {
				title: "Bar Tooltip"

				SettingToggle {
					text: "Enable Tooltips"
					checked: (PersistentConfig.adapter.bar && PersistentConfig.adapter.bar.tooltip && PersistentConfig.adapter.bar.tooltip.enabled) !== false

					onToggled: {
						const newBar = JSON.parse(JSON.stringify(PersistentConfig.adapter.bar || {}));
						if (!newBar.tooltip)
							newBar.tooltip = {};
						newBar.tooltip.enabled = !(newBar.tooltip.enabled !== false);
						PersistentConfig.adapter.bar = newBar;
					}
				}
				SettingNumber {
					text: "Tooltip Delay (ms)"
					currentValue: (PersistentConfig.adapter.bar && PersistentConfig.adapter.bar.tooltip && PersistentConfig.adapter.bar.tooltip.delayMs) !== undefined ? PersistentConfig.adapter.bar.tooltip.delayMs : 300
					minValue: 0
					maxValue: 2000
					step: 50

					onValueChanged: val => {
						const newBar = JSON.parse(JSON.stringify(PersistentConfig.adapter.bar || {}));
						if (!newBar.tooltip)
							newBar.tooltip = {};
						newBar.tooltip.delayMs = val;
						PersistentConfig.adapter.bar = newBar;
					}
				}
			}
			SettingSection {
				title: "Bar Widgets"

				SettingToggle {
					text: "Show Workspaces Text"
					checked: (PersistentConfig.adapter.bar && PersistentConfig.adapter.bar.widgets && PersistentConfig.adapter.bar.widgets.workspaces && PersistentConfig.adapter.bar.widgets.workspaces.showText) !== false

					onToggled: {
						const newBar = JSON.parse(JSON.stringify(PersistentConfig.adapter.bar || {}));
						if (!newBar.widgets)
							newBar.widgets = {};
						if (!newBar.widgets.workspaces)
							newBar.widgets.workspaces = {};
						newBar.widgets.workspaces.showText = !(newBar.widgets.workspaces.showText !== false);
						PersistentConfig.adapter.bar = newBar;
					}
				}
				SettingSelect {
					text: "System Monitor RAM Format"
					currentValue: (PersistentConfig.adapter.bar && PersistentConfig.adapter.bar.widgets && PersistentConfig.adapter.bar.widgets.systemMonitor && PersistentConfig.adapter.bar.widgets.systemMonitor.ramFormat) || "percent"
					options: ["percent", "used", "used/total"]

					onValueChanged: val => {
						const newBar = JSON.parse(JSON.stringify(PersistentConfig.adapter.bar || {}));
						if (!newBar.widgets)
							newBar.widgets = {};
						if (!newBar.widgets.systemMonitor)
							newBar.widgets.systemMonitor = {};
						newBar.widgets.systemMonitor.ramFormat = val;
						PersistentConfig.adapter.bar = newBar;
					}
				}
				SettingNumber {
					text: "Active Window Max Text Width"
					currentValue: (PersistentConfig.adapter.bar && PersistentConfig.adapter.bar.widgets && PersistentConfig.adapter.bar.widgets.activeWindow && PersistentConfig.adapter.bar.widgets.activeWindow.maxTextWidth) !== undefined ? PersistentConfig.adapter.bar.widgets.activeWindow.maxTextWidth : 200
					minValue: 50
					maxValue: 800
					step: 10

					onValueChanged: val => {
						const newBar = JSON.parse(JSON.stringify(PersistentConfig.adapter.bar || {}));
						if (!newBar.widgets)
							newBar.widgets = {};
						if (!newBar.widgets.activeWindow)
							newBar.widgets.activeWindow = {};
						newBar.widgets.activeWindow.maxTextWidth = val;
						PersistentConfig.adapter.bar = newBar;
					}
				}
			}
		}
	}
}
