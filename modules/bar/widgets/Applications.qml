pragma ComponentBehavior: Bound

import QtQuick
import Quickshell.Wayland
import Quickshell.Widgets
import "../../../config"
import "../../../services/system"
import "../../../components/bar"

BaseWidget {
    id: widget

    implicitWidth: row.implicitWidth
    implicitHeight: row.implicitHeight

    Row {
        id: row
        spacing: Theme.spacingSmall

        Repeater {
            model: ToplevelManager.toplevels
            delegate: BaseWidget {
                id: appItem
                required property Toplevel modelData

                implicitWidth: Theme.iconSizeSmall + Theme.paddingSmall * 2
                implicitHeight: Theme.iconSizeSmall + Theme.paddingSmall * 2

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
                    color: appItem.modelData?.activated ? Qt.alpha(Theme.accentColor, 0.3) : "transparent"

                    IconImage {
                        id: icon
                        anchors.centerIn: parent
                        width: Theme.iconSizeSmall
                        height: Theme.iconSizeSmall
                        source: AppIcons.iconForAppId(appItem.modelData.appId ?? "")

                        Connections {
                            target: appItem.modelData
                            function onAppIdChanged() {
                                icon.source = AppIcons.iconForAppId(appItem.modelData.appId ?? "")
                            }
                        }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (appItem.modelData) {
                            appItem.modelData.activate()
                        }
                    }
                }
            }
        }
    }
}
