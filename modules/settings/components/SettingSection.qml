pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import "../../../config"

ColumnLayout {
    id: root

    property string title: ""
    default property alias content: innerLayout.data

    Layout.fillWidth: true
    spacing: 15

    Text {
        text: root.title
        color: Theme.accentColor
        font.pixelSize: Theme.fontSizeLarge
        font.bold: true
    }

    Rectangle {
        Layout.fillWidth: true
        height: 1
        color: Theme.surfaceColor
    }

    ColumnLayout {
        id: innerLayout
        Layout.fillWidth: true
        spacing: 15
    }
}
