pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import "../../../components"
import "../../../config"

Item {
    id: row

    property string iconSource: ""
    property color iconColor: Theme.foregroundColor
    property string label: ""
    property string trailingIcon: ""
    property color trailingColor: Theme.foregroundColor
    property bool showChevron: false
    property bool destructive: false

    signal clicked()

    width: parent.width
    implicitHeight: contentRow.implicitHeight + Theme.paddingSmall * 2

    Rectangle {
        anchors.fill: parent
        radius: Theme.radiusSmall
        color: hoverArea.containsMouse && row.enabled
            ? Qt.alpha(row.destructive ? Theme.errorColor : Theme.accentColor, 0.15)
            : "transparent"
        Behavior on color {
            ColorAnimation { duration: Theme.listHighlightDuration }
        }
    }

    RowLayout {
        id: contentRow

        spacing: Theme.spacingSmall

        anchors {
            verticalCenter: parent.verticalCenter
            left: parent.left
            right: parent.right
            leftMargin: Theme.paddingSmall
            rightMargin: Theme.paddingSmall
        }
        SvgIcon {
            source: row.iconSource
            color: row.destructive ? Theme.errorColor : row.iconColor
            iconSize: Theme.fontSizeSmall
            visible: row.iconSource !== ""
            Layout.preferredWidth: Theme.iconSizeSmall
            Layout.preferredHeight: Theme.iconSizeSmall
        }
        Text {
            text: row.label
            color: row.destructive ? Theme.errorColor : (row.enabled ? Theme.foregroundColor : Theme.mutedColor)
            font.pixelSize: Theme.fontSizeSmall
            font.family: Theme.fontFamily
            Layout.fillWidth: true
            elide: Text.ElideRight
        }
        SvgIcon {
            source: row.trailingIcon
            color: row.trailingColor
            iconSize: Theme.fontSizeSmall
            visible: row.trailingIcon !== ""
            Layout.preferredWidth: Theme.iconSizeSmall
            Layout.preferredHeight: Theme.iconSizeSmall
        }
        SvgIcon {
            source: "icons/outline/chevron-right.svg"
            color: Theme.mutedColor
            iconSize: Theme.fontSizeSmall
            visible: row.showChevron
            Layout.preferredWidth: Theme.iconSizeSmall
            Layout.preferredHeight: Theme.iconSizeSmall
        }
    }

    MouseArea {
        id: hoverArea

        anchors.fill: parent
        hoverEnabled: true
        enabled: row.enabled

        onClicked: row.clicked()
    }
}
