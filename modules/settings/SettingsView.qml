pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../config"
import "../../services/system"
import "../../services/ui"

Rectangle {
	id: root

	property string currentSection: "general"

	function reset(): void {
		root.currentSection = "general";
	}

	color: Theme.backgroundColor
	radius: Theme.radiusLarge
	border.color: Theme.surfaceColor
	border.width: 1
	implicitHeight: 500

	MouseArea {
		anchors.fill: parent

		onClicked: mouse => mouse.accepted = true
	}
	Item {
		anchors.fill: parent
		focus: true

		Keys.onEscapePressed: ShellUI.closeSettings()
	}

	// Main layout with sidebar on left
	RowLayout {
		anchors.fill: parent
		anchors.margins: 1
		spacing: 0

		// Sidebar
		Rectangle {
			Layout.preferredWidth: 150
			Layout.fillHeight: true
			color: Theme.surfaceColor
			radius: Theme.radiusLarge - 1

			ColumnLayout {
				anchors.fill: parent
				anchors.margins: 15
				spacing: 5

				Text {
					text: "Settings"
					color: Theme.foregroundColor
					font.pixelSize: Theme.fontSizeLarge
					font.bold: true
					Layout.alignment: Qt.AlignHCenter
					Layout.bottomMargin: 15
				}

				// Sidebar items
				Repeater {
					model: [
						{
							id: "general",
							label: "General"
						},
						{
							id: "bar",
							label: "Bar"
						}
					]

					delegate: Rectangle {
						id: sectionItem

						required property var modelData

						Layout.fillWidth: true
						Layout.preferredHeight: 35
						radius: Theme.radiusSmall
						color: root.currentSection === sectionItem.modelData.id ? Qt.alpha(Theme.accentColor, 0.2) : "transparent"

						Text {
							anchors.left: parent.left
							anchors.verticalCenter: parent.verticalCenter
							anchors.leftMargin: 10
							text: sectionItem.modelData.label
							color: root.currentSection === sectionItem.modelData.id ? Theme.accentColor : Theme.foregroundColor
							font.pixelSize: Theme.fontSizeNormal
							font.bold: root.currentSection === sectionItem.modelData.id
						}
						MouseArea {
							anchors.fill: parent

							onClicked: root.currentSection = sectionItem.modelData.id
						}
					}
				}
				Item {
					Layout.fillHeight: true
				}
			}
		}

		// Content area
		Rectangle {
			Layout.fillWidth: true
			Layout.fillHeight: true
			color: Theme.backgroundColor
			radius: Theme.radiusLarge - 1

			ScrollView {
				anchors.fill: parent
				anchors.margins: 20
				contentWidth: availableWidth
				clip: true
				ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
				ScrollBar.vertical.policy: ScrollBar.AsNeeded

				ColumnLayout {
					id: contentLayout

					width: parent.width
					spacing: 20

					// Section title
					Text {
						text: root.currentSection === "general" ? "General" : "Bar"
						color: Theme.accentColor
						font.pixelSize: Theme.fontSizeLarge
						font.bold: true
					}
					Rectangle {
						Layout.fillWidth: true
						Layout.preferredHeight: 1
						color: Theme.surfaceColor
					}

					// General section
					ColumnLayout {
						visible: root.currentSection === "general"
						Layout.fillWidth: true
						spacing: 15

						SettingToggle {
							text: "Do Not Disturb"
							checked: PersistentConfig.adapterView.dndEnabled

							onToggled: {
								PersistentConfig.adapterView.dndEnabled = !PersistentConfig.adapterView.dndEnabled;
							}
						}
						SettingDropdown {
							text: "Time Zone"
							currentValue: PersistentConfig.adapterView.timeZone
							options: TimeZone.allTimezones

							onValueChanged: val => {
								TimeZone.setSystemTimezone(val);
							}
						}
						Connections {
							function onTimezoneSetSuccess(timeZone) {
								PersistentConfig.adapterView.timeZone = timeZone;
							}
							function onTimezoneSetFailed(timeZone, error) {
								console.error("Settings: failed to set timezone:", error);
							}

							target: TimeZone
						}
					}

					// Bar section
					ColumnLayout {
						visible: root.currentSection === "bar"
						Layout.fillWidth: true
						spacing: 20

						// General bar settings
						ColumnLayout {
							Layout.fillWidth: true
							spacing: 15

							SettingSelect {
								text: "Bar Edge"
								currentValue: PersistentConfig.adapterView.barEdge
								options: ["top", "bottom"]

								onValueChanged: val => {
									PersistentConfig.adapterView.barEdge = val;
								}
							}
							SettingSelect {
								text: "Bar Display Mode"
								currentValue: PersistentConfig.adapterView.barDisplayMode
								options: ["visible", "auto_hide"]

								onValueChanged: val => {
									PersistentConfig.adapterView.barDisplayMode = val;
								}
							}
							SettingNumber {
								text: "Bar Height"
								currentValue: PersistentConfig.adapterView.barHeight
								minValue: 20
								maxValue: 80
								step: 2

								onValueChanged: val => {
									PersistentConfig.adapterView.barHeight = val;
								}
							}
						}

						// Sub-section: Tooltip
						Text {
							text: "Tooltip"
							color: Theme.foregroundColor
							font.pixelSize: Theme.fontSizeNormal
							font.bold: true
						}
						Rectangle {
							Layout.fillWidth: true
							Layout.preferredHeight: 1
							color: Theme.surfaceColor
						}
						ColumnLayout {
							Layout.fillWidth: true
							spacing: 15

							SettingToggle {
								text: "Enable Tooltips"
								checked: (PersistentConfig.adapterView.bar && PersistentConfig.adapterView.bar.tooltip && PersistentConfig.adapterView.bar.tooltip.enabled) !== false

								onToggled: {
									const newBar = JSON.parse(JSON.stringify(PersistentConfig.adapterView.bar || {}));
									if (!newBar.tooltip)
										newBar.tooltip = {};
									newBar.tooltip.enabled = !(newBar.tooltip.enabled !== false);
									PersistentConfig.adapterView.bar = newBar;
								}
							}
							SettingNumber {
								text: "Tooltip Delay (ms)"
								currentValue: (PersistentConfig.adapterView.bar && PersistentConfig.adapterView.bar.tooltip && PersistentConfig.adapterView.bar.tooltip.delayMs) !== undefined ? PersistentConfig.adapterView.bar.tooltip.delayMs : 300
								minValue: 0
								maxValue: 2000
								step: 50

								onValueChanged: val => {
									const newBar = JSON.parse(JSON.stringify(PersistentConfig.adapterView.bar || {}));
									if (!newBar.tooltip)
										newBar.tooltip = {};
									newBar.tooltip.delayMs = val;
									PersistentConfig.adapterView.bar = newBar;
								}
							}
						}

						// Sub-section: Widgets
						Text {
							text: "Widgets"
							color: Theme.foregroundColor
							font.pixelSize: Theme.fontSizeNormal
							font.bold: true
							Layout.topMargin: 10
						}
						Rectangle {
							Layout.fillWidth: true
							Layout.preferredHeight: 1
							color: Theme.surfaceColor
						}
						ColumnLayout {
							Layout.fillWidth: true
							spacing: 15

							SettingToggle {
								text: "Show Workspaces Text"
								checked: (PersistentConfig.adapterView.bar && PersistentConfig.adapterView.bar.widgets && PersistentConfig.adapterView.bar.widgets.workspaces && PersistentConfig.adapterView.bar.widgets.workspaces.showText) !== false

								onToggled: {
									const newBar = JSON.parse(JSON.stringify(PersistentConfig.adapterView.bar || {}));
									if (!newBar.widgets)
										newBar.widgets = {};
									if (!newBar.widgets.workspaces)
										newBar.widgets.workspaces = {};
									newBar.widgets.workspaces.showText = !(newBar.widgets.workspaces.showText !== false);
									PersistentConfig.adapterView.bar = newBar;
								}
							}
							SettingSelect {
								text: "System Monitor RAM Format"
								currentValue: (PersistentConfig.adapterView.bar && PersistentConfig.adapterView.bar.widgets && PersistentConfig.adapterView.bar.widgets.systemMonitor && PersistentConfig.adapterView.bar.widgets.systemMonitor.ramFormat) || "percent"
								options: ["percent", "used", "used/total"]

								onValueChanged: val => {
									const newBar = JSON.parse(JSON.stringify(PersistentConfig.adapterView.bar || {}));
									if (!newBar.widgets)
										newBar.widgets = {};
									if (!newBar.widgets.systemMonitor)
										newBar.widgets.systemMonitor = {};
									newBar.widgets.systemMonitor.ramFormat = val;
									PersistentConfig.adapterView.bar = newBar;
								}
							}
							SettingNumber {
								text: "Active Window Max Text Width"
								currentValue: (PersistentConfig.adapterView.bar && PersistentConfig.adapterView.bar.widgets && PersistentConfig.adapterView.bar.widgets.activeWindow && PersistentConfig.adapterView.bar.widgets.activeWindow.maxTextWidth) !== undefined ? PersistentConfig.adapterView.bar.widgets.activeWindow.maxTextWidth : 200
								minValue: 50
								maxValue: 800
								step: 10

								onValueChanged: val => {
									const newBar = JSON.parse(JSON.stringify(PersistentConfig.adapterView.bar || {}));
									if (!newBar.widgets)
										newBar.widgets = {};
									if (!newBar.widgets.activeWindow)
										newBar.widgets.activeWindow = {};
									newBar.widgets.activeWindow.maxTextWidth = val;
									PersistentConfig.adapterView.bar = newBar;
								}
							}
						}
					}
				}
			}
		}
	}
}
