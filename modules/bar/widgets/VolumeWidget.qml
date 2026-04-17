import QtQuick
import "../../../config"
import "../../../services/system"

Item {
    id: widget

    implicitWidth: text.implicitWidth
    implicitHeight: text.implicitHeight

    readonly property real _volumePercent: Math.round(Audio.volume * 100)

    Component.onCompleted: {
        console.log("VolumeWidget loaded, volume:", Audio.volume, "muted:", Audio.muted)
    }
    
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
