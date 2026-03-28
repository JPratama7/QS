pragma ComponentBehavior: Bound
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

    Binding on implicitWidth { value: container.implicitWidth + (root.horizontalPadding * 2) }
    Binding on implicitHeight { value: container.implicitHeight + (root.verticalPadding * 2) }

    Column {
        id: container
        anchors.centerIn: parent
        spacing: 0
    }
}
