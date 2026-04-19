pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import "../../config"
import "widgets"

RowLayout {
    id: barLayout

    required property string screenName
    required property PanelWindow barWindow

    anchors.fill: parent
    anchors.leftMargin: Theme.paddingNormal
    anchors.rightMargin: Theme.paddingNormal

    spacing: Theme.spacingNormal

    // Left zone: launcher button, workspaces, active window title
    RowLayout {
        Layout.fillHeight: true
        Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
        spacing: Theme.spacingSmall

        LauncherButton {
            screenName: barLayout.screenName
        }

        WorkspacesWidget {
            screenName: barLayout.screenName
        }

        ActiveWindowWidget {
            screenName: barLayout.screenName
            Layout.fillWidth: true
        }
    }

    // Center zone: clock/date
    ClockWidget {
        Layout.fillHeight: true
        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
    }

    // Right zone: network, volume, battery, notification, tray, session
    RowLayout {
        Layout.fillHeight: true
        Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
        spacing: Theme.spacingSmall

        NetworkWidget {}

        VolumeWidget {}

        BatteryWidget {}

        NotificationIndicatorWidget {}

        TrayWidget {
            screenName: barLayout.screenName
            barWindow: barLayout.barWindow
        }

        SessionMenuButton {
            screenName: barLayout.screenName
            barWindow: barLayout.barWindow
        }
    }
}
