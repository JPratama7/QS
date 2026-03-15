import QtQuick
import "../config" as Config

Rectangle {
    id: root

    default property alias content: container.data

    property color bgColor: Config.Theme.widgetBg
    property int horizontalPadding: Config.Theme.widgetPadding
    property int verticalPadding: 0

    color: bgColor
    radius: height / 2 // Dynamically maintain a perfect pill shape

    implicitWidth: container.implicitWidth + (horizontalPadding * 2)
    implicitHeight: container.implicitHeight + (verticalPadding * 2)

    Column {
        id: container
        anchors.centerIn: parent
        spacing: 0
    }
}
