pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import "../../config"
import "../../services/ui"
import "widgets"

Item {
	id: barLayout

	required property string screenName
	required property PanelWindow barWindow
	readonly property real widgetScale: ShellConfig.widgetScaleForScreen(screenName)
	readonly property real spacing: Theme.spacingLarge

	function showTooltip(widgetItem: Item): void {
		// qmllint disable missing-property
		if (widgetItem && widgetItem.tooltipComponent) {
			Tooltip.show(widgetItem, widgetItem.tooltipComponent, barLayout.screenName, barLayout.barWindow);
		}
	}
	function hideTooltip(): void {
		Tooltip.hide();
	}
	function widgetComponentForId(id: string): Component {
		switch (id) {
		case "launcher":
			return launcherComp;
		case "workspaces":
			return workspacesComp;
		case "activeWindow":
			return activeWindowComp;
		case "clock":
			return clockComp;
		case "network":
			return networkComp;
		case "volume":
			return volumeComp;
		case "battery":
			return batteryComp;
		case "notifications":
			return notificationsComp;
		case "tray":
			return trayComp;
		case "session":
			return sessionComp;
		case "settings":
			return settingsComp;
		case "idleInhibitor":
			return idleInhibitorComp;
		case "taskbar":
			return taskbar;
		case "systemMonitor":
			return systemMonitorComp;
		case "vpn":
			return vpnComp;
		}
		return null;
	}
	function widgetLayoutForZone(zone: string): var {
		const layout = ShellConfig.barWidgetLayoutForScreen(barLayout.screenName);
		return layout[zone] || [];
	}

	anchors.fill: parent
	anchors.leftMargin: Theme.paddingNormal
	anchors.rightMargin: Theme.paddingNormal

	// Widget components - shared, no Loader inside
	Component {
		id: launcherComp

		LauncherButton {
			screenName: barLayout.screenName
			widgetScale: barLayout.widgetScale
		}
	}
	Component {
		id: taskbar

		Applications {
		}
	}
	Component {
		id: workspacesComp

		WorkspacesWidget {
			screenName: barLayout.screenName
			widgetScale: barLayout.widgetScale
		}
	}
	Component {
		id: activeWindowComp

		ActiveWindowWidget {
			screenName: barLayout.screenName
			widgetScale: barLayout.widgetScale
		}
	}
	Component {
		id: clockComp

		ClockWidget {
			screenName: barLayout.screenName
			barWindow: barLayout.barWindow
			widgetScale: barLayout.widgetScale
		}
	}
	Component {
		id: networkComp

		NetworkWidget {
			screenName: barLayout.screenName
			barWindow: barLayout.barWindow
			widgetScale: barLayout.widgetScale
		}
	}
	Component {
		id: volumeComp

		VolumeWidget {
			widgetScale: barLayout.widgetScale
		}
	}
	Component {
		id: batteryComp

		BatteryWidget {
			widgetScale: barLayout.widgetScale
		}
	}
	Component {
		id: notificationsComp

		NotificationIndicatorWidget {
			screenName: barLayout.screenName
			barWindow: barLayout.barWindow
			widgetScale: barLayout.widgetScale
		}
	}
	Component {
		id: trayComp

		TrayWidget {
			screenName: barLayout.screenName
			barWindow: barLayout.barWindow
			widgetScale: barLayout.widgetScale
		}
	}
	Component {
		id: sessionComp

		SessionMenuButton {
			screenName: barLayout.screenName
			barWindow: barLayout.barWindow
			widgetScale: barLayout.widgetScale
		}
	}
	Component {
		id: settingsComp

		SettingsWidget {
			screenName: barLayout.screenName
			widgetScale: barLayout.widgetScale
		}
	}
	Component {
		id: idleInhibitorComp

		IdleInhibitorWidget {
			widgetScale: barLayout.widgetScale
		}
	}
	Component {
		id: systemMonitorComp

		SystemMonitorWidget {
			widgetScale: barLayout.widgetScale
		}
	}
	Component {
		id: vpnComp

		VpnWidget {
			screenName: barLayout.screenName
			barWindow: barLayout.barWindow
			widgetScale: barLayout.widgetScale
		}
	}

	// Left zone
	Row {
		id: leftZone

		height: parent.height
		anchors.left: parent.left
		anchors.verticalCenter: parent.verticalCenter
		spacing: barLayout.spacing

		Repeater {
			model: barLayout.widgetLayoutForZone("left")

			Item {
				required property string modelData

				width: leftWidgetLoader.implicitWidth
				height: parent.height
				anchors.verticalCenter: parent.verticalCenter

				Loader {
					id: leftWidgetLoader

					asynchronous: true
					sourceComponent: barLayout.widgetComponentForId(parent.modelData)
					anchors.verticalCenter: parent.verticalCenter
				}
				HoverHandler {
					id: leftHoverHandler

					onHoveredChanged: {
						if (hovered && leftWidgetLoader.item)
							barLayout.showTooltip(leftWidgetLoader.item);
						else
							barLayout.hideTooltip();
					}
				}
			}
		}
	}

	// Center zone
	Row {
		id: centerZone

		height: parent.height
		anchors.horizontalCenter: parent.horizontalCenter
		anchors.verticalCenter: parent.verticalCenter
		spacing: barLayout.spacing

		Repeater {
			model: barLayout.widgetLayoutForZone("center")

			Item {
				required property string modelData

				width: centerWidgetLoader.implicitWidth
				height: parent.height
				anchors.verticalCenter: parent.verticalCenter

				Loader {
					id: centerWidgetLoader

					asynchronous: true
					sourceComponent: barLayout.widgetComponentForId(parent.modelData)
					anchors.verticalCenter: parent.verticalCenter
				}
				HoverHandler {
					id: centerHoverHandler

					onHoveredChanged: {
						if (hovered && centerWidgetLoader.item)
							barLayout.showTooltip(centerWidgetLoader.item);
						else
							barLayout.hideTooltip();
					}
				}
			}
		}
	}

	// Right zone
	Row {
		id: rightZone

		height: parent.height
		anchors.right: parent.right
		anchors.verticalCenter: parent.verticalCenter
		spacing: barLayout.spacing

		Repeater {
			model: barLayout.widgetLayoutForZone("right")

			Item {
				required property string modelData

				width: rightWidgetLoader.implicitWidth
				height: parent.height
				anchors.verticalCenter: parent.verticalCenter

				Loader {
					id: rightWidgetLoader

					asynchronous: true
					sourceComponent: barLayout.widgetComponentForId(parent.modelData)
					anchors.verticalCenter: parent.verticalCenter
				}
				HoverHandler {
					id: rightHoverHandler

					onHoveredChanged: {
						if (hovered && rightWidgetLoader.item)
							barLayout.showTooltip(rightWidgetLoader.item);
						else
							barLayout.hideTooltip();
					}
				}
			}
		}
	}
}
