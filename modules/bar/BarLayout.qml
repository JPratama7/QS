import QtQuick
import QtQuick.Layouts
import "../../config"

RowLayout {
    id: barLayout

    anchors.fill: parent
    anchors.leftMargin: Theme.paddingNormal
    anchors.rightMargin: Theme.paddingNormal

    spacing: Theme.spacingNormal

    // Left zone: launcher button, workspaces, active window title
    RowLayout {
        Layout.fillHeight: true
        Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
        spacing: Theme.spacingSmall

        Text {
            text: "☰"
            color: Theme.foregroundColor
            font.pixelSize: Theme.fontSizeNormal
            font.family: Theme.fontFamily
        }

        Text {
            text: "Workspaces"
            color: Theme.mutedColor
            font.pixelSize: Theme.fontSizeSmall
            font.family: Theme.fontFamily
        }

        Text {
            text: "Active Window"
            color: Theme.mutedColor
            font.pixelSize: Theme.fontSizeSmall
            font.family: Theme.fontFamily
            Layout.fillWidth: true
            elide: Text.ElideRight
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
            text: "🔔"
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
            text: "⏻"
            color: Theme.foregroundColor
            font.pixelSize: Theme.fontSizeNormal
            font.family: Theme.fontFamily
        }
    }
}
