import QtQuick
import QtQuick.Layouts
import "../../config"
import "widgets"

RowLayout {
    id: barLayout

    required property string screenName

    anchors.fill: parent
    anchors.leftMargin: Theme.paddingNormal
    anchors.rightMargin: Theme.paddingNormal

    spacing: Theme.spacingNormal

    // Left zone: launcher button, workspaces, active window title
    RowLayout {
        Layout.fillHeight: true
        Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
        spacing: Theme.spacingSmall

        WorkspacesWidget {
            screenName: barLayout.screenName
        }

        ActiveWindowWidget {
            screenName: barLayout.screenName
            Layout.fillWidth: true
        }
    }

    // Center zone: clock/date
    Text {
        Layout.fillHeight: true
        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
        text: "Clock"
        color: Theme.foregroundColor
        font.pixelSize: Theme.fontSizeNormal
        font.family: Theme.fontFamily
        verticalAlignment: Text.AlignVCenter
    }

    // Right zone: network, volume, battery, notification, tray, session
    RowLayout {
        Layout.fillHeight: true
        Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
        spacing: Theme.spacingSmall

        Text {
            text: "Net"
            color: Theme.mutedColor
            font.pixelSize: Theme.fontSizeSmall
            font.family: Theme.fontFamily
        }

        Text {
            text: "Vol"
            color: Theme.mutedColor
            font.pixelSize: Theme.fontSizeSmall
            font.family: Theme.fontFamily
        }

        Text {
            text: "Bat"
            color: Theme.mutedColor
            font.pixelSize: Theme.fontSizeSmall
            font.family: Theme.fontFamily
        }

        Text {
            text: "&#128276;"
            color: Theme.mutedColor
            font.pixelSize: Theme.fontSizeSmall
            font.family: Theme.fontFamily
        }

        Text {
            text: "Tray"
            color: Theme.mutedColor
            font.pixelSize: Theme.fontSizeSmall
            font.family: Theme.fontFamily
        }

        Text {
            text: "&#9211;"
            color: Theme.foregroundColor
            font.pixelSize: Theme.fontSizeNormal
            font.family: Theme.fontFamily
        }
    }
}
