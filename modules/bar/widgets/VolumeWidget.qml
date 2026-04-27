pragma ComponentBehavior: Bound

import QtQuick
import "../../../config"
import "../../../services/system"

Item {
    id: widget

    property Component tooltipComponent: Component {
        Text {
            text: Audio.muted ? "Muted" : "Volume: " + Math.round(Audio.volume * 100) + "%"
            font.pixelSize: Theme.fontSizeSmall
            color: Theme.foregroundColor
        }
    }

    implicitWidth: text.implicitWidth
    implicitHeight: text.implicitHeight

    readonly property real _volumePercent: Math.round(Audio.volume * 100)

    Text {
        id: text
        text: Audio.muted ? "Mute" : widget._volumePercent + "%"
        color: Audio.muted ? Theme.mutedColor : Theme.foregroundColor
        font.pixelSize: Theme.fontSizeSmall
        font.family: Theme.fontFamily
    }

    MouseArea {
        anchors.fill: parent
        onClicked: Audio.toggleMute()
    }
}
