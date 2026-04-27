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

    anchors.fill: parent
    anchors.leftMargin: Theme.paddingNormal
    anchors.rightMargin: Theme.paddingNormal

    function showTooltip(widgetItem: Item): void {
        // qmllint disable missing-property
        if (widgetItem && widgetItem.tooltipComponent) {
            Tooltip.show(widgetItem, widgetItem.tooltipComponent, barLayout.screenName, barLayout.barWindow)
        }
    }

    function hideTooltip(): void {
        Tooltip.hide()
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
        case "idleInhibitor":
            return idleInhibitorComp;
        }
        return null;
    }

    function widgetLayoutForZone(zone: string): var {
        const layout = ShellConfig.barWidgetLayoutForScreen(barLayout.screenName);
        return layout[zone] || [];
    }

    // Widget components - shared, no Loader inside
    Component {
        id: launcherComp
        LauncherButton {
            screenName: barLayout.screenName
        }
    }
    Component {
        id: workspacesComp
        WorkspacesWidget {
            screenName: barLayout.screenName
        }
    }
    Component {
        id: activeWindowComp
        ActiveWindowWidget {
            screenName: barLayout.screenName
        }
    }
    Component {
        id: clockComp
        ClockWidget {}
    }
    Component {
        id: networkComp
        NetworkWidget {}
    }
    Component {
        id: volumeComp
        VolumeWidget {}
    }
    Component {
        id: batteryComp
        BatteryWidget {}
    }
    Component {
        id: notificationsComp
        NotificationIndicatorWidget {}
    }
    Component {
        id: trayComp
        TrayWidget {
            screenName: barLayout.screenName
            barWindow: barLayout.barWindow
        }
    }
    Component {
        id: sessionComp
        SessionMenuButton {
            screenName: barLayout.screenName
            barWindow: barLayout.barWindow
        }
    }
    Component {
        id: idleInhibitorComp
        IdleInhibitorWidget {}
    }

    // Left zone
    Row {
        id: leftZone

        height: parent.height
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        spacing: Theme.spacingSmall

        Repeater {
            model: barLayout.widgetLayoutForZone("left")
            Item {
                required property var modelData
                readonly property string widgetId: modelData
                width: leftWidgetLoader.implicitWidth
                height: parent.height
                anchors.verticalCenter: parent.verticalCenter

                Loader {
                    id: leftWidgetLoader
                    sourceComponent: barLayout.widgetComponentForId(parent.widgetId)
                    anchors.verticalCenter: parent.verticalCenter
                }

                HoverHandler {
                    id: leftHoverHandler
                    onHoveredChanged: {
                        if (hovered && leftWidgetLoader.item)
                            barLayout.showTooltip(leftWidgetLoader.item)
                        else
                            barLayout.hideTooltip()
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
        spacing: Theme.spacingSmall

        Repeater {
            model: barLayout.widgetLayoutForZone("center")
            Item {
                required property var modelData
                readonly property string widgetId: modelData
                width: centerWidgetLoader.implicitWidth
                height: parent.height
                anchors.verticalCenter: parent.verticalCenter

                Loader {
                    id: centerWidgetLoader
                    sourceComponent: barLayout.widgetComponentForId(parent.widgetId)
                    anchors.verticalCenter: parent.verticalCenter
                }

                HoverHandler {
                    id: centerHoverHandler
                    onHoveredChanged: {
                        if (hovered && centerWidgetLoader.item)
                            barLayout.showTooltip(centerWidgetLoader.item)
                        else
                            barLayout.hideTooltip()
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
        spacing: Theme.spacingSmall

        Repeater {
            model: barLayout.widgetLayoutForZone("right")
            Item {
                required property var modelData
                readonly property string widgetId: modelData
                width: rightWidgetLoader.implicitWidth
                height: parent.height
                anchors.verticalCenter: parent.verticalCenter

                Loader {
                    id: rightWidgetLoader
                    sourceComponent: barLayout.widgetComponentForId(parent.widgetId)
                    anchors.verticalCenter: parent.verticalCenter
                }

                HoverHandler {
                    id: rightHoverHandler
                    onHoveredChanged: {
                        if (hovered && rightWidgetLoader.item)
                            barLayout.showTooltip(rightWidgetLoader.item)
                        else
                            barLayout.hideTooltip()
                    }
                }
            }
        }
    }
}
