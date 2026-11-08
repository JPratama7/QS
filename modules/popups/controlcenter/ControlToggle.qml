pragma ComponentBehavior: Bound

import QtQuick
import "../../../components"
import "../../../config"

// Quick-settings toggle tile: icon + switch on top, label below. On state gets
// the accentSoft fill + accentBorder ring (DESIGN_GUIDE.md §2 toggle grid).
Item {
    id: toggle

    property string iconSource: ""
    property string label: ""
    property bool checked: false

    signal toggled()

    implicitHeight: column.implicitHeight + Theme.paddingNormal * 2
    implicitWidth: parent.width

    Rectangle {
        anchors.fill: parent
        radius: Theme.radiusInner
        color: toggle.checked ? Theme.accentSoft : Qt.alpha(Theme.foregroundColor, 0.05)
        border.width: 1
        border.color: toggle.checked ? Theme.accentBorder : "transparent"

        Behavior on color {
            ColorAnimation { duration: Theme.hoverDuration }
        }
        Behavior on border.color {
            ColorAnimation { duration: Theme.hoverDuration }
        }
    }

    Column {
        id: column

        anchors {
            fill: parent
            margins: Theme.paddingNormal
        }
        spacing: Theme.spacingSmall

        Row {
            width: parent.width
            spacing: Theme.spacingSmall

            SvgIcon {
                id: icon

                source: toggle.iconSource
                iconSize: 16
                color: toggle.checked ? Theme.accentColor : Theme.mutedColor
                anchors.verticalCenter: parent.verticalCenter
            }
            Item {
                width: parent.width - icon.width - toggleSwitch.width - parent.spacing
                height: 1
            }
            ToggleSwitch {
                id: toggleSwitch

                checked: toggle.checked
                anchors.verticalCenter: parent.verticalCenter

                // Switch swallows clicks over it — forward to the tile
                onToggled: toggle.toggled()
            }
        }
        Text {
            text: toggle.label
            color: toggle.checked ? Theme.foregroundColor : Theme.mutedColor
            font.pixelSize: Theme.fontSizeSmall
            font.family: Theme.fontFamily

            Behavior on color {
                ColorAnimation { duration: Theme.hoverDuration }
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        onClicked: toggle.toggled()
    }
}
