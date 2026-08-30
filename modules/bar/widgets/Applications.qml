pragma ComponentBehavior: Bound

import QtQuick
import Quickshell.Wayland
import Quickshell.Widgets
import "../../../components/bar"
import "../../../config"
import "../../../services/compositor"
import "../../../services/system"

BaseWidget {
	id: widget

	implicitWidth: row.implicitWidth
	implicitHeight: row.implicitHeight

	Row {
		id: row

		spacing: Theme.spacingSmall

		Repeater {
			model: Compositor.toplevels

			delegate: BaseWidget {
				id: appItem

				required property Toplevel modelData

				implicitWidth: ShellConfig.barIconSize + Theme.paddingSmall * 2
				implicitHeight: ShellConfig.barIconSize + Theme.paddingSmall * 2

				tooltipComponent: Component {
					Text {
						text: appItem.modelData.title ?? "Application"
						font.pixelSize: Theme.fontSizeSmall
						color: Theme.foregroundColor
					}
				}

				Rectangle {
					anchors.fill: parent
					radius: Theme.radiusSmall
					color: {
						if (appItem.modelData?.activated)
							return Qt.alpha(Theme.accentColor, 0.3);
						if (appMouseArea.containsMouse)
							return Theme.hoverColor;
						return "transparent";
					}

					Image {
						anchors.centerIn: parent
						width: ShellConfig.barIconSize
						height: ShellConfig.barIconSize
						fillMode: Image.PreserveAspectFit
						sourceSize.width: ShellConfig.barIconSize
						sourceSize.height: ShellConfig.barIconSize
						source: AppIcons.iconForAppId(appItem.modelData?.appId ?? "")
					}
				}
				MouseArea {
					id: appMouseArea
					anchors.fill: parent
					hoverEnabled: true
					cursorShape: Qt.PointingHandCursor
					acceptedButtons: Qt.LeftButton | Qt.RightButton

					onClicked: (mouse) => {
						if (!appItem.modelData) {
							return;
						}
						if (mouse.button === Qt.RightButton) {
							appItem.modelData.close();
						} else {
							appItem.modelData.activate();
						}
					}
				}
			}
		}
	}
}
