pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import "../../config"
import "widgets"

Item {
    id: barLayout

    required property string screenName
    required property PanelWindow barWindow

    anchors.fill: parent
    anchors.leftMargin: Theme.paddingNormal
    anchors.rightMargin: Theme.paddingNormal

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

    // Left zone
    Row {
        id: leftZone

        height: parent.height
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        spacing: Theme.spacingSmall

        Repeater {
            model: barLayout.widgetLayoutForZone("left")
            Loader {
                required property var modelData
                sourceComponent: barLayout.widgetComponentForId(modelData)
                anchors.verticalCenter: parent.verticalCenter
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
            Loader {
                required property var modelData
                sourceComponent: barLayout.widgetComponentForId(modelData)
                anchors.verticalCenter: parent.verticalCenter
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
            Loader {
                required property var modelData
                sourceComponent: barLayout.widgetComponentForId(modelData)
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }
}
