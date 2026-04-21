pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import "../../../config"
import "../../../services/ui"
import "../../popups"

Item {
    id: widget

    required property string screenName
    required property PanelWindow barWindow

    implicitWidth: label.implicitWidth
    implicitHeight: label.implicitHeight

    Text {
        id: label
        anchors.centerIn: parent
        text: "\u23FB"
        color: Theme.foregroundColor
        font.pixelSize: Theme.fontSizeNormal
        font.family: Theme.fontFamily
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            const pos = widget.mapToItem(null, 0, 0);
            ShellUI.openPopup(widget.screenName, "session", sessionMenuComponent, pos.x);
        }
    }

    Component {
        id: sessionMenuComponent
        SessionMenu {
            screenName: widget.screenName
        }
    }
}
