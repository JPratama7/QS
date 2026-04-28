pragma ComponentBehavior: Bound

import QtQuick
import "../../../config"
import "../../../components/bar"
import "../../../services/launcher"

BaseWidget {
    id: widget

    required property string screenName

    tooltipComponent: Component {
        Text {
            text: "Launcher"
            font.pixelSize: Theme.fontSizeSmall
            color: Theme.foregroundColor
        }
    }

    implicitWidth: label.implicitWidth + Theme.paddingSmall * 2
    implicitHeight: label.implicitHeight + Theme.paddingSmall * 2

    Rectangle {
        anchors.fill: parent
        radius: Theme.radiusSmall
        color: mouseArea.containsMouse ? Qt.alpha(Theme.foregroundColor, 0.1) : "transparent"
    }

    Text {
        id: label
        anchors.centerIn: parent
        text: "\u2630"
        color: Theme.foregroundColor
        font.pixelSize: Theme.fontSizeNormal
        font.family: Theme.fontFamily
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: Launcher.open(widget.screenName)
    }
}
