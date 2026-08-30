pragma ComponentBehavior: Bound

import QtQuick
import "../../../services/compositor"
import "../../../config"
import "../../../components/bar"

BaseWidget {
	id: widget

	required property string screenName

	tooltipComponent: Component {
		Text {
			text: "Workspaces"
			font.pixelSize: Theme.fontSizeSmall
			color: Theme.foregroundColor
		}
	}

	readonly property var workspaces: Compositor.workspacesForScreen(screenName)
	readonly property int activeWorkspaceId: Compositor.activeWorkspaceIdForScreen(screenName)
	property var workspacesConfig: ({})
	property bool showText: Defaults.bar.widgets.workspaces.showText

	// Dot-mode geometry — inactive dots are small, active expands to a pill
	readonly property int dotSize: 5
	readonly property int dotActiveWidth: 20
	readonly property int dotHoverWidth: 10

	function applyWorkspacesConfig(): void {
		const widgetsConfig = ShellConfig.barWidgetsConfig()
		const nextWorkspacesConfig = widgetsConfig.workspaces || {}
		workspacesConfig = nextWorkspacesConfig
		showText = typeof nextWorkspacesConfig.showText === "boolean"
			? nextWorkspacesConfig.showText
			: Defaults.bar.widgets.workspaces.showText
	}

	Component.onCompleted: applyWorkspacesConfig()

	Connections {
		target: ShellConfig
		function onBarChanged(): void {
			widget.applyWorkspacesConfig()
		}
	}

	// Hide if compositor doesn't support workspaces
	visible: workspaces.length > 0

	implicitWidth: visible ? row.implicitWidth : 0
	implicitHeight: visible ? row.implicitHeight : 0

	Row {
		id: row
		spacing: Theme.spacingSmall

		Repeater {
			model: widget.workspaces
			delegate: Item {
				id: wsItem

				required property var modelData

				readonly property bool isActive: modelData.id === widget.activeWorkspaceId
				readonly property bool isHovered: wsMouseArea.containsMouse

				// Dot mode: variable-width pill — dot when inactive, pill when active
				// Text mode: uniform rounded square with color hierarchy
				width: widget.showText ? 22 : (isActive ? widget.dotActiveWidth : (isHovered ? widget.dotHoverWidth : widget.dotSize))
				height: widget.showText ? 22 : widget.dotSize
				anchors.verticalCenter: parent.verticalCenter

				Behavior on width {
					NumberAnimation { duration: Theme.hoverDuration; easing.type: Easing.OutCubic }
				}

				Rectangle {
					anchors.fill: parent
					radius: widget.showText ? Theme.radiusSmall : parent.height / 2
					color: {
						if (widget.showText) {
							if (wsItem.isActive)
								return Theme.accentColor
							if (wsItem.isHovered)
								return Theme.hoverColor
							return Qt.alpha(Theme.surfaceColor, 0.5)
						}
						// Dot mode
						if (wsItem.isActive)
							return Theme.accentColor
						if (wsItem.isHovered)
							return Qt.alpha(Theme.accentColor, 0.4)
						return Qt.alpha(Theme.mutedColor, 0.6)
					}
					Behavior on color {
						ColorAnimation { duration: Theme.hoverDuration }
					}

					Text {
						visible: widget.showText
						anchors.centerIn: parent
						text: wsItem.modelData.id
						font.pixelSize: Theme.fontSizeSmall
						font.family: Theme.fontFamilyMono
						color: wsItem.isActive ? Theme.barBackgroundColor : Theme.mutedColor
					}
				}

				MouseArea {
					id: wsMouseArea
					anchors.fill: parent
					hoverEnabled: true
					cursorShape: Qt.PointingHandCursor
					onClicked: Compositor.switchWorkspace(widget.screenName, wsItem.modelData.id)
				}
			}
		}
	}
}
